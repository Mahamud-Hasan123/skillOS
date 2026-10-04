package com.skillos.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import com.fasterxml.jackson.annotation.JsonIgnore;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Represents an individual task card moving across the Kanban columns.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "kanban_cards")
public class KanbanCard {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // The column this card is currently in. This acts as the SINGLE SOURCE OF TRUTH for status.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "column_id", nullable = false)
    @JsonIgnore
    private KanbanColumn column;

    // If this card is generated from a roadmap task
    @Column(name = "task_id")
    private Long taskId; // keeping as raw ID for simplicity if we don't have RoadmapTask mapped yet

    // If this card is mapped to a specific feature task from the AI project breakdown
    @Column(name = "project_task_id")
    private Long projectTaskId;

    @Column(nullable = false, length = 255)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "due_date")
    private LocalDate dueDate;

    // Vertical sorting position within the column
    @Column(name = "order_index", nullable = false)
    private Integer orderIndex;

    // Flag set to true when the card is moved to the "Done" column
    @Column(name = "is_done", nullable = false)
    private Boolean isDone = false;

    // Soft delete timestamp
    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
