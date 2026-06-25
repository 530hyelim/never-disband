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

    /**
     * 대기 중인 출금 총액 조회
     */
    public long getPendingWithdrawalSum(Long guildId, Long memberId) {
        String sql = "SELECT COALESCE(SUM(amount), 0) FROM bank_transactions WHERE guild_id = ? AND member_id = ? AND type = 'withdrawal' AND status = 'pending'";
        Long sum = jdbc.queryForObject(sql, Long.class, guildId, memberId);
        return sum != null ? sum : 0;
    }

    /**
     * 길드의 pending 신청서 목록 (타입별, 멤버명 join)
     */
    public List<Map<String, Object>> findPendingByType(Long guildId, String type) {
        String sql = """
                SELECT bt.id, bt.member_id, bt.amount, bt.created_at, gm.character_name
                FROM bank_transactions bt
                JOIN guild_members gm ON gm.id = bt.member_id
                WHERE bt.guild_id = ? AND bt.type = ? AND bt.status = 'pending'
                ORDER BY bt.created_at ASC
                """;
        return jdbc.queryForList(sql, guildId, type);
    }

    /**
     * 처리된 내역 로그 (승인/반려/직접, 처리자 이름 join)
     */
    public List<Map<String, Object>> findProcessedLogs(Long guildId, int limit) {
        String sql = """
                SELECT bt.id, bt.type, bt.amount, bt.status, bt.created_at, bt.approved_at,
                       gm.character_name AS target_name,
                       approver.character_name AS approved_by_name
                FROM bank_transactions bt
                JOIN guild_members gm ON gm.id = bt.member_id
                LEFT JOIN guild_members approver ON approver.id = bt.approved_by
                WHERE bt.guild_id = ? AND bt.status != 'pending'
                ORDER BY bt.approved_at DESC
                LIMIT ?
                """;
        return jdbc.queryForList(sql, guildId, limit);
    }

    /**
     * 신청서 승인
     */
    public void approve(Long id, Long overrideAmount, Long approvedBy) {
        if (overrideAmount != null) {
            jdbc.update("UPDATE bank_transactions SET status = 'approved', amount = ?, approved_at = NOW(), approved_by = ? WHERE id = ?",
                    overrideAmount, approvedBy, id);
        } else {
            jdbc.update("UPDATE bank_transactions SET status = 'approved', approved_at = NOW(), approved_by = ? WHERE id = ?",
                    approvedBy, id);
        }
    }

    /**
     * 신청서 반려
     */
    public void reject(Long id, Long approvedBy) {
        jdbc.update("UPDATE bank_transactions SET status = 'rejected', approved_at = NOW(), approved_by = ? WHERE id = ?",
                approvedBy, id);
    }

    /**
     * 직접 입출금 (바로 approved 상태로 생성)
     */
    public void createDirect(Long guildId, Long memberId, String type, long amount, Long approvedBy) {
        String sql = """
                INSERT INTO bank_transactions (guild_id, member_id, type, amount, status, created_at, approved_at, approved_by)
                VALUES (?, ?, ?, ?, 'approved', NOW(), NOW(), ?)
                """;
        jdbc.update(sql, guildId, memberId, type, amount, approvedBy);
    }

    /**
     * 정산 참여비용 입금 건 생성 (pending 상태, settlement_id 연결)
     */
    public void createFeeDeposit(Long guildId, Long memberId, long amount, Long settlementId) {
        String sql = """
                INSERT INTO bank_transactions (guild_id, member_id, type, amount, status, settlement_id, created_at)
                VALUES (?, ?, 'deposit', ?, 'pending', ?, NOW())
                """;
        jdbc.update(sql, guildId, memberId, amount, settlementId);
    }

    /**
     * 특정 settlement_id의 모든 건이 approved 상태인지 확인
     */
    public boolean allApprovedBySettlementId(Long settlementId) {
        String sql = "SELECT COUNT(*) FROM bank_transactions WHERE settlement_id = ? AND status != 'approved'";
        Integer count = jdbc.queryForObject(sql, Integer.class, settlementId);
        return count != null && count == 0;
    }

    /**
     * ID로 단건 조회
     */
    public Map<String, Object> findById(Long id) {
        List<Map<String, Object>> results = jdbc.queryForList(
                "SELECT * FROM bank_transactions WHERE id = ?", id);
        return results.isEmpty() ? null : results.get(0);
    }

    /**
     * 입출금 흐름 (입금 - 출금) 조회 (approved만)
     */
    public List<Map<String, Object>> getDailyProfit(Long guildId, String fromDate) {
        String sql = """
                SELECT DATE(approved_at) AS day,
                       SUM(CASE WHEN type = 'deposit' THEN amount ELSE 0 END) AS total_deposit,
                       SUM(CASE WHEN type = 'withdrawal' THEN amount ELSE 0 END) AS total_withdrawal
                FROM bank_transactions
                WHERE guild_id = ? AND status = 'approved' AND approved_at >= ?
                GROUP BY DATE(approved_at)
                ORDER BY day ASC
                """;
        return jdbc.queryForList(sql, guildId, fromDate);
    }
}
