package com.skillos.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AiPromptRequest {

    @NotBlank(message = "Prompt text cannot be empty")
    @Size(max = 2000, message = "Prompt text cannot exceed 2000 characters")
    private String promptText;
}
