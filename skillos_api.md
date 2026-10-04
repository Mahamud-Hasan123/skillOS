# SkillOS — Complete REST API Specification

> **Base URL:** `/api/v1`  
> **Content-Type:** `application/json` (all requests & responses)  
> **Auth:** `Authorization: Bearer <access_token>` on all protected routes  
> **Refresh Token:** stored in `httpOnly` cookie (`skillos_refresh`)  
> **Timestamps:** ISO 8601 — `2025-04-28T10:30:00Z`

---

## Global Conventions

### Pagination
All list endpoints accept:
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `page` | integer | `1` | Page number |
| `limit` | integer | `20` | Items per page |

All list responses wrap data as:
```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 84,
    "total_pages": 5
  }
}
```

### Error Format
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The email field is required.",
    "field": "email"
  }
}
```

### Rate Limit Headers (on every response)
```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 58
X-RateLimit-Reset: 1714300800
```

### HTTP Status Codes
| Code | Meaning |
|------|---------|
| 200 | OK |
| 201 | Created |
| 204 | No Content |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 409 | Conflict |
| 422 | Unprocessable Entity |
| 429 | Too Many Requests |
| 500 | Internal Server Error |

---

## Table of Contents

1. [Auth & Session](#module-1-auth--session)
2. [Onboarding](#module-2-onboarding)
3. [User Profile](#module-3-user-profile)
4. [Roadmap Generator](#module-4-roadmap-generator)
5. [Roadmaps](#module-5-roadmaps)
6. [Milestones](#module-6-milestones)
7. [Tasks](#module-7-tasks)
8. [Daily Tasks](#module-8-daily-tasks)
9. [Resources](#module-9-resources)
10. [XP & Levels](#module-10-xp--levels)
11. [Streaks](#module-11-streaks)
12. [Achievements](#module-12-achievements)
13. [Rewards Store](#module-13-rewards-store)
14. [Leaderboard](#module-14-leaderboard)
15. [Peers](#module-15-peers)
16. [Peer Groups & Chat](#module-16-peer-groups--chat)
17. [Notes](#module-17-notes)
18. [Flashcards](#module-18-flashcards)
19. [Notifications](#module-19-notifications)
20. [Weekly Review](#module-20-weekly-review)
21. [Kanban Board](#module-21-kanban-board)
22. [Projects](#module-22-projects)
23. [Dashboard](#module-23-dashboard)
24. [Progress & Comparison](#module-24-progress--comparison)
25. [AI Hub](#module-25-ai-hub-stub)
26. [Middleware & Architecture Notes](#middleware--architecture-notes)

---

## Module 1: Auth & Session

---

### **POST** `/auth/register`
Create a new user account (step 1 of onboarding flow).

- **Auth:** Public
- **Rate limit:** 5 req/min per IP

**Request Body:**
```json
{
  "full_name": "string, required, 2–120 chars",
  "email": "string, required, valid email, max 255",
  "password": "string, required, min 8 chars, 1 uppercase, 1 number"
}
```

**Success — 201 Created:**
```json
{
  "message": "Account created. Please verify your email.",
  "user": {
    "id": 1,
    "full_name": "Rahim Uddin",
    "email": "rahim@example.com",
    "email_verified": false,
    "onboarding_completed": false,
    "created_at": "2025-04-28T10:00:00Z"
  }
}
```

**Errors:**
- `409 CONFLICT` — email already registered
- `422 VALIDATION_ERROR` — invalid fields

---

### **POST** `/auth/login`
Authenticate with email and password.

- **Auth:** Public
- **Rate limit:** 10 req/min per IP

**Request Body:**
```json
{
  "email": "string, required",
  "password": "string, required",
  "captcha_token": "string, required after 3 failed attempts"
}
```

**Success — 200 OK:**
```json
{
  "access_token": "eyJhbGci...",
  "token_type": "Bearer",
  "expires_in": 900,
  "user": {
    "id": 1,
    "full_name": "Rahim Uddin",
    "email": "rahim@example.com",
    "email_verified": true,
    "role": "student",
    "onboarding_completed": true,
    "avatar": "preset_01",
    "current_level": 5,
    "total_xp": 1250
  }
}
```
> Refresh token set as `httpOnly` cookie `skillos_refresh`.

**Errors:**
- `401 INVALID_CREDENTIALS` — wrong email or password
- `403 EMAIL_NOT_VERIFIED` — account not verified
- `403 CAPTCHA_REQUIRED` — 3+ failed attempts, captcha_token missing or invalid
- `429 TOO_MANY_REQUESTS` — rate limit exceeded

---

### **POST** `/auth/logout`
Revoke the current session token.

- **Auth:** Required
- **Rate limit:** 30 req/min

**Request Body:** _(empty)_

**Success — 204 No Content**

> Clears `skillos_refresh` cookie.

**Errors:**
- `401 UNAUTHORIZED`

---

### **POST** `/auth/refresh`
Exchange a valid refresh token for a new access token.

- **Auth:** Public (reads `skillos_refresh` cookie)
- **Rate limit:** 30 req/min

**Request Body:** _(empty — token read from cookie)_

**Success — 200 OK:**
```json
{
  "access_token": "eyJhbGci...",
  "token_type": "Bearer",
  "expires_in": 900
}
```

**Errors:**
- `401 INVALID_REFRESH_TOKEN`
- `401 REFRESH_TOKEN_EXPIRED`

---

### **POST** `/auth/oauth/google`
Login or register via Google OAuth.

- **Auth:** Public
- **Rate limit:** 10 req/min

**Request Body:**
```json
{
  "id_token": "string, required — Google ID token from frontend"
}
```

**Success — 200 OK** (login) or **201 Created** (new account):
```json
{
  "access_token": "eyJhbGci...",
  "token_type": "Bearer",
  "expires_in": 900,
  "is_new_user": true,
  "user": {
    "id": 2,
    "full_name": "Nadia Islam",
    "email": "nadia@gmail.com",
    "email_verified": true,
    "onboarding_completed": false
  }
}
```

**Errors:**
- `400 INVALID_OAUTH_TOKEN`
- `409 EMAIL_TAKEN_BY_PASSWORD_ACCOUNT`

---

### **POST** `/auth/oauth/github`
Login or register via GitHub OAuth.

- **Auth:** Public
- **Rate limit:** 10 req/min

**Request Body:**
```json
{
  "code": "string, required — GitHub OAuth authorization code"
}
```

**Success — 200/201** _(same shape as Google OAuth)_

**Errors:**
- `400 INVALID_OAUTH_CODE`
- `409 EMAIL_TAKEN_BY_PASSWORD_ACCOUNT`

---

### **POST** `/auth/verify-email`
Submit 6-digit OTP to verify email address.

- **Auth:** Public
- **Rate limit:** 5 req/min per IP

**Request Body:**
```json
{
  "email": "string, required",
  "otp": "string, required, exactly 6 digits"
}
```

**Success — 200 OK:**
```json
{
  "message": "Email verified successfully.",
  "email_verified": true
}
```

**Errors:**
- `400 INVALID_OTP` — wrong or expired OTP
- `409 ALREADY_VERIFIED`

---

### **POST** `/auth/resend-verification`
Resend OTP email. Always returns 200 to prevent email enumeration.

- **Auth:** Public
- **Rate limit:** 3 req/min per IP

**Request Body:**
```json
{
  "email": "string, required"
}
```

**Success — 200 OK:**
```json
{
  "message": "If this email exists, a new OTP has been sent.",
  "cooldown_active": true,
  "remaining_seconds": 42
}
```
> `remaining_seconds` is `0` when no cooldown is active.

---

### **POST** `/auth/forgot-password`
Send password reset email. Always returns 200.

- **Auth:** Public
- **Rate limit:** 3 req/min per IP

**Request Body:**
```json
{
  "email": "string, required"
}
```

**Success — 200 OK:**
```json
{
  "message": "If this email is registered, a reset link has been sent."
}
```

---

### **POST** `/auth/reset-password`
Submit new password using reset token.

- **Auth:** Public
- **Rate limit:** 5 req/min per IP

**Request Body:**
```json
{
  "token": "string, required",
  "new_password": "string, required, min 8 chars, 1 uppercase, 1 number"
}
```

**Success — 200 OK:**
```json
{
  "message": "Password reset successfully. Please log in."
}
```

**Errors:**
- `400 INVALID_RESET_TOKEN`
- `400 RESET_TOKEN_EXPIRED`
- `422 VALIDATION_ERROR`

---

### **GET** `/auth/me`
Return currently authenticated user's profile.

- **Auth:** Required
- **Rate limit:** 60 req/min

**Success — 200 OK:**
```json
{
  "id": 1,
  "full_name": "Rahim Uddin",
  "email": "rahim@example.com",
  "role": "student",
  "profession": "student",
  "avatar": "preset_01",
  "bio": "Learning full-stack development.",
  "timezone": "Asia/Dhaka",
  "email_verified": true,
  "onboarding_completed": true,
  "created_at": "2025-04-28T10:00:00Z"
}
```

**Errors:**
- `401 UNAUTHORIZED`

---

## Module 2: Onboarding

---

### **GET** `/onboarding/status`
Return current onboarding step and completion status.

- **Auth:** Required
- **Rate limit:** 60 req/min

**Success — 200 OK:**
```json
{
  "current_step": 3,
  "is_completed": false,
  "steps": {
    "1": { "completed": true, "data": { "goal_skill_tags": ["Python", "Data Science"] } },
    "2": { "completed": true, "data": { "daily_commitment_min": 60 } },
    "3": { "completed": false, "data": null },
    "4": { "completed": false, "skipped": false, "data": null },
    "5": { "completed": false, "skipped": false, "data": null }
  }
}
```

---

### **PUT** `/onboarding/step/:step_number`
Save data for a specific onboarding step.

- **Auth:** Required
- **Rate limit:** 30 req/min
- **Path params:** `step_number` — integer, 1–5

**Request Body (Step 1):**
```json
{ "goal_skill_tags": ["Python", "Machine Learning"] }
```

**Request Body (Step 2):**
```json
{ "daily_commitment_min": 45 }
```

**Request Body (Step 3):**
```json
{ "days_available_bitmask": 62 }
```
> Bitmask: bit0=Sun, bit1=Mon … bit6=Sat. Value `62` = Mon–Fri.

**Request Body (Step 4 — skippable):**
```json
{ "peer_opt_in": true, "peer_skill_filter": ["Python"] }
```
> Send `{ "skip": true }` to skip.

**Request Body (Step 5 — skippable):**
```json
{
  "full_name": "Rahim Uddin",
  "profession": "student",
  "bio": "Aspiring data scientist.",
  "avatar": "preset_03"
}
```
> Send `{ "skip": true }` to skip.

**Success — 200 OK:**
```json
{
  "message": "Step 3 saved.",
  "current_step": 4
}
```

**Errors:**
- `400 INVALID_STEP` — step_number out of range
- `422 VALIDATION_ERROR`

---

### **POST** `/onboarding/complete`
Mark onboarding as fully completed.

- **Auth:** Required
- **Rate limit:** 10 req/min

**Request Body:** _(empty)_

**Success — 200 OK:**
```json
{
  "message": "Onboarding complete. Welcome to SkillOS!",
  "onboarding_completed": true
}
```

**Errors:**
- `400 ONBOARDING_INCOMPLETE` — required steps not finished

---

## Module 3: User Profile

---

### **GET** `/users/me`
Full authenticated user profile with XP, level, and streak summary.

- **Auth:** Required
- **Rate limit:** 60 req/min

**Success — 200 OK:**
```json
{
  "id": 1,
  "full_name": "Rahim Uddin",
  "email": "rahim@example.com",
  "role": "student",
  "profession": "student",
  "avatar": "preset_01",
  "bio": "Learning full-stack development.",
  "timezone": "Asia/Dhaka",
  "xp": {
    "total_xp": 1250,
    "current_level": 5,
    "level_label": "Apprentice",
    "xp_to_next_level": 250
  },
  "streaks": {
    "current_streak": 7,
    "longest_streak": 21,
    "total_active_days": 45,
    "at_risk": false
  },
  "recent_achievements": [
    { "id": 3, "name": "7-Day Streak", "icon_key": "streak_7", "unlocked_at": "2025-04-25T00:00:00Z" }
  ],
  "peers_count": 4,
  "created_at": "2025-01-10T08:00:00Z"
}
```

---

### **PUT** `/users/me`
Update display name, avatar, bio, timezone, profession.

- **Auth:** Required
- **Rate limit:** 20 req/min

**Request Body:**
```json
{
  "full_name": "string, optional, 2–120 chars",
  "avatar": "string, optional, preset key or URL",
  "bio": "string, optional, max 500 chars",
  "timezone": "string, optional, valid IANA timezone",
  "profession": "student | self_learner | professional, optional"
}
```

**Success — 200 OK:**
```json
{
  "message": "Profile updated.",
  "user": { "...updated fields..." }
}
```

**Errors:**
- `422 VALIDATION_ERROR`

---

### **PUT** `/users/me/password`
Change password (requires current password verification).

- **Auth:** Required
- **Rate limit:** 5 req/min

**Request Body:**
```json
{
  "current_password": "string, required",
  "new_password": "string, required, min 8 chars"
}
```

**Success — 200 OK:**
```json
{ "message": "Password changed successfully." }
```

**Errors:**
- `401 INCORRECT_CURRENT_PASSWORD`
- `422 VALIDATION_ERROR`

---

### **DELETE** `/users/me`
Soft-delete own account.

- **Auth:** Required
- **Rate limit:** 3 req/min

**Request Body:**
```json
{ "password": "string, required — confirmation" }
```

**Success — 204 No Content**

**Errors:**
- `401 INCORRECT_PASSWORD`

---

### **GET** `/users/:id`
Public profile of any user (for peer viewing).

- **Auth:** Required
- **Rate limit:** 60 req/min
- **Path params:** `id` — integer

**Success — 200 OK:**
```json
{
  "id": 7,
  "full_name": "Nadia Islam",
  "profession": "professional",
  "avatar": "preset_05",
  "bio": "Full-stack dev learning ML.",
  "current_level": 8,
  "total_xp": 3400,
  "current_streak": 12,
  "highest_streak": 34,
  "global_rank": 142,
  "skills_learning": ["Machine Learning", "Python"],
  "is_peer": true
}
```

**Errors:**
- `404 USER_NOT_FOUND`

---

## Module 4: Roadmap Generator

---

### **POST** `/roadmaps/generate`
Submit inputs to generate a roadmap via Gemini API (async job).

- **Auth:** Required
- **Rate limit:** 3 req/min

**Request Body:**
```json
{
  "skill_goal": "string, required, max 120 chars",
  "daily_time_minutes": "integer, required, 15–480",
  "duration_months": "integer, required, one of: 1, 3, 6, 12",
  "goal_purpose": "job | education | other, required",
  "experience_description": "string, optional, max 1000 chars",
  "level": "beginner | intermediate | advanced, required",
  "focus_areas": ["array of strings, optional, max 10 items"]
}
```

**Success — 202 Accepted:**
```json
{
  "job_id": "gen_abc123xyz",
  "status": "queued",
  "message": "Roadmap generation started. Poll /roadmaps/generate/status/{job_id} for updates.",
  "estimated_seconds": 15
}
```

**Errors:**
- `422 VALIDATION_ERROR`
- `429 GENERATION_LIMIT_REACHED` — too many concurrent generations

---

### **GET** `/roadmaps/generate/status/:job_id`
Poll the status of an ongoing generation job.

- **Auth:** Required
- **Rate limit:** 30 req/min
- **Path params:** `job_id` — string

**Success — 200 OK:**
```json
{
  "job_id": "gen_abc123xyz",
  "status": "processing",
  "progress_percent": 60,
  "started_at": "2025-04-28T10:01:00Z",
  "estimated_remaining_seconds": 6
}
```
> `status` values: `queued | processing | complete | failed`

**Errors:**
- `404 JOB_NOT_FOUND`
- `403 FORBIDDEN` — job belongs to another user

---

### **GET** `/roadmaps/generate/result/:job_id`
Fetch the completed roadmap data after generation.

- **Auth:** Required
- **Rate limit:** 20 req/min
- **Path params:** `job_id` — string

**Success — 200 OK:**
```json
{
  "job_id": "gen_abc123xyz",
  "status": "complete",
  "roadmap": {
    "title": "Python for Data Science",
    "skill_goal": "Python",
    "level": "beginner",
    "total_days": 90,
    "phases": [
      {
        "title": "Phase 1: Foundation",
        "order_index": 1,
        "milestones": [
          {
            "title": "Python Basics",
            "duration_days": 14,
            "order_index": 1,
            "tasks": [
              {
                "day_number": 1,
                "title": "Variables & Data Types",
                "question": "What data type does Python use for decimal numbers?",
                "answer": "float",
                "estimated_time_minutes": 45,
                "xp_reward": 20
              }
            ],
            "resources": [
              {
                "title": "Python Crash Course",
                "resource_type": "course",
                "source_name": "Coursera",
                "url": "https://coursera.org/...",
                "duration_label": "4 hrs"
              }
            ]
          }
        ]
      }
    ]
  }
}
```

**Errors:**
- `404 JOB_NOT_FOUND`
- `400 GENERATION_NOT_COMPLETE` — job still in progress
- `400 GENERATION_FAILED` — Gemini returned an error

---

## Module 5: Roadmaps

---

### **GET** `/roadmaps`
List all roadmaps for the current user.

- **Auth:** Required
- **Rate limit:** 60 req/min
- **Query params:**
  - `status` — `active | completed | archived`, optional filter

**Success — 200 OK:**
```json
{
  "data": [
    {
      "id": 1,
      "title": "Python for Data Science",
      "skill_goal": "Python",
      "level": "beginner",
      "status": "active",
      "duration_months": 3,
      "total_days": 90,
      "start_date": "2025-04-01",
      "end_date": "2025-06-30",
      "progress_percent": 28.5,
      "created_at": "2025-04-01T08:00:00Z"
    }
  ],
  "pagination": { "page": 1, "limit": 20, "total": 1, "total_pages": 1 }
}
```

---

### **POST** `/roadmaps`
Create a roadmap manually or save from generation result.

- **Auth:** Required
- **Rate limit:** 10 req/min

**Request Body:**
```json
{
  "job_id": "string, optional — if saving from generation",
  "title": "string, required if no job_id, max 255",
  "skill_goal": "string, required if no job_id",
  "level": "beginner | intermediate | advanced",
  "daily_time_minutes": "integer, 15–480",
  "duration_months": "integer, 1 | 3 | 6 | 12",
  "goal_purpose": "job | education | other",
  "start_date": "date string YYYY-MM-DD, required",
  "focus_areas": ["array of strings, optional"]
}
```

**Success — 201 Created:**
```json
{
  "message": "Roadmap created.",
  "roadmap": { "id": 1, "title": "...", "status": "active", "...": "..." }
}
```

**Errors:**
- `404 JOB_NOT_FOUND` — if job_id invalid
- `400 GENERATION_NOT_COMPLETE`
- `422 VALIDATION_ERROR`

---

### **GET** `/roadmaps/:id`
Full roadmap with phases, milestones, and top-level progress.

- **Auth:** Required
- **Rate limit:** 60 req/min
- **Path params:** `id` — integer

**Success — 200 OK:**
```json
{
  "id": 1,
  "title": "Python for Data Science",
  "skill_goal": "Python",
  "level": "beginner",
  "status": "active",
  "total_days": 90,
  "start_date": "2025-04-01",
  "end_date": "2025-06-30",
  "progress_percent": 28.5,
  "daily_time_minutes": 60,
  "goal_purpose": "job",
  "focus_areas": ["NumPy", "Pandas"],
  "phases": [
    {
      "id": 1,
      "title": "Phase 1: Foundation",
      "order_index": 1,
      "milestones_count": 3,
      "milestones_completed": 1
    }
  ]
}
```

**Errors:**
- `404 ROADMAP_NOT_FOUND`

---

### **PUT** `/roadmaps/:id`
Update roadmap metadata.

- **Auth:** Required
- **Rate limit:** 20 req/min
- **Path params:** `id` — integer

**Request Body:**
```json
{
  "title": "string, optional",
  "status": "active | completed | archived, optional"
}
```

**Success — 200 OK:**
```json
{ "message": "Roadmap updated.", "roadmap": { "id": 1, "title": "...", "status": "active" } }
```

**Errors:**
- `404 ROADMAP_NOT_FOUND`
- `422 VALIDATION_ERROR`

---

### **DELETE** `/roadmaps/:id`
Soft-delete a roadmap.

- **Auth:** Required
- **Rate limit:** 10 req/min
- **Path params:** `id` — integer

**Success — 204 No Content**

**Errors:**
- `404 ROADMAP_NOT_FOUND`

---

### **POST** `/roadmaps/:id/regenerate`
Trigger AI regeneration of an existing roadmap (requires explicit confirmation).

- **Auth:** Required
- **Rate limit:** 2 req/min
- **Path params:** `id` — integer

**Request Body:**
```json
{
  "confirm": true,
  "reason": "string, optional"
}
```

**Success — 202 Accepted:**
```json
{
  "job_id": "gen_xyz789",
  "status": "queued",
  "message": "Regeneration started. Previous roadmap data will be replaced upon completion."
}
```

**Errors:**
- `400 CONFIRM_REQUIRED` — `confirm` not true
- `404 ROADMAP_NOT_FOUND`
- `409 ROADMAP_ALREADY_GENERATING`

---

## Module 6: Milestones

---

### **GET** `/roadmaps/:roadmap_id/milestones`
List all milestones for a roadmap with status and progress.

- **Auth:** Required
- **Rate limit:** 60 req/min
- **Path params:** `roadmap_id` — integer

**Success — 200 OK:**
```json
{
  "data": [
    {
      "id": 1,
      "title": "Python Basics",
      "description": "Core Python syntax and data types.",
      "duration_days": 14,
      "order_index": 1,
      "status": "completed",
      "prerequisite_milestone_id": null,
      "tasks_total": 14,
      "tasks_completed": 14
    },
    {
      "id": 2,
      "title": "Data Structures",
      "duration_days": 10,
      "order_index": 2,
      "status": "in_progress",
      "prerequisite_milestone_id": 1,
      "tasks_total": 10,
      "tasks_completed": 3
    }
  ]
}
```

---

### **GET** `/roadmaps/:roadmap_id/milestones/:id`
Milestone detail with full task list and resources.

- **Auth:** Required
- **Rate limit:** 60 req/min
- **Path params:** `roadmap_id`, `id` — integers

**Success — 200 OK:**
```json
{
  "id": 2,
  "title": "Data Structures",
  "description": "Lists, dicts, sets, tuples.",
  "duration_days": 10,
  "order_index": 2,
  "status": "in_progress",
  "tasks": [
    {
      "id": 15,
      "day_number": 15,
      "title": "Lists and Tuples",
      "question": "How do you add an item to a Python list?",
      "estimated_time_minutes": 45,
      "xp_reward": 20,
      "status": "completed"
    }
  ],
  "resources": [
    {
      "id": 3,
      "title": "Python Data Structures",
      "resource_type": "article",
      "source_name": "RealPython",
      "url": "https://realpython.com/...",
      "duration_label": "15 min",
      "is_bookmarked": true
    }
  ]
}
```

**Errors:**
- `404 MILESTONE_NOT_FOUND`

---

### **POST** `/roadmaps/:roadmap_id/milestones`
Add a new milestone to a roadmap.

- **Auth:** Required
- **Rate limit:** 20 req/min

**Request Body:**
```json
{
  "title": "string, required, max 255",
  "description": "string, optional",
  "duration_days": "integer, required, 1–365",
  "order_index": "integer, required",
  "prerequisite_milestone_id": "integer, optional"
}
```

**Success — 201 Created:**
```json
{ "message": "Milestone added.", "milestone": { "id": 4, "title": "...", "order_index": 4 } }
```

**Errors:**
- `404 ROADMAP_NOT_FOUND`
- `422 VALIDATION_ERROR`

---

### **PUT** `/roadmaps/:roadmap_id/milestones/:id`
Update milestone metadata.

- **Auth:** Required
- **Rate limit:** 20 req/min

**Request Body:**
```json
{
  "title": "string, optional",
  "description": "string, optional",
  "duration_days": "integer, optional",
  "order_index": "integer, optional"
}
```

**Success — 200 OK:**
```json
{ "message": "Milestone updated.", "milestone": { "id": 2, "...": "..." } }
```

**Errors:**
- `404 MILESTONE_NOT_FOUND`
- `422 VALIDATION_ERROR`

---

### **DELETE** `/roadmaps/:roadmap_id/milestones/:id`
Delete a milestone. Enforces minimum 3 milestones per roadmap.

- **Auth:** Required
- **Rate limit:** 10 req/min

**Success — 204 No Content**

**Errors:**
- `404 MILESTONE_NOT_FOUND`
- `400 MINIMUM_MILESTONES` — would drop below 3

---

### **PUT** `/roadmaps/:roadmap_id/milestones/reorder`
Batch reorder milestones.

- **Auth:** Required
- **Rate limit:** 20 req/min

**Request Body:**
```json
{
  "order": [
    { "id": 3, "order_index": 1 },
    { "id": 1, "order_index": 2 },
    { "id": 2, "order_index": 3 }
  ]
}
```

**Success — 200 OK:**
```json
{ "message": "Milestones reordered." }
```

**Errors:**
- `422 VALIDATION_ERROR` — duplicate order_index values

---

## Module 7: Tasks

---

### **GET** `/roadmaps/:roadmap_id/milestones/:milestone_id/tasks`
List all tasks for a milestone.

- **Auth:** Required
- **Rate limit:** 60 req/min

**Success — 200 OK:**
```json
{
  "data": [
    {
      "id": 15,
      "day_number": 15,
      "title": "Lists and Tuples",
      "question": "How do you add an item to a Python list?",
      "answer": "list.append(item)",
      "estimated_time_minutes": 45,
      "xp_reward": 20,
      "order_index": 1,
      "status": "completed",
      "completed_at": "2025-04-15T12:00:00Z"
    }
  ]
}
```

---

### **POST** `/roadmaps/:roadmap_id/milestones/:milestone_id/tasks`
Add a task to a milestone.

- **Auth:** Required
- **Rate limit:** 20 req/min

**Request Body:**
```json
{
  "title": "string, required",
  "question": "string, required",
  "answer": "string, required",
  "estimated_time_minutes": "integer, optional",
  "xp_reward": "integer, optional, default 10",
  "day_number": "integer, required",
  "order_index": "integer, required"
}
```

**Success — 201 Created:**
```json
{ "message": "Task added.", "task": { "id": 20, "...": "..." } }
```

---

### **PUT** `/roadmaps/:roadmap_id/milestones/:milestone_id/tasks/:id`
Update task fields.

- **Auth:** Required
- **Rate limit:** 20 req/min

**Request Body:** _(any subset of task fields)_

**Success — 200 OK:**
```json
{ "message": "Task updated.", "task": { "id": 20, "...": "..." } }
```

---

### **DELETE** `/roadmaps/:roadmap_id/milestones/:milestone_id/tasks/:id`
Soft-delete a task.

- **Auth:** Required
- **Rate limit:** 10 req/min

**Success — 204 No Content**

**Errors:**
- `404 TASK_NOT_FOUND`

---

### **POST** `/tasks/:id/complete`
Mark a task complete. Validates that the user's answer is correct before awarding XP.

- **Auth:** Required
- **Rate limit:** 30 req/min
- **Path params:** `id` — integer

**Request Body:**
```json
{
  "user_answer": "string, required"
}
```

**Success — 200 OK:**
```json
{
  "correct": true,
  "xp_awarded": 20,
  "total_xp": 1270,
  "level_up": false,
  "current_level": 5,
  "streak_updated": true,
  "current_streak": 8
}
```

**Errors:**
- `400 INCORRECT_ANSWER` — `{ "correct": false, "hint": "Check the append method." }`
- `409 ALREADY_COMPLETED`
- `404 TASK_NOT_FOUND`

---

### **POST** `/tasks/:id/uncomplete`
Undo a task completion (reverses XP, streak not affected).

- **Auth:** Required
- **Rate limit:** 10 req/min

**Success — 200 OK:**
```json
{
  "message": "Task marked incomplete.",
  "xp_deducted": 20,
  "total_xp": 1250
}
```

**Errors:**
- `409 TASK_NOT_COMPLETED`
- `404 TASK_NOT_FOUND`

---

## Module 8: Daily Tasks

---

### **GET** `/daily-tasks`
Get today's task list (or any date's tasks).

- **Auth:** Required
- **Rate limit:** 60 req/min
- **Query params:**
  - `date` — `YYYY-MM-DD`, default today
  - `roadmap_id` — integer, optional filter

**Success — 200 OK:**
```json
{
  "date": "2025-04-28",
  "data": [
    {
      "id": 45,
      "task_id": 15,
      "roadmap_id": 1,
      "roadmap_title": "Python for Data Science",
      "day_number": 28,
      "title": "Pandas DataFrames",
      "question": "How do you read a CSV in Pandas?",
      "status": "in_progress",
      "time_spent_seconds": 720,
      "timer_status": "paused",
      "scheduled_date": "2025-04-28",
      "xp_reward": 20
    }
  ],
  "summary": {
    "total": 3,
    "completed": 1,
    "in_progress": 1,
    "pending": 1
  }
}
```

---

### **POST** `/daily-tasks/:id/start-timer`
Start the stopwatch for a daily task.

- **Auth:** Required
- **Rate limit:** 60 req/min
- **Path params:** `id` — integer

**Request Body:** _(empty)_

**Success — 200 OK:**
```json
{
  "daily_task_id": 45,
  "timer_status": "running",
  "started_at": "2025-04-28T10:15:00Z",
  "elapsed_seconds": 720
}
```

**Errors:**
- `409 TIMER_ALREADY_RUNNING`
- `404 DAILY_TASK_NOT_FOUND`

---

### **POST** `/daily-tasks/:id/pause-timer`
Pause the stopwatch and store elapsed seconds.

- **Auth:** Required
- **Rate limit:** 60 req/min

**Success — 200 OK:**
```json
{
  "daily_task_id": 45,
  "timer_status": "paused",
  "elapsed_seconds": 900
}
```

**Errors:**
- `409 TIMER_NOT_RUNNING`

---

### **POST** `/daily-tasks/:id/stop-timer`
Stop and finalize time_spent_seconds.

- **Auth:** Required
- **Rate limit:** 60 req/min

**Success — 200 OK:**
```json
{
  "daily_task_id": 45,
  "timer_status": "idle",
  "time_spent_seconds": 1200,
  "message": "Timer stopped. Time recorded."
}
```

---

### **PUT** `/daily-tasks/:id/notes`
Save or update notes for a daily task entry.

- **Auth:** Required
- **Rate limit:** 30 req/min

**Request Body:**
```json
{
  "content": "string, required, max 5000 chars",
  "resource_links": ["array of URL strings, optional, max 10"]
}
```

**Success — 200 OK:**
```json
{
  "message": "Notes saved.",
  "note": {
    "id": 12,
    "content": "Pandas read_csv reads a CSV file into a DataFrame.",
    "resource_links": ["https://pandas.pydata.org/docs/..."],
    "skill_name": "Python",
    "day_number": 28
  }
}
```

---

### **GET** `/daily-tasks/summary`
Tasks done vs total for today (used on Dashboard).

- **Auth:** Required
- **Rate limit:** 60 req/min

**Success — 200 OK:**
```json
{
  "date": "2025-04-28",
  "completed": 2,
  "total": 4,
  "progress_percent": 50.0,
  "xp_earned_today": 40,
  "time_studied_seconds": 3600
}
```

---

## Module 9: Resources

---

### **GET** `/milestones/:milestone_id/resources`
List all resources for a milestone.

- **Auth:** Required
- **Rate limit:** 60 req/min

**Success — 200 OK:**
```json
{
  "data": [
    {
      "id": 3,
      "title": "Python Data Structures",
      "resource_type": "article",
      "source_name": "RealPython",
      "url": "https://realpython.com/...",
      "duration_label": "15 min",
      "is_bookmarked": false
    }
  ]
}
```

---

### **POST** `/milestones/:milestone_id/resources`
Add a resource to a milestone.

- **Auth:** Required
- **Rate limit:** 20 req/min

**Request Body:**
```json
{
  "title": "string, required, max 255",
  "resource_type": "video | article | course | other, required",
  "source_name": "string, optional",
  "url": "string, required, valid URL",
  "duration_label": "string, optional, e.g. '12 min'"
}
```

**Success — 201 Created:**
```json
{ "message": "Resource added.", "resource": { "id": 5, "...": "..." } }
```

---

### **PUT** `/milestones/:milestone_id/resources/:id`
Update a resource.

- **Auth:** Required
- **Rate limit:** 20 req/min

**Request Body:** _(any subset of resource fields)_

**Success — 200 OK:**
```json
{ "message": "Resource updated." }
```

---

### **DELETE** `/milestones/:milestone_id/resources/:id`
Delete a resource.

- **Auth:** Required
- **Rate limit:** 10 req/min

**Success — 204 No Content**

---

### **POST** `/resources/:id/bookmark`
Toggle bookmark on a resource.

- **Auth:** Required
- **Rate limit:** 30 req/min
- **Path params:** `id` — integer

**Success — 200 OK:**
```json
{
  "resource_id": 3,
  "is_bookmarked": true
}
```

---

### **GET** `/resources/bookmarked`
All bookmarked resources for the current user.

- **Auth:** Required
- **Rate limit:** 30 req/min

**Success — 200 OK:**
```json
{
  "data": [
    {
      "id": 3,
      "title": "Python Data Structures",
      "resource_type": "article",
      "url": "https://...",
      "milestone_title": "Data Structures",
      "roadmap_title": "Python for Data Science"
    }
  ],
  "pagination": { "...": "..." }
}
```

---

## Module 10: XP & Levels

---

### **GET** `/xp/me`
Current XP balance and level info.

- **Auth:** Required
- **Rate limit:** 60 req/min

**Success — 200 OK:**
```json
{
  "total_xp": 1270,
  "current_level": 5,
  "level_label": "Apprentice",
  "xp_for_current_level": 1000,
  "xp_for_next_level": 1500,
  "xp_to_next_level": 230,
  "progress_percent": 54.0
}
```

---

### **GET** `/xp/log`
Paginated XP transaction history.

- **Auth:** Required
- **Rate limit:** 30 req/min
- **Query params:** `page`, `limit`, `source_type` (filter)

**Success — 200 OK:**
```json
{
  "data": [
    {
      "id": 88,
      "source_type": "task",
      "source_id": 15,
      "xp_amount": 20,
      "description": "Completed: Lists and Tuples",
      "awarded_at": "2025-04-15T12:00:00Z"
    }
  ],
  "pagination": { "...": "..." }
}
```

---

### **GET** `/levels`
All level definitions (for UI display).

- **Auth:** Required
- **Rate limit:** 60 req/min

**Success — 200 OK:**
```json
{
  "data": [
    { "level_number": 1, "label": "Beginner", "xp_required": 0 },
    { "level_number": 2, "label": "Explorer", "xp_required": 100 },
    { "level_number": 5, "label": "Apprentice", "xp_required": 1000 }
  ]
}
```

---

## Module 11: Streaks

---

### **GET** `/streaks/me`
Current streak stats for the authenticated user.

- **Auth:** Required
- **Rate limit:** 60 req/min

**Success — 200 OK:**
```json
{
  "current_streak": 7,
  "longest_streak": 21,
  "total_active_days": 45,
  "at_risk": false,
  "freeze_tokens_remaining": 1,
  "last_active_date": "2025-04-27"
}
```

---

### **GET** `/streaks/heatmap`
Last 12 weeks of activity (for heatmap display).

- **Auth:** Required
- **Rate limit:** 30 req/min

**Success — 200 OK:**
```json
{
  "data": [
    { "date": "2025-04-28", "tasks_completed": 3, "intensity": 3 },
    { "date": "2025-04-27", "tasks_completed": 1, "intensity": 1 },
    { "date": "2025-04-26", "tasks_completed": 0, "intensity": 0 }
  ]
}
```
> `intensity`: 0 = inactive, 1 = low, 2 = medium, 3 = high (≥3 tasks)

---

### **GET** `/streaks/milestones`
Streak milestone badges with locked/unlocked status.

- **Auth:** Required
- **Rate limit:** 30 req/min

**Success — 200 OK:**
```json
{
  "data": [
    { "days": 7,  "label": "Week Warrior",  "unlocked": true,  "unlocked_at": "2025-04-20T00:00:00Z" },
    { "days": 30, "label": "Month Master",  "unlocked": false, "unlocked_at": null },
    { "days": 100,"label": "Century Keeper","unlocked": false, "unlocked_at": null }
  ]
}
```

---

### **POST** `/streaks/freeze`
Consume a streak freeze token (max 1 per calendar week).

- **Auth:** Required
- **Rate limit:** 5 req/min

**Request Body:** _(empty)_

**Success — 200 OK:**
```json
{
  "message": "Streak freeze applied for today.",
  "freeze_used_on": "2025-04-28",
  "remaining_this_week": 0
}
```

**Errors:**
- `400 NO_FREEZE_TOKENS` — user has no tokens available
- `400 FREEZE_ALREADY_USED_THIS_WEEK`
- `400 STREAK_NOT_AT_RISK` — freeze not needed today

---

## Module 12: Achievements

---

### **GET** `/achievements`
All achievement definitions with user's unlock status.

- **Auth:** Required
- **Rate limit:** 30 req/min

**Success — 200 OK:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "First Step",
      "description": "Complete your first roadmap task.",
      "icon_key": "first_task",
      "xp_reward": 50,
      "achievement_points": 10,
      "condition_type": "tasks_done",
      "condition_value": 1,
      "unlocked": true,
      "unlocked_at": "2025-04-01T09:00:00Z"
    },
    {
      "id": 2,
      "name": "7-Day Streak",
      "description": "Maintain a 7-day streak.",
      "icon_key": "streak_7",
      "xp_reward": 100,
      "achievement_points": 25,
      "condition_type": "streak_days",
      "condition_value": 7,
      "unlocked": true,
      "unlocked_at": "2025-04-08T00:00:00Z"
    },
    {
      "id": 5,
      "name": "Century Keeper",
      "description": "Maintain a 100-day streak.",
      "icon_key": "streak_100",
      "xp_reward": 500,
      "achievement_points": 200,
      "unlocked": false,
      "unlocked_at": null
    }
  ]
}
```

