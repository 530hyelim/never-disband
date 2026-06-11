package com.neverdisband.service;

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

/**
 * 알비온 온라인 API 서비스  https://www.tools4albion.com/api_info.php
 */
@Service
public class AlbionApiService {

    private static final Logger logger = LoggerFactory.getLogger(AlbionApiService.class);
    private static final String BASE_URL = "https://gameinfo-sgp.albiononline.com/api/gameinfo";
    private final HttpClient httpClient = HttpClient.newHttpClient();

    /**
     * 길드 ID로 상세 정보 조회 (Founded, AllianceTag, MemberCount)
     * @return { "Founded": "...", "AllianceTag": "...", "MemberCount": "..." } or null
     */
    public Map<String, String> fetchGuildDetail(String guildId) {
        String url = BASE_URL + "/guilds/" + guildId;

        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                logger.warn("Albion guild detail fetch failed: status={}", response.statusCode());
                return null;
            }

            String json = response.body();
            String founded = extractStringValue(json, "Founded");
            String allianceTag = extractStringValue(json, "AllianceTag");
            String memberCount = extractNumberValue(json, "MemberCount");

            return Map.of(
                    "Founded", founded != null ? founded : "",
                    "AllianceTag", allianceTag != null ? allianceTag : "",
                    "MemberCount", memberCount != null ? memberCount : "0"
            );

        } catch (IOException | InterruptedException e) {
            logger.error("Failed to fetch guild detail for guildId={}", guildId, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return null;
        }
    }

    /**
     * 길드명으로 검색하여 정확히 일치하는 길드 ID 반환
     * @return { "id": "...", "name": "..." } or null
     */
    public Map<String, String> searchGuild(String guildName) {
        String url = BASE_URL + "/search?q=" + URLEncoder.encode(guildName, StandardCharsets.UTF_8);

        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                logger.warn("Albion search failed: status={}", response.statusCode());
                return null;
            }

            String json = response.body();
            // guilds 배열에서 이름이 정확히 일치하는 길드 찾기
            String guildsArray = extractArray(json, "guilds");
            if (guildsArray == null || guildsArray.equals("[]")) {
                return null;
            }

            // 간단한 파싱: 배열 내 각 오브젝트에서 Name이 일치하는 것 찾기
            String guildId = findMatchingGuild(guildsArray, guildName);
            if (guildId == null) {
                return null;
            }

            return Map.of("id", guildId, "name", guildName);

        } catch (IOException | InterruptedException e) {
            logger.error("Failed to search guild: {}", guildName, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return null;
        }
    }

    /**
     * 캐릭터명으로 검색하여 해당 캐릭터가 소속된 길드 정보 반환
     * @return { "guildId": "...", "guildName": "...", "allianceTag": "..." } or null (길드 미소속)
     */
    public Map<String, String> fetchGuildByCharacter(String characterName) {
        String url = BASE_URL + "/search?q=" + URLEncoder.encode(characterName, StandardCharsets.UTF_8);

        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                logger.warn("Albion character search failed: status={}", response.statusCode());
                return null;
            }

            String json = response.body();
            String playersArray = extractArray(json, "players");
            if (playersArray == null || playersArray.equals("[]")) {
                return null;
            }

            // 이름이 정확히 일치하는 플레이어의 GuildId, GuildName 추출
            return findPlayerGuild(playersArray, characterName);

        } catch (IOException | InterruptedException e) {
            logger.error("Failed to search character: {}", characterName, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return null;
        }
    }

    /**
     * 캐릭터명이 알비온 온라인에 실제 존재하는지 확인
     */
    public boolean characterExists(String characterName) {
        String url = BASE_URL + "/search?q=" + URLEncoder.encode(characterName, StandardCharsets.UTF_8);

        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) return false;

            String json = response.body();
            String playersArray = extractArray(json, "players");
            if (playersArray == null || playersArray.equals("[]")) return false;

            // 이름이 정확히 일치하는 플레이어가 있는지 확인
            int cursor = 0;
            while (true) {
                int nameIdx = playersArray.indexOf("\"Name\":\"", cursor);
                if (nameIdx == -1) break;
                int nameStart = nameIdx + 8;
                int nameEnd = playersArray.indexOf("\"", nameStart);
                if (nameEnd == -1) break;
                if (playersArray.substring(nameStart, nameEnd).equals(characterName)) return true;
                cursor = nameEnd + 1;
            }
            return false;

        } catch (IOException | InterruptedException e) {
            logger.error("Failed to check character existence: {}", characterName, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return false;
        }
    }

    /**
     * 길드 ID로 멤버 목록을 조회하여 특정 캐릭터가 있는지 확인
     */
    public boolean isCharacterInGuild(String guildId, String characterName) {
        String url = BASE_URL + "/guilds/" + guildId + "/members";

        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                logger.warn("Albion members fetch failed: status={}", response.statusCode());
                return false;
            }

            String json = response.body();
            // 멤버 목록에서 Name이 일치하는 캐릭터 검색
            return json.contains("\"Name\":\"" + characterName + "\"");

        } catch (IOException | InterruptedException e) {
            logger.error("Failed to fetch guild members for guildId={}", guildId, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return false;
        }
    }

    private String extractArray(String json, String key) {
        String search = "\"" + key + "\"";
        int keyIndex = json.indexOf(search);
        if (keyIndex == -1) return null;

        int start = json.indexOf("[", keyIndex);
        if (start == -1) return null;

        int depth = 0;
        int end = start;
        for (int i = start; i < json.length(); i++) {
            if (json.charAt(i) == '[') depth++;
            else if (json.charAt(i) == ']') {
                depth--;
                if (depth == 0) { end = i; break; }
            }
        }
        return json.substring(start, end + 1);
    }

    private String findMatchingGuild(String guildsArray, String targetName) {
        // "Name":"xxx" 패턴으로 순회하며 이름 일치하는 길드의 Id 반환
        int cursor = 0;
        while (true) {
            int nameIdx = guildsArray.indexOf("\"Name\":\"", cursor);
            if (nameIdx == -1) break;

            int nameStart = nameIdx + 8;
            int nameEnd = guildsArray.indexOf("\"", nameStart);
            if (nameEnd == -1) break;

            String name = guildsArray.substring(nameStart, nameEnd);

            if (name.equals(targetName)) {
                // 같은 객체 내에서 Id 찾기 (앞쪽으로)
                int objStart = guildsArray.lastIndexOf("{", nameIdx);
                int idIdx = guildsArray.indexOf("\"Id\":\"", objStart);
                if (idIdx != -1 && idIdx < nameIdx + 200) {
                    int idStart = idIdx + 6;
                    int idEnd = guildsArray.indexOf("\"", idStart);
                    return guildsArray.substring(idStart, idEnd);
                }
            }
            cursor = nameEnd + 1;
        }
        return null;
    }

    private String extractStringValue(String json, String key) {
        String search = "\"" + key + "\":\"";
        int idx = json.indexOf(search);
        if (idx == -1) return null;
        int start = idx + search.length();
        int end = json.indexOf("\"", start);
        if (end == -1) return null;
        return json.substring(start, end);
    }

    private String extractNumberValue(String json, String key) {
        String search = "\"" + key + "\":";
        int idx = json.indexOf(search);
        if (idx == -1) return null;
        int start = idx + search.length();
        int end = start;
        while (end < json.length() && (Character.isDigit(json.charAt(end)) || json.charAt(end) == '.')) {
            end++;
        }
        if (end == start) return null;
        return json.substring(start, end);
    }

    private Map<String, String> findPlayerGuild(String playersArray, String targetName) {
        int cursor = 0;
        while (true) {
            int nameIdx = playersArray.indexOf("\"Name\":\"", cursor);
            if (nameIdx == -1) break;

            int nameStart = nameIdx + 8;
            int nameEnd = playersArray.indexOf("\"", nameStart);
            if (nameEnd == -1) break;

            String name = playersArray.substring(nameStart, nameEnd);

            if (name.equals(targetName)) {
                int objStart = playersArray.lastIndexOf("{", nameIdx);
                int objEnd = playersArray.indexOf("}", nameIdx);
                if (objStart == -1 || objEnd == -1) break;
                String obj = playersArray.substring(objStart, objEnd + 1);

                String guildId = extractStringValue(obj, "GuildId");
                String guildName = extractStringValue(obj, "GuildName");
                String allianceTag = extractStringValue(obj, "AllianceName");

                if (guildId == null || guildId.isEmpty()) return null;

                return Map.of(
                        "guildId", guildId,
                        "guildName", guildName != null ? guildName : "",
                        "allianceTag", allianceTag != null ? allianceTag : ""
                );
            }
            cursor = nameEnd + 1;
        }
        return null;
    }
}
