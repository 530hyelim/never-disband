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
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Controller
@RequestMapping("/{subdomain}/admin")
public class AdminController {

    private final GuildDao guildDao;
    private final GuildMemberDao guildMemberDao;
    private final GuildPageDao guildPageDao;
    private final UserDao userDao;
    private final Optional<JDA> jda;

    public AdminController(GuildDao guildDao, GuildMemberDao guildMemberDao,
                           GuildPageDao guildPageDao, UserDao userDao,
                           Optional<JDA> jda) {
        this.guildDao = guildDao;
        this.guildMemberDao = guildMemberDao;
        this.guildPageDao = guildPageDao;
        this.userDao = userDao;
        this.jda = jda;
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

        var discordGuild = jda.isPresent() ? jda.get().getGuildById(result.guild.getDiscordGuildId()) : null;
        if (discordGuild == null) {
            return ResponseEntity.ok(List.of());
        }

        List<Map<String, String>> channels = discordGuild.getTextChannels().stream()
                .map(ch -> Map.of("id", ch.getId(), "name", ch.getName()))
                .toList();

        return ResponseEntity.ok(channels);
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
