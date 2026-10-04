package com.skillos.service;

import com.skillos.entity.*;
import com.skillos.exception.ResourceNotFoundException;
import com.skillos.planner.SchedulingService;
import com.skillos.repository.DailyScheduleRepository;
import com.skillos.repository.DurationHistoryRepository;
import com.skillos.repository.PlannerTaskRepository;
import com.skillos.repository.ScheduleEntryRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Tracks real-time task execution and triggers dynamic rescheduling
 * when reality deviates significantly from the plan.
 *
 * Rules:
 *   - NEVER reschedule completed entries
 *   - NEVER move fixed events
 *   - Preserve original schedule (old version stays with is_active=false)
 *   - Notify frontend via WebSocket on reschedule (TODO: wire up in Phase 5)
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ExecutionTrackingService {

    private final ScheduleEntryRepository scheduleEntryRepository;
    private final DailyScheduleRepository dailyScheduleRepository;
    private final PlannerTaskRepository plannerTaskRepository;
    private final DurationHistoryRepository durationHistoryRepository;
    private final SchedulingService schedulingService;

    // Rescheduling is triggered if actual differs from estimated by more than this
    private static final int RESCHEDULE_THRESHOLD_MINUTES = 10;

    /**
     * Mark a schedule entry as started.
     */
    @Transactional
    public ScheduleEntry startEntry(Long entryId, User user) {
        ScheduleEntry entry = getAndValidateEntry(entryId, user);

        if (!"pending".equalsIgnoreCase(entry.getStatus())) {
            throw new IllegalStateException("Can only start a pending entry. Current status: " + entry.getStatus());
        }

        entry.setStatus("in_progress");
        entry.setActualStartTime(LocalTime.now());
        entry.setStartedAt(LocalDateTime.now());

        // Also update the planner task status
        PlannerTask task = entry.getPlannerTask();
        task.setStatus("in_progress");
        plannerTaskRepository.save(task);

        return scheduleEntryRepository.save(entry);
    }

    /**
     * Mark a schedule entry as completed and potentially trigger rescheduling.
     */
    @Transactional
    public ScheduleEntry completeEntry(Long entryId, User user, Integer actualMinutes) {
        ScheduleEntry entry = getAndValidateEntry(entryId, user);

        if (!"in_progress".equalsIgnoreCase(entry.getStatus())) {
            throw new IllegalStateException("Can only complete an in-progress entry. Current status: " + entry.getStatus());
        }

        entry.setStatus("completed");
        entry.setActualEndTime(LocalTime.now());
        entry.setActualMinutes(actualMinutes);
        entry.setCompletedAt(LocalDateTime.now());
        scheduleEntryRepository.save(entry);

        // Update planner task
        PlannerTask task = entry.getPlannerTask();
        task.setStatus("completed");
        plannerTaskRepository.save(task);

        // Record duration history
        recordDurationHistory(user, entry, actualMinutes);

        // Check if rescheduling is needed
        int deviation = actualMinutes - entry.getPlannerTask().getEstimatedMinutes();
        if (Math.abs(deviation) > RESCHEDULE_THRESHOLD_MINUTES) {
            log.info("Deviation of {} min detected. Triggering reschedule.", deviation);
            triggerReschedule(entry, user);
        }

        return entry;
    }

    /**
     * Mark a schedule entry as skipped and trigger rescheduling.
     */
    @Transactional
    public ScheduleEntry skipEntry(Long entryId, User user) {
        ScheduleEntry entry = getAndValidateEntry(entryId, user);

        if ("completed".equalsIgnoreCase(entry.getStatus())) {
            throw new IllegalStateException("Cannot skip a completed entry.");
        }

        entry.setStatus("skipped");
        entry.setCompletedAt(LocalDateTime.now());
        scheduleEntryRepository.save(entry);

        // Update planner task back to pending so it can be rescheduled
        PlannerTask task = entry.getPlannerTask();
        task.setStatus("pending");
        plannerTaskRepository.save(task);

        log.info("Entry {} skipped. Triggering reschedule.", entryId);
        triggerReschedule(entry, user);

        return entry;
    }

    /**
     * Trigger a reschedule for the remaining tasks in today's schedule.
     */
    private void triggerReschedule(ScheduleEntry triggerEntry, User user) {
        DailySchedule currentSchedule = triggerEntry.getSchedule();
        LocalDate today = currentSchedule.getScheduleDate();

        // Get remaining incomplete entries
        List<ScheduleEntry> remaining = scheduleEntryRepository
                .findByScheduleIdAndStatusIn(currentSchedule.getId(), List.of("pending"));

        if (remaining.isEmpty()) {
            log.info("No remaining pending entries to reschedule.");
            return;
        }

        // Collect the planner tasks from remaining entries
        List<PlannerTask> remainingTasks = remaining.stream()
                .map(ScheduleEntry::getPlannerTask)
                .collect(Collectors.toList());

        // Reset their status to pending so the scheduler picks them up
        for (PlannerTask task : remainingTasks) {
            task.setStatus("pending");
            plannerTaskRepository.save(task);
        }

        // Reschedule from current time
        LocalTime fromTime = LocalTime.now();
        schedulingService.reschedule(user, today, fromTime, remainingTasks);

        log.info("Rescheduled {} remaining tasks from {}", remainingTasks.size(), fromTime);
    }

    /**
     * Record duration history for estimate improvement.
     */
    private void recordDurationHistory(User user, ScheduleEntry entry, int actualMinutes) {
        DurationHistory record = DurationHistory.builder()
                .user(user)
                .plannerTask(entry.getPlannerTask())
                .estimatedMinutes(entry.getPlannerTask().getEstimatedMinutes())
                .actualMinutes(actualMinutes)
                .category(entry.getPlannerTask().getCategory())
                .build();
        durationHistoryRepository.save(record);
    }

    /**
     * Fetch and validate that the entry exists and belongs to the user.
     */
    private ScheduleEntry getAndValidateEntry(Long entryId, User user) {
        ScheduleEntry entry = scheduleEntryRepository.findById(entryId)
                .orElseThrow(() -> new ResourceNotFoundException("Schedule entry not found"));

        if (!entry.getSchedule().getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized to modify this schedule entry");
        }

        return entry;
    }
}
