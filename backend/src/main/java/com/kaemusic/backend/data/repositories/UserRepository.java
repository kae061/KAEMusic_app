package com.kaemusic.backend.data.repositories;

import com.kaemusic.backend.data.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, String> {
    Optional<User> findByEmail(String email);
    Optional<User> findByUsername(String username);

    @Query("SELECT u FROM User u LEFT JOIN FETCH u.favoriteTracks WHERE u.id = :id")
    Optional<User> findByIdWithFavoriteTracks(@Param("id") String id);
}
