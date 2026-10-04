package com.skillos.planner.model;

import com.skillos.entity.PlannerTask;

import java.time.LocalTime;

/**
 * Represents a single task assignment within a schedule:
 * which task goes into which time slot.
 */
public class TaskAssignment {
    private final PlannerTask task;
    private final LocalTime startTime;
    private final LocalTime endTime;

    public TaskAssignment(PlannerTask task, LocalTime startTime, LocalTime endTime) {
        this.task = task;
        this.startTime = startTime;
        this.endTime = endTime;
    }

    public PlannerTask getTask() {
        return task;
    }

    public LocalTime getStartTime() {
        return startTime;
    }

    public LocalTime getEndTime() {
        return endTime;
    }

    public int durationMinutes() {
        return (int) java.time.Duration.between(startTime, endTime).toMinutes();
    }

    @Override
    public String toString() {
        return task.getTitle() + " [" + startTime + " - " + endTime + "]";
    }
}
