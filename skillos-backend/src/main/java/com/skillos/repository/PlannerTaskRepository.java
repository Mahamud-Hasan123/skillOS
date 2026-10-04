package com.skillos.repository;

import com.skillos.entity.PlannerTask;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface PlannerTaskRepository extends JpaRepository<PlannerTask, Long> {

    List<PlannerTask> findByUserId(Long userId);

    List<PlannerTask> findByUserIdAndStatus(Long userId, String status);

    List<PlannerTask> findByUserIdAndStatusIn(Long userId, List<String> statuses);

    List<PlannerTask> findByUserIdAndPriority(Long userId, String priority);

    List<PlannerTask> findByUserIdAndCategory(Long userId, String category);

    // Find tasks due on or before a deadline
    List<PlannerTask> findByUserIdAndDeadlineLessThanEqualAndStatusIn(Long userId, LocalDateTime deadline, List<String> statuses);

    // Prevent duplicate imports from the same source
    Optional<PlannerTask> findByUserIdAndSourceTypeAndSourceId(Long userId, String sourceType, Long sourceId);
}
