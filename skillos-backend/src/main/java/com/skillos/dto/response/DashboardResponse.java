package com.skillos.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardResponse {
    private String greeting;
    private Integer streakCount;
    private FocusInfo todayFocus;
    private RoadmapInfo activeRoadmap;
    private LevelDetails levelInfo;
    private List<TaskDetails> upcomingTasks;
    private List<PeerDetails> peers;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class FocusInfo {
        private String badge;
        private String title;
        private String subtitle;
        private String btnText;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RoadmapInfo {
        private String badge;
        private String title;
        private String subtitle;
        private Integer percent;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class LevelDetails {
        private Integer level;
        private String title;
        private String subtitle;
        private Integer percent;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TaskDetails {
        private Long id;
        private String title;
        private String meta;
        private Boolean completed;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PeerDetails {
        private Long id;
        private String name;
        private Integer level;
        private String status;
        private Boolean active;
        private String initial;
    }
}
