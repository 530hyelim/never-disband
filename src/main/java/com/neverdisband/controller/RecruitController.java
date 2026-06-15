package com.neverdisband.controller;

import com.neverdisband.dao.CompositionDao;
import com.neverdisband.dao.GuildDao;
import com.neverdisband.dao.GuildMemberDao;
import com.neverdisband.dao.GuildPageDao;
import com.neverdisband.dao.RecruitParticipantDao;
import com.neverdisband.dao.RecruitPostDao;
import com.neverdisband.dao.UserDao;
import com.neverdisband.model.Guild;
import com.neverdisband.model.GuildMember;
import com.neverdisband.model.GuildPage;
import com.neverdisband.model.PageType;
import com.neverdisband.model.RecruitPost;
import com.neverdisband.service.AlbionItemService;
import com.neverdisband.service.DiscordBotService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Controller
@RequestMapping("/{subdomain}/recruit")
public class RecruitController {

    private static final int CONTENT_MAX_LENGTH = 2000;

    private final GuildDao guildDao;
    private final GuildMemberDao guildMemberDao;
    private final GuildPageDao guildPageDao;
    private final RecruitPostDao recruitPostDao;
    private final RecruitParticipantDao participantDao;
    private final UserDao userDao;
    private final CompositionDao compositionDao;
    private final AlbionItemService albionItemService;
    private final DiscordBotService discordBotService;
    private final SimpMessagingTemplate messagingTemplate;

    public RecruitController(GuildDao guildDao, GuildMemberDao guildMemberDao,
                             GuildPageDao guildPageDao, RecruitPostDao recruitPostDao,
                             RecruitParticipantDao participantDao, UserDao userDao,
                             CompositionDao compositionDao, AlbionItemService albionItemService,
                             DiscordBotService discordBotService,
                             SimpMessagingTemplate messagingTemplate) {
        this.guildDao = guildDao;
        this.guildMemberDao = guildMemberDao;
        this.guildPageDao = guildPageDao;
        this.recruitPostDao = recruitPostDao;
        this.participantDao = participantDao;
        this.userDao = userDao;
        this.compositionDao = compositionDao;
        this.albionItemService = albionItemService;
        this.discordBotService = discordBotService;
        this.messagingTemplate = messagingTemplate;
    }

    @GetMapping
    public String recruitPage(@PathVariable String subdomain, HttpSession session, Model model) {
        var result = validateMember(subdomain, session);
        if (result.errorRedirect != null) return result.errorRedirect;

        Optional<GuildPage> recruitPage = guildPageDao.findByGuildIdAndType(result.guild.getId(), PageType.RECRUIT);
        boolean hasChannel = recruitPage.isPresent() && recruitPage.get().getDiscordChannelId() != null;

        // 채널 읽기 권한 확인 — 권한 없으면 에러 메시지 노출
        var currentUser = userDao.findById(result.member.getUserId());
        if (hasChannel && currentUser.isPresent()) {
            boolean canView = discordBotService.hasViewChannelPermission(
                    result.guild.getDiscordGuildId(), currentUser.get().getDiscordId(),
                    recruitPage.get().getDiscordChannelId());
            if (!canView) {
                model.addAttribute("guild", result.guild);
                model.addAttribute("accessDenied", true);
                model.addAttribute("accessDeniedMessage", "해당 디스코드 채널에 접근 권한이 없습니다.");
                return "fragments/recruit";
            }
        }

        model.addAttribute("guild", result.guild);
        model.addAttribute("hasChannel", hasChannel);
        model.addAttribute("channelName", hasChannel ? recruitPage.get().getDiscordChannelName() : null);
        model.addAttribute("currentMemberId", result.member.getId());
        // 길드마스터 여부
        boolean isGuildMaster = guildMemberDao.isGuildMaster(result.member.getId());
        model.addAttribute("isGuildMaster", isGuildMaster);
        // CONTENTS_LEADER 여부 (mandatory 설정 가능)
        boolean canSetMandatory = isGuildMaster || guildMemberDao.hasRole(result.member.getId(), com.neverdisband.model.GuildRole.CONTENTS_LEADER);
        model.addAttribute("canSetMandatory", canSetMandatory);
        // 디스코드 @everyone/@here 멘션 권한 확인 (채널별 permission overwrite 반영)
        boolean canMentionEveryone = false;
        if (currentUser.isPresent() && hasChannel) {
            canMentionEveryone = discordBotService.hasMentionEveryonePermission(
                    result.guild.getDiscordGuildId(), currentUser.get().getDiscordId(),
                    recruitPage.get().getDiscordChannelId());
        }
        model.addAttribute("canMentionEveryone", canMentionEveryone);
        return "fragments/recruit";
    }

