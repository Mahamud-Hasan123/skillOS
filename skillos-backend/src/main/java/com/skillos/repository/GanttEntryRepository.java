package com.skillos.repository;

import com.skillos.entity.GanttEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GanttEntryRepository extends JpaRepository<GanttEntry, Long> {
    List<GanttEntry> findByProjectIdOrderByOrderIndexAsc(Long projectId);
}
