package com.skillos.planner.model;

import com.skillos.entity.PlannerTask;

import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Represents a partial or complete schedule state during A* search.
 *
 * State definition for A*:
 *   - scheduledTasks: ordered list of tasks already placed in time slots
 *   - remainingTasks: set of tasks not yet placed
 *   - currentTime: the earliest time at which the next task can start
 *   - availableSlots: the free time windows for the day
 *   - currentSlotIndex: which available slot we are currently filling
 */
public class ScheduleState implements Comparable<ScheduleState> {

    private final List<TaskAssignment> scheduledTasks;
    private final List<PlannerTask> remainingTasks;
    private final LocalTime currentTime;
    private final List<TimeSlot> availableSlots;
    private final int currentSlotIndex;

    // A* costs
    private final double gCost; // accumulated cost so far
    private double hCost;       // heuristic estimate of remaining cost
    private double fCost;       // g + h

    public ScheduleState(
            List<TaskAssignment> scheduledTasks,
            List<PlannerTask> remainingTasks,
            LocalTime currentTime,
            List<TimeSlot> availableSlots,
            int currentSlotIndex,
            double gCost
    ) {
        this.scheduledTasks = new ArrayList<>(scheduledTasks);
        this.remainingTasks = new ArrayList<>(remainingTasks);
        this.currentTime = currentTime;
        this.availableSlots = availableSlots;
        this.currentSlotIndex = currentSlotIndex;
        this.gCost = gCost;
        this.hCost = 0;
        this.fCost = gCost;
    }

    /**
     * Create the initial state: no tasks scheduled, all tasks remaining.
     */
    public static ScheduleState initial(List<PlannerTask> tasks, List<TimeSlot> availableSlots) {
        LocalTime startTime = availableSlots.isEmpty() ? LocalTime.of(9, 0) : availableSlots.get(0).getStart();
        return new ScheduleState(
                new ArrayList<>(),
                new ArrayList<>(tasks),
                startTime,
                availableSlots,
                0,
                0.0
        );
    }

    /**
     * Check if this is a goal state: no remaining tasks or no remaining time.
     */
    public boolean isGoal() {
        return remainingTasks.isEmpty() || currentSlotIndex >= availableSlots.size();
    }

    /**
     * Get the set of task IDs already scheduled (for dependency checking).
     */
    public Set<Long> getScheduledTaskIds() {
        Set<Long> ids = new HashSet<>();
        for (TaskAssignment a : scheduledTasks) {
            ids.add(a.getTask().getId());
        }
        return ids;
    }

    /**
     * Compute the next available start time, advancing to the next slot if current is exhausted.
     * Returns null if no more time is available.
     */
    public LocalTime getEffectiveCurrentTime() {
        int idx = currentSlotIndex;
        LocalTime time = currentTime;

        while (idx < availableSlots.size()) {
            TimeSlot slot = availableSlots.get(idx);
            // If current time is before this slot starts, snap to slot start
            if (time.isBefore(slot.getStart())) {
                return slot.getStart();
            }
            // If current time is within this slot, it's valid
            if (!time.isAfter(slot.getEnd()) && time.isBefore(slot.getEnd())) {
                return time;
            }
            // Current time is past this slot, try next
            idx++;
            if (idx < availableSlots.size()) {
                time = availableSlots.get(idx).getStart();
            }
        }
        return null; // No more available time
    }

    /**
     * Get the slot index for a given time.
     */
    public int getSlotIndexForTime(LocalTime time) {
        for (int i = currentSlotIndex; i < availableSlots.size(); i++) {
            TimeSlot slot = availableSlots.get(i);
            if (!time.isBefore(slot.getStart()) && time.isBefore(slot.getEnd())) {
                return i;
            }
            if (time.isBefore(slot.getStart())) {
                return i; // Will snap to this slot's start
            }
        }
        return availableSlots.size(); // Past all slots
    }

    /**
     * Check if a task of the given duration can fit starting from the effective current time.
     */
    public boolean canFitTask(int durationMinutes) {
        LocalTime start = getEffectiveCurrentTime();
        if (start == null) return false;

        int idx = getSlotIndexForTime(start);
        if (idx >= availableSlots.size()) return false;

        TimeSlot slot = availableSlots.get(idx);
        LocalTime effectiveStart = start.isBefore(slot.getStart()) ? slot.getStart() : start;
        return slot.canFit(effectiveStart, durationMinutes);
    }

    // --- Getters ---

    public List<TaskAssignment> getScheduledTasks() {
        return scheduledTasks;
    }

    public List<PlannerTask> getRemainingTasks() {
        return remainingTasks;
    }

    public LocalTime getCurrentTime() {
        return currentTime;
    }

    public List<TimeSlot> getAvailableSlots() {
        return availableSlots;
    }

    public int getCurrentSlotIndex() {
        return currentSlotIndex;
    }

    public double getGCost() {
        return gCost;
    }

    public double getHCost() {
        return hCost;
    }

    public void setHCost(double hCost) {
        this.hCost = hCost;
        this.fCost = this.gCost + hCost;
    }

    public double getFCost() {
        return fCost;
    }

    /**
     * For the A* priority queue: lower f-cost = higher priority.
     */
    @Override
    public int compareTo(ScheduleState other) {
        return Double.compare(this.fCost, other.fCost);
    }
}
