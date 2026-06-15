package com.neverdisband.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                // 로그인, 콜백, 정적 리소스는 인증 없이 접근 가능
                // TODO: 운영 배포 시 제거 또는 Profile 제한
                .requestMatchers("/dev/*", "/login", "/auth/discord/callback", "/static/**",
                                 "/*.css", "/*.js", "/*.png", "/*.webp", "/*.ico").permitAll()
                // 길드 메인 페이지는 컨트롤러에서 직접 인증 처리
                .requestMatchers("/*/main", "/*/admin", "/*/admin/**").permitAll()
                // WebSocket 엔드포인트
                .requestMatchers("/ws/**").permitAll()
                // WEB-INF 내부 JSP forward는 Security 체크 제외
                .dispatcherTypeMatchers(
                    jakarta.servlet.DispatcherType.FORWARD,
                    jakarta.servlet.DispatcherType.ERROR
                ).permitAll()
                // 나머지는 로그인 필요
                .anyRequest().authenticated()
            )
            // Spring Security 기본 로그인 폼 비활성화 (Discord OAuth로 직접 처리)
            .formLogin(form -> form.disable())
            // CSRF: 일반 웹앱이므로 활성화 유지 (로그아웃에만 POST 사용 시 필요)
            .csrf(csrf -> csrf
                .ignoringRequestMatchers("/auth/discord/callback")
            )
            // 미인증 접근 시 /login 으로 리다이렉트
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint((request, response, authException) ->
                    response.sendRedirect(request.getContextPath() + "/login")
                )
            )
            // 세션 고정 방지 비활성화
            // - Discord OAuth 콜백 시 세션이 교체되면 oauth_state가 소멸되는 문제 방지
            // - CSRF는 별도로 보호하므로 세션 고정 방지 없어도 안전
            .sessionManagement(session -> session
                .sessionFixation().none()
            )
            // 로그아웃 설정
            .logout(logout -> logout
                .logoutUrl("/logout")
                .logoutSuccessUrl("/login")
                .invalidateHttpSession(true)
                .deleteCookies("JSESSIONID")
            );

        return http.build();
    }

    // Spring Security 기본 유저 자동 생성 비활성화
    // (Discord OAuth로만 인증하므로 불필요)
    @Bean
    public UserDetailsService userDetailsService() {
        return new InMemoryUserDetailsManager();
    }
}
