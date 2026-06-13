package com.neverdisband.service;

import com.neverdisband.dao.GuildDao;
import com.neverdisband.dao.GuildMemberDao;
import com.neverdisband.dao.GuildPageDao;
import com.neverdisband.dao.RecruitParticipantDao;
import com.neverdisband.dao.RecruitPostDao;
import com.neverdisband.model.Guild;
import com.neverdisband.model.GuildPage;
import com.neverdisband.model.PageType;
import com.neverdisband.model.RecruitPost;
import net.dv8tion.jda.api.events.message.MessageReceivedEvent;
import net.dv8tion.jda.api.events.message.react.MessageReactionAddEvent;
import net.dv8tion.jda.api.hooks.ListenerAdapter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Optional;

@Component
public class DiscordGatewayListener extends ListenerAdapter {

    private static final Logger logger = LoggerFactory.getLogger(DiscordGatewayListener.class);

    private final GuildDao guildDao;
    private final GuildPageDao guildPageDao;
    private final GuildMemberDao guildMemberDao;
    private final RecruitPostDao recruitPostDao;
    private final RecruitParticipantDao participantDao;
    private final SimpMessagingTemplate messagingTemplate;

    public DiscordGatewayListener(GuildDao guildDao, GuildPageDao guildPageDao,
                                  GuildMemberDao guildMemberDao, RecruitPostDao recruitPostDao,
                                  RecruitParticipantDao participantDao,
                                  SimpMessagingTemplate messagingTemplate) {
        this.guildDao = guildDao;
        this.guildPageDao = guildPageDao;
        this.guildMemberDao = guildMemberDao;
        this.recruitPostDao = recruitPostDao;
        this.participantDao = participantDao;
        this.messagingTemplate = messagingTemplate;
    }

    @Override
    public void onMessageReceived(MessageReceivedEvent event) {
        if (event.getAuthor().isBot()) return;

        String channelId = event.getChannel().getId();

        // 이 채널이 어떤 페이지에 연동되어 있는지 확인
        Optional<GuildPage> pageOpt = guildPageDao.findByDiscordChannelId(channelId);
        if (pageOpt.isEmpty()) return;

        GuildPage page = pageOpt.get();

        // 등록된 길드 조회
        Optional<Guild> guildOpt = guildDao.findById(page.getGuildId());
        if (guildOpt.isEmpty()) return;

        Guild guild = guildOpt.get();

        if (page.getPageType() == PageType.RECRUIT) {
            handleRecruitMessage(event, guild);
        }

        // WebSocket push
        messagingTemplate.convertAndSend(
                "/topic/guild/" + guild.getSubdomain() + "/" + page.getPageType().name().toLowerCase(),
                Map.of(
                        "channelName", event.getChannel().getName(),
                        "author", event.getAuthor().getName(),
                        "content", event.getMessage().getContentDisplay(),
                        "messageId", event.getMessageId(),
                        "timestamp", event.getMessage().getTimeCreated().toString()
                )
        );
    }

    /**
     * RECRUIT 채널 메시지 → recruit_posts 저장
     * - 발신자가 길드 멤버가 아니면 스킵 (파티장 특정 불가)
     * - 중복 메시지 ID는 스킵
     */
    private void handleRecruitMessage(MessageReceivedEvent event, Guild guild) {
        String discordMessageId = event.getMessageId();

        // 중복 방지
        if (recruitPostDao.existsByDiscordMessageId(discordMessageId)) return;

        // 발신자의 discord_id로 guild_member 조회
        String authorDiscordId = event.getAuthor().getId();

        Long leaderMemberId = guildMemberDao.findMemberIdByGuildIdAndDiscordId(guild.getId(), authorDiscordId);
        if (leaderMemberId == null) {
            logger.debug("[recruit] Message author {} is not a guild member in guild {}, skipping",
                    authorDiscordId, guild.getName());
            return;
        }

        RecruitPost post = new RecruitPost();
        post.setGuildId(guild.getId());
        post.setLeaderMemberId(leaderMemberId);
        post.setContent(event.getMessage().getContentDisplay());
        post.setDiscordMessageId(discordMessageId);
        post.setSource(RecruitPost.Source.DISCORD);
        post.setStatus(RecruitPost.Status.OPEN);
        post.setPublic(false);  // 기본값: 길드원만

        Long postId = recruitPostDao.insert(post);
        // 리더를 participants에 자동 insert (slot_id = null, 자유참여로 시작)
        participantDao.insert(postId, leaderMemberId);
        logger.info("[recruit] Post created from Discord message={} in guild={}", discordMessageId, guild.getName());
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
