package com.mms.backend.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Configuration
@Order(Ordered.HIGHEST_PRECEDENCE)
@lombok.extern.slf4j.Slf4j
public class RequestLoggingFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        long startTime = System.currentTimeMillis();

        log.info("==========================================================================================");
        log.info(">>> [REQUEST] {} {}{}", request.getMethod(), request.getRequestURI(),
                (request.getQueryString() != null ? "?" + request.getQueryString() : ""));
        log.info(">>> [CLIENT] IP: {}", request.getRemoteAddr());
        log.info("==========================================================================================");

        try {
            filterChain.doFilter(request, response);
        } finally {
            long duration = System.currentTimeMillis() - startTime;
            log.info("==========================================================================================");
            log.info("<<< [RESPONSE] Status: {} | Time: {}ms", response.getStatus(), duration);
            log.info("==========================================================================================");
        }
    }
}
