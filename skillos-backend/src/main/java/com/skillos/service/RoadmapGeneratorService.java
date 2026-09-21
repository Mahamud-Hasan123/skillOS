package com.skillos.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.skillos.dto.request.GenerateRoadmapRequest;
import com.skillos.entity.*;
import com.skillos.repository.GenerationJobRepository;
import com.skillos.repository.RoadmapRepository;
import com.skillos.repository.RoadmapTaskRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Slf4j
@Service
@RequiredArgsConstructor
public class RoadmapGeneratorService {

    private final GeminiService geminiService;
    private final GenerationJobRepository generationJobRepository;
    private final RoadmapRepository roadmapRepository;
    private final RoadmapTaskRepository roadmapTaskRepository;
    private final ObjectMapper objectMapper;

    @Async("taskExecutor")
    @Transactional
    public void generateAndSaveRoadmap(GenerationJob job, User user, GenerateRoadmapRequest request) {
        try {
            job.setStatus("processing");
            generationJobRepository.save(job);

            log.info("Starting AI generation for Job ID: {}", job.getJobId());

            String jsonResponse = geminiService.generateRoadmapJson(
                    request.getSkillGoal(),
                    request.getDailyTimeMinutes(),
                    request.getDurationMonths(),
                    request.getLevel(),
                    request.getFocusAreas()
            );

            log.info("AI generation successful for Job ID: {}", job.getJobId());

            // Parse response
            JsonNode root = objectMapper.readTree(jsonResponse);
            
            // Deactivate all existing active roadmaps for this user
            java.util.List<Roadmap> currentlyActive = roadmapRepository.findByUserIdAndStatus(user.getId(), "active");
            for (Roadmap existing : currentlyActive) {
                existing.setStatus("archived");
                roadmapRepository.save(existing);
            }

            Roadmap roadmap = Roadmap.builder()
                    .user(user)
                    .title(root.get("title").asText())
                    .skillGoal(root.get("skill_goal").asText())
                    .level(root.get("level").asText())
                    .status("active")
                    .durationMonths(request.getDurationMonths())
                    .dailyTimeMinutes(request.getDailyTimeMinutes())
                    .totalDays(root.get("total_days").asInt())
                    .startDate(java.time.LocalDate.now())
                    .endDate(java.time.LocalDate.now().plusDays(root.get("total_days").asInt()))
                    .build();

            roadmap = roadmapRepository.save(roadmap);

            JsonNode tasksNode = root.get("tasks");
            if (tasksNode != null && tasksNode.isArray()) {
                for (JsonNode taskNode : tasksNode) {
                    RoadmapTask task = RoadmapTask.builder()
                            .roadmap(roadmap)
                            .dayNumber(taskNode.get("day_number").asInt())
                            .title(taskNode.get("title").asText())
                            .question(taskNode.get("question").asText())
                            .answer(taskNode.get("answer").asText())
                            .status("pending")
                            .xpReward(10) // default XP
                            .build();
                    roadmapTaskRepository.save(task);

                    // We will handle Flashcards later in Module 18, 
                    // for now we just store the roadmap task.
                }
            }

            job.setStatus("complete");
            job.setProgressPercent(100);
            job.setResultId(roadmap.getId());
            job.setCompletedAt(LocalDateTime.now());
            generationJobRepository.save(job);
            
            log.info("Saved Roadmap ID {} for Job ID: {}", roadmap.getId(), job.getJobId());

        } catch (Exception e) {
            log.error("Generation failed for Job ID: {}", job.getJobId(), e);
            job.setStatus("failed");
            job.setErrorMessage(e.getMessage());
            job.setCompletedAt(LocalDateTime.now());
            generationJobRepository.save(job);
        }
    }
}
