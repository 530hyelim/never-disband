package com.neverdisband.model;

import java.time.LocalDateTime;

public class CompositionSlot {

    public enum Role { OFF_TANK, MDPS, RDPS, HEALER, SUPPORT, DEF_TANK, BATTLEMOUNT }

    private Long id;
    private Long compositionId;
    private int slotOrder;
    private Role role;
    private String weapon;      // 무기
    private String offhand;     // 보조무기
    private String head;        // 머리 방어구
    private String chest;       // 갑바 방어구
    private String shoes;       // 신발 방어구
    private String cape;        // 망토
    private String food;        // 음식
    private LocalDateTime createdAt;

    public CompositionSlot() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getCompositionId() { return compositionId; }
    public void setCompositionId(Long compositionId) { this.compositionId = compositionId; }

    public int getSlotOrder() { return slotOrder; }
    public void setSlotOrder(int slotOrder) { this.slotOrder = slotOrder; }

    public Role getRole() { return role; }
    public void setRole(Role role) { this.role = role; }

    public String getWeapon() { return weapon; }
    public void setWeapon(String weapon) { this.weapon = weapon; }

    public String getOffhand() { return offhand; }
    public void setOffhand(String offhand) { this.offhand = offhand; }

    public String getHead() { return head; }
    public void setHead(String head) { this.head = head; }

    public String getChest() { return chest; }
    public void setChest(String chest) { this.chest = chest; }

    public String getShoes() { return shoes; }
    public void setShoes(String shoes) { this.shoes = shoes; }

    public String getCape() { return cape; }
    public void setCape(String cape) { this.cape = cape; }

    public String getFood() { return food; }
    public void setFood(String food) { this.food = food; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
