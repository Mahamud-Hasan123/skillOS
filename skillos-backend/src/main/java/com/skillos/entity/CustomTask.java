package com.skillos.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Maps to the existing `custom_tasks` table in the database.
 * This table already exists (see skillos_v1.sql line 132) but previously had no JPA entity.
 */
@Data
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "custom_tasks")
public class CustomTask {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String title;

    @Column(name = "scheduled_date", nullable = false)
    private LocalDate scheduledDate;

    @Builder.Default
    @Column(nullable = false, columnDefinition = "enum('pending','completed') DEFAULT 'pending'")
    private String status = "pending";

    @Builder.Default
    @Column(name = "xp_reward", nullable = false)
    private Integer xpReward = 15;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
