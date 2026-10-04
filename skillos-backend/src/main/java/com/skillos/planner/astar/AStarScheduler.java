package com.skillos.planner.astar;

import com.skillos.entity.PlannerTask;
import com.skillos.planner.csp.ConstraintChecker;
import com.skillos.planner.model.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * A* search algorithm for finding the optimal task sequence.
 *
 * Explores possible orderings of tasks within available time slots
 * and uses g(n) + h(n) to find the lowest-cost valid schedule.
 *
 * Cost function g(n) penalizes:
 *   - Missed deadlines:                 100 points (heavy)
 *   - Low-priority tasks before high:    10 points (moderate)
 *   - Gaps between tasks:                 1 point per 15 min (light)
 *
 * The search space for a typical day (5-15 tasks, 3-5 time slots) is small,
 * so A* will complete in milliseconds without exotic optimizations.
 */
public class AStarScheduler {

    private static final double MISSED_DEADLINE_PENALTY = 100.0;
    private static final double PRIORITY_INVERSION_PENALTY = 10.0;
    private static final double GAP_PENALTY_PER_15_MIN = 1.0;
    private static final int MAX_ITERATIONS = 10_000; // Safety limit

    private final ConstraintChecker constraintChecker;
    private final ScheduleHeuristic heuristic;

    public AStarScheduler() {
        this.constraintChecker = new ConstraintChecker();
        this.heuristic = new ScheduleHeuristic();
    }

    /**
     * Run A* to find the optimal schedule for the given tasks within available time slots.
     *
     * @param tasks          The tasks eligible for scheduling today
     * @param availableSlots The free time windows (fixed events already subtracted)
     * @param scheduleDate   The date being scheduled (for deadline evaluation)
     * @return               A ScheduleCandidate with the optimal ordering and any warnings
     */
    public ScheduleCandidate search(List<PlannerTask> tasks, List<TimeSlot> availableSlots, LocalDate scheduleDate) {
        if (tasks.isEmpty() || availableSlots.isEmpty()) {
            ScheduleCandidate empty = new ScheduleCandidate(List.of(), 0.0);
            if (tasks.isEmpty()) {
                empty.addWarning("No tasks to schedule.");
            }
            if (availableSlots.isEmpty()) {
                empty.addWarning("No available time slots.");
                tasks.forEach(t -> empty.addUnscheduledTask(t.getTitle()));
            }
            return empty;
        }

        LocalDateTime endOfDay = scheduleDate.atTime(23, 59, 59);

        // Priority queue: lowest f-cost first
        PriorityQueue<ScheduleState> openSet = new PriorityQueue<>();
        ScheduleState initial = ScheduleState.initial(tasks, availableSlots);
        initial.setHCost(heuristic.estimate(initial, endOfDay));
        openSet.add(initial);

        ScheduleState bestGoal = null;
        int iterations = 0;

        while (!openSet.isEmpty() && iterations < MAX_ITERATIONS) {
            iterations++;
            ScheduleState current = openSet.poll();

            // Check if this is a goal state (all tasks placed or no time left)
            if (current.isGoal()) {
                if (bestGoal == null || current.getFCost() < bestGoal.getFCost()) {
                    bestGoal = current;
                }
                // A* guarantees the first goal popped is optimal (with admissible heuristic)
                break;
            }

            // Expand: try scheduling each remaining task next
            List<ScheduleState> successors = expand(current, endOfDay);
            for (ScheduleState successor : successors) {
                successor.setHCost(heuristic.estimate(successor, endOfDay));
                openSet.add(successor);
            }

            // Also consider "giving up" on remaining tasks (skip to goal)
            // This allows finding schedules where not all tasks fit
            if (current.getEffectiveCurrentTime() == null) {
                // No more time — this state is implicitly a goal
                if (bestGoal == null || current.getGCost() < bestGoal.getGCost()) {
                    bestGoal = current;
                }
            }
        }

        // Build the result
        if (bestGoal == null) {
            // Fallback: use a greedy priority-based schedule
            return buildGreedySchedule(tasks, availableSlots, endOfDay);
        }

        return buildCandidate(bestGoal, tasks);
    }

