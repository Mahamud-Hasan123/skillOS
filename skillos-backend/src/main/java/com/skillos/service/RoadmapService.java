package com.skillos.service;

import com.skillos.dto.request.UpdateRoadmapRequest;
import com.skillos.entity.Roadmap;
import com.skillos.entity.RoadmapTask;
import com.skillos.entity.User;
import com.skillos.exception.ResourceNotFoundException;
import com.skillos.repository.RoadmapRepository;
import com.skillos.repository.RoadmapTaskRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class RoadmapService {

    private final RoadmapRepository roadmapRepository;
    private final RoadmapTaskRepository roadmapTaskRepository;

    public List<Roadmap> getUserRoadmaps(User user) {
        return roadmapRepository.findByUserId(user.getId());
    }

    @Transactional
    public Roadmap updateRoadmap(Long id, UpdateRoadmapRequest request, User user) {
        Roadmap roadmap = roadmapRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Roadmap not found"));

        if (!roadmap.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Forbidden"); // Should use proper exception
        }

        if (request.getTitle() != null) {
            roadmap.setTitle(request.getTitle());
        }

        if (request.getStatus() != null) {
            // If setting to active, we should archive others
            if ("active".equals(request.getStatus())) {
                List<Roadmap> activeRoadmaps = roadmapRepository.findByUserIdAndStatus(user.getId(), "active");
                for (Roadmap active : activeRoadmaps) {
                    if (!active.getId().equals(roadmap.getId())) {
                        active.setStatus("archived");
                        roadmapRepository.save(active);
                    }
                }
            }
            roadmap.setStatus(request.getStatus());
        }

        if (request.getProgressPercent() != null) {
            roadmap.setProgressPercent(request.getProgressPercent());
        }

        return roadmapRepository.save(roadmap);
    }

    @Transactional
    public void deleteRoadmap(Long id, User user) {
        Roadmap roadmap = roadmapRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Roadmap not found"));

        if (!roadmap.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Forbidden");
        }

        roadmapRepository.delete(roadmap);
    }
    
    @Transactional
    public void completeTask(Long taskId, User user) {
        RoadmapTask task = roadmapTaskRepository.findById(taskId)
                .orElseThrow(() -> new ResourceNotFoundException("Task not found"));
                
        if (!task.getRoadmap().getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Forbidden");
        }
        
        task.setStatus("completed");
        task.setCompletedAt(LocalDateTime.now());
        roadmapTaskRepository.save(task);
    }
}
