package com.kaemusic.backend.presentation.controllers;

import com.kaemusic.backend.data.entities.Song;
import com.kaemusic.backend.data.entities.User;
import com.kaemusic.backend.data.repositories.SongRepository;
import com.kaemusic.backend.data.repositories.UserRepository;
import com.kaemusic.backend.presentation.dto.SongDto;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
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
@RequestMapping("/api/v1/songs")
@RequiredArgsConstructor
@CrossOrigin
public class SongController {

    private final SongRepository songRepository;
    private final UserRepository userRepository;

    @GetMapping
    @Transactional(readOnly = true)
    public ResponseEntity<?> getSongs(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<Song> songPage = songRepository.findAll(PageRequest.of(page, size));
        List<SongDto> content = songPage.getContent().stream()
                .map(SongDto::fromEntity)
                .collect(Collectors.toList());
        Page<SongDto> dtoPage = new PageImpl<>(content, songPage.getPageable(), songPage.getTotalElements());
        return ResponseEntity.ok(dtoPage);
    }

    @GetMapping("/{id}")
    @Transactional(readOnly = true)
    public ResponseEntity<?> getSongById(@PathVariable String id) {
        return songRepository.findById(id)
                .map(song -> ResponseEntity.ok(SongDto.fromEntity(song)))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/search")
    @Transactional(readOnly = true)
    public ResponseEntity<List<SongDto>> searchSongs(@RequestParam String q) {
        List<SongDto> results = songRepository.searchSongs(q).stream()
                .map(SongDto::fromEntity)
                .collect(Collectors.toList());
        return ResponseEntity.ok(results);
    }



    private User getAuthenticatedUser(HttpServletRequest request) {
        String userId = request.getHeader("X-User-Id");
        if (userId != null && !userId.trim().isEmpty()) {
            Optional<User> byId = userRepository.findById(userId.trim());
            if (byId.isPresent()) {
                return byId.get();
            }
        }

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
}
