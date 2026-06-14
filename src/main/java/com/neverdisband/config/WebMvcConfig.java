package com.neverdisband.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    private final MemberRoleInterceptor memberRoleInterceptor;

    public WebMvcConfig(MemberRoleInterceptor memberRoleInterceptor) {
        this.memberRoleInterceptor = memberRoleInterceptor;
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/logo.webp")
                .addResourceLocations("classpath:/static/", "/");
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(memberRoleInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns("/", "/guild/**", "/auth/**", "/login", "/logout", "/ws/**",
                        "/logo.webp", "/error");
    }
}
