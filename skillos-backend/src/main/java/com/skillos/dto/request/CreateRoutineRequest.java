package com.skillos.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalTime;

@Data
public class CreateRoutineRequest {

    @NotNull(message = "Day of week is required")
    @Min(value = 0, message = "Day of week must be 0 (Sunday) to 6 (Saturday)")
    @Max(value = 6, message = "Day of week must be 0 (Sunday) to 6 (Saturday)")
    private Integer dayOfWeek;

    @NotNull(message = "Start time is required")
    private LocalTime startTime;

    @NotNull(message = "End time is required")
    private LocalTime endTime;

    // TRUE = available window, FALSE = fixed event
    private Boolean isAvailable = true;

    // Optional label, e.g. "Morning Study", "CS101 Class"
    private String label;
}
