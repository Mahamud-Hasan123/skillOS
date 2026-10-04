package com.skillos.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CompleteEntryRequest {

    @NotNull(message = "Actual minutes is required")
    @Min(value = 0, message = "Actual minutes cannot be negative")
    private Integer actualMinutes;
}
