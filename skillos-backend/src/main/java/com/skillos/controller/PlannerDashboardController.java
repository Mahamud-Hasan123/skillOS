package com.skillos.controller;

import com.skillos.dto.response.PlannerDashboardResponse;
import com.skillos.entity.User;
import com.skillos.service.PlannerDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/planner")
@RequiredArgsConstructor
public class PlannerDashboardController {

    private final PlannerDashboardService plannerDashboardService;

    @GetMapping("/dashboard")
    public ResponseEntity<PlannerDashboardResponse> getDashboard(@AuthenticationPrincipal User user) {
        PlannerDashboardResponse dashboard = plannerDashboardService.getDashboard(user.getId());
        return ResponseEntity.ok(dashboard);
    }
}
