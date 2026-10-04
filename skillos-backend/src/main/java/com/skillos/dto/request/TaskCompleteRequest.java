package com.skillos.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class TaskCompleteRequest {
    @NotBlank
    private String userAnswer;
}
