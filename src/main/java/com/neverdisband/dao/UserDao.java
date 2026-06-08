package com.neverdisband.dao;

import com.neverdisband.model.User;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public class UserDao {

    private final JdbcTemplate jdbc;

    public UserDao(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public User upsert(User user) {
        String sql = """
                INSERT INTO users (discord_id, username, avatar_hash)
                VALUES (?, ?, ?)
                ON DUPLICATE KEY UPDATE
                    username = VALUES(username),
                    avatar_hash = VALUES(avatar_hash),
                    last_login_at = CURRENT_TIMESTAMP
                """;
        jdbc.update(sql, user.getDiscordId(), user.getUsername(), user.getAvatarHash());
        return user;
    }

    public Optional<User> findByDiscordId(String discordId) {
        String sql = "SELECT * FROM users WHERE discord_id = ?";
        return jdbc.query(sql, rs -> {
            if (rs.next()) {
                User user = new User();
                user.setId(rs.getLong("id"));
                user.setDiscordId(rs.getString("discord_id"));
                user.setUsername(rs.getString("username"));
                user.setAvatarHash(rs.getString("avatar_hash"));
                user.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
                user.setLastLoginAt(rs.getTimestamp("last_login_at").toLocalDateTime());
                return Optional.of(user);
            }
            return Optional.empty();
        }, discordId);
    }
}
