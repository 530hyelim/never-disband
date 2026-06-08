package com.neverdisband.dao;

import com.neverdisband.model.User;

import java.sql.*;
import java.util.Optional;

public class UserDao {

    public User upsert(User user) throws SQLException {
        String sql = """
                INSERT INTO users (discord_id, username, avatar_hash)
                VALUES (?, ?, ?)
                ON DUPLICATE KEY UPDATE
                    username = VALUES(username),
                    avatar_hash = VALUES(avatar_hash),
                    last_login_at = CURRENT_TIMESTAMP
                """;

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, user.getDiscordId());
            ps.setString(2, user.getUsername());
            ps.setString(3, user.getAvatarHash());
            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) {
                user.setId(rs.getLong(1));
            }
        }
        return user;
    }

    public Optional<User> findByDiscordId(String discordId) throws SQLException {
        String sql = "SELECT * FROM users WHERE discord_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, discordId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return Optional.of(mapRow(rs));
            }
        }
        return Optional.empty();
    }

    private User mapRow(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getLong("id"));
        user.setDiscordId(rs.getString("discord_id"));
        user.setUsername(rs.getString("username"));
        user.setAvatarHash(rs.getString("avatar_hash"));
        user.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        user.setLastLoginAt(rs.getTimestamp("last_login_at").toLocalDateTime());
        return user;
    }
}
