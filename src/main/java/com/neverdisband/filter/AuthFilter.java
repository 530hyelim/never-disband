package com.neverdisband.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter("/*")
public class AuthFilter implements Filter {

    private static final String[] EXCLUDED_PATHS = {
            "/login",
            "/auth/",
            "/static/"
    };

    private static final String[] EXCLUDED_EXTENSIONS = {
            ".css", ".js", ".png", ".jpg", ".ico"
    };

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path = req.getRequestURI().substring(req.getContextPath().length());

        // 제외 경로 체크
        if (isExcluded(path)) {
            chain.doFilter(request, response);
            return;
        }

        // 세션 체크
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_discord_id") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        chain.doFilter(request, response);
    }

    private boolean isExcluded(String path) {
        for (String excluded : EXCLUDED_PATHS) {
            if (path.startsWith(excluded)) return true;
        }
        for (String ext : EXCLUDED_EXTENSIONS) {
            if (path.endsWith(ext)) return true;
        }
        return false;
    }
}
