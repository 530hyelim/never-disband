package com.neverdisband.controller;

import com.neverdisband.service.DiscordOAuthService;
import com.neverdisband.service.OAuthStateService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class LoginController {

    private final DiscordOAuthService oAuthService;
    private final OAuthStateService stateService;

    public LoginController(DiscordOAuthService oAuthService, OAuthStateService stateService) {
        this.oAuthService = oAuthService;
        this.stateService = stateService;
    }

    @GetMapping("/login")
    public String login(
            @RequestParam(required = false) String error,
            Model model) {

        // HMAC 서명 기반 state 생성 - 세션에 저장하지 않으므로 덮어씌워지는 문제 없음
        String state = stateService.generate();
        model.addAttribute("authUrl", oAuthService.buildAuthorizationUrl(state));
        if (error != null) {
            model.addAttribute("errorMessage", error);
        }

        return "login";
    }
}
