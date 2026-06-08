package com.neverdisband.servlet;

import com.neverdisband.dao.UserDao;
import com.neverdisband.exception.OAuthException;
import com.neverdisband.model.User;
import com.neverdisband.service.DiscordOAuthService;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/auth/discord/callback")
public class CallbackServlet extends HttpServlet {

    private static final Logger logger = Logger.getLogger(CallbackServlet.class.getName());
    private final DiscordOAuthService oAuthService = new DiscordOAuthService();
    private final UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();

        // 1. state 검증
        String savedState = (String) session.getAttribute("oauth_state");
        String returnedState = req.getParameter("state");

        if (savedState == null || !savedState.equals(returnedState)) {
            logger.warning("State mismatch: expected=" + savedState + ", got=" + returnedState);
            resp.sendRedirect(req.getContextPath() + "/login?error=보안 검증에 실패했습니다. 다시 시도해주세요.");
            return;
        }

        // state 사용 후 삭제
        session.removeAttribute("oauth_state");

        // 2. Authorization Code 확인
        String code = req.getParameter("code");
        if (code == null) {
            resp.sendRedirect(req.getContextPath() + "/login?error=인증이 취소되었습니다.");
            return;
        }

        try {
            // 3. Access Token 교환
            String accessToken = oAuthService.exchangeCodeForToken(code);

            // 4. 사용자 정보 조회
            User user = oAuthService.fetchUserInfo(accessToken);

            // 5. DB 저장 (UPSERT)
            userDao.upsert(user);

            // 6. 세션에 사용자 정보 저장
            session.setAttribute("user_discord_id", user.getDiscordId());
            session.setAttribute("user_name", user.getUsername());
            session.setAttribute("user_avatar_url", user.getAvatarUrl());

            logger.info("Login success: " + user.getUsername() + " (" + user.getDiscordId() + ")");

            // 7. 메인 페이지로 리다이렉트
            resp.sendRedirect(req.getContextPath() + "/");

        } catch (OAuthException e) {
            logger.log(Level.WARNING, "OAuth failed: " + e.getType(), e);
            String message = switch (e.getType()) {
                case CONNECTION_FAILED -> "Discord 서비스에 연결할 수 없습니다. 다시 시도해주세요.";
                case TOKEN_EXCHANGE_FAILED -> "인증에 실패했습니다. 다시 로그인해주세요.";
                case USER_INFO_FAILED -> "인증 정보가 만료되었습니다. 다시 로그인해주세요.";
                case STATE_MISMATCH -> "보안 검증에 실패했습니다.";
            };
            resp.sendRedirect(req.getContextPath() + "/login?error=" + message);

        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Database error during login", e);
            resp.sendRedirect(req.getContextPath() + "/login?error=일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
        }
    }
}
