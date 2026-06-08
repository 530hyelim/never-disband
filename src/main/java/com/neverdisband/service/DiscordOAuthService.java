package com.neverdisband.service;

import com.neverdisband.config.OAuthConfig;
import com.neverdisband.exception.OAuthException;
import com.neverdisband.model.User;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.logging.Logger;

public class DiscordOAuthService {

    private static final Logger logger = Logger.getLogger(DiscordOAuthService.class.getName());
    private final HttpClient httpClient = HttpClient.newHttpClient();

    public String buildAuthorizationUrl(String state) {
        return OAuthConfig.AUTHORIZATION_ENDPOINT
                + "?client_id=" + encode(OAuthConfig.getClientId())
                + "&redirect_uri=" + encode(OAuthConfig.getRedirectUri())
                + "&response_type=code"
                + "&scope=identify"
                + "&state=" + encode(state);
    }

    public String exchangeCodeForToken(String code) throws OAuthException {
        String body = "client_id=" + encode(OAuthConfig.getClientId())
                + "&client_secret=" + encode(OAuthConfig.getClientSecret())
                + "&grant_type=authorization_code"
                + "&code=" + encode(code)
                + "&redirect_uri=" + encode(OAuthConfig.getRedirectUri());

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(OAuthConfig.TOKEN_ENDPOINT))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(body))
                .build();

        try {
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                logger.warning("Token exchange failed: " + response.body());
                throw new OAuthException(OAuthException.ErrorType.TOKEN_EXCHANGE_FAILED,
                        "토큰 교환 실패: HTTP " + response.statusCode());
            }

            return extractJsonValue(response.body(), "access_token");

        } catch (IOException e) {
            throw new OAuthException(OAuthException.ErrorType.CONNECTION_FAILED,
                    "Discord 서비스에 연결할 수 없습니다.", e);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new OAuthException(OAuthException.ErrorType.CONNECTION_FAILED,
                    "요청이 중단되었습니다.", e);
        }
    }

    public User fetchUserInfo(String accessToken) throws OAuthException {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(OAuthConfig.USER_INFO_ENDPOINT))
                .header("Authorization", "Bearer " + accessToken)
                .GET()
                .build();

        try {
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                logger.warning("User info fetch failed: " + response.body());
                throw new OAuthException(OAuthException.ErrorType.USER_INFO_FAILED,
                        "사용자 정보 조회 실패: HTTP " + response.statusCode());
            }

            String json = response.body();
            String id = extractJsonValue(json, "id");
            String username = extractJsonValue(json, "username");
            String avatar = extractJsonValue(json, "avatar");

            return new User(id, username, "null".equals(avatar) ? null : avatar);

        } catch (IOException e) {
            throw new OAuthException(OAuthException.ErrorType.CONNECTION_FAILED,
                    "Discord 서비스에 연결할 수 없습니다.", e);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new OAuthException(OAuthException.ErrorType.CONNECTION_FAILED,
                    "요청이 중단되었습니다.", e);
        }
    }

    private String extractJsonValue(String json, String key) {
        String search = "\"" + key + "\"";
        int keyIndex = json.indexOf(search);
        if (keyIndex == -1) return null;

        int colonIndex = json.indexOf(":", keyIndex);
        int valueStart = colonIndex + 1;

        // Skip whitespace
        while (valueStart < json.length() && json.charAt(valueStart) == ' ') {
            valueStart++;
        }

        if (json.charAt(valueStart) == '"') {
            // String value
            int valueEnd = json.indexOf("\"", valueStart + 1);
            return json.substring(valueStart + 1, valueEnd);
        } else if (json.substring(valueStart).startsWith("null")) {
            return "null";
        } else {
            // Number or other
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
