package com.skillos.service;

import com.skillos.dto.request.CreateRoutineRequest;
import com.skillos.dto.request.UpdateRoutineRequest;
import com.skillos.dto.response.RoutineResponse;
import com.skillos.entity.User;
import com.skillos.entity.UserRoutine;
import com.skillos.exception.ResourceNotFoundException;
import com.skillos.repository.UserRoutineRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserRoutineService {

    private final UserRoutineRepository userRoutineRepository;

    /**
     * Get all routine slots for a user.
     */
    public List<RoutineResponse> getUserRoutines(Long userId) {
        return userRoutineRepository.findByUserId(userId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    /**
     * Get routine slots for a specific day of the week.
     */
    public List<RoutineResponse> getRoutinesByDay(Long userId, Integer dayOfWeek) {
        return userRoutineRepository.findByUserIdAndDayOfWeek(userId, dayOfWeek).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    /**
     * Create a new routine slot (availability window or fixed event).
     * Validates that the new slot doesn't overlap with existing slots on the same day.
     */
    public RoutineResponse createRoutine(User user, CreateRoutineRequest request) {
        validateTimeRange(request.getStartTime(), request.getEndTime());
        validateNoOverlap(user.getId(), request.getDayOfWeek(), request.getStartTime(), request.getEndTime(), null);

        UserRoutine routine = UserRoutine.builder()
                .user(user)
                .dayOfWeek(request.getDayOfWeek())
                .startTime(request.getStartTime())
                .endTime(request.getEndTime())
                .isAvailable(request.getIsAvailable() != null ? request.getIsAvailable() : true)
                .label(request.getLabel())
                .build();

        return toResponse(userRoutineRepository.save(routine));
    }

    /**
     * Update an existing routine slot.
     */
    public RoutineResponse updateRoutine(Long routineId, User user, UpdateRoutineRequest request) {
        UserRoutine routine = userRoutineRepository.findById(routineId)
                .orElseThrow(() -> new ResourceNotFoundException("Routine not found"));

        if (!routine.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized to update this routine");
        }

        if (request.getDayOfWeek() != null) routine.setDayOfWeek(request.getDayOfWeek());
        if (request.getStartTime() != null) routine.setStartTime(request.getStartTime());
        if (request.getEndTime() != null) routine.setEndTime(request.getEndTime());
        if (request.getIsAvailable() != null) routine.setIsAvailable(request.getIsAvailable());
        if (request.getLabel() != null) routine.setLabel(request.getLabel());

        validateTimeRange(routine.getStartTime(), routine.getEndTime());
        validateNoOverlap(user.getId(), routine.getDayOfWeek(), routine.getStartTime(), routine.getEndTime(), routineId);

        return toResponse(userRoutineRepository.save(routine));
    }

    /**
     * Delete a routine slot.
     */
    public void deleteRoutine(Long routineId, User user) {
        UserRoutine routine = userRoutineRepository.findById(routineId)
                .orElseThrow(() -> new ResourceNotFoundException("Routine not found"));

        if (!routine.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized to delete this routine");
        }

        userRoutineRepository.delete(routine);
    }

    /**
     * Compute free time slots for a given day by subtracting fixed events from available windows.
     * Returns a list of TimeSlot-like responses representing usable time for scheduling.
     * This method is used by the scheduling engine (Phase 3).
     */
    public List<TimeWindow> computeFreeSlots(Long userId, Integer dayOfWeek) {
        List<UserRoutine> availableWindows = userRoutineRepository
                .findByUserIdAndDayOfWeekAndIsAvailable(userId, dayOfWeek, true);
        List<UserRoutine> fixedEvents = userRoutineRepository
                .findByUserIdAndDayOfWeekAndIsAvailable(userId, dayOfWeek, false);

        if (availableWindows.isEmpty()) {
            return List.of();
        }

        // Sort available windows by start time
        availableWindows.sort(Comparator.comparing(UserRoutine::getStartTime));
        fixedEvents.sort(Comparator.comparing(UserRoutine::getStartTime));

        List<TimeWindow> freeSlots = new ArrayList<>();

        for (UserRoutine window : availableWindows) {
            // Start with the full available window, then subtract each fixed event that overlaps
            List<TimeWindow> windowSlots = new ArrayList<>();
            windowSlots.add(new TimeWindow(window.getStartTime(), window.getEndTime()));

            for (UserRoutine event : fixedEvents) {
                List<TimeWindow> newSlots = new ArrayList<>();
                for (TimeWindow slot : windowSlots) {
                    newSlots.addAll(subtractEvent(slot, event.getStartTime(), event.getEndTime()));
                }
                windowSlots = newSlots;
            }

            freeSlots.addAll(windowSlots);
        }

        return freeSlots;
    }

    // --- Validation helpers ---

    private void validateTimeRange(LocalTime start, LocalTime end) {
        if (start != null && end != null && !end.isAfter(start)) {
            throw new IllegalArgumentException("End time must be after start time");
        }
    }

    private void validateNoOverlap(Long userId, Integer dayOfWeek, LocalTime start, LocalTime end, Long excludeId) {
        List<UserRoutine> existing = userRoutineRepository.findByUserIdAndDayOfWeek(userId, dayOfWeek);

        for (UserRoutine r : existing) {
            // Skip the routine being updated
            if (excludeId != null && r.getId().equals(excludeId)) continue;

            // Check overlap: two ranges overlap if one starts before the other ends
            if (start.isBefore(r.getEndTime()) && end.isAfter(r.getStartTime())) {
                throw new IllegalArgumentException(
                        "Time slot overlaps with existing routine: " + r.getLabel()
                                + " (" + r.getStartTime() + " - " + r.getEndTime() + ")");
            }
        }
    }

    /**
     * Subtract a fixed event from a free time window.
     * Returns 0, 1, or 2 remaining windows depending on overlap.
     */
    private List<TimeWindow> subtractEvent(TimeWindow slot, LocalTime eventStart, LocalTime eventEnd) {
        List<TimeWindow> result = new ArrayList<>();

        // No overlap — event is entirely outside the slot
        if (!eventStart.isBefore(slot.end) || !eventEnd.isAfter(slot.start)) {
            result.add(slot);
            return result;
        }

        // Part before the event
        if (eventStart.isAfter(slot.start)) {
            result.add(new TimeWindow(slot.start, eventStart));
        }

        // Part after the event
        if (eventEnd.isBefore(slot.end)) {
            result.add(new TimeWindow(eventEnd, slot.end));
        }

        return result;
    }

    private RoutineResponse toResponse(UserRoutine routine) {
        return RoutineResponse.builder()
                .id(routine.getId())
                .dayOfWeek(routine.getDayOfWeek())
                .startTime(routine.getStartTime())
                .endTime(routine.getEndTime())
                .isAvailable(routine.getIsAvailable())
                .label(routine.getLabel())
                .createdAt(routine.getCreatedAt())
                .updatedAt(routine.getUpdatedAt())
                .build();
    }

    // --- Inner class for free slot computation ---

    /**
     * Simple time window record used internally and by the scheduling engine.
     */
    public static class TimeWindow {
        public final LocalTime start;
        public final LocalTime end;
        public final boolean isAvailable;
        public final String label;
        public final String sourceType;

        public TimeWindow(LocalTime start, LocalTime end) {
            this(start, end, true, null, "routine");
        }

        public TimeWindow(LocalTime start, LocalTime end, boolean isAvailable, String label, String sourceType) {
            this.start = start;
            this.end = end;
            this.isAvailable = isAvailable;
            this.label = label;
            this.sourceType = sourceType;
        }

        public int durationMinutes() {
            return (int) java.time.Duration.between(start, end).toMinutes();
        }

        @Override
        public String toString() {
            return start + " - " + end + (label != null ? " (" + label + ")" : "");
        }
    }
}
