package com.skillos.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import java.util.List;

@Data
public class NoteRequest {
    
    private Long roadmapId;
    private Integer dayNumber;
    private String skillName;
    
    @NotBlank(message = "Content is required")
    private String content;
    
    private List<String> resourceLinks;
}
