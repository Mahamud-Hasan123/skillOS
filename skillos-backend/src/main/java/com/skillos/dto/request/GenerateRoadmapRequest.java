package com.skillos.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.util.List;

@Data
public class GenerateRoadmapRequest {
    @NotBlank(message = "Skill goal is required")
    private String skillGoal;

    @Min(15)
    @Max(480)
    private Integer dailyTimeMinutes;

    @Min(1)
    private Integer durationMonths;

    @NotBlank
    private String goalPurpose; // job | education | other

    private String experienceDescription;

    @NotBlank
    private String level; // beginner | intermediate | advanced

    private List<String> focusAreas;
}
