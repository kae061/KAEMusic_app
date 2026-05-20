package com.kaemusic.backend.presentation.controllers;

import com.kaemusic.backend.data.entities.Album;
import com.kaemusic.backend.data.entities.Song;
import com.kaemusic.backend.data.repositories.AlbumRepository;
import com.kaemusic.backend.data.repositories.SongRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/albums")
@RequiredArgsConstructor
@CrossOrigin
public class AlbumController {

    private final AlbumRepository albumRepository;
    private final SongRepository songRepository;

    @GetMapping
    public ResponseEntity<?> getAlbums(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<Album> albumPage = albumRepository.findAll(PageRequest.of(page, size));
        return ResponseEntity.ok(albumPage);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Album> getAlbumById(@PathVariable String id) {
        return albumRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/{id}/songs")
    public ResponseEntity<List<Song>> getAlbumSongs(@PathVariable String id) {
        List<Song> songs = songRepository.findByAlbumId(id);
        return ResponseEntity.ok(songs);
    }
}