---

### **GET** `/achievements/me`
Only achievements the user has unlocked, with points summary.

- **Auth:** Required
- **Rate limit:** 30 req/min

**Success — 200 OK:**
```json
{
  "total_points_earned": 150,
  "total_points_spent": 50,
  "points_balance": 100,
  "achievements": [ { "...": "..." } ]
}
```

---

## Module 13: Rewards Store

---

### **GET** `/rewards`
List all available reward items.

- **Auth:** Required
- **Rate limit:** 30 req/min

**Success — 200 OK:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Dark Theme",
      "description": "Unlock the sleek dark mode.",
      "item_type": "theme",
      "point_cost": 100,
      "duration_hours": null,
      "is_active": true,
      "already_owned": false
    },
    {
      "id": 3,
      "name": "XP Boost (1 Day)",
      "description": "Double XP for 24 hours.",
      "item_type": "xp_boost",
      "point_cost": 50,
      "duration_hours": 24,
      "already_owned": false
    }
  ]
}
```

---

### **POST** `/rewards/:id/purchase`
Purchase a reward item with achievement points.

- **Auth:** Required
- **Rate limit:** 10 req/min
- **Path params:** `id` — integer

**Request Body:** _(empty)_

**Success — 200 OK:**
```json
{
  "message": "Reward purchased.",
  "item": { "id": 3, "name": "XP Boost (1 Day)" },
  "points_spent": 50,
  "points_balance": 50,
  "expires_at": "2025-04-29T10:00:00Z"
}
```

**Errors:**
- `400 INSUFFICIENT_POINTS`
- `409 ALREADY_OWNED` — for permanent items
- `404 REWARD_NOT_FOUND`

---

### **GET** `/rewards/me`
User's purchased rewards and their active status.

- **Auth:** Required
- **Rate limit:** 30 req/min

**Success — 200 OK:**
```json
{
  "data": [
    {
      "id": 7,
      "item_id": 3,
      "item_name": "XP Boost (1 Day)",
      "item_type": "xp_boost",
      "is_active": true,
      "purchased_at": "2025-04-28T10:00:00Z",
      "expires_at": "2025-04-29T10:00:00Z"
    }
  ]
}
```

---

## Module 14: Leaderboard

---

### **GET** `/leaderboard/weekly`
Ranked list for the current ISO week.

- **Auth:** Required
- **Rate limit:** 30 req/min
- **Query params:** `week_number`, `year` (optional, defaults to current)

**Success — 200 OK:**
```json
{
  "week_number": 17,
  "year": 2025,
  "data": [
    {
      "rank": 1,
      "user_id": 42,
      "display_name": "Nadia Islam",
      "avatar": "preset_05",
      "xp_gained": 480,
      "current_streak": 14
    }
  ],
  "pagination": { "...": "..." }
}
```

---

### **GET** `/leaderboard/alltime`
All-time leaderboard ranked by global ranking score.

- **Auth:** Required
- **Rate limit:** 30 req/min

**Success — 200 OK:**
```json
{
  "data": [
    {
      "rank": 1,
      "user_id": 42,
      "display_name": "Nadia Islam",
      "avatar": "preset_05",
      "total_xp": 12400,
      "current_streak": 45,
      "hours_studied": 320.5,
      "milestones_reached": 24,
      "lifetime_achievement_points": 850,
      "ranking_score": 87650.0
    }
  ],
  "pagination": { "...": "..." }
}
```

---

### **GET** `/leaderboard/me`
Current user's rank in both leaderboards.

- **Auth:** Required
- **Rate limit:** 30 req/min

**Success — 200 OK:**
```json
{
  "weekly": {
    "rank": 5,
    "xp_gained": 220,
    "week_number": 17,
    "year": 2025
  },
  "alltime": {
    "rank": 142,
    "percentile": 91.3,
    "ranking_score": 18750.0,
    "xp_to_next_rank": 340
  }
}
```

---

## Module 15: Peers

---

### **GET** `/peers`
List all accepted peers of the current user.

- **Auth:** Required
- **Rate limit:** 60 req/min

**Success — 200 OK:**
```json
{
  "data": [
    {
      "peer_user_id": 7,
      "display_name": "Nadia Islam",
      "avatar": "preset_05",
      "profession": "professional",
      "current_streak": 12,
      "highest_streak": 34,
      "current_level": 8,
      "skills_learning": ["Machine Learning"],
      "global_rank": 142,
      "paired_at": "2025-03-01T00:00:00Z"
    }
  ],
  "pagination": { "...": "..." }
}
```

---

### **GET** `/peers/discover`
Search for other platform users to add as peers.

- **Auth:** Required
- **Rate limit:** 30 req/min
- **Query params:**
  - `q` — search string (name or email), optional
  - `skill` — filter by skill being learned, optional
  - `page`, `limit`

**Success — 200 OK:**
```json
{
  "data": [
    {
      "user_id": 99,
      "display_name": "Karim Hasan",
      "profession": "student",
      "bio": "Learning web dev.",
      "skills_learning": ["JavaScript", "React"],
      "current_streak": 3,
      "highest_streak": 10,
      "current_level": 3,
      "global_rank": 520,
      "request_status": "none"
    }
  ],
  "pagination": { "...": "..." }
}
```
> `request_status`: `none | pending_sent | pending_received | paired`

---

### **POST** `/peers/request`
Send a peer pairing request.

- **Auth:** Required
- **Rate limit:** 20 req/min

**Request Body:**
```json
{ "receiver_id": "integer, required" }
```

**Success — 201 Created:**
```json
{ "message": "Peer request sent.", "request_id": 14 }
```

**Errors:**
- `404 USER_NOT_FOUND`
- `409 REQUEST_ALREADY_SENT`
- `409 ALREADY_PEERS`

---

### **PUT** `/peers/request/:id`
Accept or decline a peer request.

- **Auth:** Required
- **Rate limit:** 20 req/min
- **Path params:** `id` — integer (request id)

**Request Body:**
```json
{ "action": "accepted | declined, required" }
```

**Success — 200 OK:**
```json
{ "message": "Peer request accepted.", "status": "accepted" }
```

**Errors:**
- `404 REQUEST_NOT_FOUND`
- `403 NOT_RECEIVER` — only the receiver can respond

---

### **DELETE** `/peers/:peer_user_id`
Remove a peer connection.

- **Auth:** Required
- **Rate limit:** 10 req/min
- **Path params:** `peer_user_id` — integer

**Success — 204 No Content**

**Errors:**
- `404 PEER_NOT_FOUND`

---

## Module 16: Peer Groups & Chat

---

### **GET** `/peers/groups`
List peer groups the user belongs to.

- **Auth:** Required
- **Rate limit:** 30 req/min

**Success — 200 OK:**
```json
{
  "data": [
    {
      "id": 3,
      "name": "Python Learners",
      "focus_area_tags": ["Python", "Data Science"],
      "member_count": 12,
      "role": "member",
      "joined_at": "2025-03-10T00:00:00Z",
      "last_message_at": "2025-04-27T20:00:00Z"
    }
  ]
}
```

---

### **GET** `/peers/groups/discover`
Suggested groups based on user's roadmap focus areas.

- **Auth:** Required
- **Rate limit:** 20 req/min

**Success — 200 OK:**
```json
{
  "data": [
    {
      "id": 5,
      "name": "ML Practitioners",
      "focus_area_tags": ["Machine Learning", "Python"],
      "member_count": 38,
      "overlap_skills": ["Python"]
    }
  ]
}
```

---

### **POST** `/peers/groups/:id/join`
Join a peer group.

- **Auth:** Required
- **Rate limit:** 10 req/min
- **Path params:** `id` — integer

**Success — 200 OK:**
```json
{ "message": "Joined group Python Learners.", "group_id": 3 }
```

**Errors:**
- `404 GROUP_NOT_FOUND`
- `409 ALREADY_MEMBER`

---

### **POST** `/peers/groups/:id/leave`
Leave a peer group.

- **Auth:** Required
- **Rate limit:** 10 req/min

**Success — 200 OK:**
```json
{ "message": "Left group." }
```

**Errors:**
- `403 CANNOT_LEAVE_LAST_MODERATOR`

---

### **GET** `/peers/groups/:id`
Group detail with member list.

- **Auth:** Required
- **Rate limit:** 30 req/min

**Success — 200 OK:**
```json
{
  "id": 3,
  "name": "Python Learners",
  "focus_area_tags": ["Python", "Data Science"],
  "members": [
    {
      "user_id": 1,
      "display_name": "Rahim Uddin",
      "avatar": "preset_01",
      "role": "member",
      "joined_at": "2025-03-10T00:00:00Z"
    }
  ]
}
```

---

### **GET** `/peers/groups/:group_id/threads`
List threads in a group (paginated).

- **Auth:** Required (must be group member)
- **Rate limit:** 30 req/min

**Success — 200 OK:**
```json
{
  "data": [
    {
      "id": 9,
      "title": "Best Python resources?",
      "created_by": { "user_id": 1, "display_name": "Rahim Uddin" },
      "message_count": 14,
      "last_message_at": "2025-04-27T20:00:00Z",
      "created_at": "2025-04-20T10:00:00Z"
    }
  ],
  "pagination": { "...": "..." }
}
```

---

### **POST** `/peers/groups/:group_id/threads`
Create a new thread.

- **Auth:** Required (must be group member)
- **Rate limit:** 10 req/min

**Request Body:**
```json
{ "title": "string, optional, max 255" }
```

**Success — 201 Created:**
```json
{ "message": "Thread created.", "thread": { "id": 10, "title": "..." } }
```

---

### **GET** `/peers/groups/:group_id/threads/:thread_id/messages`
List messages in a thread, with nested replies.

- **Auth:** Required (must be group member)
- **Rate limit:** 60 req/min

**Success — 200 OK:**
```json
{
  "data": [
    {
      "id": 55,
      "sender": { "user_id": 1, "display_name": "Rahim Uddin", "avatar": "preset_01" },
      "body": "I've been using RealPython — highly recommend!",
      "parent_message_id": null,
      "is_deleted": false,
      "reactions": [{ "emoji": "👍", "count": 3, "reacted_by_me": true }],
      "replies": [
        {
          "id": 56,
          "sender": { "user_id": 7, "display_name": "Nadia Islam" },
          "body": "Same here! Great explanations.",
          "parent_message_id": 55,
          "reactions": [],
          "created_at": "2025-04-27T20:05:00Z"
        }
      ],
      "created_at": "2025-04-27T20:00:00Z",
      "edited_at": null
    }
  ],
  "pagination": { "...": "..." }
}
```

---

### **POST** `/peers/groups/:group_id/threads/:thread_id/messages`
Post a message (supports replies via `parent_message_id`).

- **Auth:** Required (must be group member)
- **Rate limit:** 20 req/min

**Request Body:**
```json
{
  "body": "string, required, max 5000 chars",
  "parent_message_id": "integer, optional — for threaded replies"
}
```

**Success — 201 Created:**
```json
{ "message": "Message posted.", "message_id": 57 }
```

---

### **PUT** `/peers/groups/:group_id/threads/:thread_id/messages/:id`
Edit a message (owner only).

- **Auth:** Required
- **Rate limit:** 20 req/min

**Request Body:**
```json
{ "body": "string, required" }
```

**Success — 200 OK:**
```json
{ "message": "Message updated.", "edited_at": "2025-04-28T10:00:00Z" }
```

**Errors:**
- `403 NOT_OWNER`
- `404 MESSAGE_NOT_FOUND`

---

### **DELETE** `/peers/groups/:group_id/threads/:thread_id/messages/:id`
Soft-delete a message (owner or moderator).

- **Auth:** Required
- **Rate limit:** 20 req/min

**Success — 200 OK:**
```json
{ "message": "Message deleted.", "body": "[deleted]" }
```

**Errors:**
- `403 FORBIDDEN` — not owner or moderator

---

### **POST** `/peers/groups/:group_id/threads/:thread_id/messages/:id/react`
Add or toggle an emoji reaction.

- **Auth:** Required (must be group member)
- **Rate limit:** 30 req/min

**Request Body:**
```json
{ "emoji": "string, required, single emoji character" }
```

**Success — 200 OK:**
```json
{
  "message_id": 55,
  "emoji": "👍",
  "reacted": true,
  "total_reactions": 4
}
```

---

## Module 17: Notes

---

### **GET** `/notes`
List all notes for the current user.

- **Auth:** Required
- **Rate limit:** 30 req/min
- **Query params:** `roadmap_id`, `day_number`, `skill_name`, `page`, `limit`

**Success — 200 OK:**
```json
{
  "data": [
    {
      "id": 12,
      "content": "Pandas read_csv reads a CSV into a DataFrame.",
      "resource_links": ["https://pandas.pydata.org/docs/"],
      "roadmap_id": 1,
      "roadmap_title": "Python for Data Science",
      "skill_name": "Python",
      "day_number": 28,
      "created_at": "2025-04-28T11:00:00Z"
    }
  ],
  "pagination": { "...": "..." }
}
```

---

### **POST** `/notes`
Create a note (manual — must specify skill and optionally day).

- **Auth:** Required
- **Rate limit:** 30 req/min

**Request Body:**
```json
{
  "content": "string, required, max 10000 chars",
  "resource_links": ["array of URLs, optional"],
  "roadmap_id": "integer, optional",
  "day_number": "integer, optional",
  "skill_name": "string, optional, max 255"
}
```

**Success — 201 Created:**
```json
{ "message": "Note created.", "note": { "id": 13, "...": "..." } }
```

---

### **PUT** `/notes/:id`
Update a note.

- **Auth:** Required
- **Rate limit:** 20 req/min

**Request Body:** _(any subset of note fields)_

**Success — 200 OK:**
```json
{ "message": "Note updated." }
```

---

### **DELETE** `/notes/:id`
Delete a note.

- **Auth:** Required
- **Rate limit:** 10 req/min

**Success — 204 No Content**

**Errors:**
- `404 NOTE_NOT_FOUND`

---

## Module 18: Flashcards

---

### **GET** `/flashcards`
List all flashcards for the current user.

- **Auth:** Required
- **Rate limit:** 30 req/min
- **Query params:** `skill_name`, `difficulty`, `source` (`auto_generated | manual`), `page`, `limit`

**Success — 200 OK:**
```json
{
  "data": [
    {
      "id": 7,
      "skill_name": "Python",
      "question": "What is the difference between a list and a tuple?",
      "answer": "Lists are mutable; tuples are immutable.",
      "difficulty": "medium",
      "mastery": 40,
      "source": "auto_generated",
      "created_at": "2025-04-10T09:00:00Z"
    }
  ],
  "pagination": { "...": "..." }
}
```

---

### **POST** `/flashcards`
Create a flashcard manually.

- **Auth:** Required
- **Rate limit:** 20 req/min

**Request Body:**
```json
{
  "question": "string, required",
  "answer": "string, required",
  "skill_name": "string, required",
  "difficulty": "easy | medium | hard | forgot, required"
}
```

**Success — 201 Created:**
```json
{ "message": "Flashcard created.", "flashcard": { "id": 8, "mastery": 0, "...": "..." } }
```

---

### **POST** `/flashcards/generate`
Auto-generate flashcards from all user notes (AI-powered).

- **Auth:** Required
- **Rate limit:** 3 req/min

**Request Body:**
```json
{
  "skill_name": "string, optional — generate only for this skill",
  "roadmap_id": "integer, optional"
}
```

**Success — 202 Accepted:**
```json
{
  "job_id": "fc_gen_xyz",
  "message": "Flashcard generation started.",
  "estimated_seconds": 10
}
```

---

### **GET** `/flashcards/generate/status/:job_id`
Poll flashcard generation job status.

- **Auth:** Required

**Success — 200 OK:**
```json
{
  "job_id": "fc_gen_xyz",
  "status": "complete",
  "cards_generated": 15
}
```

---

### **PUT** `/flashcards/:id`
Update flashcard difficulty or content.

- **Auth:** Required
- **Rate limit:** 30 req/min

**Request Body:**
```json
{
  "difficulty": "easy | medium | hard | forgot, optional (can never reset to null)",
  "question": "string, optional",
  "answer": "string, optional"
}
```

**Success — 200 OK:**
```json
{ "message": "Flashcard updated.", "flashcard": { "id": 7, "difficulty": "easy", "..." : "..." } }
```

**Errors:**
- `400 CANNOT_UNSET_DIFFICULTY` — difficulty cannot be set to null

---

### **DELETE** `/flashcards/:id`
Delete a flashcard.

- **Auth:** Required
- **Rate limit:** 10 req/min

**Success — 204 No Content**

---

### **POST** `/flashcards/study/session`
Start a study mode session. Returns a filtered set of flashcards.

- **Auth:** Required
- **Rate limit:** 10 req/min

**Request Body:**
```json
{
  "skill_names": ["array of strings, optional — empty means all skills"],
  "difficulties": ["easy | medium | hard | forgot | null — optional filter"],
  "limit": "integer, optional, default 20, max 50"
}
```

**Success — 200 OK:**
```json
{
  "session_id": "study_abc",
  "cards": [
    {
      "id": 7,
      "skill_name": "Python",
      "question": "What is the difference between a list and a tuple?",
      "mastery": 40
    }
  ],
  "total_cards": 14
}
```

---

### **POST** `/flashcards/:id/review`
Review a flashcard in study mode — sets difficulty and updates mastery.

- **Auth:** Required
- **Rate limit:** 60 req/min
- **Path params:** `id` — integer

**Request Body:**
```json
{
  "difficulty": "easy | medium | hard | forgot, required"
}
```

**Success — 200 OK:**
```json
{
  "flashcard_id": 7,
  "difficulty_set": "easy",
  "mastery_before": 40,
  "mastery_after": 55,
  "xp_awarded": 5
}
```

---

## Module 19: Notifications

---

### **GET** `/notifications`
Paginated notifications list (max 50 shown).

- **Auth:** Required
- **Rate limit:** 30 req/min
- **Query params:**
  - `tab` — `all | peers | system | reminders`, default `all`
  - `page`, `limit`

**Success — 200 OK:**
```json
{
  "unread_count": 3,
  "data": [
    {
      "id": 21,
      "type": "peer_request",
      "title": "New peer request",
      "body": "Nadia Islam wants to pair up with you.",
      "reference_type": "peer_request",
      "reference_id": 14,
      "is_read": false,
      "created_at": "2025-04-28T09:00:00Z"
    }
  ],
  "pagination": { "...": "..." }
}
```

---

### **POST** `/notifications/read-all`
Mark all notifications as read.

- **Auth:** Required
- **Rate limit:** 10 req/min

**Success — 200 OK:**
```json
{ "message": "All notifications marked as read.", "updated_count": 3 }
```

---

### **PUT** `/notifications/:id/read`
Mark a single notification as read.

- **Auth:** Required
- **Rate limit:** 60 req/min
- **Path params:** `id` — integer

**Success — 200 OK:**
```json
{ "notification_id": 21, "is_read": true }
```

---

### **DELETE** `/notifications/:id`
Delete a single notification.

- **Auth:** Required
- **Rate limit:** 30 req/min

**Success — 204 No Content**

---

## Module 20: Weekly Review

---

### **GET** `/reviews/current`
Current week's review: stats, AI insight, peer comparison.

- **Auth:** Required
- **Rate limit:** 30 req/min

**Success — 200 OK:**
```json
{
  "week_number": 17,
  "year": 2025,
  "tasks_done": 18,
  "xp_earned": 360,
  "streak_days": 5,
  "hours_studied": 9.5,
  "score": 74,
  "ai_insight_text": "Great consistency this week! You completed 18 tasks and studied 9.5 hours. Focus on reducing missed days next week.",
  "peer_comparison_percent": 22.5,
  "goals": [
    { "id": 3, "goal_text": "Complete milestone 2", "status": "hit" }
  ]
}
```

---

### **GET** `/reviews/history`
Past weekly review summaries.

- **Auth:** Required
- **Rate limit:** 20 req/min

**Success — 200 OK:**
```json
{
  "data": [
    { "week_number": 16, "year": 2025, "score": 68, "tasks_done": 14, "xp_earned": 280 }
  ],
  "pagination": { "...": "..." }
}
```

---

### **GET** `/reviews/:week_number/:year`
Specific week's review.

- **Auth:** Required
- **Rate limit:** 30 req/min
- **Path params:** `week_number` (1–53), `year`

**Success — 200 OK:** _(same shape as `/reviews/current`)_

**Errors:**
- `404 REVIEW_NOT_FOUND`

---

### **POST** `/reviews/:week_number/:year/goals`
Set goals for the upcoming week.

- **Auth:** Required
- **Rate limit:** 10 req/min

**Request Body:**
```json
{
  "goals": [
    { "goal_text": "Complete Python milestone 3" },
    { "goal_text": "Study 8 hours this week" }
  ]
}
```

**Success — 201 Created:**
```json
{ "message": "Goals set.", "goals": [ { "id": 4, "goal_text": "...", "status": null } ] }
```

---

### **PUT** `/reviews/:week_number/:year/goals/:id`
Update a goal's status after the week ends.

- **Auth:** Required
- **Rate limit:** 10 req/min

**Request Body:**
```json
{ "status": "hit | missed | partial, required" }
```

**Success — 200 OK:**
```json
{ "goal_id": 4, "status": "hit" }
```

---

## Module 21: Kanban Board

---

### **GET** `/kanban`
Get the user's kanban board with all columns and cards.

- **Auth:** Required
- **Rate limit:** 30 req/min
- **Query params:** `project_id` — integer, optional

**Success — 200 OK:**
```json
{
  "board_id": 1,
  "columns": [
    {
      "id": 1,
      "title": "To Do",
      "order_index": 1,
      "color": "blue",
      "cards": [
        {
          "id": 5,
          "title": "Implement login page",
          "description": "Use JWT auth.",
          "due_date": "2025-05-01",
          "order_index": 1,
          "is_done": false,
          "task_id": null
        }
      ]
    },
    { "id": 2, "title": "In Progress", "order_index": 2, "cards": [] },
    { "id": 3, "title": "Review",      "order_index": 3, "cards": [] },
    { "id": 4, "title": "Done",        "order_index": 4, "cards": [] }
  ]
}
```

---

### **POST** `/kanban/columns`
Add a column to the board.

- **Auth:** Required
- **Rate limit:** 10 req/min

**Request Body:**
```json
{
  "title": "string, required, max 60",
  "color": "string, optional",
  "order_index": "integer, required"
}
```

**Success — 201 Created:**
```json
{ "message": "Column added.", "column": { "id": 5, "title": "Backlog", "order_index": 5 } }
```

---

### **PUT** `/kanban/columns/:id`
Rename or recolor a column.

- **Auth:** Required
- **Rate limit:** 20 req/min

**Request Body:**
```json
{
  "title": "string, optional",
  "color": "string, optional"
}
```

**Success — 200 OK:**
```json
{ "message": "Column updated." }
```

---

### **DELETE** `/kanban/columns/:id`
Delete a column and all its cards.

- **Auth:** Required
- **Rate limit:** 10 req/min

**Success — 204 No Content**

---

### **PUT** `/kanban/columns/reorder`
Reorder board columns.

- **Auth:** Required
- **Rate limit:** 20 req/min

**Request Body:**
```json
{
  "order": [ { "id": 2, "order_index": 1 }, { "id": 1, "order_index": 2 } ]
}
```

**Success — 200 OK:**
```json
{ "message": "Columns reordered." }
```

---

### **POST** `/kanban/columns/:column_id/cards`
Add a card to a column.

- **Auth:** Required
- **Rate limit:** 30 req/min

**Request Body:**
```json
{
  "title": "string, required, max 255",
  "description": "string, optional",
  "due_date": "date YYYY-MM-DD, optional",
  "order_index": "integer, required",
  "task_id": "integer, optional — links to a roadmap task"
}
```

**Success — 201 Created:**
```json
{ "message": "Card added.", "card": { "id": 6, "...": "..." } }
```

---

### **PUT** `/kanban/cards/:id`
Update card fields or move to a different column (drag-drop).

- **Auth:** Required
- **Rate limit:** 30 req/min

**Request Body:**
```json
{
  "title": "string, optional",
  "description": "string, optional",
  "due_date": "date, optional",
  "column_id": "integer, optional — for drag-drop move",
  "is_done": "boolean, optional",
  "order_index": "integer, optional"
}
```

**Success — 200 OK:**
```json
{ "message": "Card updated." }
```

---

### **DELETE** `/kanban/cards/:id`
Soft-delete a card.

- **Auth:** Required
- **Rate limit:** 10 req/min

**Success — 204 No Content**

---

### **PUT** `/kanban/cards/reorder`
Batch reorder cards within or across columns.

- **Auth:** Required
- **Rate limit:** 20 req/min

**Request Body:**
```json
{
  "cards": [
    { "id": 5, "column_id": 2, "order_index": 1 },
    { "id": 6, "column_id": 2, "order_index": 2 }
  ]
}
```

**Success — 200 OK:**
```json
{ "message": "Cards reordered." }
```

---

## Module 22: Projects

---

### **GET** `/projects`
List all projects for the current user.

- **Auth:** Required
- **Rate limit:** 30 req/min
- **Query params:** `status` — `active | completed | archived`

**Success — 200 OK:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Portfolio Website",
      "skill_name": "React",
      "color": "blue",
      "status": "active",
      "start_date": "2025-04-01",
      "due_date": "2025-04-30",
      "deadline_days": 29,
      "progress_percent": 45.0
    }
  ],
  "pagination": { "...": "..." }
}
```

