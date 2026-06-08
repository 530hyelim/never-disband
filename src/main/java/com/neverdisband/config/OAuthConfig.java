package com.neverdisband.config;

public class OAuthConfig {

    public static final String AUTHORIZATION_ENDPOINT = "https://discord.com/api/oauth2/authorize";
    public static final String TOKEN_ENDPOINT = "https://discord.com/api/oauth2/token";
    public static final String USER_INFO_ENDPOINT = "https://discord.com/api/users/@me";

    public static String getClientId() {
        return System.getenv("DISCORD_CLIENT_ID");
    }

    public static String getClientSecret() {
        return System.getenv("DISCORD_CLIENT_SECRET");
    }

    public static String getRedirectUri() {
        return System.getenv("DISCORD_REDIRECT_URI");
    }

    public static String getDbUrl() {
        String host = System.getenv("DB_HOST");
        String port = System.getenv("DB_PORT");
        String name = System.getenv("DB_NAME");
        return "jdbc:mysql://" + host + ":" + port + "/" + name + "?useSSL=false&allowPublicKeyAuthentication=true";
    }

    public static String getDbUser() {
        return System.getenv("DB_USER");
    }

    public static String getDbPassword() {
        return System.getenv("DB_PASSWORD");
    }
}
