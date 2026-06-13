package com.neverdisband.service;

import com.neverdisband.config.OAuthConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.Map;

@Service
public class DiscordBotService {

    private static final Logger logger = LoggerFactory.getLogger(DiscordBotService.class);
    private final HttpClient httpClient = HttpClient.newHttpClient();
    private final OAuthConfig oAuthConfig;

    public DiscordBotService(OAuthConfig oAuthConfig) {
        this.oAuthConfig = oAuthConfig;
    }

    /**
     * 봇 초대 URL 생성
     * permissions=8 (Administrator), scope=bot 으로 서버에 봇 추가
     */
    public String buildBotInviteUrl(String state) {
        return OAuthConfig.AUTHORIZATION_ENDPOINT
                + "?client_id=" + encode(oAuthConfig.getClientId())
                + "&permissions=8"
                + "&scope=bot"
                + "&redirect_uri=" + encode(oAuthConfig.getBotRedirectUri())
                + "&response_type=code"
                + "&state=" + encode(state);
    }

    /**
     * Bot Token을 이용해 Discord API에서 길드 정보 조회
     * 반환: { "name": "서버명", "owner_id": "소유자 discord id", "id": "guild id" } 등
     */
    public Map<String, String> fetchGuildInfo(String guildId) {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(OAuthConfig.GUILD_ENDPOINT + guildId))
                .header("Authorization", "Bot " + oAuthConfig.getBotToken())
                .GET()
                .build();

        try {
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                logger.warn("Guild info fetch failed: status={}, body={}", response.statusCode(), response.body());
                return null;
            }

            String json = response.body();
            String name = extractJsonValue(json, "name");
            String ownerId = extractJsonValue(json, "owner_id");
            String id = extractJsonValue(json, "id");

            return Map.of("name", name != null ? name : "",
                          "owner_id", ownerId != null ? ownerId : "",
                          "id", id != null ? id : "");

        } catch (IOException | InterruptedException e) {
            logger.error("Failed to fetch guild info for guildId={}", guildId, e);
            if (e instanceof InterruptedException) {
                Thread.currentThread().interrupt();
            }
            return null;
        }
    }

    /**
     * 특정 유저가 디스코드 서버에 참여 중인지 확인
     * Discord Bot API: GET /guilds/{guild_id}/members/{user_id}
     */
    public boolean isUserInGuild(String guildId, String userDiscordId) {
        String url = OAuthConfig.GUILD_ENDPOINT + guildId + "/members/" + userDiscordId;
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Bot " + oAuthConfig.getBotToken())
                .GET()
                .build();

        try {
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            return response.statusCode() == 200;
        } catch (IOException | InterruptedException e) {
            logger.error("Failed to check guild membership: guildId={}, userId={}", guildId, userDiscordId, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return false;
        }
    }

    private String extractJsonValue(String json, String key) {
        String search = "\"" + key + "\"";
        int keyIndex = json.indexOf(search);
        if (keyIndex == -1) return null;

        int colonIndex = json.indexOf(":", keyIndex);
        int valueStart = colonIndex + 1;

        while (valueStart < json.length() && json.charAt(valueStart) == ' ') {
            valueStart++;
        }

        if (json.charAt(valueStart) == '"') {
            int valueEnd = json.indexOf("\"", valueStart + 1);
            return json.substring(valueStart + 1, valueEnd);
        } else if (json.substring(valueStart).startsWith("null")) {
            return null;
        } else {
            int valueEnd = valueStart;
            while (valueEnd < json.length() && json.charAt(valueEnd) != ',' && json.charAt(valueEnd) != '}') {
                valueEnd++;
            }
            return json.substring(valueStart, valueEnd).trim();
        }
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    /**
     * 디스코드 채널에 메시지 전송
     * @return 전송된 메시지 ID (실패 시 null)
     */
    public String sendChannelMessage(String channelId, String content) {
        String url = "https://discord.com/api/v10/channels/" + channelId + "/messages";
        String jsonBody = "{\"content\":" + escapeJson(content) + "}";

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Bot " + oAuthConfig.getBotToken())
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                .build();

        try {
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() == 200 || response.statusCode() == 201) {
                return extractJsonValue(response.body(), "id");
            }
            logger.warn("Discord sendMessage failed: status={}, body={}", response.statusCode(), response.body());
            return null;
        } catch (IOException | InterruptedException e) {
            logger.error("Failed to send Discord message to channel={}", channelId, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return null;
        }
    }

    /**
     * 디스코드 채널 메시지 수정
     */
    public boolean editChannelMessage(String channelId, String messageId, String content) {
        String url = "https://discord.com/api/v10/channels/" + channelId + "/messages/" + messageId;
        String jsonBody = "{\"content\":" + escapeJson(content) + "}";

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Bot " + oAuthConfig.getBotToken())
                .header("Content-Type", "application/json")
                .method("PATCH", HttpRequest.BodyPublishers.ofString(jsonBody))
                .build();

        try {
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() == 200) return true;
            logger.warn("Discord editMessage failed: status={}, body={}", response.statusCode(), response.body());
            return false;
        } catch (IOException | InterruptedException e) {
            logger.error("Failed to edit Discord message={} in channel={}", messageId, channelId, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return false;
        }
    }

    private String escapeJson(String value) {
        if (value == null) return "null";
        return "\"" + value.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r") + "\"";
    }

    /**
     * 봇이 해당 채널에 접근 가능한지 확인
     * @return true면 접근 가능, false면 권한 없음
     */
    public boolean canAccessChannel(String channelId) {
        String url = "https://discord.com/api/v10/channels/" + channelId;
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Bot " + oAuthConfig.getBotToken())
                .GET()
                .build();

        try {
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            return response.statusCode() == 200;
        } catch (IOException | InterruptedException e) {
            logger.error("Failed to check channel access: channelId={}", channelId, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return false;
        }
    }
}
