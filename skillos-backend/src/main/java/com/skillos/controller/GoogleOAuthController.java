package com.skillos.controller;

import com.skillos.entity.User;
import com.skillos.service.GoogleCalendarService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/v1/integrations/google")
@RequiredArgsConstructor
public class GoogleOAuthController {

    private final GoogleCalendarService googleCalendarService;

    /**
     * Get the Google OAuth URL to redirect the user to.
     */
    @GetMapping("/auth-url")
    public ResponseEntity<Map<String, String>> getAuthUrl(@AuthenticationPrincipal User user) {
        String url = googleCalendarService.getAuthorizationUrl(user.getId());
        return ResponseEntity.ok(Map.of("url", url));
    }

    /**
     * Handle the OAuth callback from Google.
     * In a production app, the frontend handles the redirect and passes the code here.
     * But for this prototype, we accept the code directly if testing via browser.
     */
    @GetMapping("/callback")
    public ResponseEntity<String> oauthCallback(
            @RequestParam("code") String code,
            @RequestParam("state") String state // We passed the User ID in the state
    ) {
        try {
            Long userId = Long.parseLong(state);
            // Wait, normally we need the User object here. 
            // In a real flow, if the frontend sends this as a POST, we just use @AuthenticationPrincipal.
            // Since it's a GET from the browser, we use the state as a shortcut.
            User mockUser = new User();
            mockUser.setId(userId);
            
            googleCalendarService.exchangeCodeAndSaveTokens(code, userId, mockUser);
            
            return ResponseEntity.ok("Successfully connected Google Calendar! You can close this tab and return to SkillOS.");
        } catch (Exception e) {
            log.error("Failed to exchange Google OAuth code", e);
            return ResponseEntity.status(500).body("Authentication failed: " + e.getMessage());
        }
    }
}
