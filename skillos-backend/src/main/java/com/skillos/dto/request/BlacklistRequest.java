package com.skillos.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class BlacklistRequest {
    @NotBlank
    private String domain;
    private String reason;
}
