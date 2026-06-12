package com.neverdisband.controller;

import com.neverdisband.dao.CompositionDao;
import com.neverdisband.dao.UserDao;
import com.neverdisband.model.Composition;
import com.neverdisband.model.CompositionSlot;
import com.neverdisband.model.User;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/compositions")
public class CompositionController {

    private final CompositionDao compositionDao;
    private final UserDao userDao;

    public CompositionController(CompositionDao compositionDao, UserDao userDao) {
        this.compositionDao = compositionDao;
        this.userDao = userDao;
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

        // 슬롯 교체 (삭제 후 재삽입)
        compositionDao.deleteSlotsByCompositionId(id);
        saveSlots(id, body);

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
        return ResponseEntity.ok(Map.of("success", true));
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
