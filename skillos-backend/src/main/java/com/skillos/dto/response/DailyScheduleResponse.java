package com.skillos.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DailyScheduleResponse {
    private Long id;
    private LocalDate scheduleDate;
    private Integer version;
    private Boolean isActive;
    private LocalDateTime generatedAt;
    private String notes;
    private List<ScheduleEntryResponse> entries;
}
