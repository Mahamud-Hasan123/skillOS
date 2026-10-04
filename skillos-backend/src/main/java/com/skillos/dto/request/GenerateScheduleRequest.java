package com.skillos.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

@Data
public class GenerateScheduleRequest {

    @NotNull(message = "Date is required")
    private LocalDate date;
}
