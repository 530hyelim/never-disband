package com.neverdisband.dao;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class RecruitParticipantDao {

    private final JdbcTemplate jdbc;

    public RecruitParticipantDao(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public void insert(Long postId, Long memberId) {
        jdbc.update("INSERT IGNORE INTO recruit_participants (post_id, member_id) VALUES (?, ?)", postId, memberId);
    }

    public void insertWithSlot(Long postId, Long memberId, Long slotId) {
        jdbc.update("INSERT IGNORE INTO recruit_participants (post_id, member_id, slot_id) VALUES (?, ?, ?)",
                postId, memberId, slotId);
    }

    public void updateSlot(Long postId, Long memberId, Long slotId) {
        jdbc.update("UPDATE recruit_participants SET slot_id = ? WHERE post_id = ? AND member_id = ?",
                slotId, postId, memberId);
    }
    public void delete(Long postId, Long memberId) {
        jdbc.update("DELETE FROM recruit_participants WHERE post_id = ? AND member_id = ?", postId, memberId);
    }

    public boolean exists(Long postId, Long memberId) {
        Integer count = jdbc.queryForObject(
                "SELECT COUNT(*) FROM recruit_participants WHERE post_id = ? AND member_id = ?",
                Integer.class, postId, memberId);
        return count != null && count > 0;
    }

    /**
     * 포스트별 참여자 목록 (character_name, discord_id, avatar_hash 포함)
     * 파티장이 맨 앞에 오도록 post의 leader_member_id와 비교해서 정렬
     */
    public List<Map<String, Object>> findParticipantsByPostId(Long postId) {
        String sql = """
                SELECT gm.id AS member_id,
                       gm.character_name,
                       u.discord_id,
                       u.avatar_hash,
                       rp.slot_id,
                       cs.weapon AS slot_weapon
                FROM recruit_participants rp
                JOIN guild_members gm ON gm.id = rp.member_id
                JOIN users u ON u.id = gm.user_id
                LEFT JOIN composition_slots cs ON cs.id = rp.slot_id
                WHERE rp.post_id = ?
                ORDER BY rp.joined_at ASC
                """;
        return jdbc.queryForList(sql, postId);
    }

    public int countByPostId(Long postId) {
        Integer count = jdbc.queryForObject(
                "SELECT COUNT(*) FROM recruit_participants WHERE post_id = ?",
                Integer.class, postId);
        return count != null ? count : 0;
    }
}
