package com.skillos.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

/**
 * Stores notification toggles and UI preferences for a user.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "user_preferences")
public class UserPreference {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Builder.Default
    @Column(nullable = false, columnDefinition = "enum('system','light','dark') DEFAULT 'system'")
    private String theme = "system";

    @Builder.Default
    @Column(nullable = false, length = 10)
    private String language = "en";

    @Builder.Default
    @Column(name = "notification_email", nullable = false)
    private Boolean notificationEmail = true;

    @Builder.Default
    @Column(name = "notification_push", nullable = false)
    private Boolean notificationPush = true;

    @Builder.Default
    @Column(name = "notification_peer_activity", nullable = false)
    private Boolean notificationPeerActivity = true;

    @Builder.Default
    @Column(name = "notification_daily_reminder", nullable = false)
    private Boolean notificationDailyReminder = true;

    @Builder.Default
    @Column(name = "notification_achievement", nullable = false)
    private Boolean notificationAchievement = true;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
