package com.skillos.planner;

import com.skillos.entity.*;
import com.skillos.planner.astar.AStarScheduler;
import com.skillos.planner.model.ScheduleCandidate;
import com.skillos.planner.model.TaskAssignment;
import com.skillos.planner.model.TimeSlot;
import com.skillos.repository.DailyScheduleRepository;
import com.skillos.repository.PlannerTaskRepository;
import com.skillos.repository.ScheduleEntryRepository;
import com.skillos.service.GoogleCalendarService;
import com.skillos.service.UserRoutineService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Main orchestrator for the scheduling engine.
 *
 * Flow:
 *   1. Fetch user's routine for the target day of week
 *   2. Compute free time slots (available windows minus fixed events)
 *   3. Fetch eligible planner tasks (pending, due today/overdue, not blocked)
 *   4. If total task time > total free time → flag overload, still schedule what fits
 *   5. Run A* (which internally uses CSP) to find optimal sequence
 *   6. Persist as a new DailySchedule + ScheduleEntries
 *   7. Return the schedule
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SchedulingService {

    private final UserRoutineService userRoutineService;
    private final GoogleCalendarService googleCalendarService;
    private final PlannerTaskRepository plannerTaskRepository;
    private final DailyScheduleRepository dailyScheduleRepository;
    private final ScheduleEntryRepository scheduleEntryRepository;

    /**
     * Generate a new daily schedule for the given user and date.
     * If a schedule already exists for this date, it is deactivated and a new version is created.
     */
    @Transactional
    public DailySchedule generateSchedule(User user, LocalDate date) {
        Long userId = user.getId();
        int dayOfWeek = date.getDayOfWeek().getValue() % 7; // Convert Monday=1..Sunday=7 to Sunday=0..Saturday=6

        log.info("Generating schedule for user {} on {} (dayOfWeek={})", userId, date, dayOfWeek);

        // 1. Compute free time slots
        List<UserRoutineService.TimeWindow> freeWindows = userRoutineService.computeFreeSlots(userId, dayOfWeek);

        if (freeWindows.isEmpty()) {
            log.warn("No available time slots for user {} on day {}", userId, dayOfWeek);
            // Create an empty schedule
            return persistSchedule(user, date, new ScheduleCandidate(List.of(), 0.0), List.of());
        }

        // 2. Fetch Google Calendar events
        List<UserRoutineService.TimeWindow> gcalEvents = googleCalendarService.fetchBlockedTimes(user, date);
        
        List<TimeSlot> availableSlots = subtractGCalEvents(freeWindows, gcalEvents, null);

        int totalAvailableMinutes = availableSlots.stream().mapToInt(TimeSlot::durationMinutes).sum();
        log.info("Available time: {} minutes across {} slots (after GCal sync)", totalAvailableMinutes, availableSlots.size());

        // 2. Fetch eligible tasks
        List<PlannerTask> eligibleTasks = getEligibleTasks(userId, date);

        if (eligibleTasks.isEmpty()) {
            log.info("No eligible tasks to schedule for user {} on {}", userId, date);
            return persistSchedule(user, date, new ScheduleCandidate(List.of(), 0.0), gcalEvents);
        }

        int totalTaskMinutes = eligibleTasks.stream().mapToInt(PlannerTask::getEstimatedMinutes).sum();
        log.info("Eligible tasks: {} tasks requiring {} minutes", eligibleTasks.size(), totalTaskMinutes);

        if (totalTaskMinutes > totalAvailableMinutes) {
            log.warn("Task overload: {} min of tasks vs {} min available", totalTaskMinutes, totalAvailableMinutes);
        }

        // 3. Run A* search (CSP is used internally by A*)
        AStarScheduler scheduler = new AStarScheduler();
        ScheduleCandidate candidate = scheduler.search(eligibleTasks, availableSlots, date);

        log.info("Schedule generated: {} tasks placed, cost={}, warnings={}",
                candidate.getAssignments().size(),
                candidate.getTotalCost(),
                candidate.getWarnings().size());

        if (candidate.hasFeasibilityWarning()) {
            log.warn("Feasibility warning: {}", candidate.getFeasibilityWarning());
        }

        // 4. Persist
        return persistSchedule(user, date, candidate, gcalEvents);
    }

    /**
     * Resets the schedule for the given date. Deactivates the active schedule and sets
     * all associated 'scheduled' PlannerTasks back to 'pending'.
     */
    @Transactional
    public void resetSchedule(User user, LocalDate date) {
        Optional<DailySchedule> activeSchedule = dailyScheduleRepository
                .findByUserIdAndScheduleDateAndIsActive(user.getId(), date, true);
        activeSchedule.ifPresent(schedule -> {
            List<ScheduleEntry> entries = scheduleEntryRepository.findByScheduleIdOrderBySlotOrder(schedule.getId());
            for (ScheduleEntry entry : entries) {
                if (!"external".equals(entry.getSourceType()) && !"external".equals(entry.getPlannerTask().getSourceType())) {
                    PlannerTask task = entry.getPlannerTask();
                    if ("scheduled".equals(task.getStatus())) {
                        task.setStatus("pending");
                        plannerTaskRepository.save(task);
                    }
                }
            }
            schedule.setIsActive(false);
            dailyScheduleRepository.save(schedule);
        });
    }

    /**
     * Unschedules a specific PlannerTask from today's active schedule.
     */
    @Transactional
    public void unscheduleTask(User user, LocalDate date, Long plannerTaskId) {
        // 1. Revert task status
        PlannerTask task = plannerTaskRepository.findByIdAndUserId(plannerTaskId, user.getId())
                .orElseThrow(() -> new IllegalArgumentException("Task not found or doesn't belong to user"));
        if ("scheduled".equals(task.getStatus())) {
            task.setStatus("pending");
            plannerTaskRepository.save(task);
        }

        // 2. Remove from today's active schedule
        Optional<DailySchedule> activeSchedule = dailyScheduleRepository
                .findByUserIdAndScheduleDateAndIsActive(user.getId(), date, true);
        activeSchedule.ifPresent(schedule -> {
            List<ScheduleEntry> entries = scheduleEntryRepository.findByScheduleIdOrderBySlotOrder(schedule.getId());
            for (ScheduleEntry entry : entries) {
                if (entry.getPlannerTask() != null && entry.getPlannerTask().getId().equals(plannerTaskId)) {
                    scheduleEntryRepository.delete(entry);
                }
            }
        });
    }

    /**
     * Regenerate a schedule for remaining tasks only (used during rescheduling).
     * Takes the current time and only schedules tasks that haven't been completed.
     */
    @Transactional
    public DailySchedule reschedule(User user, LocalDate date, LocalTime fromTime, List<PlannerTask> remainingTasks) {
        Long userId = user.getId();
        int dayOfWeek = date.getDayOfWeek().getValue() % 7;

        log.info("Rescheduling for user {} from {} on {}", userId, fromTime, date);

        // Compute free slots but only from 'fromTime' onwards
        List<UserRoutineService.TimeWindow> freeWindows = userRoutineService.computeFreeSlots(userId, dayOfWeek);
        List<UserRoutineService.TimeWindow> gcalEvents = googleCalendarService.fetchBlockedTimes(user, date);
        List<TimeSlot> availableSlots = subtractGCalEvents(freeWindows, gcalEvents, fromTime);

        if (availableSlots.isEmpty() || remainingTasks.isEmpty()) {
            ScheduleCandidate empty = new ScheduleCandidate(List.of(), 0.0);
            remainingTasks.forEach(t -> empty.addUnscheduledTask(t.getTitle()));
            return persistSchedule(user, date, empty, googleCalendarService.fetchBlockedTimes(user, date));
        }

        AStarScheduler scheduler = new AStarScheduler();
        ScheduleCandidate candidate = scheduler.search(remainingTasks, availableSlots, date);

        return persistSchedule(user, date, candidate, gcalEvents);
    }

    /**
     * Fetch tasks that should be considered for today's schedule:
     * - Status is 'pending' or 'scheduled'
     * - Deadline is today or overdue, OR no deadline (always eligible)
     * - Dependencies are satisfied (dependency task is completed)
     */
    private List<PlannerTask> getEligibleTasks(Long userId, LocalDate date) {
        List<PlannerTask> allPending = plannerTaskRepository.findByUserIdAndStatusIn(
                userId, List.of("pending", "scheduled"));

        return allPending.stream()
                .filter(task -> {
                    // Include if: no deadline, or deadline is today or past
                    if (task.getDeadline() == null) return true;
                    return !task.getDeadline().toLocalDate().isAfter(date);
                })
                .filter(task -> {
                    // Include only if dependency is met
                    if (task.getDependencyTask() == null) return true;
                    return "completed".equalsIgnoreCase(task.getDependencyTask().getStatus());
                })
                .collect(Collectors.toList());
    }

    /**
     * Persist a schedule candidate as a DailySchedule with ScheduleEntries.
     * Deactivates any existing active schedule for this date.
     */
    private DailySchedule persistSchedule(User user, LocalDate date, ScheduleCandidate candidate, List<UserRoutineService.TimeWindow> externalEvents) {
        List<ScheduleEntry> retainedEntries = new ArrayList<>();
        
        // Deactivate existing active schedule and extract completed/skipped tasks
        Optional<DailySchedule> existingActive = dailyScheduleRepository
                .findByUserIdAndScheduleDateAndIsActive(user.getId(), date, true);
        existingActive.ifPresent(existing -> {
            List<ScheduleEntry> oldEntries = scheduleEntryRepository.findByScheduleIdOrderBySlotOrder(existing.getId());
            for (ScheduleEntry oldEntry : oldEntries) {
                if (!"external".equals(oldEntry.getSourceType()) && 
                    !oldEntry.getPlannerTask().getSourceType().equals("external") &&
                    ("completed".equals(oldEntry.getStatus()) || "skipped".equals(oldEntry.getStatus()))) {
                    retainedEntries.add(oldEntry);
                }
            }
            existing.setIsActive(false);
            dailyScheduleRepository.save(existing);
        });

        // Determine version number
        int newVersion = 1;
        Optional<DailySchedule> latestVersion = dailyScheduleRepository
                .findFirstByUserIdAndScheduleDateOrderByVersionDesc(user.getId(), date);
        if (latestVersion.isPresent()) {
            newVersion = latestVersion.get().getVersion() + 1;
        }

        // Build notes from warnings
        String notes = null;
        List<String> allNotes = new ArrayList<>();
        if (!candidate.getWarnings().isEmpty()) {
            allNotes.addAll(candidate.getWarnings());
        }
        if (candidate.hasFeasibilityWarning()) {
            allNotes.add(candidate.getFeasibilityWarning());
        }
        if (!allNotes.isEmpty()) {
            notes = String.join("; ", allNotes);
        }

        DailySchedule schedule = DailySchedule.builder()
                .user(user)
                .scheduleDate(date)
                .version(newVersion)
                .isActive(true)
                .notes(notes)
                .build();

        schedule = dailyScheduleRepository.save(schedule);

        // Create schedule entries
        List<ScheduleEntry> entries = new ArrayList<>();
        int order = 1;
        for (TaskAssignment assignment : candidate.getAssignments()) {
            ScheduleEntry entry = ScheduleEntry.builder()
                    .schedule(schedule)
                    .plannerTask(assignment.getTask())
                    .startTime(assignment.getStartTime())
                    .endTime(assignment.getEndTime())
                    .slotOrder(order++)
                    .status("pending")
                    .build();
            entries.add(scheduleEntryRepository.save(entry));

            // Update the planner task status to 'scheduled'
            PlannerTask task = assignment.getTask();
            task.setStatus("scheduled");
            plannerTaskRepository.save(task);
        }

        // Copy retained historical entries
        for (ScheduleEntry oldEntry : retainedEntries) {
            ScheduleEntry copiedEntry = ScheduleEntry.builder()
                    .schedule(schedule)
                    .plannerTask(oldEntry.getPlannerTask())
                    .title(oldEntry.getTitle())
                    .sourceType(oldEntry.getSourceType())
                    .startTime(oldEntry.getStartTime())
                    .endTime(oldEntry.getEndTime())
                    .slotOrder(order++)
                    .status(oldEntry.getStatus())
                    .actualStartTime(oldEntry.getActualStartTime())
                    .actualEndTime(oldEntry.getActualEndTime())
                    .actualMinutes(oldEntry.getActualMinutes())
                    .startedAt(oldEntry.getStartedAt())
                    .completedAt(oldEntry.getCompletedAt())
                    .build();
            entries.add(scheduleEntryRepository.save(copiedEntry));
        }

        // Add external events (GCal) to the schedule entries
        for (UserRoutineService.TimeWindow extEvent : externalEvents) {
            // Create a ghost PlannerTask to satisfy the database NOT NULL constraint
            PlannerTask ghostTask = PlannerTask.builder()
                    .user(user)
                    .sourceType("external")
                    .title(extEvent.label != null ? extEvent.label : "Busy")
                    .status("completed") // Mark as completed so A* ignores it next time
                    .estimatedMinutes(extEvent.durationMinutes())
                    .category("google_calendar")
                    .build();
            ghostTask = plannerTaskRepository.save(ghostTask);

            ScheduleEntry entry = ScheduleEntry.builder()
                    .schedule(schedule)
                    .plannerTask(ghostTask)
                    .title(extEvent.label)
                    .sourceType(extEvent.sourceType) // "google_calendar"
                    .startTime(extEvent.start)
                    .endTime(extEvent.end)
                    .slotOrder(order++)
                    .status("completed") // Mark as completed so we don't track time for them
                    .build();
            entries.add(scheduleEntryRepository.save(entry));
        }

        // Sort all entries by start time to keep slotOrder mathematically correct if needed later
        entries.sort((a, b) -> a.getStartTime().compareTo(b.getStartTime()));
        for (int i = 0; i < entries.size(); i++) {
            entries.get(i).setSlotOrder(i + 1);
            scheduleEntryRepository.save(entries.get(i));
        }

        schedule.setEntries(entries);
        return schedule;
    }

    private List<TimeSlot> subtractGCalEvents(List<UserRoutineService.TimeWindow> freeWindows, List<UserRoutineService.TimeWindow> gcalEvents, LocalTime fromTime) {
        List<TimeSlot> availableSlots = new ArrayList<>();
        for (UserRoutineService.TimeWindow free : freeWindows) {
            List<UserRoutineService.TimeWindow> currentSlots = new ArrayList<>();
            currentSlots.add(free);
            
            for (UserRoutineService.TimeWindow gcalEvent : gcalEvents) {
                List<UserRoutineService.TimeWindow> nextSlots = new ArrayList<>();
                for (UserRoutineService.TimeWindow slot : currentSlots) {
                    if (gcalEvent.end.isBefore(slot.start) || gcalEvent.end.equals(slot.start) || 
                        gcalEvent.start.isAfter(slot.end) || gcalEvent.start.equals(slot.end)) {
                        nextSlots.add(slot);
                    } else {
                        if (gcalEvent.start.isAfter(slot.start)) {
                            nextSlots.add(new UserRoutineService.TimeWindow(slot.start, gcalEvent.start));
                        }
                        if (gcalEvent.end.isBefore(slot.end)) {
                            nextSlots.add(new UserRoutineService.TimeWindow(gcalEvent.end, slot.end));
                        }
                    }
                }
                currentSlots = nextSlots;
            }
            
            for (UserRoutineService.TimeWindow w : currentSlots) {
                LocalTime effectiveStart = w.start;
                if (fromTime != null && w.start.isBefore(fromTime)) {
                    effectiveStart = fromTime;
                }
                if (effectiveStart.isBefore(w.end)) {
                    availableSlots.add(new TimeSlot(effectiveStart, w.end));
                }
            }
        }
        return availableSlots;
    }
}
