package com.neverdisband.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OAuthConfig {

    public static final String AUTHORIZATION_ENDPOINT = "https://discord.com/api/oauth2/authorize";
    public static final String TOKEN_ENDPOINT = "https://discord.com/api/oauth2/token";
    public static final String USER_INFO_ENDPOINT = "https://discord.com/api/users/@me";
    public static final String GUILD_ENDPOINT = "https://discord.com/api/v10/guilds/";

    @Value("${discord.client-id}")
    private String clientId;

    @Value("${discord.client-secret}")
    private String clientSecret;

    @Value("${discord.redirect-uri}")
    private String redirectUri;

    @Value("${discord.bot-token}")
    private String botToken;

    @Value("${discord.bot-redirect-uri}")
    private String botRedirectUri;

    public String getClientId() {
        return clientId;
    }

    public String getClientSecret() {
        return clientSecret;
    }

    public String getRedirectUri() {
        return redirectUri;
    }

    public String getBotToken() {
        return botToken;
    }

    public String getBotRedirectUri() {
        return botRedirectUri;
    }
}
