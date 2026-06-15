package com.neverdisband.controller;

import com.neverdisband.dao.BattleStatsDao;
import com.neverdisband.dao.FameSnapshotDao;
import com.neverdisband.dao.GuildDao;
import com.neverdisband.dao.GuildMemberDao;
import com.neverdisband.dao.UserDao;
import com.neverdisband.model.Guild;
import com.neverdisband.service.AlbionApiService;
import com.neverdisband.service.FameSnapshotService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.*;

@Controller
@RequestMapping("/{subdomain}/home")
public class HomeController {

    private final GuildDao guildDao;
    private final GuildMemberDao guildMemberDao;
    private final UserDao userDao;
    private final FameSnapshotDao fameSnapshotDao;
    private final BattleStatsDao battleStatsDao;
    private final AlbionApiService albionApiService;
    private final FameSnapshotService fameSnapshotService;
    private final SimpMessagingTemplate messagingTemplate;

    public HomeController(GuildDao guildDao, GuildMemberDao guildMemberDao,
                          UserDao userDao, FameSnapshotDao fameSnapshotDao,
                          BattleStatsDao battleStatsDao, AlbionApiService albionApiService,
                          FameSnapshotService fameSnapshotService,
                          SimpMessagingTemplate messagingTemplate) {
        this.guildDao = guildDao;
        this.guildMemberDao = guildMemberDao;
        this.userDao = userDao;
        this.fameSnapshotDao = fameSnapshotDao;
        this.battleStatsDao = battleStatsDao;
        this.albionApiService = albionApiService;
        this.fameSnapshotService = fameSnapshotService;
        this.messagingTemplate = messagingTemplate;
    }

    /**
     * 홈 fragment 반환
     */
    @GetMapping
    public String homePage(@PathVariable String subdomain) {
        return "fragments/home";
    }

    /**
     * 홈 대시보드 통계 API
     * 스냅샷 기반 주간 diff + 길드 PvP 데이터 + 최근 전투
     */
    @GetMapping("/stats")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getStats(
            @PathVariable String subdomain, HttpSession session) {

        var guild = validateAccess(subdomain, session);
        if (guild == null) return ResponseEntity.status(403).build();

        String albionGuildId = guild.getAlbionGuildId();
        if (albionGuildId == null || albionGuildId.isEmpty()) {
            return ResponseEntity.ok(Map.of("error", "알비온 길드 ID가 설정되지 않았습니다."));
        }

        // 스냅샷 날짜 목록 조회
        List<LocalDate> dates = fameSnapshotDao.findSnapshotDates(guild.getId());
        if (dates.size() < 2) {
            // 스냅샷이 2개 미만이면 diff 계산 불가
            String recentEvents = albionApiService.fetchRecentKillEvents(albionGuildId, 20);

            Map<String, Object> result = new HashMap<>();
            result.put("noSnapshot", true);
            result.put("recentEvents", recentEvents);
            return ResponseEntity.ok(result);
        }

        // 최신 2개 스냅샷으로 diff 계산
        LocalDate toDate = dates.get(0);   // 이번 주 월요일
        LocalDate fromDate = dates.get(1); // 지난 주 월요일

        String periodStart = fromDate.toString();
        String periodEnd = toDate.minusDays(1).toString(); // 일요일

        // 주간 랭킹
        List<Map<String, Object>> pvpRanking = fameSnapshotDao.getKillFameDiff(guild.getId(), fromDate, toDate, 5);
        List<Map<String, Object>> pveRanking = fameSnapshotDao.getPveDiff(guild.getId(), fromDate, toDate, 5);
        List<Map<String, Object>> gatherRanking = fameSnapshotDao.getGatheringDiff(guild.getId(), fromDate, toDate, 5);

        // 최근 전투
        String recentEvents = albionApiService.fetchRecentKillEvents(albionGuildId, 20);

        Map<String, Object> result = new HashMap<>();
        result.put("pvpRanking", pvpRanking);
        result.put("pveRanking", pveRanking);
        result.put("gatheringRanking", gatherRanking);
        result.put("recentEvents", recentEvents);
        result.put("periodStart", periodStart);
        result.put("periodEnd", periodEnd);
        return ResponseEntity.ok(result);
    }

