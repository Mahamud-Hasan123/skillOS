package com.skillos.controller;

import com.skillos.dto.request.GanttEntryUpdateRequest;
import com.skillos.entity.GanttEntry;
import com.skillos.entity.User;
import com.skillos.service.GanttService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class GanttController {

    private final GanttService ganttService;

    @GetMapping("/projects/{projectId}/gantt")
    public ResponseEntity<Map<String, Object>> getProjectGanttEntries(
            @PathVariable Long projectId,
            @AuthenticationPrincipal User user) {
        
        List<GanttEntry> entries = ganttService.getProjectGanttEntries(projectId, user);
        return ResponseEntity.ok(Map.of("data", entries));
    }

    @PutMapping("/gantt/entries/{id}")
    public ResponseEntity<GanttEntry> updateGanttEntry(
            @PathVariable Long id,
            @AuthenticationPrincipal User user,
            @Valid @RequestBody GanttEntryUpdateRequest request) {
        
        GanttEntry entry = ganttService.updateGanttEntry(id, request, user);
        return ResponseEntity.ok(entry);
    }
}
