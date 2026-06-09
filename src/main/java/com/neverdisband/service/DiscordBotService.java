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
     * permissions=0 (최소 권한), scope=bot 으로 서버에 봇 추가
     */
    public String buildBotInviteUrl(String state) {
        return OAuthConfig.AUTHORIZATION_ENDPOINT
                + "?client_id=" + encode(oAuthConfig.getClientId())
                + "&permissions=0"
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
}
