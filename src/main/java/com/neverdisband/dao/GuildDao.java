package com.neverdisband.dao;

import com.neverdisband.model.Guild;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.List;
import java.util.Optional;

@Repository
public class GuildDao {

    private final JdbcTemplate jdbc;

    public GuildDao(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /**
     * 길드를 DB에 저장하고 생성된 PK를 반환합니다.
     */
    public Long insert(Guild guild) {
        String sql = """
                INSERT INTO guilds (name, subdomain, discord_guild_id, albion_guild_id, owner_discord_id)
                VALUES (?, ?, ?, ?, ?)
                """;
        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbc.update(con -> {
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, guild.getName());
            ps.setString(2, guild.getSubdomain());
            ps.setString(3, guild.getDiscordGuildId());
            ps.setString(4, guild.getAlbionGuildId());
            ps.setString(5, guild.getOwnerDiscordId());
            return ps;
        }, keyHolder);
        return keyHolder.getKey().longValue();
    }

    public boolean existsByDiscordGuildId(String discordGuildId) {
        String sql = "SELECT COUNT(*) FROM guilds WHERE discord_guild_id = ?";
        Integer count = jdbc.queryForObject(sql, Integer.class, discordGuildId);
        return count != null && count > 0;
    }

    public boolean existsByName(String name) {
        String sql = "SELECT COUNT(*) FROM guilds WHERE name = ?";
        Integer count = jdbc.queryForObject(sql, Integer.class, name);
        return count != null && count > 0;
    }

    public List<Guild> findByName(String name) {
        String sql = "SELECT * FROM guilds WHERE name = ?";
        return jdbc.query(sql, (rs, rowNum) -> mapGuild(rs), name);
    }

    public boolean existsBySubdomain(String subdomain) {
        String sql = "SELECT COUNT(*) FROM guilds WHERE subdomain = ?";
        Integer count = jdbc.queryForObject(sql, Integer.class, subdomain);
        return count != null && count > 0;
    }

    public Optional<Guild> findBySubdomain(String subdomain) {
        String sql = "SELECT * FROM guilds WHERE subdomain = ?";
        return jdbc.query(sql, rs -> rs.next() ? Optional.of(mapGuild(rs)) : Optional.empty(), subdomain);
    }

    public Optional<Guild> findById(Long id) {
        String sql = "SELECT * FROM guilds WHERE id = ?";
        return jdbc.query(sql, rs -> rs.next() ? Optional.of(mapGuild(rs)) : Optional.empty(), id);
    }

    public List<Guild> findByOwnerDiscordId(String ownerDiscordId) {
        String sql = "SELECT * FROM guilds WHERE owner_discord_id = ?";
        return jdbc.query(sql, (rs, rowNum) -> mapGuild(rs), ownerDiscordId);
    }

    public List<Guild> findByMemberDiscordId(String discordId) {
        String sql = """
                SELECT g.* FROM guilds g
                JOIN guild_members gm ON gm.guild_id = g.id
                JOIN users u ON u.id = gm.user_id
                WHERE u.discord_id = ?
                """;
        return jdbc.query(sql, (rs, rowNum) -> mapGuild(rs), discordId);
    }

    public Optional<Guild> findByDiscordGuildId(String discordGuildId) {
        String sql = "SELECT * FROM guilds WHERE discord_guild_id = ?";
        return jdbc.query(sql, rs -> rs.next() ? Optional.of(mapGuild(rs)) : Optional.empty(), discordGuildId);
    }

    public Optional<Guild> findByAlbionGuildId(String albionGuildId) {
        String sql = "SELECT * FROM guilds WHERE albion_guild_id = ?";
        return jdbc.query(sql, rs -> rs.next() ? Optional.of(mapGuild(rs)) : Optional.empty(), albionGuildId);
    }

    public void updateVoiceCategoryId(Long guildId, String voiceCategoryId) {
        jdbc.update("UPDATE guilds SET voice_category_id = ? WHERE id = ?", voiceCategoryId, guildId);
    }

    public String getVoiceCategoryId(Long guildId) {
        return jdbc.query("SELECT voice_category_id FROM guilds WHERE id = ?", rs -> {
            if (rs.next()) return rs.getString("voice_category_id");
            return null;
        }, guildId);
    }

    public void updateMemberRoleId(Long guildId, String memberRoleId) {
        jdbc.update("UPDATE guilds SET member_role_id = ? WHERE id = ?", memberRoleId, guildId);
    }

    public List<Guild> findAll() {
        String sql = "SELECT * FROM guilds";
        return jdbc.query(sql, (rs, rowNum) -> mapGuild(rs));
    }

    public String getMemberRoleId(Long guildId) {
        // Guild 모델에 이미 로드됨 — 별도 조회가 필요한 경우 사용
        return jdbc.query("SELECT member_role_id FROM guilds WHERE id = ?", rs -> {
            if (rs.next()) return rs.getString("member_role_id");
            return null;
        }, guildId);
    }

    /**
     * ResultSet → Guild 매핑 공통 메서드
     */
    private Guild mapGuild(java.sql.ResultSet rs) throws java.sql.SQLException {
        Guild guild = new Guild();
        guild.setId(rs.getLong("id"));
        guild.setName(rs.getString("name"));
        guild.setSubdomain(rs.getString("subdomain"));
        guild.setDiscordGuildId(rs.getString("discord_guild_id"));
        guild.setAlbionGuildId(rs.getString("albion_guild_id"));
        guild.setOwnerDiscordId(rs.getString("owner_discord_id"));
        guild.setVoiceCategoryId(rs.getString("voice_category_id"));
        guild.setMemberRoleId(rs.getString("member_role_id"));
        guild.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        return guild;
    }
}
