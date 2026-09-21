package com.skillos.dto.request;

import lombok.Data;

@Data
public class UpdateRoadmapRequest {
    private String title;
    private String status; // active, completed, archived
    private Integer progressPercent;
}
