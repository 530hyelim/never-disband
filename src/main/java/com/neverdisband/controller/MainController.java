package com.neverdisband.controller;

import com.neverdisband.dao.GuildDao;
import com.neverdisband.dao.GuildMemberDao;
import com.neverdisband.dao.UserDao;
import com.neverdisband.model.Guild;
import com.neverdisband.service.DiscordBotService;
import com.neverdisband.service.DiscordOAuthService;
import com.neverdisband.service.OAuthStateService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Optional;

@Controller
public class MainController {

    private final GuildDao guildDao;
    private final GuildMemberDao guildMemberDao;
    private final UserDao userDao;
    private final DiscordBotService botService;
    private final DiscordOAuthService oAuthService;
    private final OAuthStateService stateService;

    public MainController(GuildDao guildDao, GuildMemberDao guildMemberDao, UserDao userDao,
                          DiscordBotService botService, DiscordOAuthService oAuthService, OAuthStateService stateService) {
        this.guildDao = guildDao;
        this.guildMemberDao = guildMemberDao;
        this.userDao = userDao;
        this.botService = botService;
        this.oAuthService = oAuthService;
        this.stateService = stateService;
    }

    @GetMapping("/{subdomain}/main")
    public String main(@PathVariable String subdomain, HttpSession session, Model model) {
        Optional<Guild> guildOpt = guildDao.findBySubdomain(subdomain);
        if (guildOpt.isEmpty()) {
            return "redirect:/?error=" + URLEncoder.encode("존재하지 않는 길드입니다.", StandardCharsets.UTF_8);
        }

        Guild guild = guildOpt.get();

        // 미로그인 시 바로 디스코드 OAuth 호출
        String userDiscordId = (String) session.getAttribute("user_discord_id");
        if (userDiscordId == null) {
            session.setAttribute("redirect_after_login", "/" + subdomain + "/main");
            String state = stateService.generate();
            return "redirect:" + oAuthService.buildAuthorizationUrl(state);
        }

        // 현재 유저가 해당 길드의 멤버인지 확인
        var userOpt = userDao.findByDiscordId(userDiscordId);
        if (userOpt.isEmpty()) {
            return "redirect:/?error=" + URLEncoder.encode("올바르지 않은 접근입니다.", StandardCharsets.UTF_8);
        }

        Long userId = userOpt.get().getId();
        if (!guildMemberDao.existsByGuildIdAndUserId(guild.getId(), userId)) {
            // 멤버는 아니지만 디스코드 서버에 참여 중이면 index의 길드 참여 모달로 유도
            if (botService.isUserInGuild(guild.getDiscordGuildId(), userDiscordId)) {
                return "redirect:/?joinGuild=" + URLEncoder.encode(guild.getName(), StandardCharsets.UTF_8);
            }
            return "redirect:/?error=" + URLEncoder.encode("접근 권한이 없습니다.", StandardCharsets.UTF_8);
        }

        model.addAttribute("guild", guild);

        // 현재 유저의 멤버 정보 (캐릭터명, balance)
        var member = guildMemberDao.findByGuildIdAndUserId(guild.getId(), userOpt.get().getId());
        if (member != null) {
            model.addAttribute("characterName", member.getCharacterName());
            model.addAttribute("balance", member.getBalance());
        }

        return "main";
    }
}
