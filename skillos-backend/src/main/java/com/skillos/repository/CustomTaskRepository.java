package com.skillos.repository;

import com.skillos.entity.CustomTask;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface CustomTaskRepository extends JpaRepository<CustomTask, Long> {

    List<CustomTask> findByUserId(Long userId);

    List<CustomTask> findByUserIdAndStatus(Long userId, String status);

    List<CustomTask> findByUserIdAndScheduledDate(Long userId, LocalDate scheduledDate);
}
