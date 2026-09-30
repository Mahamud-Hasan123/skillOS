# AI Adaptive Task Planner — Execution Plan

> **Purpose:** This document is the single source of truth for implementing the Adaptive Task Planner feature in the SkillOS application. Any AI or developer reading this file should be able to understand *what* we are building, *why*, and *exactly how* to implement it step by step — without needing any other context.

---

## 1. Project Context

### 1.1 What is SkillOS?

SkillOS is a gamified learning platform. Users generate AI-powered **learning roadmaps** (via the Gemini API), then work through daily tasks to learn new skills. The app tracks progress, awards XP, and maintains streaks.

### 1.2 What is the Adaptive Task Planner?

The Adaptive Task Planner is a new core feature that takes a user's tasks from multiple sources (roadmaps, manual input, and eventually external platforms), combines them with the user's available time (their "routine"), and uses **CSP (Constraint Satisfaction Problem)** + **A\* Search** algorithms to generate an optimized, conflict-free daily schedule. The schedule self-corrects in real time as the user's day unfolds (tasks take longer, get skipped, etc.).

### 1.3 What already exists?

| Component | Status | Location |
|---|---|---|
| Spring Boot 3.2.5 backend (Java 17) | ✅ Built | `skillos-backend/` |
| Auth (JWT, Spring Security) | ✅ Built | `entity/User.java`, `service/AuthService.java`, `security/` |
| Gemini AI integration | ✅ Built | `service/GeminiService.java` — calls Gemini REST API |
| Roadmap generation (async via GenerationJob) | ✅ Built | `service/RoadmapGeneratorService.java` |
| Entities: `User`, `Roadmap`, `RoadmapTask`, `DailyTask`, `GenerationJob` | ✅ Built | `entity/` |
| Daily task tracking (`time_spent_seconds`, `estimated_time_minutes`, `completed_at`) | ✅ Partial | `entity/DailyTask.java` |
| `custom_tasks` table in DB | ✅ Exists in DB | `skillos_v1.sql` line 132 — **no JPA entity yet** |
| WebSocket support | ✅ Built | `config/WebSocketConfig.java` |
| Vite + React frontend | ✅ Built | `skillos-frontend/` |
| MySQL database (`skillos_v1`) | ✅ Running | `spring.jpa.hibernate.ddl-auto=none` — can switch to `update` when adding new tables |

### 1.4 Key architectural constraints

- **`ddl-auto` is currently `none` but can be switched to `update`**: When we need to create the new planner tables, we temporarily set `spring.jpa.hibernate.ddl-auto=update` so Hibernate auto-generates them from our `@Entity` classes. Once the tables are created, we can switch it back to `none` or leave it on `update` during development.
- **Existing DB has many unused tables**: We are ignoring them (no entity mapping). Only map what we need.
- **Lombok** is used throughout for `@Data`, `@Builder`, `@AllArgsConstructor`, `@NoArgsConstructor`.
- **Async pattern**: Long-running AI tasks use the `GenerationJob` + `@Async("taskExecutor")` pattern with WebSocket progress updates.

---

