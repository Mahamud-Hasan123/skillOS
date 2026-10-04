package com.skillos.service;

import com.google.api.client.auth.oauth2.AuthorizationCodeRequestUrl;
import com.google.api.client.auth.oauth2.Credential;
import com.google.api.client.auth.oauth2.TokenResponse;
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.google.api.client.googleapis.auth.oauth2.GoogleClientSecrets;
import com.google.api.client.googleapis.auth.oauth2.GoogleCredential;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.http.HttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.services.calendar.Calendar;
import com.google.api.services.calendar.CalendarScopes;
import com.google.api.services.calendar.model.Event;
import com.google.api.services.calendar.model.Events;
import com.skillos.entity.User;
import com.skillos.entity.UserIntegration;
import com.skillos.repository.UserIntegrationRepository;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class GoogleCalendarService {

    private final UserIntegrationRepository userIntegrationRepository;

    @Value("${application.google.client-id}")
    private String clientId;

    @Value("${application.google.client-secret}")
    private String clientSecret;

    @Value("${application.google.redirect-uri}")
    private String redirectUri;

    private static final JsonFactory JSON_FACTORY = GsonFactory.getDefaultInstance();
    private static final List<String> SCOPES = Collections.singletonList(CalendarScopes.CALENDAR_READONLY);
    private HttpTransport httpTransport;
    private GoogleAuthorizationCodeFlow flow;

    @PostConstruct
    public void init() throws GeneralSecurityException, IOException {
        this.httpTransport = GoogleNetHttpTransport.newTrustedTransport();
        GoogleClientSecrets.Details web = new GoogleClientSecrets.Details();
        web.setClientId(clientId);
        web.setClientSecret(clientSecret);

        GoogleClientSecrets clientSecrets = new GoogleClientSecrets();
        clientSecrets.setWeb(web);

        this.flow = new GoogleAuthorizationCodeFlow.Builder(
                httpTransport, JSON_FACTORY, clientSecrets, SCOPES)
                .setAccessType("offline") // Required to get a refresh token
                .setApprovalPrompt("force")
                .build();
    }

    /**
     * Generate the Google Login URL for a specific user.
     */
    public String getAuthorizationUrl(Long userId) {
        AuthorizationCodeRequestUrl authorizationUrl = flow.newAuthorizationUrl()
                .setRedirectUri(redirectUri)
                .setState(userId.toString()); // Pass the user ID through the OAuth flow
        return authorizationUrl.build();
    }

    /**
     * Exchange the authorization code for tokens and save them.
     */
    public void exchangeCodeAndSaveTokens(String code, Long userId, User user) throws IOException {
        TokenResponse response = flow.newTokenRequest(code)
                .setRedirectUri(redirectUri)
                .execute();

        String accessToken = response.getAccessToken();
        String refreshToken = response.getRefreshToken(); // Can be null if already authorized previously

        Optional<UserIntegration> existingIntegration = userIntegrationRepository.findByUserIdAndProvider(userId, "google");
        
        UserIntegration integration = existingIntegration.orElseGet(() -> UserIntegration.builder()
                .user(user)
                .provider("google")
                .build());

        integration.setAccessToken(accessToken);
        if (refreshToken != null) {
            integration.setRefreshToken(refreshToken);
        }

        userIntegrationRepository.save(integration);
        log.info("Successfully saved Google Calendar tokens for user {}", userId);
    }

    /**
     * Fetch events for a specific date from Google Calendar.
     */
    public List<UserRoutineService.TimeWindow> fetchBlockedTimes(User user, LocalDate date) {
        Optional<UserIntegration> integrationOpt = userIntegrationRepository.findByUserIdAndProvider(user.getId(), "google");
        
        if (integrationOpt.isEmpty() || integrationOpt.get().getRefreshToken() == null) {
            return Collections.emptyList(); // Not connected
        }

        try {
            UserIntegration integration = integrationOpt.get();
            Credential credential = new GoogleCredential.Builder()
                    .setTransport(httpTransport)
                    .setJsonFactory(JSON_FACTORY)
                    .setClientSecrets(clientId, clientSecret)
                    .build()
                    .setRefreshToken(integration.getRefreshToken());

            // Check if access token is present, else credential will refresh it automatically using refresh token
            if (integration.getAccessToken() != null) {
                credential.setAccessToken(integration.getAccessToken());
            }

            Calendar service = new Calendar.Builder(httpTransport, JSON_FACTORY, credential)
                    .setApplicationName("SkillOS")
                    .build();

            // Set time boundaries for the API request (Start of day to End of day)
            ZonedDateTime startOfDay = date.atStartOfDay(ZoneId.of(user.getTimezone()));
            ZonedDateTime endOfDay = date.plusDays(1).atStartOfDay(ZoneId.of(user.getTimezone()));

            com.google.api.client.util.DateTime timeMin = new com.google.api.client.util.DateTime(startOfDay.toInstant().toEpochMilli());
            com.google.api.client.util.DateTime timeMax = new com.google.api.client.util.DateTime(endOfDay.toInstant().toEpochMilli());

            Events events = service.events().list("primary")
                    .setTimeMin(timeMin)
                    .setTimeMax(timeMax)
                    .setOrderBy("startTime")
                    .setSingleEvents(true)
                    .execute();

            List<Event> items = events.getItems();
            if (items == null || items.isEmpty()) {
                return Collections.emptyList();
            }

            // Map Google Events to our TimeWindow format
            return items.stream()
                    .filter(event -> event.getStart().getDateTime() != null) // Ignore all-day events for scheduling
                    .map(event -> {
                        // Convert Google's DateTime to java.time.LocalTime
                        java.time.LocalTime startTime = java.time.Instant.ofEpochMilli(event.getStart().getDateTime().getValue())
                                .atZone(ZoneId.of(user.getTimezone()))
                                .toLocalTime();
                        java.time.LocalTime endTime = java.time.Instant.ofEpochMilli(event.getEnd().getDateTime().getValue())
                                .atZone(ZoneId.of(user.getTimezone()))
                                .toLocalTime();
                        
                        return new UserRoutineService.TimeWindow(startTime, endTime, false, event.getSummary(), "google_calendar");
                    })
                    .collect(Collectors.toList());

        } catch (Exception e) {
            log.error("Failed to fetch Google Calendar events for user {}", user.getId(), e);
            return Collections.emptyList();
        }
    }
}
