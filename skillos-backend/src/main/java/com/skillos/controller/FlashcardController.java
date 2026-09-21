package com.skillos.controller;

import com.skillos.dto.request.FlashcardGenerateRequest;
import com.skillos.dto.request.FlashcardRequest;
import com.skillos.dto.request.FlashcardReviewRequest;
import com.skillos.entity.Flashcard;
import com.skillos.entity.FlashcardReview;
import com.skillos.entity.GenerationJob;
import com.skillos.entity.User;
import com.skillos.repository.GenerationJobRepository;
import com.skillos.service.FlashcardGeneratorService;
import com.skillos.service.FlashcardService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/flashcards")
@RequiredArgsConstructor
public class FlashcardController {

    private final FlashcardService flashcardService;
    private final FlashcardGeneratorService flashcardGeneratorService;
    private final GenerationJobRepository generationJobRepository;

    @PostMapping
    public ResponseEntity<Flashcard> createManualFlashcard(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody FlashcardRequest request) {
        Flashcard flashcard = flashcardService.createManualFlashcard(user, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(flashcard);
    }

    @GetMapping
    public ResponseEntity<List<Flashcard>> getAllFlashcards(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(flashcardService.getAllUserFlashcards(user.getId()));
    }

    @GetMapping("/study")
    public ResponseEntity<Map<String, Object>> getStudyBatch(
            @AuthenticationPrincipal User user,
            @RequestParam(required = false) String skill_name,
            @RequestParam(defaultValue = "10") int limit) {
        
        List<Flashcard> cards = flashcardService.getStudyBatch(user.getId(), skill_name, limit);
        return ResponseEntity.ok(Map.of("data", cards));
    }

    @PostMapping("/{id}/review")
    public ResponseEntity<FlashcardReview> submitReview(
            @PathVariable Long id,
            @AuthenticationPrincipal User user,
            @Valid @RequestBody FlashcardReviewRequest request) {
        
        FlashcardReview review = flashcardService.submitReview(id, user, request);
        return ResponseEntity.ok(review);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Flashcard> updateFlashcard(
            @PathVariable Long id,
            @AuthenticationPrincipal User user,
            @Valid @RequestBody FlashcardRequest request) {
        Flashcard updated = flashcardService.updateFlashcard(id, user, request);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteFlashcard(
            @PathVariable Long id,
            @AuthenticationPrincipal User user) {
        flashcardService.deleteFlashcard(id, user);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/generate")
    public ResponseEntity<Map<String, Object>> generateFlashcards(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody FlashcardGenerateRequest request) {

        String jobId = "gen_" + UUID.randomUUID().toString().replace("-", "");

        GenerationJob job = GenerationJob.builder()
                .jobId(jobId)
                .user(user)
                .jobType("flashcard_generation")
                .status("queued")
                .inputsJson("{\"skill_name\":\"" + request.getSkillName() + "\"}")
                .build();

        generationJobRepository.save(job);

        flashcardGeneratorService.generateFlashcardsAsync(job, user, request.getSkillName());

        Map<String, Object> response = new HashMap<>();
        response.put("job_id", jobId);
        response.put("status", "queued");

        return ResponseEntity.status(HttpStatus.ACCEPTED).body(response);
    }

    @GetMapping("/generate/status/{jobId}")
    public ResponseEntity<Map<String, Object>> getGenerationStatus(@PathVariable String jobId) {
        GenerationJob job = generationJobRepository.findByJobId(jobId)
                .orElseThrow(() -> new RuntimeException("Job not found"));

        Map<String, Object> response = new HashMap<>();
        response.put("job_id", job.getJobId());
        response.put("status", job.getStatus());
        response.put("progress_percent", job.getProgressPercent());

        if ("complete".equals(job.getStatus())) {
            response.put("result_id", job.getResultId());
        } else if ("failed".equals(job.getStatus())) {
            response.put("error", job.getErrorMessage());
        }

        return ResponseEntity.ok(response);
    }
}
