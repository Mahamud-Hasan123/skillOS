package com.skillos.dto.request;

import lombok.Data;

import java.util.List;

@Data
public class OnboardingStepRequest {
    // Step 1
    private List<String> goalSkillTags;
    
    // Step 2
    private Integer dailyCommitmentMin;
    
    // Step 3
    private Integer daysAvailableBitmask;
    
    // Step 4
    private Boolean peerOptIn;
    private List<String> peerSkillFilter;
    
    // Step 5
    private String fullName;
    private String profession;
    private String bio;
    private String avatar;
    
    // Skip flag
    private Boolean skip;
}
