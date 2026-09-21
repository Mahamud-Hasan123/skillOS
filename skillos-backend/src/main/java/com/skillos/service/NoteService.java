package com.skillos.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.skillos.dto.request.NoteRequest;
import com.skillos.entity.Note;
import com.skillos.entity.Roadmap;
import com.skillos.entity.User;
import com.skillos.exception.ResourceNotFoundException;
import com.skillos.repository.NoteRepository;
import com.skillos.repository.RoadmapRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NoteService {

    private final NoteRepository noteRepository;
    private final RoadmapRepository roadmapRepository;
    private final ObjectMapper objectMapper;

    public List<Note> getUserNotes(Long userId) {
        return noteRepository.findByUserId(userId);
    }

    public Note createNote(User user, NoteRequest request) {
        Roadmap roadmap = null;
        if (request.getRoadmapId() != null) {
            roadmap = roadmapRepository.findById(request.getRoadmapId())
                    .orElseThrow(() -> new ResourceNotFoundException("Roadmap not found"));
            
            if (!roadmap.getUser().getId().equals(user.getId())) {
                throw new RuntimeException("Unauthorized to add note to this roadmap");
            }
        }

        validateResourceLinks(request.getResourceLinks());

        String resourceLinksJson = null;
        try {
            if (request.getResourceLinks() != null && !request.getResourceLinks().isEmpty()) {
                resourceLinksJson = objectMapper.writeValueAsString(request.getResourceLinks());
            }
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to serialize resource links", e);
        }

        Note note = Note.builder()
                .user(user)
                .roadmap(roadmap)
                .dayNumber(request.getDayNumber())
                .skillName(request.getSkillName())
                .content(request.getContent())
                .resourceLinks(resourceLinksJson)
                .usedForFlashcardGen(false)
                .build();

        return noteRepository.save(note);
    }

    public Note updateNote(Long noteId, User user, NoteRequest request) {
        Note note = noteRepository.findById(noteId)
                .orElseThrow(() -> new ResourceNotFoundException("Note not found"));

        if (!note.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized to update this note");
        }

        validateResourceLinks(request.getResourceLinks());

        try {
            if (request.getResourceLinks() != null && !request.getResourceLinks().isEmpty()) {
                note.setResourceLinks(objectMapper.writeValueAsString(request.getResourceLinks()));
            } else {
                note.setResourceLinks(null);
            }
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to serialize resource links", e);
        }

        note.setContent(request.getContent());
        
        if (request.getSkillName() != null) {
            note.setSkillName(request.getSkillName());
        }

        return noteRepository.save(note);
    }

    public void deleteNote(Long noteId, User user) {
        Note note = noteRepository.findById(noteId)
                .orElseThrow(() -> new ResourceNotFoundException("Note not found"));

        if (!note.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized to delete this note");
        }

        noteRepository.delete(note);
    }

    private void validateResourceLinks(List<String> links) {
        if (links == null || links.isEmpty()) return;

        for (String link : links) {
            try {
                String urlToParse = link;
                if (!urlToParse.startsWith("http://") && !urlToParse.startsWith("https://")) {
                    urlToParse = "http://" + urlToParse;
                }
                new URI(urlToParse);
            } catch (URISyntaxException e) {
                throw new RuntimeException("Invalid URL format: " + link);
            }
        }
    }
}
