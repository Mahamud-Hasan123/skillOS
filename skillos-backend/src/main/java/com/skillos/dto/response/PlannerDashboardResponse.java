package com.skillos.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PlannerDashboardResponse {
    private TodaySchedule today;
    private EstimateAccuracy estimateAccuracy;
    private NextTask nextTask;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TodaySchedule {
        private LocalDate date;
        private Integer scheduleVersion;
        private Integer totalTasks;
        private Integer completed;
        private Integer inProgress;
        private Integer remaining;
        private Integer skipped;
        private String feasibilityWarning;
        private List<ScheduleEntryResponse> entries;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class EstimateAccuracy {
        private Double averageDeviationMinutes;
        private Long totalTasksTracked;
        private Double overrunPercentage;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class NextTask {
        private Long id;
        private String title;
        private String startTime;
        private Integer estimatedMinutes;
    }
}
