package com.skillos.repository;

import com.skillos.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    Boolean existsByEmail(String email);

    @Query("SELECT u FROM User u WHERE (LOWER(u.fullName) LIKE LOWER(CONCAT('%',:query,'%')) " +
           "OR LOWER(u.email) LIKE LOWER(CONCAT('%',:query,'%')) " +
           "OR EXISTS (SELECT 1 FROM Roadmap r WHERE r.user = u AND LOWER(r.title) LIKE LOWER(CONCAT('%',:query,'%')))) " +
           "AND u.id != :currentUserId " +
           "AND u.id NOT IN (SELECT p.userA.id FROM Peer p WHERE p.userB.id = :currentUserId) " +
           "AND u.id NOT IN (SELECT p.userB.id FROM Peer p WHERE p.userA.id = :currentUserId)")
    List<User> searchPeers(@Param("query") String query, @Param("currentUserId") Long currentUserId);

    @Query("SELECT u FROM User u WHERE " +
           "(:role IS NULL OR u.role = :role) AND " +
           "(:query IS NULL OR LOWER(u.fullName) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(u.email) LIKE LOWER(CONCAT('%', :query, '%')))")
    org.springframework.data.domain.Page<User> searchAdminUsers(@Param("query") String query, @Param("role") String role, org.springframework.data.domain.Pageable pageable);

    @Query("SELECT COUNT(u) FROM User u WHERE u.updatedAt >= :sinceDate")
    long countActiveUsers(@Param("sinceDate") java.time.LocalDateTime sinceDate);

    @Query("SELECT u FROM User u JOIN UserStat us ON us.user.id = u.id WHERE us.currentStreak > 0")
    List<User> findUsersWithActiveStreak();
}
