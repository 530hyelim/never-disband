package com.neverdisband.model;

import java.time.LocalDateTime;

public class RecruitSettlement {

    public enum SettleStatus { NONE, PENDING, DONE }

    private Long id;
    private Long postId;
    private Long guildId;
    private Long splitAmount;
    private String splitMethod;
    private SettleStatus splitStatus;
    private LocalDateTime splitExpiresAt;
    private Long feeAmount;
    private SettleStatus feeStatus;
    private LocalDateTime createdAt;

    public RecruitSettlement() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getPostId() { return postId; }
    public void setPostId(Long postId) { this.postId = postId; }

    public Long getGuildId() { return guildId; }
    public void setGuildId(Long guildId) { this.guildId = guildId; }

    public Long getSplitAmount() { return splitAmount; }
    public void setSplitAmount(Long splitAmount) { this.splitAmount = splitAmount; }

    public String getSplitMethod() { return splitMethod; }
    public void setSplitMethod(String splitMethod) { this.splitMethod = splitMethod; }

    public SettleStatus getSplitStatus() { return splitStatus; }
    public void setSplitStatus(SettleStatus splitStatus) { this.splitStatus = splitStatus; }

    public LocalDateTime getSplitExpiresAt() { return splitExpiresAt; }
    public void setSplitExpiresAt(LocalDateTime splitExpiresAt) { this.splitExpiresAt = splitExpiresAt; }

    public Long getFeeAmount() { return feeAmount; }
    public void setFeeAmount(Long feeAmount) { this.feeAmount = feeAmount; }

    public SettleStatus getFeeStatus() { return feeStatus; }
    public void setFeeStatus(SettleStatus feeStatus) { this.feeStatus = feeStatus; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
