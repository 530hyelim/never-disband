package com.neverdisband.dao;

import com.neverdisband.model.GuildPage;
import com.neverdisband.model.PageType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public class GuildPageDao {

    private final JdbcTemplate jdbc;

    public GuildPageDao(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /**
     * 길드 생성 시 모든 페이지를 기본값으로 일괄 생성 (사용/미연동)
     */
    public void insertAllDefaults(Long guildId) {
        String sql = "INSERT INTO guild_pages (guild_id, page_type) VALUES (?, ?)";
        for (PageType type : PageType.values()) {
            jdbc.update(sql, guildId, type.name());
        }
    }

    public List<GuildPage> findByGuildId(Long guildId) {
        String sql = "SELECT * FROM guild_pages WHERE guild_id = ? ORDER BY id";
        return jdbc.query(sql, (rs, rowNum) -> mapRow(rs), guildId);
    }

    public Optional<GuildPage> findByGuildIdAndType(Long guildId, PageType type) {
        String sql = "SELECT * FROM guild_pages WHERE guild_id = ? AND page_type = ?";
        List<GuildPage> results = jdbc.query(sql, (rs, rowNum) -> mapRow(rs), guildId, type.name());
        return results.isEmpty() ? Optional.empty() : Optional.of(results.get(0));
    }

    public void updateEnabled(Long guildId, PageType type, boolean enabled) {
        String sql = "UPDATE guild_pages SET enabled = ? WHERE guild_id = ? AND page_type = ?";
        jdbc.update(sql, enabled ? 1 : 0, guildId, type.name());
    }

    public void updateChannel(Long guildId, PageType type, String channelId, String channelName) {
        String sql = "UPDATE guild_pages SET discord_channel_id = ?, discord_channel_name = ? WHERE guild_id = ? AND page_type = ?";
        jdbc.update(sql, channelId, channelName, guildId, type.name());
    }

    public void clearChannel(Long guildId, PageType type) {
        String sql = "UPDATE guild_pages SET discord_channel_id = NULL, discord_channel_name = NULL WHERE guild_id = ? AND page_type = ?";
        jdbc.update(sql, guildId, type.name());
    }

    /**
     * discord_channel_id로 페이지 조회 (Gateway 이벤트에서 사용)
     */
    public Optional<GuildPage> findByDiscordChannelId(String discordChannelId) {
        String sql = "SELECT * FROM guild_pages WHERE discord_channel_id = ?";
        List<GuildPage> results = jdbc.query(sql, (rs, rowNum) -> mapRow(rs), discordChannelId);
        return results.isEmpty() ? Optional.empty() : Optional.of(results.get(0));
    }

    private GuildPage mapRow(java.sql.ResultSet rs) throws java.sql.SQLException {
        GuildPage page = new GuildPage();
        page.setId(rs.getLong("id"));
        page.setGuildId(rs.getLong("guild_id"));
        page.setPageType(PageType.valueOf(rs.getString("page_type")));
        page.setEnabled(rs.getBoolean("enabled"));
        page.setDiscordChannelId(rs.getString("discord_channel_id"));
        page.setDiscordChannelName(rs.getString("discord_channel_name"));
        page.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        return page;
    }
}
