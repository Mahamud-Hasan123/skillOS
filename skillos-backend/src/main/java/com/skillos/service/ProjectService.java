package com.skillos.service;

import com.skillos.dto.request.ProjectCreateRequest;
import com.skillos.entity.Project;
import com.skillos.entity.User;
import com.skillos.repository.ProjectRepository;
import com.skillos.repository.KanbanCardRepository;
import com.skillos.repository.KanbanColumnRepository;
import com.skillos.entity.KanbanColumn;
import com.skillos.entity.KanbanCard;
import com.skillos.entity.KanbanBoard;
import com.skillos.repository.KanbanBoardRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ProjectService {

    private final ProjectRepository projectRepository;
    private final KanbanBoardRepository kanbanBoardRepository;
    private final KanbanColumnRepository kanbanColumnRepository;
    private final KanbanCardRepository kanbanCardRepository;

    public List<Project> getUserProjects(Long userId) {
        return projectRepository.findByUserIdAndDeletedAtIsNull(userId);
    }

    public Project getProject(Long id) {
        return projectRepository.findById(id).orElseThrow(() -> new RuntimeException("Project not found"));
    }

    public Project createProject(User user, ProjectCreateRequest request) {
        // Enforce max 1 active project rule
        List<Project> activeProjects = projectRepository.findByUserIdAndStatusAndDeletedAtIsNull(user.getId(), "active");
        for (Project p : activeProjects) {
            p.setStatus("archived");
            projectRepository.save(p);
        }

        Project project = Project.builder()
                .user(user)
                .name(request.getName())
                .description(request.getDescription())
                .skillName(request.getSkillName())
                .deadlineDays(request.getDeadlineDays())
                .startDate(LocalDate.now())
                .dueDate(LocalDate.now().plusDays(request.getDeadlineDays()))
                .color(request.getColor() != null ? request.getColor() : "blue")
                .status("active")
                .progressPercent(BigDecimal.ZERO)
                .build();

        return projectRepository.save(project);
    }

    public Project setActiveProject(Long id, User user) {
        Project project = getProject(id);
        if (!project.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Not authorized");
        }

        List<Project> activeProjects = projectRepository.findByUserIdAndStatusAndDeletedAtIsNull(user.getId(), "active");
        for (Project p : activeProjects) {
            if (!p.getId().equals(id)) {
                p.setStatus("archived");
                projectRepository.save(p);
            }
        }

        project.setStatus("active");
        return projectRepository.save(project);
    }

    public void deleteProject(Long id, User user) {
        Project project = getProject(id);
        if (!project.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Not authorized");
        }
        project.setDeletedAt(java.time.LocalDateTime.now());
        projectRepository.save(project);
    }

    public void recalculateProgress(Long projectId) {
        Project project = getProject(projectId);
        KanbanBoard board = kanbanBoardRepository.findByProjectId(projectId).orElse(null);
        
        if (board == null) return;

        List<KanbanColumn> columns = kanbanColumnRepository.findByBoardIdOrderByOrderIndexAsc(board.getId());
        
        int totalCards = 0;
        int doneCards = 0;

        for (KanbanColumn column : columns) {
            List<KanbanCard> cards = kanbanCardRepository.findByColumnIdOrderByOrderIndexAsc(column.getId());
            totalCards += cards.size();
            if (column.getTitle().equalsIgnoreCase("Done")) {
                doneCards += cards.size();
            }
        }

        if (totalCards > 0) {
            double percent = ((double) doneCards / totalCards) * 100.0;
            project.setProgressPercent(BigDecimal.valueOf(percent).setScale(2, RoundingMode.HALF_UP));
            if (doneCards == totalCards) {
                project.setStatus("completed");
            }
        } else {
            project.setProgressPercent(BigDecimal.ZERO);
        }

        projectRepository.save(project);
    }
}
