package com.neverdisband.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.neverdisband.dao.BattleStatsDao;
import com.neverdisband.dao.FameSnapshotDao;
import com.neverdisband.dao.GuildDao;
import com.neverdisband.model.Guild;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

@Service
public class FameSnapshotService {

    private static final Logger logger = LoggerFactory.getLogger(FameSnapshotService.class);
    private final ObjectMapper objectMapper = new ObjectMapper();

    private final GuildDao guildDao;
    private final FameSnapshotDao fameSnapshotDao;
    private final BattleStatsDao battleStatsDao;
    private final AlbionApiService albionApiService;

    public FameSnapshotService(GuildDao guildDao, FameSnapshotDao fameSnapshotDao,
                               BattleStatsDao battleStatsDao, AlbionApiService albionApiService) {
        this.guildDao = guildDao;
        this.fameSnapshotDao = fameSnapshotDao;
        this.battleStatsDao = battleStatsDao;
        this.albionApiService = albionApiService;
    }

    /**
     * 1시간마다 전체 길드 스냅샷 (테스트용, 추후 매주 월요일 0시로 변경)
     */
    @Scheduled(cron = "0 0 * * * *")
    public void weeklySnapshot() {
        logger.info("[FameSnapshot] Weekly snapshot started");
        List<Guild> guilds = guildDao.findAll();
        LocalDate today = LocalDate.now();

        for (Guild guild : guilds) {
            try {
                takeSnapshot(guild, today);
                fameSnapshotDao.deleteOldSnapshots(guild.getId());
                Thread.sleep(2000);
            } catch (Exception e) {
                logger.error("[FameSnapshot] Failed for guild: {} ({})", guild.getName(), guild.getId(), e);
            }
        }

        logger.info("[FameSnapshot] Weekly snapshot completed for {} guilds", guilds.size());
    }

    /**
     * 매일 자정에 전투 데이터 수집 (안전망)
     */
    @Scheduled(cron = "0 30 0 * * *")
    public void dailyBattleCollection() {
        logger.info("[BattleStats] Daily battle collection started");
        List<Guild> guilds = guildDao.findAll();

        for (Guild guild : guilds) {
            try {
                collectBattles(guild, "day");
                Thread.sleep(2000);
            } catch (Exception e) {
                logger.error("[BattleStats] Failed for guild: {} ({})", guild.getName(), guild.getId(), e);
            }
        }

        battleStatsDao.deleteOlderThan(LocalDateTime.now().minusYears(1));
        logger.info("[BattleStats] Daily battle collection completed");
    }

    /**
     * 특정 길드의 스냅샷 즉시 실행 (길드 생성 시 호출)
     */
    public void takeSnapshotForGuild(Long guildId) {
        guildDao.findById(guildId).ifPresent(guild -> {
            try {
                takeSnapshot(guild, LocalDate.now());
                logger.info("[FameSnapshot] Initial snapshot taken for guild: {}", guild.getName());
            } catch (Exception e) {
                logger.error("[FameSnapshot] Failed initial snapshot for guild: {}", guild.getName(), e);
            }
        });
    }

    /**
     * 전투 데이터 수집 (폴링 API에서도 호출)
     */
    public void collectBattles(Guild guild, String range) {
        String albionGuildId = guild.getAlbionGuildId();
        if (albionGuildId == null || albionGuildId.isEmpty()) return;

        String battlesJson = albionApiService.fetchBattles(albionGuildId, range, 9999);
        if (battlesJson == null || battlesJson.equals("[]")) return;

        parseBattlesAndSave(guild.getId(), albionGuildId, battlesJson);
    }

    public void collectBattlesForGuild(Long guildId) {
        guildDao.findById(guildId).ifPresent(guild -> collectBattles(guild, "month"));
    }

    // ===== 멤버 스냅샷 =====

    private void takeSnapshot(Guild guild, LocalDate snapshotDate) {
        String albionGuildId = guild.getAlbionGuildId();
        if (albionGuildId == null || albionGuildId.isEmpty()) {
            logger.warn("[FameSnapshot] No albion guild id for guild: {}", guild.getName());
            return;
        }

        String membersJson = albionApiService.fetchGuildMembers(albionGuildId);
        if (membersJson == null || membersJson.equals("[]")) {
            logger.warn("[FameSnapshot] No members data for guild: {}", guild.getName());
            return;
        }

        parseMembersAndSave(guild.getId(), membersJson, snapshotDate);
    }