---

### **POST** `/projects`
Create a new project (triggers AI task generation).

- **Auth:** Required
- **Rate limit:** 5 req/min

**Request Body:**
```json
{
  "name": "string, required, max 255",
  "description": "string, required, max 2000",
  "deadline_days": "integer, required, 1–365",
  "skill_name": "string, optional",
  "color": "blue | cyan | green | orange | red, required"
}
```

**Success — 201 Created:**
```json
{
  "message": "Project created. Tasks and Gantt chart generated.",
  "project": {
    "id": 2,
    "name": "Portfolio Website",
    "color": "blue",
    "start_date": "2025-04-28",
    "due_date": "2025-05-27"
  },
  "kanban_board_id": 3
}
```

---

### **GET** `/projects/:id`
Full project detail with Gantt entries and progress.

- **Auth:** Required
- **Rate limit:** 30 req/min

**Success — 200 OK:**
```json
{
  "id": 2,
  "name": "Portfolio Website",
  "description": "Personal portfolio with React and Tailwind.",
  "color": "blue",
  "status": "active",
  "progress_percent": 45.0,
  "kanban_board_id": 3,
  "gantt": [
    { "id": 1, "feature_name": "Setup & Config",   "order_index": 1, "start_day": 0, "duration_days": 2 },
    { "id": 2, "feature_name": "Hero Section",     "order_index": 2, "start_day": 2, "duration_days": 3 },
    { "id": 3, "feature_name": "Projects Section", "order_index": 3, "start_day": 5, "duration_days": 4 }
  ]
}
```

