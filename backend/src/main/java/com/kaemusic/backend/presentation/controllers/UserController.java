package com.kaemusic.backend.presentation.controllers;

import com.kaemusic.backend.data.entities.User;
import com.kaemusic.backend.data.repositories.UserRepository;
import com.kaemusic.backend.presentation.dto.UserDto;
import jakarta.annotation.PostConstruct;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Map;
import java.util.Optional;

@Slf4j
@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    private final UserRepository userRepository;
    
    private final String AVATARS_DIR = "src/main/resources/static/avatars/";

    @Autowired
    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @PostConstruct
    public void init() {
        try {
            Path path = Paths.get(AVATARS_DIR);
            if (!Files.exists(path)) {
                Files.createDirectories(path);
            }
        } catch (IOException e) {
            System.err.println("Failed to create avatars directory: " + e.getMessage());
        }
    }

    private User getAuthenticatedUser(HttpServletRequest request) {
        String userId = request.getHeader("X-User-Id");
        log.info("getAuthenticatedUser called, X-User-Id: {}", userId);

        if (userId != null && !userId.trim().isEmpty()) {
            Optional<User> byId = userRepository.findById(userId.trim());
            if (byId.isPresent()) {
                log.info("User found by X-User-Id: {}", userId);
                return byId.get();
            }
            log.warn("User not found by X-User-Id: {}", userId);
        }

        var authentication = SecurityContextHolder.getContext().getAuthentication();
        log.info("SecurityContext authentication: {}", authentication);

        if (authentication == null || !authentication.isAuthenticated()) {
            log.warn("Authentication is null or not authenticated");
            return null;
        }
        Object principal = authentication.getPrincipal();
        log.info("Principal: {}", principal);

        if (!(principal instanceof String username) || "anonymousUser".equals(username)) {
            log.warn("Principal is not a valid username");
            return null;
        }
        Optional<User> user = userRepository.findByUsername(username);
        if (user.isPresent()) {
            log.info("User found by username: {}", username);
            return user.get();
        }
        log.warn("User not found by username: {}", username);
        return null;
    }

    private boolean isImageFile(MultipartFile file) {
        String contentType = file.getContentType();
        if (contentType != null && contentType.startsWith("image/")) {
            return true;
        }
        String filename = file.getOriginalFilename();
        if (filename == null) {
            return false;
        }
        String lower = filename.toLowerCase();
        return lower.endsWith(".png")
                || lower.endsWith(".jpg")
                || lower.endsWith(".jpeg")
                || lower.endsWith(".gif")
                || lower.endsWith(".webp");
    }

    @GetMapping("/me")
    public ResponseEntity<UserDto> getMe(HttpServletRequest request) {
        User user = getAuthenticatedUser(request);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        return ResponseEntity.ok(UserDto.fromEntity(user));
    }

    @PutMapping("/me/display-name")
    @Transactional
    public ResponseEntity<?> updateDisplayName(
            @RequestBody Map<String, String> requestBody,
            HttpServletRequest request) {
        log.info("updateDisplayName called");
        User user = getAuthenticatedUser(request);
        if (user == null) {
            log.warn("updateDisplayName: user is null, returning UNAUTHORIZED");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        String displayName = requestBody.get("displayName");
        log.info("updateDisplayName: displayName = {}", displayName);
        if (displayName == null || displayName.trim().isEmpty()) {
            log.warn("updateDisplayName: displayName is null or empty");
            return ResponseEntity.badRequest().body(Map.of("message", "displayName is required"));
        }

        user.setDisplayName(displayName.trim());
        userRepository.save(user);
        log.info("updateDisplayName: saved user with new displayName");

        return ResponseEntity.ok(UserDto.fromEntity(user));
    }

    @PutMapping("/profile")
    @Transactional
    public ResponseEntity<?> updateProfile(
            @RequestBody Map<String, String> requestBody,
            HttpServletRequest request) {
        User user = getAuthenticatedUser(request);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        String displayName = requestBody.get("displayName");
        if (displayName == null || displayName.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "displayName is required"));
        }

        user.setDisplayName(displayName.trim());
        userRepository.save(user);

        return ResponseEntity.ok(UserDto.fromEntity(user));
    }

    @PutMapping("/me/avatar")
    @Transactional
    public ResponseEntity<?> updateAvatarUrl(
            @RequestBody Map<String, String> requestBody,
            HttpServletRequest request) {
        User user = getAuthenticatedUser(request);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        String avatarUrl = requestBody.get("avatarUrl");
        if (avatarUrl == null || avatarUrl.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "avatarUrl is required"));
        }

        user.setAvatarUrl(avatarUrl.trim());
        userRepository.save(user);

        return ResponseEntity.ok(UserDto.fromEntity(user));
    }

    @PostMapping("/me/avatar")
    @Transactional
    public ResponseEntity<?> uploadAvatar(
            @RequestParam("file") MultipartFile file,
            HttpServletRequest request) {
        log.info("uploadAvatar called");
        User user = getAuthenticatedUser(request);
        if (user == null) {
            log.warn("uploadAvatar: user is null, returning UNAUTHORIZED");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        log.info("uploadAvatar: file.isEmpty() = {}, file.size() = {}", file.isEmpty(), file.getSize());
        if (file.isEmpty()) {
            log.warn("uploadAvatar: file is empty");
            return ResponseEntity.badRequest().body(Map.of("message", "File is empty"));
        }

        log.info("uploadAvatar: file.contentType = {}", file.getContentType());
        if (!isImageFile(file)) {
            log.warn("uploadAvatar: file is not an image");
            return ResponseEntity.badRequest().body(Map.of("message", "File must be an image"));
        }

        try {
            String extension = ".png";
            String original = file.getOriginalFilename();
            if (original != null && original.contains(".")) {
                extension = original.substring(original.lastIndexOf('.')).toLowerCase();
            }
            String filename = "user_" + user.getId() + "_avatar" + extension;
            Path targetLocation = Paths.get(AVATARS_DIR).resolve(filename);
            Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);

            String avatarUrl = "/avatars/" + filename;
            user.setAvatarUrl(avatarUrl);
            userRepository.save(user);
            log.info("uploadAvatar: saved avatar, avatarUrl = {}", avatarUrl);

            return ResponseEntity.ok(UserDto.fromEntity(user));
        } catch (IOException e) {
            log.error("uploadAvatar: IOException while saving avatar", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("message", "Could not save avatar image"));
        }
    }

    @DeleteMapping("/me/avatar")
    @Transactional
    public ResponseEntity<?> deleteAvatar(HttpServletRequest request) {
        User user = getAuthenticatedUser(request);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        user.setAvatarUrl(null);
        userRepository.save(user);

        return ResponseEntity.ok(UserDto.fromEntity(user));
    }
}