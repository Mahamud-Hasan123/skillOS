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
 * Tracks individual review sessions for a flashcard, recording the difficulty chosen and the mastery change.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "flashcard_reviews")
public class FlashcardReview {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // The flashcard being reviewed
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "flashcard_id", nullable = false)
    @JsonIgnore
    private Flashcard flashcard;

    // The user who is reviewing it
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @JsonIgnore
    private User user;

    // The difficulty level chosen by the user during the review
    @Column(name = "difficulty_set", nullable = false, columnDefinition = "enum('easy','medium','hard','forgot')")
    private String difficultySet;

    // What the mastery level became after this specific review
    @Column(name = "mastery_after", nullable = false)
    private Integer masteryAfter;

    // When the user actually performed the review in the frontend
    @Column(name = "reviewed_at", nullable = false, updatable = false)
    private LocalDateTime reviewedAt = LocalDateTime.now();

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
