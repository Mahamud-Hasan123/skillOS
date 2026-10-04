package com.skillos.repository;

import com.skillos.entity.ScheduleEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ScheduleEntryRepository extends JpaRepository<ScheduleEntry, Long> {

    List<ScheduleEntry> findByScheduleIdOrderBySlotOrder(Long scheduleId);

    // Get remaining incomplete entries for rescheduling
    List<ScheduleEntry> findByScheduleIdAndStatusIn(Long scheduleId, List<String> statuses);

    // Count completed entries for progress tracking
    long countByScheduleIdAndStatus(Long scheduleId, String status);
}
