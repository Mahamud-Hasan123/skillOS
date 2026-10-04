package com.skillos.planner.astar;

import com.skillos.entity.PlannerTask;
import com.skillos.planner.model.ScheduleState;
import com.skillos.planner.model.TimeSlot;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

/**
 * Admissible heuristic for the A* scheduler.
 *
 * h(n) estimates the MINIMUM remaining penalty from the current state to the goal.
 * It must NEVER overestimate (admissibility requirement) for A* to find the optimal solution.
 *
 * Penalty sources:
 *   - Missed deadlines:  Heavy penalty (100 per task)
 *   - Priority inversion: Not estimated in heuristic (0 — safe underestimate)
 *   - Gaps:               Not estimated in heuristic (0 — safe underestimate)
 *
 * This keeps h(n) simple and admissible. The heuristic counts only tasks whose
 * deadlines are impossible to meet given the remaining available time.
 */
public class ScheduleHeuristic {

    // Must match the penalty used in AStarScheduler.calculateTransitionCost()
    private static final double MISSED_DEADLINE_PENALTY = 100.0;

    /**
     * Estimate the minimum remaining cost from this state to a goal state.
     *
     * We count how many remaining tasks have deadlines that cannot possibly be met,
     * because their deadline is before the earliest time they could be scheduled.
     *
     * @param state    The current partial schedule state
     * @param endOfDay The end-of-day cutoff for deadline evaluation
     * @return         Admissible (never overestimates) h(n) value
     */
    public double estimate(ScheduleState state, LocalDateTime endOfDay) {
        if (state.isGoal()) return 0.0;

        double h = 0.0;
        LocalTime effectiveTime = state.getEffectiveCurrentTime();

        if (effectiveTime == null) {
            // No more time available — every remaining task with a deadline today is missed
            for (PlannerTask task : state.getRemainingTasks()) {
                if (task.getDeadline() != null && !task.getDeadline().isAfter(endOfDay)) {
                    h += MISSED_DEADLINE_PENALTY;
                }
            }
            return h;
        }

        // Calculate total remaining available minutes
        int remainingMinutes = 0;
        List<TimeSlot> slots = state.getAvailableSlots();
        for (int i = state.getCurrentSlotIndex(); i < slots.size(); i++) {
            TimeSlot slot = slots.get(i);
            LocalTime slotStart = (i == state.getCurrentSlotIndex() && effectiveTime.isAfter(slot.getStart()))
                    ? effectiveTime
                    : slot.getStart();
            if (slotStart.isBefore(slot.getEnd())) {
                remainingMinutes += (int) java.time.Duration.between(slotStart, slot.getEnd()).toMinutes();
            }
        }

        // Accumulate estimated times of remaining tasks sorted by deadline urgency
        // If cumulative time exceeds remaining minutes, those tasks are guaranteed to be missed
        int cumulativeMinutes = 0;
        List<PlannerTask> deadlineTasks = state.getRemainingTasks().stream()
                .filter(t -> t.getDeadline() != null && !t.getDeadline().isAfter(endOfDay))
                .sorted((a, b) -> a.getDeadline().compareTo(b.getDeadline()))
                .toList();

        for (PlannerTask task : deadlineTasks) {
            cumulativeMinutes += task.getEstimatedMinutes();
            if (cumulativeMinutes > remainingMinutes) {
                h += MISSED_DEADLINE_PENALTY;
            }
        }

        return h;
    }
}
