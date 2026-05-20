package com.kaemusic.backend.presentation.dto;

import com.kaemusic.backend.data.entities.Track;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class TrackDto {
    private String id;
    private String title;
    private String artist;
    private String album;
    private String genre;
    private Integer durationSeconds;
    private String streamUrl;
    private String coverArtUrl;

    public static TrackDto fromEntity(Track track) {
        return TrackDto.builder()
                .id(track.getId() != null ? track.getId().toString() : null)
                .title(track.getTitle())
                .artist(track.getArtist())
                .album(track.getAlbum())
                .genre(track.getGenre())
                .durationSeconds(track.getDurationSeconds())
                .streamUrl(track.getStreamUrl())
                .coverArtUrl(track.getCoverArtUrl())
                .build();
    }
}
