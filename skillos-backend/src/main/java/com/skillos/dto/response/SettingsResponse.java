package com.skillos.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class SettingsResponse {
    private String theme;
    private String language;
    private String timezone;
    
    private Boolean globalRankingOptIn;
    
    private Boolean notificationEmail;
    private Boolean notificationPush;
    private Boolean notificationPeerActivity;
    private Boolean notificationDailyReminder;
    private Boolean notificationAchievement;
}
