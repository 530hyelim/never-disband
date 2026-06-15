package com.neverdisband.model;

import java.time.LocalDateTime;

public class GuildPage {

    private Long id;
    private Long guildId;
    private PageType pageType;
    private boolean enabled;
    private String discordChannelId;
    private String discordChannelName;
    private LocalDateTime createdAt;

    public GuildPage() {}

    public GuildPage(Long guildId, PageType pageType) {
        this.guildId = guildId;
        this.pageType = pageType;
        this.enabled = true;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getGuildId() { return guildId; }
    public void setGuildId(Long guildId) { this.guildId = guildId; }

    public PageType getPageType() { return pageType; }
    public void setPageType(PageType pageType) { this.pageType = pageType; }

    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }

    public String getDiscordChannelId() { return discordChannelId; }
    public void setDiscordChannelId(String discordChannelId) { this.discordChannelId = discordChannelId; }

    public String getDiscordChannelName() { return discordChannelName; }
    public void setDiscordChannelName(String discordChannelName) { this.discordChannelName = discordChannelName; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
