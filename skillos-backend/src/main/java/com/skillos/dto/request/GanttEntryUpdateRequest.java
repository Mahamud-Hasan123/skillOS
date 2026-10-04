package com.skillos.dto.request;

import lombok.Data;

@Data
public class GanttEntryUpdateRequest {
    private Integer startDay;
    private Integer durationDays;
    private Integer orderIndex;
}
