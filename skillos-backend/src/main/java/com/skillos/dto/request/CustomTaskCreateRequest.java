package com.skillos.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CustomTaskCreateRequest {
    @NotBlank(message = "Title cannot be empty")
    private String title;
}
