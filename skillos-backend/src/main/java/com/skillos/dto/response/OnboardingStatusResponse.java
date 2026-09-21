package com.skillos.dto.response;

import lombok.Builder;
import lombok.Data;

import java.util.Map;

@Data
@Builder
public class OnboardingStatusResponse {
    private Integer currentStep;
    private Boolean isCompleted;
    private Map<String, Object> steps;
}