    private void parseMembersAndSave(Long guildId, String json, LocalDate snapshotDate) {
        try {
            JsonNode members = objectMapper.readTree(json);
            if (!members.isArray()) return;

            int savedCount = 0;
            for (JsonNode member : members) {
                String playerName = member.path("Name").asText(null);
                String playerId = member.path("Id").asText(null);
                if (playerName == null || playerId == null) continue;

                long killFame = member.path("KillFame").asLong(0);

                JsonNode lifetime = member.path("LifetimeStatistics");
                long pveFame = lifetime.path("PvE").path("Total").asLong(0);

                JsonNode gathering = lifetime.path("Gathering");
                long fiberFame = gathering.path("Fiber").path("Total").asLong(0);
                long hideFame = gathering.path("Hide").path("Total").asLong(0);
                long oreFame = gathering.path("Ore").path("Total").asLong(0);
                long rockFame = gathering.path("Rock").path("Total").asLong(0);
                long woodFame = gathering.path("Wood").path("Total").asLong(0);
                long gatheringFame = gathering.path("All").path("Total").asLong(0);

                fameSnapshotDao.upsert(guildId, playerName, playerId,
                        pveFame, gatheringFame, killFame,
                        fiberFame, hideFame, oreFame, rockFame, woodFame,
                        snapshotDate);
                savedCount++;
            }

            logger.info("[FameSnapshot] Saved {} members for guildId={}", savedCount, guildId);
        } catch (Exception e) {
            logger.error("[FameSnapshot] Failed to parse members JSON for guildId={}", guildId, e);
        }
    }

    // ===== 배틀 파싱 =====

    private int parseBattlesAndSave(Long guildId, String albionGuildId, String json) {
        try {
            JsonNode battles = objectMapper.readTree(json);
            if (!battles.isArray()) return 0;

            int savedCount = 0;
            for (JsonNode battle : battles) {
                long battleId = battle.path("id").asLong(0);
                String startTime = battle.path("startTime").asText(null);
                if (battleId == 0 || startTime == null) continue;

                // guilds 맵에서 우리 길드 찾기
                JsonNode guilds = battle.path("guilds");
                JsonNode ourGuild = guilds.path(albionGuildId);
                if (ourGuild.isMissingNode()) continue;

                int ourKills = ourGuild.path("kills").asInt(0);
                int ourDeaths = ourGuild.path("deaths").asInt(0);
                long ourKillFame = ourGuild.path("killFame").asLong(0);

                // 총 참여자 수
                JsonNode players = battle.path("players");
                int totalPlayers = players.size();

                // 우리 길드 참여자 수
                int ourPlayerCount = 0;
                Iterator<Map.Entry<String, JsonNode>> playerFields = players.fields();
                while (playerFields.hasNext()) {
                    Map.Entry<String, JsonNode> entry = playerFields.next();
                    if (albionGuildId.equals(entry.getValue().path("guildId").asText())) {
                        ourPlayerCount++;
                    }
                }

                LocalDateTime battleTime = parseAlbionTime(startTime);
                if (battleTime != null) {
                    battleStatsDao.upsert(guildId, battleId, battleTime,
                            ourKills, ourDeaths, ourKillFame, totalPlayers, ourPlayerCount);
                    savedCount++;
                }
            }

            if (savedCount > 0) {
                logger.info("[BattleStats] Saved {} battles for guildId={}", savedCount, guildId);
            }
            return savedCount;
        } catch (Exception e) {
            logger.error("[BattleStats] Failed to parse battles JSON for guildId={}", guildId, e);
            return 0;
        }
    }

    private LocalDateTime parseAlbionTime(String time) {
        try {
            if (time.endsWith("Z")) time = time.substring(0, time.length() - 1);
            int dotIdx = time.indexOf('.');
            if (dotIdx != -1) time = time.substring(0, dotIdx);
            return LocalDateTime.parse(time);
        } catch (Exception e) {
            return null;
        }
    }
}
