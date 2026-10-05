# SkillOS — Updated Project Workflow

> **Version:** 2.0 (Updated after consistency analysis)
> **Tech Stack:** Java Spring Boot (backend), React + Vite (frontend), MySQL (DB), Gemini/OpenAI (AI)
> **Last Updated:** 2025-06-04

---

## 1. Authentication & Onboarding

### Signup
New users sign up by providing their **full name**, **email**, and **password**. Upon signup, a **6-digit OTP** is sent to the user's email for verification. The user submits the OTP to verify their email address. If the OTP expires, they can request a resend (with a cooldown period). Users can also sign up via **Google OAuth** or **GitHub OAuth** — in this case, their email is automatically verified.

### Login
Once signed up and email-verified, users can log in using their **email and password**, or via **Google/GitHub OAuth**. On successful login, the system returns:
- An **access token** (JWT, expires in 15 minutes)
- A **refresh token** (set as an httpOnly cookie, expires in 7 days, rotated on each use)
- User info including: `id`, `full_name`, `email`, `role` (user/admin/super_admin), `profession` (student/self_learner/professional), `onboarding_completed` status

> **Important:** `role` is strictly an access control field with values: `user`, `admin`, `super_admin`. `profession` is the user's self-identified category with values: `student`, `self_learner`, `professional`. These two fields must never be confused.

### Password Reset
Users can request a password reset via email. A reset link/token is sent. The user submits the token along with their new password (min 8 chars, 1 uppercase, 1 number).

### Onboarding (5 Steps)
After the first login, if `onboarding_completed` is `false`, users are guided through a **5-step onboarding flow**:

| Step | What It Asks | Required? |
|------|-------------|-----------|
| 1 | **Goal skill tags** — what skills the user wants to learn (e.g., Python, Data Science) | ✅ Required |
| 2 | **Daily commitment** — how many minutes per day the user plans to study | ✅ Required |
| 3 | **Duration in months** — which days of the week the user is available (stored as a bitmask: bit0=Sun, bit1=Mon ... bit6=Sat) | ✅ Required |
| 4 | **Peer opt-in** — whether the user wants to be discoverable by peers learning the same skills | ⏭️ Skippable |
| 5 | **Profile setup** — full name, profession, bio, avatar | ⏭️ Skippable |

Once all required steps are complete, the user marks onboarding as finished and is taken to their profile page.

---

## 2. User Profile

Once logged in and onboarded, users are taken to their **profile page** containing:

### Editable Information (user can update anytime):
- **Full name**
- **Profession** (student, self_learner, professional)
- **Avatar** (preset key or uploaded image)
- **Bio**

### Read-Only Information (computed by the system):
- **Level** and **total XP**
- **Current streak** and **highest streak**
- **Recent achievements** (with icons and unlock dates)
- **Connected peers** (count and recent peers with their avatars and streaks)
- **Global ranking opt-in** status

---

## 3. Roadmap

Users navigate to the **Roadmap page** to generate personalized learning plans.

### Generating a Roadmap
When generating a roadmap, the platform asks for:
- **Skill** they want to learn
- **Daily time commitment** (how much time per day)
- **Deadline** (minimum 1 month, user-defined — no fixed presets)
- **Goal purpose** (job, education, or other)
- **Experience level** related to the skill (beginner, intermediate, advanced)

Once the user provides this information and clicks "Generate Roadmap":
1. The platform creates a **generation job** and returns a `job_id` immediately
2. In the background, a worker sends the information along with a prompt to the **Gemini AI API** in JSON format
3. The frontend **polls the job status** every 2 seconds, showing a progress bar
4. The AI generates a day-by-day roadmap and returns it in JSON format:

```json
[
  {
    "day": 1,
    "task": "Learn basic HTML structure and essential tags (html, head, body, headings, paragraphs)",
    "question": "Which HTML tag is used to define the largest heading?",
    "answer": "h1"
  },
  {
    "day": 2,
    "task": "Learn HTML structural elements (links, images, lists, and tables)",
    "question": "Which attribute is used in an anchor tag to specify the URL?",
    "answer": "href"
  }
]
```

The roadmap spans from **day 0 to the deadline** (e.g., 6-month deadline = day 0 to day 180).

### Roadmap Day Format
Each day contains:
- **Day Number** (e.g., Day 04)
- **Task** — what the user needs to learn/do
- **Question** — a question related to the day's task with a non-ambiguous answer
- **Answer Box** — text input for the user to type their answer

**Rules:**
- A user can only move to the **next day** if they answer the question correctly
- Once answered correctly, the day is marked **complete** (awards XP)
- A user can create **multiple roadmaps** but can have only **one roadmap active** at a time

