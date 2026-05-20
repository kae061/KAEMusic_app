package com.kaemusic.backend.presentation.dto;

import com.kaemusic.backend.data.entities.Playlist;
import lombok.Builder;
import lombok.Data;

import java.util.List;
import java.util.stream.Collectors;

@Data
@Builder
public class PlaylistDto {
    private String id;
    private String name;
    private String description;
    private String coverUrl;
    private String userId;
    private String createdAt;
    private List<TrackDto> tracks;
    private int trackCount;

    public static PlaylistDto fromEntity(Playlist playlist) {
        if (playlist == null) {
            return null;
        }
        List<TrackDto> trackDtos = playlist.getTracks() == null
                ? List.of()
                : playlist.getTracks().stream()
                        .map(TrackDto::fromEntity)
                        .collect(Collectors.toList());

        return PlaylistDto.builder()
                .id(playlist.getId())
                .name(playlist.getName())
                .description(playlist.getDescription())
                .coverUrl(playlist.getCoverUrl())
                .userId(playlist.getOwner() != null ? playlist.getOwner().getId() : null)
                .createdAt(playlist.getCreatedAt() != null ? playlist.getCreatedAt().toString() : null)
                .tracks(trackDtos)
                .trackCount(trackDtos.size())
                .build();
    }
}
