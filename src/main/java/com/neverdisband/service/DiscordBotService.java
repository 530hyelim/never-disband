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

    public String getClientId() {
        return oAuthConfig.getClientId();
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

    /**
     * 채널의 parent_id(카테고리 ID) 조회
     * @return 카테고리 ID (없으면 null)
     */
    public String getChannelParentId(String channelId) {
        String url = "https://discord.com/api/v10/channels/" + channelId;
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Bot " + oAuthConfig.getBotToken())
                .GET()
                .build();

        try {
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() == 200) {
                return extractJsonValue(response.body(), "parent_id");
            }
            return null;
        } catch (IOException | InterruptedException e) {
            logger.error("Failed to get channel parent: channelId={}", channelId, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return null;
        }
    }

    /**
     * 비공개 음성채널 생성
     * @param guildId Discord guild ID
     * @param name 채널 이름
     * @param allowedUserIds 접근 허용할 유저 discord ID 목록
     * @return 생성된 채널 ID (실패 시 null)
     */
    public String createVoiceChannel(String guildId, String name, java.util.List<String> allowedUserIds, String parentId) {
        // permission overwrites: @everyone 차단 + 허용 유저 개별 허용
        StringBuilder overwrites = new StringBuilder();
        overwrites.append("[{\"id\":\"").append(guildId).append("\",\"type\":0,\"deny\":\"1048576\"}"); // @everyone: CONNECT 차단
        for (String userId : allowedUserIds) {
            overwrites.append(",{\"id\":\"").append(userId).append("\",\"type\":1,\"allow\":\"1048576\"}"); // CONNECT 허용
        }
        overwrites.append("]");

        String parentField = parentId != null ? ",\"parent_id\":\"" + parentId + "\"" : "";
        String jsonBody = "{\"name\":" + escapeJson(name) + ",\"type\":2,\"position\":999" + parentField + ",\"permission_overwrites\":" + overwrites + "}";
        String url = "https://discord.com/api/v10/guilds/" + guildId + "/channels";

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Bot " + oAuthConfig.getBotToken())
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                .build();

        try {
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() == 201 || response.statusCode() == 200) {
                return extractJsonValue(response.body(), "id");
            }
            logger.warn("Discord createVoiceChannel failed: status={}, body={}", response.statusCode(), response.body());
            return null;
        } catch (IOException | InterruptedException e) {
            logger.error("Failed to create voice channel in guild={}", guildId, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return null;
        }
    }

    /**
     * 유저를 음성채널로 이동 (이미 다른 음성채널에 접속 중일 때만 동작)
     * @return true면 이동 성공, false면 유저가 음성채널에 없음
     */
    public boolean moveUserToVoice(String guildId, String userId, String channelId) {
        String url = "https://discord.com/api/v10/guilds/" + guildId + "/members/" + userId;
        String jsonBody = "{\"channel_id\":\"" + channelId + "\"}";

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Bot " + oAuthConfig.getBotToken())
                .header("Content-Type", "application/json")
                .method("PATCH", HttpRequest.BodyPublishers.ofString(jsonBody))
                .build();

        try {
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            return response.statusCode() == 200 || response.statusCode() == 204;
        } catch (IOException | InterruptedException e) {
            logger.error("Failed to move user={} to channel={}", userId, channelId, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return false;
        }
    }

    /**
     * 채널 초대 링크 생성
     * @return 초대 URL (실패 시 null)
     */
    public String createChannelInvite(String channelId) {
        String url = "https://discord.com/api/v10/channels/" + channelId + "/invites";
        String jsonBody = "{\"max_age\":3600,\"max_uses\":0,\"temporary\":false}";

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Bot " + oAuthConfig.getBotToken())
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                .build();

        try {
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() == 200 || response.statusCode() == 201) {
                String code = extractJsonValue(response.body(), "code");
                return code != null ? "https://discord.gg/" + code : null;
            }
            logger.warn("Discord createInvite failed: status={}, body={}", response.statusCode(), response.body());
            return null;
        } catch (IOException | InterruptedException e) {
            logger.error("Failed to create invite for channel={}", channelId, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return null;
        }
    }

    /**
     * 유저가 특정 채널에서 @everyone/@here 멘션 권한(MENTION_EVERYONE)을 갖고 있는지 확인
     * Discord 권한 계산 순서:
     * 1. @everyone 역할 base permissions
     * 2. 멤버 보유 역할 permissions OR
     * 3. 채널 permission_overwrites: @everyone 역할 deny/allow
     * 4. 채널 permission_overwrites: 멤버 보유 역할 deny/allow
     * 5. 채널 permission_overwrites: 유저 개인 deny/allow
     * Administrator 권한이 있으면 모든 권한 보유로 판정 (채널 overwrite 무시)
     */
    public boolean hasMentionEveryonePermission(String guildId, String userDiscordId, String channelId) {
        long MENTION_EVERYONE = 0x20000L;
        return hasChannelPermission(guildId, userDiscordId, channelId, MENTION_EVERYONE);
    }

    /**
     * 하위 호환을 위한 오버로드 (채널 미지정 시 서버 레벨만 확인)
     */
    public boolean hasMentionEveryonePermission(String guildId, String userDiscordId) {
        return hasMentionEveryonePermission(guildId, userDiscordId, null);
    }

    /**
     * 유저가 특정 채널에서 메시지 전송 권한(SEND_MESSAGES)을 갖고 있는지 확인.
     * 채널별 permission_overwrites 반영.
     */
    public boolean hasSendMessagesPermission(String guildId, String userDiscordId, String channelId) {
        long SEND_MESSAGES = 0x800L;
        return hasChannelPermission(guildId, userDiscordId, channelId, SEND_MESSAGES);
    }

    /**
     * 유저가 특정 채널을 볼 수 있는 권한(VIEW_CHANNEL)을 갖고 있는지 확인.
     * 채널별 permission_overwrites 반영.
     */
    public boolean hasViewChannelPermission(String guildId, String userDiscordId, String channelId) {
        long VIEW_CHANNEL = 0x400L;
        return hasChannelPermission(guildId, userDiscordId, channelId, VIEW_CHANNEL);
    }

    /**
     * 범용 채널 권한 확인 메서드.
     * Discord 권한 계산 알고리즘에 따라 서버+채널 레벨 종합 계산.
     */
    private boolean hasChannelPermission(String guildId, String userDiscordId, String channelId, long permissionBit) {
        try {
            // 서버 소유자는 모든 권한 보유
            Map<String, String> guildInfo = fetchGuildInfo(guildId);
            if (guildInfo != null && userDiscordId.equals(guildInfo.get("owner_id"))) {
                return true;
            }

            // 길드 역할 목록 조회
            String rolesUrl = "https://discord.com/api/v10/guilds/" + guildId + "/roles";
            HttpRequest rolesReq = HttpRequest.newBuilder()
                    .uri(URI.create(rolesUrl))
                    .header("Authorization", "Bot " + oAuthConfig.getBotToken())
                    .GET()
                    .build();

            // 멤버 정보 조회
            String memberUrl = "https://discord.com/api/v10/guilds/" + guildId + "/members/" + userDiscordId;
            HttpRequest memberReq = HttpRequest.newBuilder()
                    .uri(URI.create(memberUrl))
                    .header("Authorization", "Bot " + oAuthConfig.getBotToken())
                    .GET()
                    .build();

            HttpResponse<String> rolesResp = httpClient.send(rolesReq, HttpResponse.BodyHandlers.ofString());
            HttpResponse<String> memberResp = httpClient.send(memberReq, HttpResponse.BodyHandlers.ofString());

            if (rolesResp.statusCode() != 200 || memberResp.statusCode() != 200) {
                logger.warn("Discord permission check failed: rolesStatus={}, memberStatus={}",
                        rolesResp.statusCode(), memberResp.statusCode());
                return false;
            }

            java.util.Map<String, Long> rolePermissions = parseRolePermissions(rolesResp.body());
            java.util.List<String> memberRoleIds = parseMemberRoles(memberResp.body());

            long ADMINISTRATOR = 0x8L;

            // 서버 레벨 권한 계산
            long permissions = rolePermissions.getOrDefault(guildId, 0L);
            for (String roleId : memberRoleIds) {
                permissions |= rolePermissions.getOrDefault(roleId, 0L);
            }

            if ((permissions & ADMINISTRATOR) != 0) return true;

            // 채널 레벨 permission overwrites 적용
            if (channelId != null) {
                String channelUrl = "https://discord.com/api/v10/channels/" + channelId;
                HttpRequest channelReq = HttpRequest.newBuilder()
                        .uri(URI.create(channelUrl))
                        .header("Authorization", "Bot " + oAuthConfig.getBotToken())
                        .GET()
                        .build();
                HttpResponse<String> channelResp = httpClient.send(channelReq, HttpResponse.BodyHandlers.ofString());
                if (channelResp.statusCode() == 200) {
                    java.util.List<PermissionOverwrite> overwrites = parsePermissionOverwrites(channelResp.body());

                    for (PermissionOverwrite ow : overwrites) {
                        if (ow.id.equals(guildId) && ow.type == 0) {
                            permissions &= ~ow.deny;
                            permissions |= ow.allow;
                        }
                    }
                    long roleDeny = 0L, roleAllow = 0L;
                    for (PermissionOverwrite ow : overwrites) {
                        if (ow.type == 0 && !ow.id.equals(guildId) && memberRoleIds.contains(ow.id)) {
                            roleDeny |= ow.deny;
                            roleAllow |= ow.allow;
                        }
                    }
                    permissions &= ~roleDeny;
                    permissions |= roleAllow;

                    for (PermissionOverwrite ow : overwrites) {
                        if (ow.type == 1 && ow.id.equals(userDiscordId)) {
                            permissions &= ~ow.deny;
                            permissions |= ow.allow;
                        }
                    }
                }
            }

            return (permissions & permissionBit) != 0;

        } catch (IOException | InterruptedException e) {
            logger.error("Failed to check permission: guildId={}, userId={}, channelId={}", guildId, userDiscordId, channelId, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return false;
        }
    }

    private static class PermissionOverwrite {
        String id;
        int type; // 0 = role, 1 = member
        long allow;
        long deny;
    }

    /**
     * 채널 JSON에서 permission_overwrites 배열 파싱
     */
    private java.util.List<PermissionOverwrite> parsePermissionOverwrites(String channelJson) {
        java.util.List<PermissionOverwrite> result = new java.util.ArrayList<>();
        int owStart = channelJson.indexOf("\"permission_overwrites\"");
        if (owStart == -1) return result;
        int arrStart = channelJson.indexOf("[", owStart);
        if (arrStart == -1) return result;

        // 중첩 배열 끝 찾기
        int depth = 0;
        int arrEnd = -1;
        for (int i = arrStart; i < channelJson.length(); i++) {
            char c = channelJson.charAt(i);
            if (c == '[') depth++;
            else if (c == ']') {
                depth--;
                if (depth == 0) { arrEnd = i; break; }
            }
        }
        if (arrEnd == -1) return result;

        String arrStr = channelJson.substring(arrStart + 1, arrEnd);
        // 각 오브젝트 파싱
        int idx = 0;
        while (true) {
            int objStart2 = arrStr.indexOf("{", idx);
            if (objStart2 == -1) break;
            int objEnd2 = arrStr.indexOf("}", objStart2);
            if (objEnd2 == -1) break;
            String obj = arrStr.substring(objStart2, objEnd2 + 1);

            PermissionOverwrite ow = new PermissionOverwrite();
            ow.id = extractJsonValue(obj, "id");
            String typeStr = extractJsonValue(obj, "type");
            ow.type = typeStr != null ? Integer.parseInt(typeStr) : 0;
            String allowStr = extractJsonValue(obj, "allow");
            String denyStr = extractJsonValue(obj, "deny");
            ow.allow = allowStr != null ? Long.parseLong(allowStr) : 0L;
            ow.deny = denyStr != null ? Long.parseLong(denyStr) : 0L;

            result.add(ow);
            idx = objEnd2 + 1;
        }
        return result;
    }

    /**
     * Discord roles JSON 배열에서 roleId -> permissions(long) 맵 파싱
     */
    private java.util.Map<String, Long> parseRolePermissions(String rolesJson) {
        java.util.Map<String, Long> map = new java.util.HashMap<>();
        // 간단한 파싱: 각 역할 오브젝트에서 "id"와 "permissions" 추출
        int idx = 0;
        while (true) {
            int objStart = rolesJson.indexOf("{", idx);
            if (objStart == -1) break;
            int objEnd = rolesJson.indexOf("}", objStart);
            if (objEnd == -1) break;
            String obj = rolesJson.substring(objStart, objEnd + 1);
            String id = extractJsonValue(obj, "id");
            String permsStr = extractJsonValue(obj, "permissions");
            if (id != null && permsStr != null) {
                try {
                    map.put(id, Long.parseLong(permsStr));
                } catch (NumberFormatException ignored) {}
            }
            idx = objEnd + 1;
        }
        return map;
    }

    /**
     * Discord member JSON에서 roles 배열 파싱
     */
    private java.util.List<String> parseMemberRoles(String memberJson) {
        java.util.List<String> roles = new java.util.ArrayList<>();
        int rolesStart = memberJson.indexOf("\"roles\"");
        if (rolesStart == -1) return roles;
        int arrStart = memberJson.indexOf("[", rolesStart);
        int arrEnd = memberJson.indexOf("]", arrStart);
        if (arrStart == -1 || arrEnd == -1) return roles;
        String arrStr = memberJson.substring(arrStart + 1, arrEnd);
        // 배열 내 문자열들: "id1","id2",...
        int i = 0;
        while (true) {
            int qStart = arrStr.indexOf("\"", i);
            if (qStart == -1) break;
            int qEnd = arrStr.indexOf("\"", qStart + 1);
            if (qEnd == -1) break;
            roles.add(arrStr.substring(qStart + 1, qEnd));
            i = qEnd + 1;
        }
        return roles;
    }

    /**
     * 채널에 유저 접근 권한 추가
     */
    public boolean addChannelPermission(String channelId, String userId) {
        String url = "https://discord.com/api/v10/channels/" + channelId + "/permissions/" + userId;
        String jsonBody = "{\"allow\":\"1048576\",\"type\":1}"; // CONNECT 허용, type 1 = member

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Bot " + oAuthConfig.getBotToken())
                .header("Content-Type", "application/json")
                .PUT(HttpRequest.BodyPublishers.ofString(jsonBody))
                .build();

        try {
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            return response.statusCode() == 204 || response.statusCode() == 200;
        } catch (IOException | InterruptedException e) {
            logger.error("Failed to add permission for user={} on channel={}", userId, channelId, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return false;
        }
    }

    /**
     * 채널에서 유저 접근 권한 삭제
     */
    public boolean removeChannelPermission(String channelId, String userId) {
        String url = "https://discord.com/api/v10/channels/" + channelId + "/permissions/" + userId;

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Bot " + oAuthConfig.getBotToken())
                .DELETE()
                .build();

        try {
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            return response.statusCode() == 204 || response.statusCode() == 200;
        } catch (IOException | InterruptedException e) {
            logger.error("Failed to remove permission for user={} on channel={}", userId, channelId, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return false;
        }
    }

    /**
     * 채널 삭제
     */
    public boolean deleteChannel(String channelId) {
        String url = "https://discord.com/api/v10/channels/" + channelId;
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Bot " + oAuthConfig.getBotToken())
                .DELETE()
                .build();

        try {
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            return response.statusCode() == 200;
        } catch (IOException | InterruptedException e) {
            logger.error("Failed to delete channel={}", channelId, e);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return false;
        }
    }
}
