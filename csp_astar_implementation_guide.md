# AI Task Planner: CSP & A* Implementation Guide

This document explains how the **Constraint Satisfaction Problem (CSP)** and **A* (A-Star) Search** algorithms are implemented and integrated into the SkillOS backend to generate optimized daily schedules.

---

## 1. The Big Picture: How They Work Together

The scheduling engine uses a hybrid approach:
- **CSP (The Enforcer):** Defines the "Hard Rules." It acts as a strict filter that throws away any schedule arrangement that is physically impossible or violates hard dependencies.
- **A* Search (The Optimizer):** Defines the "Soft Rules" (preferences). It explores all the valid arrangements (as approved by the CSP) and scores them to find the absolute mathematically "best" schedule based on priorities and deadlines.

---

## 2. CSP Implementation (Constraint Satisfaction)

**Location:** `com.skillos.planner.csp.ConstraintChecker`

The CSP evaluates a proposed task assignment and returns a boolean result (Valid/Invalid). 

### How it's implemented:
It checks a series of hard constraints every time the scheduler attempts to place a task into a time slot.

1. **Time Bounds Constraint:** 
   Ensures `taskEnd <= slotEnd`. A task cannot bleed outside of the user's defined free time windows.
2. **Overlap Constraint:** 
   Ensures the proposed `taskStart` happens on or after the `effectiveCurrentTime` (the end time of the previously scheduled task). Tasks cannot happen simultaneously.
3. **Dependency Constraint:** 
   Checked via `isDependencySatisfied()`. If Task B requires Task A to be done first, Task B cannot be scheduled unless Task A is either already marked as "completed" in the database OR Task A is already placed earlier in the current schedule simulation.
4. **Availability Constraint:**
   The `SchedulingService` (orchestrator) pre-processes `UserRoutine` records. It subtracts any "fixed events" (isAvailable = false) from the available windows, ensuring the CSP only ever receives genuinely free `TimeSlot`s to work with.

---

## 3. A* Search Implementation (Optimization)

**Location:** 
- Core Algorithm: `com.skillos.planner.astar.AStarScheduler`
- Heuristic: `com.skillos.planner.astar.ScheduleHeuristic`
- Search Node: `com.skillos.planner.model.ScheduleState`

The A* algorithm uses a `PriorityQueue` to explore different permutations of task orderings, always expanding the most promising path first based on the equation: `f(n) = g(n) + h(n)`

### The State (`ScheduleState`)
Each node in the search tree represents a "partial schedule". It tracks:
- `scheduledTasks`: The list of tasks already placed in this simulation.
- `remainingTasks`: Tasks waiting to be scheduled.
- `effectiveCurrentTime`: Where the timeline currently stands.

### The Cost Function: `g(n)`
Calculated in `AStarScheduler.calculateTransitionCost()`. It assigns penalty points (lower is better).
- **Missed Deadline (+100 penalty):** If placing the task at this specific time causes it to finish after its deadline (e.g., 11:59 PM today).
- **Priority Inversion (+10 penalty):** If we choose to schedule a "Low" priority task while a "High" or "Critical" priority task is still waiting in the `remainingTasks` list.
- **Time Gaps (+1 penalty per 15 min):** Penalizes schedules that leave weird gaps of unused time between tasks.

### The Heuristic Function: `h(n)`
Implemented in `ScheduleHeuristic.estimate()`. For A* to guarantee finding the optimal schedule, `h(n)` must be "admissible" (it must never overestimate the remaining cost).
- **How it works:** It looks at the `remainingTasks` and the total remaining minutes in the day's `TimeSlot`s. If the total time required for tasks with deadlines exceeds the remaining physical time available, it adds a +100 penalty for each task that is mathematically guaranteed to miss its deadline.

### The Search Loop (`AStarScheduler.search`)
1. Starts with an empty `ScheduleState` in the Priority Queue.
2. Pops the state with the lowest `f(n)` score.
3. If the state is a "Goal" (all tasks placed, or no time slots left), it returns this as the optimal schedule!
4. Otherwise, it **Expands** the state: It tries taking every single remaining eligible task and placing it in the next available slot.
5. It passes each new arrangement to the **CSP** (`ConstraintChecker`).
6. If the CSP approves it, it calculates the new `g(n)` and `h(n)` scores, creates a new `ScheduleState`, and pushes it back into the Priority Queue.

---

## 4. The Orchestrator

**Location:** `com.skillos.planner.SchedulingService`

Neither the CSP nor the A* algorithm talk to the database directly. They operate entirely in memory using plain Java objects. 

The `SchedulingService` acts as the orchestrator:
1. It queries the DB for today's `UserRoutine`s to build the `TimeSlot`s.
2. It queries the DB for pending `PlannerTask`s.
3. It hands them to the `AStarScheduler`.
4. It takes the resulting optimal `ScheduleCandidate`, loops through it, and saves standard `DailySchedule` and `ScheduleEntry` records back into the database.
