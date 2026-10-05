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
 * Represents a single task or feature in the Project's Gantt Chart timeline.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "gantt_entries")
public class GanttEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // The project this timeline entry belongs to
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "project_id", nullable = false)
    @JsonIgnore
    private Project project;

    // What the feature/task is
    @Column(name = "feature_name", nullable = false, length = 255)
    private String featureName;

    // Vertical sorting order in the Gantt chart UI
    @Column(name = "order_index", nullable = false)
    private Integer orderIndex;

    // The relative day offset from the project's start date (e.g., starts on day 0)
    @Column(name = "start_day", nullable = false)
    private Integer startDay;

    // How many days this feature takes to complete
    @Column(name = "duration_days", nullable = false)
    private Integer durationDays;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
