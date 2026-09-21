package com.skillos.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.skillos.entity.Flashcard;
import com.skillos.entity.FlashcardBatch;
import com.skillos.entity.GenerationJob;
import com.skillos.entity.Note;
import com.skillos.entity.User;
import com.skillos.repository.FlashcardBatchRepository;
import com.skillos.repository.FlashcardRepository;
import com.skillos.repository.GenerationJobRepository;
import com.skillos.repository.NoteRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class FlashcardGeneratorService {

    private final GeminiService geminiService;
    private final GenerationJobRepository generationJobRepository;
    private final NoteRepository noteRepository;
    private final FlashcardRepository flashcardRepository;
    private final FlashcardBatchRepository flashcardBatchRepository;
    private final ObjectMapper objectMapper;

    @Async("taskExecutor")
    @Transactional
    public void generateFlashcardsAsync(GenerationJob job, User user, String skillName) {
        try {
            job.setStatus("processing");
            generationJobRepository.save(job);

            log.info("Starting AI flashcard generation for Job ID: {}", job.getJobId());

            List<Note> unusedNotes = noteRepository.findByUserIdAndUsedForFlashcardGenFalse(user.getId());
            
            if (unusedNotes.isEmpty()) {
                throw new RuntimeException("No unused notes found for flashcard generation");
            }

            StringBuilder notesContent = new StringBuilder();
            for (Note note : unusedNotes) {
                // Filter by skillName if provided and if note has a skillName
                if (skillName != null && !skillName.isEmpty() && note.getSkillName() != null) {
                    if (!note.getSkillName().equalsIgnoreCase(skillName)) {
                        continue;
                    }
                }
                notesContent.append(note.getContent()).append("\n\n");
            }

            if (notesContent.isEmpty()) {
                throw new RuntimeException("No notes matched the specified skill name");
            }

            String jsonResponse = geminiService.generateFlashcardsJson(notesContent.toString());

            JsonNode root = objectMapper.readTree(jsonResponse);

            int cardsCreated = 0;
            if (root.isArray()) {
                for (JsonNode cardNode : root) {
                    Flashcard flashcard = Flashcard.builder()
                            .user(user)
                            .skillName(skillName)
                            .question(cardNode.get("question").asText())
                            .answer(cardNode.get("answer").asText())
                            .mastery(0)
                            .source("auto_generated")
                            .build();
                    flashcardRepository.save(flashcard);
                    cardsCreated++;
                }
            }

            if (cardsCreated > 0) {
                // Mark notes as used
                for (Note note : unusedNotes) {
                    note.setUsedForFlashcardGen(true);
                    noteRepository.save(note);
                }

                // Save batch record
                FlashcardBatch batch = FlashcardBatch.builder()
                        .user(user)
                        .cardCount(cardsCreated)
                        .build();
                flashcardBatchRepository.save(batch);

                job.setResultId(batch.getId());
            }

            job.setStatus("complete");
            job.setProgressPercent(100);
            job.setCompletedAt(LocalDateTime.now());
            generationJobRepository.save(job);

            log.info("Generated {} flashcards for Job ID: {}", cardsCreated, job.getJobId());

        } catch (Exception e) {
            log.error("Flashcard generation failed for Job ID: {}", job.getJobId(), e);
            job.setStatus("failed");
            job.setErrorMessage(e.getMessage());
            job.setCompletedAt(LocalDateTime.now());
            generationJobRepository.save(job);
        }
    }
}
