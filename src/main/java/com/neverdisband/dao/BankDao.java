package com.neverdisband.dao;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class BankDao {

    private final JdbcTemplate jdbc;

    public BankDao(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /**
     * 출금 신청 생성
     */
    public void createWithdrawal(Long guildId, Long memberId, long amount) {
        String sql = """
                INSERT INTO bank_transactions (guild_id, member_id, type, amount, status, created_at)
                VALUES (?, ?, 'withdrawal', ?, 'pending', NOW())
                """;
        jdbc.update(sql, guildId, memberId, amount);
    }

    /**
     * 특정 멤버의 입/출금 내역 조회 (최신순)
     */
    public List<Map<String, Object>> findByMember(Long guildId, Long memberId, int limit) {
        String sql = """
                SELECT type, amount, status, created_at, approved_at
                FROM bank_transactions
                WHERE guild_id = ? AND member_id = ?
                ORDER BY created_at DESC
                LIMIT ?
                """;
        return jdbc.queryForList(sql, guildId, memberId, limit);
    }

    /**
     * 대기 중인 출금 신청이 있는지 확인
     */
    public boolean hasPendingWithdrawal(Long guildId, Long memberId) {
        String sql = "SELECT COUNT(*) FROM bank_transactions WHERE guild_id = ? AND member_id = ? AND type = 'withdrawal' AND status = 'pending'";
        Integer count = jdbc.queryForObject(sql, Integer.class, guildId, memberId);
        return count != null && count > 0;
    }
}
