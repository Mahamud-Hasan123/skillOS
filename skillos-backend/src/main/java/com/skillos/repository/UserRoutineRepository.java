package com.skillos.repository;

import com.skillos.entity.UserRoutine;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserRoutineRepository extends JpaRepository<UserRoutine, Long> {

    List<UserRoutine> findByUserId(Long userId);

    List<UserRoutine> findByUserIdAndDayOfWeek(Long userId, Integer dayOfWeek);

    List<UserRoutine> findByUserIdAndDayOfWeekAndIsAvailable(Long userId, Integer dayOfWeek, Boolean isAvailable);
}
