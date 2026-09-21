package com.skillos.repository;

import com.skillos.entity.FlashcardBatch;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FlashcardBatchRepository extends JpaRepository<FlashcardBatch, Long> {
}
