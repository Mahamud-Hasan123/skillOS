package com.skillos.planner;

import com.skillos.entity.DailySchedule;
import com.skillos.entity.PlannerTask;
import com.skillos.entity.User;
import com.skillos.entity.UserRoutine;
import com.skillos.repository.DailyScheduleRepository;
import com.skillos.repository.DurationHistoryRepository;
import com.skillos.repository.PlannerTaskRepository;
import com.skillos.repository.UserRepository;
import com.skillos.repository.UserRoutineRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@ActiveProfiles("test") // Ensures we don't accidentally run this against production data if profiles are set
public class SchedulingIntegrationTest {

    @Autowired
    private SchedulingService schedulingService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserRoutineRepository userRoutineRepository;

    @Autowired
    private PlannerTaskRepository plannerTaskRepository;

    @Autowired
    private DailyScheduleRepository dailyScheduleRepository;

    @Autowired
    private DurationHistoryRepository durationHistoryRepository;

    private User testUser;
    private LocalDate testDate;

    @BeforeEach
    public void setup() {
        // 1. Create a test user
        testUser = User.builder()
                .fullName("Test User")
                .email("test.planner." + java.util.UUID.randomUUID().toString() + "@skillos.com")
                .passwordHash("hashedpassword")
                .build();
        testUser = userRepository.save(testUser);

        testDate = LocalDate.now();
        int dayOfWeek = testDate.getDayOfWeek().getValue() % 7; // 0=Sunday...6=Saturday

        // 2. Setup Routines (Available time slots)
        // Morning Slot: 09:00 - 11:00 (120 mins)
        UserRoutine morningSlot = UserRoutine.builder()
                .user(testUser)
                .dayOfWeek(dayOfWeek)
                .startTime(LocalTime.of(9, 0))
                .endTime(LocalTime.of(11, 0))
                .isAvailable(true)
                .label("Morning Deep Work")
                .build();
        userRoutineRepository.save(morningSlot);

        // Afternoon Slot: 13:00 - 15:00 (120 mins)
        UserRoutine afternoonSlot = UserRoutine.builder()
                .user(testUser)
                .dayOfWeek(dayOfWeek)
                .startTime(LocalTime.of(13, 0))
                .endTime(LocalTime.of(15, 0))
                .isAvailable(true)
                .label("Afternoon Focus")
                .build();
        userRoutineRepository.save(afternoonSlot);

        // 3. Setup Tasks
        // Task A: Critical (60 min)
        PlannerTask taskA = PlannerTask.builder()
                .user(testUser)
                .title("Critical Bug Fix")
                .estimatedMinutes(60)
                .priority("critical")
                .status("pending")
                .sourceType("custom")
                .build();
        plannerTaskRepository.save(taskA);

        // Task B: Medium (45 min)
        PlannerTask taskB = PlannerTask.builder()
                .user(testUser)
                .title("Write Documentation")
                .estimatedMinutes(45)
                .priority("medium")
                .status("pending")
                .sourceType("custom")
                .build();
        plannerTaskRepository.save(taskB);

        // Task C: High (30 min)
        PlannerTask taskC = PlannerTask.builder()
                .user(testUser)
                .title("Team Meeting Preparation")
                .estimatedMinutes(30)
                .priority("high")
                .status("pending")
                .sourceType("custom")
                .build();
        plannerTaskRepository.save(taskC);
    }

    @AfterEach
    public void cleanup() {
        // Cleanup all records created by the test
        dailyScheduleRepository.deleteAll();
        durationHistoryRepository.deleteAll();
        plannerTaskRepository.deleteAll();
        userRoutineRepository.deleteAll();
        userRepository.delete(testUser);
    }

    @Test
    public void testGenerateSchedule_SuccessfullySchedulesTasks() {
        // Act: Run the A* scheduler via the orchestrator
        DailySchedule schedule = schedulingService.generateSchedule(testUser, testDate);

        // Assert: The schedule was persisted and returned
        assertThat(schedule).isNotNull();
        assertThat(schedule.getIsActive()).isTrue();
        assertThat(schedule.getEntries()).hasSize(3); // All 3 tasks should fit (135 total mins vs 240 available)

        // The tasks should be ordered properly by priority.
        // Highest priority should be scheduled earliest (assuming they all fit without deadline constraints)
        List<String> orderedTitles = schedule.getEntries().stream()
                .sorted((e1, e2) -> e1.getStartTime().compareTo(e2.getStartTime()))
                .map(e -> e.getPlannerTask().getTitle())
                .toList();

        // 1. Critical, 2. High, 3. Medium
        assertThat(orderedTitles.get(0)).isEqualTo("Critical Bug Fix");
        assertThat(orderedTitles.get(1)).isEqualTo("Team Meeting Preparation");
        assertThat(orderedTitles.get(2)).isEqualTo("Write Documentation");

        // Verify time constraints: No task should overlap, and they should fit in the slots
        schedule.getEntries().forEach(entry -> {
            LocalTime start = entry.getStartTime();
            LocalTime end = entry.getEndTime();
            
            // Should be either in morning slot or afternoon slot boundaries
            boolean inMorning = !start.isBefore(LocalTime.of(9, 0)) && !end.isAfter(LocalTime.of(11, 0));
            boolean inAfternoon = !start.isBefore(LocalTime.of(13, 0)) && !end.isAfter(LocalTime.of(15, 0));
            
            assertThat(inMorning || inAfternoon).isTrue();
        });
    }
}
