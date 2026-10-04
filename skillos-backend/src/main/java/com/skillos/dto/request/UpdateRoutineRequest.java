package com.skillos.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.Data;

import java.time.LocalTime;

@Data
public class UpdateRoutineRequest {

    @Min(value = 0, message = "Day of week must be 0 (Sunday) to 6 (Saturday)")
    @Max(value = 6, message = "Day of week must be 0 (Sunday) to 6 (Saturday)")
    private Integer dayOfWeek;

    private LocalTime startTime;

    private LocalTime endTime;

    private Boolean isAvailable;

    private String label;
}