### Notes from Roadmap
A **"+"** button is attached to each day. Clicking it lets the user create a note for that day:
- The **skill** and **day number** are **automatically mapped** to the note
- The **roadmap_id** is also auto-populated
- The note holds text content and a separate field for **resource links**
- When adding links, they are **checked against a blacklist** of banned websites

### Progress
A **progress bar** at the top of the Roadmap page shows the overall completion percentage (e.g., "30% of the roadmap completed").

---

## 4. Knowledge (Notes & Flashcards)

### Notes
Users can view all their notes and create new ones from this section.

**Creating notes from Knowledge section:**
- Users must **manually input** the skill and day number the note belongs to
- They can also choose to leave skill and/or day number **empty**
- Notes include text content and optional resource links (checked against the blacklist)

**Creating notes from Roadmap (via "+" button):**
- Skill and day are **automatically mapped**

### Flashcards
The flashcard system supports both auto-generation and manual creation.

**Flashcard fields:**
- **Difficulty** — initially `null`; once reviewed, set to: `easy`, `medium`, `hard`, or `forgot`. Once set, difficulty can **never be reset to null** again
- **Skill** — the skill the flashcard belongs to (optional for manual creation)
- **Question** — the flashcard question
- **Answer** — the flashcard answer
- **Mastery** — starts at `0`, increases as user reviews with lower difficulties, maxed at `100`

**Auto-generating flashcards:**
1. Takes all the user's notes that have **not been previously used** for flashcard generation
2. Sends note content to Gemini AI in JSON format (sends skill name and note text, **excludes links**)
3. AI generates question/answer pairs and returns them as flashcards
4. Flashcards are auto-mapped to their skill, mastery set to `0`, difficulty set to `null`
5. Generation uses the **async job pattern** (same as roadmap — returns `job_id`, polls for status)

**Manual flashcard creation:**
- User provides: question, answer, skill name (optional — can skip), and difficulty
- Mastery is set to `0` automatically

### Study Mode
A review mode where:
- Flashcards are shown **randomly**, one at a time
- User reviews each card and **sets its difficulty** (easy/medium/hard/forgot)
- The more a user gives lower difficulties, the more the **mastery increases**
- Users can **filter** which cards appear by:
  - Skill (specific skill or all)
  - Difficulty level (specific level or all)

---

## 5. Peers

Users can search and add peers for co-learning.

### Discovery
On the Peers page, users see other platform users. They can search by:
- **Skill** being learned
- **Name** or **email**

For each user they can view:
- Name, profession, bio
- Skill they are learning
- Highest streak, current streak
- Level and global ranking

### Pairing
- Users can **send a peer request** to another user
- The other user can **accept or decline** the request
- Once paired, they are connected as peers

### 1:1 Chat (Primary)
Once paired, peers can **chat with one another** via direct messages:
- Real-time delivery via **WebSocket** (Spring WebSocket/STOMP)
- Messages can be edited and soft-deleted
- Message history is paginated
- Unread counts are tracked per conversation

### Peer Notifications
Peers are notified when:
- Their peer **misses their daily tasks** (detected by a scheduled backend job running daily at 21:00 per user timezone)
- Their peer **breaks their streak** (detected by a scheduled backend job running daily at 00:30 UTC)

### Group Chat (Deprioritized)
> **Note:** Group chat functionality (peer groups, threads, replies, reactions) exists in the API and schema but is **deprioritized**. It will not be implemented until all other features are complete and may be discarded entirely. 1:1 DM is the primary focus.

One user can connect with **multiple peers**.

---

## 6. Projects

Users can manage their projects from the **Projects page**.

### Creating a Project
Click "New Project" and provide:
- **Name** of the project
- **Description** (what the project does, its features)
- **Deadline** (in how many days they want to complete it)
- **Skill** the project belongs to
- **Color** to highlight the project — chosen from a set: `blue`, `cyan`, `green`, `orange`, `red`

Once submitted:
1. The platform creates a **generation job** and returns a `job_id` immediately
2. In the background, the information is sent to **Gemini AI**
3. AI generates: to-do tasks, feature sequence, and time allocations for the Gantt chart
4. AI returns the structured data in JSON format

### Kanban Board
The platform provides a **Kanban board** with 4 columns:
- **To Do**
- **In Progress**
- **Review**
- **Done**

> **Important:** The kanban column position is the **single source of truth** for task status. There is no separate status field on tasks. When a card moves to the "Done" column, the backend sets `completed_at` on the task and awards XP.

Users can:
- Add custom tasks to the project
- Move cards between columns (drag and drop)
- Mark tasks as done (moving to Done column)

### Gantt Chart
Shows the **sequence of features** and the **time allocated** to each. Users can:
- Change the time allocated to each feature
- Change the sequence/order of features

