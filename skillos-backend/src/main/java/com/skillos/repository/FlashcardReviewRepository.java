package com.skillos.repository;

import com.skillos.entity.FlashcardReview;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FlashcardReviewRepository extends JpaRepository<FlashcardReview, Long> {
    int countByUserId(Long userId);
    void deleteByFlashcardId(Long flashcardId);
}
