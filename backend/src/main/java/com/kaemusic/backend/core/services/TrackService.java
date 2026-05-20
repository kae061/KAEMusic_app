package com.kaemusic.backend.core.services;

import com.kaemusic.backend.data.entities.Track;
import com.kaemusic.backend.data.repositories.TrackRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class TrackService {

    private final TrackRepository trackRepository;

    public Page<Track> getAllTracks(Pageable pageable) {
        return trackRepository.findAll(pageable);
    }

    public List<Track> searchTracks(String query) {
        return trackRepository.searchTracksGlobally(query);
    }

    public Optional<Track> getTrackById(String id) {
        try {
            return trackRepository.findById(Integer.parseInt(id));
        } catch (NumberFormatException ex) {
            log.warn("Invalid track id: {}", id);
            return Optional.empty();
        }
    }
}
