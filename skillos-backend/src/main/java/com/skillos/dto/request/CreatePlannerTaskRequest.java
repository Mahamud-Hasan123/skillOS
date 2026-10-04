package com.skillos.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class CreatePlannerTaskRequest {

    @NotBlank(message = "Title is required")
    private String title;

    private String description;

    @NotNull(message = "Estimated minutes is required")
    @Min(value = 1, message = "Estimated minutes must be at least 1")
    private Integer estimatedMinutes;

    // low, medium, high, critical
    private String priority = "medium";

    private LocalDateTime deadline;

    private String category;

    // ID of another PlannerTask that must be completed first
    private Long dependencyTaskId;

    private Boolean isRecurring = false;
}
