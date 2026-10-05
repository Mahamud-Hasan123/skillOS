package com.skillos.repository;

import com.skillos.entity.Project;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProjectRepository extends JpaRepository<Project, Long> {
    List<Project> findByUserIdAndDeletedAtIsNull(Long userId);
    List<Project> findByUserIdAndStatusAndDeletedAtIsNull(Long userId, String status);
    int countByUserIdAndStatusAndDeletedAtIsNull(Long userId, String status);

    @org.springframework.data.jpa.repository.Query("SELECT p.skillName AS skillName, COUNT(p) AS count FROM Project p GROUP BY p.skillName ORDER BY count DESC")
    List<com.skillos.dto.response.SkillPopularityData> findTopSkills(org.springframework.data.domain.Pageable pageable);
}
