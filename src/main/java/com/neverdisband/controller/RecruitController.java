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
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
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

    private final GuildDao guildDao;
    private final GuildMemberDao guildMemberDao;
    private final GuildPageDao guildPageDao;
    private final RecruitPostDao recruitPostDao;
    private final RecruitParticipantDao participantDao;
    private final UserDao userDao;
    private final CompositionDao compositionDao;

    public RecruitController(GuildDao guildDao, GuildMemberDao guildMemberDao,
                             GuildPageDao guildPageDao, RecruitPostDao recruitPostDao,
                             RecruitParticipantDao participantDao, UserDao userDao,
                             CompositionDao compositionDao) {
        this.guildDao = guildDao;
        this.guildMemberDao = guildMemberDao;
        this.guildPageDao = guildPageDao;
        this.recruitPostDao = recruitPostDao;
        this.participantDao = participantDao;
        this.userDao = userDao;
        this.compositionDao = compositionDao;
    }

    @GetMapping
    public String recruitPage(@PathVariable String subdomain, HttpSession session, Model model) {
        var result = validateMember(subdomain, session);
        if (result.errorRedirect != null) return result.errorRedirect;

        Optional<GuildPage> recruitPage = guildPageDao.findByGuildIdAndType(result.guild.getId(), PageType.RECRUIT);
        boolean hasChannel = recruitPage.isPresent() && recruitPage.get().getDiscordChannelId() != null;

        model.addAttribute("guild", result.guild);
        model.addAttribute("hasChannel", hasChannel);
        model.addAttribute("channelName", hasChannel ? recruitPage.get().getDiscordChannelName() : null);
        model.addAttribute("currentMemberId", result.member.getId());
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
            item.put("isPublic", post.isPublic());
            item.put("status", post.getStatus().name());
            item.put("source", post.getSource().name());
            item.put("mandatory", post.getMandatory());
            item.put("createdAt", post.getCreatedAt().toString());

            // 참여자 목록 (파티장 포함 — 파티장은 DB에 participants로 저장 안되므로 맨 앞에 수동 추가)
            List<Map<String, Object>> rawParticipants = participantDao.findParticipantsByPostId(post.getId());
            List<Map<String, Object>> participants = new ArrayList<>();

            // 파티장 먼저
            Map<String, Object> leader = buildParticipantEntry(result.guild.getId(), post.getLeaderMemberId(), post.getLeaderCharacterName());
            participants.add(leader);

            // 나머지 참여자 (파티장 중복 제외)
            for (Map<String, Object> p : rawParticipants) {
                Long memberId = ((Number) p.get("member_id")).longValue();
                if (!memberId.equals(post.getLeaderMemberId())) {
                    Map<String, Object> entry = new HashMap<>();
                    entry.put("memberId", memberId);
                    entry.put("characterName", p.get("character_name"));
                    String discordId = (String) p.get("discord_id");
                    String avatarHash = (String) p.get("avatar_hash");
                    entry.put("avatarUrl", buildAvatarUrl(discordId, avatarHash));
                    entry.put("compositionId", p.get("composition_id"));
                    entry.put("compositionName", p.get("composition_name"));
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

        // 파티장은 참여/취소 불가
        if (memberId.equals(post.getLeaderMemberId())) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "파티장은 참여 신청을 변경할 수 없습니다."));
        }

        boolean alreadyJoined = participantDao.exists(postId, memberId);
        if (alreadyJoined) {
            participantDao.delete(postId, memberId);
            return ResponseEntity.ok(Map.of("success", true, "joined", false));
        } else {
            participantDao.insert(postId, memberId);
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
            return ResponseEntity.ok(Map.of("success", true));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "잘못된 상태값입니다."));
        }
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
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "파티장만 수정할 수 있습니다."));
        }

        Boolean isPublic = (Boolean) body.get("isPublic");
        String mandatory = (String) body.get("mandatory");
        String scheduledAt = (String) body.get("scheduledAt");
        Integer minMembers = body.get("minMembers") != null ? ((Number) body.get("minMembers")).intValue() : null;
        Integer maxMembers = body.get("maxMembers") != null ? ((Number) body.get("maxMembers")).intValue() : null;
        Long compositionId = body.get("compositionId") != null ? ((Number) body.get("compositionId")).longValue() : null;

        recruitPostDao.updatePost(postId,
                isPublic != null ? (isPublic ? "Y" : "N") : (postOpt.get().isPublic() ? "Y" : "N"),
                mandatory != null ? mandatory : postOpt.get().getMandatory(),
                scheduledAt,
                minMembers, maxMembers, compositionId);

        return ResponseEntity.ok(Map.of("success", true));
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
