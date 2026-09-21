package com.skillos.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileResponse {
    private Long id;
    private String fullName;
    private String email;
    private String role;
    private String avatar;
    private String bio;
    private String profession;
    private String timezone;
    private Integer currentLevel;
    private Integer totalXp;
    private Integer apBalance;
    private LocalDateTime createdAt;
}
