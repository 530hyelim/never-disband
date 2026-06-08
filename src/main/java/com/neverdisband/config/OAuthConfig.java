package com.neverdisband.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OAuthConfig {

    public static final String AUTHORIZATION_ENDPOINT = "https://discord.com/api/oauth2/authorize";
    public static final String TOKEN_ENDPOINT = "https://discord.com/api/oauth2/token";
    public static final String USER_INFO_ENDPOINT = "https://discord.com/api/users/@me";

    @Value("${discord.client-id}")
    private String clientId;

    @Value("${discord.client-secret}")
    private String clientSecret;

    @Value("${discord.redirect-uri}")
    private String redirectUri;

    public String getClientId() {
        return clientId;
    }

    public String getClientSecret() {
        return clientSecret;
    }

    public String getRedirectUri() {
        return redirectUri;
    }
}
