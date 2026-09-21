package com.skillos.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

@Data
public class TimerActionRequest {

    @NotBlank(message = "Action is required")
    @Pattern(regexp = "^(start|pause|resume|stop)$", message = "Action must be start, pause, resume, or stop")
    private String action;
}
