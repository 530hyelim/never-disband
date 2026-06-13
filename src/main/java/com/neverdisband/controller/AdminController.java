package com.neverdisband.controller;

import com.neverdisband.dao.GuildDao;
import com.neverdisband.dao.GuildMemberDao;
import com.neverdisband.dao.GuildPageDao;
import com.neverdisband.dao.UserDao;
import com.neverdisband.model.Guild;
import com.neverdisband.model.GuildRole;
import com.neverdisband.model.PageType;
import jakarta.servlet.http.HttpSession;
import net.dv8tion.jda.api.JDA;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/{subdomain}/admin")
public class AdminController {

    private static final Logger logger = LoggerFactory.getLogger(AdminController.class);

    private final GuildDao guildDao;
    private final GuildMemberDao guildMemberDao;
    private final GuildPageDao guildPageDao;
    private final UserDao userDao;
    private final com.neverdisband.service.DiscordBotService discordBotService;

    @Nullable
    @Autowired(required = false)
    private JDA jda;

    public AdminController(GuildDao guildDao, GuildMemberDao guildMemberDao,
                           GuildPageDao guildPageDao, UserDao userDao,
                           com.neverdisband.service.DiscordBotService discordBotService) {
        this.guildDao = guildDao;
        this.guildMemberDao = guildMemberDao;
        this.guildPageDao = guildPageDao;
        this.userDao = userDao;
        this.discordBotService = discordBotService;
    }

    /**
     * 관리 페이지 fragment (main.jsp의 main-content 영역에 들어갈 HTML)
     */
    @GetMapping
    public String adminPage(@PathVariable String subdomain, HttpSession session, Model model) {
        var result = validateGuildMaster(subdomain, session);
        if (result.errorRedirect != null) return result.errorRedirect;

        model.addAttribute("guild", result.guild);
        model.addAttribute("pages", guildPageDao.findByGuildId(result.guild.getId()));
        // 봇 재초대 URL (redirect_uri 없이 간단 초대)
        String botInviteUrl = "https://discord.com/api/oauth2/authorize?client_id="
                + discordBotService.getClientId() + "&permissions=8&scope=bot";
        model.addAttribute("botInviteUrl", botInviteUrl);
        // 연동된 디스코드 서버 이름
        var discordGuild = jda != null ? jda.getGuildById(result.guild.getDiscordGuildId()) : null;
        model.addAttribute("discordServerName", discordGuild != null ? discordGuild.getName() : null);
        model.addAttribute("voiceCategoryId", guildDao.getVoiceCategoryId(result.guild.getId()));
        model.addAttribute("memberRoleId", guildDao.getMemberRoleId(result.guild.getId()));
        return "fragments/admin";
    }

    /**
     * 디스코드 서버의 텍스트 채널 목록 조회 (AJAX)
     */
    @GetMapping("/channels")
    @ResponseBody
    public ResponseEntity<List<Map<String, String>>> getDiscordChannels(
            @PathVariable String subdomain, HttpSession session) {

        var result = validateGuildMaster(subdomain, session);
        if (result.errorRedirect != null) {
            return ResponseEntity.status(403).build();
        }

        var discordGuild = jda != null ? jda.getGuildById(result.guild.getDiscordGuildId()) : null;
        if (discordGuild == null) {
            return ResponseEntity.ok(List.of());
        }

        List<Map<String, String>> channels = discordGuild.getTextChannels().stream()
                .map(ch -> Map.of("id", ch.getId(), "name", ch.getName()))
                .toList();

        return ResponseEntity.ok(channels);
    }

