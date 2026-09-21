package com.skillos.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class SettingsUpdateRequest {
    @NotBlank
    private String theme;
    @NotBlank
    private String language;
    @NotBlank
    private String timezone;

    private Boolean globalRankingOptIn;
    
    private Boolean notificationEmail;
    private Boolean notificationPush;
    private Boolean notificationPeerActivity;
    private Boolean notificationDailyReminder;
    private Boolean notificationAchievement;
}
