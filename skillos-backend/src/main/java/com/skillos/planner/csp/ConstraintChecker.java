package com.skillos.planner.csp;

import com.skillos.entity.PlannerTask;
import com.skillos.planner.model.ScheduleState;
import com.skillos.planner.model.TaskAssignment;
import com.skillos.planner.model.TimeSlot;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

/**
 * CSP (Constraint Satisfaction Problem) checker for the scheduling engine.
 *
 * This is a FILTER, not an optimizer. It answers: "Is this assignment valid?"
 * It checks hard constraints but does not rank solutions.
 *
 * Constraints enforced:
 *   C1 - No overlap:        No two tasks occupy the same time
 *   C2 - Available windows: Tasks can only be placed within available time slots
 *   C3 - Fixed events:      Never schedule over fixed events (handled upstream by free slot computation)
 *   C4 - Dependencies:      If task B depends on task A, A must be scheduled before B
 *   C5 - Deadlines:         Tasks with a deadline today must be included
 *   C6 - Duration fit:      A task's estimated_minutes must fit entirely within its assigned slot
 */
public class ConstraintChecker {

    /**
     * Check if scheduling a specific task at a specific time is valid
     * given the current state.
     *
     * @param state   The current partial schedule state
     * @param task    The task to schedule next
     * @param start   Proposed start time
     * @param end     Proposed end time
     * @return        Result with pass/fail and list of violations
     */
    public ConstraintResult check(ScheduleState state, PlannerTask task, LocalTime start, LocalTime end) {
        List<String> violations = new ArrayList<>();

        // C1: No overlap with already scheduled tasks
        for (TaskAssignment existing : state.getScheduledTasks()) {
            if (start.isBefore(existing.getEndTime()) && end.isAfter(existing.getStartTime())) {
                violations.add("C1_OVERLAP: Task '" + task.getTitle()
                        + "' overlaps with '" + existing.getTask().getTitle() + "'");
            }
        }

        // C2 + C6: Must fit entirely within an available time slot
        boolean fitsInSlot = false;
        for (TimeSlot slot : state.getAvailableSlots()) {
            if (slot.canFit(start, task.getEstimatedMinutes())) {
                fitsInSlot = true;
                break;
            }
        }
        if (!fitsInSlot) {
            violations.add("C2_NO_FIT: Task '" + task.getTitle()
                    + "' (" + task.getEstimatedMinutes() + " min) does not fit in any available slot at " + start);
        }

        // C4: Dependency check — if this task has a dependency, it must already be scheduled
        if (task.getDependencyTask() != null) {
            Set<Long> scheduledIds = state.getScheduledTaskIds();
            if (!scheduledIds.contains(task.getDependencyTask().getId())) {
                violations.add("C4_DEPENDENCY: Task '" + task.getTitle()
                        + "' depends on task ID " + task.getDependencyTask().getId()
                        + " which is not yet scheduled");
            }
        }

        return new ConstraintResult(violations.isEmpty(), violations);
    }

    /**
     * Check if a task is eligible to be scheduled next, considering only
     * dependency constraints (not timing). Used to filter candidates for A*.
     */
    public boolean isDependencySatisfied(PlannerTask task, Set<Long> scheduledTaskIds) {
        if (task.getDependencyTask() == null) {
            return true;
        }
        return scheduledTaskIds.contains(task.getDependencyTask().getId());
    }

    /**
     * Check if a task has a deadline that falls on or before the given date/time.
     * Used to identify tasks that MUST be scheduled today.
     */
    public boolean isDeadlineToday(PlannerTask task, LocalDateTime endOfDay) {
        if (task.getDeadline() == null) return false;
        return !task.getDeadline().isAfter(endOfDay);
    }

    /**
     * Result of a constraint check.
     */
    public static class ConstraintResult {
        private final boolean satisfied;
        private final List<String> violations;

        public ConstraintResult(boolean satisfied, List<String> violations) {
            this.satisfied = satisfied;
            this.violations = violations;
        }

        public boolean isSatisfied() {
            return satisfied;
        }

        public List<String> getViolations() {
            return violations;
        }

        @Override
        public String toString() {
            if (satisfied) return "SATISFIED";
            return "VIOLATED: " + String.join("; ", violations);
        }
    }
}