### Project Management
- The project interface shows **project information** and **overall progress**
- Kanban board and Gantt chart change based on the **selected project**
- Users can have **multiple projects** but only **one active at a time**

---

## 7. Dashboard

The dashboard is the main hub showing:

### Today's Focus
- **Today's roadmap task** (from the active roadmap)
- **Today's project task** (if the user has an active project)

### Active Items
- **Active roadmap** (name, progress percentage)
- **Active project** (name, color, progress percentage)

### XP & Level
- Current **level** and **total XP**
- **XP progress graph** showing XP gained over:
  - Week (daily breakdown)
  - Month (weekly breakdown)
  - Year (monthly breakdown)
- **Average daily XP**

### Quick Action Buttons
- Add note
- Add flashcard
- Study flashcards
- Add a task to do

### Peers
- Shows **currently active peers** (with avatars and streaks)

---

## 8. Progress

The **Progress page** shows peer comparison metrics:

- **User's rank among peers** based on roadmap completion progress
- **Average XP earned** comparison (e.g., "+30%" means earned 30% more than all peers' average)
- **Tasks done in this period** comparison
- **Number of peers** learning the same skill
- **Peer leaderboard** based on XP (shows all peers including the user)
- **Average daily learning time** comparison
- **Roadmap progress comparison** — user's progress vs peers' (same skill) progress
- Filterable by period: `week`, `month`, or `all`

---

## 9. Rank

The **Ranks page** shows the **global ranking** of all users on the platform.

### Ranking Display
Each entry shows:
| Rank | Name | XP | Streaks | Hours | Milestones Reached | Lifetime Achievement Points |
|------|------|----|---------| ------|-------------------|----------------------------|

### Ranking Formula
The ranking is calculated using a **weighted scoring formula**:
```
ranking_score = (xp × 0.40) + (streak × 50 × 0.15) + (hours × 100 × 0.15) + (milestones × 200 × 0.15) + (achievement_pts × 0.15)
```

Rankings are updated via **nightly snapshots** (not real-time).

### Additional Features
- Shows **XP required for next rank** update
- Shows what **percentile** the user is in
- Users can choose to **opt in or opt out** of the global ranking (via preferences or the `global_rankings.opted_in` field)

---

## 10. Achievements

The Achievements page shows:
- All **available achievements** and what users need to do to earn them
- Achievements the user has **already completed**
- Completing achievements provides **achievement points** and **XP**

Achievements are condition-based (e.g., "Maintain a 7-day streak", "Complete 50 tasks", "Reach level 10"). Each has a `condition_type` and `condition_value` threshold.

---

## 11. Rewards Store

In the Rewards Store, users spend **achievement points** to purchase:
- **Dark theme** / custom themes
- **Custom avatar frame**
- **XP boost** (double XP) for one day
- **Streak freeze** for one day (prevents streak from breaking even if user didn't log in)
- Other items

Some items are **permanent** (e.g., themes), others are **temporary** with expiration (e.g., XP boost, streak freeze). Active purchases are tracked.

> **Note:** Streak freeze can be obtained from the rewards store (costs achievement points) OR via a native endpoint `POST /streaks/freeze` (limited uses per week). Both paths use the same underlying streak protection logic.

---

## 12. Settings

The Settings page contains:
- **Change password** (requires current password + new password)
- **Preferences** (stored in a separate `user_preferences` table):
  - Theme: `system` / `light` / `dark`
  - Language (ISO 639-1 code, default: `en`)
  - Notification toggles:
    - Email notifications
    - Push notifications
    - Peer activity notifications
    - Daily reminder notifications
    - Achievement notifications
  - Timezone (IANA timezone string)
  - Global ranking opt-in/out

---

## 13. AI Hub

A page where users can **chat with the AI** (Gemini or OpenAI API):
- Users can create **multiple conversations**
- Each conversation has a title (auto-generated or custom)
- Users send messages and receive AI responses
- Full message history is retained per conversation
- Conversations can be deleted

---

## 14. Admin Page

> All admin endpoints require `role: admin` or `role: super_admin`.

Admins can:
- **Manage the blacklist** — add, remove, and search blacklisted website domains
- **View skill analytics** — filter skills by:
  - **Popularity** (most active learners) over periods: week, 1 month, 6 months, 1 year, all time
  - **Most time spent** (total hours studied)
- **View and search all users** — filter by role, search by name/email
- **View platform dashboard** — total users, active users, total roadmaps, total projects, top skills
- **Trigger notification jobs** — manually run the peer streak/task miss detection jobs for testing

---

## 15. Weekly Review

At the end of each week, users can view a **weekly review** containing:
- **Tasks completed** that week
- **XP earned**
- **Streak days** maintained
- **Hours studied**
- **Overall score** (computed)
- **AI insight text** — Gemini-generated summary and advice based on the week's performance
- **Peer comparison** — how the user performed vs peer average (percentage)
- **Weekly goals** — users can set goals for the upcoming week and mark them as `hit`, `missed`, or `partial` after the week ends
- **Review history** — past weekly reviews are accessible for tracking long-term progress

---

## Cross-Cutting Features

### Study Timer
A **timer on the header** of the platform:
- User starts the timer when they begin studying
- Timer tracks total time spent studying
- Timer **resets daily**
- User can **pause** and **resume** at any time
- Timer state is persisted in the database and synced on start/pause/stop

### Notifications
A **notification button** in the header. Pressing it shows notifications such as:
- Peer request accepted
- Peer sent a message
- Rank updated
- Achievement unlocked
- Daily task reminder (if any tasks are due or not)
- Peer achievement notifications
- Peer streak broken / peer missed tasks

Notifications are delivered in **real-time via WebSocket** (Spring WebSocket/STOMP) and stored in the database for history.

### XP Sources
Things that provide XP:
- Completing a **day** in a roadmap
- Taking a **note**
- Reviewing flashcards (**study mode**)
- Adding a **flashcard**
- Completing **tasks in projects** (moving kanban card to "Done" column)

### Blacklist Enforcement
When a user adds a link to their note, the link's domain is **checked against the blacklisted websites** list. Links from blacklisted domains are rejected.

### Async AI Generation (Job Queue Pattern)
All AI generation (roadmaps, flashcards, project tasks) follows the same pattern:
1. User submits a generation request
2. Backend creates a **generation job** row (`status: queued`) and returns a `job_id` immediately (HTTP 202)
3. A background worker picks up the job, calls the AI API, updates `progress_percent`
4. Frontend polls `GET /status/:job_id` every 2 seconds to show progress
5. On success: result is stored, job marked `complete`, WebSocket event emitted
6. On failure: retries up to 3 times with exponential backoff, then marks `failed` with error message

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Backend | Java Spring Boot |
| Frontend | React + Vite |
| Database | MySQL |
| AI Integration | Gemini API (primary) / OpenAI API (fallback) |
| Real-time | Spring WebSocket / STOMP |
| Background Jobs | Spring `@Async` + `ThreadPoolTaskExecutor` |
| Validation | Jakarta Bean Validation (`@Valid`, `@NotNull`, `@Size`) |
| Security | Spring Security (JWT, CORS, rate limiting via Bucket4j) |
| Cron Jobs | Spring `@Scheduled` (peer streak check, task miss detection, nightly rank snapshots) |

---

## Implemented Backend Architecture (Phases 3 & 4)

### Phase 3: User Profile & Onboarding Architecture
- **Global Error Handling**: `GlobalExceptionHandler.java` intercepts exceptions (e.g., `MethodArgumentNotValidException`, `ResourceNotFoundException`) and normalizes responses into a `{ "error": { "code": "...", "message": "..." } }` structure.
- **Onboarding Services**: `OnboardingController` and `OnboardingService` manage the 5-step onboarding flow. Steps 1-3 update core fields (e.g., `skill_goal`, `daily_time_minutes`, `days_available`), and Step 5 updates the User Profile.
- **User Settings & Profile**: `UserController` handles fetching `/users/me` and `/users/{id}` (fetching public profiles).

### Phase 4: Async AI Job Architecture
The roadmap generation uses a non-blocking asynchronous queue pattern:
1. **Controller (`RoadmapController`)**: Receives the roadmap parameters, instantly creates a `GenerationJob` entity with status `queued`, and returns `202 Accepted` with a `job_id`.
2. **Worker (`RoadmapGeneratorService`)**: Runs on a separate thread pool (`@Async("taskExecutor")`). It updates the job status to `processing`.
3. **AI Client (`GeminiService`)**: Uses `RestTemplate` to send a strictly formatted prompt to `generativelanguage.googleapis.com`. It includes a JSON mock fallback if the user lacks a valid API key.
4. **Persistence & Mapping**: Upon receiving the JSON response from Gemini, the worker parses it using `ObjectMapper`, saves the `Roadmap` and maps out `RoadmapTask` relationships (`@OneToMany` with `@JsonIgnore` to prevent Hibernate proxy serialization errors). It updates the job status to `complete` and sets the `result_id` to the newly created Roadmap.
5. **Polling**: The frontend polls `GET /api/v1/roadmaps/generate/status/{jobId}` until it sees `status: complete`, then fetches the final roadmap via `GET /api/v1/roadmaps/{result_id}`.
