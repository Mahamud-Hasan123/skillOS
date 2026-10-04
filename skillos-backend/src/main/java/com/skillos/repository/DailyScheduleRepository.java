package com.skillos.repository;

import com.skillos.entity.DailySchedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface DailyScheduleRepository extends JpaRepository<DailySchedule, Long> {

    // Get the current active schedule for a given date
    Optional<DailySchedule> findByUserIdAndScheduleDateAndIsActive(Long userId, LocalDate scheduleDate, Boolean isActive);

    // Get all versions (history) for a given date
    List<DailySchedule> findByUserIdAndScheduleDateOrderByVersionDesc(Long userId, LocalDate scheduleDate);

    // Get the latest version number for a given date
    Optional<DailySchedule> findFirstByUserIdAndScheduleDateOrderByVersionDesc(Long userId, LocalDate scheduleDate);
}
