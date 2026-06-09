package com.neverdisband.dao;

import com.neverdisband.model.Guild;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public class GuildDao {

    private final JdbcTemplate jdbc;

    public GuildDao(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public void insert(Guild guild) {
        String sql = """
                INSERT INTO guilds (name, subdomain, discord_guild_id, owner_discord_id)
                VALUES (?, ?, ?, ?)
                """;
        jdbc.update(sql, guild.getName(), guild.getSubdomain(), guild.getDiscordGuildId(), guild.getOwnerDiscordId());
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

    public boolean existsBySubdomain(String subdomain) {
        String sql = "SELECT COUNT(*) FROM guilds WHERE subdomain = ?";
        Integer count = jdbc.queryForObject(sql, Integer.class, subdomain);
        return count != null && count > 0;
    }

    public List<Guild> findByOwnerDiscordId(String ownerDiscordId) {
        String sql = "SELECT * FROM guilds WHERE owner_discord_id = ?";
        return jdbc.query(sql, (rs, rowNum) -> {
            Guild guild = new Guild();
            guild.setId(rs.getLong("id"));
            guild.setName(rs.getString("name"));
            guild.setSubdomain(rs.getString("subdomain"));
            guild.setDiscordGuildId(rs.getString("discord_guild_id"));
            guild.setOwnerDiscordId(rs.getString("owner_discord_id"));
            guild.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
            return guild;
        }, ownerDiscordId);
    }

    public Optional<Guild> findByDiscordGuildId(String discordGuildId) {
        String sql = "SELECT * FROM guilds WHERE discord_guild_id = ?";
        return jdbc.query(sql, rs -> {
            if (rs.next()) {
                Guild guild = new Guild();
                guild.setId(rs.getLong("id"));
                guild.setName(rs.getString("name"));
                guild.setSubdomain(rs.getString("subdomain"));
                guild.setDiscordGuildId(rs.getString("discord_guild_id"));
                guild.setOwnerDiscordId(rs.getString("owner_discord_id"));
                guild.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
                return Optional.of(guild);
            }
            return Optional.empty();
        }, discordGuildId);
    }
}
