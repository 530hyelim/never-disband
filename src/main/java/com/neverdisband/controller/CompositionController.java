package com.neverdisband.controller;

import com.neverdisband.dao.CompositionDao;
import com.neverdisband.dao.UserDao;
import com.neverdisband.model.Composition;
import com.neverdisband.model.CompositionSlot;
import com.neverdisband.model.User;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/compositions")
public class CompositionController {

    private final CompositionDao compositionDao;
    private final UserDao userDao;
    private final SimpMessagingTemplate messagingTemplate;

    public CompositionController(CompositionDao compositionDao, UserDao userDao, SimpMessagingTemplate messagingTemplate) {
        this.compositionDao = compositionDao;
        this.userDao = userDao;
        this.messagingTemplate = messagingTemplate;
    }

    /**
     * 내 빌드 목록 조회
     */
    @GetMapping
    public ResponseEntity<?> list(HttpSession session) {
        Long userId = getUserId(session);
        if (userId == null) return ResponseEntity.status(401).body(Map.of("message", "로그인이 필요합니다."));

        List<Composition> comps = compositionDao.findByUserId(userId);
        // 슬롯 정보도 채워주기
        for (Composition comp : comps) {
            comp.setSlots(compositionDao.findSlotsByCompositionId(comp.getId()));
        }
        return ResponseEntity.ok(comps);
    }

