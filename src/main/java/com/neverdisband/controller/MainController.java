package com.neverdisband.controller;

import com.neverdisband.dao.GuildDao;
import com.neverdisband.model.Guild;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.Optional;

@Controller
public class MainController {

    private final GuildDao guildDao;

    public MainController(GuildDao guildDao) {
        this.guildDao = guildDao;
    }

    @GetMapping("/{subdomain}/main")
    public String main(@PathVariable String subdomain, Model model) {
        Optional<Guild> guildOpt = guildDao.findBySubdomain(subdomain);
        if (guildOpt.isEmpty()) {
            return "redirect:/?error=존재하지 않는 길드입니다.";
        }
        model.addAttribute("guild", guildOpt.get());
        return "main";
    }
}