    /**
     * 포스트 목록 + 각 포스트의 참여자 목록 조회
     * 반환: [ { post 필드들..., participants: [ { memberId, characterName, discordId, avatarUrl } ] } ]
     */
    @GetMapping("/posts")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getPosts(
            @PathVariable String subdomain, HttpSession session) {

        var result = validateMember(subdomain, session);
        if (result.errorRedirect != null) return ResponseEntity.status(403).build();

        List<RecruitPost> posts = recruitPostDao.findByGuildId(result.guild.getId());
        List<Map<String, Object>> response = new ArrayList<>();

        for (RecruitPost post : posts) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", post.getId());
            item.put("guildId", post.getGuildId());
            item.put("leaderMemberId", post.getLeaderMemberId());
            item.put("leaderCharacterName", post.getLeaderCharacterName());
            item.put("content", post.getContent());
            item.put("scheduledAt", post.getScheduledAt() != null ? post.getScheduledAt().toString() : null);
            item.put("minMembers", post.getMinMembers());
            item.put("maxMembers", post.getMaxMembers());
            item.put("compositionName", post.getCompositionName());
            item.put("compositionId", post.getCompositionId());
            item.put("status", post.getStatus().name());
            item.put("source", post.getSource().name());
            item.put("mandatory", post.getMandatory());
            item.put("createdAt", post.getCreatedAt().toString());

            // 참여자 목록 — 전부 DB에서 조회 (파티장도 participants에 insert하는 구조)
            // 파티장이 아직 참여 안 했으면 fallback으로 맨 앞에 추가
            List<Map<String, Object>> rawParticipants = participantDao.findParticipantsByPostId(post.getId());
            List<Map<String, Object>> participants = new ArrayList<>();

            boolean leaderInParticipants = rawParticipants.stream()
                    .anyMatch(p -> ((Number) p.get("member_id")).longValue() == post.getLeaderMemberId());

            if (!leaderInParticipants) {
                // 파티장이 아직 슬롯 미선택 — 이름/아바타만 맨 앞에 표시
                participants.add(buildParticipantEntry(result.guild.getId(), post.getLeaderMemberId(), post.getLeaderCharacterName()));
            }

            for (Map<String, Object> p : rawParticipants) {
                Long memberId = ((Number) p.get("member_id")).longValue();
                Map<String, Object> entry = new HashMap<>();
                entry.put("memberId", memberId);
                entry.put("characterName", p.get("character_name"));
                String discordId = (String) p.get("discord_id");
                String avatarHash = (String) p.get("avatar_hash");
                entry.put("avatarUrl", buildAvatarUrl(discordId, avatarHash));
                entry.put("slotId", p.get("slot_id"));
                // 파티장이면 맨 앞에, 아니면 뒤에
                if (memberId.equals(post.getLeaderMemberId())) {
                    participants.add(0, entry);
                } else {
                    participants.add(entry);
                }
            }

            item.put("participants", participants);
            item.put("participantCount", participants.size());
            response.add(item);
        }

