package com.skillos.repository;

import com.skillos.entity.DurationHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DurationHistoryRepository extends JpaRepository<DurationHistory, Long> {

    List<DurationHistory> findByUserId(Long userId);

    List<DurationHistory> findByUserIdAndCategory(Long userId, String category);

    // Get average actual duration for a user + category (for estimate improvement)
    @Query("SELECT AVG(d.actualMinutes) FROM DurationHistory d WHERE d.user.id = :userId AND d.category = :category")
    Double findAverageActualMinutesByUserIdAndCategory(Long userId, String category);

    // Count records for a user + category (to decide if we have enough data)
    long countByUserIdAndCategory(Long userId, String category);
}
