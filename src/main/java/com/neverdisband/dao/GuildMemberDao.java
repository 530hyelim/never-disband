package com.neverdisband.dao;

import com.neverdisband.model.GuildMember;
import com.neverdisband.model.GuildMemberRole;
import com.neverdisband.model.GuildRole;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.List;

@Repository
public class GuildMemberDao {

    private final JdbcTemplate jdbc;

    public GuildMemberDao(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /**
     * guild_members에 멤버십을 삽입하고 생성된 PK를 반환합니다.
     */
    public Long insert(GuildMember member) {
        String sql = "INSERT INTO guild_members (guild_id, user_id, character_name) VALUES (?, ?, ?)";
        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbc.update(con -> {
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setLong(1, member.getGuildId());
            ps.setLong(2, member.getUserId());
            ps.setString(3, member.getCharacterName());
            return ps;
        }, keyHolder);
        return keyHolder.getKey().longValue();
    }

    /**
     * guild_member_roles에 role을 추가합니다.
     */
    public void insertRole(GuildMemberRole memberRole) {
        String sql = "INSERT INTO guild_member_roles (member_id, role) VALUES (?, ?)";
        jdbc.update(sql, memberRole.getMemberId(), memberRole.getRole().name());
    }

    public boolean existsByGuildIdAndUserId(Long guildId, Long userId) {
        String sql = "SELECT COUNT(*) FROM guild_members WHERE guild_id = ? AND user_id = ?";
        Integer count = jdbc.queryForObject(sql, Integer.class, guildId, userId);
        return count != null && count > 0;
    }

    public GuildMember findByGuildIdAndUserId(Long guildId, Long userId) {
        String sql = "SELECT * FROM guild_members WHERE guild_id = ? AND user_id = ?";
        List<GuildMember> results = jdbc.query(sql, (rs, rowNum) -> {
            GuildMember member = new GuildMember();
            member.setId(rs.getLong("id"));
            member.setGuildId(rs.getLong("guild_id"));
            member.setUserId(rs.getLong("user_id"));
            member.setCharacterName(rs.getString("character_name"));
            member.setBalance(rs.getLong("balance"));
            member.setJoinedAt(rs.getTimestamp("joined_at").toLocalDateTime());
            return member;
        }, guildId, userId);
        return results.isEmpty() ? null : results.get(0);
    }

    public List<GuildMember> findByGuildId(Long guildId) {
        String sql = "SELECT * FROM guild_members WHERE guild_id = ?";
        return jdbc.query(sql, (rs, rowNum) -> {
            GuildMember member = new GuildMember();
            member.setId(rs.getLong("id"));
            member.setGuildId(rs.getLong("guild_id"));
            member.setUserId(rs.getLong("user_id"));
            member.setCharacterName(rs.getString("character_name"));
            member.setBalance(rs.getLong("balance"));
            member.setJoinedAt(rs.getTimestamp("joined_at").toLocalDateTime());
            return member;
        }, guildId);
    }

    public List<GuildMember> findByUserId(Long userId) {
        String sql = "SELECT * FROM guild_members WHERE user_id = ?";
        return jdbc.query(sql, (rs, rowNum) -> {
            GuildMember member = new GuildMember();
            member.setId(rs.getLong("id"));
            member.setGuildId(rs.getLong("guild_id"));
            member.setUserId(rs.getLong("user_id"));
            member.setCharacterName(rs.getString("character_name"));
            member.setBalance(rs.getLong("balance"));
            member.setJoinedAt(rs.getTimestamp("joined_at").toLocalDateTime());
            return member;
        }, userId);
    }

    public List<GuildMemberRole> findRolesByMemberId(Long memberId) {
        String sql = "SELECT * FROM guild_member_roles WHERE member_id = ?";
        return jdbc.query(sql, (rs, rowNum) -> {
            GuildMemberRole mr = new GuildMemberRole();
            mr.setId(rs.getLong("id"));
            mr.setMemberId(rs.getLong("member_id"));
            mr.setRole(GuildRole.valueOf(rs.getString("role")));
            return mr;
        }, memberId);
    }

    public int countByGuildId(Long guildId) {
        String sql = "SELECT COUNT(*) FROM guild_members WHERE guild_id = ?";
        Integer count = jdbc.queryForObject(sql, Integer.class, guildId);
        return count != null ? count : 0;
    }

    public String findCharacterNameByGuildIdAndDiscordId(Long guildId, String discordId) {
        String sql = """
                SELECT gm.character_name FROM guild_members gm
                JOIN users u ON u.id = gm.user_id
                WHERE gm.guild_id = ? AND u.discord_id = ?
                """;
        List<String> results = jdbc.query(sql, (rs, rowNum) -> rs.getString("character_name"), guildId, discordId);
        return results.isEmpty() ? null : results.get(0);
    }

    /**
     * guild_id + discord_id로 guild_members.id 조회
     * Gateway 이벤트에서 메시지 발신자를 길드 멤버로 특정할 때 사용
     */
    public Long findMemberIdByGuildIdAndDiscordId(Long guildId, String discordId) {
        String sql = """
                SELECT gm.id FROM guild_members gm
                JOIN users u ON u.id = gm.user_id
                WHERE gm.guild_id = ? AND u.discord_id = ?
                """;
        List<Long> results = jdbc.query(sql, (rs, rowNum) -> rs.getLong("id"), guildId, discordId);
        return results.isEmpty() ? null : results.get(0);
    }

    public GuildMember findById(Long memberId) {
        String sql = "SELECT * FROM guild_members WHERE id = ?";
        List<GuildMember> results = jdbc.query(sql, (rs, rowNum) -> {
            GuildMember member = new GuildMember();
            member.setId(rs.getLong("id"));
            member.setGuildId(rs.getLong("guild_id"));
            member.setUserId(rs.getLong("user_id"));
            member.setCharacterName(rs.getString("character_name"));
            member.setBalance(rs.getLong("balance"));
            member.setJoinedAt(rs.getTimestamp("joined_at").toLocalDateTime());
            return member;
        }, memberId);
        return results.isEmpty() ? null : results.get(0);
    }

    /**
     * 길드 멤버 삭제 - 사용자가 직접 사이트 탈퇴 or 관리자에 의해 추방
     * 관련 역할, 모집 참여 등 종속 데이터도 정리
     */
    public void deleteByGuildIdAndUserId(Long guildId, Long userId) {
        var member = findByGuildIdAndUserId(guildId, userId);
        if (member == null) return;
        jdbc.update("DELETE FROM guild_member_roles WHERE member_id = ?", member.getId());
        jdbc.update("DELETE FROM recruit_participants WHERE member_id = ?", member.getId());
        jdbc.update("DELETE FROM guild_members WHERE id = ?", member.getId());
    }

    /**
     * 멤버에게 MEMBER 역할 부여 (중복 방지)
     */
    public void grantMemberRole(Long memberId) {
        grantRole(memberId, com.neverdisband.model.GuildRole.MEMBER);
    }

    /**
     * 멤버에서 MEMBER 역할 제거
     */
    public void revokeMemberRole(Long memberId) {
        revokeRole(memberId, com.neverdisband.model.GuildRole.MEMBER);
    }

    /**
     * 멤버에게 특정 역할 부여 (중복 방지)
     */
    public void grantRole(Long memberId, com.neverdisband.model.GuildRole role) {
        String check = "SELECT COUNT(*) FROM guild_member_roles WHERE member_id = ? AND role = ?";
        Integer count = jdbc.queryForObject(check, Integer.class, memberId, role.name());
        if (count != null && count > 0) return;
        jdbc.update("INSERT INTO guild_member_roles (member_id, role) VALUES (?, ?)", memberId, role.name());
    }

    /**
     * 멤버에서 특정 역할 제거
     */
    public void revokeRole(Long memberId, com.neverdisband.model.GuildRole role) {
        jdbc.update("DELETE FROM guild_member_roles WHERE member_id = ? AND role = ?", memberId, role.name());
    }

    /**
     * 멤버가 MEMBER 역할을 보유하고 있는지 확인
     */
    public boolean hasMemberRole(Long memberId) {
        String sql = "SELECT COUNT(*) FROM guild_member_roles WHERE member_id = ? AND role = 'MEMBER'";
        Integer count = jdbc.queryForObject(sql, Integer.class, memberId);
        return count != null && count > 0;
    }

    /**
     * 멤버가 길드마스터인지 확인
     */
    public boolean isGuildMaster(Long memberId) {
        String sql = "SELECT COUNT(*) FROM guild_member_roles WHERE member_id = ? AND role = 'GUILD_MASTER'";
        Integer count = jdbc.queryForObject(sql, Integer.class, memberId);
        return count != null && count > 0;
    }

    /**
     * 멤버가 특정 역할을 보유하고 있는지 확인
     */
    public boolean hasRole(Long memberId, com.neverdisband.model.GuildRole role) {
        String sql = "SELECT COUNT(*) FROM guild_member_roles WHERE member_id = ? AND role = ?";
        Integer count = jdbc.queryForObject(sql, Integer.class, memberId, role.name());
        return count != null && count > 0;
    }
}