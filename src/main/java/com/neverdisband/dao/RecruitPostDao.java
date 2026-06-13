package com.neverdisband.dao;

import com.neverdisband.model.RecruitPost;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

@Repository
public class RecruitPostDao {

    private final JdbcTemplate jdbc;

    public RecruitPostDao(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public Long insert(RecruitPost post) {
        String sql = """
                INSERT INTO recruit_posts
                    (guild_id, leader_member_id, content, scheduled_at, min_members, max_members,
                     composition_id, is_public, status, discord_message_id, source)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;
        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbc.update(con -> {
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setLong(1, post.getGuildId());
            ps.setLong(2, post.getLeaderMemberId());
            ps.setString(3, post.getContent());
            ps.setTimestamp(4, post.getScheduledAt() != null ? Timestamp.valueOf(post.getScheduledAt()) : null);
            ps.setObject(5, post.getMinMembers());
            ps.setObject(6, post.getMaxMembers());
            ps.setObject(7, post.getCompositionId());
            ps.setString(8, post.isPublic() ? "Y" : "N");
            ps.setString(9, post.getStatus().name());
            ps.setString(10, post.getDiscordMessageId());
            ps.setString(11, post.getSource().name());
            return ps;
        }, keyHolder);
        return keyHolder.getKey().longValue();
    }

    /**
     * discord_message_id 중복 여부 확인
     */
    public boolean existsByDiscordMessageId(String discordMessageId) {
        String sql = "SELECT COUNT(*) FROM recruit_posts WHERE discord_message_id = ?";
        Integer count = jdbc.queryForObject(sql, Integer.class, discordMessageId);
        return count != null && count > 0;
    }

    public List<RecruitPost> findByGuildId(Long guildId) {
        String sql = """
                SELECT rp.*,
                       gm.character_name  AS leader_character_name,
                       c.name             AS composition_name
                FROM recruit_posts rp
                JOIN guild_members gm ON gm.id = rp.leader_member_id
                LEFT JOIN compositions c ON c.id = rp.composition_id
                WHERE rp.guild_id = ?
                ORDER BY rp.created_at DESC
                """;
        return jdbc.query(sql, (rs, rowNum) -> mapRow(rs), guildId);
    }

    public Optional<RecruitPost> findById(Long id) {
        String sql = """
                SELECT rp.*,
                       gm.character_name  AS leader_character_name,
                       c.name             AS composition_name
                FROM recruit_posts rp
                JOIN guild_members gm ON gm.id = rp.leader_member_id
                LEFT JOIN compositions c ON c.id = rp.composition_id
                WHERE rp.id = ?
                """;
        List<RecruitPost> results = jdbc.query(sql, (rs, rowNum) -> mapRow(rs), id);
        return results.isEmpty() ? Optional.empty() : Optional.of(results.get(0));
    }

    public void updateStatus(Long id, RecruitPost.Status status) {
        jdbc.update("UPDATE recruit_posts SET status = ? WHERE id = ?", status.name(), id);
    }

    public void updatePost(Long id, String content, String isPublic, String mandatory,
                           String scheduledAt, Integer minMembers, Integer maxMembers, Long compositionId) {
        jdbc.update("""
                UPDATE recruit_posts
                SET content = ?, is_public = ?, mandatory = ?, scheduled_at = ?,
                    min_members = ?, max_members = ?, composition_id = ?
                WHERE id = ?
                """,
                content, isPublic, mandatory, scheduledAt, minMembers, maxMembers, compositionId, id);
    }

    public void deleteById(Long id) {
        jdbc.update("DELETE FROM recruit_participants WHERE post_id = ?", id);
        jdbc.update("DELETE FROM recruit_posts WHERE id = ?", id);
    }

    public void updateMetadata(Long id, String isPublic, String mandatory,
                               String scheduledAt, Integer minMembers, Integer maxMembers, Long compositionId) {
        jdbc.update("""
                UPDATE recruit_posts
                SET is_public = ?, mandatory = ?, scheduled_at = ?,
                    min_members = ?, max_members = ?, composition_id = ?
                WHERE id = ?
                """,
                isPublic, mandatory, scheduledAt, minMembers, maxMembers, compositionId, id);
    }

    private RecruitPost mapRow(java.sql.ResultSet rs) throws java.sql.SQLException {
        RecruitPost post = new RecruitPost();
        post.setId(rs.getLong("id"));
        post.setGuildId(rs.getLong("guild_id"));
        post.setLeaderMemberId(rs.getLong("leader_member_id"));
        post.setContent(rs.getString("content"));

        Timestamp scheduledAt = rs.getTimestamp("scheduled_at", java.util.Calendar.getInstance(java.util.TimeZone.getTimeZone("UTC")));
        if (scheduledAt != null) post.setScheduledAt(scheduledAt.toLocalDateTime());

        post.setMinMembers((Integer) rs.getObject("min_members"));
        post.setMaxMembers((Integer) rs.getObject("max_members"));

        long compId = rs.getLong("composition_id");
        if (!rs.wasNull()) post.setCompositionId(compId);

        post.setPublic("Y".equals(rs.getString("is_public")));
        post.setStatus(RecruitPost.Status.valueOf(rs.getString("status")));
        post.setDiscordMessageId(rs.getString("discord_message_id"));
        post.setSource(RecruitPost.Source.valueOf(rs.getString("source")));
        post.setMandatory(rs.getString("mandatory") != null ? rs.getString("mandatory") : "N");
        post.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());

        post.setLeaderCharacterName(rs.getString("leader_character_name"));
        post.setCompositionName(rs.getString("composition_name"));
        return post;
    }
}
