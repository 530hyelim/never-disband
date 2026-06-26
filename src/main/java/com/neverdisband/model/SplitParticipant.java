package com.neverdisband.model;

public class SplitParticipant {

    private Long id;
    private Long settlementId;
    private Long memberId;
    private String characterName;
    private Integer choice;   // 경마: 말 번호, 사다리: 라인 번호, 주사위: null
    private Integer rank;     // null=미확정, 0=포기, 1~N=순위

    public SplitParticipant() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getSettlementId() { return settlementId; }
    public void setSettlementId(Long settlementId) { this.settlementId = settlementId; }

    public Long getMemberId() { return memberId; }
    public void setMemberId(Long memberId) { this.memberId = memberId; }

    public String getCharacterName() { return characterName; }
    public void setCharacterName(String characterName) { this.characterName = characterName; }

    public Integer getChoice() { return choice; }
    public void setChoice(Integer choice) { this.choice = choice; }

    public Integer getRank() { return rank; }
    public void setRank(Integer rank) { this.rank = rank; }
}
