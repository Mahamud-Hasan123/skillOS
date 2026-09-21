package com.skillos.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.skillos.dto.request.GenerateRoadmapRequest;
import com.skillos.dto.request.UpdateRoadmapRequest;
import com.skillos.entity.GenerationJob;
import com.skillos.entity.Roadmap;
import com.skillos.entity.User;
import com.skillos.exception.ResourceNotFoundException;
import com.skillos.repository.GenerationJobRepository;
import com.skillos.repository.RoadmapRepository;
import com.skillos.service.RoadmapGeneratorService;
import com.skillos.service.RoadmapService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/roadmaps")
@RequiredArgsConstructor
public class RoadmapController {

    private final GenerationJobRepository generationJobRepository;
    private final RoadmapRepository roadmapRepository;
    private final RoadmapGeneratorService roadmapGeneratorService;
    private final RoadmapService roadmapService;
    private final ObjectMapper objectMapper;

    @PostMapping("/generate")
    public ResponseEntity<Map<String, Object>> requestGeneration(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody GenerateRoadmapRequest request) {

        // UUID without dashes is 32 chars + "gen_" = 36 chars (matches DB column length)
        String jobId = "gen_" + UUID.randomUUID().toString().replace("-", "");

        try {
            GenerationJob job = GenerationJob.builder()
                    .jobId(jobId)
                    .user(user)
                    .jobType("roadmap_generation")
                    .status("queued")
                    .inputsJson(objectMapper.writeValueAsString(request))
                    .build();

            generationJobRepository.save(job);

            // Call async service method (this returns immediately)
            roadmapGeneratorService.generateAndSaveRoadmap(job, user, request);

            Map<String, Object> response = new HashMap<>();
            response.put("job_id", jobId);
            response.put("status", "queued");
            
            return ResponseEntity.status(HttpStatus.ACCEPTED).body(response);

        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to serialize request inputs", e);
        }
    }

    @GetMapping("/generate/status/{jobId}")
    public ResponseEntity<Map<String, Object>> getGenerationStatus(@PathVariable String jobId) {
        GenerationJob job = generationJobRepository.findByJobId(jobId)
                .orElseThrow(() -> new ResourceNotFoundException("Job not found"));

        Map<String, Object> response = new HashMap<>();
        response.put("job_id", job.getJobId());
        response.put("status", job.getStatus());
        response.put("progress_percent", job.getProgressPercent());
        
        if ("complete".equals(job.getStatus())) {
            response.put("result_id", job.getResultId());
        } else if ("failed".equals(job.getStatus())) {
            response.put("error", job.getErrorMessage());
        }

        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Roadmap> getRoadmapDetails(@PathVariable Long id, @AuthenticationPrincipal User user) {
        Roadmap roadmap = roadmapRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Roadmap not found"));

        if (!roadmap.getUser().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        return ResponseEntity.ok(roadmap);
    }

    @GetMapping
    public ResponseEntity<List<Roadmap>> getUserRoadmaps(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(roadmapService.getUserRoadmaps(user));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Roadmap> updateRoadmap(
            @PathVariable Long id,
            @RequestBody UpdateRoadmapRequest request,
            @AuthenticationPrincipal User user) {
        return ResponseEntity.ok(roadmapService.updateRoadmap(id, request, user));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteRoadmap(@PathVariable Long id, @AuthenticationPrincipal User user) {
        roadmapService.deleteRoadmap(id, user);
        return ResponseEntity.noContent().build();
    }
    
    @PostMapping("/tasks/{taskId}/complete")
    public ResponseEntity<Void> completeTask(@PathVariable Long taskId, @AuthenticationPrincipal User user) {
        roadmapService.completeTask(taskId, user);
        return ResponseEntity.ok().build();
    }
}
