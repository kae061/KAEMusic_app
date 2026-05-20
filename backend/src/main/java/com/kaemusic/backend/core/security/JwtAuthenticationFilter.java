package com.kaemusic.backend.core.security;

import com.kaemusic.backend.data.entities.User;
import com.kaemusic.backend.data.repositories.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Optional;

@Component
@RequiredArgsConstructor
@Slf4j
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenProvider jwtTokenProvider;
    private final UserRepository userRepository;

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        String requestUri = request.getRequestURI();
        String method = request.getMethod();

        // Try JWT authentication first
        String token = jwtTokenProvider.resolveToken(request);
        if (token != null && jwtTokenProvider.validateToken(token)) {
            String username = jwtTokenProvider.getUsername(token);
            log.info("JWT token validated for {} {}: username={}", method, requestUri, username);

            UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(
                    username, null, new ArrayList<>());
            auth.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

            SecurityContextHolder.getContext().setAuthentication(auth);
        } else {
            // Fall back to X-User-Id authentication for user endpoints
            String userId = request.getHeader("X-User-Id");
            if (userId != null && !userId.trim().isEmpty() && requestUri.contains("/users/")) {
                log.info("Attempting X-User-Id authentication for {} {}: userId={}", method, requestUri, userId);
                Optional<User> userOptional = userRepository.findById(userId.trim());
                if (userOptional.isPresent()) {
                    User user = userOptional.get();
                    log.info("User found via X-User-Id: {}", user.getUsername());

                    UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(
                            user.getUsername(), null, new ArrayList<>());
                    auth.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

                    SecurityContextHolder.getContext().setAuthentication(auth);
                } else {
                    log.warn("User not found via X-User-Id: {}", userId);
                }
            } else {
                if (token != null) {
                    log.warn("JWT token validation failed for {} {}", method, requestUri);
                } else {
                    log.debug("No JWT token found for {} {}", method, requestUri);
                }
            }
        }

        filterChain.doFilter(request, response);
    }
}