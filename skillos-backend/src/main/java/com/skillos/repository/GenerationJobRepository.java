package com.skillos.repository;

import com.skillos.entity.GenerationJob;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface GenerationJobRepository extends JpaRepository<GenerationJob, Long> {
    Optional<GenerationJob> findByJobId(String jobId);
}