---

### **PUT** `/projects/:id`
Update project metadata.

- **Auth:** Required
- **Rate limit:** 20 req/min

**Request Body:** _(any subset of project fields)_

**Success — 200 OK:**
```json
{ "message": "Project updated." }
```

---

### **DELETE** `/projects/:id`
Soft-delete a project.

- **Auth:** Required
- **Rate limit:** 10 req/min

**Success — 204 No Content**

---

### **PUT** `/projects/:id/gantt`
Update Gantt chart entries (sequence or duration).

- **Auth:** Required
- **Rate limit:** 10 req/min

**Request Body:**
```json
{
  "entries": [
    { "id": 1, "order_index": 1, "start_day": 0, "duration_days": 3 },
    { "id": 2, "order_index": 2, "start_day": 3, "duration_days": 4 }
  ]
}
```

**Success — 200 OK:**
```json
{ "message": "Gantt chart updated." }
```

---

## Module 23: Dashboard

---

### **GET** `/dashboard`
Full dashboard data in one call.

- **Auth:** Required
- **Rate limit:** 30 req/min

**Success — 200 OK:**
```json
{
  "today": {
    "date": "2025-04-28",
    "roadmap_tasks": [
      { "daily_task_id": 45, "title": "Pandas DataFrames", "roadmap_title": "Python for Data Science", "status": "pending" }
    ],
    "project_tasks": [
      { "card_id": 5, "title": "Implement login page", "project_name": "Portfolio Website", "is_done": false }
    ]
  },
  "active_roadmap": {
    "id": 1, "title": "Python for Data Science", "progress_percent": 28.5, "status": "active"
  },
  "active_project": {
    "id": 2, "name": "Portfolio Website", "color": "blue", "progress_percent": 45.0
  },
  "xp": {
    "total_xp": 1270,
    "current_level": 5,
    "level_label": "Apprentice",
    "xp_to_next_level": 230
  },
  "xp_graph": {
    "week":  [{ "date": "2025-04-22", "xp": 40 }, { "date": "2025-04-23", "xp": 20 }],
    "month": [{ "week": "W15", "xp": 180 }, { "week": "W16", "xp": 220 }],
    "year":  [{ "month": "Jan", "xp": 800 }, { "month": "Feb", "xp": 950 }],
    "avg_daily_xp": 35.4
  },
  "active_peers": [
    { "user_id": 7, "display_name": "Nadia Islam", "avatar": "preset_05", "current_streak": 12 }
  ]
}
```

