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
 * Represents a study note created by a user, either manually or via a Roadmap day.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "notes")
public class Note {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // The user who wrote the note
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @JsonIgnore
    private User user;

    // If the note was created from the roadmap UI, it maps to the roadmap
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "roadmap_id")
    @JsonIgnore
    private Roadmap roadmap;

    // The specific day of the roadmap the note applies to
    @Column(name = "day_number")
    private Integer dayNumber;

    // Manually entered skill name (if not using roadmap_id mapping)
    @Column(name = "skill_name", length = 255)
    private String skillName;

    // The actual text content of the note
    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    // A JSON array of verified resource links added to the note
    @Column(name = "resource_links", columnDefinition = "JSON")
    private String resourceLinks;

    // Tracks if this note has been consumed by the AI flashcard generator yet
    @Column(name = "used_for_flashcard_gen", nullable = false)
    private Boolean usedForFlashcardGen = false;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
