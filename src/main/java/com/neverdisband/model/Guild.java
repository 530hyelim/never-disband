package com.neverdisband.model;

import java.time.LocalDateTime;

public class Guild {

    private Long id;
    private String name;
    private String subdomain;
    private String discordGuildId;
    private String albionGuildId;
    private String ownerDiscordId;
    private String voiceCategoryId;
    private String memberRoleId;
    private LocalDateTime createdAt;

    // 알비온 API 조회 정보 (DB 미저장, 런타임용)
    private String allianceTag;
    private int memberCount;
    private String founded;
    private int registeredMemberCount;
    private String myCharacterName;

    public Guild() {}

    public Guild(String name, String subdomain, String discordGuildId, String albionGuildId, String ownerDiscordId) {
        this.name = name;
        this.subdomain = subdomain;
        this.discordGuildId = discordGuildId;
        this.albionGuildId = albionGuildId;
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

    public String getAlbionGuildId() { return albionGuildId; }
    public void setAlbionGuildId(String albionGuildId) { this.albionGuildId = albionGuildId; }

    public String getOwnerDiscordId() { return ownerDiscordId; }
    public void setOwnerDiscordId(String ownerDiscordId) { this.ownerDiscordId = ownerDiscordId; }

    public String getVoiceCategoryId() { return voiceCategoryId; }
    public void setVoiceCategoryId(String voiceCategoryId) { this.voiceCategoryId = voiceCategoryId; }

    public String getMemberRoleId() { return memberRoleId; }
    public void setMemberRoleId(String memberRoleId) { this.memberRoleId = memberRoleId; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getAllianceTag() { return allianceTag; }
    public void setAllianceTag(String allianceTag) { this.allianceTag = allianceTag; }

    public int getMemberCount() { return memberCount; }
    public void setMemberCount(int memberCount) { this.memberCount = memberCount; }

    public String getFounded() { return founded; }
    public void setFounded(String founded) { this.founded = founded; }

    public int getRegisteredMemberCount() { return registeredMemberCount; }
    public void setRegisteredMemberCount(int registeredMemberCount) { this.registeredMemberCount = registeredMemberCount; }

    public String getMyCharacterName() { return myCharacterName; }
    public void setMyCharacterName(String myCharacterName) { this.myCharacterName = myCharacterName; }

    /**
     * [AllianceTag] Name 형식으로 표시명 반환
     */
    public String getDisplayName() {
        if (allianceTag != null && !allianceTag.isEmpty()) {
            return "[" + allianceTag + "] " + name;
        }
        return name;
    }
}
