package com.skillos.planner.model;

import java.time.Duration;
import java.time.LocalTime;

/**
 * Represents a continuous block of available time.
 * Used by the scheduling engine to know WHERE tasks can be placed.
 */
public class TimeSlot {
    private final LocalTime start;
    private final LocalTime end;

    public TimeSlot(LocalTime start, LocalTime end) {
        if (!end.isAfter(start)) {
            throw new IllegalArgumentException("End time must be after start time: " + start + " - " + end);
        }
        this.start = start;
        this.end = end;
    }

    public LocalTime getStart() {
        return start;
    }

    public LocalTime getEnd() {
        return end;
    }

    /**
     * Duration of this slot in minutes.
     */
    public int durationMinutes() {
        return (int) Duration.between(start, end).toMinutes();
    }

    /**
     * Check if a task of the given duration can fit starting at the given time within this slot.
     */
    public boolean canFit(LocalTime taskStart, int durationMinutes) {
        LocalTime taskEnd = taskStart.plusMinutes(durationMinutes);
        return !taskStart.isBefore(start) && !taskEnd.isAfter(end);
    }

    /**
     * Check if a given time falls within this slot.
     */
    public boolean contains(LocalTime time) {
        return !time.isBefore(start) && time.isBefore(end);
    }

    @Override
    public String toString() {
        return start + " - " + end + " (" + durationMinutes() + " min)";
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        TimeSlot timeSlot = (TimeSlot) o;
        return start.equals(timeSlot.start) && end.equals(timeSlot.end);
    }

    @Override
    public int hashCode() {
        return 31 * start.hashCode() + end.hashCode();
    }
}
