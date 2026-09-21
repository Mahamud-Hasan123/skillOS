package com.skillos.repository;

import com.skillos.entity.RoadmapTask;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RoadmapTaskRepository extends JpaRepository<RoadmapTask, Long> {
    List<RoadmapTask> findByRoadmapId(Long roadmapId);
    List<RoadmapTask> findByRoadmapIdAndDeletedAtIsNull(Long roadmapId);
    int countByRoadmapUserIdAndCompletedAtIsNotNull(Long userId);
    boolean existsByRoadmapIdAndDayNumberAndStatus(Long roadmapId, Integer dayNumber, String status);

    @org.springframework.data.jpa.repository.Query("SELECT rt FROM RoadmapTask rt WHERE rt.roadmap.id = :roadmapId AND NOT EXISTS (SELECT 1 FROM DailyTask dt WHERE dt.task.id = rt.id) ORDER BY rt.dayNumber ASC")
    List<RoadmapTask> findNextUnassignedTasks(@org.springframework.data.repository.query.Param("roadmapId") Long roadmapId, org.springframework.data.domain.Pageable pageable);
}
