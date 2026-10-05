package com.skillos.controller;

import com.skillos.dto.request.CompleteEntryRequest;
import com.skillos.dto.request.GenerateScheduleRequest;
import com.skillos.dto.response.DailyScheduleResponse;
import com.skillos.dto.response.ScheduleEntryResponse;
import com.skillos.entity.DailySchedule;
import com.skillos.entity.ScheduleEntry;
import com.skillos.entity.User;
import com.skillos.exception.ResourceNotFoundException;
import com.skillos.planner.SchedulingService;
import com.skillos.repository.DailyScheduleRepository;
import com.skillos.service.ExecutionTrackingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/planner/schedule")
@RequiredArgsConstructor
public class ScheduleController {

    private final SchedulingService schedulingService;
    private final DailyScheduleRepository dailyScheduleRepository;
    private final ExecutionTrackingService executionTrackingService;

    /**
     * Generate (or regenerate) a daily schedule for the given date.
     */
    @PostMapping("/generate")
    public ResponseEntity<DailyScheduleResponse> generateSchedule(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody GenerateScheduleRequest request) {
        DailySchedule schedule = schedulingService.generateSchedule(user, request.getDate());
        return ResponseEntity.status(HttpStatus.CREATED).body(toResponse(schedule));
    }

    /**
     * Get the currently active schedule for a given date.
     */
    @GetMapping("/{date}")
    public ResponseEntity<DailyScheduleResponse> getSchedule(
            @AuthenticationPrincipal User user,
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        DailySchedule schedule = dailyScheduleRepository
                .findByUserIdAndScheduleDateAndIsActive(user.getId(), date, true)
                .orElseThrow(() -> new ResourceNotFoundException("No active schedule found for " + date));
        return ResponseEntity.ok(toResponse(schedule));
    }

    /**
     * Reset the schedule for a given date.
     */
    @DeleteMapping("/{date}/reset")
    public ResponseEntity<Void> resetSchedule(
            @AuthenticationPrincipal User user,
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        schedulingService.resetSchedule(user, date);
        return ResponseEntity.noContent().build();
    }

    /**
     * Get all schedule versions (revision history) for a given date.
     */
    @GetMapping("/{date}/history")
    public ResponseEntity<Map<String, Object>> getScheduleHistory(
            @AuthenticationPrincipal User user,
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        List<DailySchedule> versions = dailyScheduleRepository
                .findByUserIdAndScheduleDateOrderByVersionDesc(user.getId(), date);
        List<DailyScheduleResponse> responses = versions.stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(Map.of("data", responses));
    }

    /**
     * Unschedule a specific PlannerTask from today's schedule.
     */
    @DeleteMapping("/{date}/tasks/{plannerTaskId}/unschedule")
    public ResponseEntity<Void> unscheduleTask(
            @AuthenticationPrincipal User user,
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @PathVariable Long plannerTaskId) {
        schedulingService.unscheduleTask(user, date, plannerTaskId);
        return ResponseEntity.noContent().build();
    }

    // --- Execution tracking endpoints ---

    /**
     * Mark a schedule entry as started.
     */
    @PostMapping("/entries/{entryId}/start")
    public ResponseEntity<ScheduleEntryResponse> startEntry(
            @PathVariable Long entryId,
            @AuthenticationPrincipal User user) {
        ScheduleEntry entry = executionTrackingService.startEntry(entryId, user);
        return ResponseEntity.ok(toEntryResponse(entry));
    }

    /**
     * Mark a schedule entry as completed.
     */
    @PostMapping("/entries/{entryId}/complete")
    public ResponseEntity<ScheduleEntryResponse> completeEntry(
            @PathVariable Long entryId,
            @AuthenticationPrincipal User user,
            @Valid @RequestBody CompleteEntryRequest request) {
        ScheduleEntry entry = executionTrackingService.completeEntry(entryId, user, request.getActualMinutes());
        return ResponseEntity.ok(toEntryResponse(entry));
    }

    /**
     * Mark a schedule entry as skipped.
     */
    @PostMapping("/entries/{entryId}/skip")
    public ResponseEntity<ScheduleEntryResponse> skipEntry(
            @PathVariable Long entryId,
            @AuthenticationPrincipal User user) {
        ScheduleEntry entry = executionTrackingService.skipEntry(entryId, user);
        return ResponseEntity.ok(toEntryResponse(entry));
    }

    // --- Mapping helpers ---

    private DailyScheduleResponse toResponse(DailySchedule schedule) {
        List<ScheduleEntryResponse> entries = List.of();
        if (schedule.getEntries() != null) {
            entries = schedule.getEntries().stream()
                    .map(this::toEntryResponse)
                    .collect(Collectors.toList());
        }

        return DailyScheduleResponse.builder()
                .id(schedule.getId())
                .scheduleDate(schedule.getScheduleDate())
                .version(schedule.getVersion())
                .isActive(schedule.getIsActive())
                .generatedAt(schedule.getGeneratedAt())
                .notes(schedule.getNotes())
                .entries(entries)
                .build();
    }

    private ScheduleEntryResponse toEntryResponse(ScheduleEntry entry) {
        return ScheduleEntryResponse.builder()
                .id(entry.getId())
                .plannerTaskId(entry.getPlannerTask().getId())
                .taskTitle(entry.getPlannerTask().getTitle())
                .sourceType(entry.getPlannerTask().getSourceType())
                .startTime(entry.getStartTime())
                .endTime(entry.getEndTime())
                .slotOrder(entry.getSlotOrder())
                .status(entry.getStatus())
                .estimatedMinutes(entry.getPlannerTask().getEstimatedMinutes())
                .actualStartTime(entry.getActualStartTime())
                .actualEndTime(entry.getActualEndTime())
                .actualMinutes(entry.getActualMinutes())
                .startedAt(entry.getStartedAt())
                .completedAt(entry.getCompletedAt())
                .build();
    }
}
