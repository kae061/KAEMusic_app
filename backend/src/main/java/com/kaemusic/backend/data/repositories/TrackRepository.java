package com.kaemusic.backend.data.repositories;

import com.kaemusic.backend.data.entities.Track;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TrackRepository extends JpaRepository<Track, Integer> {
    List<Track> findByTitleContainingIgnoreCase(String title);
    List<Track> findByArtistContainingIgnoreCase(String artist);
    List<Track> findByGenre(String genre);

    @Query("SELECT t FROM Track t WHERE LOWER(t.title) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(t.artist) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(t.album) LIKE LOWER(CONCAT('%', :query, '%'))")
    List<Track> searchTracksGlobally(@Param("query") String query);
}
