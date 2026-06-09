package com.neverdisband.model;

import java.time.LocalDateTime;
public class GuildMember {

    private Long id;
    private Long guildId;
    private Long userId;
    private LocalDateTime joinedAt;

    public GuildMember() {}

    public GuildMember(Long guildId, Long userId) {
        this.guildId = guildId;
        this.userId = userId;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getGuildId() { return guildId; }
    public void setGuildId(Long guildId) { this.guildId = guildId; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public LocalDateTime getJoinedAt() { return joinedAt; }
    public void setJoinedAt(LocalDateTime joinedAt) { this.joinedAt = joinedAt; }
}
