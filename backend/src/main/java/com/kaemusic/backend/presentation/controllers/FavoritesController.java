package com.kaemusic.backend.presentation.controllers;

import com.kaemusic.backend.data.entities.Track;
import com.kaemusic.backend.data.entities.User;
import com.kaemusic.backend.data.repositories.TrackRepository;
import com.kaemusic.backend.data.repositories.UserRepository;
import com.kaemusic.backend.presentation.dto.TrackDto;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/favorites")
@RequiredArgsConstructor
@CrossOrigin
@Slf4j
public class FavoritesController {

    private final UserRepository userRepository;
    private final TrackRepository trackRepository;

    private User getAuthenticatedUser(HttpServletRequest request) {
        String userId = request.getHeader("X-User-Id");
        log.info("getAuthenticatedUser: X-User-Id header = {}", userId);
        
        if (userId != null && !userId.trim().isEmpty()) {
            Optional<User> byId = userRepository.findById(userId.trim());
            if (byId.isPresent()) {
                log.info("getAuthenticatedUser: found user by X-User-Id: {}", byId.get().getUsername());
                return byId.get();
            }
        }

        var authentication = SecurityContextHolder.getContext().getAuthentication();
        log.info("getAuthenticatedUser: SecurityContext authentication = {}", authentication);
        
        if (authentication == null || !authentication.isAuthenticated()) {
            log.warn("getAuthenticatedUser: authentication is null or not authenticated");
            return null;
        }
        Object principal = authentication.getPrincipal();
        log.info("getAuthenticatedUser: principal = {}", principal);
        
        if (!(principal instanceof String username) || "anonymousUser".equals(username)) {
            log.warn("getAuthenticatedUser: principal is not a String or is anonymousUser");
            return null;
        }
        User user = userRepository.findByUsername(username).orElse(null);
        log.info("getAuthenticatedUser: found user by username: {}", user != null ? user.getUsername() : null);
        return user;
    }

    @GetMapping
    @Transactional(readOnly = true)
    public ResponseEntity<?> getFavorites(HttpServletRequest request) {
        User user = getAuthenticatedUser(request);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("message", "Not authenticated"));
        }

        Optional<User> userWithLikes = userRepository.findByIdWithFavoriteTracks(user.getId());
        if (userWithLikes.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("message", "User not found"));
        }

        List<TrackDto> favorites = userWithLikes.get().getFavoriteTracks().stream()
                .map(TrackDto::fromEntity)
                .collect(Collectors.toList());

        return ResponseEntity.ok(favorites);
    }

    @PostMapping("/{trackId}")
    @Transactional
    public ResponseEntity<?> toggleFavorite(
            @PathVariable String trackId,
            HttpServletRequest request) {
        log.info("toggleFavorite called with trackId: {}", trackId);
        User user = getAuthenticatedUser(request);
        if (user == null) {
            log.warn("toggleFavorite: user is null, returning UNAUTHORIZED");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("message", "Not authenticated"));
        }

        Optional<User> userOpt = userRepository.findByIdWithFavoriteTracks(user.getId());
        if (userOpt.isEmpty()) {
            log.warn("toggleFavorite: user not found in repository");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("message", "User not found"));
        }

        // Try to parse as Integer first (for backward compatibility)
        Integer parsedTrackId = null;
        try {
            parsedTrackId = Integer.parseInt(trackId);
        } catch (NumberFormatException ex) {
            // If not a number, try to find by string representation
            parsedTrackId = null;
        }

        Optional<Track> trackOpt;
        if (parsedTrackId != null) {
            trackOpt = trackRepository.findById(parsedTrackId);
        } else {
            // Try to find track by converting string ID to integer if possible
            try {
                trackOpt = trackRepository.findById(Integer.parseInt(trackId));
            } catch (NumberFormatException e) {
                log.warn("toggleFavorite: invalid track id format: {}", trackId);
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(Map.of("message", "Invalid track id format"));
            }
        }

        if (trackOpt.isEmpty()) {
            log.warn("toggleFavorite: track not found with id: {}", trackId);
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", "Track not found"));
        }

        User fetchedUser = userOpt.get();
        Track track = trackOpt.get();
        boolean isAlreadyLiked = fetchedUser.getFavoriteTracks().stream()
                .anyMatch(t -> t.getId().equals(track.getId()));

        log.info("toggleFavorite: isAlreadyLiked = {}", isAlreadyLiked);

        if (isAlreadyLiked) {
            fetchedUser.getFavoriteTracks().removeIf(t -> t.getId().equals(track.getId()));
        } else {
            fetchedUser.getFavoriteTracks().add(track);
        }

        userRepository.saveAndFlush(fetchedUser);
        log.info("toggleFavorite: saved user favorites, returning favorited = {}", !isAlreadyLiked);

        return ResponseEntity.ok(Map.of(
                "favorited", !isAlreadyLiked
        ));
    }
}
