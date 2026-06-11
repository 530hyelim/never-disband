package com.neverdisband.model;

import java.time.LocalDateTime;

public class RecruitPost {

    public enum Source { SITE, DISCORD }
    public enum Status { OPEN, CLOSED }

    private Long id;
    private Long guildId;
    private Long leaderMemberId;
    private String content;
    private LocalDateTime scheduledAt;      // null: 미정
    private Integer minMembers;             // null: 미정
    private Integer maxMembers;             // null: 미정
    private Long compositionId;             // null: 미정
    private boolean isPublic;               // false: 길드원만, true: 누구나
    private Status status;                  // OPEN: 모집중, CLOSED: 완료
    private String discordMessageId;        // null: 사이트 origin
    private Source source;
    private LocalDateTime createdAt;

    // 조회 시 JOIN으로 채워주는 런타임 필드 (DB 미저장)
    private String compositionName;
    private String leaderCharacterName;

    public RecruitPost() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getGuildId() { return guildId; }
    public void setGuildId(Long guildId) { this.guildId = guildId; }

    public Long getLeaderMemberId() { return leaderMemberId; }
    public void setLeaderMemberId(Long leaderMemberId) { this.leaderMemberId = leaderMemberId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public LocalDateTime getScheduledAt() { return scheduledAt; }
    public void setScheduledAt(LocalDateTime scheduledAt) { this.scheduledAt = scheduledAt; }

    public Integer getMinMembers() { return minMembers; }
    public void setMinMembers(Integer minMembers) { this.minMembers = minMembers; }

    public Integer getMaxMembers() { return maxMembers; }
    public void setMaxMembers(Integer maxMembers) { this.maxMembers = maxMembers; }

    public Long getCompositionId() { return compositionId; }
    public void setCompositionId(Long compositionId) { this.compositionId = compositionId; }

    public boolean isPublic() { return isPublic; }
    public void setPublic(boolean isPublic) { this.isPublic = isPublic; }

    public Status getStatus() { return status; }
    public void setStatus(Status status) { this.status = status; }

    public String getDiscordMessageId() { return discordMessageId; }
    public void setDiscordMessageId(String discordMessageId) { this.discordMessageId = discordMessageId; }

    public Source getSource() { return source; }
    public void setSource(Source source) { this.source = source; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getCompositionName() { return compositionName; }
    public void setCompositionName(String compositionName) { this.compositionName = compositionName; }

    public String getLeaderCharacterName() { return leaderCharacterName; }
    public void setLeaderCharacterName(String leaderCharacterName) { this.leaderCharacterName = leaderCharacterName; }
}
