package com.neverdisband.dao;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Repository
public class FameSnapshotDao {

    private final JdbcTemplate jdbc;

    public FameSnapshotDao(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /**
     * 스냅샷 저장 (upsert)
     */
    public void upsert(Long guildId, String playerName, String playerId,
                       long pveFame, long gatheringFame, long killFame,
                       long fiberFame, long hideFame, long oreFame, long rockFame, long woodFame,
                       LocalDate snapshotDate) {
        String sql = """
                INSERT INTO fame_snapshots (guild_id, player_name, player_id, pve_fame, gathering_fame, kill_fame,
                    fiber_fame, hide_fame, ore_fame, rock_fame, wood_fame, snapshot_date)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE
                    player_name = VALUES(player_name),
                    pve_fame = VALUES(pve_fame),
                    gathering_fame = VALUES(gathering_fame),
                    kill_fame = VALUES(kill_fame),
                    fiber_fame = VALUES(fiber_fame),
                    hide_fame = VALUES(hide_fame),
                    ore_fame = VALUES(ore_fame),
                    rock_fame = VALUES(rock_fame),
                    wood_fame = VALUES(wood_fame)
                """;
        jdbc.update(sql, guildId, playerName, playerId, pveFame, gatheringFame, killFame,
                fiberFame, hideFame, oreFame, rockFame, woodFame, snapshotDate);
    }

    /**
     * 특정 길드의 특정 날짜 스냅샷 조회
     */
    public List<Map<String, Object>> findByGuildIdAndDate(Long guildId, LocalDate snapshotDate) {
        String sql = "SELECT * FROM fame_snapshots WHERE guild_id = ? AND snapshot_date = ?";
        return jdbc.queryForList(sql, guildId, snapshotDate);
    }

    /**
     * 두 날짜 간 차이 계산하여 랭킹 반환 (PvE)
     * 양쪽 스냅샷 모두 존재하는 멤버만 (중간 가입자 제외)
     */
    public List<Map<String, Object>> getPveDiff(Long guildId, LocalDate fromDate, LocalDate toDate, int limit) {
        String sql = """
                SELECT t.player_name,
                       (t.pve_fame - f.pve_fame) AS fame_diff
                FROM fame_snapshots t
                INNER JOIN fame_snapshots f ON f.guild_id = t.guild_id AND f.player_id = t.player_id AND f.snapshot_date = ?
                WHERE t.guild_id = ? AND t.snapshot_date = ?
                  AND (t.pve_fame - f.pve_fame) > 0
                ORDER BY fame_diff DESC
                LIMIT ?
                """;
        return jdbc.queryForList(sql, fromDate, guildId, toDate, limit);
    }

    /**
     * 두 날짜 간 차이 - 채집 전체
     */
    public List<Map<String, Object>> getGatheringDiff(Long guildId, LocalDate fromDate, LocalDate toDate, int limit) {
        String sql = """
                SELECT t.player_name,
                       (t.gathering_fame - f.gathering_fame) AS fame_diff
                FROM fame_snapshots t
                INNER JOIN fame_snapshots f ON f.guild_id = t.guild_id AND f.player_id = t.player_id AND f.snapshot_date = ?
                WHERE t.guild_id = ? AND t.snapshot_date = ?
                  AND (t.gathering_fame - f.gathering_fame) > 0
                ORDER BY fame_diff DESC
                LIMIT ?
                """;
        return jdbc.queryForList(sql, fromDate, guildId, toDate, limit);
    }

    /**
     * 두 날짜 간 차이 - 채집 세부타입
     */
    public List<Map<String, Object>> getGatheringSubtypeDiff(Long guildId, LocalDate fromDate, LocalDate toDate,
                                                             String subtypeColumn, int limit) {
        String sql = "SELECT t.player_name, "
                + "(t." + subtypeColumn + " - f." + subtypeColumn + ") AS fame_diff "
                + "FROM fame_snapshots t "
                + "INNER JOIN fame_snapshots f ON f.guild_id = t.guild_id AND f.player_id = t.player_id AND f.snapshot_date = ? "
                + "WHERE t.guild_id = ? AND t.snapshot_date = ? "
                + "AND (t." + subtypeColumn + " - f." + subtypeColumn + ") > 0 "
                + "ORDER BY fame_diff DESC LIMIT ?";
        return jdbc.queryForList(sql, fromDate, guildId, toDate, limit);
    }

    /**
     * 두 날짜 간 차이 - PvP Kill Fame
     */
    public List<Map<String, Object>> getKillFameDiff(Long guildId, LocalDate fromDate, LocalDate toDate, int limit) {
        String sql = """
                SELECT t.player_name,
                       (t.kill_fame - f.kill_fame) AS fame_diff
                FROM fame_snapshots t
                INNER JOIN fame_snapshots f ON f.guild_id = t.guild_id AND f.player_id = t.player_id AND f.snapshot_date = ?
                WHERE t.guild_id = ? AND t.snapshot_date = ?
                  AND (t.kill_fame - f.kill_fame) > 0
                ORDER BY fame_diff DESC
                LIMIT ?
                """;
        return jdbc.queryForList(sql, fromDate, guildId, toDate, limit);
    }

    /**
     * 길드별 최신 2개 스냅샷 외 나머지 삭제
     */
    public void deleteOldSnapshots(Long guildId) {
        // 최신 2개 날짜 가져오기
        List<LocalDate> dates = findSnapshotDates(guildId);
        if (dates.size() <= 2) return;

        LocalDate cutoff = dates.get(1); // 두 번째로 최신 날짜
        jdbc.update("DELETE FROM fame_snapshots WHERE guild_id = ? AND snapshot_date < ?", guildId, cutoff);
    }

    /**
     * 특정 길드의 스냅샷 날짜 목록 (최신순)
     */
    public List<LocalDate> findSnapshotDates(Long guildId) {
        String sql = "SELECT DISTINCT snapshot_date FROM fame_snapshots WHERE guild_id = ? ORDER BY snapshot_date DESC";
        return jdbc.query(sql, (rs, rowNum) -> rs.getDate("snapshot_date").toLocalDate(), guildId);
    }
}
