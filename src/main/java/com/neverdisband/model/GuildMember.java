package com.neverdisband.model;

import java.time.LocalDateTime;
public class GuildMember {

    private Long id;
    private Long guildId;
    private Long userId;
    private String characterName;
    private Long balance;
    private LocalDateTime joinedAt;

    public GuildMember() {}

    public GuildMember(Long guildId, Long userId, String characterName) {
        this.guildId = guildId;
        this.userId = userId;
        this.characterName = characterName;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getGuildId() { return guildId; }
    public void setGuildId(Long guildId) { this.guildId = guildId; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getCharacterName() { return characterName; }
    public void setCharacterName(String characterName) { this.characterName = characterName; }

    public Long getBalance() { return balance; }
    public void setBalance(Long balance) { this.balance = balance; }

    public LocalDateTime getJoinedAt() { return joinedAt; }
    public void setJoinedAt(LocalDateTime joinedAt) { this.joinedAt = joinedAt; }
}
