package com.skillos.service;

import com.skillos.dto.response.PlannerDashboardResponse;
import com.skillos.dto.response.ScheduleEntryResponse;
import com.skillos.entity.DailySchedule;
import com.skillos.entity.DurationHistory;
import com.skillos.entity.ScheduleEntry;
import com.skillos.repository.DailyScheduleRepository;
import com.skillos.repository.DurationHistoryRepository;
import com.skillos.repository.ScheduleEntryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PlannerDashboardService {

    private final DailyScheduleRepository dailyScheduleRepository;
    private final ScheduleEntryRepository scheduleEntryRepository;
    private final DurationHistoryRepository durationHistoryRepository;

    public PlannerDashboardResponse getDashboard(Long userId) {
        LocalDate today = LocalDate.now();

        // Today's schedule
        PlannerDashboardResponse.TodaySchedule todaySchedule = buildTodaySchedule(userId, today);

        // Estimate accuracy
        PlannerDashboardResponse.EstimateAccuracy accuracy = buildEstimateAccuracy(userId);

        // Next task
        PlannerDashboardResponse.NextTask nextTask = buildNextTask(userId, today);

        return PlannerDashboardResponse.builder()
                .today(todaySchedule)
                .estimateAccuracy(accuracy)
                .nextTask(nextTask)
                .build();
    }

    private PlannerDashboardResponse.TodaySchedule buildTodaySchedule(Long userId, LocalDate today) {
        Optional<DailySchedule> activeSchedule = dailyScheduleRepository
                .findByUserIdAndScheduleDateAndIsActive(userId, today, true);

        if (activeSchedule.isEmpty()) {
            return PlannerDashboardResponse.TodaySchedule.builder()
                    .date(today)
                    .scheduleVersion(0)
                    .totalTasks(0)
                    .completed(0)
                    .inProgress(0)
                    .remaining(0)
                    .skipped(0)
                    .entries(List.of())
                    .build();
        }

        DailySchedule schedule = activeSchedule.get();
        List<ScheduleEntry> entries = scheduleEntryRepository
                .findByScheduleIdOrderBySlotOrder(schedule.getId());

        int completed = 0, inProgress = 0, remaining = 0, skipped = 0;
        for (ScheduleEntry entry : entries) {
            switch (entry.getStatus().toLowerCase()) {
                case "completed" -> completed++;
                case "in_progress" -> inProgress++;
                case "skipped" -> skipped++;
                default -> remaining++;
            }
        }

        List<ScheduleEntryResponse> entryResponses = entries.stream()
                .map(this::toEntryResponse)
                .collect(Collectors.toList());

        return PlannerDashboardResponse.TodaySchedule.builder()
                .date(today)
                .scheduleVersion(schedule.getVersion())
                .totalTasks(entries.size())
                .completed(completed)
                .inProgress(inProgress)
                .remaining(remaining)
                .skipped(skipped)
                .feasibilityWarning(schedule.getNotes())
                .entries(entryResponses)
                .build();
    }

    private PlannerDashboardResponse.EstimateAccuracy buildEstimateAccuracy(Long userId) {
        List<DurationHistory> history = durationHistoryRepository.findByUserId(userId);

        if (history.isEmpty()) {
            return PlannerDashboardResponse.EstimateAccuracy.builder()
                    .averageDeviationMinutes(0.0)
                    .totalTasksTracked(0L)
                    .overrunPercentage(0.0)
                    .build();
        }

        double totalDeviation = 0;
        long overruns = 0;

        for (DurationHistory record : history) {
            totalDeviation += Math.abs(record.getActualMinutes() - record.getEstimatedMinutes());
            if (record.getActualMinutes() > record.getEstimatedMinutes()) {
                overruns++;
            }
        }

        double avgDeviation = totalDeviation / history.size();
        double overrunPct = (overruns * 100.0) / history.size();

        return PlannerDashboardResponse.EstimateAccuracy.builder()
                .averageDeviationMinutes(Math.round(avgDeviation * 10.0) / 10.0)
                .totalTasksTracked((long) history.size())
                .overrunPercentage(Math.round(overrunPct * 10.0) / 10.0)
                .build();
    }

    private PlannerDashboardResponse.NextTask buildNextTask(Long userId, LocalDate today) {
        Optional<DailySchedule> activeSchedule = dailyScheduleRepository
                .findByUserIdAndScheduleDateAndIsActive(userId, today, true);

        if (activeSchedule.isEmpty()) return null;

        List<ScheduleEntry> entries = scheduleEntryRepository
                .findByScheduleIdOrderBySlotOrder(activeSchedule.get().getId());

        // Find the first pending or in_progress entry
        for (ScheduleEntry entry : entries) {
            if ("pending".equalsIgnoreCase(entry.getStatus()) || "in_progress".equalsIgnoreCase(entry.getStatus())) {
                return PlannerDashboardResponse.NextTask.builder()
                        .id(entry.getId())
                        .title(entry.getPlannerTask().getTitle())
                        .startTime(entry.getStartTime().toString())
                        .estimatedMinutes(entry.getPlannerTask().getEstimatedMinutes())
                        .build();
            }
        }

        return null; // All tasks completed or skipped
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
