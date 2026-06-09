package com.neverdisband.model;

import java.time.LocalDateTime;

public class Guild {

    private Long id;
    private String name;
    private String subdomain;
    private String discordGuildId;
    private String ownerDiscordId;
    private LocalDateTime createdAt;

    public Guild() {}

    public Guild(String name, String subdomain, String discordGuildId, String ownerDiscordId) {
        this.name = name;
        this.subdomain = subdomain;
        this.discordGuildId = discordGuildId;
        this.ownerDiscordId = ownerDiscordId;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getSubdomain() { return subdomain; }
    public void setSubdomain(String subdomain) { this.subdomain = subdomain; }

    public String getDiscordGuildId() { return discordGuildId; }
    public void setDiscordGuildId(String discordGuildId) { this.discordGuildId = discordGuildId; }

    public String getOwnerDiscordId() { return ownerDiscordId; }
    public void setOwnerDiscordId(String ownerDiscordId) { this.ownerDiscordId = ownerDiscordId; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
