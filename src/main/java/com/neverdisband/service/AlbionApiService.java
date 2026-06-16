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
    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(java.time.Duration.ofSeconds(5))
            .build();

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

    /**
     * 주간/월간 명성 랭킹 조회
     * @param type PvE | Gathering
     * @param subtype All | Fiber | Hide | Ore | Rock | Wood
     * @param range week | month
     * @param guildId 알비온 길드 ID
     * @param limit 조회 수 (1~9999)
     * @return JSON 문자열 (배열)
     */
    public String fetchPlayerStatistics(String type, String subtype, String range, String guildId, int limit) {
        StringBuilder url = new StringBuilder(BASE_URL + "/players/statistics?type=" + type
                + "&range=" + range
                + "&guildId=" + guildId
                + "&limit=" + limit
                + "&offset=0");
        // subtype=All은 서버에서 에러를 유발하므로 생략 (기본값이 전체)
        if (subtype != null && !subtype.isEmpty() && !subtype.equalsIgnoreCase("All")) {
            url.append("&subtype=").append(subtype);
        }

        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url.toString()))
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 200) {
                logger.warn("Albion statistics fetch failed: status={}, url={}", response.statusCode(), url);
                return "[]";
            }
            return response.body();
        } catch (IOException | InterruptedException e) {
            logger.error("Failed to fetch player statistics: type={}, guildId={}", type, guildId, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return "[]";
        }
    }

    /**
     * 주간/월간 PvP 킬 명성 랭킹 조회
     * @param range week | month | lastWeek | lastMonth
     * @param guildId 알비온 길드 ID (nullable)
     * @param limit 조회 수 (1~51)
     * @return JSON 문자열 (배열)
     */
    public String fetchKillFameRanking(String range, String guildId, int limit) {
        String url = BASE_URL + "/events/killfame?range=" + range
                + "&limit=" + limit
                + "&offset=0"
                + (guildId != null ? "&guildId=" + guildId : "");

        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 200) {
                logger.warn("Albion killfame fetch failed: status={}, url={}", response.statusCode(), url);
                return "[]";
            }
            return response.body();
        } catch (IOException | InterruptedException e) {
            logger.error("Failed to fetch kill fame ranking: guildId={}", guildId, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return "[]";
        }
    }

    /**
     * 최근 PvP 킬 이벤트 조회
     * @param guildId 알비온 길드 ID
     * @param limit 조회 수 (1~51)
     * @return JSON 문자열 (배열)
     */
    public String fetchRecentKillEvents(String guildId, int limit) {
        return fetchRecentKillEvents(guildId, limit, 0);
    }

    public String fetchRecentKillEvents(String guildId, int limit, int offset) {
        String url = BASE_URL + "/events?guildId=" + guildId + "&limit=" + limit + "&offset=" + offset;

        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 200) {
                logger.warn("Albion events fetch failed: status={}, url={}", response.statusCode(), url);
                return "[]";
            }
            return response.body();
        } catch (IOException | InterruptedException e) {
            logger.error("Failed to fetch kill events: guildId={}", guildId, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return "[]";
        }
    }

    /**
     * 길드 데이터 조회 (전체 PvP 요약 + Top Players)
     * @param guildId 알비온 길드 ID
     * @return JSON 문자열 (object)
     */
    public String fetchGuildData(String guildId) {
        String url = BASE_URL + "/guilds/" + guildId + "/data";

        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 200) {
                logger.warn("Albion guild data fetch failed: status={}, url={}", response.statusCode(), url);
                return "{}";
            }
            return response.body();
        } catch (IOException | InterruptedException e) {
            logger.error("Failed to fetch guild data: guildId={}", guildId, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return "{}";
        }
    }

    /**
     * 길드 멤버 목록 조회 (LifetimeStatistics 포함)
     * @param guildId 알비온 길드 ID
     * @return JSON 문자열 (배열)
     */
    public String fetchGuildMembers(String guildId) {
        String url = BASE_URL + "/guilds/" + guildId + "/members";

        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(java.time.Duration.ofSeconds(30))
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 200) {
                logger.warn("Albion guild members fetch failed: status={}, url={}", response.statusCode(), url);
                return "[]";
            }
            return response.body();
        } catch (IOException | InterruptedException e) {
            logger.error("Failed to fetch guild members: guildId={}", guildId, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return "[]";
        }
    }

    /**
     * 특정 킬 이벤트 상세 조회
     * @param eventId 이벤트 ID
     * @return JSON 문자열 (object)
     */
    public String fetchEventDetail(String eventId) {
        String url = BASE_URL + "/events/" + eventId;

        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 200) {
                logger.warn("Albion event detail fetch failed: status={}, eventId={}", response.statusCode(), eventId);
                return "{\"error\":\"이벤트를 찾을 수 없습니다.\"}";
            }
            return response.body();
        } catch (IOException | InterruptedException e) {
            logger.error("Failed to fetch event detail: eventId={}", eventId, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return "{\"error\":\"서버 오류\"}";
        }
    }

    /**
     * 길드 전투 목록 조회
     * @param guildId 알비온 길드 ID
     * @param range day | week | month
     * @param limit 조회 수 (1~9999, offset+limit <= 10000)
     * @return JSON 문자열 (배열)
     */
    public String fetchBattles(String guildId, String range, int limit) {
        return fetchBattles(guildId, range, limit, 0);
    }

    public String fetchBattles(String guildId, String range, int limit, int offset) {
        String url = BASE_URL + "/battles?guildId=" + guildId
                + "&range=" + range
                + "&limit=" + limit
                + "&offset=" + offset
                + "&sort=recent";

        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(java.time.Duration.ofSeconds(30))
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 200) {
                logger.warn("Albion battles fetch failed: status={}, url={}", response.statusCode(), url);
                return "[]";
            }
            return response.body();
        } catch (IOException | InterruptedException e) {
            logger.error("Failed to fetch battles: guildId={}", guildId, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return "[]";
        }
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
