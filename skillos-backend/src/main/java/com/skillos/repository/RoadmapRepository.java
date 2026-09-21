package com.skillos.repository;

import com.skillos.entity.Roadmap;
import com.skillos.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RoadmapRepository extends JpaRepository<Roadmap, Long> {
    List<Roadmap> findByUserId(Long userId);
    List<Roadmap> findByUserIdAndStatus(Long userId, String status);
    List<Roadmap> findByUserAndStatus(User user, String status);
    List<Roadmap> findByUserOrderByCreatedAtDesc(User user);
    List<Roadmap> findByStatus(String status);


    @org.springframework.data.jpa.repository.Query("SELECT r.title AS skillName, COUNT(DISTINCT r.user) AS count FROM Roadmap r GROUP BY r.title ORDER BY count DESC")
    List<com.skillos.dto.response.SkillPopularityData> findTopSkills(org.springframework.data.domain.Pageable pageable);
}
