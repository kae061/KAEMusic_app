package com.kaemusic.backend.presentation.controllers;

import com.kaemusic.backend.core.services.TrackService;
import com.kaemusic.backend.data.entities.Track;
import com.kaemusic.backend.presentation.dto.TrackDto;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping({"/api/tracks", "/api/v1/tracks"})
@RequiredArgsConstructor
@CrossOrigin
public class TrackController {

    private final TrackService trackService;

    @GetMapping
    public ResponseEntity<Page<TrackDto>> getTracks(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<Track> tracksPage = trackService.getAllTracks(PageRequest.of(page, size));
        Page<TrackDto> trackDtos = tracksPage.map(TrackDto::fromEntity);
        return ResponseEntity.ok(trackDtos);
    }

    @GetMapping("/search")
    public ResponseEntity<List<TrackDto>> searchTracks(@RequestParam String q) {
        List<Track> tracks = trackService.searchTracks(q);
        List<TrackDto> trackDtos = tracks.stream()
                .map(TrackDto::fromEntity)
                .collect(Collectors.toList());
        return ResponseEntity.ok(trackDtos);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TrackDto> getTrackById(@PathVariable String id) {
        return trackService.getTrackById(id)
                .map(track -> ResponseEntity.ok(TrackDto.fromEntity(track)))
                .orElse(ResponseEntity.notFound().build());
    }
}
