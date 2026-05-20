package com.kaemusic.backend.data.repositories;

import com.kaemusic.backend.data.entities.Album;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface AlbumRepository extends JpaRepository<Album, String> {
    List<Album> findByArtistId(String artistId);
}
