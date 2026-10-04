# SkillOS Frontend Design & Architecture Specification

## 1. Design Aesthetics & Visual Identity
The SkillOS frontend will be designed to feel **premium, dynamic, and state-of-the-art**. It should not feel like a standard CRUD app; it should feel like an intelligent "operating system" for the user's life.

- **Theme & Colors:** Deep Dark Mode by default (sleek off-blacks like `#0f172a`), accented with vibrant, glowing gradients (e.g., neon purples, electric blues, and emerald greens) to highlight active tasks and AI actions.
- **Typography:** Modern, clean, and highly legible. Primary font: **Inter** or **Outfit**. Large, confident headings with subdued, readable body text.
- **Style Technique:** **Glassmorphism**. Panels and cards will have semi-transparent backgrounds with subtle background blurs (`backdrop-filter: blur`) and delicate 1px borders to create depth.
- **Animations:** Micro-interactions on every clickable element. Hover states will slightly elevate elements, and transitions (like the AI generating a schedule) will have shimmering skeleton loaders to build anticipation.

## 2. Core Pages & User Flow

### A. Authentication & Landing
- **Visuals:** A clean, centered login panel against a deep, subtly animated gradient background. 
- **Data Collected:** Email, Password, or "Sign in with Google" OAuth.
- **Flow:** If it's a new user, they are immediately routed to the Onboarding flow.

### B. Intelligent Onboarding (One-Time)
- **Visuals:** A beautiful, step-by-step wizard.
- **Data Collected (Crucial):**
  - **Timezone:** Automatically captured from the browser using `Intl.DateTimeFormat().resolvedOptions().timeZone` (Sent silently to prevent the Google Calendar bug).
  - **Profession/Goal:** "What are you focusing on?" (e.g., Student, Developer).
  - **Daily Routine:** A visual time-selector where the user paints their "Focus Blocks" (e.g., 8 PM - 11 PM) for each day of the week.

### C. The Main Dashboard (The Heart of SkillOS)
The dashboard is split into two primary panes to maximize productivity without feeling cluttered:

**Left Pane: The Backlog & Controls**
- **Pending Tasks List:** A sleek list of tasks waiting to be scheduled. Includes custom tasks and Roadmap milestones.
- **"Add Task" Input:** A quick-add text bar to drop in new tasks with estimated time and priority.
- **The "Generate Schedule" Button:** The most prominent button on the screen. It should have a glowing or shimmering effect. Clicking it triggers the AI A* Planner.

**Right Pane: The Dynamic Timeline (Today's Schedule)**
- **Visuals:** A vertical, chronologically ordered timeline for the current day.
- **Data Displayed:** 
  - **Google Calendar Events:** Displayed with a distinct color (e.g., Google Blue) and a calendar icon. Marked as locked/fixed.
  - **AI Scheduled Tasks:** Displayed with priority-based colors.
  - **Current Time Indicator:** A horizontal glowing line moving down the timeline as the day progresses.
- **Interactions:** Hovering over an AI task reveals "Complete", "Skip", or "Reschedule" actions.

### D. Settings & Integrations
- **Visuals:** A clean modal or dedicated page.
- **Data Managed:** 
  - Connect/Disconnect Google Calendar (Triggers the OAuth redirect we just built).
  - Adjust default Routine Time Slots.
  - Update Profile Info (Avatar, Timezone override).

## 3. Technology Stack
- **Framework:** React + Vite (Fast, lightweight).
- **Styling:** Vanilla CSS modules with CSS variables for design tokens (Colors, Spacing, Shadows). **No Tailwind** (to maintain absolute control over the premium aesthetic).
- **Icons:** Phosphor Icons or Lucide React (Clean, modern stroke icons).
- **Routing:** React Router DOM (v6).
- **API Communication:** `fetch` or `axios` with a centralized interceptor to automatically attach the JWT token to every request.

## 4. Primary API Integration Points
The frontend will heavily interact with the endpoints we've already built:
1. `POST /api/v1/auth/login` (Receive JWT Token).
2. `PUT /api/v1/users/me` (Send captured Timezone and Profile data).
3. `POST /api/v1/routines` (Save the user's free-time focus blocks).
4. `GET /api/v1/integrations/google/auth-url` (Fetch the Google OAuth URL for the Connect button).
5. `GET /api/v1/planner/dashboard` (Fetch the timeline data to render the right pane).
6. `POST /api/v1/planner/schedule/generate` (Trigger the A* AI to schedule tasks).
