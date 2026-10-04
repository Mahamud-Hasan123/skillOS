package com.skillos.planner.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Represents a complete, finalized schedule produced by the A* search.
 * This is what gets persisted as a DailySchedule + ScheduleEntries.
 */
public class ScheduleCandidate {

    private final List<TaskAssignment> assignments;
    private final double totalCost;
    private final List<String> warnings;
    private final List<String> unscheduledTaskTitles;

    public ScheduleCandidate(List<TaskAssignment> assignments, double totalCost) {
        this.assignments = new ArrayList<>(assignments);
        this.totalCost = totalCost;
        this.warnings = new ArrayList<>();
        this.unscheduledTaskTitles = new ArrayList<>();
    }

    public List<TaskAssignment> getAssignments() {
        return assignments;
    }

    public double getTotalCost() {
        return totalCost;
    }

    public List<String> getWarnings() {
        return warnings;
    }

    public void addWarning(String warning) {
        this.warnings.add(warning);
    }

    public List<String> getUnscheduledTaskTitles() {
        return unscheduledTaskTitles;
    }

    public void addUnscheduledTask(String title) {
        this.unscheduledTaskTitles.add(title);
    }

    public boolean hasFeasibilityWarning() {
        return !unscheduledTaskTitles.isEmpty();
    }

    public String getFeasibilityWarning() {
        if (unscheduledTaskTitles.isEmpty()) return null;
        return "Could not schedule " + unscheduledTaskTitles.size()
                + " task(s) due to insufficient time: "
                + String.join(", ", unscheduledTaskTitles);
    }

    public int totalScheduledMinutes() {
        return assignments.stream().mapToInt(TaskAssignment::durationMinutes).sum();
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("Schedule (cost=").append(String.format("%.2f", totalCost)).append("):\n");
        for (TaskAssignment a : assignments) {
            sb.append("  ").append(a).append("\n");
        }
        if (hasFeasibilityWarning()) {
            sb.append("  ⚠ ").append(getFeasibilityWarning()).append("\n");
        }
        return sb.toString();
    }
}
