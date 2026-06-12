package com.neverdisband.dao;

import com.neverdisband.model.Composition;
import com.neverdisband.model.CompositionSlot;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.*;

@Repository
public class CompositionDao {

    private final JdbcTemplate jdbc;

    public CompositionDao(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public Long insert(Composition comp) {
        String sql = "INSERT INTO compositions (user_id, name, is_public) VALUES (?, ?, ?)";
        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbc.update(con -> {
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setLong(1, comp.getUserId());
            ps.setString(2, comp.getName());
            ps.setString(3, comp.isPublic() ? "Y" : "N");
            return ps;
        }, keyHolder);
        return keyHolder.getKey().longValue();
    }

    public void insertSlot(CompositionSlot slot) {
        String sql = """
                INSERT INTO composition_slots (composition_id, slot_order, role, weapon, offhand, head, chest, shoes, cape, food)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;
        jdbc.update(sql, slot.getCompositionId(), slot.getSlotOrder(), slot.getRole().name(),
                slot.getWeapon(), slot.getOffhand(), slot.getHead(), slot.getChest(),
                slot.getShoes(), slot.getCape(), slot.getFood());
    }

    public List<Composition> findByUserId(Long userId) {
        String sql = "SELECT * FROM compositions WHERE user_id = ? ORDER BY created_at DESC";
        return jdbc.query(sql, (rs, rowNum) -> {
            Composition c = new Composition();
            c.setId(rs.getLong("id"));
            c.setUserId(rs.getLong("user_id"));
            c.setName(rs.getString("name"));
            c.setPublic("Y".equals(rs.getString("is_public")));
            c.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
            return c;
        }, userId);
    }

    public Composition findById(Long id) {
        String sql = "SELECT * FROM compositions WHERE id = ?";
        return jdbc.query(sql, rs -> {
            if (rs.next()) {
                Composition c = new Composition();
                c.setId(rs.getLong("id"));
                c.setUserId(rs.getLong("user_id"));
                c.setName(rs.getString("name"));
                c.setPublic("Y".equals(rs.getString("is_public")));
                c.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
                return c;
            }
            return null;
        }, id);
    }

    public List<CompositionSlot> findSlotsByCompositionId(Long compositionId) {
        String sql = "SELECT * FROM composition_slots WHERE composition_id = ? ORDER BY slot_order";
        return jdbc.query(sql, (rs, rowNum) -> {
            CompositionSlot s = new CompositionSlot();
            s.setId(rs.getLong("id"));
            s.setCompositionId(rs.getLong("composition_id"));
            s.setSlotOrder(rs.getInt("slot_order"));
            s.setRole(CompositionSlot.Role.valueOf(rs.getString("role")));
            s.setWeapon(rs.getString("weapon"));
            s.setOffhand(rs.getString("offhand"));
            s.setHead(rs.getString("head"));
            s.setChest(rs.getString("chest"));
            s.setShoes(rs.getString("shoes"));
            s.setCape(rs.getString("cape"));
            s.setFood(rs.getString("food"));
            s.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
            return s;
        }, compositionId);
    }

    public void update(Composition comp) {
        String sql = "UPDATE compositions SET name = ?, is_public = ? WHERE id = ?";
        jdbc.update(sql, comp.getName(), comp.isPublic() ? "Y" : "N", comp.getId());
    }

    public void deleteSlotsByCompositionId(Long compositionId) {
        jdbc.update("DELETE FROM composition_slots WHERE composition_id = ?", compositionId);
    }

    public void deleteById(Long id) {
        jdbc.update("DELETE FROM compositions WHERE id = ?", id);
    }

    /**
     * 길드 멤버들의 공개 빌드 조회 (본인 제외)
     */
    public List<Map<String, Object>> findPublicByGuildId(Long guildId, Long excludeUserId) {
        String sql = """
                SELECT c.id, c.name, c.user_id,
                       (SELECT COUNT(*) FROM composition_slots cs WHERE cs.composition_id = c.id) AS slot_count
                FROM compositions c
                JOIN guild_members gm ON gm.user_id = c.user_id AND gm.guild_id = ?
                WHERE c.is_public = 'Y' AND c.user_id != ?
                ORDER BY c.name
                """;
        return jdbc.query(sql, (rs, rowNum) -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", rs.getLong("id"));
            map.put("name", rs.getString("name"));
            map.put("slots", Collections.nCopies(rs.getInt("slot_count"), null));
            return map;
        }, guildId, excludeUserId);
    }
}
