package com.kaemusic.backend.presentation.controllers;

import com.kaemusic.backend.data.entities.Playlist;
import com.kaemusic.backend.data.entities.Track;
import com.kaemusic.backend.data.entities.User;
import com.kaemusic.backend.data.repositories.PlaylistRepository;
import com.kaemusic.backend.data.repositories.TrackRepository;
import com.kaemusic.backend.data.repositories.UserRepository;
import com.kaemusic.backend.presentation.dto.PlaylistDto;
import com.kaemusic.backend.presentation.dto.TrackDto;
import jakarta.servlet.http.HttpServletRequest;
import lombok.Data;
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
@RequestMapping("/api/v1/playlists")
@RequiredArgsConstructor
@CrossOrigin
@Slf4j
public class PlaylistController {

    private final PlaylistRepository playlistRepository;
    private final TrackRepository trackRepository;
    private final UserRepository userRepository;

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
    public ResponseEntity<?> getMyPlaylists(HttpServletRequest request) {
        User user = getAuthenticatedUser(request);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        List<PlaylistDto> playlists = playlistRepository.findByOwnerIdWithTracks(user.getId()).stream()
                .map(PlaylistDto::fromEntity)
                .collect(Collectors.toList());

        return ResponseEntity.ok(playlists);
    }

    @GetMapping("/{id}")
    @Transactional(readOnly = true)
    public ResponseEntity<?> getPlaylistById(@PathVariable String id, HttpServletRequest request) {
        User user = getAuthenticatedUser(request);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        Optional<Playlist> opt = playlistRepository.findByIdWithTracks(id);
        if (opt.isEmpty() || !opt.get().getOwner().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        return ResponseEntity.ok(PlaylistDto.fromEntity(opt.get()));
    }

    @PostMapping
    @Transactional
    public ResponseEntity<?> createPlaylist(
            @RequestBody CreatePlaylistRequest requestBody,
            HttpServletRequest request) {
        log.info("createPlaylist called with name: {}", requestBody.getName());
        User user = getAuthenticatedUser(request);
        if (user == null) {
            log.warn("createPlaylist: user is null, returning UNAUTHORIZED");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        if (requestBody.getName() == null || requestBody.getName().trim().isEmpty()) {
            log.warn("createPlaylist: name is empty");
            return ResponseEntity.badRequest().body(Map.of("error", "Playlist name cannot be empty"));
        }

        Playlist playlist = Playlist.builder()
                .name(requestBody.getName().trim())
                .description(requestBody.getDescription())
                .owner(user)
                .coverUrl("https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?w=500&auto=format&fit=crop&q=80")
                .build();

        Playlist saved = playlistRepository.save(playlist);
        log.info("createPlaylist: playlist created with id: {}", saved.getId());
        return ResponseEntity.status(HttpStatus.CREATED).body(PlaylistDto.fromEntity(saved));
    }

    @PutMapping("/{id}")
    @Transactional
    public ResponseEntity<?> renamePlaylist(
            @PathVariable String id,
            @RequestBody RenamePlaylistRequest requestBody,
            HttpServletRequest request) {
        User user = getAuthenticatedUser(request);
        if (user == null) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();

        if (requestBody.getName() == null || requestBody.getName().trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Name required"));
        }

        Optional<Playlist> opt = playlistRepository.findById(id);
        if (opt.isEmpty() || !opt.get().getOwner().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        Playlist p = opt.get();
        p.setName(requestBody.getName().trim());
        playlistRepository.save(p);
        return ResponseEntity.ok(PlaylistDto.fromEntity(p));
    }

    @DeleteMapping("/{id}")
    @Transactional
    public ResponseEntity<?> deletePlaylist(@PathVariable String id, HttpServletRequest request) {
        User user = getAuthenticatedUser(request);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        Optional<Playlist> playlistOpt = playlistRepository.findById(id);
        if (playlistOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Playlist playlist = playlistOpt.get();
        if (!playlist.getOwner().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Not the owner"));
        }

        playlistRepository.delete(playlist);
        return ResponseEntity.ok(Map.of("message", "Playlist deleted successfully"));
    }

    @PostMapping("/{id}/tracks")
    @Transactional
    public ResponseEntity<?> addTrackToPlaylist(
            @PathVariable String id,
            @RequestBody Map<String, String> body,
            HttpServletRequest request) {
        User user = getAuthenticatedUser(request);
        if (user == null) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();

        String trackId = body.get("trackId");
        if (trackId == null) return ResponseEntity.badRequest().build();

        Optional<Playlist> playlistOpt = playlistRepository.findByIdWithTracks(id);
        if (playlistOpt.isEmpty()) return ResponseEntity.notFound().build();

        Playlist playlist = playlistOpt.get();
        if (!playlist.getOwner().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        final Integer parsedTrackId;
        try {
            parsedTrackId = Integer.parseInt(trackId);
        } catch (NumberFormatException ex) {
            return ResponseEntity.badRequest().build();
        }

        Optional<Track> trackOpt = trackRepository.findById(parsedTrackId);
        if (trackOpt.isEmpty()) return ResponseEntity.notFound().build();

        Track track = trackOpt.get();
        boolean alreadyExists = playlist.getTracks().stream()
                .anyMatch(t -> t.getId().equals(parsedTrackId));

        if (alreadyExists) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("error", "Track already in playlist"));
        }

        playlist.getTracks().add(track);
        playlistRepository.saveAndFlush(playlist);

        return ResponseEntity.ok(PlaylistDto.fromEntity(playlist));
    }

    @DeleteMapping("/{id}/tracks/{trackId}")
    @Transactional
    public ResponseEntity<?> removeTrackFromPlaylist(
            @PathVariable String id,
            @PathVariable String trackId,
            HttpServletRequest request) {
        User user = getAuthenticatedUser(request);
        if (user == null) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();

        Optional<Playlist> playlistOpt = playlistRepository.findByIdWithTracks(id);
        if (playlistOpt.isEmpty()) return ResponseEntity.notFound().build();

        Playlist playlist = playlistOpt.get();
        if (!playlist.getOwner().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        final Integer parsedTrackId;
        try {
            parsedTrackId = Integer.parseInt(trackId);
        } catch (NumberFormatException ex) {
            return ResponseEntity.badRequest().build();
        }

        playlist.getTracks().removeIf(t -> t.getId().equals(parsedTrackId));
        playlistRepository.saveAndFlush(playlist);

        return ResponseEntity.ok(PlaylistDto.fromEntity(playlist));
    }

    @Data
    public static class CreatePlaylistRequest {
        private String name;
        private String description;
    }

    @Data
    public static class RenamePlaylistRequest {
        private String name;
    }
}
