package com.neverdisband.controller;

import com.neverdisband.dao.UserDao;
import com.neverdisband.exception.OAuthException;
import com.neverdisband.model.User;
import com.neverdisband.service.DiscordOAuthService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@Controller
public class CallbackController {

    private static final Logger logger = LoggerFactory.getLogger(CallbackController.class);

    private final DiscordOAuthService oAuthService;
    private final UserDao userDao;

    public CallbackController(DiscordOAuthService oAuthService, UserDao userDao) {
        this.oAuthService = oAuthService;
        this.userDao = userDao;
    }

    @GetMapping("/auth/discord/callback")
    public String callback(
            @RequestParam(required = false) String code,
            @RequestParam(required = false) String state,
            HttpSession session,
            HttpServletRequest request) {

        // 1. state 검증
        String savedState = (String) session.getAttribute("oauth_state");
        if (savedState == null || !savedState.equals(state)) {
            logger.warn("State mismatch: expected={}, got={}", savedState, state);
            return "redirect:/login?error=보안 검증에 실패했습니다. 다시 시도해주세요.";
        }
        session.removeAttribute("oauth_state");

        // 2. Authorization Code 확인
        if (code == null) {
            return "redirect:/login?error=인증이 취소되었습니다.";
        }

        try {
            // 3. Access Token 교환
            String accessToken = oAuthService.exchangeCodeForToken(code);

            // 4. 사용자 정보 조회
            User user = oAuthService.fetchUserInfo(accessToken);

            // 5. DB 저장 (UPSERT)
            userDao.upsert(user);

            // 6. JSP에서 쓸 세션 값 저장
            session.setAttribute("user_discord_id", user.getDiscordId());
            session.setAttribute("user_name", user.getUsername());
            session.setAttribute("user_avatar_url", user.getAvatarUrl());

            // 7. Spring Security 인증 등록 (이게 없으면 계속 미인증 상태로 루프 발생)
            UsernamePasswordAuthenticationToken authentication =
                new UsernamePasswordAuthenticationToken(
                    user.getDiscordId(),
                    null,
                    List.of(new SimpleGrantedAuthority("ROLE_USER"))
                );
            SecurityContext securityContext = SecurityContextHolder.createEmptyContext();
            securityContext.setAuthentication(authentication);
            SecurityContextHolder.setContext(securityContext);
            // 세션에도 저장해야 다음 요청에서도 인증 유지됨
            session.setAttribute(
                HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY,
                securityContext
            );

            logger.info("Login success: {} ({})", user.getUsername(), user.getDiscordId());

            return "redirect:/";

        } catch (OAuthException e) {
            logger.warn("OAuth failed: {}", e.getType(), e);
            String message = switch (e.getType()) {
                case CONNECTION_FAILED -> "Discord 서비스에 연결할 수 없습니다. 다시 시도해주세요.";
                case TOKEN_EXCHANGE_FAILED -> "인증에 실패했습니다. 다시 로그인해주세요.";
                case USER_INFO_FAILED -> "인증 정보가 만료되었습니다. 다시 로그인해주세요.";
                case STATE_MISMATCH -> "보안 검증에 실패했습니다.";
            };
            return "redirect:/login?error=" + URLEncoder.encode(message, StandardCharsets.UTF_8);
        }
    }
}
