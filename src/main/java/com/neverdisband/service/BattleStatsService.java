package com.neverdisband.service;

import com.neverdisband.dao.BattleStatsDao;
import com.neverdisband.dao.GuildDao;
import com.neverdisband.model.Guild;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class BattleStatsService {

    private static final Logger logger = LoggerFactory.getLogger(BattleStatsService.class);

    private final GuildDao guildDao;
    private final BattleStatsDao battleStatsDao;
    private final AlbionApiService albionApiService;

    public BattleStatsService(GuildDao guildDao, BattleStatsDao battleStatsDao,
                              AlbionApiService albionApiService) {
        this.guildDao = guildDao;
        this.battleStatsDao = battleStatsDao;
        this.albionApiService = albionApiService;
    }

    /**
     * 매일 1시에 전날 전투 데이터 수집
     */
    @Scheduled(cron = "0 0 1 * * *")
    public void dailyBattleCollection() {
        logger.info("[BattleStats] Daily collection started");
        List<Guild> guilds = guildDao.findAll();

        for (Guild guild : guilds) {
            try {
                collectBattles(guild);
                Thread.sleep(2000);
            } catch (Exception e) {
                logger.error("[BattleStats] Failed for guild: {} ({})", guild.getName(), guild.getId(), e);
            }
        }

        // 1년 이상 된 데이터 삭제
        battleStatsDao.deleteOlderThan(LocalDateTime.now().minusYears(1));
        logger.info("[BattleStats] Daily collection completed for {} guilds", guilds.size());
    }

    /**
     * 특정 길드 전투 수집 (즉시 실행용)
     */
    public void collectBattlesForGuild(Long guildId) {
        guildDao.findById(guildId).ifPresent(guild -> {
            try {
                collectBattles(guild);
                logger.info("[BattleStats] Collected battles for guild: {}", guild.getName());
            } catch (Exception e) {
                logger.error("[BattleStats] Failed for guild: {}", guild.getName(), e);
            }
        });
    }

    private void collectBattles(Guild guild) {
        String albionGuildId = guild.getAlbionGuildId();
        if (albionGuildId == null || albionGuildId.isEmpty()) return;

        // 최근 전투 수집 (day 범위 — 하루치)
        String battlesJson = albionApiService.fetchBattles(albionGuildId, "day", 1000);
        if (battlesJson == null || battlesJson.equals("[]")) return;

        parseBattlesAndSave(guild.getId(), albionGuildId, battlesJson);
    }

    private void parseBattlesAndSave(Long guildId, String albionGuildId, String json) {
        // 배열 내 각 battle 오브젝트 순회
        int cursor = 0;
        int savedCount = 0;

        while (true) {
            // 각 battle의 "id": 찾기
            int idIdx = json.indexOf("\"id\":", cursor);
            if (idIdx == -1) break;

            // battle object 시작
            int objStart = json.lastIndexOf("{", idIdx);
            // 다음 battle의 시작 또는 배열 끝 찾기
            int nextObjStart = json.indexOf("{\"id\":", idIdx + 5);
            int objEnd = nextObjStart > 0 ? nextObjStart : json.length();
            String battleObj = json.substring(objStart, objEnd);

            // battle id 추출
            long battleId = extractLongValue(battleObj, "\"id\":", 0);
            if (battleId <= 0) { cursor = idIdx + 5; continue; }

            // startTime 추출
            String startTime = extractStringValue(battleObj, "\"startTime\":\"");
            LocalDateTime battleTime = null;
            if (startTime != null) {
                try {
                    // 2026-06-15T04:21:48.097873400Z 형태
                    battleTime = LocalDateTime.parse(startTime.substring(0, Math.min(startTime.length(), 19)),
                            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss"));
                } catch (Exception e) {
                    battleTime = LocalDateTime.now();
                }
            } else {
                battleTime = LocalDateTime.now();
            }

            // totalPlayers: players 객체 내 플레이어 수 카운트
            int playersIdx = battleObj.indexOf("\"players\":{");
            int totalPlayers = 0;
            if (playersIdx > 0) {
                // "name": 패턴 개수로 카운트
                int pCursor = playersIdx;
                while (true) {
                    int nIdx = battleObj.indexOf("\"name\":\"", pCursor + 1);
                    if (nIdx == -1 || nIdx > battleObj.indexOf("\"guilds\":{", playersIdx)) break;
                    totalPlayers++;
                    pCursor = nIdx + 8;
                }
            }

            // guilds에서 우리 길드 데이터 추출
            int guildsIdx = battleObj.indexOf("\"guilds\":{");
            int ourKills = 0, ourDeaths = 0;
            long ourKillFame = 0;
            int ourPlayerCount = 0;

            if (guildsIdx > 0) {
                // 우리 길드 ID로 검색
                String guildKey = "\"" + albionGuildId + "\":{";
                int ourGuildIdx = battleObj.indexOf(guildKey, guildsIdx);
                if (ourGuildIdx > 0) {
                    int ourGuildEnd = battleObj.indexOf("}", ourGuildIdx + guildKey.length());
                    String ourGuildObj = battleObj.substring(ourGuildIdx, ourGuildEnd + 1);

                    ourKills = (int) extractLongValue(ourGuildObj, "\"kills\":", 0);
                    ourDeaths = (int) extractLongValue(ourGuildObj, "\"deaths\":", 0);
                    ourKillFame = extractLongValue(ourGuildObj, "\"killFame\":", 0);
                }

                // 우리 길드 참여 인원 수: players에서 guildId 매칭
                if (playersIdx > 0) {
                    int pCursor2 = playersIdx;
                    int guildsSection = battleObj.indexOf("\"guilds\":{");
                    while (true) {
                        int gidIdx = battleObj.indexOf("\"guildId\":\"" + albionGuildId + "\"", pCursor2 + 1);
                        if (gidIdx == -1 || gidIdx > guildsSection) break;
                        ourPlayerCount++;
                        pCursor2 = gidIdx + 10;
                    }
                }
            }

            if (ourKills > 0 || ourDeaths > 0) {
                battleStatsDao.upsert(guildId, battleId, battleTime,
                        ourKills, ourDeaths, ourKillFame, totalPlayers, ourPlayerCount);
                savedCount++;
            }

            cursor = idIdx + 5;
        }

        logger.info("[BattleStats] Saved {} battles for guildId={}", savedCount, guildId);
    }

    private long extractLongValue(String json, String prefix, int searchFrom) {
        int idx = json.indexOf(prefix, searchFrom);
        if (idx == -1) return 0;
        int start = idx + prefix.length();
        int end = start;
        while (end < json.length() && (Character.isDigit(json.charAt(end)) || json.charAt(end) == '.')) {
            end++;
        }
        if (end == start) return 0;
        try {
            return (long) Double.parseDouble(json.substring(start, end));
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private String extractStringValue(String json, String prefix) {
        int idx = json.indexOf(prefix);
        if (idx == -1) return null;
        int start = idx + prefix.length();
        int end = json.indexOf("\"", start);
        if (end == -1) return null;
        return json.substring(start, end);
    }
}
