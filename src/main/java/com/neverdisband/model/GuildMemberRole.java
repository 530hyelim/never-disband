package com.neverdisband.model;

public class GuildMemberRole {

    private Long id;
    private Long memberId;
    private GuildRole role;

    public GuildMemberRole() {}

    public GuildMemberRole(Long memberId, GuildRole role) {
        this.memberId = memberId;
        this.role = role;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getMemberId() { return memberId; }
    public void setMemberId(Long memberId) { this.memberId = memberId; }

    public GuildRole getRole() { return role; }
    public void setRole(GuildRole role) { this.role = role; }
}
