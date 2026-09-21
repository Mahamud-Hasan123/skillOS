package com.skillos.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import com.fasterxml.jackson.annotation.JsonIgnore;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "roadmaps")
public class Roadmap {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @JsonIgnore
    private User user;

    @Column(nullable = false)
    private String title;

    private String skillGoal;

    private String level;

    @Builder.Default
    private String status = "active";

    @Builder.Default
    private Integer progressPercent = 0;

    private Integer totalDays;

    private Integer durationMonths;

    private Integer dailyTimeMinutes;

    private LocalDate startDate;

    private LocalDate endDate;

    @OneToMany(mappedBy = "roadmap", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<RoadmapTask> tasks;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;
}
