package com.neverdisband.model;

import java.time.LocalDateTime;
import java.util.List;

public class Composition {

    private Long id;
    private Long userId;
    private String name;
    private boolean isPublic;
    private LocalDateTime createdAt;

    // 조회 시 슬롯 목록을 함께 채워주는 런타임 필드 (DB 미저장)
    private List<CompositionSlot> slots;

    public Composition() {}

    public Composition(Long userId, String name, boolean isPublic) {
        this.userId = userId;
        this.name = name;
        this.isPublic = isPublic;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public boolean isPublic() { return isPublic; }
    public void setPublic(boolean isPublic) { this.isPublic = isPublic; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public List<CompositionSlot> getSlots() { return slots; }
    public void setSlots(List<CompositionSlot> slots) { this.slots = slots; }
}
