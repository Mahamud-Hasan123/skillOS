package com.skillos.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalTime;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ScheduleEntryResponse {
    private Long id;
    private Long plannerTaskId;
    private String taskTitle;
    private String sourceType;
    private LocalTime startTime;
    private LocalTime endTime;
    private Integer slotOrder;
    private String status;
    private Integer estimatedMinutes;
    private LocalTime actualStartTime;
    private LocalTime actualEndTime;
    private Integer actualMinutes;
    private LocalDateTime startedAt;
    private LocalDateTime completedAt;
}
