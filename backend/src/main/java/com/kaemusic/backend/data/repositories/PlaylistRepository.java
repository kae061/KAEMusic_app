package com.kaemusic.backend.data.repositories;

import com.kaemusic.backend.data.entities.Playlist;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface PlaylistRepository extends JpaRepository<Playlist, String> {
    List<Playlist> findByOwnerId(String ownerId);
    Optional<Playlist> findByIdAndOwnerId(String id, String ownerId);

    @Query("SELECT DISTINCT p FROM Playlist p LEFT JOIN FETCH p.tracks t WHERE p.id = :id")
    Optional<Playlist> findByIdWithTracks(@Param("id") String id);

    @Query("SELECT DISTINCT p FROM Playlist p LEFT JOIN FETCH p.tracks t WHERE p.owner.id = :ownerId")
    List<Playlist> findByOwnerIdWithTracks(@Param("ownerId") String ownerId);
}
