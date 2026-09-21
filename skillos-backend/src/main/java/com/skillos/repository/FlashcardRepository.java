package com.skillos.repository;

import com.skillos.entity.Flashcard;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

@Repository
public interface FlashcardRepository extends JpaRepository<Flashcard, Long> {
    
    List<Flashcard> findByUserIdOrderByIdDesc(Long userId);

    @Query(value = "SELECT * FROM flashcards WHERE user_id = :userId ORDER BY RAND() LIMIT :limit", nativeQuery = true)
    List<Flashcard> findRandomStudyCards(@Param("userId") Long userId, @Param("limit") int limit);

    @Query(value = "SELECT * FROM flashcards WHERE user_id = :userId AND skill_name = :skillName ORDER BY RAND() LIMIT :limit", nativeQuery = true)
    List<Flashcard> findRandomStudyCardsBySkill(@Param("userId") Long userId, @Param("skillName") String skillName, @Param("limit") int limit);
}