    /**
     * 빌드 상세 조회
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> get(@PathVariable Long id, HttpSession session) {
        Long userId = getUserId(session);
        if (userId == null) return ResponseEntity.status(401).body(Map.of("message", "로그인이 필요합니다."));

        Composition comp = compositionDao.findById(id);
        if (comp == null || !comp.getUserId().equals(userId)) {
            return ResponseEntity.status(404).body(Map.of("message", "빌드를 찾을 수 없습니다."));
        }
        comp.setSlots(compositionDao.findSlotsByCompositionId(comp.getId()));
        return ResponseEntity.ok(comp);
    }

    /**
     * 빌드 생성
     */
    @PostMapping
    public ResponseEntity<?> create(@RequestBody Map<String, Object> body, HttpSession session) {
        Long userId = getUserId(session);
        if (userId == null) return ResponseEntity.status(401).body(Map.of("message", "로그인이 필요합니다."));

        String name = (String) body.get("name");
        if (name == null || name.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "빌드 이름을 입력해주세요."));
        }

        Boolean isPublic = (Boolean) body.getOrDefault("isPublic", false);

        Composition comp = new Composition(userId, name.trim(), isPublic);
        Long compId = compositionDao.insert(comp);

        // 슬롯 저장
        saveSlots(compId, body);

        return ResponseEntity.ok(Map.of("success", true, "id", compId));
    }

    /**
     * 빌드 수정
     */
    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, @RequestBody Map<String, Object> body, HttpSession session) {
        Long userId = getUserId(session);
        if (userId == null) return ResponseEntity.status(401).body(Map.of("message", "로그인이 필요합니다."));

        Composition comp = compositionDao.findById(id);
        if (comp == null || !comp.getUserId().equals(userId)) {
            return ResponseEntity.status(404).body(Map.of("message", "빌드를 찾을 수 없습니다."));
        }

        String name = (String) body.get("name");
        if (name != null && !name.trim().isEmpty()) comp.setName(name.trim());
        Boolean isPublic = (Boolean) body.get("isPublic");
        if (isPublic != null) comp.setPublic(isPublic);

        compositionDao.update(comp);

        // 슬롯 스마트 업데이트: 기존 ID 유지, 새 슬롯 insert, 삭제된 슬롯만 delete
        syncSlots(id, body);

        messagingTemplate.convertAndSend("/topic/compositions/" + id, Map.of("action", "update", "id", id));
        return ResponseEntity.ok(Map.of("success", true));
    }

    /**
     * 빌드 삭제
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id, HttpSession session) {
        Long userId = getUserId(session);
        if (userId == null) return ResponseEntity.status(401).body(Map.of("message", "로그인이 필요합니다."));

        Composition comp = compositionDao.findById(id);
        if (comp == null || !comp.getUserId().equals(userId)) {
            return ResponseEntity.status(404).body(Map.of("message", "빌드를 찾을 수 없습니다."));
        }

        compositionDao.deleteById(id);
        messagingTemplate.convertAndSend("/topic/compositions/" + id, Map.of("action", "delete", "id", id));
        return ResponseEntity.ok(Map.of("success", true));
    }

    @SuppressWarnings("unchecked")
    private void syncSlots(Long compId, Map<String, Object> body) {
        List<Map<String, Object>> incomingSlots = (List<Map<String, Object>>) body.get("slots");
        if (incomingSlots == null) incomingSlots = List.of();

        List<CompositionSlot> existingSlots = compositionDao.findSlotsByCompositionId(compId);

        // 들어온 슬롯의 ID 수집
        java.util.Set<Long> incomingIds = new java.util.HashSet<>();
        for (Map<String, Object> s : incomingSlots) {
            Object idObj = s.get("id");
            if (idObj != null) incomingIds.add(((Number) idObj).longValue());
        }

        // 기존에 있었는데 들어오지 않은 슬롯 → 삭제 (참여자 slot_id도 null로)
        for (CompositionSlot existing : existingSlots) {
            if (!incomingIds.contains(existing.getId())) {
                // 해당 슬롯을 참조하는 participants의 slot_id를 null로
                compositionDao.deleteSlotById(existing.getId());
            }
        }

        // 들어온 슬롯 처리
        for (int i = 0; i < incomingSlots.size(); i++) {
            Map<String, Object> s = incomingSlots.get(i);
            Object idObj = s.get("id");

            CompositionSlot slot = new CompositionSlot();
            slot.setCompositionId(compId);
            slot.setSlotOrder(i + 1);
            slot.setRole(CompositionSlot.Role.valueOf((String) s.getOrDefault("role", "OFF_TANK")));
            slot.setWeapon((String) s.get("weapon"));
            slot.setOffhand((String) s.get("offhand"));
            slot.setHead((String) s.get("head"));
            slot.setChest((String) s.get("chest"));
            slot.setShoes((String) s.get("shoes"));
            slot.setCape((String) s.get("cape"));
            slot.setFood((String) s.get("food"));

            if (idObj != null) {
                // 기존 슬롯 업데이트
                slot.setId(((Number) idObj).longValue());
                compositionDao.updateSlot(slot);
            } else {
                // 새 슬롯 삽입
                compositionDao.insertSlot(slot);
            }
        }
    }

    @SuppressWarnings("unchecked")
    private void saveSlots(Long compId, Map<String, Object> body) {
        List<Map<String, Object>> slots = (List<Map<String, Object>>) body.get("slots");
        if (slots == null) return;

        for (int i = 0; i < slots.size(); i++) {
            Map<String, Object> s = slots.get(i);
            CompositionSlot slot = new CompositionSlot();
            slot.setCompositionId(compId);
            slot.setSlotOrder(i + 1);
            slot.setRole(CompositionSlot.Role.valueOf((String) s.getOrDefault("role", "DPS")));
            slot.setWeapon((String) s.get("weapon"));
            slot.setOffhand((String) s.get("offhand"));
            slot.setHead((String) s.get("head"));
            slot.setChest((String) s.get("chest"));
            slot.setShoes((String) s.get("shoes"));
            slot.setCape((String) s.get("cape"));
            slot.setFood((String) s.get("food"));
            compositionDao.insertSlot(slot);
        }
    }

    private Long getUserId(HttpSession session) {
        String discordId = (String) session.getAttribute("user_discord_id");
        if (discordId == null) return null;
        Optional<User> user = userDao.findByDiscordId(discordId);
        return user.map(User::getId).orElse(null);
    }
}