---

## Module 24: Progress & Comparison

---

### **GET** `/progress`
Peer comparison and progress metrics.

- **Auth:** Required
- **Rate limit:** 20 req/min
- **Query params:** `period` — `week | month | all`, default `week`

**Success — 200 OK:**
```json
{
  "period": "week",
  "user": {
    "roadmap_progress_percent": 28.5,
    "xp_earned": 220,
    "tasks_done": 11,
    "avg_daily_learning_hours": 1.4
  },
  "peer_averages": {
    "roadmap_progress_percent": 19.2,
    "xp_earned": 175,
    "tasks_done": 8,
    "avg_daily_learning_hours": 1.1
  },
  "xp_vs_peer_avg_percent": 25.7,
  "tasks_vs_peer_avg_percent": 37.5,
  "peers_learning_same_skill": 3,
  "peer_leaderboard": [
    { "rank": 1, "user_id": 1,  "display_name": "Rahim Uddin", "is_me": true,  "total_xp": 1270 },
    { "rank": 2, "user_id": 7,  "display_name": "Nadia Islam",  "is_me": false, "total_xp": 980  }
  ],
  "roadmap_progress_vs_peers": [
    { "user_id": 1, "display_name": "Rahim Uddin", "is_me": true,  "progress_percent": 28.5 },
    { "user_id": 7, "display_name": "Nadia Islam",  "is_me": false, "progress_percent": 21.0 }
  ]
}
```

