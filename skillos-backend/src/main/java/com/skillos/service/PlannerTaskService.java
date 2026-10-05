package com.skillos.service;

import com.skillos.dto.request.CreatePlannerTaskRequest;
import com.skillos.dto.request.UpdatePlannerTaskRequest;
import com.skillos.dto.response.PlannerTaskResponse;
import com.skillos.entity.PlannerTask;
import com.skillos.entity.Roadmap;
import com.skillos.entity.RoadmapTask;
import com.skillos.entity.User;
import com.skillos.exception.ResourceNotFoundException;
import com.skillos.repository.PlannerTaskRepository;
import com.skillos.repository.RoadmapRepository;
import com.skillos.repository.RoadmapTaskRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PlannerTaskService {

    private final PlannerTaskRepository plannerTaskRepository;
    private final RoadmapRepository roadmapRepository;
    private final RoadmapTaskRepository roadmapTaskRepository;

    public List<PlannerTaskResponse> getTasks(Long userId, String status, String priority, String category) {
        List<PlannerTask> tasks = plannerTaskRepository.findByUserId(userId);

        if (status != null) {
            List<String> statuses = java.util.Arrays.asList(status.toLowerCase().split(","));
            tasks = tasks.stream().filter(t -> t.getStatus() != null && statuses.contains(t.getStatus().toLowerCase())).collect(Collectors.toList());
        }
        if (priority != null) {
            tasks = tasks.stream().filter(t -> priority.equalsIgnoreCase(t.getPriority())).collect(Collectors.toList());
        }
        if (category != null) {
            tasks = tasks.stream().filter(t -> category.equalsIgnoreCase(t.getCategory())).collect(Collectors.toList());
        }

        return tasks.stream().map(this::toResponse).collect(Collectors.toList());
    }

    public PlannerTaskResponse createTask(User user, CreatePlannerTaskRequest request) {
        PlannerTask dependency = null;
        if (request.getDependencyTaskId() != null) {
            dependency = plannerTaskRepository.findById(request.getDependencyTaskId())
                    .orElseThrow(() -> new ResourceNotFoundException("Dependency task not found"));
            if (!dependency.getUser().getId().equals(user.getId())) {
                throw new RuntimeException("Unauthorized to set this task as dependency");
            }
        }

        PlannerTask task = PlannerTask.builder()
                .user(user)
                .sourceType("custom")
                .title(request.getTitle())
                .description(request.getDescription())
                .estimatedMinutes(request.getEstimatedMinutes() != null ? request.getEstimatedMinutes() : 30)
                .priority(request.getPriority() != null ? request.getPriority() : "medium")
                .deadline(request.getDeadline())
                .category(request.getCategory())
                .dependencyTask(dependency)
                .isRecurring(request.getIsRecurring() != null ? request.getIsRecurring() : false)
                .status("pending")
                .build();

        return toResponse(plannerTaskRepository.save(task));
    }

    public PlannerTaskResponse updateTask(Long taskId, User user, UpdatePlannerTaskRequest request) {
        PlannerTask task = plannerTaskRepository.findById(taskId)
                .orElseThrow(() -> new ResourceNotFoundException("Planner task not found"));

        if (!task.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized to update this task");
        }

        if (request.getTitle() != null) task.setTitle(request.getTitle());
        if (request.getDescription() != null) task.setDescription(request.getDescription());
        if (request.getEstimatedMinutes() != null) task.setEstimatedMinutes(request.getEstimatedMinutes());
        if (request.getPriority() != null) task.setPriority(request.getPriority());
        if (request.getDeadline() != null) task.setDeadline(request.getDeadline());
        if (request.getCategory() != null) task.setCategory(request.getCategory());
        if (request.getIsRecurring() != null) task.setIsRecurring(request.getIsRecurring());
        if (request.getStatus() != null) task.setStatus(request.getStatus());

        if (request.getDependencyTaskId() != null) {
            PlannerTask dependency = plannerTaskRepository.findById(request.getDependencyTaskId())
                    .orElseThrow(() -> new ResourceNotFoundException("Dependency task not found"));
            if (!dependency.getUser().getId().equals(user.getId())) {
                throw new RuntimeException("Unauthorized to set this task as dependency");
            }
            task.setDependencyTask(dependency);
        }

        return toResponse(plannerTaskRepository.save(task));
    }

    public void deleteTask(Long taskId, User user) {
        PlannerTask task = plannerTaskRepository.findById(taskId)
                .orElseThrow(() -> new ResourceNotFoundException("Planner task not found"));

        if (!task.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized to delete this task");
        }

        plannerTaskRepository.delete(task);
    }

    public List<PlannerTaskResponse> importFromRoadmap(Long roadmapId, User user) {
        Roadmap roadmap = roadmapRepository.findById(roadmapId)
                .orElseThrow(() -> new ResourceNotFoundException("Roadmap not found"));

        if (!roadmap.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized to import tasks from this roadmap");
        }

        List<RoadmapTask> roadmapTasks = roadmapTaskRepository.findByRoadmapIdAndDeletedAtIsNull(roadmapId);
        List<PlannerTask> importedTasks = new ArrayList<>();

        // Start deadline calculation from today, adding the dayNumber.
        // Assuming dayNumber starts at 1
        LocalDateTime baseDate = LocalDateTime.now().withHour(23).withMinute(59).withSecond(59);

        for (RoadmapTask rTask : roadmapTasks) {
            if (!"pending".equalsIgnoreCase(rTask.getStatus())) {
                continue; // Only import pending tasks
            }

            Optional<PlannerTask> existing = plannerTaskRepository
                    .findByUserIdAndSourceTypeAndSourceId(user.getId(), "roadmap", rTask.getId());

            if (existing.isPresent()) {
                continue; // Skip already imported
            }

            LocalDateTime deadline = baseDate.plusDays(rTask.getDayNumber() - 1);

            PlannerTask task = PlannerTask.builder()
                    .user(user)
                    .sourceType("roadmap")
                    .sourceId(rTask.getId())
                    .title(rTask.getTitle())
                    .description("Question: " + rTask.getQuestion())
                    .estimatedMinutes(roadmap.getDailyTimeMinutes() != null && roadmap.getDailyTimeMinutes() > 0 ? roadmap.getDailyTimeMinutes() : 30)
                    .priority("high")
                    .deadline(deadline)
                    .category(roadmap.getSkillGoal())
                    .isRecurring(false)
                    .status("pending")
                    .build();

            importedTasks.add(plannerTaskRepository.save(task));
        }

        return importedTasks.stream().map(this::toResponse).collect(Collectors.toList());
    }

    private PlannerTaskResponse toResponse(PlannerTask task) {
        return PlannerTaskResponse.builder()
                .id(task.getId())
                .sourceType(task.getSourceType())
                .sourceId(task.getSourceId())
                .title(task.getTitle())
                .description(task.getDescription())
                .estimatedMinutes(task.getEstimatedMinutes())
                .priority(task.getPriority())
                .deadline(task.getDeadline())
                .category(task.getCategory())
                .dependencyTaskId(task.getDependencyTask() != null ? task.getDependencyTask().getId() : null)
                .isRecurring(task.getIsRecurring())
                .status(task.getStatus())
                .createdAt(task.getCreatedAt())
                .updatedAt(task.getUpdatedAt())
                .build();
    }
}
