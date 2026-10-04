package com.skillos.controller;

import com.skillos.dto.request.CreatePlannerTaskRequest;
import com.skillos.dto.request.UpdatePlannerTaskRequest;
import com.skillos.dto.response.PlannerTaskResponse;
import com.skillos.entity.User;
import com.skillos.service.PlannerTaskService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/planner/tasks")
@RequiredArgsConstructor
public class PlannerTaskController {

    private final PlannerTaskService plannerTaskService;

    @GetMapping
    public ResponseEntity<Map<String, Object>> getTasks(
            @AuthenticationPrincipal User user,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String priority,
            @RequestParam(required = false) String category) {
        List<PlannerTaskResponse> tasks = plannerTaskService.getTasks(user.getId(), status, priority, category);
        return ResponseEntity.ok(Map.of("data", tasks));
    }

    @PostMapping
    public ResponseEntity<PlannerTaskResponse> createTask(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody CreatePlannerTaskRequest request) {
        PlannerTaskResponse created = plannerTaskService.createTask(user, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<PlannerTaskResponse> updateTask(
            @PathVariable Long id,
            @AuthenticationPrincipal User user,
            @Valid @RequestBody UpdatePlannerTaskRequest request) {
        PlannerTaskResponse updated = plannerTaskService.updateTask(id, user, request);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTask(
            @PathVariable Long id,
            @AuthenticationPrincipal User user) {
        plannerTaskService.deleteTask(id, user);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/import/roadmap/{roadmapId}")
    public ResponseEntity<Map<String, Object>> importFromRoadmap(
            @PathVariable Long roadmapId,
            @AuthenticationPrincipal User user) {
        List<PlannerTaskResponse> importedTasks = plannerTaskService.importFromRoadmap(roadmapId, user);
        return ResponseEntity.ok(Map.of(
                "message", "Successfully imported " + importedTasks.size() + " tasks.",
                "data", importedTasks
        ));
    }
}
