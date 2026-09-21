package com.skillos.dto.request;

import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class UpdateProfileRequest {
    @Size(min = 2, max = 120, message = "Full name must be between 2 and 120 characters")
    private String fullName;
    
    private String avatar;
    
    @Size(max = 500, message = "Bio cannot exceed 500 characters")
    private String bio;
    
    private String timezone;
    private String profession;
    private Boolean globalRankingOptIn;
}