    /**
     * 채집 세부 랭킹 (subtype별)
     */
    @GetMapping("/stats/gathering")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getGatheringStats(
            @PathVariable String subdomain,
            @RequestParam(defaultValue = "All") String subtype,
            HttpSession session) {

        var guild = validateAccess(subdomain, session);
        if (guild == null) return ResponseEntity.status(403).build();

        List<LocalDate> dates = fameSnapshotDao.findSnapshotDates(guild.getId());
        if (dates.size() < 2) {
            return ResponseEntity.ok(Map.of("ranking", List.of()));
        }

        LocalDate toDate = dates.get(0);
        LocalDate fromDate = dates.get(1);

        List<Map<String, Object>> ranking;
        if ("All".equalsIgnoreCase(subtype)) {
            ranking = fameSnapshotDao.getGatheringDiff(guild.getId(), fromDate, toDate, 10);
        } else {
            String column = switch (subtype.toLowerCase()) {
                case "fiber" -> "fiber_fame";
                case "hide" -> "hide_fame";
                case "ore" -> "ore_fame";
                case "rock" -> "rock_fame";
                case "wood" -> "wood_fame";
                default -> "gathering_fame";
            };
            ranking = fameSnapshotDao.getGatheringSubtypeDiff(guild.getId(), fromDate, toDate, column, 10);
        }

        return ResponseEntity.ok(Map.of("ranking", ranking));
    }

    /**
     * 최근 전투 이벤트 (폴링용) — 새 전투 발견 시 DB 저장 + WebSocket 브로드캐스트
     */
    @GetMapping("/stats/battles")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getBattles(
            @PathVariable String subdomain, HttpSession session) {

        var guild = validateAccess(subdomain, session);
        if (guild == null) return ResponseEntity.status(403).build();

        String albionGuildId = guild.getAlbionGuildId();
        if (albionGuildId == null || albionGuildId.isEmpty()) {
            return ResponseEntity.ok(Map.of("events", "[]"));
        }

        // 최근 전투 이벤트
        String recentEvents = albionApiService.fetchRecentKillEvents(albionGuildId, 51);

        // 배틀 데이터도 겸사겸사 수집 (비동기)
        new Thread(() -> {
            try {
                fameSnapshotService.collectBattles(guild, "day");
                // 새 데이터가 있으면 소켓으로 알림
                messagingTemplate.convertAndSend("/topic/guild/" + subdomain + "/battles", "update");
            } catch (Exception ignored) {}
        }).start();

        return ResponseEntity.ok(Map.of("events", recentEvents));
    }

    /**
     * 배틀 K/D 그래프 데이터
     * @param scale 규모 필터: all | small(2-9) | medium(10-22) | large(23+)
     */
    @GetMapping("/stats/battles/graph")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getBattleGraph(
            @PathVariable String subdomain,
            @RequestParam(defaultValue = "all") String scale,
            HttpSession session) {

        var guild = validateAccess(subdomain, session);
        if (guild == null) return ResponseEntity.status(403).build();

        // 홈 접근 시 day 수집 비동기 실행
        Guild g = guild;
        new Thread(() -> {
            try { fameSnapshotService.collectBattles(g, "day"); } catch (Exception ignored) {}
        }).start();

        // 1개월 전부터 조회 (문자열로 비교하여 타임존 이슈 방지)
        String fromDate = LocalDate.now().minusMonths(1).atStartOfDay().toString();

        int minPlayers = 1;
        int maxPlayers = 0;
        switch (scale) {
            case "small" -> { minPlayers = 2; maxPlayers = 9; }
            case "medium" -> { minPlayers = 10; maxPlayers = 22; }
            case "large" -> { minPlayers = 23; maxPlayers = 0; }
        }

        List<Map<String, Object>> battles = battleStatsDao.findByGuildAndScale(
                guild.getId(), fromDate, minPlayers, maxPlayers);

        return ResponseEntity.ok(Map.of("battles", battles));
    }

    /**
     * 전투 상세 이벤트 조회
     */
    @GetMapping("/stats/battle/{eventId}")
    @ResponseBody
    public ResponseEntity<String> getBattleDetail(
            @PathVariable String subdomain,
            @PathVariable String eventId,
            HttpSession session) {

        var guild = validateAccess(subdomain, session);
        if (guild == null) return ResponseEntity.status(403).body("{\"error\":\"권한이 없습니다.\"}");

        String albionGuildId = guild.getAlbionGuildId();
        if (albionGuildId == null || albionGuildId.isEmpty()) {
            return ResponseEntity.ok("{\"error\":\"길드 ID가 없습니다.\"}");
        }

        String eventDetail = albionApiService.fetchEventDetail(eventId);
        return ResponseEntity.ok(eventDetail);
    }

    private Guild validateAccess(String subdomain, HttpSession session) {
        Optional<Guild> guildOpt = guildDao.findBySubdomain(subdomain);
        if (guildOpt.isEmpty()) return null;

        String userDiscordId = (String) session.getAttribute("user_discord_id");
        if (userDiscordId == null) return null;

        var userOpt = userDao.findByDiscordId(userDiscordId);
        if (userOpt.isEmpty()) return null;

        if (!guildMemberDao.existsByGuildIdAndUserId(guildOpt.get().getId(), userOpt.get().getId())) {
            return null;
        }

        return guildOpt.get();
    }
}
