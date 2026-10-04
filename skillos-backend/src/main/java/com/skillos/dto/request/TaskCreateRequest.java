package com.skillos.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class TaskCreateRequest {
    @NotBlank
    private String title;
    
    @NotBlank
    private String question;
    
    @NotBlank
    private String answer;
    
    @NotNull
    private Integer dayNumber;
    
    private Integer xpReward = 10;
}
