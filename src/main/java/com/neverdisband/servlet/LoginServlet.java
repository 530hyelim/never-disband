package com.neverdisband.servlet;

import com.neverdisband.service.DiscordOAuthService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.security.SecureRandom;
import java.util.Base64;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final DiscordOAuthService oAuthService = new DiscordOAuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // state 생성 (CSRF 방지)
        String state = generateState();
        HttpSession session = req.getSession();
        session.setAttribute("oauth_state", state);

        // 인증 URL 생성
        String authUrl = oAuthService.buildAuthorizationUrl(state);
        req.setAttribute("authUrl", authUrl);

        // 에러 메시지 전달 (있으면)
        String error = req.getParameter("error");
        if (error != null) {
            req.setAttribute("errorMessage", error);
        }

        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }

    private String generateState() {
        byte[] bytes = new byte[24];
        new SecureRandom().nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}
