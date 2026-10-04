package com.skillos.service;

import com.skillos.entity.KanbanCard;
import com.skillos.entity.KanbanColumn;
import com.skillos.entity.ProjectTask;
import com.skillos.entity.User;
import com.skillos.repository.KanbanCardRepository;
import com.skillos.repository.KanbanColumnRepository;
import com.skillos.repository.ProjectTaskRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class KanbanService {

    private final KanbanCardRepository kanbanCardRepository;
    private final KanbanColumnRepository kanbanColumnRepository;
    private final ProjectTaskRepository projectTaskRepository;
    private final XpEngineService xpEngineService;
    private final ProjectService projectService;

    @Transactional
    public KanbanCard moveCard(Long cardId, Long targetColumnId, Integer targetOrderIndex, User user) {
        KanbanCard card = kanbanCardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));
        
        KanbanColumn oldColumn = card.getColumn();
        KanbanColumn newColumn = kanbanColumnRepository.findById(targetColumnId)
                .orElseThrow(() -> new RuntimeException("Target column not found"));

        // If moved to a new column, adjust old column indices
        if (!oldColumn.getId().equals(newColumn.getId())) {
            List<KanbanCard> oldCards = kanbanCardRepository.findByColumnIdOrderByOrderIndexAsc(oldColumn.getId());
            int order = 0;
            for (KanbanCard c : oldCards) {
                if (!c.getId().equals(card.getId())) {
                    c.setOrderIndex(order++);
                    kanbanCardRepository.save(c);
                }
            }
        }

        // Adjust new column indices to make space
        List<KanbanCard> newCards = kanbanCardRepository.findByColumnIdOrderByOrderIndexAsc(newColumn.getId());
        if (oldColumn.getId().equals(newColumn.getId())) {
            newCards.removeIf(c -> c.getId().equals(card.getId())); // remove self if same column
        }

        int targetIdx = Math.min(targetOrderIndex, newCards.size());
        newCards.add(targetIdx, card);

        for (int i = 0; i < newCards.size(); i++) {
            KanbanCard c = newCards.get(i);
            c.setOrderIndex(i);
            if (c.getId().equals(card.getId())) {
                c.setColumn(newColumn);
            }
            kanbanCardRepository.save(c);
        }

        // Handle "Done" Logic
        boolean cardWasDone = Boolean.TRUE.equals(card.getIsDone());
        boolean targetIsDone = newColumn.getTitle().equalsIgnoreCase("Done");

        if (targetIsDone && !cardWasDone) {
            card.setIsDone(true);
            kanbanCardRepository.save(card);

            if (card.getProjectTaskId() != null) {
                projectTaskRepository.findById(card.getProjectTaskId()).ifPresent(pt -> {
                    pt.setCompletedAt(LocalDateTime.now());
                    projectTaskRepository.save(pt);
                    int xp = pt.getXpReward() != null ? pt.getXpReward() : 5;
                    xpEngineService.awardXp(user, xp, "project_task", pt.getId());
                });
            }

            // Optional: Recalculate project progress
            try {
                if (newColumn.getBoard() != null && newColumn.getBoard().getProject() != null) {
                    projectService.recalculateProgress(newColumn.getBoard().getProject().getId());
                }
            } catch (Exception e) {
                // Board may not be linked to a project (e.g., roadmap board)
            }

        } else if (!targetIsDone && cardWasDone) {
            card.setIsDone(false);
            kanbanCardRepository.save(card);
            
            if (card.getProjectTaskId() != null) {
                projectTaskRepository.findById(card.getProjectTaskId()).ifPresent(pt -> {
                    pt.setCompletedAt(null); // Un-done
                    projectTaskRepository.save(pt);
                });
            }

            try {
                if (newColumn.getBoard() != null && newColumn.getBoard().getProject() != null) {
                    projectService.recalculateProgress(newColumn.getBoard().getProject().getId());
                }
            } catch (Exception e) {
                // Board may not be linked to a project
            }
        }

        return card;
    }
}