    /**
     * 디스코드 서버의 카테고리 채널 목록 조회 (AJAX)
     */
    @GetMapping("/categories")
    @ResponseBody
    public ResponseEntity<List<Map<String, String>>> getDiscordCategories(
            @PathVariable String subdomain, HttpSession session) {

        var result = validateGuildMaster(subdomain, session);
        if (result.errorRedirect != null) {
            return ResponseEntity.status(403).build();
        }

        var discordGuild = jda != null ? jda.getGuildById(result.guild.getDiscordGuildId()) : null;
        if (discordGuild == null) {
            return ResponseEntity.ok(List.of());
        }

        List<Map<String, String>> categories = discordGuild.getCategories().stream()
                .map(cat -> Map.of("id", cat.getId(), "name", cat.getName()))
                .toList();

        return ResponseEntity.ok(categories);
    }

    /**
     * 페이지 사용/미사용 토글 (AJAX)
     */
    @PostMapping("/pages/toggle")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> togglePage(
            @PathVariable String subdomain,
            @RequestParam String pageType,
            @RequestParam boolean enabled,
            HttpSession session) {

        var result = validateGuildMaster(subdomain, session);
        if (result.errorRedirect != null) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "권한이 없습니다."));
        }

        try {
            PageType type = PageType.valueOf(pageType);
            guildPageDao.updateEnabled(result.guild.getId(), type, enabled);
            return ResponseEntity.ok(Map.of("success", true));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "잘못된 페이지 타입입니다."));
        }
    }

    /**
     * 채널 연동 저장 (AJAX)
     */
    @PostMapping("/channels/link")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> linkChannel(
            @PathVariable String subdomain,
            @RequestParam String pageType,
            @RequestParam String discordChannelId,
            @RequestParam String discordChannelName,
            HttpSession session) {

        var result = validateGuildMaster(subdomain, session);
        if (result.errorRedirect != null) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "권한이 없습니다."));
        }

        try {
            PageType type = PageType.valueOf(pageType);

            // 봇이 해당 채널에 접근 가능한지 확인
            if (!discordBotService.canAccessChannel(discordChannelId)) {
                return ResponseEntity.ok(Map.of("success", false,
                        "message", "봇이 해당 채널에 접근할 수 없습니다. \n채널 설정에서 봇 역할에 '채널 보기'와 '메시지 보내기' 권한을 허용해주세요."));
            }

            guildPageDao.updateChannel(result.guild.getId(), type, discordChannelId, discordChannelName);
            return ResponseEntity.ok(Map.of("success", true));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "잘못된 페이지 타입입니다."));
        }
    }

    /**
     * 채널 연동 해제 (AJAX)
     */
    @PostMapping("/channels/unlink")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> unlinkChannel(
            @PathVariable String subdomain,
            @RequestParam String pageType,
            HttpSession session) {

        var result = validateGuildMaster(subdomain, session);
        if (result.errorRedirect != null) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "권한이 없습니다."));
        }

        try {
            PageType type = PageType.valueOf(pageType);
            guildPageDao.clearChannel(result.guild.getId(), type);
            return ResponseEntity.ok(Map.of("success", true));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "잘못된 페이지 타입입니다."));
        }
    }

    /**
     * 보이스 카테고리 연동 저장 (AJAX)
     */
    @PostMapping("/voice-category")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> setVoiceCategory(
            @PathVariable String subdomain,
            @RequestParam String categoryId,
            HttpSession session) {

        var result = validateGuildMaster(subdomain, session);
        if (result.errorRedirect != null) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "권한이 없습니다."));
        }

        guildDao.updateVoiceCategoryId(result.guild.getId(), categoryId.isEmpty() ? null : categoryId);
        return ResponseEntity.ok(Map.of("success", true));
    }

    /**
     * 디스코드 서버의 역할 목록 조회 (AJAX)
     */
    @GetMapping("/roles")
    @ResponseBody
    public ResponseEntity<List<Map<String, String>>> getDiscordRoles(
            @PathVariable String subdomain, HttpSession session) {

        var result = validateGuildMaster(subdomain, session);
        if (result.errorRedirect != null) {
            return ResponseEntity.status(403).build();
        }

        var discordGuild = jda != null ? jda.getGuildById(result.guild.getDiscordGuildId()) : null;
        if (discordGuild == null) {
            return ResponseEntity.ok(List.of());
        }

        // @everyone 역할과 봇 관리 역할은 제외
        List<Map<String, String>> roles = discordGuild.getRoles().stream()
                .filter(r -> !r.isPublicRole() && !r.isManaged())
                .map(r -> Map.of("id", r.getId(), "name", r.getName()))
                .toList();

        return ResponseEntity.ok(roles);
    }

    /**
     * 길드 멤버 역할 설정 저장 (AJAX)
     */
    @PostMapping("/member-role")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> setMemberRole(
            @PathVariable String subdomain,
            @RequestParam String roleId,
            HttpSession session) {

        var result = validateGuildMaster(subdomain, session);
        if (result.errorRedirect != null) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "권한이 없습니다."));
        }

        guildDao.updateMemberRoleId(result.guild.getId(), roleId.isEmpty() ? null : roleId);

        // 역할이 설정되면, 해당 역할을 가진 디스코드 멤버들 중 사이트 가입+길드 참여자에게 MEMBER 권한 부여
        if (!roleId.isEmpty() && jda != null) {
            var discordGuild = jda.getGuildById(result.guild.getDiscordGuildId());
            if (discordGuild != null) {
                var role = discordGuild.getRoleById(roleId);
                if (role != null) {
                    final Long guildId = result.guild.getId();
                    discordGuild.findMembersWithRoles(role).onSuccess(members -> {
                        for (var member : members) {
                            String discordId = member.getUser().getId();
                            var userOpt = userDao.findByDiscordId(discordId);
                            if (userOpt.isPresent()) {
                                Long userId = userOpt.get().getId();
                                var gmRecord = guildMemberDao.findByGuildIdAndUserId(guildId, userId);
                                if (gmRecord != null) {
                                    guildMemberDao.grantMemberRole(gmRecord.getId());
                                }
                            }
                        }
                    });
                }
            }
        }

        return ResponseEntity.ok(Map.of("success", true));
    }

    // === 내부 헬퍼 ===

    private ValidationResult validateGuildMaster(String subdomain, HttpSession session) {
        var guildOpt = guildDao.findBySubdomain(subdomain);
        if (guildOpt.isEmpty()) {
            return new ValidationResult("redirect:/?error=" + URLEncoder.encode("존재하지 않는 길드입니다.", StandardCharsets.UTF_8));
        }

        Guild guild = guildOpt.get();
        String userDiscordId = (String) session.getAttribute("user_discord_id");
        if (userDiscordId == null) {
            return new ValidationResult("redirect:/login");
        }

        var userOpt = userDao.findByDiscordId(userDiscordId);
        if (userOpt.isEmpty()) {
            return new ValidationResult("redirect:/?error=" + URLEncoder.encode("올바르지 않은 접근입니다.", StandardCharsets.UTF_8));
        }

        // 길드마스터 권한 확인
        var member = guildMemberDao.findByGuildIdAndUserId(guild.getId(), userOpt.get().getId());
        if (member == null) {
            return new ValidationResult("redirect:/?error=" + URLEncoder.encode("올바르지 않은 접근입니다.", StandardCharsets.UTF_8));
        }

        var roles = guildMemberDao.findRolesByMemberId(member.getId());
        boolean isGuildMaster = roles.stream().anyMatch(r -> r.getRole() == GuildRole.GUILD_MASTER);
        if (!isGuildMaster) {
            return new ValidationResult("redirect:/" + subdomain + "/main");
        }

        return new ValidationResult(guild);
    }

    private static class ValidationResult {
        final String errorRedirect;
        final Guild guild;

        ValidationResult(String errorRedirect) {
            this.errorRedirect = errorRedirect;
            this.guild = null;
        }

        ValidationResult(Guild guild) {
            this.errorRedirect = null;
            this.guild = guild;
        }
    }
}
