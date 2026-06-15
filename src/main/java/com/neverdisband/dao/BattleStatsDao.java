package com.neverdisband.dao;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Repository
public class BattleStatsDao {

    private final JdbcTemplate jdbc;

    public BattleStatsDao(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public void upsert(Long guildId, Long battleId, LocalDateTime battleTime,
                       int ourKills, int ourDeaths, long ourKillFame,
                       int totalPlayers, int ourPlayerCount) {
        String sql = """
                INSERT INTO guild_battle_stats (guild_id, battle_id, battle_time, our_kills, our_deaths,
                    our_kill_fame, total_players, our_player_count)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE
                    our_kills = VALUES(our_kills),
                    our_deaths = VALUES(our_deaths),
                    our_kill_fame = VALUES(our_kill_fame),
                    total_players = VALUES(total_players),
                    our_player_count = VALUES(our_player_count)
                """;
        jdbc.update(sql, guildId, battleId, battleTime, ourKills, ourDeaths,
                ourKillFame, totalPlayers, ourPlayerCount);
    }

    /**
     * 규모 필터만 적용하여 전체 전투 목록 조회 (그래프용)
     * 기간은 문자열로 비교하여 타임존 이슈 방지
     */
    public List<Map<String, Object>> findByGuildAndScale(Long guildId, String fromDate, int minPlayers, int maxPlayers) {
        String sql;
        if (maxPlayers > 0) {
            sql = """
                SELECT battle_id, battle_time, our_kills, our_deaths, our_kill_fame, total_players, our_player_count
                FROM guild_battle_stats
                WHERE guild_id = ? AND battle_time >= ? AND total_players >= ? AND total_players <= ?
                ORDER BY battle_time ASC
                """;
            return jdbc.queryForList(sql, guildId, fromDate, minPlayers, maxPlayers);
        } else if (minPlayers > 0) {
            sql = """
                SELECT battle_id, battle_time, our_kills, our_deaths, our_kill_fame, total_players, our_player_count
                FROM guild_battle_stats
                WHERE guild_id = ? AND battle_time >= ? AND total_players >= ?
                ORDER BY battle_time ASC
                """;
            return jdbc.queryForList(sql, guildId, fromDate, minPlayers);
        } else {
            sql = """
                SELECT battle_id, battle_time, our_kills, our_deaths, our_kill_fame, total_players, our_player_count
                FROM guild_battle_stats
                WHERE guild_id = ? AND battle_time >= ?
                ORDER BY battle_time ASC
                """;
            return jdbc.queryForList(sql, guildId, fromDate);
        }
    }

    /**
     * 기간 + 규모 필터로 전투 목록 조회 (그래프용)
     * @param minPlayers 최소 참여자 수 (규모 필터)
     * @param maxPlayers 최대 참여자 수 (0이면 무제한)
     */
    public List<Map<String, Object>> findByGuildAndPeriod(Long guildId, LocalDateTime from, LocalDateTime to,
                                                          int minPlayers, int maxPlayers) {
        String sql;
        if (maxPlayers > 0) {
            sql = """
                SELECT battle_id, battle_time, our_kills, our_deaths, our_kill_fame, total_players, our_player_count
                FROM guild_battle_stats
                WHERE guild_id = ? AND battle_time >= ? AND battle_time <= ?
                  AND total_players >= ? AND total_players <= ?
                ORDER BY battle_time ASC
                """;
            return jdbc.queryForList(sql, guildId, from, to, minPlayers, maxPlayers);
        } else {
            sql = """
                SELECT battle_id, battle_time, our_kills, our_deaths, our_kill_fame, total_players, our_player_count
                FROM guild_battle_stats
                WHERE guild_id = ? AND battle_time >= ? AND battle_time <= ?
                  AND total_players >= ?
                ORDER BY battle_time ASC
                """;
            return jdbc.queryForList(sql, guildId, from, to, minPlayers);
        }
    }

    /**
     * 1년 이상 된 데이터 삭제
     */
    public void deleteOlderThan(LocalDateTime cutoff) {
        jdbc.update("DELETE FROM guild_battle_stats WHERE battle_time < ?", cutoff);
    }

    /**
     * 특정 길드의 가장 최근 전투 시각 조회
     */
    public LocalDateTime findLatestBattleTime(Long guildId) {
        String sql = "SELECT MAX(battle_time) FROM guild_battle_stats WHERE guild_id = ?";
        return jdbc.query(sql, rs -> {
            if (rs.next() && rs.getTimestamp(1) != null) {
                return rs.getTimestamp(1).toLocalDateTime();
            }
            return null;
        }, guildId);
    }
}
