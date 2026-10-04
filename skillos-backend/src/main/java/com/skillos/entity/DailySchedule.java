package com.skillos.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "daily_schedules",
    uniqueConstraints = @UniqueConstraint(name = "uq_user_date_version", columnNames = {"user_id", "schedule_date", "version"}),
    indexes = {
        @Index(name = "idx_user_date_active", columnList = "user_id, schedule_date, is_active")
    }
)
public class DailySchedule {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "schedule_date", nullable = false)
    private LocalDate scheduleDate;

    // Increments on each reschedule
    @Builder.Default
    @Column(nullable = false)
    private Integer version = 1;

    // Only one active version per day
    @Builder.Default
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @CreationTimestamp
    @Column(name = "generated_at", updatable = false)
    private LocalDateTime generatedAt;

    // Reason for rescheduling (null for the original schedule)
    @Column(columnDefinition = "TEXT")
    private String notes;

    @OneToMany(mappedBy = "schedule", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ScheduleEntry> entries;
}
