package com.skillos.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

@Data
public class FlashcardReviewRequest {

    @NotBlank(message = "Difficulty is required")
    @Pattern(regexp = "^(easy|medium|hard|forgot)$", message = "Difficulty must be easy, medium, hard, or forgot")
    private String difficulty;
}