## 2. High-Level Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                        DATA SOURCES                              │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────────┐    │
│  │ RoadmapTask │  │  CustomTask  │  │ (Future) External    │    │
│  │ (existing)  │  │  (user-added)│  │ Google Cal / GitHub  │    │
│  └──────┬──────┘  └──────┬───────┘  └──────────┬───────────┘    │
│         └────────────────┼─────────────────────┘                │
│                          ▼                                       │
│               ┌──────────────────┐                               │
│               │ Task Collector   │  Normalize all sources into   │
│               │ Service          │  a common PlannerTask format  │
│               └────────┬─────────┘                               │
│                        ▼                                         │
│  ┌───────────────────────────────────────────────┐               │
│  │            User Routine Service               │               │
│  │  (available windows, fixed events, breaks)    │               │
│  └────────────────────┬──────────────────────────┘               │
│                       ▼                                          │
│  ┌───────────────────────────────────────────────┐               │
│  │          Scheduling Engine                    │               │
│  │  ┌─────────┐    ┌────────────┐                │               │
│  │  │   CSP   │───▶│    A*      │                │               │
│  │  │ (filter)│    │  (search)  │                │               │
│  │  └─────────┘    └────────────┘                │               │
│  └────────────────────┬──────────────────────────┘               │
│                       ▼                                          │
│          ┌────────────────────────┐                               │
│          │   DailySchedule       │  Persisted schedule           │
│          │   (time-slotted plan) │  with version history         │
│          └───────────┬───────────┘                               │
│                      ▼                                           │
│  ┌───────────────────────────────────────────────┐               │
│  │       Execution Tracker                       │               │
│  │  (start/pause/complete → compare est vs act)  │               │
│  │  (triggers rescheduling on deviation)          │               │
│  └───────────────────────────────────────────────┘               │
└──────────────────────────────────────────────────────────────────┘
```

---

## 3. Implementation Phases

We build this in **5 phases**, each one delivering a working increment.

---

### Phase 1: Database Schema & Core Entities

**Goal:** Create the new tables and JPA entities needed for the planner.

#### 1.1 Creating the new tables

**Approach:** Set `spring.jpa.hibernate.ddl-auto=update` in `application.properties`, then create the JPA entity classes (section 1.2). Hibernate will auto-generate the tables on the next application startup.

> **TIP:** Optionally, keep a reference SQL file at `skillos-backend/src/main/resources/db/migration/V2__task_planner_schema.sql` for documentation purposes, but it does NOT need to be run manually.

**Tables that Hibernate will create (reference schema):**

```sql
-- 1. User routines (availability windows)
CREATE TABLE user_routines (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT UNSIGNED NOT NULL,
    day_of_week     TINYINT NOT NULL COMMENT '0=Sunday, 1=Monday ... 6=Saturday',
    start_time      TIME NOT NULL,
    end_time        TIME NOT NULL,
    is_available    BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'TRUE=available window, FALSE=fixed event',
    label           VARCHAR(255) DEFAULT NULL COMMENT 'e.g. "Morning Study", "CS101 Class"',
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_day (user_id, day_of_week)
);

-- 2. Planner tasks (normalized from all sources)
CREATE TABLE planner_tasks (
    id                      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id                 BIGINT UNSIGNED NOT NULL,
    source_type             ENUM('roadmap', 'custom', 'external') NOT NULL,
    source_id               BIGINT UNSIGNED DEFAULT NULL COMMENT 'FK to roadmap_tasks.id or custom_tasks.id',
    title                   VARCHAR(500) NOT NULL,
    description             TEXT DEFAULT NULL,
    estimated_minutes       INT UNSIGNED NOT NULL DEFAULT 30,
    priority                ENUM('low', 'medium', 'high', 'critical') NOT NULL DEFAULT 'medium',
    deadline                DATETIME DEFAULT NULL,
    category                VARCHAR(100) DEFAULT NULL,
    dependency_task_id      BIGINT UNSIGNED DEFAULT NULL COMMENT 'Must complete this task first',
    is_recurring            BOOLEAN NOT NULL DEFAULT FALSE,
    status                  ENUM('pending', 'scheduled', 'in_progress', 'completed', 'skipped') NOT NULL DEFAULT 'pending',
    created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (dependency_task_id) REFERENCES planner_tasks(id) ON DELETE SET NULL,
    INDEX idx_user_status (user_id, status),
    INDEX idx_user_deadline (user_id, deadline)
);

-- 3. Daily schedules (the generated plan for a specific day)
CREATE TABLE daily_schedules (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT UNSIGNED NOT NULL,
    schedule_date   DATE NOT NULL,
    version         INT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Increments on each reschedule',
    is_active       BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Only one active version per day',
    generated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes           TEXT DEFAULT NULL COMMENT 'Reason for rescheduling',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uq_user_date_version (user_id, schedule_date, version),
    INDEX idx_user_date_active (user_id, schedule_date, is_active)
);

-- 4. Schedule entries (individual time slots within a daily schedule)
CREATE TABLE schedule_entries (
    id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    schedule_id         BIGINT UNSIGNED NOT NULL,
    planner_task_id     BIGINT UNSIGNED NOT NULL,
    start_time          TIME NOT NULL,
    end_time            TIME NOT NULL,
    slot_order          INT UNSIGNED NOT NULL COMMENT 'Sequence position in the schedule',
    status              ENUM('pending', 'in_progress', 'completed', 'skipped', 'overrun') NOT NULL DEFAULT 'pending',
    actual_start_time   TIME DEFAULT NULL,
    actual_end_time     TIME DEFAULT NULL,
    actual_minutes      INT UNSIGNED DEFAULT NULL,
    started_at          TIMESTAMP NULL DEFAULT NULL,
    completed_at        TIMESTAMP NULL DEFAULT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (schedule_id) REFERENCES daily_schedules(id) ON DELETE CASCADE,
    FOREIGN KEY (planner_task_id) REFERENCES planner_tasks(id) ON DELETE CASCADE,
    INDEX idx_schedule_order (schedule_id, slot_order)
);