---

## Module 25: AI Hub (Stub)

---

### **POST** `/ai-hub/prompt`
Accepts a prompt, logs it, and returns a stub response.

- **Auth:** Required
- **Rate limit:** 10 req/min

**Request Body:**
```json
{ "prompt_text": "string, required, max 2000 chars" }
```

**Success — 200 OK:**
```json
{
  "message": "AI Hub coming soon.",
  "prompt_logged": true
}
```

---

## Middleware & Architecture Notes

---

### Recommended Middleware Stack

```
Request
  │
  ├─ 1. CORS — allow configured origins, credentials: true
  ├─ 2. Helmet — security headers (CSP, HSTS, X-Frame-Options)
  ├─ 3. Rate Limiter — per-route limits (Redis-backed sliding window)
  ├─ 4. Request Logger — structured JSON (request ID, method, path, latency)
  ├─ 5. Body Parser — JSON, max 2MB
  ├─ 6. JWT Authenticator — verifies Bearer token, attaches user to req
  ├─ 7. Resource Ownership Guard — verifies user owns the requested resource
  ├─ 8. Input Validator — schema validation (Zod / Joi / class-validator)
  │
  Controller / Handler
  │
  ├─ 9. Response Formatter — wraps all responses in consistent shape
  └─ 10. Global Error Handler — maps errors to standard error format
```

