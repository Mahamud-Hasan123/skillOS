package com.skillos.dto.request;

import jakarta.validation.constraints.Min;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class UpdatePlannerTaskRequest {

    private String title;

    private String description;

    @Min(value = 1, message = "Estimated minutes must be at least 1")
    private Integer estimatedMinutes;

    // low, medium, high, critical
    private String priority;

    private LocalDateTime deadline;

    private String category;

    private Long dependencyTaskId;

    private Boolean isRecurring;

    // pending, scheduled, in_progress, completed, skipped
    private String status;
}