-- 5. Duration history (for learning from past estimates)
CREATE TABLE duration_history (
    id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id             BIGINT UNSIGNED NOT NULL,
    planner_task_id     BIGINT UNSIGNED NOT NULL,
    estimated_minutes   INT UNSIGNED NOT NULL,
    actual_minutes      INT UNSIGNED NOT NULL,
    category            VARCHAR(100) DEFAULT NULL,
    recorded_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (planner_task_id) REFERENCES planner_tasks(id) ON DELETE CASCADE,
    INDEX idx_user_category (user_id, category)
);
```

#### 1.2 JPA Entities to create

Create the following files under `com.skillos.entity`:

| File | Maps to table | Key relationships |
|---|---|---|
| `UserRoutine.java` | `user_routines` | `@ManyToOne → User` |
| `PlannerTask.java` | `planner_tasks` | `@ManyToOne → User`, self-referencing `dependency` |
| `DailySchedule.java` | `daily_schedules` | `@ManyToOne → User`, `@OneToMany → ScheduleEntry` |
| `ScheduleEntry.java` | `schedule_entries` | `@ManyToOne → DailySchedule`, `@ManyToOne → PlannerTask` |
| `DurationHistory.java` | `duration_history` | `@ManyToOne → User`, `@ManyToOne → PlannerTask` |

#### 1.3 Also create a JPA entity for the existing `custom_tasks` table

The `custom_tasks` table already exists in the DB (see `skillos_v1.sql` line 132) but has no entity class. Create `CustomTask.java` mapping to it.

---

### Phase 2: User Routine & Task Management APIs

**Goal:** Let users define their daily availability and manually add/manage tasks.

#### 2.1 User Routine CRUD

Create `UserRoutineController.java` and `UserRoutineService.java`.

| Endpoint | Method | Description |
|---|---|---|
| `/api/v1/routines` | `GET` | Get all routine slots for the authenticated user |
| `/api/v1/routines` | `POST` | Add a new availability window or fixed event |
| `/api/v1/routines/{id}` | `PUT` | Update a routine slot |
| `/api/v1/routines/{id}` | `DELETE` | Remove a routine slot |
| `/api/v1/routines/day/{dayOfWeek}` | `GET` | Get routine for a specific day (0–6) |

**Business rules:**
- Validate that time windows don't overlap for the same `day_of_week`.
- `is_available=true` means the user CAN work. `is_available=false` means this is a fixed event (class, meeting) — it blocks scheduling.
- The service should be able to compute "free slots" for a given day by subtracting fixed events from available windows.

#### 2.2 Planner Task CRUD

Create `PlannerTaskController.java` and `PlannerTaskService.java`.

| Endpoint | Method | Description |
|---|---|---|
| `/api/v1/planner/tasks` | `GET` | List user's planner tasks (filterable by `status`, `priority`, `category`) |
| `/api/v1/planner/tasks` | `POST` | Manually add a task |
| `/api/v1/planner/tasks/{id}` | `PUT` | Update a task |
| `/api/v1/planner/tasks/{id}` | `DELETE` | Delete a task |
| `/api/v1/planner/tasks/import/roadmap/{roadmapId}` | `POST` | Import pending tasks from a roadmap into `planner_tasks` |

**Business rules:**
- When importing from a roadmap, copy `RoadmapTask.title`, `RoadmapTask.dayNumber` (to derive a deadline), and set `source_type='roadmap'`, `source_id=roadmapTask.id`.
- Validate that `estimated_minutes > 0`.
- Prevent duplicate imports (check `source_type` + `source_id` combo).
- The `dependency_task_id` must reference another `PlannerTask` owned by the same user.

---

### Phase 3: Scheduling Engine (CSP + A*)

**Goal:** Build the core algorithmic engine that generates optimal daily schedules.

> **IMPORTANT:** This is a pure backend computation with no external API calls. It runs synchronously for daily schedules (the search space is small enough: typically 5–15 tasks in a 12–16 hour day).

#### 3.1 Data model for the engine

Create a `planner` package: `com.skillos.planner`.

```
planner/
├── model/
│   ├── TimeSlot.java          // start: LocalTime, end: LocalTime
│   ├── ScheduleState.java     // current partial assignment of tasks to slots
│   └── ScheduleCandidate.java // A complete assignment with a cost score
├── csp/
│   └── ConstraintChecker.java // validates a ScheduleState against all constraints
├── astar/
│   ├── AStarScheduler.java    // the A* search implementation
│   └── ScheduleHeuristic.java // h(n) estimation
└── SchedulingService.java     // orchestrates CSP + A*, entry point
```

#### 3.2 CSP Constraint Checker

`ConstraintChecker.java` should enforce these hard constraints on any proposed schedule state:

| # | Constraint | Description |
|---|---|---|
| C1 | **No overlap** | No two tasks occupy the same time |
| C2 | **Fit in available windows** | Tasks can only be placed within `is_available=true` slots |
| C3 | **Respect fixed events** | Never schedule over `is_available=false` slots |
| C4 | **Dependencies** | If task B depends on task A, A must be scheduled before B |
| C5 | **Deadlines** | Tasks with a deadline today must be included in the schedule |
| C6 | **Duration fit** | A task's `estimated_minutes` must fit entirely within its assigned time slot |

The checker returns `true/false` for a given state plus a list of violated constraints if `false`.

#### 3.3 A* Search

`AStarScheduler.java` searches for the best task sequence.

**State definition:**
- `currentTime`: the next available time in the schedule
- `scheduledTasks`: ordered list of tasks already placed
- `remainingTasks`: set of tasks not yet placed

**Actions:**
- Pick a task from `remainingTasks` and assign it to the next available slot starting at `currentTime`.

**Goal:**
- `remainingTasks` is empty, OR all remaining time is consumed.

**Cost function `g(n)`:**
- Accumulated penalty score. Penalize:
  - Missed deadlines (heavy penalty)
  - Low-priority tasks scheduled before high-priority ones (moderate penalty)
  - Large gaps between tasks (light penalty)

**Heuristic `h(n)`:**
- Estimate the minimum remaining penalty. For example: count remaining tasks with deadlines that cannot possibly be met given remaining time. This must be **admissible** (never overestimates) for A* to find the optimal solution.

**Output:**
- A `ScheduleCandidate` containing an ordered list of `(PlannerTask, startTime, endTime)` entries and a total cost score.

#### 3.4 SchedulingService (orchestrator)

`SchedulingService.java` is the main entry point:

```java
public DailySchedule generateSchedule(Long userId, LocalDate date) {
    // 1. Fetch user's routine for this day of week
    // 2. Compute free time slots (available windows minus fixed events)
    // 3. Fetch eligible planner tasks (pending, due today/overdue, not blocked)
    // 4. If total task time > total free time → flag overload, still schedule what fits
    // 5. Run CSP to validate feasibility
    // 6. Run A* to find optimal sequence
    // 7. Persist as a new DailySchedule + ScheduleEntries
    // 8. Return the schedule
}
```

| Endpoint | Method | Description |
|---|---|---|
| `/api/v1/planner/schedule/generate` | `POST` | Generate (or regenerate) today's schedule. Body: `{ "date": "2026-09-27" }` |
| `/api/v1/planner/schedule/{date}` | `GET` | Get the active schedule for a given date |
| `/api/v1/planner/schedule/{date}/history` | `GET` | Get all versions (revision history) for a given date |

---

### Phase 4: Execution Tracking & Dynamic Rescheduling

**Goal:** Track real-time task execution and automatically reschedule when reality deviates from the plan.

#### 4.1 Task execution endpoints

| Endpoint | Method | Description |
|---|---|---|
| `/api/v1/planner/schedule/entries/{entryId}/start` | `POST` | Mark a schedule entry as started. Records `actual_start_time` and `started_at`. |
| `/api/v1/planner/schedule/entries/{entryId}/complete` | `POST` | Mark as completed. Records `actual_end_time`, `actual_minutes`, `completed_at`. Body: `{ "actual_minutes": 45 }` |
| `/api/v1/planner/schedule/entries/{entryId}/skip` | `POST` | Mark as skipped. |

#### 4.2 Rescheduling trigger logic

Inside `ExecutionTrackingService.java`:

```
When a task completes or is skipped:
  1. Calculate time deviation = actual_minutes - estimated_minutes
  2. If |deviation| > threshold (e.g., 10 minutes) OR task was skipped:
     a. Get remaining incomplete entries for today
     b. Determine new "current time" = now
     c. Re-run SchedulingService for ONLY the remaining tasks in the remaining free time
     d. Create a new DailySchedule version (version++)
     e. Mark old version as is_active=false
     f. Notify frontend via WebSocket (existing WebSocket infra)
  3. Save to duration_history for future estimate improvement