        return ResponseEntity.ok(response);
    }

    /**
     * 참여 신청 / 취소 토글
     */
    @PostMapping("/posts/{postId}/join")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> toggleJoin(
            @PathVariable String subdomain,
            @PathVariable Long postId,
            HttpSession session) {

        var result = validateMember(subdomain, session);
        if (result.errorRedirect != null) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "권한이 없습니다."));
        }

        Optional<RecruitPost> postOpt = recruitPostDao.findById(postId);
        if (postOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("success", false, "message", "게시글을 찾을 수 없습니다."));
        }

        RecruitPost post = postOpt.get();
        if (post.getStatus() == RecruitPost.Status.CLOSED) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "모집이 마감된 컨텐츠입니다."));
        }

        Long memberId = result.member.getId();

        // maxMembers 초과 체크 (이미 참여한 경우는 취소 허용)
        boolean alreadyJoined = participantDao.exists(postId, memberId);
        if (!alreadyJoined && post.getMaxMembers() != null) {
            int currentCount = participantDao.countByPostId(postId);
            if (currentCount >= post.getMaxMembers()) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "인원이 가득 찼습니다."));
            }
        }

        if (alreadyJoined) {
            participantDao.delete(postId, memberId);
            // 음성채널 권한 회수
            if (post.getVoiceChannelId() != null) {
                var userOpt2 = userDao.findById(result.member.getUserId());
                if (userOpt2.isPresent()) {
                    discordBotService.removeChannelPermission(post.getVoiceChannelId(), userOpt2.get().getDiscordId());
                }
            }
            broadcastRecruitUpdate(result.guild.getSubdomain(), "join", postId);
            return ResponseEntity.ok(Map.of("success", true, "joined", false));
        } else {
            participantDao.insert(postId, memberId);
            broadcastRecruitUpdate(result.guild.getSubdomain(), "join", postId);
            return ResponseEntity.ok(Map.of("success", true, "joined", true));
        }
    }

    /**
     * 포스트 상태 변경 - 파티장 본인만 가능
     */
    @PostMapping("/posts/{postId}/status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateStatus(
            @PathVariable String subdomain,
            @PathVariable Long postId,
            @RequestParam String status,
            HttpSession session) {

        var result = validateMember(subdomain, session);
        if (result.errorRedirect != null) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "권한이 없습니다."));
        }

        Optional<RecruitPost> postOpt = recruitPostDao.findById(postId);
        if (postOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("success", false, "message", "게시글을 찾을 수 없습니다."));
        }

        if (!postOpt.get().getLeaderMemberId().equals(result.member.getId())) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "파티장만 변경할 수 있습니다."));
        }

        try {
            recruitPostDao.updateStatus(postId, RecruitPost.Status.valueOf(status));
            broadcastRecruitUpdate(result.guild.getSubdomain(), "status", postId);
            return ResponseEntity.ok(Map.of("success", true));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "잘못된 상태값입니다."));
        }
    }

    /**
     * 웹에서 모집글 작성
     */
    @PostMapping("/posts/create")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createPost(
            @PathVariable String subdomain,
            @RequestBody Map<String, Object> body,
            HttpSession session) {

        var result = validateMember(subdomain, session);
        if (result.errorRedirect != null) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "권한이 없습니다."));
        }

        String content = body.get("content") != null ? ((String) body.get("content")).trim() : "";
        if (content.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "내용을 입력해주세요."));
        }
        if (content.length() > CONTENT_MAX_LENGTH) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "내용은 2000자 이하여야 합니다."));
        }

        String mandatory = (String) body.get("mandatory");
        // mandatory는 길드마스터 또는 CONTENTS_LEADER만 설정 가능
        if ("Y".equals(mandatory)) {
            boolean canSetMandatory = guildMemberDao.isGuildMaster(result.member.getId())
                    || guildMemberDao.hasRole(result.member.getId(), com.neverdisband.model.GuildRole.CONTENTS_LEADER);
            if (!canSetMandatory) mandatory = "N";
        }
        String scheduledAt = (String) body.get("scheduledAt");
        Integer minMembers = body.get("minMembers") != null ? ((Number) body.get("minMembers")).intValue() : null;
        Integer maxMembers = body.get("maxMembers") != null ? ((Number) body.get("maxMembers")).intValue() : null;
        Long compositionId = body.get("compositionId") != null ? ((Number) body.get("compositionId")).longValue() : null;

        // scheduledAt 유효성 검사
        if (scheduledAt != null) {
            try { java.time.LocalDateTime.parse(scheduledAt); }
            catch (Exception e) { scheduledAt = null; }
        }

        RecruitPost post = new RecruitPost();
        post.setGuildId(result.guild.getId());
        post.setLeaderMemberId(result.member.getId());
        post.setContent(content);
        if (scheduledAt != null) post.setScheduledAt(java.time.LocalDateTime.parse(scheduledAt));
        post.setMinMembers(minMembers);
        post.setMaxMembers(maxMembers);
        post.setCompositionId(compositionId);
        post.setStatus(RecruitPost.Status.OPEN);
        post.setSource(RecruitPost.Source.SITE);
        post.setMandatory(mandatory != null ? mandatory : "N");

        // Discord 채널에 메시지 전송
        Optional<GuildPage> recruitPage = guildPageDao.findByGuildIdAndType(result.guild.getId(), PageType.RECRUIT);
        String discordMessageId = null;
        if (recruitPage.isPresent() && recruitPage.get().getDiscordChannelId() != null) {
            // 파티장의 채널 쓰기 권한 확인
            var postUser = userDao.findById(result.member.getUserId());
            if (postUser.isPresent()) {
                boolean canSend = discordBotService.hasSendMessagesPermission(
                        result.guild.getDiscordGuildId(), postUser.get().getDiscordId(),
                        recruitPage.get().getDiscordChannelId());
                if (!canSend) {
                    return ResponseEntity.status(403).body(Map.of("success", false, "message",
                            "디스코드 채널에 메시지를 보낼 권한이 없습니다."));
                }
            }
            discordMessageId = discordBotService.sendChannelMessage(
                    recruitPage.get().getDiscordChannelId(), content);
        }
        post.setDiscordMessageId(discordMessageId);

        Long postId = recruitPostDao.insert(post);
        // 리더를 participants에 자동 insert
        participantDao.insert(postId, result.member.getId());

        broadcastRecruitUpdate(result.guild.getSubdomain(), "create", postId);
        return ResponseEntity.ok(Map.of("success", true, "postId", postId));
    }

    /**
     * 포스트 수정 - 파티장 본인만 가능
     */
    @PostMapping("/posts/{postId}/edit")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> editPost(
            @PathVariable String subdomain,
            @PathVariable Long postId,
            @RequestBody Map<String, Object> body,
            HttpSession session) {

        var result = validateMember(subdomain, session);
        if (result.errorRedirect != null) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "권한이 없습니다."));
        }

        Optional<RecruitPost> postOpt = recruitPostDao.findById(postId);
        if (postOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("success", false, "message", "게시글을 찾을 수 없습니다."));
        }

        if (!postOpt.get().getLeaderMemberId().equals(result.member.getId())) {
            if (!guildMemberDao.isGuildMaster(result.member.getId())) {
                return ResponseEntity.status(403).body(Map.of("success", false, "message", "파티장만 수정할 수 있습니다."));
            }
        }

        RecruitPost post = postOpt.get();
        String mandatory = (String) body.get("mandatory");
        String scheduledAt = (String) body.get("scheduledAt");
        // scheduledAt 유효성 검사 — NaN이나 잘못된 형식이면 null 처리
        if (scheduledAt != null) {
            try {
                java.time.LocalDateTime.parse(scheduledAt);
            } catch (Exception e) {
                scheduledAt = null;
            }
        }
        Integer minMembers = body.get("minMembers") != null ? ((Number) body.get("minMembers")).intValue() : null;
        Integer maxMembers = body.get("maxMembers") != null ? ((Number) body.get("maxMembers")).intValue() : null;
        Long compositionId = body.get("compositionId") != null ? ((Number) body.get("compositionId")).longValue() : null;

        String mandatoryVal = mandatory != null ? mandatory : post.getMandatory();

        if (post.getSource() == RecruitPost.Source.DISCORD) {
            recruitPostDao.updateMetadata(postId, mandatoryVal,
                    scheduledAt, minMembers, maxMembers, compositionId);
        } else {
            String content = body.get("content") != null ? ((String) body.get("content")).trim() : post.getContent();
            if (content.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "내용을 입력해주세요."));
            }
            if (content.length() > CONTENT_MAX_LENGTH) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "내용은 2000자 이하여야 합니다."));
            }
            recruitPostDao.updatePost(postId, content, mandatoryVal,
                    scheduledAt, minMembers, maxMembers, compositionId);
        }

        broadcastRecruitUpdate(result.guild.getSubdomain(), "edit", postId);

        // Discord 메시지 동기화
        if (post.getDiscordMessageId() != null) {
            Optional<GuildPage> recruitPage = guildPageDao.findByGuildIdAndType(post.getGuildId(), PageType.RECRUIT);
            if (recruitPage.isPresent() && recruitPage.get().getDiscordChannelId() != null) {
                String finalContent = body.get("content") != null ? ((String) body.get("content")).trim() : post.getContent();
                discordBotService.editChannelMessage(
                        recruitPage.get().getDiscordChannelId(),
                        post.getDiscordMessageId(),
                        finalContent);
            }
        }

        return ResponseEntity.ok(Map.of("success", true));
    }

    /**
     * 모집 글에 연결된 조합의 슬롯 목록 조회
     * 반환: { slots: [...], filledSlotMemberIds: [...], maxMembers: N }
     */
    @GetMapping("/posts/{postId}/composition")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getPostComposition(
            @PathVariable String subdomain,
            @PathVariable Long postId,
            HttpSession session) {

        var result = validateMember(subdomain, session);
        if (result.errorRedirect != null) return ResponseEntity.status(403).build();

        Optional<RecruitPost> postOpt = recruitPostDao.findById(postId);
        if (postOpt.isEmpty()) return ResponseEntity.status(404).build();

        RecruitPost post = postOpt.get();
        if (post.getCompositionId() == null) {
            return ResponseEntity.status(404).body(Map.of("error", "조합이 없습니다."));
        }

        var slots = compositionDao.findSlotsByCompositionId(post.getCompositionId());

        // 모든 장비 unique name 수집 → 한글 이름 변환
        List<String> allItemNames = new ArrayList<>();
        for (var s : slots) {
            if (s.getWeapon() != null) allItemNames.add(s.getWeapon());
            if (s.getOffhand() != null) allItemNames.add(s.getOffhand());
            if (s.getHead() != null) allItemNames.add(s.getHead());
            if (s.getChest() != null) allItemNames.add(s.getChest());
            if (s.getShoes() != null) allItemNames.add(s.getShoes());
            if (s.getCape() != null) allItemNames.add(s.getCape());
            if (s.getFood() != null) allItemNames.add(s.getFood());
        }
        Map<String, String> displayNames = albionItemService.getDisplayNames(allItemNames);

        List<Map<String, Object>> slotList = new ArrayList<>();
        for (var s : slots) {
            Map<String, Object> m = new HashMap<>();
            m.put("id", s.getId());
            m.put("slotOrder", s.getSlotOrder());
            m.put("role", s.getRole().name());
            m.put("weapon", displayNames.getOrDefault(s.getWeapon(), s.getWeapon()));
            m.put("offhand", displayNames.getOrDefault(s.getOffhand(), s.getOffhand()));
            m.put("head", displayNames.getOrDefault(s.getHead(), s.getHead()));
            m.put("chest", displayNames.getOrDefault(s.getChest(), s.getChest()));
            m.put("shoes", displayNames.getOrDefault(s.getShoes(), s.getShoes()));
            m.put("cape", displayNames.getOrDefault(s.getCape(), s.getCape()));
            m.put("food", displayNames.getOrDefault(s.getFood(), s.getFood()));
            // 원본 unique name (이미지 URL용)
            m.put("weaponId", s.getWeapon());
            m.put("offhandId", s.getOffhand());
            m.put("headId", s.getHead());
            m.put("chestId", s.getChest());
            m.put("shoesId", s.getShoes());
            m.put("capeId", s.getCape());
            m.put("foodId", s.getFood());
            slotList.add(m);
        }

        // 현재 슬롯별로 어떤 참여자가 있는지 (slot_id 기준) — 파티장 포함
        List<Map<String, Object>> participants = participantDao.findParticipantsByPostId(postId);
        List<Map<String, Object>> participantList = new ArrayList<>();

        boolean leaderInParticipants = participants.stream()
                .anyMatch(p -> ((Number) p.get("member_id")).longValue() == post.getLeaderMemberId());

        if (!leaderInParticipants) {
            // 파티장 슬롯 미선택 상태 — slotId null로 추가
            Map<String, Object> leaderEntry = new HashMap<>();
            leaderEntry.put("memberId", post.getLeaderMemberId());
            leaderEntry.put("characterName", post.getLeaderCharacterName());
            leaderEntry.put("slotId", null);
            participantList.add(leaderEntry);
        }

        for (var p : participants) {
            Map<String, Object> m = new HashMap<>();
            Long mid = ((Number) p.get("member_id")).longValue();
            m.put("memberId", mid);
            m.put("characterName", p.get("character_name"));
            m.put("slotId", p.get("slot_id"));
            if (mid.equals(post.getLeaderMemberId())) {
                participantList.add(0, m);
            } else {
                participantList.add(m);
            }
        }

        Map<String, Object> response = new HashMap<>();
        response.put("slots", slotList);
        response.put("participants", participantList);
        response.put("maxMembers", post.getMaxMembers());
        response.put("compositionId", post.getCompositionId());
        return ResponseEntity.ok(response);
    }

    /**
     * 슬롯을 선택하여 참여 (조합이 있는 모집글)
     */
    @PostMapping("/posts/{postId}/join-slot")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> joinWithSlot(
            @PathVariable String subdomain,
            @PathVariable Long postId,
            @RequestBody Map<String, Object> body,
            HttpSession session) {

        var result = validateMember(subdomain, session);
        if (result.errorRedirect != null) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "권한이 없습니다."));
        }

        Optional<RecruitPost> postOpt = recruitPostDao.findById(postId);
        if (postOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("success", false, "message", "게시글을 찾을 수 없습니다."));
        }

        RecruitPost post = postOpt.get();
        if (post.getStatus() == RecruitPost.Status.CLOSED) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "모집이 마감된 컨텐츠입니다."));
        }

        Long memberId = result.member.getId();
        Long slotId = body.get("slotId") != null ? ((Number) body.get("slotId")).longValue() : null;

        // maxMembers 초과 체크 (신규 참여 시에만, 슬롯 변경은 허용)
        boolean alreadyJoined = participantDao.exists(postId, memberId);
        if (!alreadyJoined && slotId != null && post.getMaxMembers() != null) {
            int currentCount = participantDao.countByPostId(postId);
            if (currentCount >= post.getMaxMembers()) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "인원이 가득 찼습니다."));
            }
        }

        if (alreadyJoined) {
            if (slotId != null) {
                participantDao.updateSlot(postId, memberId, slotId);
            } else {
                participantDao.delete(postId, memberId);
                // 음성채널 권한 회수
                if (post.getVoiceChannelId() != null) {
                    var userOpt2 = userDao.findById(result.member.getUserId());
                    if (userOpt2.isPresent()) {
                        discordBotService.removeChannelPermission(post.getVoiceChannelId(), userOpt2.get().getDiscordId());
                    }
                }
            }
        } else {
            if (slotId != null) {
                participantDao.insertWithSlot(postId, memberId, slotId);
            } else {
                participantDao.insert(postId, memberId);
            }
        }

        broadcastRecruitUpdate(result.guild.getSubdomain(), "join", postId);
        return ResponseEntity.ok(Map.of("success", true));
    }

    /**
     * 포스트 삭제 - 파티장 본인만 가능
     */
    @PostMapping("/posts/{postId}/delete")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deletePost(
            @PathVariable String subdomain,
            @PathVariable Long postId,
            HttpSession session) {

        var result = validateMember(subdomain, session);
        if (result.errorRedirect != null) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "권한이 없습니다."));
        }

        Optional<RecruitPost> postOpt = recruitPostDao.findById(postId);
        if (postOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("success", false, "message", "게시글을 찾을 수 없습니다."));
        }

        if (!postOpt.get().getLeaderMemberId().equals(result.member.getId())) {
            if (!guildMemberDao.isGuildMaster(result.member.getId())) {
                return ResponseEntity.status(403).body(Map.of("success", false, "message", "파티장만 삭제할 수 있습니다."));
            }
        }

        recruitPostDao.deleteById(postId);
        broadcastRecruitUpdate(result.guild.getSubdomain(), "delete", postId);
        return ResponseEntity.ok(Map.of("success", true));
    }

    /**
     * 디스코드 채널에 알림 메시지 전송 (파티장만)
     */
    @PostMapping("/posts/{postId}/ping")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> pingPost(
            @PathVariable String subdomain,
            @PathVariable Long postId,
            @RequestBody Map<String, Object> body,
            HttpSession session) {

        var result = validateMember(subdomain, session);
        if (result.errorRedirect != null) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "권한이 없습니다."));
        }

        Optional<RecruitPost> postOpt = recruitPostDao.findById(postId);
        if (postOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("success", false, "message", "게시글을 찾을 수 없습니다."));
        }

        RecruitPost post = postOpt.get();
        // 길드마스터 여부 확인
        boolean isPingGuildMaster = guildMemberDao.isGuildMaster(result.member.getId());

        if (!post.getLeaderMemberId().equals(result.member.getId()) && !isPingGuildMaster) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "파티장만 알림을 보낼 수 있습니다."));
        }

        Optional<GuildPage> recruitPage = guildPageDao.findByGuildIdAndType(post.getGuildId(), PageType.RECRUIT);
        if (recruitPage.isEmpty() || recruitPage.get().getDiscordChannelId() == null) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "디스코드 채널이 연동되지 않았습니다."));
        }

        String channelId = recruitPage.get().getDiscordChannelId();

        // 길드마스터가 아닌 경우에만 채널 쓰기 권한 확인
        if (!isPingGuildMaster) {
            var pingUser = userDao.findById(result.member.getUserId());
            if (pingUser.isEmpty()) {
                return ResponseEntity.status(403).body(Map.of("success", false, "message", "유저 정보를 찾을 수 없습니다."));
            }
            if (!discordBotService.hasSendMessagesPermission(
                    result.guild.getDiscordGuildId(), pingUser.get().getDiscordId(), channelId)) {
                return ResponseEntity.status(403).body(Map.of("success", false, "message", "디스코드 채널에 메시지를 보낼 권한이 없습니다."));
            }
        }

        String mentionType = body.get("mention") != null ? (String) body.get("mention") : "";

        // @everyone, @here는 길드마스터이거나 디스코드 MENTION_EVERYONE 권한 보유자만 가능
        if (("everyone".equals(mentionType) || "here".equals(mentionType)) && !isPingGuildMaster) {
            var pingUser2 = userDao.findById(result.member.getUserId());
            if (pingUser2.isPresent()) {
                boolean canMention = discordBotService.hasMentionEveryonePermission(
                        result.guild.getDiscordGuildId(), pingUser2.get().getDiscordId(), channelId);
                if (!canMention) {
                    return ResponseEntity.status(403).body(Map.of("success", false, "message", "디스코드 서버에서 @everyone/@here 멘션 권한이 없습니다."));
                }
            }
        }

        // 멘션 문자열 생성
        String mentionPrefix = "";
        if ("everyone".equals(mentionType)) {
            mentionPrefix = "@everyone ";
        } else if ("here".equals(mentionType)) {
            mentionPrefix = "@here ";
        } else if ("participants".equals(mentionType)) {
            List<Map<String, Object>> participants = participantDao.findParticipantsByPostId(postId);
            StringBuilder sb = new StringBuilder();
            for (var p : participants) {
                String discordId = (String) p.get("discord_id");
                if (discordId != null) sb.append("<@").append(discordId).append("> ");
            }
            mentionPrefix = sb.toString();
        }

        // 메시지 링크 또는 내용
        String messageBody;
        if (post.getDiscordMessageId() != null) {
            messageBody = "https://discord.com/channels/"
                    + result.guild.getDiscordGuildId() + "/"
                    + channelId + "/"
                    + post.getDiscordMessageId();
        } else {
            messageBody = post.getContent().substring(0, Math.min(post.getContent().length(), 100))
                    + (post.getContent().length() > 100 ? "..." : "");
        }

        String pingContent = "📢 **모집 알림** — " + messageBody + "\n\n" + mentionPrefix;
        String msgId = discordBotService.sendChannelMessage(channelId, pingContent);
        if (msgId == null) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "디스코드 전송에 실패했습니다."));
        }

        return ResponseEntity.ok(Map.of("success", true));
    }

    /**
     * 음성채널 입장 — 채널 생성(없으면) + 이동 시도 + 실패 시 초대 링크 반환
     */
    @PostMapping("/posts/{postId}/voice")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> joinVoice(
            @PathVariable String subdomain,
            @PathVariable Long postId,
            HttpSession session) {

        var result = validateMember(subdomain, session);
        if (result.errorRedirect != null) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "권한이 없습니다."));
        }

        Optional<RecruitPost> postOpt = recruitPostDao.findById(postId);
        if (postOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("success", false, "message", "게시글을 찾을 수 없습니다."));
        }

        RecruitPost post = postOpt.get();

        // 참여자인지 확인
        Long memberId = result.member.getId();
        boolean isParticipant = participantDao.exists(postId, memberId) || memberId.equals(post.getLeaderMemberId());
        if (!isParticipant) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "참여자만 음성채널에 입장할 수 있습니다."));
        }

        // 유저의 discord ID
        var userOpt = userDao.findById(result.member.getUserId());
        if (userOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "유저 정보를 찾을 수 없습니다."));
        }
        String userDiscordId = userOpt.get().getDiscordId();

        String voiceChannelId = post.getVoiceChannelId();

        // 음성채널이 없으면 생성
        if (voiceChannelId == null) {
            // 참여자 discord ID 목록 수집
            List<Map<String, Object>> participants = participantDao.findParticipantsByPostId(postId);
            List<String> allowedIds = new java.util.ArrayList<>();
            for (var p : participants) {
                String dId = (String) p.get("discord_id");
                if (dId != null) allowedIds.add(dId);
            }

            // 파티장 디스코드 이름으로 채널명 설정
            var leaderMemberOpt = guildMemberDao.findById(post.getLeaderMemberId());
            String leaderDiscordName = "Never Disband";
            if (leaderMemberOpt != null) {
                var leaderUserOpt = userDao.findById(leaderMemberOpt.getUserId());
                if (leaderUserOpt.isPresent()) leaderDiscordName = leaderUserOpt.get().getUsername();
            }
            String channelName = leaderDiscordName;

            // 모집 채널의 카테고리 또는 guild 설정의 보이스 카테고리 사용
            String parentId = guildDao.getVoiceCategoryId(result.guild.getId());
            if (parentId == null) {
                Optional<GuildPage> recruitPage = guildPageDao.findByGuildIdAndType(result.guild.getId(), PageType.RECRUIT);
                if (recruitPage.isPresent() && recruitPage.get().getDiscordChannelId() != null) {
                    parentId = discordBotService.getChannelParentId(recruitPage.get().getDiscordChannelId());
                }
            }

            voiceChannelId = discordBotService.createVoiceChannel(
                    result.guild.getDiscordGuildId(), channelName, allowedIds, parentId);

            if (voiceChannelId == null) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "음성채널 생성에 실패했습니다."));
            }
            recruitPostDao.updateVoiceChannelId(postId, voiceChannelId);
        }

        // 유저에게 채널 접근 권한 부여 (이미 있으면 무시됨)
        discordBotService.addChannelPermission(voiceChannelId, userDiscordId);

        // 유저 이동 시도
        boolean moved = discordBotService.moveUserToVoice(result.guild.getDiscordGuildId(), userDiscordId, voiceChannelId);
        if (moved) {
            return ResponseEntity.ok(Map.of("success", true, "moved", true));
        }

        // 이동 실패 (유저가 음성채널에 없음) → 초대 링크 생성
        String inviteUrl = discordBotService.createChannelInvite(voiceChannelId);
        if (inviteUrl != null) {
            return ResponseEntity.ok(Map.of("success", true, "moved", false, "inviteUrl", inviteUrl));
        }

        return ResponseEntity.ok(Map.of("success", true, "moved", false, "message", "초대 링크 생성에 실패했습니다. Discord에서 직접 입장해주세요."));
    }

    /**
     * 길드 멤버가 공개로 설정한 빌드 목록 (본인 제외)
     */
    @GetMapping("/compositions/public")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getPublicCompositions(
            @PathVariable String subdomain, HttpSession session) {

        var result = validateMember(subdomain, session);
        if (result.errorRedirect != null) return ResponseEntity.status(403).build();

        List<Map<String, Object>> comps = compositionDao.findPublicByGuildId(result.guild.getId(), result.member.getUserId());
        return ResponseEntity.ok(comps);
    }

    // === 내부 헬퍼 ===

    private void broadcastRecruitUpdate(String subdomain, String action, Long postId) {
        messagingTemplate.convertAndSend(
                "/topic/guild/" + subdomain + "/recruit",
                Map.of("action", action, "postId", postId)
        );
    }

    private Map<String, Object> buildParticipantEntry(Long guildId, Long memberId, String characterName) {
        Map<String, Object> entry = new HashMap<>();
        entry.put("memberId", memberId);
        entry.put("characterName", characterName);

        // member_id로 user 정보 조회해서 아바타 URL 생성
        var memberOpt = guildMemberDao.findById(memberId);
        if (memberOpt != null) {
            var userOpt = userDao.findById(memberOpt.getUserId());
            userOpt.ifPresent(u -> entry.put("avatarUrl", u.getAvatarUrl()));
        }
        return entry;
    }

    private String buildAvatarUrl(String discordId, String avatarHash) {
        if (discordId == null || avatarHash == null) return null;
        return "https://cdn.discordapp.com/avatars/" + discordId + "/" + avatarHash + ".png";
    }

    private ValidationResult validateMember(String subdomain, HttpSession session) {
        Optional<Guild> guildOpt = guildDao.findBySubdomain(subdomain);
        if (guildOpt.isEmpty()) {
            return new ValidationResult("redirect:/?error=" + URLEncoder.encode("존재하지 않는 길드입니다.", StandardCharsets.UTF_8));
        }

        Guild guild = guildOpt.get();
        String userDiscordId = (String) session.getAttribute("user_discord_id");
        if (userDiscordId == null) return new ValidationResult("redirect:/login");

        var userOpt = userDao.findByDiscordId(userDiscordId);
        if (userOpt.isEmpty()) {
            return new ValidationResult("redirect:/?error=" + URLEncoder.encode("올바르지 않은 접근입니다.", StandardCharsets.UTF_8));
        }

        GuildMember member = guildMemberDao.findByGuildIdAndUserId(guild.getId(), userOpt.get().getId());
        if (member == null) {
            return new ValidationResult("redirect:/?error=" + URLEncoder.encode("길드 멤버가 아닙니다.", StandardCharsets.UTF_8));
        }

        return new ValidationResult(guild, member);
    }

    private static class ValidationResult {
        final String errorRedirect;
        final Guild guild;
        final GuildMember member;

        ValidationResult(String errorRedirect) { this.errorRedirect = errorRedirect; this.guild = null; this.member = null; }
        ValidationResult(Guild guild, GuildMember member) { this.errorRedirect = null; this.guild = guild; this.member = member; }
    }
}
