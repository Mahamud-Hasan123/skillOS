package com.skillos.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Data
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "planner_tasks", indexes = {
    @Index(name = "idx_user_status", columnList = "user_id, status"),
    @Index(name = "idx_user_deadline", columnList = "user_id, deadline")
})
public class PlannerTask {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // 'roadmap', 'custom', or 'external'
    @Column(name = "source_type", nullable = false, columnDefinition = "enum('roadmap','custom','external')")
    private String sourceType;

    // FK to roadmap_tasks.id or custom_tasks.id depending on source_type
    @Column(name = "source_id")
    private Long sourceId;

    @Column(nullable = false, length = 500)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Builder.Default
    @Column(name = "estimated_minutes", nullable = false)
    private Integer estimatedMinutes = 30;

    @Builder.Default
    @Column(nullable = false, columnDefinition = "enum('low','medium','high','critical') DEFAULT 'medium'")
    private String priority = "medium";

    @Column
    private LocalDateTime deadline;

    @Column(length = 100)
    private String category;

    // Self-referencing: must complete this task first
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dependency_task_id")
    private PlannerTask dependencyTask;

    @Builder.Default
    @Column(name = "is_recurring", nullable = false)
    private Boolean isRecurring = false;

    @Builder.Default
    @Column(nullable = false, columnDefinition = "enum('pending','scheduled','in_progress','completed','skipped') DEFAULT 'pending'")
    private String status = "pending";

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
