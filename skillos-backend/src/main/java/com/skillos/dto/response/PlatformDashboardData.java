package com.skillos.dto.response;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class PlatformDashboardData {
    private long totalUsers;
    private long activeUsers; // e.g. users active in last 7 days
    private long totalRoadmaps;
    private long totalProjects;
    private List<SkillPopularityData> topSkills;
}
