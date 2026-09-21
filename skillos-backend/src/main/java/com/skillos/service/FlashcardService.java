package com.skillos.service;

import com.skillos.dto.request.FlashcardRequest;
import com.skillos.dto.request.FlashcardReviewRequest;
import com.skillos.entity.Flashcard;
import com.skillos.entity.FlashcardReview;
import com.skillos.entity.Roadmap;
import com.skillos.entity.User;
import com.skillos.exception.ResourceNotFoundException;
import com.skillos.repository.FlashcardRepository;
import com.skillos.repository.FlashcardReviewRepository;
import com.skillos.repository.RoadmapRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FlashcardService {

    private final FlashcardRepository flashcardRepository;
    private final FlashcardReviewRepository flashcardReviewRepository;
    private final RoadmapRepository roadmapRepository;

    public Flashcard createManualFlashcard(User user, FlashcardRequest request) {
        Roadmap roadmap = null;
        if (request.getRoadmapId() != null) {
            roadmap = roadmapRepository.findById(request.getRoadmapId())
                    .orElseThrow(() -> new ResourceNotFoundException("Roadmap not found"));
            
            if (!roadmap.getUser().getId().equals(user.getId())) {
                throw new RuntimeException("Unauthorized to link flashcard to this roadmap");
            }
        }

        Flashcard flashcard = Flashcard.builder()
                .user(user)
                .roadmap(roadmap)
                .skillName(request.getSkillName())
                .question(request.getQuestion())
                .answer(request.getAnswer())
                .difficulty(request.getDifficulty())
                .mastery(0)
                .source("manual")
                .build();

        return flashcardRepository.save(flashcard);
    }

    public List<Flashcard> getAllUserFlashcards(Long userId) {
        return flashcardRepository.findByUserIdOrderByIdDesc(userId);
    }

    public List<Flashcard> getStudyBatch(Long userId, String skillName, int limit) {
        if (skillName != null && !skillName.isEmpty()) {
            return flashcardRepository.findRandomStudyCardsBySkill(userId, skillName, limit);
        }
        return flashcardRepository.findRandomStudyCards(userId, limit);
    }

    @Transactional
    public FlashcardReview submitReview(Long flashcardId, User user, FlashcardReviewRequest request) {
        Flashcard flashcard = flashcardRepository.findById(flashcardId)
                .orElseThrow(() -> new ResourceNotFoundException("Flashcard not found"));

        if (!flashcard.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized to review this flashcard");
        }

        // Calculate mastery
        int currentMastery = flashcard.getMastery();
        int newMastery;

        switch (request.getDifficulty()) {
            case "easy":
                newMastery = Math.min(100, currentMastery + 20);
                break;
            case "medium":
                newMastery = Math.min(100, currentMastery + 10);
                break;
            case "hard":
                newMastery = Math.min(100, currentMastery + 5);
                break;
            case "forgot":
                newMastery = 0;
                break;
            default:
                throw new IllegalArgumentException("Invalid difficulty level");
        }

        flashcard.setMastery(newMastery);
        flashcard.setDifficulty(request.getDifficulty());
        flashcard = flashcardRepository.save(flashcard);

        FlashcardReview review = FlashcardReview.builder()
                .flashcard(flashcard)
                .user(user)
                .difficultySet(request.getDifficulty())
                .masteryAfter(newMastery)
                .build();

        return flashcardReviewRepository.save(review);
    }

    @Transactional
    public Flashcard updateFlashcard(Long id, User user, FlashcardRequest request) {
        Flashcard flashcard = flashcardRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Flashcard not found"));

        if (!flashcard.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized to update this flashcard");
        }

        flashcard.setQuestion(request.getQuestion());
        flashcard.setAnswer(request.getAnswer());
        
        // Optional updates if provided
        if (request.getSkillName() != null) {
            flashcard.setSkillName(request.getSkillName());
        }
        if (request.getDifficulty() != null) {
            flashcard.setDifficulty(request.getDifficulty());
        }

        return flashcardRepository.save(flashcard);
    }

    @Transactional
    public void deleteFlashcard(Long id, User user) {
        Flashcard flashcard = flashcardRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Flashcard not found"));

        if (!flashcard.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized to delete this flashcard");
        }

        // Delete associated reviews first due to foreign key constraints if they exist
        flashcardReviewRepository.deleteByFlashcardId(id);
        flashcardRepository.delete(flashcard);
    }
}
