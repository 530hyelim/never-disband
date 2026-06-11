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

    public void insertWithComposition(Long postId, Long memberId, Long compositionId) {
        jdbc.update("INSERT IGNORE INTO recruit_participants (post_id, member_id, composition_id) VALUES (?, ?, ?)",
                postId, memberId, compositionId);
    }

    public void updateComposition(Long postId, Long memberId, Long compositionId) {
        jdbc.update("UPDATE recruit_participants SET composition_id = ? WHERE post_id = ? AND member_id = ?",
                compositionId, postId, memberId);
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
                       rp.composition_id,
                       c.name AS composition_name
                FROM recruit_participants rp
                JOIN guild_members gm ON gm.id = rp.member_id
                JOIN users u ON u.id = gm.user_id
                LEFT JOIN compositions c ON c.id = rp.composition_id
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
