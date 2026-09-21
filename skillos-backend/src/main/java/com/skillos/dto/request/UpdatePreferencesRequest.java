package com.skillos.dto.request;

import lombok.Data;

@Data
public class UpdatePreferencesRequest {
    private String theme;
    private String language;
    private String timezone; // from the User entity but returned in preferences API
    private Boolean globalRankingOptIn; // from the User entity but returned in preferences API
    private Boolean notificationEmail;
    private Boolean notificationPush;
    private Boolean notificationPeerActivity;
    private Boolean notificationDailyReminder;
    private Boolean notificationAchievement;
}
