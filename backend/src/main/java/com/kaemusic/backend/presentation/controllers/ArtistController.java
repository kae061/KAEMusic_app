package com.kaemusic.backend.presentation.controllers;

import com.kaemusic.backend.data.entities.Artist;
import com.kaemusic.backend.data.entities.Album;
import com.kaemusic.backend.data.entities.Song;
import com.kaemusic.backend.data.repositories.ArtistRepository;
import com.kaemusic.backend.data.repositories.AlbumRepository;
import com.kaemusic.backend.data.repositories.SongRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/artists")
@RequiredArgsConstructor
@CrossOrigin
public class ArtistController {

    private final ArtistRepository artistRepository;
    private final AlbumRepository albumRepository;
    private final SongRepository songRepository;

    @GetMapping
    public ResponseEntity<?> getArtists(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<Artist> artistPage = artistRepository.findAll(PageRequest.of(page, size));
        return ResponseEntity.ok(artistPage);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Artist> getArtistById(@PathVariable String id) {
        return artistRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/{id}/albums")
    public ResponseEntity<List<Album>> getArtistAlbums(@PathVariable String id) {
        List<Album> albums = albumRepository.findByArtistId(id);
        return ResponseEntity.ok(albums);
    }

    @GetMapping("/{id}/songs")
    public ResponseEntity<List<Song>> getArtistSongs(@PathVariable String id) {
        List<Song> songs = songRepository.findByArtistId(id);
        return ResponseEntity.ok(songs);
    }
}
