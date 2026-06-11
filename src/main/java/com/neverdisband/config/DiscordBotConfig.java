package com.neverdisband.config;

import com.neverdisband.service.DiscordGatewayListener;
import net.dv8tion.jda.api.JDA;
import net.dv8tion.jda.api.JDABuilder;
import net.dv8tion.jda.api.requests.GatewayIntent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Lazy;
import org.springframework.lang.Nullable;


@Configuration
public class DiscordBotConfig {

    private static final Logger logger = LoggerFactory.getLogger(DiscordBotConfig.class);

    private final OAuthConfig oAuthConfig;
    private final DiscordGatewayListener gatewayListener;

    @Value("${app.env}")
    private String appEnv;

    public DiscordBotConfig(OAuthConfig oAuthConfig, @Lazy DiscordGatewayListener gatewayListener) {
        this.oAuthConfig = oAuthConfig;
        this.gatewayListener = gatewayListener;
    }

    @Bean
    @Nullable
    public JDA jda() {
        if ("DEV".equals(appEnv)) {
            logger.info("Discord Gateway bot is disabled. (APP_ENV=DEV)");
            return null;
        }

        try {
            JDA jda = JDABuilder.createDefault(oAuthConfig.getBotToken())
                    .enableIntents(
                            GatewayIntent.GUILD_MESSAGES,
                            GatewayIntent.GUILD_MESSAGE_REACTIONS,
                            GatewayIntent.MESSAGE_CONTENT
                    )
                    .addEventListeners(gatewayListener)
                    .build();

            jda.awaitReady();
            logger.info("Discord Gateway bot connected: {}", jda.getSelfUser().getName());
            return jda;
        } catch (Exception e) {
            logger.error("Failed to connect Discord Gateway bot. App will start without bot features.", e);
            return null;
        }
    }
}
