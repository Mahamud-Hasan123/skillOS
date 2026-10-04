package com.skillos.controller;

import com.skillos.dto.request.KanbanCardMoveRequest;
import com.skillos.entity.KanbanBoard;
import com.skillos.entity.KanbanCard;
import com.skillos.entity.KanbanColumn;
import com.skillos.entity.User;
import com.skillos.repository.KanbanBoardRepository;
import com.skillos.repository.KanbanCardRepository;
import com.skillos.repository.KanbanColumnRepository;
import com.skillos.service.KanbanService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class KanbanController {

    private final KanbanBoardRepository kanbanBoardRepository;
    private final KanbanColumnRepository kanbanColumnRepository;
    private final KanbanCardRepository kanbanCardRepository;
    private final KanbanService kanbanService;

    @GetMapping("/projects/{projectId}/kanban")
    public ResponseEntity<Map<String, Object>> getProjectKanban(
            @PathVariable Long projectId,
            @AuthenticationPrincipal User user) {
        
        KanbanBoard board = kanbanBoardRepository.findByProjectId(projectId)
                .orElse(null);

        if (board == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", "Kanban board not found for this project"));
        }

        if (!board.getUser().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        List<KanbanColumn> columns = kanbanColumnRepository.findByBoardIdOrderByOrderIndexAsc(board.getId());
        
        Map<String, Object> response = new HashMap<>();
        response.put("board", board);
        
        List<Map<String, Object>> columnsData = columns.stream().map(col -> {
            Map<String, Object> colMap = new HashMap<>();
            colMap.put("column", col);
            colMap.put("cards", kanbanCardRepository.findByColumnIdOrderByOrderIndexAsc(col.getId()));
            return colMap;
        }).toList();

        response.put("columns", columnsData);

        return ResponseEntity.ok(response);
    }

    @PutMapping("/kanban/cards/{cardId}/move")
    public ResponseEntity<KanbanCard> moveCard(
            @PathVariable Long cardId,
            @AuthenticationPrincipal User user,
            @Valid @RequestBody KanbanCardMoveRequest request) {
        
        KanbanCard movedCard = kanbanService.moveCard(cardId, request.getTargetColumnId(), request.getTargetOrderIndex(), user);
        return ResponseEntity.ok(movedCard);
    }
}
