package com.skillos.controller;

import com.skillos.dto.request.CreateRoutineRequest;
import com.skillos.dto.request.UpdateRoutineRequest;
import com.skillos.dto.response.RoutineResponse;
import com.skillos.entity.User;
import com.skillos.service.UserRoutineService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/routines")
@RequiredArgsConstructor
public class UserRoutineController {

    private final UserRoutineService userRoutineService;

    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllRoutines(@AuthenticationPrincipal User user) {
        List<RoutineResponse> routines = userRoutineService.getUserRoutines(user.getId());
        return ResponseEntity.ok(Map.of("data", routines));
    }

    @GetMapping("/day/{dayOfWeek}")
    public ResponseEntity<Map<String, Object>> getRoutinesByDay(
            @AuthenticationPrincipal User user,
            @PathVariable Integer dayOfWeek) {
        List<RoutineResponse> routines = userRoutineService.getRoutinesByDay(user.getId(), dayOfWeek);
        return ResponseEntity.ok(Map.of("data", routines));
    }

    @PostMapping
    public ResponseEntity<RoutineResponse> createRoutine(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody CreateRoutineRequest request) {
        RoutineResponse created = userRoutineService.createRoutine(user, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<RoutineResponse> updateRoutine(
            @PathVariable Long id,
            @AuthenticationPrincipal User user,
            @Valid @RequestBody UpdateRoutineRequest request) {
        RoutineResponse updated = userRoutineService.updateRoutine(id, user, request);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteRoutine(
            @PathVariable Long id,
            @AuthenticationPrincipal User user) {
        userRoutineService.deleteRoutine(id, user);
        return ResponseEntity.noContent().build();
    }
}
