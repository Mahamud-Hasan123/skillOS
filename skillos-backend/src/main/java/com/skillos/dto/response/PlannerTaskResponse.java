package com.skillos.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PlannerTaskResponse {
    private Long id;
    private String sourceType;
    private Long sourceId;
    private String title;
    private String description;
    private Integer estimatedMinutes;
    private String priority;
    private LocalDateTime deadline;
    private String category;
    private Long dependencyTaskId;
    private Boolean isRecurring;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