    /**
     * Expand a state: generate successor states by trying each eligible remaining task.
     */
    private List<ScheduleState> expand(ScheduleState state, LocalDateTime endOfDay) {
        List<ScheduleState> successors = new ArrayList<>();
        Set<Long> scheduledIds = state.getScheduledTaskIds();
        LocalTime effectiveTime = state.getEffectiveCurrentTime();

        if (effectiveTime == null) return successors; // No more time

        for (PlannerTask task : state.getRemainingTasks()) {
            // Check dependency constraint
            if (!constraintChecker.isDependencySatisfied(task, scheduledIds)) {
                continue;
            }

            // Find where this task would start
            int slotIdx = state.getSlotIndexForTime(effectiveTime);
            if (slotIdx >= state.getAvailableSlots().size()) continue;

            TimeSlot slot = state.getAvailableSlots().get(slotIdx);
            LocalTime taskStart = effectiveTime.isBefore(slot.getStart()) ? slot.getStart() : effectiveTime;
            LocalTime taskEnd = taskStart.plusMinutes(task.getEstimatedMinutes());

            // Check if it fits in this slot
            if (taskEnd.isAfter(slot.getEnd())) {
                // Try the next slot
                if (slotIdx + 1 < state.getAvailableSlots().size()) {
                    TimeSlot nextSlot = state.getAvailableSlots().get(slotIdx + 1);
                    if (nextSlot.durationMinutes() >= task.getEstimatedMinutes()) {
                        taskStart = nextSlot.getStart();
                        taskEnd = taskStart.plusMinutes(task.getEstimatedMinutes());
                        slotIdx = slotIdx + 1;
                    } else {
                        continue; // Can't fit anywhere
                    }
                } else {
                    continue; // No more slots
                }
            }

            // Validate with CSP
            ConstraintChecker.ConstraintResult result = constraintChecker.check(state, task, taskStart, taskEnd);
            if (!result.isSatisfied()) continue;

            // Calculate transition cost
            double transitionCost = calculateTransitionCost(state, task, taskStart, endOfDay);

            // Build successor state
            List<TaskAssignment> newAssignments = new ArrayList<>(state.getScheduledTasks());
            newAssignments.add(new TaskAssignment(task, taskStart, taskEnd));

            List<PlannerTask> newRemaining = state.getRemainingTasks().stream()
                    .filter(t -> !t.getId().equals(task.getId()))
                    .collect(Collectors.toList());

            ScheduleState successor = new ScheduleState(
                    newAssignments,
                    newRemaining,
                    taskEnd,
                    state.getAvailableSlots(),
                    slotIdx,
                    state.getGCost() + transitionCost
            );

            successors.add(successor);
        }

        return successors;
    }

    /**
     * Calculate the cost of scheduling a task at a given time.
     */
    private double calculateTransitionCost(ScheduleState state, PlannerTask task, LocalTime taskStart, LocalDateTime endOfDay) {
        double cost = 0.0;

        // Missed deadline penalty
        if (task.getDeadline() != null && !task.getDeadline().isAfter(endOfDay)) {
            LocalTime deadlineTime = task.getDeadline().toLocalTime();
            LocalTime taskEnd = taskStart.plusMinutes(task.getEstimatedMinutes());
            if (taskEnd.isAfter(deadlineTime)) {
                cost += MISSED_DEADLINE_PENALTY;
            }
        }

        // Priority inversion: scheduling a low-priority task before remaining high-priority ones
        int taskPriorityRank = priorityRank(task.getPriority());
        for (PlannerTask remaining : state.getRemainingTasks()) {
            if (remaining.getId().equals(task.getId())) continue;
            int remainingRank = priorityRank(remaining.getPriority());
            if (remainingRank > taskPriorityRank) {
                cost += PRIORITY_INVERSION_PENALTY;
            }
        }

        // Gap penalty: time between end of last scheduled task and start of this one
        if (!state.getScheduledTasks().isEmpty()) {
            TaskAssignment lastTask = state.getScheduledTasks().get(state.getScheduledTasks().size() - 1);
            long gapMinutes = java.time.Duration.between(lastTask.getEndTime(), taskStart).toMinutes();
            if (gapMinutes > 0) {
                cost += (gapMinutes / 15.0) * GAP_PENALTY_PER_15_MIN;
            }
        }

        return cost;
    }

