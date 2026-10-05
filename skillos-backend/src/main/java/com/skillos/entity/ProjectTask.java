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

/**
 * Represents a granular task within a Project, which can be linked to a Kanban Card.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "project_tasks")
public class ProjectTask {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // The project this task belongs to
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "project_id", nullable = false)
    @JsonIgnore
    private Project project;

    // Optional link to a timeline feature
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "gantt_entry_id")
    @JsonIgnore
    private GanttEntry ganttEntry;

    @Column(nullable = false, length = 255)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "order_index", nullable = false)
    private Integer orderIndex = 0;

    // True if AI generated this task during project breakdown, False if user added it manually
    @Column(name = "is_ai_generated", nullable = false)
    private Boolean isAiGenerated = false;

    @Column(name = "xp_reward", nullable = false)
    private Integer xpReward = 5;

    @Builder.Default
    @Column(name = "estimated_minutes", nullable = false)
    private Integer estimatedMinutes = 30;

    @Builder.Default
    @Column(nullable = false, columnDefinition = "enum('low','medium','high','critical') DEFAULT 'medium'")
    private String priority = "medium";

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
