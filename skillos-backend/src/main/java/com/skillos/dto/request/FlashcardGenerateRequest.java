package com.skillos.dto.request;

import lombok.Data;

@Data
public class FlashcardGenerateRequest {

    // Optional skill name to associate with the generated flashcards
    private String skillName;
}
