package com.neverdisband.dao;

import com.neverdisband.model.RecruitSettlement;
import com.neverdisband.model.RecruitSettlement.SettleStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.Optional;

@Repository
public class RecruitSettlementDao {

    private final JdbcTemplate jdbc;

    public RecruitSettlementDao(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public Long insert(RecruitSettlement s) {
        String sql = """
                INSERT INTO recruit_settlements
                    (post_id, guild_id, split_amount, split_method, split_status, split_expires_at, split_seed, split_started_at, fee_amount, fee_status)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;
        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbc.update(con -> {
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setLong(1, s.getPostId());
            ps.setLong(2, s.getGuildId());
            ps.setLong(3, s.getSplitAmount() != null ? s.getSplitAmount() : 0);
            ps.setString(4, s.getSplitMethod());
            ps.setString(5, s.getSplitStatus() != null ? s.getSplitStatus().name() : "NONE");
            ps.setTimestamp(6, s.getSplitExpiresAt() != null ? Timestamp.valueOf(s.getSplitExpiresAt()) : null);
            ps.setObject(7, s.getSplitSeed());
            ps.setTimestamp(8, s.getSplitStartedAt() != null ? Timestamp.valueOf(s.getSplitStartedAt()) : null);
            ps.setLong(9, s.getFeeAmount() != null ? s.getFeeAmount() : 0);
            ps.setString(10, s.getFeeStatus() != null ? s.getFeeStatus().name() : "NONE");
            return ps;
        }, keyHolder);
        return keyHolder.getKey().longValue();
    }

    public Optional<RecruitSettlement> findByPostId(Long postId) {
        String sql = "SELECT * FROM recruit_settlements WHERE post_id = ?";
        List<RecruitSettlement> results = jdbc.query(sql, (rs, rowNum) -> mapRow(rs), postId);
        return results.isEmpty() ? Optional.empty() : Optional.of(results.get(0));
    }

    public Optional<RecruitSettlement> findById(Long id) {
        String sql = "SELECT * FROM recruit_settlements WHERE id = ?";
        List<RecruitSettlement> results = jdbc.query(sql, (rs, rowNum) -> mapRow(rs), id);
        return results.isEmpty() ? Optional.empty() : Optional.of(results.get(0));
    }

    public void updateFeeStatus(Long id, SettleStatus status) {
        jdbc.update("UPDATE recruit_settlements SET fee_status = ? WHERE id = ?", status.name(), id);
    }

    /**
     * 여러 post의 settlement를 한 번에 조회 (N+1 방지)
     */
    public Map<Long, RecruitSettlement> findByPostIds(List<Long> postIds) {
        if (postIds.isEmpty()) return Map.of();
        String placeholders = String.join(",", postIds.stream().map(id -> "?").toList());
        String sql = "SELECT * FROM recruit_settlements WHERE post_id IN (" + placeholders + ")";
        List<RecruitSettlement> results = jdbc.query(sql, (rs, rowNum) -> mapRow(rs), postIds.toArray());
        Map<Long, RecruitSettlement> map = new HashMap<>();
        for (RecruitSettlement s : results) {
            map.put(s.getPostId(), s);
        }
        return map;
    }

    public void updateSplitStatus(Long id, SettleStatus status) {
        jdbc.update("UPDATE recruit_settlements SET split_status = ? WHERE id = ?", status.name(), id);
    }

    public void updateSplitResult(Long id, String resultJson, Long seed) {
        jdbc.update("UPDATE recruit_settlements SET split_result = ?, split_seed = ?, split_status = 'DONE' WHERE id = ?",
                resultJson, seed, id);
    }

    public void updateSplitStartedAt(Long id, java.time.LocalDateTime startedAt) {
        jdbc.update("UPDATE recruit_settlements SET split_started_at = ? WHERE id = ?",
                Timestamp.valueOf(startedAt), id);
    }

    /**
     * 시작 시간이 지났는데 결과가 아직 없는 settlement 조회 (서버 재시작 복구용)
     */
    public List<RecruitSettlement> findPendingSplits() {
        String sql = "SELECT * FROM recruit_settlements WHERE split_status = 'PENDING' AND split_started_at IS NOT NULL AND split_started_at <= UTC_TIMESTAMP() AND split_result IS NULL";
        return jdbc.query(sql, (rs, rowNum) -> mapRow(rs));
    }

    private RecruitSettlement mapRow(java.sql.ResultSet rs) throws java.sql.SQLException {
        RecruitSettlement s = new RecruitSettlement();
        s.setId(rs.getLong("id"));
        s.setPostId(rs.getLong("post_id"));
        s.setGuildId(rs.getLong("guild_id"));
        s.setSplitAmount(rs.getLong("split_amount"));
        s.setSplitMethod(rs.getString("split_method"));
        s.setSplitStatus(SettleStatus.valueOf(rs.getString("split_status")));
        Timestamp splitExp = rs.getTimestamp("split_expires_at");
        if (splitExp != null) s.setSplitExpiresAt(splitExp.toLocalDateTime());
        long seed = rs.getLong("split_seed");
        s.setSplitSeed(rs.wasNull() ? null : seed);
        s.setSplitResult(rs.getString("split_result"));
        Timestamp splitStarted = rs.getTimestamp("split_started_at");
        if (splitStarted != null) s.setSplitStartedAt(splitStarted.toLocalDateTime());
        s.setFeeAmount(rs.getLong("fee_amount"));
        s.setFeeStatus(SettleStatus.valueOf(rs.getString("fee_status")));
        s.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        return s;
    }
}
