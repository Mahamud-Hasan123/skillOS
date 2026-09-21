package com.skillos.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import com.fasterxml.jackson.annotation.JsonIgnore;

import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/**
 * Represents a single daily task within a generated roadmap.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "roadmap_tasks")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class RoadmapTask {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // The roadmap this task belongs to
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "roadmap_id", nullable = false)
    @JsonIgnore
    private Roadmap roadmap;

    // What the user needs to learn (e.g. "Learn basic HTML structure")
    @Column(nullable = false, columnDefinition = "TEXT")
    private String title;

    // Comprehension question for this day
    @Column(nullable = false, columnDefinition = "TEXT")
    private String question;

    // Correct answer used for validation when user submits their answer
    @Column(nullable = false, columnDefinition = "TEXT")
    private String answer;

    // Base XP reward for completing this day's task
    @Column(name = "xp_reward", nullable = false)
    private Integer xpReward = 10;

    // The sequential day this task is assigned to (Day 0...Day N)
    @Column(name = "day_number", nullable = false)
    private Integer dayNumber;

    // Tracks if this specific task has been marked complete (though daily_tasks table handles actual daily status)
    @Column(nullable = false, columnDefinition = "enum('pending','completed') DEFAULT 'pending'")
    private String status = "pending";

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