---

### Gemini API Integration Pattern (Async Job Queue)

```
POST /roadmaps/generate
  │
  ├─ 1. Validate user inputs
  ├─ 2. Create a job row in generation_jobs table: { status: "queued", user_id, inputs_json }
  ├─ 3. Return 202 with job_id immediately
  │
Background Worker (BullMQ / AWS SQS consumer)
  │
  ├─ 4. Pick up job, update status → "processing"
  ├─ 5. Build Gemini prompt from inputs_json
  ├─ 6. Call Gemini API (gemini-1.5-pro or flash)
  ├─ 7. On success:
  │     ├─ Store raw_response + parsed JSON in roadmaps table
  │     ├─ Update job status → "complete"
  │     └─ Emit WebSocket event OR set push notification for user
  └─ 8. On failure:
        ├─ Retry up to 3 times with exponential backoff
        └─ Update job status → "failed" with error_message

GET /roadmaps/generate/status/:job_id → polls job table
GET /roadmaps/generate/result/:job_id → reads from roadmaps table
```

---

### Real-Time Features: WebSocket + Polling Strategy

| Feature | Recommended Approach | Notes |
|---------|---------------------|-------|
| Roadmap generation status | **Polling** (`/roadmaps/generate/status/:job_id`) | Simple; 2s interval; stop on complete/failed |
| Flashcard generation status | **Polling** (`/flashcards/generate/status/:job_id`) | Same pattern |
| Notifications | **WebSocket** (Socket.io room per user) | Push on: peer request, message, achievement, rank update |
| Peer group chat | **WebSocket** (Socket.io room per group) | Real-time message delivery; REST for history |
| Study timer (header) | **Client-side** with DB sync on pause/stop | No WS needed; `last_timer_state` persisted in `user_study_timer` |
| Leaderboard updates | **Polling** (60s interval) | Snapshots are nightly; real-time unnecessary |

**WebSocket Rooms:**
```
user:{user_id}         → personal notifications
group:{group_id}       → peer group chat
```

**Socket Events (Server → Client):**
```json
{ "event": "notification",       "data": { "type": "peer_request", "...": "..." } }
{ "event": "new_message",        "data": { "thread_id": 9, "message": { "...": "..." } } }
{ "event": "generation_complete","data": { "job_id": "gen_abc123", "roadmap_id": 1 } }
{ "event": "achievement_unlocked","data": { "achievement": { "name": "7-Day Streak", "...": "..." } } }
{ "event": "peer_streak_broken", "data": { "peer_user_id": 7, "display_name": "Nadia Islam" } }
```

---

> **Security reminders:**
> - Never return `password_hash`, `token_hash`, or OTP codes in any response.
> - All OTP and password-reset endpoints return `200` regardless of whether the email exists.
> - Resource ownership is checked before every read/write on user-scoped data.
> - Admin-scoped endpoints (not listed here) require `role: admin` middleware guard.
> - JWT access tokens expire in 15 minutes; refresh tokens in 7 days (rotated on use).
