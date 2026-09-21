package com.skillos.controller;

import com.skillos.dto.request.NoteRequest;
import com.skillos.entity.Note;
import com.skillos.entity.User;
import com.skillos.service.NoteService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/notes")
@RequiredArgsConstructor
public class NoteController {

    private final NoteService noteService;

    @GetMapping
    public ResponseEntity<Map<String, Object>> getUserNotes(@AuthenticationPrincipal User user) {
        List<Note> notes = noteService.getUserNotes(user.getId());
        return ResponseEntity.ok(Map.of("data", notes));
    }

    @PostMapping
    public ResponseEntity<Note> createNote(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody NoteRequest request) {
        Note createdNote = noteService.createNote(user, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdNote);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Note> updateNote(
            @PathVariable Long id,
            @AuthenticationPrincipal User user,
            @Valid @RequestBody NoteRequest request) {
        Note updatedNote = noteService.updateNote(id, user, request);
        return ResponseEntity.ok(updatedNote);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteNote(
            @PathVariable Long id,
            @AuthenticationPrincipal User user) {
        noteService.deleteNote(id, user);
        return ResponseEntity.noContent().build();
    }
}
