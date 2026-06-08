package com.neverdisband.controller;

import com.neverdisband.service.DiscordOAuthService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.security.SecureRandom;
import java.util.Base64;

@Controller
public class LoginController {

    private final DiscordOAuthService oAuthService;

    public LoginController(DiscordOAuthService oAuthService) {
        this.oAuthService = oAuthService;
    }

    @GetMapping("/login")
    public String login(
            @RequestParam(required = false) String error,
            HttpSession session,
            Model model) {

        // state 생성 (CSRF 방지)
        String state = generateState();
        session.setAttribute("oauth_state", state);

        model.addAttribute("authUrl", oAuthService.buildAuthorizationUrl(state));
        if (error != null) {
            model.addAttribute("errorMessage", error);
        }

        return "login";
    }

    private String generateState() {
        byte[] bytes = new byte[24];
        new SecureRandom().nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}
