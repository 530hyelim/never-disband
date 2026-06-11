package com.neverdisband.controller;

import com.neverdisband.dao.GuildDao;
import com.neverdisband.dao.GuildMemberDao;
import com.neverdisband.model.Guild;
import com.neverdisband.service.AlbionApiService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.Collections;
import java.util.List;
import java.util.Map;

@Controller
public class HomeController {

    private final GuildDao guildDao;
    private final GuildMemberDao guildMemberDao;
    private final AlbionApiService albionApiService;

    public HomeController(GuildDao guildDao, GuildMemberDao guildMemberDao, AlbionApiService albionApiService) {
        this.guildDao = guildDao;
        this.guildMemberDao = guildMemberDao;
        this.albionApiService = albionApiService;
    }

    @GetMapping("/")
    public String home(HttpSession session, Model model) {
        String userDiscordId = (String) session.getAttribute("user_discord_id");
        if (userDiscordId != null) {
            List<Guild> guilds = guildDao.findByMemberDiscordId(userDiscordId);

            for (Guild guild : guilds) {
                // 등록 멤버 수
                guild.setRegisteredMemberCount(guildMemberDao.countByGuildId(guild.getId()));

                // 내 캐릭터명
                String charName = guildMemberDao.findCharacterNameByGuildIdAndDiscordId(guild.getId(), userDiscordId);
                guild.setMyCharacterName(charName);

                // 알비온 API로 상세 정보 채우기
                if (guild.getAlbionGuildId() != null && !guild.getAlbionGuildId().isEmpty()) {
                    Map<String, String> detail = albionApiService.fetchGuildDetail(guild.getAlbionGuildId());
                    if (detail != null) {
                        guild.setAllianceTag(detail.get("AllianceTag"));
                        guild.setFounded(detail.get("Founded"));
                        try {
                            guild.setMemberCount(Integer.parseInt(detail.get("MemberCount")));
                        } catch (NumberFormatException e) {
                            guild.setMemberCount(0);
                        }
                    }
                }
            }

            model.addAttribute("guilds", guilds);
        } else {
            model.addAttribute("guilds", Collections.emptyList());
        }
        return "index";
    }
}
