package com.skillos.controller;

import com.skillos.dto.request.ProjectCreateRequest;
import com.skillos.entity.GenerationJob;
import com.skillos.entity.Project;
import com.skillos.entity.User;
import com.skillos.repository.GenerationJobRepository;
import com.skillos.service.ProjectGeneratorService;
import com.skillos.service.ProjectService;
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
@RequestMapping("/api/v1/projects")
@RequiredArgsConstructor
public class ProjectController {

    private final ProjectService projectService;
    private final ProjectGeneratorService projectGeneratorService;
    private final GenerationJobRepository generationJobRepository;

    @GetMapping
    public ResponseEntity<Map<String, Object>> getUserProjects(@AuthenticationPrincipal User user) {
        List<Project> projects = projectService.getUserProjects(user.getId());
        return ResponseEntity.ok(Map.of("data", projects));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Project> getProject(
            @PathVariable Long id,
            @AuthenticationPrincipal User user) {
        Project project = projectService.getProject(id);
        if (!project.getUser().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        return ResponseEntity.ok(project);
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createProject(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody ProjectCreateRequest request) {

        // 1. Create the project
        Project project = projectService.createProject(user, request);

        // 2. Setup the async generation job
        String jobId = "gen_" + UUID.randomUUID().toString().replace("-", "");
        
        String inputsJson = String.format("{\"name\":\"%s\", \"skill_name\":\"%s\"}", 
            project.getName(), project.getSkillName());

        GenerationJob job = GenerationJob.builder()
                .jobId(jobId)
                .user(user)
                .jobType("project_generation")
                .status("queued")
                .inputsJson(inputsJson)
                .build();

        generationJobRepository.save(job);

        // 3. Trigger async generation
        projectGeneratorService.generateProjectAsync(job, user, project);

        Map<String, Object> response = new HashMap<>();
        response.put("job_id", jobId);
        response.put("project", project);
        response.put("status", "queued");

        return ResponseEntity.status(HttpStatus.ACCEPTED).body(response);
    }

    @PostMapping("/{id}/active")
    public ResponseEntity<Project> setActiveProject(
            @PathVariable Long id,
            @AuthenticationPrincipal User user) {
        Project project = projectService.setActiveProject(id, user);
        return ResponseEntity.ok(project);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProject(
            @PathVariable Long id,
            @AuthenticationPrincipal User user) {
        projectService.deleteProject(id, user);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/generate/status/{jobId}")
    public ResponseEntity<Map<String, Object>> getGenerationStatus(@PathVariable String jobId) {
        GenerationJob job = generationJobRepository.findByJobId(jobId)
                .orElseThrow(() -> new com.skillos.exception.ResourceNotFoundException("Job not found"));

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
}
