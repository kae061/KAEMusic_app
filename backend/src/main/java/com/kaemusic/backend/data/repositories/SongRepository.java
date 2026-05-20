package com.kaemusic.backend.data.repositories;

import com.kaemusic.backend.data.entities.Song;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface SongRepository extends JpaRepository<Song, String> {

    @EntityGraph(attributePaths = {"artist", "album"})
    @Override
    Page<Song> findAll(Pageable pageable);
    List<Song> findByAlbumId(String albumId);
    List<Song> findByArtistId(String artistId);

    @Query("SELECT s FROM Song s WHERE LOWER(s.title) LIKE LOWER(CONCAT('%', :q, '%')) " +
           "OR LOWER(s.artist.name) LIKE LOWER(CONCAT('%', :q, '%'))")
    List<Song> searchSongs(@Param("q") String query);
}
