package com.kaemusic.backend.presentation.controllers;

import com.kaemusic.backend.core.security.JwtTokenProvider;
import com.kaemusic.backend.data.entities.User;
import com.kaemusic.backend.data.repositories.UserRepository;
import com.kaemusic.backend.presentation.dto.UserDto;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@CrossOrigin
public class AuthController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
        if (userRepository.findByUsername(request.getUsername()).isPresent() ||
            userRepository.findByEmail(request.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Username or Email already exists"));
        }

        User user = User.builder()
                .username(request.getUsername())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .displayName(request.getDisplayName())
                .avatarUrl(request.getAvatarUrl())
                .build();

        userRepository.save(user);

        return ResponseEntity.ok(buildAuthResponse(user));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        String identifier = request.getUsername();
        if (identifier == null || identifier.isBlank()) {
            identifier = request.getEmail();
        }
        if (identifier == null || identifier.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Username or email is required"));
        }

        Optional<User> userOpt = userRepository.findByUsername(identifier);
        if (userOpt.isEmpty()) {
            userOpt = userRepository.findByEmail(identifier);
        }

        if (userOpt.isEmpty() || !passwordEncoder.matches(request.getPassword(), userOpt.get().getPassword())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Invalid credentials"));
        }

        return ResponseEntity.ok(buildAuthResponse(userOpt.get()));
    }

    @GetMapping("/me")
    public ResponseEntity<?> me() {
        User user = resolveAuthenticatedUser();
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        return ResponseEntity.ok(UserDto.fromEntity(user));
    }

    private Map<String, Object> buildAuthResponse(User user) {
        String token = jwtTokenProvider.generateToken(user.getUsername());
        return Map.of(
            "accessToken", token,
            "refreshToken", token,
            "token", token,
            "user", UserDto.fromEntity(user)
        );
    }

    private User resolveAuthenticatedUser() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return null;
        }
        Object principal = authentication.getPrincipal();
        if (!(principal instanceof String username) || "anonymousUser".equals(username)) {
            return null;
        }
        return userRepository.findByUsername(username).orElse(null);
    }

    @Data
    public static class LoginRequest {
        private String username;
        private String email;
        private String password;
    }

    @Data
    public static class RegisterRequest {
        private String username;
        private String email;
        private String password;
        private String displayName;
        private String avatarUrl;
    }
}
