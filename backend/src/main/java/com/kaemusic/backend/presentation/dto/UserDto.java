package com.kaemusic.backend.presentation.dto;

import com.kaemusic.backend.data.entities.User;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UserDto {
    private String id;
    private String username;
    private String email;
    private String displayName;
    private String avatarUrl;
    private String role;

    public static UserDto fromEntity(User user) {
        if (user == null) {
            return null;
        }
        return UserDto.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .displayName(user.getDisplayName())
                .avatarUrl(user.getAvatarUrl())
                .role(user.getRole() != null ? user.getRole() : "USER")
                .build();
    }
}
