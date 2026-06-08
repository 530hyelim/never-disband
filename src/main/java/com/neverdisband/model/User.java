package com.neverdisband.model;

import java.time.LocalDateTime;

public class User {

    private Long id;
    private String discordId;
    private String username;
    private String avatarHash;
    private LocalDateTime createdAt;
    private LocalDateTime lastLoginAt;

    public User() {}

    public User(String discordId, String username, String avatarHash) {
        this.discordId = discordId;
        this.username = username;
        this.avatarHash = avatarHash;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getDiscordId() { return discordId; }
    public void setDiscordId(String discordId) { this.discordId = discordId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getAvatarHash() { return avatarHash; }
    public void setAvatarHash(String avatarHash) { this.avatarHash = avatarHash; }

    public String getAvatarUrl() {
        if (avatarHash == null) return null;
        return "https://cdn.discordapp.com/avatars/" + discordId + "/" + avatarHash + ".png";
    }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getLastLoginAt() { return lastLoginAt; }
    public void setLastLoginAt(LocalDateTime lastLoginAt) { this.lastLoginAt = lastLoginAt; }
}
