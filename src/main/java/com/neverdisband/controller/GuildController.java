package com.neverdisband.controller;

import com.neverdisband.dao.GuildDao;
import com.neverdisband.dao.GuildMemberDao;
import com.neverdisband.dao.UserDao;
import com.neverdisband.model.Guild;
import com.neverdisband.model.GuildMember;
import com.neverdisband.model.GuildMemberRole;
import com.neverdisband.model.GuildRole;
import com.neverdisband.model.User;
import com.neverdisband.service.AlbionApiService;
import com.neverdisband.service.DiscordBotService;
import com.neverdisband.service.OAuthStateService;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;

@Controller
@RequestMapping("/guild")
public class GuildController {

    private static final Logger logger = LoggerFactory.getLogger(GuildController.class);

    private final DiscordBotService botService;
    private final AlbionApiService albionApiService;
    private final GuildDao guildDao;
    private final GuildMemberDao guildMemberDao;
    private final UserDao userDao;
    private final OAuthStateService stateService;

    public GuildController(DiscordBotService botService, AlbionApiService albionApiService, GuildDao guildDao,
                           GuildMemberDao guildMemberDao, UserDao userDao, OAuthStateService stateService) {
        this.botService = botService;
        this.albionApiService = albionApiService;
        this.guildDao = guildDao;
        this.guildMemberDao = guildMemberDao;
        this.userDao = userDao;
        this.stateService = stateService;
    }

    /**
     * 길드 생성 시작 - 봇 초대 URL로 리다이렉트
     */
    @GetMapping("/create")
    public String createGuild() {
        String state = stateService.generate();
        String inviteUrl = botService.buildBotInviteUrl(state);
        return "redirect:" + inviteUrl;
    }

    /**
     * 봇 초대 콜백 - 서버 소유자 검증 후 분기
     */
    @GetMapping("/create/callback")
    public String createCallback(
            @RequestParam(required = false) String code,
            @RequestParam(required = false) String guild_id,
            @RequestParam(required = false) String state,
            HttpSession session,
            Model model) {

        // state 검증 (HMAC 서명 기반, 세션 불필요)
        if (!stateService.validate(state)) {
            logger.warn("Guild create state invalid: {}", state);
            return "redirect:/?error=" + URLEncoder.encode("보안 검증에 실패했습니다.", StandardCharsets.UTF_8);
        }

        // 사용자가 취소한 경우
        if (guild_id == null) {
            return "redirect:/?error=" + URLEncoder.encode("길드 생성이 취소되었습니다.", StandardCharsets.UTF_8);
        }

        // 이미 등록된 길드인지 확인
        if (guildDao.existsByDiscordGuildId(guild_id)) {
            return "redirect:/?error=" + URLEncoder.encode("이미 등록된 디스코드 서버입니다.", StandardCharsets.UTF_8);
        }

        // Discord API로 길드 정보 조회
        Map<String, String> guildInfo = botService.fetchGuildInfo(guild_id);
        if (guildInfo == null) {
            return "redirect:/?error=" + URLEncoder.encode("서버 정보를 조회할 수 없습니다. 봇이 정상적으로 초대되었는지 확인해주세요.", StandardCharsets.UTF_8);
        }

        // 소유자 검증
        String currentUserDiscordId = (String) session.getAttribute("user_discord_id");
        String guildOwnerId = guildInfo.get("owner_id");

        if (!guildOwnerId.equals(currentUserDiscordId)) {
            return "redirect:/?ownerFail=true";
        }

        // 검증 통과 - 세션에 discord guild 정보 저장 후 index에서 모달 오픈
        session.setAttribute("guild_create_discord_guild_id", guild_id);
        session.setAttribute("guild_create_discord_guild_name", guildInfo.get("name"));

        return "redirect:/?guildCreate=true";
    }

    /**
     * 길드 이름 확정 후 DB 저장
     */
    @PostMapping("/create/confirm")
    public String confirmCreate(
            @RequestParam String guildName,
            @RequestParam String discordGuildId,
            @RequestParam String albionGuildId,
            HttpSession session) {

        String currentUserDiscordId = (String) session.getAttribute("user_discord_id");

        // 서브도메인 변환 (영어 소문자 + 숫자만, 특수문자/공백 제거)
        String subdomain = guildName.toLowerCase().replaceAll("[^a-z0-9]", "");

        // 서브도메인 유효성 검증 (3~32자)
        if (subdomain.length() < 3 || subdomain.length() > 32) {
            return "redirect:/?error=" + URLEncoder.encode("길드명이 너무 짧거나 깁니다. (영문 3~32자)", StandardCharsets.UTF_8);
        }

        // 서브도메인 중복 검사
        if (guildDao.existsBySubdomain(subdomain)) {
            return "redirect:/?error=" + URLEncoder.encode("이미 사용 중인 길드명입니다.", StandardCharsets.UTF_8);
        }

        // DB 저장 - 생성된 guild PK 반환
        Guild guild = new Guild(guildName, subdomain, discordGuildId, albionGuildId, currentUserDiscordId);
        Long guildId = guildDao.insert(guild);

        // 길드 생성자를 GUILD_MASTER로 멤버 테이블에 등록
        userDao.findByDiscordId(currentUserDiscordId).ifPresent(user -> {
            Long memberId = guildMemberDao.insert(new GuildMember(guildId, user.getId()));
            guildMemberDao.insertRole(new GuildMemberRole(memberId, GuildRole.GUILD_MASTER));
        });

        logger.info("Guild created: name={}, subdomain={}, discordGuildId={}, albionGuildId={}, owner={}", guildName, subdomain, discordGuildId, albionGuildId, currentUserDiscordId);

        return "redirect:/?success=" + URLEncoder.encode("길드가 생성되었습니다.", StandardCharsets.UTF_8);
    }

    // generateState() 메서드 제거 - OAuthStateService로 대체됨

    /**
     * 알비온 API로 길드 존재 여부 + 캐릭터 소속 확인
     * 프론트에서 AJAX로 호출
     */
    @GetMapping("/verify")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> verifyGuild(
            @RequestParam String guildName,
            @RequestParam String characterName) {

        // 1. 길드 검색
        Map<String, String> guildInfo = albionApiService.searchGuild(guildName);
        if (guildInfo == null) {
            return ResponseEntity.ok(Map.of(
                    "success", false,
                    "message", "길드 \"" + guildName + "\"을(를) 찾을 수 없습니다. 정확한 이름인지 확인해주세요."
            ));
        }

        // 2. 캐릭터 소속 확인
        String albionGuildId = guildInfo.get("id");
        boolean isMember = albionApiService.isCharacterInGuild(albionGuildId, characterName);

        if (!isMember) {
            return ResponseEntity.ok(Map.of(
                    "success", false,
                    "message", "캐릭터 \"" + characterName + "\"이(가) 길드 \"" + guildName + "\"에 소속되어 있지 않습니다."
            ));
        }

        // 3. 성공
        return ResponseEntity.ok(Map.of(
                "success", true,
                "guildName", guildInfo.get("name"),
                "albionGuildId", albionGuildId,
                "characterName", characterName
        ));
    }
}
