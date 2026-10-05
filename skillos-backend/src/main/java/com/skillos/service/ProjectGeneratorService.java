package com.skillos.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.skillos.entity.*;
import com.skillos.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProjectGeneratorService {

    private final GeminiService geminiService;
    private final GenerationJobRepository generationJobRepository;
    private final ProjectRepository projectRepository;
    private final KanbanBoardRepository kanbanBoardRepository;
    private final KanbanColumnRepository kanbanColumnRepository;
    private final KanbanCardRepository kanbanCardRepository;
    private final GanttEntryRepository ganttEntryRepository;
    private final ProjectTaskRepository projectTaskRepository;
    private final ObjectMapper objectMapper;

    @Async
    public void generateProjectAsync(GenerationJob job, User user, Project project) {
        try {
            job.setStatus("processing");
            job.setStartedAt(LocalDateTime.now());
            generationJobRepository.save(job);

            String jsonResponse = geminiService.generateProjectJson(
                    project.getName(),
                    project.getDescription(),
                    project.getDeadlineDays(),
                    project.getSkillName()
            );

            JsonNode root = objectMapper.readTree(jsonResponse);
            
            // 1. Create Gantt Entries
            JsonNode features = root.path("features");
            int ganttOrder = 0;
            for (JsonNode featureNode : features) {
                GanttEntry entry = GanttEntry.builder()
                        .project(project)
                        .featureName(featureNode.path("featureName").asText())
                        .startDay(featureNode.path("startDay").asInt(0))
                        .durationDays(featureNode.path("durationDays").asInt(1))
                        .orderIndex(ganttOrder++)
                        .build();
                ganttEntryRepository.save(entry);
            }

            // 2. Create Kanban Board & Columns
            KanbanBoard board = KanbanBoard.builder()
                    .user(user)
                    .project(project)
                    .build();
            board = kanbanBoardRepository.save(board);

            KanbanColumn todoCol = kanbanColumnRepository.save(KanbanColumn.builder().board(board).title("To Do").orderIndex(0).build());
            kanbanColumnRepository.save(KanbanColumn.builder().board(board).title("In Progress").orderIndex(1).build());
            kanbanColumnRepository.save(KanbanColumn.builder().board(board).title("Review").orderIndex(2).build());
            kanbanColumnRepository.save(KanbanColumn.builder().board(board).title("Done").orderIndex(3).build());

            // 3. Create Project Tasks & Kanban Cards
            JsonNode tasks = root.path("tasks");
            int taskOrder = 0;
            for (JsonNode taskNode : tasks) {
                String featureName = taskNode.path("featureName").asText(null);
                GanttEntry linkedGantt = null;
                
                if (featureName != null && !featureName.isEmpty() && !featureName.equals("null")) {
                    linkedGantt = ganttEntryRepository.findByProjectIdOrderByOrderIndexAsc(project.getId())
                            .stream()
                            .filter(g -> g.getFeatureName().equalsIgnoreCase(featureName))
                            .findFirst()
                            .orElse(null);
                }

                ProjectTask pt = ProjectTask.builder()
                        .project(project)
                        .ganttEntry(linkedGantt)
                        .title(taskNode.path("title").asText())
                        .description(taskNode.path("description").asText())
                        .orderIndex(taskOrder)
                        .isAiGenerated(true)
                        .xpReward(taskNode.path("xpReward").asInt(5))
                        .estimatedMinutes(taskNode.has("estimatedMinutes") ? taskNode.path("estimatedMinutes").asInt(30) : 30)
                        .priority(taskNode.has("priority") ? taskNode.path("priority").asText("medium") : "medium")
                        .build();
                pt = projectTaskRepository.save(pt);

                KanbanCard card = KanbanCard.builder()
                        .column(todoCol)
                        .projectTaskId(pt.getId())
                        .featureName(featureName)
                        .title(pt.getTitle())
                        .description(pt.getDescription())
                        .orderIndex(taskOrder)
                        .isDone(false)
                        .build();
                kanbanCardRepository.save(card);
                
                taskOrder++;
            }

            job.setStatus("complete");
            job.setProgressPercent(100);
            job.setResultId(project.getId());
            job.setCompletedAt(LocalDateTime.now());
            generationJobRepository.save(job);

        } catch (Exception e) {
            log.error("Failed to generate project", e);
            job.setStatus("failed");
            job.setErrorMessage(e.getMessage());
            job.setCompletedAt(LocalDateTime.now());
            generationJobRepository.save(job);
        }
    }
}
