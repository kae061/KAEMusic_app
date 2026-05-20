package com.kaemusic.backend.presentation.dto;

import com.kaemusic.backend.data.entities.Song;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class SongDto {
    private String id;
    private String title;
    private String artistId;
    private String artistName;
    private String albumId;
    private String albumTitle;
    private String coverUrl;
    private String audioUrl;
    private int durationSeconds;
    private int playCount;
    private String releasedAt;

    public static SongDto fromEntity(Song song) {
        if (song == null) {
            return null;
        }
        return SongDto.builder()
                .id(song.getId())
                .title(song.getTitle())
                .artistId(song.getArtist() != null ? song.getArtist().getId() : null)
                .artistName(song.getArtist() != null ? song.getArtist().getName() : null)
                .albumId(song.getAlbum() != null ? song.getAlbum().getId() : null)
                .albumTitle(song.getAlbum() != null ? song.getAlbum().getTitle() : null)
                .coverUrl(song.getCoverUrl())
                .audioUrl(song.getAudioUrl())
                .durationSeconds(song.getDurationSeconds())
                .playCount(song.getPlayCount())
                .releasedAt(song.getReleasedAt() != null ? song.getReleasedAt().toString() : null)
                .build();
    }
}
