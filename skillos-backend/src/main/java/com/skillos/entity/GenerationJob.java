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
 * Tracks asynchronous AI generation tasks (e.g., generating roadmaps, flashcards, or projects) using the Job Queue pattern.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "generation_jobs")
public class GenerationJob {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // The UUID returned to the frontend immediately for polling (e.g., "gen_abc123")
    @Column(name = "job_id", nullable = false, unique = true, length = 36)
    private String jobId;

    // The user who initiated the AI generation
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // What exactly the AI is supposed to generate
    @Column(name = "job_type", nullable = false, columnDefinition = "enum('roadmap_generation','flashcard_generation')")
    private String jobType;

    // Lifecycle state of the job
    @Builder.Default
    @Column(nullable = false, columnDefinition = "enum('queued','processing','complete','failed') DEFAULT 'queued'")
    private String status = "queued";

    // Tracks 0-100% completion for the frontend progress bar
    @Builder.Default
    @Column(name = "progress_percent", nullable = false)
    private Integer progressPercent = 0;

    // The raw JSON inputs submitted by the user, stored so the background worker can read them
    @Column(name = "inputs_json", nullable = false, columnDefinition = "JSON")
    private String inputsJson;

    // When complete, holds the ID of the newly generated roadmap or flashcard batch
    @Column(name = "result_id")
    private Long resultId;

    // Stores any errors from the Gemini API if the job failed
    @Column(name = "error_message", columnDefinition = "TEXT")
    private String errorMessage;

    // How many times we've tried calling the AI API
    @Builder.Default
    @Column(name = "retry_count", nullable = false)
    private Integer retryCount = 0;

    @Builder.Default
    @Column(name = "max_retries", nullable = false)
    private Integer maxRetries = 3;

    // When the background worker actually started processing this job
    @Column(name = "started_at")
    private LocalDateTime startedAt;

    // When the job finished (success or failure)
    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
