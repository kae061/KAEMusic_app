package com.kaemusic.backend.data.entities;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false, unique = true)
    private String username;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private String displayName;

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private String avatarUrl;

    @Column(nullable = false, columnDefinition = "varchar(255) default 'USER'")
    @Builder.Default
    private String role = "USER";

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "user_favorite_tracks",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "track_id")
    )
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default
    private List<Track> favoriteTracks = new ArrayList<>();

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.displayName == null) {
            this.displayName = this.username;
        }
    }
}
