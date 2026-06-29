package com.neverdisband.dao;

import com.neverdisband.model.SplitParticipant;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

@Repository
public class SplitParticipantDao {

    private final JdbcTemplate jdbc;

    public SplitParticipantDao(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public void insertAll(Long settlementId, List<SplitParticipant> participants) {
        String sql = "INSERT INTO split_participants (settlement_id, member_id, character_name) VALUES (?, ?, ?)";
        for (SplitParticipant p : participants) {
            jdbc.update(sql, settlementId, p.getMemberId(), p.getCharacterName());
        }
    }

    public List<SplitParticipant> findBySettlementId(Long settlementId) {
        String sql = "SELECT * FROM split_participants WHERE settlement_id = ? ORDER BY id";
        return jdbc.query(sql, this::mapRow, settlementId);
    }

    public void updateChoice(Long settlementId, Long memberId, Integer choice) {
        jdbc.update(
                "UPDATE split_participants SET choice = ? WHERE settlement_id = ? AND member_id = ?",
                choice, settlementId, memberId
        );
    }

    public void updateRank(Long settlementId, Long memberId, Integer rank) {
        jdbc.update(
                "UPDATE split_participants SET `rank` = ? WHERE settlement_id = ? AND member_id = ?",
                rank, settlementId, memberId
        );
    }

    /**
     * 포기 처리 (rank = 0)
     */
    public void optOut(Long settlementId, Long memberId) {
        jdbc.update(
                "UPDATE split_participants SET `rank` = 0 WHERE settlement_id = ? AND member_id = ?",
                settlementId, memberId
        );
    }

    /**
     * 포기 취소 (rank를 다시 null로)
     */
    public void cancelOptOut(Long settlementId, Long memberId) {
        jdbc.update(
                "UPDATE split_participants SET `rank` = NULL WHERE settlement_id = ? AND member_id = ? AND `rank` = 0",
                settlementId, memberId
        );
    }

    private SplitParticipant mapRow(ResultSet rs, int rowNum) throws SQLException {
        SplitParticipant p = new SplitParticipant();
        p.setId(rs.getLong("id"));
        p.setSettlementId(rs.getLong("settlement_id"));
        p.setMemberId(rs.getLong("member_id"));
        p.setCharacterName(rs.getString("character_name"));
        int choice = rs.getInt("choice");
        p.setChoice(rs.wasNull() ? null : choice);
        int rank = rs.getInt("rank");
        p.setRank(rs.wasNull() ? null : rank);
        return p;
    }
}
