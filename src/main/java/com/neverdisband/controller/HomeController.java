package com.neverdisband.controller;

import com.neverdisband.dao.FameSnapshotDao;
import com.neverdisband.dao.GuildDao;
import com.neverdisband.dao.GuildMemberDao;
import com.neverdisband.dao.UserDao;
import com.neverdisband.model.Guild;
import com.neverdisband.service.AlbionApiService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
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
    private final AlbionApiService albionApiService;

    public HomeController(GuildDao guildDao, GuildMemberDao guildMemberDao,
                          UserDao userDao, FameSnapshotDao fameSnapshotDao,
                          AlbionApiService albionApiService) {
        this.guildDao = guildDao;
        this.guildMemberDao = guildMemberDao;
        this.userDao = userDao;
        this.fameSnapshotDao = fameSnapshotDao;
        this.albionApiService = albionApiService;
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

        return ResponseEntity.ok(Map.of("events", recentEvents));
    }

    /**
     * 배틀 K/D 그래프 데이터 — Albion /battles API 직접 호출 (1달치, 페이징)
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

        String albionGuildId = guild.getAlbionGuildId();
        if (albionGuildId == null || albionGuildId.isEmpty()) {
            return ResponseEntity.ok(Map.of("battles", List.of()));
        }

        // 규모 필터
        int minPlayers = 1;
        int maxPlayers = 0;
        switch (scale) {
            case "small" -> { minPlayers = 2; maxPlayers = 9; }
            case "medium" -> { minPlayers = 10; maxPlayers = 22; }
            case "large" -> { minPlayers = 23; maxPlayers = 0; }
        }

        // /battles API 페이징으로 조회 (sort=recent이므로 최신부터, 1달 전 데이터 나오면 중단)
        List<Map<String, Object>> result = new ArrayList<>();
        int limit = 51;
        int offset = 0;
        String oneMonthAgo = java.time.LocalDateTime.now().minusMonths(1).toString();
        boolean reachedEnd = false;

        while (!reachedEnd && offset + limit <= 10000) {
            String json = albionApiService.fetchBattles(albionGuildId, "month", limit, offset);
            if (json == null || json.equals("[]")) break;

            List<Map<String, Object>> parsed = parseBattlesJson(json, albionGuildId, minPlayers, maxPlayers, oneMonthAgo);
            result.addAll(parsed);

            // 마지막 배틀 시간이 1달 전보다 이전이면 중단
            String lastTime = getLastBattleTime(json);
            if (lastTime != null && lastTime.compareTo(oneMonthAgo) < 0) {
                reachedEnd = true;
            }

            if (countJsonArray(json) < limit) break;
            offset += limit;
        }

        // 시간순 정렬 (오래된→최신)
        result.sort(Comparator.comparing(m -> (String) m.get("battle_time")));

        return ResponseEntity.ok(Map.of("battles", result));
    }

    private List<Map<String, Object>> parseBattlesJson(String json, String albionGuildId, int minPlayers, int maxPlayers, String oneMonthAgo) {
        List<Map<String, Object>> battles = new ArrayList<>();
        try {
            var mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            var root = mapper.readTree(json);
            if (!root.isArray()) return battles;

            for (var battle : root) {
                String startTime = battle.path("startTime").asText(null);
                if (startTime == null) continue;

                // 1달 전보다 이전이면 스킵
                if (startTime.compareTo(oneMonthAgo) < 0) continue;

                var guilds = battle.path("guilds");
                var ourGuild = guilds.path(albionGuildId);
                if (ourGuild.isMissingNode()) continue;

                int totalPlayers = battle.path("players").size();

                // 규모 필터
                if (totalPlayers < minPlayers) continue;
                if (maxPlayers > 0 && totalPlayers > maxPlayers) continue;

                int ourKills = ourGuild.path("kills").asInt(0);
                int ourDeaths = ourGuild.path("deaths").asInt(0);
                long ourKillFame = ourGuild.path("killFame").asLong(0);

                // 전체 킬페임 0이면 비살상 구역 → 제외
                long totalFame = battle.path("totalFame").asLong(0);
                if (totalFame == 0) continue;

                // 우리 길드 참여자 수
                int ourPlayerCount = 0;
                var players = battle.path("players");
                var fields = players.fields();
                while (fields.hasNext()) {
                    var entry = fields.next();
                    if (albionGuildId.equals(entry.getValue().path("guildId").asText())) {
                        ourPlayerCount++;
                    }
                }

                Map<String, Object> b = new HashMap<>();
                b.put("battle_time", startTime);
                b.put("our_kills", ourKills);
                b.put("our_deaths", ourDeaths);
                b.put("our_kill_fame", ourKillFame);
                b.put("total_players", totalPlayers);
                b.put("our_player_count", ourPlayerCount);
                battles.add(b);
            }
        } catch (Exception e) {
            // 파싱 에러 무시
        }
        return battles;
    }

    private String getLastBattleTime(String json) {
        try {
            var mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            var root = mapper.readTree(json);
            if (!root.isArray() || root.isEmpty()) return null;
            return root.get(root.size() - 1).path("startTime").asText(null);
        } catch (Exception e) {
            return null;
        }
    }

    private int countJsonArray(String json) {
        try {
            var mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            var root = mapper.readTree(json);
            return root.isArray() ? root.size() : 0;
        } catch (Exception e) {
            return 0;
        }
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
