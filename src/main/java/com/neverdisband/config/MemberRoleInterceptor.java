package com.neverdisband.config;

import com.neverdisband.dao.GuildDao;
import com.neverdisband.dao.GuildMemberDao;
import com.neverdisband.dao.GuildPageDao;
import com.neverdisband.dao.UserDao;
import com.neverdisband.model.Guild;
import com.neverdisband.model.GuildMember;
import com.neverdisband.service.AlbionApiService;
import com.neverdisband.service.DiscordBotService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.HandlerMapping;

import java.util.Map;
import java.util.Optional;

/**
 * MEMBER 권한 체크 인터셉터
 * /{subdomain}/** 요청에서 MEMBER 역할이 없는 유저를 감지하고,
 * 알비온 API로 소속을 재확인해서 자동 부여를 시도
 *
 * 결과를 request attribute "accessDenied"에 세팅하여 컨트롤러/뷰에서 참조
 */
@Component
public class MemberRoleInterceptor implements HandlerInterceptor {

    private static final Logger logger = LoggerFactory.getLogger(MemberRoleInterceptor.class);

    private final GuildDao guildDao;
    private final GuildMemberDao guildMemberDao;
    private final GuildPageDao guildPageDao;
    private final UserDao userDao;
    private final AlbionApiService albionApiService;
    private final DiscordBotService discordBotService;

    public MemberRoleInterceptor(GuildDao guildDao, GuildMemberDao guildMemberDao,
                                 GuildPageDao guildPageDao, UserDao userDao,
                                 AlbionApiService albionApiService, DiscordBotService discordBotService) {
        this.guildDao = guildDao;
        this.guildMemberDao = guildMemberDao;
        this.guildPageDao = guildPageDao;
        this.userDao = userDao;
        this.albionApiService = albionApiService;
        this.discordBotService = discordBotService;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        // request attribute 기본값
        request.setAttribute("accessDenied", false);

        HttpSession session = request.getSession(false);
        if (session == null) return true;

        String userDiscordId = (String) session.getAttribute("user_discord_id");
        if (userDiscordId == null) return true;

        // URL에서 subdomain 추출
        @SuppressWarnings("unchecked")
        Map<String, String> pathVars = (Map<String, String>) request.getAttribute(HandlerMapping.URI_TEMPLATE_VARIABLES_ATTRIBUTE);
        if (pathVars == null || !pathVars.containsKey("subdomain")) {
            return true;
        }

        String subdomain = pathVars.get("subdomain");
        Optional<Guild> guildOpt = guildDao.findBySubdomain(subdomain);
        if (guildOpt.isEmpty()) return true;

        Guild guild = guildOpt.get();

        // 유저 조회
        var userOpt = userDao.findByDiscordId(userDiscordId);
        if (userOpt.isEmpty()) return true;

        GuildMember member = guildMemberDao.findByGuildIdAndUserId(guild.getId(), userOpt.get().getId());
        if (member == null) return true; // guild_members 행이 없으면 다른 곳에서 처리

        // 이미 MEMBER 역할 보유
        if (guildMemberDao.hasMemberRole(member.getId())) return true;

        // 길드마스터는 항상 통과
        if (guildMemberDao.isGuildMaster(member.getId())) return true;

        // --- MEMBER 역할 없음 → 알비온 API로 소속 재확인 ---
        if (guild.getAlbionGuildId() != null && member.getCharacterName() != null) {
            try {
                boolean inGuild = albionApiService.isCharacterInGuild(
                        guild.getAlbionGuildId(), member.getCharacterName());
                if (inGuild) {
                    guildMemberDao.grantMemberRole(member.getId());
                    logger.info("[member-check] Auto-granted MEMBER via Albion API: character={}, guild={}",
                            member.getCharacterName(), guild.getName());
                    return true;
                }
            } catch (Exception e) {
                logger.warn("[member-check] Albion API check failed, denying access: {}", e.getMessage());
            }
        }

        // MEMBER 아님 → accessDenied 세팅
        request.setAttribute("accessDenied", true);

        // recruit 채널 읽기 권한은 recruit 관련 요청에서만 확인 (매 요청마다 Discord API 호출 방지)
        String requestUri = request.getRequestURI();
        if (requestUri.contains("/recruit") || requestUri.endsWith("/main")) {
            var recruitPage = guildPageDao.findByGuildIdAndType(guild.getId(),
                    com.neverdisband.model.PageType.RECRUIT);
            boolean canViewRecruit = false;
            if (recruitPage.isPresent() && recruitPage.get().getDiscordChannelId() != null) {
                canViewRecruit = discordBotService.hasViewChannelPermission(
                        guild.getDiscordGuildId(), userDiscordId,
                        recruitPage.get().getDiscordChannelId());
            }
            request.setAttribute("canViewRecruit", canViewRecruit);
        }

        return true;
    }
}