    /**
     * Convert priority string to numeric rank (higher = more important).
     */
    private int priorityRank(String priority) {
        if (priority == null) return 1;
        return switch (priority.toLowerCase()) {
            case "critical" -> 4;
            case "high" -> 3;
            case "medium" -> 2;
            case "low" -> 1;
            default -> 1;
        };
    }

    /**
     * Fallback: build a greedy schedule when A* doesn't find a solution.
     * Schedules tasks in priority order until time runs out.
     */
    private ScheduleCandidate buildGreedySchedule(List<PlannerTask> tasks, List<TimeSlot> slots, LocalDateTime endOfDay) {
        // Sort by priority (critical first), then by deadline (earliest first)
        List<PlannerTask> sorted = tasks.stream()
                .sorted(Comparator.comparingInt((PlannerTask t) -> -priorityRank(t.getPriority()))
                        .thenComparing(t -> t.getDeadline() != null ? t.getDeadline() : LocalDateTime.MAX))
                .collect(Collectors.toList());

        List<TaskAssignment> assignments = new ArrayList<>();
        int slotIdx = 0;
        LocalTime currentTime = slots.get(0).getStart();

        for (PlannerTask task : sorted) {
            boolean placed = false;
            while (slotIdx < slots.size()) {
                TimeSlot slot = slots.get(slotIdx);
                LocalTime start = currentTime.isBefore(slot.getStart()) ? slot.getStart() : currentTime;

                if (slot.canFit(start, task.getEstimatedMinutes())) {
                    LocalTime end = start.plusMinutes(task.getEstimatedMinutes());
                    assignments.add(new TaskAssignment(task, start, end));
                    currentTime = end;
                    placed = true;
                    break;
                }

                slotIdx++;
                if (slotIdx < slots.size()) {
                    currentTime = slots.get(slotIdx).getStart();
                }
            }

            if (!placed) break; // No more time
        }

        double totalCost = assignments.size() < tasks.size() ? MISSED_DEADLINE_PENALTY * (tasks.size() - assignments.size()) : 0;
        ScheduleCandidate candidate = new ScheduleCandidate(assignments, totalCost);

        // Record unscheduled tasks
        Set<Long> scheduledIds = assignments.stream()
                .map(a -> a.getTask().getId())
                .collect(Collectors.toSet());
        for (PlannerTask task : tasks) {
            if (!scheduledIds.contains(task.getId())) {
                candidate.addUnscheduledTask(task.getTitle());
            }
        }

        return candidate;
    }

    /**
     * Build the final ScheduleCandidate from a goal state.
     */
    private ScheduleCandidate buildCandidate(ScheduleState goalState, List<PlannerTask> allTasks) {
        ScheduleCandidate candidate = new ScheduleCandidate(
                goalState.getScheduledTasks(),
                goalState.getGCost()
        );

        // Identify unscheduled tasks
        Set<Long> scheduledIds = goalState.getScheduledTaskIds();
        for (PlannerTask task : allTasks) {
            if (!scheduledIds.contains(task.getId())) {
                candidate.addUnscheduledTask(task.getTitle());
            }
        }

        return candidate;
    }
}
