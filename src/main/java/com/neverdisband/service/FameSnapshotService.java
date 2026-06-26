package com.neverdisband.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.neverdisband.dao.FameSnapshotDao;
import com.neverdisband.dao.GuildDao;
import com.neverdisband.model.Guild;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.*;

@Service
public class FameSnapshotService {

    private static final Logger logger = LoggerFactory.getLogger(FameSnapshotService.class);
    private final ObjectMapper objectMapper = new ObjectMapper();

    private final GuildDao guildDao;
    private final FameSnapshotDao fameSnapshotDao;
    private final AlbionApiService albionApiService;

    public FameSnapshotService(GuildDao guildDao, FameSnapshotDao fameSnapshotDao,
                               AlbionApiService albionApiService) {
        this.guildDao = guildDao;
        this.fameSnapshotDao = fameSnapshotDao;
        this.albionApiService = albionApiService;
    }

    /**
     * 매주 월요일마다 전체 길드 스냅샷
     */
    @Scheduled(cron = "0 0 0 * * MON")
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
}