```

**Rules for rescheduling:**
- NEVER reschedule completed entries.
- NEVER move fixed events.
- If remaining tasks can't fit in remaining time, return the schedule with a `feasibility_warning` flag listing which tasks were dropped.
- Preserve original schedule (old version stays in `daily_schedules` with `is_active=false`).

#### 4.3 Duration history recording

Every time a task completes, write to `duration_history`:
```java
DurationHistory record = DurationHistory.builder()
    .userId(userId)
    .plannerTaskId(entry.getPlannerTask().getId())
    .estimatedMinutes(entry.getPlannerTask().getEstimatedMinutes())
    .actualMinutes(actualMinutes)
    .category(entry.getPlannerTask().getCategory())
    .build();
durationHistoryRepository.save(record);
```

#### 4.4 Estimate improvement (MVP)

Create `EstimateService.java`:
```java
public int getAdjustedEstimate(Long userId, String category, int defaultEstimate) {
    // Query duration_history for this user + category
    // If >= 5 records exist, return the average actual_minutes
    // Otherwise, return defaultEstimate
}
```

This is intentionally simple for MVP. A trained prediction model can replace it later.

---

### Phase 5: Progress Dashboard API

**Goal:** Provide the frontend with all the data needed to render the planner dashboard.

#### 5.1 Dashboard endpoint

| Endpoint | Method | Description |
|---|---|---|
| `/api/v1/planner/dashboard` | `GET` | Returns today's schedule, progress stats, and estimate accuracy |

**Response structure:**

```json
{
  "today": {
    "date": "2026-09-27",
    "schedule_version": 2,
    "total_tasks": 8,
    "completed": 3,
    "in_progress": 1,
    "remaining": 3,
    "skipped": 1,
    "feasibility_warning": null,
    "entries": [
      {
        "id": 1,
        "task_title": "Introduction to DevOps",
        "start_time": "09:00",
        "end_time": "09:45",
        "status": "completed",
        "estimated_minutes": 45,
        "actual_minutes": 50,
        "source_type": "roadmap"
      }
    ]
  },
  "estimate_accuracy": {
    "average_deviation_minutes": 8.5,
    "total_tasks_tracked": 42,
    "overrun_percentage": 35.7
  },
  "next_task": {
    "id": 5,
    "title": "Practice SQL Joins",
    "start_time": "14:00",
    "estimated_minutes": 30
  }
}
```

#### 5.2 Schedule history endpoint

| Endpoint | Method | Description |
|---|---|---|
| `/api/v1/planner/history` | `GET` | Returns a paginated list of past daily schedules with completion stats |

---

## 4. File Creation Checklist

Use this checklist to track progress. Each item is a file that needs to be created or modified.

### Configuration
- [ ] Set `spring.jpa.hibernate.ddl-auto=update` in `application.properties`
- [ ] (Optional) `src/main/resources/db/migration/V2__task_planner_schema.sql` — reference only

### Entities (`com.skillos.entity`)
- [ ] `UserRoutine.java`
- [ ] `PlannerTask.java`
- [ ] `DailySchedule.java`
- [ ] `ScheduleEntry.java`
- [ ] `DurationHistory.java`
- [ ] `CustomTask.java` (for existing `custom_tasks` table)

### Repositories (`com.skillos.repository`)
- [ ] `UserRoutineRepository.java`
- [ ] `PlannerTaskRepository.java`
- [ ] `DailyScheduleRepository.java`
- [ ] `ScheduleEntryRepository.java`
- [ ] `DurationHistoryRepository.java`
- [ ] `CustomTaskRepository.java`

### DTOs — Requests (`com.skillos.dto.request`)
- [ ] `CreateRoutineRequest.java`
- [ ] `UpdateRoutineRequest.java`
- [ ] `CreatePlannerTaskRequest.java`
- [ ] `UpdatePlannerTaskRequest.java`
- [ ] `GenerateScheduleRequest.java`
- [ ] `CompleteEntryRequest.java`

### DTOs — Responses (`com.skillos.dto.response`)
- [ ] `RoutineResponse.java`
- [ ] `PlannerTaskResponse.java`
- [ ] `DailyScheduleResponse.java`
- [ ] `ScheduleEntryResponse.java`
- [ ] `PlannerDashboardResponse.java`

### Planner Engine (`com.skillos.planner`)
- [ ] `model/TimeSlot.java`
- [ ] `model/ScheduleState.java`
- [ ] `model/ScheduleCandidate.java`
- [ ] `csp/ConstraintChecker.java`
- [ ] `astar/AStarScheduler.java`
- [ ] `astar/ScheduleHeuristic.java`
- [ ] `SchedulingService.java`

### Services (`com.skillos.service`)
- [ ] `UserRoutineService.java`
- [ ] `PlannerTaskService.java`
- [ ] `ExecutionTrackingService.java`
- [ ] `EstimateService.java`
- [ ] `PlannerDashboardService.java`

### Controllers (`com.skillos.controller`)
- [ ] `UserRoutineController.java`
- [ ] `PlannerTaskController.java`
- [ ] `ScheduleController.java`
- [ ] `PlannerDashboardController.java`

---

## 5. Implementation Order

> **IMPORTANT:** Follow this exact order. Each step depends on the previous one.

```
Step 1  → Set ddl-auto=update in application.properties
Step 2  → Entity classes + Repository interfaces (Hibernate creates tables on startup)
Step 3  → Verify tables were created correctly in MySQL
Step 4  → DTOs (request + response)
Step 5  → UserRoutineService + Controller (CRUD)
Step 6  → PlannerTaskService + Controller (CRUD + import from roadmap)
Step 7  → Planner engine models (TimeSlot, ScheduleState, ScheduleCandidate)
Step 8  → ConstraintChecker (CSP)
Step 9  → AStarScheduler + ScheduleHeuristic
Step 10 → SchedulingService (orchestrator)
Step 11 → ScheduleController (generate + get schedule)
Step 12 → ExecutionTrackingService (start/complete/skip + rescheduling)
Step 13 → EstimateService (duration comparison + simple adjustment)
Step 14 → PlannerDashboardService + Controller
Step 15 → Integration testing
```

---

## 6. What NOT to build in MVP

These are explicitly deferred to future phases:

| Feature | Reason |
|---|---|
| Google Calendar / GitHub / Email integration | Requires OAuth flows and API key management. Build after core planner works. |
| ML-based duration prediction | Need enough `duration_history` data first. Start with simple averages. |
| Project Gantt / Kanban integration | Separate feature area. Connect later via `source_type='project'`. |
| Multi-day scheduling | Keep MVP focused on single-day planning. |
| Break scheduling | Can add as a constraint in CSP later. For now, user defines breaks as fixed events. |

---

## 7. Algorithm Notes for Implementers

### CSP is a filter, not an optimizer

CSP answers: "Is this assignment valid?" It checks constraints but does not rank solutions. Use it to prune invalid states during A* search.

### A* is the optimizer

A* explores the space of possible task orderings and uses `g(n) + h(n)` to find the lowest-cost valid sequence.

### Practical performance

For a typical day with 5–15 tasks and 3–5 available time windows, the search space is small. A* with a simple admissible heuristic will complete in milliseconds. No need for exotic optimizations.

### When the schedule is infeasible

If total `estimated_minutes` of eligible tasks exceeds total available minutes:
1. Schedule tasks in priority order (critical → high → medium → low) until time runs out.
2. Return the schedule along with a `feasibility_warning` listing the unscheduled tasks.
3. Do NOT silently drop tasks.

---

## 8. Reference Files

| File | What it contains |
|---|---|
| `Adaptive Task Planner — Workflow, Approach & Cautions.txt` | Original feature spec with detailed cautions |
| `mermaid-diagram.png` | End-to-end flowchart of the planner pipeline |
| `skillos_api.md` | Complete REST API spec for the full SkillOS platform |
| `skillos_v1.sql` | Current database schema dump |
| `pom.xml` | Maven dependencies — no new dependencies needed for the planner |
