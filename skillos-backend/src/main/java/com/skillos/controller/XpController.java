package com.skillos.controller;

import com.skillos.entity.User;
import com.skillos.entity.XpTransaction;
import com.skillos.repository.XpTransactionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.skillos.repository.UserXpRepository;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class XpController {

    private final XpTransactionRepository xpTransactionRepository;
    private final UserXpRepository userXpRepository;

    @GetMapping("/xp/me")
    public ResponseEntity<Map<String, Object>> getMyXp(@AuthenticationPrincipal User user) {
        Map<String, Object> response = new HashMap<>();
        
        com.skillos.entity.UserXp userXp = userXpRepository.findByUserId(user.getId()).orElse(null);
        
        int totalXp = userXp != null ? userXp.getTotalXp() : 0;
        int currentLevel = userXp != null ? userXp.getCurrentLevel() : 1;
        
        response.put("total_xp", totalXp);
        response.put("current_level", currentLevel);
        
        int xpToNext = 100 - (totalXp % 100);
        response.put("xp_to_next_level", xpToNext);

        return ResponseEntity.ok(response);
    }

    @GetMapping("/xp/log")
    public ResponseEntity<Page<XpTransaction>> getXpLog(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal User user) {
        
        PageRequest pageRequest = PageRequest.of(page, size, Sort.by("awardedAt").descending());
        return ResponseEntity.ok(xpTransactionRepository.findByUserId(user.getId(), pageRequest));
    }


    @GetMapping("/dashboard/xp-chart")
    public ResponseEntity<List<com.skillos.dto.response.XpChartData>> getXpChart(
            @RequestParam(defaultValue = "month") String range,
            @AuthenticationPrincipal User user) {
        
        java.time.LocalDateTime startDate;
        switch (range.toLowerCase()) {
            case "week":
                startDate = java.time.LocalDateTime.now().minusDays(7);
                break;
            case "year":
                startDate = java.time.LocalDateTime.now().minusDays(365);
                break;
            case "month":
            default:
                startDate = java.time.LocalDateTime.now().minusDays(30);
                break;
        }

        return ResponseEntity.ok(xpTransactionRepository.getXpChartDataByDay(user.getId(), startDate));
    }
}
