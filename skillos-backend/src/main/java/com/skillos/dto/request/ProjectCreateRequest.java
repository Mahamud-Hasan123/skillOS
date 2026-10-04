package com.skillos.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Min;
import lombok.Data;

@Data
public class ProjectCreateRequest {
    @NotBlank(message = "Project name is required")
    private String name;

    private String description;

    private String skillName;

    @NotNull(message = "Deadline days is required")
    @Min(value = 1, message = "Deadline must be at least 1 day")
    private Integer deadlineDays;

    private String color;
}
