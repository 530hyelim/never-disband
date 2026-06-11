package com.neverdisband.service;

import com.neverdisband.dao.GuildDao;
import com.neverdisband.model.Guild;
import net.dv8tion.jda.api.events.message.MessageReceivedEvent;
import net.dv8tion.jda.api.events.message.react.MessageReactionAddEvent;
import net.dv8tion.jda.api.hooks.ListenerAdapter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Optional;

/**
 * Discord Gateway 이벤트 리스너
 * - MESSAGE_CREATE: 디스코드 채널에 올라온 글 → 웹으로 push
 * - MESSAGE_REACTION_ADD: 이모지 추가 → 웹으로 push
 */
@Component
public class DiscordGatewayListener extends ListenerAdapter {

    private static final Logger logger = LoggerFactory.getLogger(DiscordGatewayListener.class);

    private final GuildDao guildDao;
    private final SimpMessagingTemplate messagingTemplate;

    public DiscordGatewayListener(GuildDao guildDao, SimpMessagingTemplate messagingTemplate) {
        this.guildDao = guildDao;
        this.messagingTemplate = messagingTemplate;
    }

    @Override
    public void onMessageReceived(MessageReceivedEvent event) {
        // 봇 자신의 메시지는 무시
        if (event.getAuthor().isBot()) return;

        String discordGuildId = event.getGuild().getId();
        String channelName = event.getChannel().getName();

        // 등록된 길드인지 확인
        Optional<Guild> guildOpt = guildDao.findByDiscordGuildId(discordGuildId);
        if (guildOpt.isEmpty()) return;

        Guild guild = guildOpt.get();

        // TODO: 특정 채널에서 올라온 메시지만 처리
        // 지금은 모든 메시지를 로그로 기록하고, 연동 채널은 추후 설정
        logger.debug("Message in guild [{}] channel [{}]: {}",
                guild.getName(), channelName, event.getMessage().getContentDisplay());

        // WebSocket으로 해당 길드 구독자에게 push
        messagingTemplate.convertAndSend(
                "/topic/guild/" + guild.getSubdomain() + "/messages",
                Map.of(
                        "channelName", channelName,
                        "author", event.getAuthor().getName(),
                        "content", event.getMessage().getContentDisplay(),
                        "messageId", event.getMessageId(),
                        "timestamp", event.getMessage().getTimeCreated().toString()
                )
        );
    }

    @Override
    public void onMessageReactionAdd(MessageReactionAddEvent event) {
        if (event.getUser() != null && event.getUser().isBot()) return;

        String discordGuildId = event.getGuild().getId();

        Optional<Guild> guildOpt = guildDao.findByDiscordGuildId(discordGuildId);
        if (guildOpt.isEmpty()) return;

        Guild guild = guildOpt.get();

        // WebSocket으로 리액션 이벤트 push
        messagingTemplate.convertAndSend(
                "/topic/guild/" + guild.getSubdomain() + "/reactions",
                Map.of(
                        "messageId", event.getMessageId(),
                        "emoji", event.getReaction().getEmoji().getName(),
                        "userId", event.getUserId()
                )
        );
    }
}
