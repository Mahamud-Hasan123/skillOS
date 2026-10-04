-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jun 15, 2026 at 07:13 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `skillos_v1`
--

-- --------------------------------------------------------

--
-- Table structure for table `achievement_definitions`
--

CREATE TABLE `achievement_definitions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(120) NOT NULL,
  `description` text NOT NULL COMMENT 'What the user needs to do',
  `icon_key` varchar(120) DEFAULT NULL,
  `xp_reward` int(11) NOT NULL,
  `achievement_points` int(11) NOT NULL,
  `condition_type` varchar(60) NOT NULL COMMENT 'e.g. streak_days, tasks_done, level_reached',
  `condition_value` int(10) UNSIGNED NOT NULL COMMENT 'Threshold for the condition',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `achievement_definitions`
--

INSERT INTO `achievement_definitions` (`id`, `name`, `description`, `icon_key`, `xp_reward`, `achievement_points`, `condition_type`, `condition_value`, `created_at`, `updated_at`) VALUES
(1, 'First Steps', 'Complete your first daily task.', 'footsteps', 50, 10, 'tasks_done', 1, '2026-06-12 11:49:13', '2026-06-12 11:49:13'),
(2, 'Steady Learner', 'Maintain a 3-day streak.', 'flame', 100, 20, 'streak_days', 3, '2026-06-12 11:49:13', '2026-06-12 11:49:13'),
(3, 'Unstoppable', 'Maintain a 7-day streak.', 'flame-bold', 250, 50, 'streak_days', 7, '2026-06-12 11:49:13', '2026-06-12 11:49:13'),
(4, 'Task Master', 'Complete 50 total tasks.', 'check-circle', 300, 50, 'tasks_done', 50, '2026-06-12 11:49:13', '2026-06-12 11:49:13'),
(5, 'Knowledge Seeker', 'Review 100 flashcards.', 'cards', 200, 40, 'flashcards_reviewed', 100, '2026-06-12 11:49:13', '2026-06-12 11:49:13'),
(6, 'Project Pioneer', 'Complete your first project.', 'rocket', 500, 100, 'projects_done', 1, '2026-06-12 11:49:13', '2026-06-12 11:49:13'),
(7, 'Traveller', 'Completed Day 1 of an active roadmap', '🗺️', 200, 100, 'first_roadmap_day', 1, '2026-06-14 23:20:09', '2026-06-14 23:20:09');

-- --------------------------------------------------------

--
-- Table structure for table `ai_hub_interactions`
--

CREATE TABLE `ai_hub_interactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `conversation_id` char(36) DEFAULT NULL COMMENT 'Groups messages into a conversation session',
  `prompt_text` text NOT NULL,
  `response_text` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ai_hub_logs`
--

CREATE TABLE `ai_hub_logs` (
  `id` bigint(20) NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `prompt_text` varchar(2000) NOT NULL,
  `response_text` varchar(5000) DEFAULT NULL,
  `user_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'NULL for system-initiated actions',
  `action` varchar(120) NOT NULL COMMENT 'e.g. user.login, roadmap.create',
  `entity_type` varchar(60) DEFAULT NULL,
  `entity_id` bigint(20) UNSIGNED DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `blacklisted_websites`
--

CREATE TABLE `blacklisted_websites` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `domain` varchar(255) NOT NULL COMMENT 'e.g. malicious-site.com',
  `reason` varchar(255) DEFAULT NULL COMMENT 'Why this domain is blacklisted',
  `added_by` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'Admin user who added this entry',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `blacklisted_websites`
--

INSERT INTO `blacklisted_websites` (`id`, `domain`, `reason`, `added_by`, `created_at`, `updated_at`) VALUES
(1, 'bad-site.com', 'Spam content', 2, '2026-06-13 03:10:46', '2026-06-13 03:10:46'),
(3, 'twitch.com', 'Streaming platform', 2, '2026-06-13 03:24:50', '2026-06-13 03:24:50');

-- --------------------------------------------------------

--
-- Table structure for table `custom_tasks`
--

CREATE TABLE `custom_tasks` (
  `id` bigint(20) NOT NULL,
  `completed_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `scheduled_date` date NOT NULL,
  `status` enum('pending','completed') NOT NULL DEFAULT 'pending',
  `title` text NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `xp_reward` int(11) NOT NULL,
  `user_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `custom_tasks`
--

INSERT INTO `custom_tasks` (`id`, `completed_at`, `created_at`, `scheduled_date`, `status`, `title`, `updated_at`, `xp_reward`, `user_id`) VALUES
(1, '2026-06-15 10:09:07.000000', '2026-06-15 10:06:36.000000', '2026-06-15', 'completed', 'Attend Project Show', '2026-06-15 10:09:07.000000', 15, 3),
(2, NULL, '2026-06-15 11:04:46.000000', '2026-06-15', 'pending', 'trd', '2026-06-15 11:04:46.000000', 15, 3);

-- --------------------------------------------------------

--
-- Table structure for table `daily_tasks`
--

CREATE TABLE `daily_tasks` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `roadmap_id` bigint(20) UNSIGNED NOT NULL,
  `task_id` bigint(20) UNSIGNED NOT NULL,
  `scheduled_date` date NOT NULL,
  `status` varchar(255) DEFAULT NULL,
  `user_answer` text DEFAULT NULL COMMENT 'Answer submitted by user',
  `answer_correct` tinyint(1) DEFAULT NULL COMMENT 'NULL = not yet answered',
  `time_spent_seconds` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `last_timer_state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '{"status":"paused","elapsed":300,"last_started":"2025-01-01T10:00:00Z"}' CHECK (json_valid(`last_timer_state`)),
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `day_number` int(11) DEFAULT NULL,
  `estimated_time_minutes` int(11) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `xp_reward` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `daily_tasks`
--

INSERT INTO `daily_tasks` (`id`, `user_id`, `roadmap_id`, `task_id`, `scheduled_date`, `status`, `user_answer`, `answer_correct`, `time_spent_seconds`, `last_timer_state`, `completed_at`, `created_at`, `updated_at`, `day_number`, `estimated_time_minutes`, `title`, `xp_reward`) VALUES
(1, 2, 2, 3, '2026-06-15', 'pending', NULL, NULL, 0, NULL, NULL, '2026-06-16 01:48:45', '2026-06-15 01:51:27', NULL, NULL, 'Introduction to Data Engineering & Python Basics', NULL),
(2, 4, 8, 244, '2026-06-15', 'pending', NULL, NULL, 0, NULL, NULL, '2026-06-15 01:48:45', '2026-06-15 01:48:45', NULL, NULL, 'Introduction to DevOps // Learn about the definition, history, and core principles of DevOps (CALMS)', NULL),
(3, 8, 12, 424, '2026-06-14', 'pending', NULL, NULL, 0, NULL, NULL, '2026-06-15 01:48:45', '2026-06-15 01:53:47', NULL, NULL, 'Introduction to Cyber Security // Understand what Cyber Security is, its importance, and the core concepts like the CIA Triad.', NULL),
(4, 3, 13, 454, '2026-06-15', 'pending', NULL, NULL, 0, NULL, NULL, '2026-06-15 01:48:45', '2026-06-15 01:48:45', NULL, NULL, 'Introduction to DevOps // Understand the core principles, culture, and benefits of DevOps. Explore the \'infinity loop\' phases (Plan, Code, Build, Test, Release, Deploy, Operate, Monitor).', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `direct_messages`
--

CREATE TABLE `direct_messages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `sender_id` bigint(20) UNSIGNED NOT NULL,
  `receiver_id` bigint(20) UNSIGNED NOT NULL,
  `body` text NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `direct_messages`
--

INSERT INTO `direct_messages` (`id`, `sender_id`, `receiver_id`, `body`, `is_read`, `created_at`, `updated_at`) VALUES
(1, 8, 6, 'hey', 1, '2026-06-14 17:53:35', '2026-06-14 17:53:37'),
(2, 6, 8, 'hey there', 1, '2026-06-14 17:53:40', '2026-06-14 18:57:32'),
(3, 6, 8, 'how is it going', 1, '2026-06-14 17:53:46', '2026-06-14 18:57:32'),
(4, 8, 6, 'good good', 0, '2026-06-14 17:53:54', '2026-06-14 17:53:54'),
(5, 6, 8, 'bfighfalsdkjhg', 1, '2026-06-14 17:54:03', '2026-06-14 18:57:32'),
(6, 8, 6, 'fewytry', 0, '2026-06-14 17:54:07', '2026-06-14 17:54:07'),
(7, 4, 8, 'hey', 1, '2026-06-14 18:14:01', '2026-06-14 18:14:07'),
(8, 4, 7, 'hey', 0, '2026-06-14 20:45:11', '2026-06-14 20:45:11'),
(9, 3, 8, 'hey there', 1, '2026-06-15 01:40:11', '2026-06-15 01:40:16'),
(10, 8, 3, 'hello', 1, '2026-06-15 01:40:21', '2026-06-15 02:00:47'),
(11, 3, 8, 'bro you missed a task, i see.', 1, '2026-06-15 02:01:02', '2026-06-15 04:22:41'),
(12, 3, 8, 'hey there', 1, '2026-06-15 04:22:32', '2026-06-15 04:22:41');

-- --------------------------------------------------------

--
-- Table structure for table `flashcards`
--

CREATE TABLE `flashcards` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `roadmap_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'Auto-mapped when generated from notes',
  `skill_name` varchar(255) DEFAULT NULL,
  `question` text NOT NULL,
  `answer` text NOT NULL,
  `difficulty` enum('easy','medium','hard','forgot') DEFAULT NULL COMMENT 'NULL until first review',
  `mastery` int(11) NOT NULL,
  `source` enum('auto_generated','manual') NOT NULL DEFAULT 'manual',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `flashcards`
--

INSERT INTO `flashcards` (`id`, `user_id`, `roadmap_id`, `skill_name`, `question`, `answer`, `difficulty`, `mastery`, `source`, `created_at`, `updated_at`) VALUES
(2, 2, NULL, 'Python Programming', 'What keyword is used to define a function in Python?', 'def...', 'easy', 0, 'manual', '2026-06-05 10:13:26', '2026-06-05 10:13:26'),
(3, 4, NULL, NULL, 'Why can\'t I generate flashcards from the provided notes?', 'The notes content \'whatevere\' is too short and lacks any meaningful information or concepts to create relevant questions and answers for flashcards. Please provide more detailed and substantive study material.', 'medium', 25, 'auto_generated', '2026-06-13 09:35:08', '2026-06-13 12:06:08'),
(4, 4, NULL, NULL, 'How do you print in Python?', 'You write `print()`.', 'easy', 45, 'auto_generated', '2026-06-13 09:38:35', '2026-06-15 00:09:24'),
(5, 4, NULL, 'DE', 'What is full Form of DE', 'Data Engineering', 'hard', 45, 'manual', '2026-06-13 09:42:51', '2026-06-13 12:06:04'),
(7, 8, NULL, NULL, 'What is a common English greeting used to acknowledge someone and ask about their well-being?', 'Hello, How are you.', NULL, 0, 'auto_generated', '2026-06-14 17:06:33', '2026-06-14 17:06:33'),
(8, 4, NULL, NULL, 'What is \'def\' used for in Python?', 'To define functions.', NULL, 0, 'auto_generated', '2026-06-14 21:29:21', '2026-06-14 21:29:21');

-- --------------------------------------------------------

--
-- Table structure for table `flashcard_batches`
--

CREATE TABLE `flashcard_batches` (
  `id` bigint(20) NOT NULL,
  `card_count` int(11) NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `source_note_id` bigint(20) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `user_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `flashcard_batches`
--

INSERT INTO `flashcard_batches` (`id`, `card_count`, `created_at`, `source_note_id`, `updated_at`, `user_id`) VALUES
(1, 1, '2026-06-13 15:35:08.000000', NULL, '2026-06-13 15:35:08.000000', 4),
(2, 1, '2026-06-13 15:38:35.000000', NULL, '2026-06-13 15:38:35.000000', 4),
(3, 1, '2026-06-14 23:06:33.000000', NULL, '2026-06-14 23:06:33.000000', 8),
(4, 1, '2026-06-15 03:29:21.000000', NULL, '2026-06-15 03:29:21.000000', 4);

-- --------------------------------------------------------

--
-- Table structure for table `flashcard_reviews`
--

CREATE TABLE `flashcard_reviews` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `flashcard_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `difficulty_set` enum('easy','medium','hard','forgot') NOT NULL,
  `mastery_after` int(11) NOT NULL,
  `reviewed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `flashcard_reviews`
--

INSERT INTO `flashcard_reviews` (`id`, `flashcard_id`, `user_id`, `difficulty_set`, `mastery_after`, `reviewed_at`, `created_at`, `updated_at`) VALUES
(1, 4, 4, 'easy', 20, '2026-06-13 09:43:02', '2026-06-13 09:43:02', '2026-06-13 09:43:02'),
(2, 3, 4, 'hard', 5, '2026-06-13 09:43:05', '2026-06-13 09:43:05', '2026-06-13 09:43:05'),
(3, 5, 4, 'easy', 20, '2026-06-13 09:43:08', '2026-06-13 09:43:08', '2026-06-13 09:43:08'),
(4, 3, 4, 'medium', 15, '2026-06-13 10:23:20', '2026-06-13 10:23:20', '2026-06-13 10:23:20'),
(5, 4, 4, 'hard', 25, '2026-06-13 10:23:21', '2026-06-13 10:23:21', '2026-06-13 10:23:21'),
(6, 5, 4, 'easy', 40, '2026-06-13 10:23:23', '2026-06-13 10:23:23', '2026-06-13 10:23:23'),
(7, 5, 4, 'hard', 45, '2026-06-13 12:06:04', '2026-06-13 12:06:04', '2026-06-13 12:06:04'),
(8, 3, 4, 'medium', 25, '2026-06-13 12:06:08', '2026-06-13 12:06:08', '2026-06-13 12:06:08'),
(9, 4, 4, 'easy', 45, '2026-06-13 12:06:09', '2026-06-13 12:06:09', '2026-06-13 12:06:09');

-- --------------------------------------------------------

--
-- Table structure for table `gantt_entries`
--

CREATE TABLE `gantt_entries` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `project_id` bigint(20) UNSIGNED NOT NULL,
  `feature_name` varchar(255) NOT NULL,
  `order_index` int(11) NOT NULL,
  `start_day` int(11) NOT NULL,
  `duration_days` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `gantt_entries`
--

INSERT INTO `gantt_entries` (`id`, `project_id`, `feature_name`, `order_index`, `start_day`, `duration_days`, `created_at`, `updated_at`) VALUES
(1, 2, 'Project Setup & Core Structure', 0, 0, 2, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(2, 2, 'Dashboard Layout & Navigation', 2, 2, 3, '2026-06-12 11:09:08', '2026-06-12 11:39:20'),
(3, 2, 'Data Visualization Integration', 1, 2, 4, '2026-06-12 11:09:08', '2026-06-12 11:39:20'),
(4, 2, 'Data Tables & Forms', 3, 9, 3, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(5, 2, 'State Management & Refinement', 4, 12, 2, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(6, 4, 'Backend Infrastructure', 0, 0, 2, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(7, 4, 'University Data Service', 1, 1, 3, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(8, 4, 'University Search API', 2, 3, 3, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(9, 4, 'University Comparison API', 3, 6, 3, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(10, 4, 'Frontend UI Development', 4, 8, 6, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(11, 4, 'Deployment & Testing', 5, 14, 1, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(12, 5, 'Project Setup & Core Infrastructure', 0, 0, 1, '2026-06-14 18:05:40', '2026-06-14 18:05:40'),
(13, 5, 'User Authentication & Authorization', 1, 0, 2, '2026-06-14 18:05:40', '2026-06-14 18:05:40'),
(14, 5, 'User Profile Management', 2, 1, 1, '2026-06-14 18:05:40', '2026-06-14 18:05:40'),
(15, 5, 'Instructor Course Management', 3, 2, 2, '2026-06-14 18:05:40', '2026-06-14 18:05:40'),
(16, 5, 'Instructor Content Management', 4, 3, 2, '2026-06-14 18:05:40', '2026-06-14 18:05:40'),
(17, 5, 'Student Course Discovery & Enrollment', 5, 4, 2, '2026-06-14 18:05:40', '2026-06-14 18:05:40'),
(18, 5, 'Student Learning Progression', 6, 5, 1, '2026-06-14 18:05:40', '2026-06-14 18:05:40'),
(19, 5, 'Basic UI & Navigation', 7, 0, 7, '2026-06-14 18:05:40', '2026-06-14 18:05:40'),
(20, 5, 'Testing & Deployment Prep', 8, 6, 1, '2026-06-14 18:05:40', '2026-06-14 18:05:40'),
(21, 6, 'API & Database Setup', 0, 0, 1, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(22, 6, 'Task Management (CRUD)', 1, 1, 2, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(23, 6, 'Task Status & Filtering', 2, 3, 1, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(24, 6, 'Time Tracking', 3, 4, 2, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(25, 6, 'API Testing & Documentation', 4, 6, 1, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(26, 8, 'Project Setup & DB Integration', 0, 0, 1, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(27, 8, 'Task Model & Repository', 1, 1, 1, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(28, 8, 'Task Service Layer', 2, 2, 1, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(29, 8, 'REST API Endpoints', 3, 3, 2, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(30, 8, 'Error Handling & Validation', 4, 5, 1, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(31, 8, 'Testing & Refinement', 5, 6, 1, '2026-06-15 03:07:31', '2026-06-15 03:07:31');

-- --------------------------------------------------------

--
-- Table structure for table `generation_jobs`
--

CREATE TABLE `generation_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `job_id` varchar(36) NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `job_type` enum('roadmap_generation','flashcard_generation','project_generation') NOT NULL,
  `status` enum('queued','processing','complete','failed') NOT NULL DEFAULT 'queued',
  `progress_percent` int(11) NOT NULL,
  `inputs_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'User inputs that were sent to AI' CHECK (json_valid(`inputs_json`)),
  `result_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'FK to roadmaps.id or flashcards batch — polymorphic',
  `error_message` text DEFAULT NULL COMMENT 'Error details if status = failed',
  `retry_count` int(11) NOT NULL,
  `max_retries` int(11) NOT NULL,
  `started_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `generation_jobs`
--

INSERT INTO `generation_jobs` (`id`, `job_id`, `user_id`, `job_type`, `status`, `progress_percent`, `inputs_json`, `result_id`, `error_message`, `retry_count`, `max_retries`, `started_at`, `completed_at`, `created_at`, `updated_at`) VALUES
(4, 'gen_91669a5b87344faea7be6786f94df2ab', 2, 'roadmap_generation', 'queued', 0, '{\"skillGoal\":\"Python Programming\",\"dailyTimeMinutes\":60,\"durationMonths\":1,\"goalPurpose\":\"education\",\"experienceDescription\":null,\"level\":\"beginner\",\"focusAreas\":[\"Data Structures\",\"Loops\"]}', NULL, NULL, 0, 3, NULL, NULL, '2026-06-05 02:58:09', '2026-06-05 02:58:09'),
(5, 'gen_af3101e4451543d29afbe3789b6aa0ec', 2, 'roadmap_generation', 'complete', 100, '{\"skillGoal\":\"Python Programming\",\"dailyTimeMinutes\":60,\"durationMonths\":1,\"goalPurpose\":\"education\",\"experienceDescription\":null,\"level\":\"beginner\",\"focusAreas\":[\"Data Structures\",\"Loops\"]}', 1, NULL, 0, 3, NULL, '2026-06-05 03:04:20', '2026-06-05 03:04:20', '2026-06-05 03:04:20'),
(6, 'gen_23bde367a26e4584a9af188d17c04fe1', 2, 'roadmap_generation', 'failed', 0, '{\"skillGoal\":\"Python Programming\",\"dailyTimeMinutes\":60,\"durationMonths\":1,\"goalPurpose\":\"education\",\"experienceDescription\":null,\"level\":\"beginner\",\"focusAreas\":[\"Data Structures\",\"Loops\"]}', NULL, 'Failed to parse JSON from Gemini API', 0, 3, NULL, '2026-06-10 07:11:45', '2026-06-10 07:11:44', '2026-06-10 07:11:45'),
(7, 'gen_011124582f4842148e3cf33bd8d1e47e', 2, 'roadmap_generation', 'complete', 100, '{\"skillGoal\":\"Data Engineering\",\"dailyTimeMinutes\":60,\"durationMonths\":1,\"goalPurpose\":\"education\",\"experienceDescription\":null,\"level\":\"beginner\",\"focusAreas\":[\"Data Structures\",\"Loops\"]}', 2, NULL, 0, 3, NULL, '2026-06-10 07:22:08', '2026-06-10 07:21:37', '2026-06-10 07:22:08'),
(8, 'gen_b222e84c81694def9f6325aeb85b580a', 2, 'project_generation', 'failed', 0, '{\"name\":\"Build a React Dashboard\", \"skill_name\":\"React\"}', NULL, 'Failed to parse JSON from Gemini API', 0, 3, '2026-06-12 11:00:22', '2026-06-12 11:00:25', '2026-06-12 11:00:22', '2026-06-12 11:00:25'),
(9, 'gen_0b2df3d29dae4516abfd1c0832d1ac0d', 2, 'project_generation', 'complete', 100, '{\"name\":\"Build a React Dashboard\", \"skill_name\":\"React\"}', 2, NULL, 0, 3, '2026-06-12 11:08:52', '2026-06-12 11:09:08', '2026-06-12 11:08:52', '2026-06-12 11:09:08'),
(10, 'gen_8568e25ffe9a49b6a38ede91ae24d154', 4, 'roadmap_generation', 'queued', 0, '{\"skillGoal\":\"Data Science\",\"dailyTimeMinutes\":120,\"durationMonths\":3,\"goalPurpose\":\"job\",\"experienceDescription\":\"I know basics of python, nothing much other than that\",\"level\":\"beginner\",\"focusAreas\":null}', NULL, NULL, 0, 3, NULL, NULL, '2026-06-13 05:42:58', '2026-06-13 05:42:58'),
(11, 'gen_adaa3adda618462082794fa5ac6524cb', 4, 'roadmap_generation', 'failed', 0, '{\"skillGoal\":\"Data Science\",\"dailyTimeMinutes\":60,\"durationMonths\":1,\"goalPurpose\":\"job\",\"experienceDescription\":\"I know basic of python, nothing else much\",\"level\":\"beginner\",\"focusAreas\":null}', NULL, 'Failed to parse JSON from Gemini API', 0, 3, NULL, '2026-06-13 07:11:27', '2026-06-13 07:11:25', '2026-06-13 07:11:27'),
(12, 'gen_841a27ccd38e4726b4a6ed0bf196f477', 4, 'roadmap_generation', 'complete', 100, '{\"skillGoal\":\"Data Science\",\"dailyTimeMinutes\":60,\"durationMonths\":1,\"goalPurpose\":\"job\",\"experienceDescription\":\"I know basic of python, nothing else much\",\"level\":\"beginner\",\"focusAreas\":null}', 3, NULL, 0, 3, NULL, '2026-06-13 07:16:14', '2026-06-13 07:15:41', '2026-06-13 07:16:14'),
(13, 'gen_98cce9cfd6e1440886b159eb3d37f1fd', 4, 'roadmap_generation', 'complete', 100, '{\"skillGoal\":\"DevOps\",\"dailyTimeMinutes\":60,\"durationMonths\":1,\"goalPurpose\":\"job\",\"experienceDescription\":null,\"level\":\"beginner\",\"focusAreas\":null}', 4, NULL, 0, 3, NULL, '2026-06-13 07:21:07', '2026-06-13 07:20:46', '2026-06-13 07:21:07'),
(14, 'gen_7210649ec1cc43b69db00b786f7ab5c7', 4, 'flashcard_generation', 'complete', 100, '{\"skill_name\":\"null\"}', 1, NULL, 0, 3, NULL, '2026-06-13 09:35:08', '2026-06-13 09:35:05', '2026-06-13 09:35:08'),
(15, 'gen_abfe9f57cb0346a89e39ab9583800518', 4, 'flashcard_generation', 'failed', 0, '{\"skill_name\":\"null\"}', NULL, 'No unused notes found for flashcard generation', 0, 3, NULL, '2026-06-13 09:35:28', '2026-06-13 09:35:28', '2026-06-13 09:35:28'),
(16, 'gen_527a17e1745048c3acefc74ed237208e', 4, 'flashcard_generation', 'complete', 100, '{\"skill_name\":\"null\"}', 2, NULL, 0, 3, NULL, '2026-06-13 09:38:35', '2026-06-13 09:38:32', '2026-06-13 09:38:35'),
(17, 'gen_fb99783ce5d647a083c6b465476d12ce', 4, 'project_generation', 'failed', 0, '{\"name\":\"NextCamppus\", \"skill_name\":\"Java Spring Boot\"}', NULL, 'Failed to parse JSON from Gemini API', 0, 3, '2026-06-13 10:12:26', '2026-06-13 10:12:29', '2026-06-13 10:12:26', '2026-06-13 10:12:29'),
(18, 'gen_7f6dbe9d3269447c9bc57855cbf19a9b', 4, 'project_generation', 'complete', 100, '{\"name\":\"NextCamppus\", \"skill_name\":\"Java Spring Boot\"}', 4, NULL, 0, 3, '2026-06-13 10:12:50', '2026-06-13 10:13:15', '2026-06-13 10:12:50', '2026-06-13 10:13:15'),
(19, 'gen_64c71d86f1fb448c80a028b2e04cc899', 4, 'roadmap_generation', 'complete', 100, '{\"skillGoal\":\"Web Developing\",\"dailyTimeMinutes\":60,\"durationMonths\":3,\"goalPurpose\":\"job\",\"experienceDescription\":\"none\",\"level\":\"beginner\",\"focusAreas\":null}', 5, NULL, 0, 3, NULL, '2026-06-13 10:24:10', '2026-06-13 10:22:10', '2026-06-13 10:24:10'),
(20, 'gen_30487ae722334cc8985bcae13d01d121', 4, 'roadmap_generation', 'failed', 0, '{\"skillGoal\":\"Devops\",\"dailyTimeMinutes\":60,\"durationMonths\":3,\"goalPurpose\":\"job\",\"experienceDescription\":null,\"level\":\"beginner\",\"focusAreas\":null}', NULL, 'Failed to parse JSON from Gemini API', 0, 3, NULL, '2026-06-13 12:01:10', '2026-06-13 12:00:48', '2026-06-13 12:01:10'),
(21, 'gen_c3705121d9c64e6a8f552bb72eff78c6', 3, 'roadmap_generation', 'complete', 100, '{\"skillGoal\":\"DevOps\",\"dailyTimeMinutes\":120,\"durationMonths\":1,\"goalPurpose\":\"job\",\"experienceDescription\":null,\"level\":\"beginner\",\"focusAreas\":null}', 6, NULL, 0, 3, NULL, '2026-06-14 13:17:17', '2026-06-14 13:16:58', '2026-06-14 13:17:17'),
(22, 'gen_52cc45fa6aa2477786c0a095f4f9e02f', 3, 'roadmap_generation', 'failed', 0, '{\"skillGoal\":\"Web developer\",\"dailyTimeMinutes\":60,\"durationMonths\":1,\"goalPurpose\":\"job\",\"experienceDescription\":\"I know bit of html that is all\",\"level\":\"intermediate\",\"focusAreas\":null}', NULL, 'Failed to parse JSON from Gemini API', 0, 3, NULL, '2026-06-14 13:19:23', '2026-06-14 13:19:03', '2026-06-14 13:19:23'),
(23, 'gen_7ce07df37069476f9bb3003c5c251af6', 4, 'roadmap_generation', 'failed', 0, '{\"skillGoal\":\"DevOps\",\"dailyTimeMinutes\":60,\"durationMonths\":1,\"goalPurpose\":\"job\",\"experienceDescription\":null,\"level\":\"beginner\",\"focusAreas\":null}', NULL, 'Failed to parse JSON from Gemini API', 0, 3, NULL, '2026-06-14 13:36:54', '2026-06-14 13:36:51', '2026-06-14 13:36:54'),
(24, 'gen_9356cee112f84db483f67eddf37fc813', 4, 'roadmap_generation', 'complete', 100, '{\"skillGoal\":\"Data Science\",\"dailyTimeMinutes\":60,\"durationMonths\":1,\"goalPurpose\":\"job\",\"experienceDescription\":null,\"level\":\"beginner\",\"focusAreas\":null}', 7, NULL, 0, 3, NULL, '2026-06-14 14:14:55', '2026-06-14 14:14:31', '2026-06-14 14:14:55'),
(25, 'gen_66fbb0498b8a4541b5376edd0303a838', 4, 'roadmap_generation', 'complete', 100, '{\"skillGoal\":\"DevOps\",\"dailyTimeMinutes\":60,\"durationMonths\":1,\"goalPurpose\":\"job\",\"experienceDescription\":null,\"level\":\"beginner\",\"focusAreas\":null}', 8, NULL, 0, 3, NULL, '2026-06-14 14:18:00', '2026-06-14 14:17:40', '2026-06-14 14:18:00'),
(26, 'gen_6ae6370490434d55ab63772cca66db0c', 4, 'roadmap_generation', 'complete', 100, '{\"skillGoal\":\"Python\",\"dailyTimeMinutes\":60,\"durationMonths\":1,\"goalPurpose\":\"job\",\"experienceDescription\":null,\"level\":\"beginner\",\"focusAreas\":null}', 9, NULL, 0, 3, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:14', '2026-06-14 14:22:32'),
(27, 'gen_f88a7f2fafc64abbbbb1e3982c25dd9f', 4, 'roadmap_generation', 'complete', 100, '{\"skillGoal\":\"Data Science\",\"dailyTimeMinutes\":120,\"durationMonths\":3,\"goalPurpose\":\"other\",\"experienceDescription\":null,\"level\":\"intermediate\",\"focusAreas\":null}', 10, NULL, 0, 3, NULL, '2026-06-14 14:39:55', '2026-06-14 14:39:04', '2026-06-14 14:39:55'),
(28, 'gen_1601961f162a44a3984af18a6c558601', 4, 'roadmap_generation', 'complete', 100, '{\"skillGoal\":\"Web Developer\",\"dailyTimeMinutes\":60,\"durationMonths\":1,\"goalPurpose\":\"job\",\"experienceDescription\":null,\"level\":\"beginner\",\"focusAreas\":null}', 11, NULL, 0, 3, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:18', '2026-06-14 14:59:37'),
(29, 'gen_99338c173ae746c4b60d7d02ab540335', 8, 'flashcard_generation', 'complete', 100, '{\"skill_name\":\"null\"}', 3, NULL, 0, 3, NULL, '2026-06-14 17:06:33', '2026-06-14 17:06:28', '2026-06-14 17:06:33'),
(30, 'gen_5b4a832fac3d47a38cc07be42ec7bd8d', 8, 'project_generation', 'complete', 100, '{\"name\":\"Next Campus\", \"skill_name\":\"Java \"}', 5, NULL, 0, 3, '2026-06-14 18:05:21', '2026-06-14 18:05:40', '2026-06-14 18:05:21', '2026-06-14 18:05:40'),
(31, 'gen_ec633e2665fa46cfa7069fbaca9c4c70', 4, 'project_generation', 'complete', 100, '{\"name\":\"To Do app\", \"skill_name\":\"Backend Engineering\"}', 6, NULL, 0, 3, '2026-06-14 18:27:01', '2026-06-14 18:27:22', '2026-06-14 18:27:01', '2026-06-14 18:27:22'),
(32, 'gen_3bee7cad72c74e3d99f11de050c3c677', 8, 'roadmap_generation', 'complete', 100, '{\"skillGoal\":\"Cyber Security\",\"dailyTimeMinutes\":120,\"durationMonths\":1,\"goalPurpose\":\"job\",\"experienceDescription\":null,\"level\":\"beginner\",\"focusAreas\":null}', 12, NULL, 0, 3, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:34', '2026-06-14 21:09:54'),
(33, 'gen_4ca9fbe61a1948bd9d61bcbec73be057', 4, 'flashcard_generation', 'complete', 100, '{\"skill_name\":\"null\"}', 4, NULL, 0, 3, NULL, '2026-06-14 21:29:21', '2026-06-14 21:29:18', '2026-06-14 21:29:21'),
(34, 'gen_55ddea3957b34f24b5cc44dc3337e9b5', 3, 'roadmap_generation', 'complete', 100, '{\"skillGoal\":\"Devops\",\"dailyTimeMinutes\":60,\"durationMonths\":1,\"goalPurpose\":\"education\",\"experienceDescription\":null,\"level\":\"beginner\",\"focusAreas\":null}', 13, NULL, 0, 3, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:08', '2026-06-15 00:39:28'),
(35, 'gen_b3c69da6356e4daca6ee34876630e33e', 3, 'project_generation', 'failed', 0, '{\"name\":\"NextCampus4D\", \"skill_name\":\"Java Spring Boot\"}', NULL, 'Failed to parse JSON from Gemini API', 0, 3, '2026-06-15 03:01:34', '2026-06-15 03:01:36', '2026-06-15 03:01:34', '2026-06-15 03:01:36'),
(36, 'gen_0b3edf5f6e994310a348969c8c394336', 3, 'project_generation', 'complete', 100, '{\"name\":\"To Do app\", \"skill_name\":\"Java Spring Boot\"}', 8, NULL, 0, 3, '2026-06-15 03:07:11', '2026-06-15 03:07:31', '2026-06-15 03:07:11', '2026-06-15 03:07:31');

-- --------------------------------------------------------

--
-- Table structure for table `global_rankings`
--

CREATE TABLE `global_rankings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `opted_in` tinyint(1) NOT NULL DEFAULT 1 COMMENT '0 = user excluded from public leaderboard',
  `total_xp` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `current_streak` int(11) NOT NULL,
  `total_hours_studied` decimal(10,2) NOT NULL DEFAULT 0.00,
  `milestones_reached` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `lifetime_achievement_points` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `ranking_score` decimal(18,4) NOT NULL DEFAULT 0.0000 COMMENT 'Weighted formula: xp*0.40 + streak*50*0.15 + hours*100*0.15 + milestones*200*0.15 + achievement_pts*0.15',
  `global_rank` int(10) UNSIGNED DEFAULT NULL,
  `percentile` decimal(5,2) DEFAULT NULL COMMENT 'e.g. 95.00 = top 5%',
  `xp_to_next_rank` int(10) UNSIGNED DEFAULT NULL,
  `snapshot_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `global_rankings`
--

INSERT INTO `global_rankings` (`id`, `user_id`, `opted_in`, `total_xp`, `current_streak`, `total_hours_studied`, `milestones_reached`, `lifetime_achievement_points`, `ranking_score`, `global_rank`, `percentile`, `xp_to_next_rank`, `snapshot_at`, `created_at`, `updated_at`) VALUES
(2, 4, 1, 330, 1, 3.60, 2, 5100, 1018.4792, 1, 87.50, 0, '2026-06-15 01:54:48', '2026-06-13 11:27:53', '2026-06-15 01:54:48'),
(3, 2, 1, 8, 0, 0.03, 0, 0, 3.7167, 4, 50.00, 342, '2026-06-15 01:54:48', '2026-06-13 11:27:53', '2026-06-15 01:54:48'),
(4, 1, 1, 0, 0, 0.00, 0, 0, 0.0000, 5, 37.50, 10, '2026-06-15 01:54:48', '2026-06-13 11:27:53', '2026-06-15 01:54:48'),
(5, 3, 1, 210, 1, 0.25, 1, 100, 140.2875, 3, 62.50, 179, '2026-06-15 01:54:48', '2026-06-13 11:27:53', '2026-06-15 01:54:48'),
(6, 8, 1, 450, 0, 0.02, 1, 10, 211.7250, 2, 75.00, 2017, '2026-06-15 01:54:48', '2026-06-14 19:00:56', '2026-06-15 01:54:48'),
(7, 5, 1, 0, 0, 0.00, 0, 0, 0.0000, 6, 25.00, 0, '2026-06-15 01:54:48', '2026-06-14 19:00:56', '2026-06-15 01:54:48'),
(8, 6, 1, 0, 0, 0.00, 0, 0, 0.0000, 7, 12.50, 0, '2026-06-15 01:54:48', '2026-06-14 19:00:56', '2026-06-15 01:54:48'),
(9, 7, 1, 0, 0, 0.00, 0, 0, 0.0000, 8, 0.00, 0, '2026-06-15 01:54:48', '2026-06-14 19:00:56', '2026-06-15 01:54:48');

-- --------------------------------------------------------

--
-- Table structure for table `kanban_boards`
--

CREATE TABLE `kanban_boards` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `project_id` bigint(20) UNSIGNED DEFAULT NULL,
  `roadmap_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `kanban_boards`
--

INSERT INTO `kanban_boards` (`id`, `user_id`, `project_id`, `roadmap_id`, `created_at`, `updated_at`) VALUES
(1, 2, 2, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(2, 4, 4, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(3, 8, 5, NULL, '2026-06-14 18:05:40', '2026-06-14 18:05:40'),
(4, 4, 6, NULL, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(5, 3, 8, NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:31');

-- --------------------------------------------------------

--
-- Table structure for table `kanban_cards`
--

CREATE TABLE `kanban_cards` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `column_id` bigint(20) UNSIGNED NOT NULL,
  `task_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'Links to roadmap_tasks if applicable',
  `project_task_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'Links to project_tasks if applicable',
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `order_index` int(11) NOT NULL,
  `is_done` tinyint(1) NOT NULL DEFAULT 0,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `kanban_cards`
--

INSERT INTO `kanban_cards` (`id`, `column_id`, `task_id`, `project_task_id`, `title`, `description`, `due_date`, `order_index`, `is_done`, `deleted_at`, `created_at`, `updated_at`) VALUES
(1, 4, NULL, 1, 'Initialize React Project', 'Create a new React project using Vite or Create React App.', NULL, 0, 1, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(2, 1, NULL, 2, 'Configure TailwindCSS', 'Install and configure TailwindCSS within the React project for utility-first styling.', NULL, 0, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(3, 1, NULL, 3, 'Establish Folder Structure', 'Set up a logical folder structure for components, pages, utils, and assets.', NULL, 1, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(4, 1, NULL, 4, 'Install React Router DOM', 'Install and set up React Router DOM for client-side routing.', NULL, 2, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(5, 1, NULL, 5, 'Create Sidebar Component', 'Design and implement a responsive navigation sidebar using TailwindCSS.', NULL, 3, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(6, 1, NULL, 6, 'Create Header Component', 'Develop a header component with user profile, notifications, and dashboard title.', NULL, 4, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(7, 1, NULL, 7, 'Implement Main Layout', 'Combine sidebar and header into the main dashboard layout, ensuring responsiveness.', NULL, 5, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(8, 1, NULL, 8, 'Define Dashboard Routes', 'Configure routes for key dashboard sections like Home, Charts, and Tables.', NULL, 6, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(9, 1, NULL, 9, 'Add Active Link Styling', 'Implement styling to indicate the currently active navigation link in the sidebar.', NULL, 7, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(10, 1, NULL, 10, 'Install Recharts Library', 'Add Recharts to the project dependencies for data visualization.', NULL, 8, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(11, 1, NULL, 11, 'Create Line Chart Component', 'Build a reusable component for displaying line charts using Recharts and dummy data.', NULL, 9, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(12, 1, NULL, 12, 'Create Bar Chart Component', 'Build a reusable component for displaying bar charts using Recharts and dummy data.', NULL, 10, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(13, 1, NULL, 13, 'Create Pie Chart Component', 'Build a reusable component for displaying pie charts using Recharts and dummy data.', NULL, 11, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(14, 1, NULL, 14, 'Integrate Charts into Dashboard Page', 'Display various charts on a dedicated \'Charts\' page within the dashboard.', NULL, 12, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(15, 1, NULL, 15, 'Add Chart Interactivity', 'Implement tooltips, legends, and basic responsiveness for Recharts components.', NULL, 13, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(16, 1, NULL, 16, 'Create Reusable Data Table Component', 'Develop a generic table component capable of displaying data arrays with customizable columns.', NULL, 14, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(17, 1, NULL, 17, 'Populate Table with Dummy Data', 'Integrate the data table component on a \'Users\' or \'Products\' page using mock data.', NULL, 15, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(18, 1, NULL, 18, 'Implement Basic Pagination', 'Add simple pagination functionality to the data table component.', NULL, 16, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(19, 1, NULL, 19, 'Create User Form Component', 'Build a form component for adding new users or editing existing user details.', NULL, 17, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(20, 1, NULL, 20, 'Implement Form Validation', 'Add basic client-side validation to the user form fields.', NULL, 18, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(21, 1, NULL, 21, 'Connect Form to Data State', 'Enable form submission to add new items or update existing items in the application\'s dummy data state.', NULL, 19, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(22, 1, NULL, 22, 'Implement React Context API', 'Set up a global state management solution using React\'s Context API for shared data.', NULL, 20, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(23, 1, NULL, 23, 'Refactor Dashboard Settings to Context', 'Move global settings, like sidebar state, to the shared Context API.', NULL, 21, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(24, 1, NULL, 24, 'Integrate Data Loading with Context', 'Refactor chart and table data fetching/management to utilize the global context.', NULL, 22, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(25, 1, NULL, 25, 'Final Styling Pass', 'Review and refine all components for consistent styling and adherence to TailwindCSS best practices.', NULL, 23, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(26, 1, NULL, 26, 'Optimize Component Rendering', 'Apply `React.memo` or `useCallback`/`useMemo` where appropriate to optimize performance.', NULL, 24, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(27, 1, NULL, 27, 'Write Project README', 'Document the project setup, scripts, and key features in a comprehensive README.md file.', NULL, 25, 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(28, 8, NULL, 28, 'Initialize Spring Boot Project', 'Set up a new Spring Boot project with necessary dependencies (Web, Data JPA, H2/PostgreSQL driver).', NULL, 0, 1, NULL, '2026-06-13 10:13:15', '2026-06-14 18:15:34'),
(29, 5, NULL, 29, 'Configure Database', 'Configure application.properties for H2 (development) or PostgreSQL (production) database connection and JPA settings.', NULL, 0, 0, NULL, '2026-06-13 10:13:15', '2026-06-14 17:57:59'),
(30, 7, NULL, 30, 'Implement Global Exception Handling', 'Set up centralized exception handling using @ControllerAdvice for consistent API error responses.', NULL, 0, 0, NULL, '2026-06-13 10:13:15', '2026-06-14 18:10:43'),
(31, 5, NULL, 31, 'Define University Entity', 'Create the University JPA entity with relevant fields (e.g., name, location, type, ranking, fees, description).', NULL, 1, 0, NULL, '2026-06-13 10:13:15', '2026-06-14 18:10:41'),
(32, 5, NULL, 32, 'Create University Repository', 'Implement JpaRepository for basic data access operations on University entities.', NULL, 2, 0, NULL, '2026-06-13 10:13:15', '2026-06-14 18:10:41'),
(33, 5, NULL, 33, 'Develop University Service Layer', 'Create a service class to encapsulate business logic for fetching and managing universities.', NULL, 3, 0, NULL, '2026-06-13 10:13:15', '2026-06-14 18:10:41'),
(34, 5, NULL, 34, 'Populate Dummy University Data', 'Write a data initialization script or use a CSV import to pre-populate the database with at least 15-20 dummy university entries.', NULL, 4, 0, NULL, '2026-06-13 10:13:15', '2026-06-14 18:10:41'),
(35, 5, NULL, 35, 'Design Search Endpoint', 'Create a REST Controller endpoint (e.g., GET /api/universities/search) to handle search queries.', NULL, 5, 0, NULL, '2026-06-13 10:13:15', '2026-06-14 18:10:41'),
(36, 5, NULL, 36, 'Implement Search Logic with Criteria', 'Develop service layer logic to filter universities based on various criteria like name, location, type, or minimum ranking.', NULL, 6, 0, NULL, '2026-06-13 10:13:15', '2026-06-14 18:10:41'),
(37, 5, NULL, 37, 'Add Pagination to Search Results', 'Integrate Spring Data JPA\'s Pageable interface for paginated and sortable search results.', NULL, 7, 0, NULL, '2026-06-13 10:13:15', '2026-06-14 18:10:41'),
(38, 5, NULL, 38, 'Create University Details Endpoint', 'Develop a REST Controller endpoint (e.g., GET /api/universities/{id}) to retrieve a single university\'s comprehensive details.', NULL, 8, 0, NULL, '2026-06-13 10:13:15', '2026-06-14 18:10:41'),
(39, 5, NULL, 39, 'Design Comparison Endpoint', 'Create a REST Controller endpoint (e.g., GET /api/universities/compare?ids=1,2,3) to accept multiple university IDs for comparison.', NULL, 9, 0, NULL, '2026-06-13 10:13:15', '2026-06-14 18:10:41'),
(40, 5, NULL, 40, 'Implement Comparison Logic', 'Retrieve detailed information for all provided university IDs and structure a response showing commonalities and key differences.', NULL, 10, 0, NULL, '2026-06-13 10:13:15', '2026-06-14 18:10:41'),
(41, 5, NULL, 41, 'Set Up Basic Frontend Structure', 'Create basic HTML templates (e.g., using Thymeleaf or a simple client-side JS/HTML setup) and initial CSS for the web application.', NULL, 11, 0, NULL, '2026-06-13 10:13:15', '2026-06-14 18:10:41'),
(42, 5, NULL, 42, 'Develop University Search Page', 'Create a UI page with a search input, filters, and a dynamic display area for search results. Integrate with the University Search API.', NULL, 12, 0, NULL, '2026-06-13 10:13:15', '2026-06-14 18:10:41'),
(43, 5, NULL, 43, 'Implement University Details Page', 'Design a dedicated page to show comprehensive information for a selected university. Integrate with the University Details API.', NULL, 13, 0, NULL, '2026-06-13 10:13:15', '2026-06-14 18:10:41'),
(44, 5, NULL, 44, 'Create University Comparison Interface', 'Develop a UI where users can select multiple universities (e.g., from search results) and view a side-by-side comparison. Integrate with the Comparison API.', NULL, 14, 0, NULL, '2026-06-13 10:13:15', '2026-06-14 18:10:41'),
(45, 5, NULL, 45, 'Add Basic Navigation and Styling', 'Implement essential navigation elements (e.g., home, search) and apply basic CSS for a presentable and user-friendly interface.', NULL, 15, 0, NULL, '2026-06-13 10:13:15', '2026-06-14 18:10:41'),
(46, 5, NULL, 46, 'Perform API Integration Testing', 'Manually test all backend API endpoints using tools like Postman to ensure correct functionality and error handling.', NULL, 16, 0, NULL, '2026-06-13 10:13:15', '2026-06-14 18:10:41'),
(47, 5, NULL, 47, 'Conduct UI Acceptance Testing', 'Thoroughly test the entire user flow from search to details to comparison, ensuring a smooth and intuitive user experience.', NULL, 17, 0, NULL, '2026-06-13 10:13:15', '2026-06-14 18:10:41'),
(48, 5, NULL, 48, 'Prepare Deployment Artifact', 'Generate the executable JAR file for the Spring Boot application, ready for deployment.', NULL, 18, 0, NULL, '2026-06-13 10:13:15', '2026-06-14 18:10:41'),
(49, 5, NULL, 49, 'Write Project README', 'Create a comprehensive README.md file covering project setup instructions, API endpoints, and usage guide.', NULL, 19, 0, NULL, '2026-06-13 10:13:15', '2026-06-14 18:10:41'),
(50, 12, NULL, 50, 'Initialize Spring Boot Project', 'Create a new Spring Boot project with necessary dependencies (Web, Data JPA, H2/PostgreSQL).', NULL, 26, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(51, 12, NULL, 51, 'Configure Database', 'Set up H2 in-memory database for development and basic PostgreSQL configuration for potential deployment.', NULL, 24, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(52, 12, NULL, 52, 'Establish Base Folder Structure', 'Organize packages for controllers, services, repositories, and entities.', NULL, 27, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(53, 12, NULL, 53, 'Design User Entity and Repository', 'Create User entity (id, username, password_hash, role) and corresponding JPA repository.', NULL, 23, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(54, 12, NULL, 54, 'Implement User Registration Endpoint', 'Develop REST API endpoint for new user registration with password hashing.', NULL, 25, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(55, 12, NULL, 55, 'Implement User Login Endpoint (JWT/Session)', 'Create API for user login, generating and returning an authentication token (e.g., JWT).', NULL, 22, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(56, 12, NULL, 56, 'Configure Spring Security', 'Set up Spring Security for authentication and authorization, defining roles (STUDENT, INSTRUCTOR).', NULL, 21, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(57, 12, NULL, 57, 'Create User Profile Service and Controller', 'Develop service and controller to allow users to view and update their own basic profile information (e.g., name, email).', NULL, 20, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(58, 12, NULL, 58, 'Implement Profile UI Component', 'Create a basic frontend component for viewing and editing the user\'s profile.', NULL, 19, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(59, 12, NULL, 59, 'Design Course Entity and Repository', 'Define Course entity (id, title, description, instructor_id) and JPA repository.', NULL, 18, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(60, 12, NULL, 60, 'Implement Course CRUD APIs', 'Develop REST endpoints for instructors to create, retrieve, update, and delete courses.', NULL, 17, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(61, 12, NULL, 61, 'Build Instructor Course Dashboard UI', 'Create a basic UI for instructors to list their courses and access CRUD operations.', NULL, 16, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(62, 12, NULL, 62, 'Design Content Block Entity', 'Create ContentBlock entity (id, course_id, title, type, content_url/text, order).', NULL, 15, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(63, 12, NULL, 63, 'Implement Content Block CRUD APIs', 'Develop APIs for instructors to add, retrieve, update, and delete content blocks within a course.', NULL, 14, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(64, 12, NULL, 64, 'Create Content Editor UI', 'Build UI for instructors to add different types of content (e.g., text, links) to specific course modules.', NULL, 13, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(65, 12, NULL, 65, 'Implement API to List All Courses', 'Develop a public API endpoint for students to browse all available courses.', NULL, 12, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(66, 12, NULL, 66, 'Design StudentCourse Enrollment Entity', 'Create entity to track student enrollments (student_id, course_id, enrollment_date).', NULL, 11, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(67, 12, NULL, 67, 'Implement Course Enrollment/Unenrollment APIs', 'Develop APIs for students to enroll in and unenroll from courses.', NULL, 10, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(68, 12, NULL, 68, 'Develop Student Course Browser UI', 'Create a UI for students to view available courses and initiate enrollment.', NULL, 9, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(69, 12, NULL, 69, 'Implement API to View Enrolled Course Content', 'Develop an API that retrieves all content blocks for a specific course a student is enrolled in.', NULL, 7, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(70, 12, NULL, 70, 'Implement Content Completion Tracking', 'Create a mechanism and API to mark specific content blocks as \'completed\' by a student.', NULL, 8, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(71, 12, NULL, 71, 'Build Student Course View UI', 'Develop UI to display course content sequentially and allow students to mark progress.', NULL, 6, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(72, 12, NULL, 72, 'Design Core Application Layout', 'Create a consistent header, footer, and main content area for the application.', NULL, 5, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(73, 12, NULL, 73, 'Implement Role-Based Navigation', 'Set up dynamic navigation menus that adapt based on the logged-in user\'s role (student/instructor).', NULL, 4, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(74, 12, NULL, 74, 'Create Landing Page/Dashboard', 'Develop a simple landing page or user dashboard displaying relevant information post-login.', NULL, 3, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(75, 12, NULL, 75, 'Write Basic Unit Tests', 'Implement essential unit tests for core services and repositories (e.g., User, Course).', NULL, 2, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(76, 12, NULL, 76, 'Perform API Integration Tests', 'Conduct integration tests for critical API flows like user registration, course creation, and enrollment.', NULL, 1, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(77, 12, NULL, 77, 'Prepare Project README and Setup Instructions', 'Document how to set up, build, and run the \'Next Campus\' application.', NULL, 0, 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(78, 16, NULL, 78, 'Choose Backend Framework & Initialize Project', 'Select a backend framework (e.g., FastAPI, Flask, Express.js) and set up the project boilerplate.', NULL, 3, 1, NULL, '2026-06-14 18:27:22', '2026-06-14 19:21:32'),
(79, 16, NULL, 79, 'Database Setup & ORM Integration', 'Configure a relational database (e.g., PostgreSQL, SQLite) and integrate an ORM/ODM (e.g., SQLAlchemy, Prisma).', NULL, 2, 1, NULL, '2026-06-14 18:27:22', '2026-06-14 19:21:32'),
(80, 16, NULL, 80, 'Define Task & TimeEntry Models', 'Create database schemas for \'Task\' (title, description, status) and \'TimeEntry\' (task_id, start_time, end_time).', NULL, 1, 1, NULL, '2026-06-14 18:27:22', '2026-06-14 19:21:32'),
(81, 16, NULL, 81, 'Implement Create Task Endpoint (POST /tasks)', 'Develop an API endpoint to create new to-do items with a title and description.', NULL, 0, 1, NULL, '2026-06-14 18:27:22', '2026-06-14 19:21:32'),
(82, 13, NULL, 82, 'Implement Get All Tasks Endpoint (GET /tasks)', 'Develop an API endpoint to retrieve a list of all existing tasks.', NULL, 0, 0, NULL, '2026-06-14 18:27:22', '2026-06-14 19:21:29'),
(83, 13, NULL, 83, 'Implement Get Single Task Endpoint (GET /tasks/{id})', 'Develop an API endpoint to retrieve details of a specific task by its ID.', NULL, 1, 0, NULL, '2026-06-14 18:27:22', '2026-06-14 19:21:29'),
(84, 13, NULL, 84, 'Implement Update Task Endpoint (PUT/PATCH /tasks/{id})', 'Develop an API endpoint to modify existing task details (title, description) by its ID.', NULL, 2, 0, NULL, '2026-06-14 18:27:22', '2026-06-14 19:21:29'),
(85, 13, NULL, 85, 'Implement Delete Task Endpoint (DELETE /tasks/{id})', 'Develop an API endpoint to remove a task from the database by its ID.', NULL, 3, 0, NULL, '2026-06-14 18:27:22', '2026-06-14 19:21:29'),
(86, 13, NULL, 86, 'Add Task Status Field', 'Modify the Task model to include a \'status\' field (e.g., \'pending\', \'completed\') and apply database migrations.', NULL, 4, 0, NULL, '2026-06-14 18:27:22', '2026-06-14 19:21:29'),
(87, 13, NULL, 87, 'Implement Update Task Status Endpoint (PATCH /tasks/{id}/status)', 'Develop an API endpoint to easily change a task\'s status.', NULL, 5, 0, NULL, '2026-06-14 18:27:22', '2026-06-14 19:21:29'),
(88, 13, NULL, 88, 'Implement Filter Tasks by Status (GET /tasks?status=...)', 'Enhance the Get All Tasks endpoint to allow filtering tasks based on their status.', NULL, 6, 0, NULL, '2026-06-14 18:27:22', '2026-06-14 19:21:29'),
(89, 13, NULL, 89, 'Implement Start Timer Endpoint (POST /tasks/{id}/start_timer)', 'Develop an API endpoint to record the start time of a work session for a specific task.', NULL, 7, 0, NULL, '2026-06-14 18:27:22', '2026-06-14 19:21:29'),
(90, 13, NULL, 90, 'Implement Stop Timer Endpoint (POST /tasks/{id}/stop_timer)', 'Develop an API endpoint to record the end time, calculate duration, and save the TimeEntry for a work session.', NULL, 8, 0, NULL, '2026-06-14 18:27:22', '2026-06-14 19:21:29'),
(91, 13, NULL, 91, 'Calculate & Retrieve Total Time Spent (GET /tasks/{id}/total_time_spent)', 'Implement logic to sum up all time entries for a given task and expose it via an API endpoint.', NULL, 9, 0, NULL, '2026-06-14 18:27:22', '2026-06-14 19:21:29'),
(92, 13, NULL, 92, 'Write Unit/Integration Tests for Core Endpoints', 'Develop unit and basic integration tests for Task CRUD and status update endpoints to ensure API reliability.', NULL, 10, 0, NULL, '2026-06-14 18:27:22', '2026-06-14 19:21:29'),
(93, 13, NULL, 93, 'Write Integration Tests for Time Tracking Logic', 'Develop integration tests for the start/stop timer and total time calculation workflows.', NULL, 11, 0, NULL, '2026-06-14 18:27:22', '2026-06-14 19:21:29'),
(94, 13, NULL, 94, 'Generate API Documentation (OpenAPI/Swagger)', 'Use tools like OpenAPI/Swagger to generate interactive API documentation for all developed endpoints.', NULL, 12, 0, NULL, '2026-06-14 18:27:22', '2026-06-14 19:21:29'),
(95, 20, NULL, 95, 'Initialize Spring Boot Project', 'Create a new Spring Boot project using Spring Initializr with dependencies: Spring Web, Spring Data JPA, H2 Database.', NULL, 2, 1, NULL, '2026-06-15 03:07:31', '2026-06-15 05:06:41'),
(96, 20, NULL, 96, 'Configure H2 Database', 'Set up H2 in-memory database configuration in application.properties for development.', NULL, 1, 1, NULL, '2026-06-15 03:07:31', '2026-06-15 05:06:41'),
(97, 20, NULL, 97, 'Create Task Entity', 'Define the `Task` JPA entity with fields: id (Long), description (String), completed (boolean, default false), creationDate (LocalDateTime).', NULL, 0, 1, NULL, '2026-06-15 03:07:31', '2026-06-15 05:06:41'),
(98, 17, NULL, 98, 'Create Task Repository', 'Develop `TaskRepository` interface extending `JpaRepository` for basic CRUD operations on `Task` entities.', NULL, 0, 0, NULL, '2026-06-15 03:07:31', '2026-06-15 05:06:37'),
(99, 17, NULL, 99, 'Define TaskService Interface', 'Create `TaskService` interface with method signatures for adding, retrieving, updating completion status, and deleting tasks.', NULL, 1, 0, NULL, '2026-06-15 03:07:31', '2026-06-15 05:06:37'),
(100, 17, NULL, 100, 'Implement TaskServiceImpl', 'Implement `TaskService` methods (`addTask`, `getAllTasks`, `getTaskById`, `markTaskCompleted`, `deleteTask`) using `TaskRepository`.', NULL, 2, 0, NULL, '2026-06-15 03:07:31', '2026-06-15 05:06:37'),
(101, 17, NULL, 101, 'Create TaskController', 'Develop the `TaskController` class annotated with `@RestController` and `@RequestMapping(\"/api/tasks\")`.', NULL, 3, 0, NULL, '2026-06-15 03:07:31', '2026-06-15 05:06:37'),
(102, 17, NULL, 102, 'Implement POST /api/tasks (Add Task)', 'Create an endpoint to add a new task, expecting a Task DTO and returning the created task.', NULL, 4, 0, NULL, '2026-06-15 03:07:31', '2026-06-15 05:06:37'),
(103, 17, NULL, 103, 'Implement GET /api/tasks (Get All Tasks)', 'Create an endpoint to retrieve a list of all tasks from the database.', NULL, 5, 0, NULL, '2026-06-15 03:07:31', '2026-06-15 05:06:37'),
(104, 17, NULL, 104, 'Implement GET /api/tasks/{id} (Get Task by ID)', 'Create an endpoint to retrieve a single task by its unique identifier.', NULL, 6, 0, NULL, '2026-06-15 03:07:31', '2026-06-15 05:06:37'),
(105, 17, NULL, 105, 'Implement PUT /api/tasks/{id}/complete (Mark Task Completed)', 'Create an endpoint to mark a specific task as completed given its ID.', NULL, 7, 0, NULL, '2026-06-15 03:07:31', '2026-06-15 05:06:37'),
(106, 17, NULL, 106, 'Implement DELETE /api/tasks/{id} (Delete Task)', 'Create an endpoint to permanently delete a task by its ID.', NULL, 8, 0, NULL, '2026-06-15 03:07:31', '2026-06-15 05:06:37'),
(107, 17, NULL, 107, 'Implement Custom Exceptions', 'Create custom exception classes like `TaskNotFoundException` for specific error scenarios.', NULL, 9, 0, NULL, '2026-06-15 03:07:31', '2026-06-15 05:06:37'),
(108, 17, NULL, 108, 'Implement Global Exception Handler', 'Set up a `@ControllerAdvice` to handle custom and common Spring exceptions gracefully across all controllers.', NULL, 10, 0, NULL, '2026-06-15 03:07:31', '2026-06-15 05:06:37'),
(109, 17, NULL, 109, 'Add Input Validation to DTOs', 'Apply Spring\'s validation annotations (e.g., `@NotBlank`, `@Size`) to DTOs for incoming request bodies.', NULL, 11, 0, NULL, '2026-06-15 03:07:31', '2026-06-15 05:06:37'),
(110, 17, NULL, 110, 'Write Unit Tests for TaskService', 'Develop unit tests for the business logic in `TaskService` using JUnit 5 and Mockito.', NULL, 12, 0, NULL, '2026-06-15 03:07:31', '2026-06-15 05:06:37'),
(111, 17, NULL, 111, 'Write Integration Tests for TaskController', 'Develop integration tests for `TaskController` endpoints using Spring Boot Test and MockMvc.', NULL, 13, 0, NULL, '2026-06-15 03:07:31', '2026-06-15 05:06:37'),
(112, 17, NULL, 112, 'Perform Code Review and Refactoring', 'Conduct a self-review of the code for adherence to best practices, readability, and minor refactorings.', NULL, 14, 0, NULL, '2026-06-15 03:07:31', '2026-06-15 05:06:37'),
(113, 17, NULL, 113, 'Document API in README.md', 'Create a `README.md` file documenting the API endpoints, how to run the application, and usage examples.', NULL, 15, 0, NULL, '2026-06-15 03:07:31', '2026-06-15 05:06:37');

-- --------------------------------------------------------

--
-- Table structure for table `kanban_columns`
--

CREATE TABLE `kanban_columns` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `board_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(60) NOT NULL,
  `order_index` int(11) NOT NULL,
  `color` varchar(30) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `kanban_columns`
--

INSERT INTO `kanban_columns` (`id`, `board_id`, `title`, `order_index`, `color`, `created_at`, `updated_at`) VALUES
(1, 1, 'To Do', 0, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(2, 1, 'In Progress', 1, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(3, 1, 'Review', 2, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(4, 1, 'Done', 3, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(5, 2, 'To Do', 0, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(6, 2, 'In Progress', 1, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(7, 2, 'Review', 2, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(8, 2, 'Done', 3, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(9, 3, 'To Do', 0, NULL, '2026-06-14 18:05:40', '2026-06-14 18:05:40'),
(10, 3, 'In Progress', 1, NULL, '2026-06-14 18:05:40', '2026-06-14 18:05:40'),
(11, 3, 'Review', 2, NULL, '2026-06-14 18:05:40', '2026-06-14 18:05:40'),
(12, 3, 'Done', 3, NULL, '2026-06-14 18:05:40', '2026-06-14 18:05:40'),
(13, 4, 'To Do', 0, NULL, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(14, 4, 'In Progress', 1, NULL, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(15, 4, 'Review', 2, NULL, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(16, 4, 'Done', 3, NULL, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(17, 5, 'To Do', 0, NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(18, 5, 'In Progress', 1, NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(19, 5, 'Review', 2, NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(20, 5, 'Done', 3, NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:31');

-- --------------------------------------------------------

--
-- Table structure for table `levels`
--

CREATE TABLE `levels` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `level_number` smallint(5) UNSIGNED NOT NULL,
  `xp_required` int(10) UNSIGNED NOT NULL COMMENT 'Total XP needed to reach this level',
  `label` varchar(60) NOT NULL COMMENT 'e.g. "Novice", "Expert"',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `levels`
--

INSERT INTO `levels` (`id`, `level_number`, `xp_required`, `label`, `created_at`, `updated_at`) VALUES
(1, 1, 0, 'Novice', '2026-06-12 11:31:50', '2026-06-12 11:31:50'),
(2, 2, 100, 'Beginner', '2026-06-12 11:31:50', '2026-06-12 11:31:50'),
(3, 3, 300, 'Apprentice', '2026-06-12 11:31:50', '2026-06-12 11:31:50'),
(4, 4, 600, 'Journeyman', '2026-06-12 11:31:50', '2026-06-12 11:31:50'),
(5, 5, 1000, 'Adept', '2026-06-12 11:31:50', '2026-06-12 11:31:50'),
(6, 6, 1500, 'Expert', '2026-06-12 11:31:50', '2026-06-12 11:31:50'),
(7, 7, 2100, 'Master', '2026-06-12 11:31:50', '2026-06-12 11:31:50'),
(8, 8, 2800, 'Grandmaster', '2026-06-12 11:31:50', '2026-06-12 11:31:50'),
(9, 9, 3600, 'Legend', '2026-06-12 11:31:50', '2026-06-12 11:31:50'),
(10, 10, 4500, 'Mythic', '2026-06-12 11:31:50', '2026-06-12 11:31:50');

-- --------------------------------------------------------

--
-- Table structure for table `message_reactions`
--

CREATE TABLE `message_reactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `message_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `reaction_emoji` varchar(10) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notes`
--

CREATE TABLE `notes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `roadmap_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'NULL if created manually without a roadmap',
  `day_number` int(11) DEFAULT NULL,
  `skill_name` varchar(255) DEFAULT NULL COMMENT 'Manually entered skill (if no roadmap linked)',
  `content` text NOT NULL,
  `resource_links` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Array of URLs user wants to store' CHECK (json_valid(`resource_links`)),
  `used_for_flashcard_gen` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 = already sent to AI for flashcard generation',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notes`
--

INSERT INTO `notes` (`id`, `user_id`, `roadmap_id`, `day_number`, `skill_name`, `content`, `resource_links`, `used_for_flashcard_gen`, `created_at`, `updated_at`) VALUES
(1, 2, NULL, 1, 'Python Programming', 'Python uses indentation to define code blocks instead of brackets.', '[\"https://docs.python.org/3/tutorial/\"]', 0, '2026-06-05 10:02:47', '2026-06-05 10:02:47'),
(3, 4, NULL, NULL, '', 'To print in python we write print', NULL, 1, '2026-06-13 09:38:27', '2026-06-13 09:38:35'),
(4, 4, NULL, NULL, '', 'def is for python functions', NULL, 1, '2026-06-13 12:05:27', '2026-06-14 21:29:21'),
(5, 8, NULL, NULL, '', 'Hello , How are you ', NULL, 1, '2026-06-14 17:06:22', '2026-06-14 17:06:33'),
(6, 4, 8, 1, 'Understand fundamental DevOps principles and tools', 'the \"L\" in CALM acronym stands for \"Lean\"', '[\"https://en.wikipedia.org/wiki/DevOps\"]', 0, '2026-06-14 22:54:13', '2026-06-14 22:54:13'),
(8, 4, 9, 2, 'Python', 'There are multiple types of Variables. Such as Integer, float, string etc', NULL, 0, '2026-06-14 23:50:03', '2026-06-14 23:50:03'),
(12, 3, NULL, NULL, '', ';ifjgvojs', '[\"https://en.wikipedia.org/wiki/DevOps\"]', 0, '2026-06-15 00:26:38', '2026-06-15 00:26:38');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `type` varchar(255) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `body` text DEFAULT NULL,
  `reference_type` varchar(60) DEFAULT NULL COMMENT 'e.g. peer_request, achievement',
  `reference_id` bigint(20) UNSIGNED DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `type`, `title`, `body`, `reference_type`, `reference_id`, `is_read`, `created_at`, `updated_at`) VALUES
(1, 4, 'PEER_REQUEST_ACCEPTED', 'Peer Request Accepted', 'Mahmud accepted your peer request!', 'PEER', 3, 1, '2026-06-14 20:42:51', '2026-06-14 20:43:19'),
(2, 7, 'PEER_MESSAGE', 'New message from Sami', 'hey', 'MESSAGE', 8, 1, '2026-06-14 20:45:11', '2026-06-14 20:45:24'),
(3, 4, 'LEVEL_UP', 'Level Up!', 'You are now level 3', 'LEVEL', 3, 1, '2026-06-14 23:22:28', '2026-06-14 23:22:44'),
(4, 4, 'ACHIEVEMENT_UNLOCKED', 'New badge unlocked!', 'Traveller', 'ACHIEVEMENT', 7, 1, '2026-06-14 23:22:28', '2026-06-14 23:22:44'),
(5, 8, 'PEER_ACHIEVEMENT', 'Sami unlocked an achievement!', 'Traveller', 'ACHIEVEMENT', 7, 1, '2026-06-14 23:22:28', '2026-06-15 01:40:41'),
(6, 7, 'PEER_ACHIEVEMENT', 'Sami unlocked an achievement!', 'Traveller', 'ACHIEVEMENT', 7, 0, '2026-06-14 23:22:28', '2026-06-14 23:22:28'),
(7, 3, 'LEVEL_UP', 'Level Up!', 'You are now level 2', 'LEVEL', 2, 1, '2026-06-15 00:42:07', '2026-06-15 00:55:50'),
(8, 3, 'ACHIEVEMENT_UNLOCKED', 'New badge unlocked!', 'Traveller', 'ACHIEVEMENT', 7, 1, '2026-06-15 00:42:07', '2026-06-15 00:55:50'),
(9, 8, 'PEER_REQUEST_RECEIVED', 'New Peer Request', 'Admin wants to be your peer!', 'PEER_REQUEST', 7, 1, '2026-06-15 01:39:17', '2026-06-15 01:40:41'),
(10, 3, 'PEER_REQUEST_ACCEPTED', 'Peer Request Accepted', 'Arif accepted your peer request!', 'PEER', 4, 1, '2026-06-15 01:39:42', '2026-06-15 01:51:58'),
(11, 8, 'PEER_MESSAGE', 'New message from Admin', 'hey there', 'MESSAGE', 9, 1, '2026-06-15 01:40:11', '2026-06-15 01:40:41'),
(12, 3, 'PEER_MESSAGE', 'New message from Arif', 'hello', 'MESSAGE', 10, 1, '2026-06-15 01:40:21', '2026-06-15 01:51:58'),
(13, 8, 'STREAK_BROKEN', 'Streak Alert!', 'Your peer Sami just broke their learning streak! Send them a nudge to get back on track!', 'USER', 4, 1, '2026-06-15 01:51:49', '2026-06-15 02:21:09'),
(14, 7, 'STREAK_BROKEN', 'Streak Alert!', 'Your peer Sami just broke their learning streak! Send them a nudge to get back on track!', 'USER', 4, 0, '2026-06-15 01:51:49', '2026-06-15 01:51:49'),
(15, 8, 'STREAK_BROKEN', 'Streak Alert!', 'Your peer Admin just broke their learning streak! Send them a nudge to get back on track!', 'USER', 3, 1, '2026-06-15 01:51:49', '2026-06-15 02:21:09'),
(16, 8, 'STREAK_BROKEN', 'Streak Alert!', 'Your peer Sami just broke their learning streak! Send them a nudge to get back on track!', 'USER', 4, 1, '2026-06-15 01:54:01', '2026-06-15 02:21:09'),
(17, 7, 'STREAK_BROKEN', 'Streak Alert!', 'Your peer Sami just broke their learning streak! Send them a nudge to get back on track!', 'USER', 4, 0, '2026-06-15 01:54:01', '2026-06-15 01:54:01'),
(18, 8, 'STREAK_BROKEN', 'Streak Alert!', 'Your peer Admin just broke their learning streak! Send them a nudge to get back on track!', 'USER', 3, 1, '2026-06-15 01:54:01', '2026-06-15 02:21:09'),
(19, 6, 'TASK_MISSED', 'Task Missed!', 'Your peer Arif missed 1 daily task(s) yesterday. Check in on them!', 'USER', 8, 0, '2026-06-15 02:00:33', '2026-06-15 02:00:33'),
(20, 4, 'TASK_MISSED', 'Task Missed!', 'Your peer Arif missed 1 daily task(s) yesterday. Check in on them!', 'USER', 8, 0, '2026-06-15 02:00:33', '2026-06-15 02:00:33'),
(21, 3, 'TASK_MISSED', 'Task Missed!', 'Your peer Arif missed 1 daily task(s) yesterday. Check in on them!', 'USER', 8, 1, '2026-06-15 02:00:33', '2026-06-15 02:00:43'),
(22, 8, 'PEER_MESSAGE', 'New message from Admin', 'bro you missed a task, i see.', 'MESSAGE', 11, 1, '2026-06-15 02:01:02', '2026-06-15 02:21:09'),
(23, 8, 'STREAK_BROKEN', 'Streak Alert!', 'Your peer Sami just broke their learning streak! Send them a nudge to get back on track!', 'USER', 4, 1, '2026-06-15 02:01:32', '2026-06-15 02:21:09'),
(24, 7, 'STREAK_BROKEN', 'Streak Alert!', 'Your peer Sami just broke their learning streak! Send them a nudge to get back on track!', 'USER', 4, 0, '2026-06-15 02:01:32', '2026-06-15 02:01:32'),
(25, 8, 'STREAK_BROKEN', 'Streak Alert!', 'Your peer Admin just broke their learning streak! Send them a nudge to get back on track!', 'USER', 3, 1, '2026-06-15 02:01:32', '2026-06-15 02:21:09'),
(26, 8, 'LEVEL_UP', 'Level Up!', 'You are now level 4', 'LEVEL', 4, 1, '2026-06-15 02:18:34', '2026-06-15 02:21:09'),
(27, 8, 'ACHIEVEMENT_UNLOCKED', 'New badge unlocked!', 'Project Pioneer', 'ACHIEVEMENT', 6, 1, '2026-06-15 02:18:34', '2026-06-15 02:21:09'),
(28, 6, 'PEER_ACHIEVEMENT', 'Arif unlocked an achievement!', 'Project Pioneer', 'ACHIEVEMENT', 6, 0, '2026-06-15 02:18:34', '2026-06-15 02:18:34'),
(29, 4, 'PEER_ACHIEVEMENT', 'Arif unlocked an achievement!', 'Project Pioneer', 'ACHIEVEMENT', 6, 0, '2026-06-15 02:18:34', '2026-06-15 02:18:34'),
(30, 3, 'PEER_ACHIEVEMENT', 'Arif unlocked an achievement!', 'Project Pioneer', 'ACHIEVEMENT', 6, 1, '2026-06-15 02:18:34', '2026-06-15 02:21:53'),
(31, 8, 'LEVEL_UP', 'Level Up!', 'You are now level 5', 'LEVEL', 5, 1, '2026-06-15 02:18:34', '2026-06-15 02:21:09'),
(32, 8, 'ACHIEVEMENT_UNLOCKED', 'New badge unlocked!', 'Traveller', 'ACHIEVEMENT', 7, 1, '2026-06-15 02:18:34', '2026-06-15 02:21:09'),
(33, 6, 'PEER_ACHIEVEMENT', 'Arif unlocked an achievement!', 'Traveller', 'ACHIEVEMENT', 7, 0, '2026-06-15 02:18:34', '2026-06-15 02:18:34'),
(34, 4, 'PEER_ACHIEVEMENT', 'Arif unlocked an achievement!', 'Traveller', 'ACHIEVEMENT', 7, 0, '2026-06-15 02:18:34', '2026-06-15 02:18:34'),
(35, 3, 'PEER_ACHIEVEMENT', 'Arif unlocked an achievement!', 'Traveller', 'ACHIEVEMENT', 7, 1, '2026-06-15 02:18:34', '2026-06-15 02:21:53'),
(36, 3, 'ACHIEVEMENT_UNLOCKED', 'New badge unlocked!', 'First Steps', 'ACHIEVEMENT', 1, 1, '2026-06-15 03:07:59', '2026-06-15 03:08:20'),
(37, 8, 'PEER_ACHIEVEMENT', 'Admin unlocked an achievement!', 'First Steps', 'ACHIEVEMENT', 1, 1, '2026-06-15 03:07:59', '2026-06-15 04:22:52'),
(38, 3, 'LEVEL_UP', 'Level Up!', 'You are now level 3', 'LEVEL', 3, 1, '2026-06-15 04:09:07', '2026-06-15 04:40:36'),
(39, 8, 'PEER_MESSAGE', 'New message from Admin', 'hey there', 'MESSAGE', 12, 1, '2026-06-15 04:22:32', '2026-06-15 04:22:52');

-- --------------------------------------------------------

--
-- Table structure for table `onboarding_progress`
--

CREATE TABLE `onboarding_progress` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `current_step` int(11) NOT NULL,
  `is_completed` tinyint(1) NOT NULL DEFAULT 0,
  `goal_skill_tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`goal_skill_tags`)),
  `daily_commitment_min` int(11) DEFAULT NULL,
  `days_available_bitmask` int(11) DEFAULT NULL,
  `peer_opt_in` tinyint(1) DEFAULT NULL,
  `peer_skill_filter` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`peer_skill_filter`)),
  `step4_skipped` tinyint(1) NOT NULL DEFAULT 0,
  `step5_skipped` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `onboarding_progress`
--

INSERT INTO `onboarding_progress` (`id`, `user_id`, `current_step`, `is_completed`, `goal_skill_tags`, `daily_commitment_min`, `days_available_bitmask`, `peer_opt_in`, `peer_skill_filter`, `step4_skipped`, `step5_skipped`, `created_at`, `updated_at`) VALUES
(1, 2, 1, 0, NULL, NULL, NULL, NULL, NULL, 0, 0, '2026-06-04 10:42:37', '2026-06-04 10:42:37');

-- --------------------------------------------------------

--
-- Table structure for table `peers`
--

CREATE TABLE `peers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id_a` bigint(20) UNSIGNED NOT NULL,
  `user_id_b` bigint(20) UNSIGNED NOT NULL,
  `paired_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `peers`
--

INSERT INTO `peers` (`id`, `user_id_a`, `user_id_b`, `paired_at`, `created_at`, `updated_at`) VALUES
(1, 8, 6, '2026-06-14 17:04:29', '2026-06-14 17:04:29', '2026-06-14 17:04:29'),
(2, 8, 4, '2026-06-14 18:13:49', '2026-06-14 18:13:49', '2026-06-14 18:13:49'),
(3, 4, 7, '2026-06-14 20:42:51', '2026-06-14 20:42:51', '2026-06-14 20:42:51'),
(4, 3, 8, '2026-06-15 01:39:42', '2026-06-15 01:39:42', '2026-06-15 01:39:42');

-- --------------------------------------------------------

--
-- Table structure for table `peer_groups`
--

CREATE TABLE `peer_groups` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(120) NOT NULL,
  `focus_area_tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`focus_area_tags`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `peer_group_members`
--

CREATE TABLE `peer_group_members` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `group_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `role` enum('member','moderator') NOT NULL DEFAULT 'member',
  `joined_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `peer_requests`
--

CREATE TABLE `peer_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `sender_id` bigint(20) UNSIGNED NOT NULL,
  `receiver_id` bigint(20) UNSIGNED NOT NULL,
  `status` enum('pending','accepted','declined') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `peer_requests`
--

INSERT INTO `peer_requests` (`id`, `sender_id`, `receiver_id`, `status`, `created_at`, `updated_at`) VALUES
(1, 4, 1, 'pending', '2026-06-13 10:49:30', '2026-06-13 10:49:30'),
(2, 4, 2, 'pending', '2026-06-13 12:03:50', '2026-06-13 12:03:50'),
(3, 8, 4, 'accepted', '2026-06-14 17:03:54', '2026-06-14 18:13:49'),
(4, 8, 6, 'accepted', '2026-06-14 17:04:23', '2026-06-14 17:04:29'),
(5, 8, 7, 'pending', '2026-06-14 18:04:13', '2026-06-14 18:04:13'),
(6, 4, 7, 'accepted', '2026-06-14 20:42:22', '2026-06-14 20:42:51'),
(7, 3, 8, 'accepted', '2026-06-15 01:39:17', '2026-06-15 01:39:42');

-- --------------------------------------------------------

--
-- Table structure for table `projects`
--

CREATE TABLE `projects` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `skill_name` varchar(255) DEFAULT NULL COMMENT 'Skill this project belongs to',
  `deadline_days` int(11) NOT NULL,
  `start_date` date NOT NULL,
  `due_date` date NOT NULL,
  `color` enum('blue','cyan','green','orange','red') NOT NULL DEFAULT 'blue',
  `status` enum('active','completed','archived') NOT NULL DEFAULT 'active',
  `progress_percent` decimal(5,2) NOT NULL DEFAULT 0.00,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `projects`
--

INSERT INTO `projects` (`id`, `user_id`, `name`, `description`, `skill_name`, `deadline_days`, `start_date`, `due_date`, `color`, `status`, `progress_percent`, `deleted_at`, `created_at`, `updated_at`) VALUES
(2, 2, 'Build a React Dashboard', 'A comprehensive admin dashboard using React, TailwindCSS, and Recharts.', 'React', 14, '2026-06-12', '2026-06-26', 'blue', 'active', 3.70, NULL, '2026-06-12 11:08:52', '2026-06-12 11:34:11'),
(3, 4, 'NextCamppus', 'An platform that lets the students select the best university for them. they can search for univertsities, compare unversities and their informations', 'Java Spring Boot', 15, '2026-06-13', '2026-06-28', 'blue', 'archived', 0.00, '2026-06-14 18:35:52', '2026-06-13 10:12:26', '2026-06-14 18:35:52'),
(4, 4, 'NextCamppus', 'An platform that lets the students select the best university for them. they can search for univertsities, compare unversities and their informations', 'Java Spring Boot', 15, '2026-06-13', '2026-06-28', 'blue', 'archived', 4.55, NULL, '2026-06-13 10:12:50', '2026-06-14 18:36:50'),
(5, 8, 'Next Campus', 'Education platform ', 'Java ', 7, '2026-06-15', '2026-06-22', 'red', 'completed', 100.00, NULL, '2026-06-14 18:05:21', '2026-06-14 18:29:29'),
(6, 4, 'To Do app', 'A todo app that lets the user take notes, and lets them track what has been done, what still needs to be done and how much time they spent on a specific task', 'Backend Engineering', 7, '2026-06-15', '2026-06-22', 'red', 'active', 23.53, NULL, '2026-06-14 18:27:01', '2026-06-14 19:21:32'),
(7, 3, 'NextCampus4D', 'A platform that lets students compare between universities, check all universities admission time, check university informations etc to chose the right university for them', 'Java Spring Boot', 7, '2026-06-15', '2026-06-22', 'green', 'active', 0.00, '2026-06-15 03:06:27', '2026-06-15 03:01:34', '2026-06-15 03:06:27'),
(8, 3, 'To Do app', 'a app that lets the user add task, mark them checked and keeps track of them.', 'Java Spring Boot', 7, '2026-06-15', '2026-06-22', 'green', 'active', 15.79, NULL, '2026-06-15 03:07:11', '2026-06-15 05:06:41');

-- --------------------------------------------------------

--
-- Table structure for table `project_tasks`
--

CREATE TABLE `project_tasks` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `project_id` bigint(20) UNSIGNED NOT NULL,
  `gantt_entry_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'Links to gantt feature if applicable',
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `order_index` int(11) NOT NULL,
  `is_ai_generated` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 = generated by AI, 0 = user-created',
  `xp_reward` int(11) NOT NULL,
  `completed_at` timestamp NULL DEFAULT NULL COMMENT 'Set when kanban card moves to Done column',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `project_tasks`
--

INSERT INTO `project_tasks` (`id`, `project_id`, `gantt_entry_id`, `title`, `description`, `order_index`, `is_ai_generated`, `xp_reward`, `completed_at`, `deleted_at`, `created_at`, `updated_at`) VALUES
(1, 2, 1, 'Initialize React Project', 'Create a new React project using Vite or Create React App.', 0, 1, 8, '2026-06-12 11:34:11', NULL, '2026-06-12 11:09:08', '2026-06-12 11:34:11'),
(2, 2, 1, 'Configure TailwindCSS', 'Install and configure TailwindCSS within the React project for utility-first styling.', 1, 1, 10, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(3, 2, 1, 'Establish Folder Structure', 'Set up a logical folder structure for components, pages, utils, and assets.', 2, 1, 5, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(4, 2, 1, 'Install React Router DOM', 'Install and set up React Router DOM for client-side routing.', 3, 1, 7, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(5, 2, 2, 'Create Sidebar Component', 'Design and implement a responsive navigation sidebar using TailwindCSS.', 4, 1, 15, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(6, 2, 2, 'Create Header Component', 'Develop a header component with user profile, notifications, and dashboard title.', 5, 1, 12, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(7, 2, 2, 'Implement Main Layout', 'Combine sidebar and header into the main dashboard layout, ensuring responsiveness.', 6, 1, 15, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(8, 2, 2, 'Define Dashboard Routes', 'Configure routes for key dashboard sections like Home, Charts, and Tables.', 7, 1, 10, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(9, 2, 2, 'Add Active Link Styling', 'Implement styling to indicate the currently active navigation link in the sidebar.', 8, 1, 8, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(10, 2, 3, 'Install Recharts Library', 'Add Recharts to the project dependencies for data visualization.', 9, 1, 5, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(11, 2, 3, 'Create Line Chart Component', 'Build a reusable component for displaying line charts using Recharts and dummy data.', 10, 1, 15, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(12, 2, 3, 'Create Bar Chart Component', 'Build a reusable component for displaying bar charts using Recharts and dummy data.', 11, 1, 15, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(13, 2, 3, 'Create Pie Chart Component', 'Build a reusable component for displaying pie charts using Recharts and dummy data.', 12, 1, 15, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(14, 2, 3, 'Integrate Charts into Dashboard Page', 'Display various charts on a dedicated \'Charts\' page within the dashboard.', 13, 1, 10, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(15, 2, 3, 'Add Chart Interactivity', 'Implement tooltips, legends, and basic responsiveness for Recharts components.', 14, 1, 12, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(16, 2, 4, 'Create Reusable Data Table Component', 'Develop a generic table component capable of displaying data arrays with customizable columns.', 15, 1, 18, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(17, 2, 4, 'Populate Table with Dummy Data', 'Integrate the data table component on a \'Users\' or \'Products\' page using mock data.', 16, 1, 10, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(18, 2, 4, 'Implement Basic Pagination', 'Add simple pagination functionality to the data table component.', 17, 1, 15, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(19, 2, 4, 'Create User Form Component', 'Build a form component for adding new users or editing existing user details.', 18, 1, 15, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(20, 2, 4, 'Implement Form Validation', 'Add basic client-side validation to the user form fields.', 19, 1, 12, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(21, 2, 4, 'Connect Form to Data State', 'Enable form submission to add new items or update existing items in the application\'s dummy data state.', 20, 1, 18, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(22, 2, 5, 'Implement React Context API', 'Set up a global state management solution using React\'s Context API for shared data.', 21, 1, 20, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(23, 2, 5, 'Refactor Dashboard Settings to Context', 'Move global settings, like sidebar state, to the shared Context API.', 22, 1, 15, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(24, 2, 5, 'Integrate Data Loading with Context', 'Refactor chart and table data fetching/management to utilize the global context.', 23, 1, 18, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(25, 2, 5, 'Final Styling Pass', 'Review and refine all components for consistent styling and adherence to TailwindCSS best practices.', 24, 1, 10, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(26, 2, 5, 'Optimize Component Rendering', 'Apply `React.memo` or `useCallback`/`useMemo` where appropriate to optimize performance.', 25, 1, 15, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(27, 2, NULL, 'Write Project README', 'Document the project setup, scripts, and key features in a comprehensive README.md file.', 26, 1, 5, NULL, NULL, '2026-06-12 11:09:08', '2026-06-12 11:09:08'),
(28, 4, 6, 'Initialize Spring Boot Project', 'Set up a new Spring Boot project with necessary dependencies (Web, Data JPA, H2/PostgreSQL driver).', 0, 1, 10, '2026-06-14 18:15:34', NULL, '2026-06-13 10:13:15', '2026-06-14 18:15:34'),
(29, 4, 6, 'Configure Database', 'Configure application.properties for H2 (development) or PostgreSQL (production) database connection and JPA settings.', 1, 1, 10, NULL, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(30, 4, 6, 'Implement Global Exception Handling', 'Set up centralized exception handling using @ControllerAdvice for consistent API error responses.', 2, 1, 10, NULL, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(31, 4, 7, 'Define University Entity', 'Create the University JPA entity with relevant fields (e.g., name, location, type, ranking, fees, description).', 3, 1, 10, NULL, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(32, 4, 7, 'Create University Repository', 'Implement JpaRepository for basic data access operations on University entities.', 4, 1, 5, NULL, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(33, 4, 7, 'Develop University Service Layer', 'Create a service class to encapsulate business logic for fetching and managing universities.', 5, 1, 10, NULL, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(34, 4, 7, 'Populate Dummy University Data', 'Write a data initialization script or use a CSV import to pre-populate the database with at least 15-20 dummy university entries.', 6, 1, 10, NULL, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(35, 4, 8, 'Design Search Endpoint', 'Create a REST Controller endpoint (e.g., GET /api/universities/search) to handle search queries.', 7, 1, 10, NULL, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(36, 4, 8, 'Implement Search Logic with Criteria', 'Develop service layer logic to filter universities based on various criteria like name, location, type, or minimum ranking.', 8, 1, 15, NULL, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(37, 4, 8, 'Add Pagination to Search Results', 'Integrate Spring Data JPA\'s Pageable interface for paginated and sortable search results.', 9, 1, 10, NULL, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(38, 4, 8, 'Create University Details Endpoint', 'Develop a REST Controller endpoint (e.g., GET /api/universities/{id}) to retrieve a single university\'s comprehensive details.', 10, 1, 10, NULL, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(39, 4, 9, 'Design Comparison Endpoint', 'Create a REST Controller endpoint (e.g., GET /api/universities/compare?ids=1,2,3) to accept multiple university IDs for comparison.', 11, 1, 10, NULL, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(40, 4, 9, 'Implement Comparison Logic', 'Retrieve detailed information for all provided university IDs and structure a response showing commonalities and key differences.', 12, 1, 15, NULL, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(41, 4, 10, 'Set Up Basic Frontend Structure', 'Create basic HTML templates (e.g., using Thymeleaf or a simple client-side JS/HTML setup) and initial CSS for the web application.', 13, 1, 10, NULL, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(42, 4, 10, 'Develop University Search Page', 'Create a UI page with a search input, filters, and a dynamic display area for search results. Integrate with the University Search API.', 14, 1, 15, NULL, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(43, 4, 10, 'Implement University Details Page', 'Design a dedicated page to show comprehensive information for a selected university. Integrate with the University Details API.', 15, 1, 15, NULL, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(44, 4, 10, 'Create University Comparison Interface', 'Develop a UI where users can select multiple universities (e.g., from search results) and view a side-by-side comparison. Integrate with the Comparison API.', 16, 1, 20, NULL, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(45, 4, 10, 'Add Basic Navigation and Styling', 'Implement essential navigation elements (e.g., home, search) and apply basic CSS for a presentable and user-friendly interface.', 17, 1, 10, NULL, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(46, 4, 11, 'Perform API Integration Testing', 'Manually test all backend API endpoints using tools like Postman to ensure correct functionality and error handling.', 18, 1, 10, NULL, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(47, 4, 11, 'Conduct UI Acceptance Testing', 'Thoroughly test the entire user flow from search to details to comparison, ensuring a smooth and intuitive user experience.', 19, 1, 10, NULL, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(48, 4, 11, 'Prepare Deployment Artifact', 'Generate the executable JAR file for the Spring Boot application, ready for deployment.', 20, 1, 5, NULL, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(49, 4, 11, 'Write Project README', 'Create a comprehensive README.md file covering project setup instructions, API endpoints, and usage guide.', 21, 1, 5, NULL, NULL, '2026-06-13 10:13:15', '2026-06-13 10:13:15'),
(50, 5, 12, 'Initialize Spring Boot Project', 'Create a new Spring Boot project with necessary dependencies (Web, Data JPA, H2/PostgreSQL).', 0, 1, 10, '2026-06-14 18:15:49', NULL, '2026-06-14 18:05:40', '2026-06-14 18:15:49'),
(51, 5, 12, 'Configure Database', 'Set up H2 in-memory database for development and basic PostgreSQL configuration for potential deployment.', 1, 1, 8, '2026-06-14 18:19:58', NULL, '2026-06-14 18:05:40', '2026-06-14 18:19:58'),
(52, 5, 12, 'Establish Base Folder Structure', 'Organize packages for controllers, services, repositories, and entities.', 2, 1, 5, '2026-06-14 18:15:45', NULL, '2026-06-14 18:05:40', '2026-06-14 18:15:45'),
(53, 5, 13, 'Design User Entity and Repository', 'Create User entity (id, username, password_hash, role) and corresponding JPA repository.', 3, 1, 15, '2026-06-14 18:20:00', NULL, '2026-06-14 18:05:40', '2026-06-14 18:20:00'),
(54, 5, 13, 'Implement User Registration Endpoint', 'Develop REST API endpoint for new user registration with password hashing.', 4, 1, 18, '2026-06-14 18:16:00', NULL, '2026-06-14 18:05:40', '2026-06-14 18:16:00'),
(55, 5, 13, 'Implement User Login Endpoint (JWT/Session)', 'Create API for user login, generating and returning an authentication token (e.g., JWT).', 5, 1, 20, '2026-06-14 18:20:02', NULL, '2026-06-14 18:05:40', '2026-06-14 18:20:02'),
(56, 5, 13, 'Configure Spring Security', 'Set up Spring Security for authentication and authorization, defining roles (STUDENT, INSTRUCTOR).', 6, 1, 20, '2026-06-14 18:20:10', NULL, '2026-06-14 18:05:40', '2026-06-14 18:20:10'),
(57, 5, 14, 'Create User Profile Service and Controller', 'Develop service and controller to allow users to view and update their own basic profile information (e.g., name, email).', 7, 1, 15, '2026-06-14 18:26:40', NULL, '2026-06-14 18:05:40', '2026-06-14 18:26:40'),
(58, 5, 14, 'Implement Profile UI Component', 'Create a basic frontend component for viewing and editing the user\'s profile.', 8, 1, 10, '2026-06-14 18:26:43', NULL, '2026-06-14 18:05:40', '2026-06-14 18:26:43'),
(59, 5, 15, 'Design Course Entity and Repository', 'Define Course entity (id, title, description, instructor_id) and JPA repository.', 9, 1, 15, '2026-06-14 18:26:49', NULL, '2026-06-14 18:05:40', '2026-06-14 18:26:49'),
(60, 5, 15, 'Implement Course CRUD APIs', 'Develop REST endpoints for instructors to create, retrieve, update, and delete courses.', 10, 1, 20, '2026-06-14 18:26:53', NULL, '2026-06-14 18:05:40', '2026-06-14 18:26:53'),
(61, 5, 15, 'Build Instructor Course Dashboard UI', 'Create a basic UI for instructors to list their courses and access CRUD operations.', 11, 1, 15, '2026-06-14 18:26:55', NULL, '2026-06-14 18:05:40', '2026-06-14 18:26:55'),
(62, 5, 16, 'Design Content Block Entity', 'Create ContentBlock entity (id, course_id, title, type, content_url/text, order).', 12, 1, 15, '2026-06-14 18:27:01', NULL, '2026-06-14 18:05:40', '2026-06-14 18:27:01'),
(63, 5, 16, 'Implement Content Block CRUD APIs', 'Develop APIs for instructors to add, retrieve, update, and delete content blocks within a course.', 13, 1, 20, '2026-06-14 18:27:03', NULL, '2026-06-14 18:05:40', '2026-06-14 18:27:03'),
(64, 5, 16, 'Create Content Editor UI', 'Build UI for instructors to add different types of content (e.g., text, links) to specific course modules.', 14, 1, 18, '2026-06-14 18:27:06', NULL, '2026-06-14 18:05:40', '2026-06-14 18:27:06'),
(65, 5, 17, 'Implement API to List All Courses', 'Develop a public API endpoint for students to browse all available courses.', 15, 1, 12, '2026-06-14 18:27:08', NULL, '2026-06-14 18:05:40', '2026-06-14 18:27:08'),
(66, 5, 17, 'Design StudentCourse Enrollment Entity', 'Create entity to track student enrollments (student_id, course_id, enrollment_date).', 16, 1, 10, '2026-06-14 18:27:10', NULL, '2026-06-14 18:05:40', '2026-06-14 18:27:10'),
(67, 5, 17, 'Implement Course Enrollment/Unenrollment APIs', 'Develop APIs for students to enroll in and unenroll from courses.', 17, 1, 18, '2026-06-14 18:27:12', NULL, '2026-06-14 18:05:40', '2026-06-14 18:27:12'),
(68, 5, 17, 'Develop Student Course Browser UI', 'Create a UI for students to view available courses and initiate enrollment.', 18, 1, 15, '2026-06-14 18:27:16', NULL, '2026-06-14 18:05:40', '2026-06-14 18:27:16'),
(69, 5, 18, 'Implement API to View Enrolled Course Content', 'Develop an API that retrieves all content blocks for a specific course a student is enrolled in.', 19, 1, 15, '2026-06-14 18:27:24', NULL, '2026-06-14 18:05:40', '2026-06-14 18:27:24'),
(70, 5, 18, 'Implement Content Completion Tracking', 'Create a mechanism and API to mark specific content blocks as \'completed\' by a student.', 20, 1, 15, '2026-06-14 18:27:21', NULL, '2026-06-14 18:05:40', '2026-06-14 18:27:21'),
(71, 5, 18, 'Build Student Course View UI', 'Develop UI to display course content sequentially and allow students to mark progress.', 21, 1, 18, '2026-06-14 18:29:06', NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:06'),
(72, 5, 19, 'Design Core Application Layout', 'Create a consistent header, footer, and main content area for the application.', 22, 1, 10, '2026-06-14 18:29:10', NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:10'),
(73, 5, 19, 'Implement Role-Based Navigation', 'Set up dynamic navigation menus that adapt based on the logged-in user\'s role (student/instructor).', 23, 1, 12, '2026-06-14 18:29:12', NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:12'),
(74, 5, 19, 'Create Landing Page/Dashboard', 'Develop a simple landing page or user dashboard displaying relevant information post-login.', 24, 1, 10, '2026-06-14 18:29:16', NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:16'),
(75, 5, 20, 'Write Basic Unit Tests', 'Implement essential unit tests for core services and repositories (e.g., User, Course).', 25, 1, 15, '2026-06-14 18:29:19', NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:19'),
(76, 5, 20, 'Perform API Integration Tests', 'Conduct integration tests for critical API flows like user registration, course creation, and enrollment.', 26, 1, 18, '2026-06-14 18:29:22', NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:22'),
(77, 5, 20, 'Prepare Project README and Setup Instructions', 'Document how to set up, build, and run the \'Next Campus\' application.', 27, 1, 8, '2026-06-14 18:29:29', NULL, '2026-06-14 18:05:40', '2026-06-14 18:29:29'),
(78, 6, 21, 'Choose Backend Framework & Initialize Project', 'Select a backend framework (e.g., FastAPI, Flask, Express.js) and set up the project boilerplate.', 0, 1, 10, '2026-06-14 19:20:45', NULL, '2026-06-14 18:27:22', '2026-06-14 19:20:45'),
(79, 6, 21, 'Database Setup & ORM Integration', 'Configure a relational database (e.g., PostgreSQL, SQLite) and integrate an ORM/ODM (e.g., SQLAlchemy, Prisma).', 1, 1, 10, '2026-06-14 19:21:01', NULL, '2026-06-14 18:27:22', '2026-06-14 19:21:01'),
(80, 6, 21, 'Define Task & TimeEntry Models', 'Create database schemas for \'Task\' (title, description, status) and \'TimeEntry\' (task_id, start_time, end_time).', 2, 1, 10, '2026-06-14 19:21:19', NULL, '2026-06-14 18:27:22', '2026-06-14 19:21:19'),
(81, 6, 22, 'Implement Create Task Endpoint (POST /tasks)', 'Develop an API endpoint to create new to-do items with a title and description.', 3, 1, 10, '2026-06-14 19:21:32', NULL, '2026-06-14 18:27:22', '2026-06-14 19:21:32'),
(82, 6, 22, 'Implement Get All Tasks Endpoint (GET /tasks)', 'Develop an API endpoint to retrieve a list of all existing tasks.', 4, 1, 8, NULL, NULL, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(83, 6, 22, 'Implement Get Single Task Endpoint (GET /tasks/{id})', 'Develop an API endpoint to retrieve details of a specific task by its ID.', 5, 1, 8, NULL, NULL, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(84, 6, 22, 'Implement Update Task Endpoint (PUT/PATCH /tasks/{id})', 'Develop an API endpoint to modify existing task details (title, description) by its ID.', 6, 1, 12, NULL, NULL, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(85, 6, 22, 'Implement Delete Task Endpoint (DELETE /tasks/{id})', 'Develop an API endpoint to remove a task from the database by its ID.', 7, 1, 8, NULL, NULL, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(86, 6, 23, 'Add Task Status Field', 'Modify the Task model to include a \'status\' field (e.g., \'pending\', \'completed\') and apply database migrations.', 8, 1, 7, NULL, NULL, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(87, 6, 23, 'Implement Update Task Status Endpoint (PATCH /tasks/{id}/status)', 'Develop an API endpoint to easily change a task\'s status.', 9, 1, 12, NULL, NULL, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(88, 6, 23, 'Implement Filter Tasks by Status (GET /tasks?status=...)', 'Enhance the Get All Tasks endpoint to allow filtering tasks based on their status.', 10, 1, 15, NULL, NULL, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(89, 6, 24, 'Implement Start Timer Endpoint (POST /tasks/{id}/start_timer)', 'Develop an API endpoint to record the start time of a work session for a specific task.', 11, 1, 15, NULL, NULL, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(90, 6, 24, 'Implement Stop Timer Endpoint (POST /tasks/{id}/stop_timer)', 'Develop an API endpoint to record the end time, calculate duration, and save the TimeEntry for a work session.', 12, 1, 15, NULL, NULL, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(91, 6, 24, 'Calculate & Retrieve Total Time Spent (GET /tasks/{id}/total_time_spent)', 'Implement logic to sum up all time entries for a given task and expose it via an API endpoint.', 13, 1, 20, NULL, NULL, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(92, 6, 25, 'Write Unit/Integration Tests for Core Endpoints', 'Develop unit and basic integration tests for Task CRUD and status update endpoints to ensure API reliability.', 14, 1, 15, NULL, NULL, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(93, 6, 25, 'Write Integration Tests for Time Tracking Logic', 'Develop integration tests for the start/stop timer and total time calculation workflows.', 15, 1, 18, NULL, NULL, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(94, 6, 25, 'Generate API Documentation (OpenAPI/Swagger)', 'Use tools like OpenAPI/Swagger to generate interactive API documentation for all developed endpoints.', 16, 1, 15, NULL, NULL, '2026-06-14 18:27:22', '2026-06-14 18:27:22'),
(95, 8, 26, 'Initialize Spring Boot Project', 'Create a new Spring Boot project using Spring Initializr with dependencies: Spring Web, Spring Data JPA, H2 Database.', 0, 1, 10, '2026-06-15 03:07:59', NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:59'),
(96, 8, 26, 'Configure H2 Database', 'Set up H2 in-memory database configuration in application.properties for development.', 1, 1, 8, '2026-06-15 04:09:30', NULL, '2026-06-15 03:07:31', '2026-06-15 04:09:30'),
(97, 8, 27, 'Create Task Entity', 'Define the `Task` JPA entity with fields: id (Long), description (String), completed (boolean, default false), creationDate (LocalDateTime).', 2, 1, 15, '2026-06-15 05:06:41', NULL, '2026-06-15 03:07:31', '2026-06-15 05:06:41'),
(98, 8, 27, 'Create Task Repository', 'Develop `TaskRepository` interface extending `JpaRepository` for basic CRUD operations on `Task` entities.', 3, 1, 10, NULL, NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(99, 8, 28, 'Define TaskService Interface', 'Create `TaskService` interface with method signatures for adding, retrieving, updating completion status, and deleting tasks.', 4, 1, 7, NULL, NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(100, 8, 28, 'Implement TaskServiceImpl', 'Implement `TaskService` methods (`addTask`, `getAllTasks`, `getTaskById`, `markTaskCompleted`, `deleteTask`) using `TaskRepository`.', 5, 1, 20, NULL, NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(101, 8, 29, 'Create TaskController', 'Develop the `TaskController` class annotated with `@RestController` and `@RequestMapping(\"/api/tasks\")`.', 6, 1, 10, NULL, NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(102, 8, 29, 'Implement POST /api/tasks (Add Task)', 'Create an endpoint to add a new task, expecting a Task DTO and returning the created task.', 7, 1, 15, NULL, NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(103, 8, 29, 'Implement GET /api/tasks (Get All Tasks)', 'Create an endpoint to retrieve a list of all tasks from the database.', 8, 1, 10, NULL, NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(104, 8, 29, 'Implement GET /api/tasks/{id} (Get Task by ID)', 'Create an endpoint to retrieve a single task by its unique identifier.', 9, 1, 12, NULL, NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(105, 8, 29, 'Implement PUT /api/tasks/{id}/complete (Mark Task Completed)', 'Create an endpoint to mark a specific task as completed given its ID.', 10, 1, 15, NULL, NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(106, 8, 29, 'Implement DELETE /api/tasks/{id} (Delete Task)', 'Create an endpoint to permanently delete a task by its ID.', 11, 1, 12, NULL, NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(107, 8, 30, 'Implement Custom Exceptions', 'Create custom exception classes like `TaskNotFoundException` for specific error scenarios.', 12, 1, 8, NULL, NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(108, 8, 30, 'Implement Global Exception Handler', 'Set up a `@ControllerAdvice` to handle custom and common Spring exceptions gracefully across all controllers.', 13, 1, 12, NULL, NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(109, 8, 30, 'Add Input Validation to DTOs', 'Apply Spring\'s validation annotations (e.g., `@NotBlank`, `@Size`) to DTOs for incoming request bodies.', 14, 1, 10, NULL, NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(110, 8, 31, 'Write Unit Tests for TaskService', 'Develop unit tests for the business logic in `TaskService` using JUnit 5 and Mockito.', 15, 1, 18, NULL, NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(111, 8, 31, 'Write Integration Tests for TaskController', 'Develop integration tests for `TaskController` endpoints using Spring Boot Test and MockMvc.', 16, 1, 18, NULL, NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(112, 8, 31, 'Perform Code Review and Refactoring', 'Conduct a self-review of the code for adherence to best practices, readability, and minor refactorings.', 17, 1, 10, NULL, NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:31'),
(113, 8, 31, 'Document API in README.md', 'Create a `README.md` file documenting the API endpoints, how to run the application, and usage examples.', 18, 1, 8, NULL, NULL, '2026-06-15 03:07:31', '2026-06-15 03:07:31');

-- --------------------------------------------------------

--
-- Table structure for table `refresh_tokens`
--

CREATE TABLE `refresh_tokens` (
  `id` bigint(20) NOT NULL,
  `expiry_date` datetime(6) NOT NULL,
  `token` varchar(500) NOT NULL,
  `user_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reward_store_items`
--

CREATE TABLE `reward_store_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(120) NOT NULL,
  `description` text DEFAULT NULL,
  `item_type` enum('theme','avatar_frame','xp_boost','streak_freeze','other') NOT NULL,
  `point_cost` int(10) UNSIGNED NOT NULL,
  `duration_hours` int(11) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `reward_store_items`
--

INSERT INTO `reward_store_items` (`id`, `name`, `description`, `item_type`, `point_cost`, `duration_hours`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Dark Theme', 'Unlock the sleek dark theme for your dashboard.', 'theme', 500, NULL, 1, '2026-06-12 11:49:13', '2026-06-12 11:49:13'),
(2, 'Cyberpunk Theme', 'Unlock the neon cyberpunk theme.', 'theme', 1000, NULL, 1, '2026-06-12 11:49:13', '2026-06-12 11:49:13'),
(3, 'Streak Freeze', 'Protect your streak for 1 day even if you miss your tasks.', 'streak_freeze', 100, 24, 1, '2026-06-12 11:49:13', '2026-06-12 11:49:13'),
(4, '2x XP Boost', 'Double all XP earned for the next 24 hours.', 'xp_boost', 200, 24, 1, '2026-06-12 11:49:13', '2026-06-12 11:49:13'),
(5, 'Gold Avatar Frame', 'Make your profile picture stand out with a gold frame.', 'avatar_frame', 1500, NULL, 1, '2026-06-12 11:49:13', '2026-06-12 11:49:13');

-- --------------------------------------------------------

--
-- Table structure for table `roadmaps`
--

CREATE TABLE `roadmaps` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `skill_goal` varchar(255) NOT NULL,
  `level` varchar(255) DEFAULT NULL,
  `daily_time_minutes` int(11) DEFAULT NULL,
  `duration_months` int(11) DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL COMMENT 'start_date + duration',
  `total_days` int(11) DEFAULT NULL,
  `focus_areas` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`focus_areas`)),
  `experience_level` text DEFAULT NULL COMMENT 'User-provided experience context',
  `goal_purpose` enum('job','education','other') NOT NULL DEFAULT 'other',
  `status` varchar(255) DEFAULT NULL,
  `ai_raw_response` longtext DEFAULT NULL COMMENT 'Raw Gemini JSON response',
  `ai_parsed_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Parsed structured roadmap' CHECK (json_valid(`ai_parsed_data`)),
  `progress_percent` int(11) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `roadmaps`
--

INSERT INTO `roadmaps` (`id`, `user_id`, `title`, `skill_goal`, `level`, `daily_time_minutes`, `duration_months`, `start_date`, `end_date`, `total_days`, `focus_areas`, `experience_level`, `goal_purpose`, `status`, `ai_raw_response`, `ai_parsed_data`, `progress_percent`, `deleted_at`, `created_at`, `updated_at`) VALUES
(1, 2, 'Master Python Programming in 30 Days (MOCKED)', 'Python Programming', 'beginner', 60, 1, '2026-06-05', '2026-07-05', 30, NULL, NULL, 'other', 'archived', NULL, NULL, 0, NULL, '2026-06-05 03:04:20', '2026-06-12 03:27:54'),
(2, 2, 'My Updated DE Roadmap', 'Understand core programming concepts (Data Structures, Loops) in Python and their foundational role in Data Engineering.', 'Beginner', 60, 1, '2026-06-10', '2026-07-10', 30, NULL, NULL, 'other', 'active', NULL, NULL, 0, NULL, '2026-06-10 07:22:08', '2026-06-12 03:28:11'),
(8, 4, 'DevOps', 'Understand fundamental DevOps principles and tools', 'beginner', 60, 1, '2026-06-14', '2026-07-14', 30, NULL, NULL, 'other', 'active', NULL, NULL, 10, NULL, '2026-06-14 14:18:00', '2026-06-15 00:17:26'),
(9, 4, 'Python', 'Foundational Python Programming', 'beginner', 60, 1, '2026-06-14', '2026-07-14', 30, NULL, NULL, 'other', 'archived', NULL, NULL, 0, NULL, '2026-06-14 14:22:32', '2026-06-15 00:17:26'),
(11, 4, 'Web Developer', 'Become a Web Developer', 'beginner', 60, 1, '2026-06-14', '2026-07-14', 30, NULL, NULL, 'other', 'archived', NULL, NULL, 0, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:45'),
(12, 8, 'Cyber Security', 'Foundational Cyber Security Knowledge', 'beginner', 120, 1, '2026-06-15', '2026-07-15', 30, NULL, NULL, 'other', 'active', NULL, NULL, 10, NULL, '2026-06-14 21:09:54', '2026-06-15 02:34:15'),
(13, 3, 'DevOps', 'Learn foundational DevOps concepts and tools', 'beginner', 60, 1, '2026-06-15', '2026-07-15', 30, NULL, NULL, 'other', 'active', NULL, NULL, 10, NULL, '2026-06-15 00:39:28', '2026-06-15 02:35:13');

-- --------------------------------------------------------

--
-- Table structure for table `roadmap_tasks`
--

CREATE TABLE `roadmap_tasks` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `roadmap_id` bigint(20) UNSIGNED NOT NULL,
  `title` text NOT NULL COMMENT 'What to learn / task description',
  `question` text NOT NULL COMMENT 'Comprehension question for this day',
  `answer` text NOT NULL COMMENT 'Correct answer used for validation',
  `xp_reward` int(11) NOT NULL,
  `day_number` int(11) NOT NULL,
  `status` enum('pending','completed') NOT NULL DEFAULT 'pending',
  `completed_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `roadmap_tasks`
--

INSERT INTO `roadmap_tasks` (`id`, `roadmap_id`, `title`, `question`, `answer`, `xp_reward`, `day_number`, `status`, `completed_at`, `deleted_at`, `created_at`, `updated_at`) VALUES
(1, 1, 'Introduction to Python Programming', 'What is the main purpose of this skill?', 'To build awesome projects.', 10, 1, 'pending', NULL, NULL, '2026-06-05 03:04:20', '2026-06-05 03:04:20'),
(2, 1, 'Core Concepts', 'Name one core concept.', 'Fundamentals.', 10, 2, 'pending', NULL, NULL, '2026-06-05 03:04:20', '2026-06-05 03:04:20'),
(3, 2, 'Introduction to Data Engineering & Python Basics', 'What is the primary role of a Data Engineer?', 'To design, build, and maintain the infrastructure and systems that enable organizations to collect, store, process, and analyze large volumes of data reliably and efficiently.', 10, 1, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(4, 2, 'Python Data Types: Integers, Floats, Strings, Booleans', 'Name the four fundamental Python data types introduced today and give an example of each.', 'Integer (e.g., 10), Float (e.g., 3.14), String (e.g., \'hello\'), Boolean (e.g., True).', 10, 2, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(5, 2, 'Data Structures: Python Lists (Ordered, Mutable Collections)', 'What are the two main characteristics of a Python List regarding its order and mutability?', 'Python Lists are ordered (elements maintain their sequence) and mutable (their elements can be changed after creation).', 10, 3, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(6, 2, 'List Operations: Accessing, Modifying, Adding, Removing Elements', 'How do you add an element to the end of a Python list and remove a specific element by its value?', 'Use `list.append(element)` to add an element to the end and `list.remove(value)` to remove the first occurrence of a specific value.', 10, 4, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(7, 2, 'Data Structures: Python Tuples (Ordered, Immutable Collections)', 'What is the key difference between a Python List and a Python Tuple?', 'Lists are mutable (changeable), while Tuples are immutable (unchangeable) after creation. Both are ordered collections.', 10, 5, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(8, 2, 'Data Structures: Python Sets (Unordered, Unique Elements)', 'What are the two primary characteristics of a Python Set?', 'Sets are unordered collections of unique elements, meaning they do not allow duplicate values and their elements do not have a specific index.', 10, 6, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(9, 2, 'Review & Practice: Basic Data Structures (Lists, Tuples, Sets)', 'When would you choose a Set over a List for storing data?', 'Choose a Set when you need to store a collection of unique items and the order of elements is not important. Sets are efficient for membership testing and removing duplicates.', 10, 7, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(10, 2, 'Control Flow: Introduction to `for` Loops', 'What is the primary purpose of a `for` loop in Python?', 'A `for` loop is used to iterate over a sequence (like a list, tuple, string, or range) or other iterable objects, executing a block of code for each item.', 10, 8, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(11, 2, 'Advanced `for` Loops: `range()` and List Iteration', 'How can you use a `for` loop to iterate a specific number of times, say 5 times?', 'You can use `for i in range(5):` which will iterate 5 times, with `i` taking values from 0 to 4.', 10, 9, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(12, 2, 'Control Flow: Introduction to `while` Loops', 'When is a `while` loop more appropriate to use than a `for` loop?', 'A `while` loop is more appropriate when the number of iterations is not known beforehand, and the loop needs to continue as long as a certain condition remains true.', 10, 10, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(13, 2, 'Loops: Nested Loops for Multi-dimensional Iteration', 'What is a nested loop and why would you use one?', 'A nested loop is a loop inside another loop. They are used to process items in multi-dimensional structures, like rows and columns in a grid, or to generate combinations.', 10, 11, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(14, 2, 'Data Structures: Python Dictionaries (Key-Value Pairs)', 'How does a Dictionary store data, and what makes its keys unique?', 'A Dictionary stores data as key-value pairs. Each key must be unique and immutable (e.g., strings, numbers, tuples), allowing for efficient retrieval of values.', 10, 12, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(15, 2, 'Dictionary Operations: Accessing, Modifying, Adding, Iterating', 'How do you access a value in a dictionary given its key, and how do you add a new key-value pair?', 'Access a value using `dictionary[key]` or `dictionary.get(key)`. Add a new pair by assigning a value to a new key: `dictionary[new_key] = new_value`.', 10, 13, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(16, 2, 'Review & Practice: Loops and Dictionaries', 'Describe a scenario where you would use a dictionary and a loop together in data processing.', 'To count the frequency of items in a list: loop through the list, and for each item, update its count in a dictionary (e.g., `counts[item] = counts.get(item, 0) + 1`).', 10, 14, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(17, 2, 'Functions: Reusable Code Blocks', 'What is the main benefit of using functions in programming?', 'Functions allow for code reusability, modularity, improved readability, and easier maintenance and debugging of programs.', 10, 15, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(18, 2, 'Functions: Inputs (Parameters) and Outputs (Return Values)', 'How do functions receive input, and how do they send output back to the calling code?', 'Functions receive input through parameters (arguments) defined in their signature. They send output back using the `return` statement.', 10, 16, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(19, 2, 'Data Engineering Prep: Reading Data from Files', 'What Python construct is typically used to open a file for reading safely and ensure it\'s closed automatically?', 'The `with open(\'filename.txt\', \'r\') as file:` statement is used. The `with` statement ensures the file is properly closed even if errors occur.', 10, 17, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(20, 2, 'Data Engineering Prep: Writing Data to Files', 'How do you open a file to add new content to the end without overwriting existing content?', 'Open the file in append mode using the mode `\'a\'`: `with open(\'filename.txt\', \'a\') as file:`.', 10, 18, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(21, 2, 'Robust Code: Handling Errors with `try-except`', 'Why is error handling important in data engineering, and what Python block is used for it?', 'Error handling ensures programs don\'t crash unexpectedly (e.g., due to corrupt data, missing files). The `try-except` block is used to catch and manage potential errors.', 10, 19, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(22, 2, 'Concise Loops: List Comprehensions', 'What is a List Comprehension, and how does it relate to loops?', 'A List Comprehension is a concise, more readable way to create lists based on existing iterables. It\'s a syntactic sugar for a `for` loop used to construct a new list.', 10, 20, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(23, 2, 'Review & Project Idea: Simple Data Processing with Functions & File I/O', 'Propose a simple data processing task that combines reading a file, using a function, and error handling.', 'A function that reads numbers from a CSV file (handling `FileNotFoundError`), converts them to integers (handling `ValueError` for non-numeric data), and returns a list of valid numbers.', 10, 21, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(24, 2, 'Applying DS & Loops: Tabular Data Representation', 'How can you represent simple tabular data (like a CSV file) using Python\'s built-in data structures learned so far?', 'As a list of lists (where each inner list is a row) or, more flexibly, as a list of dictionaries (where each dictionary is a row, with keys representing column headers).', 10, 22, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(25, 2, 'Applying DS & Loops: Basic Data Cleaning', 'Give an example of a simple data cleaning task that can be achieved using loops and conditional statements.', 'Removing duplicate entries from a list of records (by converting to a set and back to a list) or filtering out rows with missing required values using an `if` condition within a loop.', 10, 23, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(26, 2, 'Applying DS & Loops: Basic Data Aggregation', 'How can you count the occurrences of items in a list using loops and a dictionary?', 'Initialize an empty dictionary. Loop through the list; for each item, check if it\'s a key in the dictionary. If yes, increment its value; if no, add it with a value of 1.', 10, 24, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(27, 2, 'Intro to Tools: The Need for Libraries (Pandas Concept)', 'Why are libraries like Pandas typically used for data manipulation in data engineering and analysis, even if you know basic loops and data structures?', 'Pandas provides optimized, high-performance, and convenient functions for common data operations (filtering, aggregation, merging) that would be complex and slower to implement from scratch with basic Python structures and loops.', 10, 25, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(28, 2, 'Data Storage Concepts: Files vs. Databases', 'What is a key advantage of using a database over simple text files for storing structured data in a data engineering context?', 'Databases offer structured storage, efficient querying, data integrity constraints, concurrent access for multiple users, and better reliability compared to simple text files.', 10, 26, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(29, 2, 'Querying Data: Introduction to SQL (Basic SELECT, WHERE)', 'What is SQL primarily used for, and what are the two most basic keywords for retrieving filtered data?', 'SQL (Structured Query Language) is used for managing and manipulating relational databases. `SELECT` is used to specify columns, and `WHERE` is used to filter rows based on conditions.', 10, 27, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(30, 2, 'Modern Data Storage: Cloud Object Storage (S3, GCS Conceptual)', 'Name a benefit of using cloud object storage (like AWS S3 or Google Cloud Storage) for large datasets in data engineering.', 'Benefits include massive scalability (store virtually unlimited data), high durability (data redundancy), global accessibility, and often lower cost compared to managing traditional storage.', 10, 28, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(31, 2, 'Data Flow: Understanding Data Pipelines', 'What is a data pipeline, and how do functions and loops conceptually fit into its stages?', 'A data pipeline is a series of automated steps to move and transform data from source to destination. Functions represent individual transformation steps, and loops are used within these functions to process data batches or iterate through records.', 10, 29, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(32, 2, 'Capstone: Simple Data Processor with Loops & DS', 'Outline the steps to build a Python script that reads a list of numbers from a file, calculates their sum and average, and writes the results to another file, using concepts learned.', '1. Use `open()` with `\'r\'` and a `for` loop to read lines from the input file. 2. Inside the loop, convert each line to a number (using `int()` or `float()`, handling `ValueError` with `try-except`). 3. Maintain a running sum and count of valid numbers. 4. After the loop, calculate the average. 5. Use `open()` with `\'w\'` to write the sum and average to an output file.', 10, 30, 'pending', NULL, NULL, '2026-06-10 07:22:08', '2026-06-10 07:22:08'),
(33, 2, 'Learn React Hooks', 'What is the difference between useState and useEffect?', 'useState is for state, useEffect is for side-effects.', 15, 5, 'pending', NULL, NULL, '2026-06-12 03:41:04', '2026-06-12 03:41:04'),
(244, 8, 'Introduction to DevOps // Learn about the definition, history, and core principles of DevOps (CALMS)', 'What does the \'L\' in the CALMS acronym for DevOps principles stand for?', 'Lean', 10, 1, 'completed', '2026-06-14 22:18:58', NULL, '2026-06-14 14:18:00', '2026-06-14 22:18:58'),
(245, 8, 'DevOps Culture and Methodologies // Explore the cultural aspects of DevOps and its relationship with Agile methodologies', 'Which software development methodology does DevOps often integrate with to achieve continuous delivery?', 'Agile', 10, 2, 'completed', '2026-06-14 22:19:47', NULL, '2026-06-14 14:18:00', '2026-06-14 22:19:47'),
(246, 8, 'Linux Fundamentals: Basic Navigation // Understand the Linux command line interface, file system hierarchy, and basic navigation commands (`pwd`, `ls`, `cd`)', 'Which command is used to display the current working directory in Linux?', 'pwd', 10, 3, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(247, 8, 'Linux Fundamentals: File Management // Learn commands for creating, copying, moving, and deleting files and directories (`touch`, `mkdir`, `cp`, `mv`, `rm`)', 'Which command is used to create a new empty file in Linux?', 'touch', 10, 4, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(248, 8, 'Linux Fundamentals: Viewing and Searching // Explore commands for viewing file content (`cat`, `less`, `more`) and searching for text (`grep`)', 'Which command is used to display the entire content of a file to the standard output?', 'cat', 10, 5, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(249, 8, 'Linux Fundamentals: User and Permissions // Understand Linux users, groups, and file permissions (`chmod`, `chown`)', 'What numerical value represents \'read\' permission for a file in `chmod`?', '4', 10, 6, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(250, 8, 'Revision: Linux Commands // Review and practice all learned Linux commands and concepts', 'Which command changes the ownership of a file in Linux?', 'chown', 10, 7, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(251, 8, 'Introduction to Version Control // Understand the importance of Version Control Systems (VCS) and the basics of Git', 'What type of Version Control System is Git?', 'Distributed Version Control System (DVCS)', 10, 8, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(252, 8, 'Git Basics: Initialization and Commits // Learn how to initialize a Git repository, add files to the staging area, and commit changes (`git init`, `git add`, `git commit`)', 'Which Git command is used to add changes to the staging area?', 'git add', 10, 9, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(253, 8, 'Git Basics: Status and History // Explore commands to check repository status (`git status`) and view commit history (`git log`, `git diff`)', 'Which Git command shows the differences between the working directory and the staging area?', 'git diff', 10, 10, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(254, 8, 'Git Branching // Understand the concept of branches in Git and commands to create and switch branches (`git branch`, `git checkout`)', 'Which Git command is used to list existing branches?', 'git branch', 10, 11, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(255, 8, 'Git Merging and Conflict Resolution // Learn how to merge branches and resolve merge conflicts', 'What Git state occurs when Git cannot automatically combine changes from two branches?', 'Merge conflict', 10, 12, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(256, 8, 'Remote Repositories // Understand how to work with remote repositories (e.g., GitHub) and commands (`git clone`, `git push`, `git pull`)', 'Which Git command is used to download a repository from a remote source?', 'git clone', 10, 13, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(257, 8, 'Revision: Git Workflow // Review and practice common Git workflows, including branching, merging, and remote operations', 'Which Git command sends local commits to a remote repository?', 'git push', 10, 14, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(258, 8, 'Introduction to CI/CD // Understand Continuous Integration (CI), Continuous Delivery (CD), and Continuous Deployment (CD)', 'What is the primary goal of Continuous Integration?', 'To frequently integrate code changes into a shared repository', 10, 15, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(259, 8, 'CI/CD Pipeline Stages // Learn about the typical stages of a CI/CD pipeline (build, test, deploy)', 'What stage of a CI/CD pipeline involves compiling code and creating artifacts?', 'Build', 10, 16, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(260, 8, 'Introduction to Containerization and Docker // Understand the concept of containers and the basics of Docker', 'What technology allows an application and its dependencies to be packaged into a single, isolated unit?', 'Containerization', 10, 17, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(261, 8, 'Docker Installation and Basic Commands // Set up Docker (conceptual) and learn essential commands (`docker info`, `docker version`)', 'Which Docker command displays system-wide information regarding the Docker installation?', 'docker info', 10, 18, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(262, 8, 'Docker Images and Containers // Learn to pull Docker images, run containers, and manage them (`docker pull`, `docker run`, `docker ps`, `docker stop`, `docker rm`)', 'Which Docker command lists all running containers?', 'docker ps', 10, 19, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(263, 8, 'Building Custom Docker Images // Understand `Dockerfile` syntax and how to build custom images (`docker build`)', 'What is the name of the text file that contains instructions for building a Docker image?', 'Dockerfile', 10, 20, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(264, 8, 'Revision: Docker Basics // Review and practice Docker image and container management', 'Which Docker command removes a stopped container?', 'docker rm', 10, 21, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(265, 8, 'Introduction to Shell Scripting // Learn basic shell scripting concepts, variables, and `echo` command', 'What character is typically used at the beginning of a shell script to indicate the interpreter?', '#!', 10, 22, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(266, 8, 'Shell Scripting: Conditionals // Understand how to use `if`, `else`, and `elif` statements in shell scripts', 'Which keyword marks the end of an `if` statement block in a Bash script?', 'fi', 10, 23, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(267, 8, 'Shell Scripting: Loops // Learn about `for` and `while` loops for automation in shell scripts', 'Which type of loop is suitable for iterating over a list of items in a shell script?', 'for loop', 10, 24, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(268, 8, 'Introduction to Cloud Computing // Understand the fundamental concepts of cloud computing, including service models (IaaS, PaaS, SaaS) and deployment models', 'Which cloud service model provides virtualized computing resources over the internet?', 'Infrastructure as a Service (IaaS)', 10, 25, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(269, 8, 'Overview of Major Cloud Providers // Get an introduction to AWS, Azure, and Google Cloud Platform (GCP)', 'Which cloud provider offers services like EC2, S3, and Lambda?', 'AWS (Amazon Web Services)', 10, 26, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(270, 8, 'Basic Cloud Resource: Virtual Machines // Understand the concept of virtual machines in the cloud and how they are provisioned (e.g., EC2 instance conceptually)', 'What is the name of AWS\'s service for providing scalable compute capacity in the cloud?', 'EC2 (Elastic Compute Cloud)', 10, 27, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(271, 8, 'Revision: Key DevOps Concepts, Git, Docker, Cloud Basics // Comprehensive review of all topics covered so far', 'What is the main benefit of using Docker for application deployment?', 'Portability and consistency across environments', 10, 28, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(272, 8, 'Mini Project: Design a Simple CI/CD Workflow // Outline the steps for a basic CI/CD pipeline for a simple web application using learned concepts (Git, Docker, theoretical CI server)', 'In a basic CI/CD pipeline for a web app, what tool would typically manage the source code?', 'Git', 10, 29, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(273, 8, 'Roadmap Review and Next Steps // Consolidate learning, identify areas for deeper dive, and plan future learning path in DevOps', 'What is one common next step for a beginner learning DevOps after mastering basic Git and Docker?', 'Learning a CI/CD tool like Jenkins or GitLab CI/CD', 10, 30, 'pending', NULL, NULL, '2026-06-14 14:18:00', '2026-06-14 14:18:00'),
(274, 9, 'Introduction to Python // Set up Python environment, write and run \'Hello World\', understand basic syntax and comments.', 'What function is commonly used to print output to the console in Python?', 'print()', 10, 1, 'completed', '2026-06-14 23:22:28', NULL, '2026-06-14 14:22:32', '2026-06-14 23:22:28'),
(275, 9, 'Variables and Basic Data Types // Declare variables, understand integers, floats, strings, and booleans.', 'What data type in Python is used to store true/false values?', 'Boolean', 10, 2, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(276, 9, 'Operators // Learn about arithmetic, assignment, comparison, and logical operators.', 'What is the result of 5 // 2 in Python?', '2', 10, 3, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(277, 9, 'Strings // String creation, indexing, slicing, and common string methods (e.g., len(), lower(), upper()).', 'What method is used to convert a string to uppercase in Python?', '.upper()', 10, 4, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(278, 9, 'Input and Type Conversion // Get user input, and convert between data types using int(), float(), and str().', 'What function is used to get input from the user in Python?', 'input()', 10, 5, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(279, 9, 'Conditional Statements (if, elif, else) // Implement basic decision-making logic using conditional statements.', 'Which keyword is used to check for an alternative condition if the preceding \'if\' condition is false?', 'elif', 10, 6, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(280, 9, 'Loops - For Loop // Iterate over sequences like strings and lists using \'for\' loops.', 'What keyword is used to start a \'for\' loop in Python?', 'for', 10, 7, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(281, 9, 'Loops - While Loop // Execute a block of code repeatedly as long as a condition is true using \'while\' loops.', 'What keyword is used to start a \'while\' loop in Python?', 'while', 10, 8, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(282, 9, 'Loop Control Statements // Understand and use \'break\' and \'continue\' statements within loops.', 'Which statement is used to exit a loop prematurely in Python?', 'break', 10, 9, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(283, 9, 'Revision & Practice // Review variables, operators, conditionals, and loops through small coding exercises.', 'What is the primary purpose of the \'continue\' statement within a loop?', 'To skip the rest of the current iteration and move to the next.', 10, 10, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(284, 9, 'Lists // Create, access, modify, add, and remove elements from lists.', 'Which data structure in Python is ordered, changeable, and allows duplicate members?', 'List', 10, 11, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(285, 9, 'List Methods // Learn and use common list methods like append(), insert(), remove(), pop(), and sort().', 'What list method is used to add an element to the end of a list?', '.append()', 10, 12, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(286, 9, 'Tuples // Create, access elements, and understand the immutability of tuples.', 'What is the key characteristic of a Python tuple regarding its elements after creation?', 'Immutable (cannot be changed)', 10, 13, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(287, 9, 'Dictionaries // Create, access values by keys, and add/modify key-value pairs in dictionaries.', 'Which data structure in Python stores data in key-value pairs?', 'Dictionary', 10, 14, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(288, 9, 'Dictionary Methods // Learn and use common dictionary methods like keys(), values(), items(), and get().', 'What dictionary method returns a list of all the keys in the dictionary?', '.keys()', 10, 15, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(289, 9, 'Functions // Define and call simple functions, and understand function parameters.', 'What keyword is used to define a function in Python?', 'def', 10, 16, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(290, 9, 'Function Arguments // Understand positional, keyword, and default arguments in functions.', 'In a function definition, what are the placeholders for the values that will be passed into the function called?', 'Parameters', 10, 17, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(291, 9, 'Return Statement // Use the \'return\' statement to send values back from functions to the caller.', 'What keyword is used to send a value back from a function to the caller?', 'return', 10, 18, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(292, 9, 'Scope of Variables // Differentiate between local and global variables in Python.', 'Variables defined inside a function are said to have what type of scope?', 'Local', 10, 19, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(293, 9, 'Lambda Functions // Introduction to anonymous functions and their basic use cases.', 'What keyword is used to create a small, anonymous function in Python?', 'lambda', 10, 20, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(294, 9, 'Modules // Import and use built-in modules (e.g., \'math\', \'random\').', 'What keyword is used to bring a module into the current Python script?', 'import', 10, 21, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(295, 9, 'Packages // Understand packages as collections of modules (high-level overview).', 'What is a directory containing Python modules and an __init__.py file called?', 'Package', 10, 22, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(296, 9, 'Revision and Practice // Consolidate understanding of functions, modules, and data structures with small coding challenges.', 'If you only want to import a specific function `sqrt` from the `math` module, what syntax would you use?', 'from math import sqrt', 10, 23, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(297, 9, 'Error Handling (try, except) // Implement basic error handling using \'try\' and \'except\' blocks.', 'What block of code in Python is used to test a block of code for errors?', 'try', 10, 24, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(298, 9, 'Error Handling (Specific Exceptions, finally) // Handle specific exceptions and use the \'finally\' block.', 'What block of code always executes, regardless of whether an exception occurred or not?', 'finally', 10, 25, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(299, 9, 'File I/O // Open and read data from text files using read mode (\'r\').', 'What function is used to open a file in Python?', 'open()', 10, 26, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(300, 9, 'File I/O // Write and append data to text files using write mode (\'w\') and append mode (\'a\').', 'What file mode is used to write to a file, creating it if it doesn\'t exist, and overwriting it if it does?', '\'w\'', 10, 27, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(301, 9, 'File I/O (with statement) // Use the \'with\' statement for safer and automatic file handling.', 'What Python statement ensures that an opened file is properly closed even if errors occur?', 'with', 10, 28, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(302, 9, 'Object-Oriented Programming (OOP) Basics // Introduction to classes, objects, attributes, and methods.', 'In Python OOP, what is a blueprint for creating objects?', 'Class', 10, 29, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(303, 9, 'Capstone Project / Revision // Build a small console-based application (e.g., a simple calculator or to-do list) to apply learned concepts.', 'What is the term for an instance of a class?', 'Object', 10, 30, 'pending', NULL, NULL, '2026-06-14 14:22:32', '2026-06-14 14:22:32'),
(394, 11, 'Introduction to Web Development & HTML Basics // Understand what web development is and learn about HTML document structure and basic tags (e.g., html, head, body, title, h1, p).', 'What HTML tag defines the root of an HTML document?', '<html>', 10, 1, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(395, 11, 'HTML Text Formatting & Links // Learn common HTML tags for text formatting (e.g., strong, em, ul, ol, li) and how to create hyperlinks with the \'a\' tag.', 'What HTML tag is used to create an unordered list?', '<ul>', 10, 2, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(396, 11, 'HTML Images & Media // Learn how to embed images using the \'img\' tag and explore basic attributes like src, alt, width, height.', 'Which attribute of the \'img\' tag specifies the path to the image?', 'src', 10, 3, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(397, 11, 'HTML Tables & Forms Introduction // Understand how to structure data with \'table\', \'tr\', \'td\', \'th\' tags and introduce basic form elements like \'form\' and \'input\' with type \'text\'.', 'What HTML tag is used to define a row in a table?', '<tr>', 10, 4, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(398, 11, 'Advanced HTML Forms & Semantics // Learn about various input types (e.g., radio, checkbox, submit), \'textarea\', \'select\', and the importance of semantic HTML (e.g., header, nav, main, footer, article, section).', 'Which HTML input type allows users to select one option from a group?', 'radio', 10, 5, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(399, 11, 'Introduction to CSS // Understand what CSS is, different ways to include CSS (inline, internal, external), and basic syntax (selectors, properties, values).', 'What CSS property is used to change the text color of an element?', 'color', 10, 6, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(400, 11, 'CSS Selectors & Text Styling // Learn about element, class, and ID selectors. Practice styling text with properties like font-family, font-size, font-weight, text-align.', 'How do you select an HTML element with the class \'my-class\' in CSS?', '.my-class', 10, 7, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(401, 11, 'CSS Box Model // Understand the CSS Box Model: content, padding, border, and margin. Practice applying these properties to elements.', 'Which CSS property defines the space between the content and the border of an element?', 'padding', 10, 8, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(402, 11, 'CSS Colors & Backgrounds // Learn to use different color formats (hex, RGB, HSL) and apply background styles (color, image, repeat, position).', 'What is the 3-digit shorthand for the hexadecimal color #FF00FF?', '#F0F', 10, 9, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(403, 11, 'CSS Display Property & Positioning // Explore the \'display\' property (block, inline, inline-block, none) and basic positioning with \'position\' (static, relative, absolute).', 'Which \'display\' value makes an element take up the full width available and start on a new line?', 'block', 10, 10, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(404, 11, 'Introduction to JavaScript // Understand what JavaScript is, how to include it in HTML, and basic syntax for variables (var, let, const) and data types (string, number, boolean).', 'Which keyword is used to declare a variable with block scope in JavaScript?', 'let', 10, 11, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(405, 11, 'JavaScript Operators & Conditionals // Learn about arithmetic, assignment, comparison, and logical operators. Practice using \'if\', \'else if\', and \'else\' statements.', 'What is the logical AND operator in JavaScript?', '&&', 10, 12, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(406, 11, 'JavaScript Loops // Explore \'for\' and \'while\' loops to perform repetitive tasks. Practice iterating over simple data.', 'Which type of loop executes a block of code a specified number of times?', 'for loop', 10, 13, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(407, 11, 'JavaScript Functions // Understand how to define and call functions, pass arguments, and return values. Practice creating reusable code blocks.', 'What keyword is used to define a function in JavaScript?', 'function', 10, 14, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(408, 11, 'Introduction to DOM Manipulation // Learn how to select HTML elements using JavaScript (e.g., getElementById, querySelector) and modify their content or attributes.', 'Which JavaScript method is used to select an element by its ID?', 'document.getElementById()', 10, 15, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(409, 11, 'DOM Events // Learn how to add event listeners to HTML elements (e.g., \'click\', \'mouseover\') and respond to user interactions.', 'Which JavaScript method is used to attach an event handler to an element?', 'addEventListener()', 10, 16, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(410, 11, 'JavaScript Arrays & Objects // Learn to create and manipulate arrays and basic JavaScript objects to store collections of data.', 'How do you access the first element of an array named \'myArray\'?', 'myArray[0]', 10, 17, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(411, 11, 'Simple Interactive Project: Counter // Apply HTML, CSS, and JS knowledge to build a basic counter that increments and decrements on button clicks.', 'What property of an HTML element represents its text content?', 'textContent', 10, 18, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(412, 11, 'Flexbox Fundamentals // Introduce CSS Flexbox for creating flexible and responsive layouts. Learn about container and item properties (e.g., display: flex, justify-content, align-items).', 'What CSS property needs to be set on the parent container to enable Flexbox?', 'display: flex', 10, 19, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(413, 11, 'Building a Basic Layout with Flexbox // Practice using Flexbox to build a simple header, navigation, main content, and footer layout.', 'Which Flexbox property aligns flex items along the cross-axis?', 'align-items', 10, 20, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(414, 11, 'Responsive Design Basics & Media Queries // Understand the concept of responsive web design. Learn to use CSS Media Queries to apply styles based on screen size.', 'What CSS rule is used to define styles that only apply under certain conditions, like screen size?', '@media', 10, 21, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(415, 11, 'Introduction to Browser Developer Tools // Learn how to use browser developer tools (Inspect Element) for debugging HTML, CSS, and basic JavaScript.', 'What browser tool allows you to inspect and modify HTML and CSS live in the browser?', 'Developer Tools (or Inspect Element)', 10, 22, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(416, 11, 'Version Control with Git - Part 1 // Understand the importance of version control. Learn basic Git commands: \'git init\', \'git add\', \'git commit\'.', 'What Git command is used to record changes to the repository?', 'git commit', 10, 23, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(417, 11, 'Version Control with Git - Part 2 // Learn about remote repositories. Practice \'git remote add\', \'git push\', and \'git pull\' with a platform like GitHub.', 'What Git command is used to upload local repository commits to a remote repository?', 'git push', 10, 24, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(418, 11, 'Deployment of a Static Website // Learn how to host a simple static website using free platforms (e.g., GitHub Pages, Netlify basic plan).', 'Which platform can be used to host a static website directly from a Git repository?', 'GitHub Pages (or Netlify)', 10, 25, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(419, 11, 'Mini-Project: Simple Portfolio Page // Apply all learned HTML, CSS, and basic JS to create a basic one-page personal portfolio website.', 'What is the primary purpose of a \'<footer>\' tag in HTML?', 'To define the footer of a document or section, typically containing copyright info, contact data, etc.', 10, 26, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(420, 11, 'Enhancing Portfolio Page with CSS & Responsiveness // Refine the portfolio page\'s styling using advanced CSS properties and make it responsive with media queries.', 'What CSS property is often used to ensure images scale down on smaller screens without overflowing?', 'max-width: 100%; height: auto;', 10, 27, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(421, 11, 'Adding Basic Interactivity to Portfolio Page // Add simple JavaScript interactivity to the portfolio, e.g., a \'scroll to top\' button or a theme switcher.', 'Which JavaScript property can be used to get or set the inline style of an HTML element?', 'element.style', 10, 28, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(422, 11, 'Review and Debugging // Review all learned concepts. Practice identifying and fixing common errors in HTML, CSS, and JavaScript using browser developer tools.', 'What is a common use case for \'console.log()\' in JavaScript?', 'To output messages, variable values, or objects to the browser\'s console for debugging.', 10, 29, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(423, 11, 'Next Steps and Further Learning // Understand the roadmap ahead: exploring JavaScript frameworks (React, Vue, Angular), backend development, and building more complex projects. Identify resources for continued learning.', 'What is a popular JavaScript library used for building user interfaces?', 'React (or Vue, Angular)', 10, 30, 'pending', NULL, NULL, '2026-06-14 14:59:37', '2026-06-14 14:59:37'),
(424, 12, 'Introduction to Cyber Security // Understand what Cyber Security is, its importance, and the core concepts like the CIA Triad.', 'What does the \'C\' in the CIA Triad stand for?', 'Confidentiality', 10, 1, 'completed', '2026-06-15 02:18:34', NULL, '2026-06-14 21:09:54', '2026-06-15 02:18:34'),
(425, 12, 'Types of Cyber Threats // Learn about common cyber threats including malware (viruses, worms, ransomware), phishing, DoS/DDoS attacks, and social engineering.', 'What type of malware encrypts a user\'s files and demands payment for their release?', 'Ransomware', 10, 2, 'completed', '2026-06-15 02:20:31', NULL, '2026-06-14 21:09:54', '2026-06-15 02:20:31'),
(426, 12, 'Cyber Security Principles // Explore fundamental security principles such as Defense-in-Depth, Least Privilege, and Zero Trust.', 'Which security principle suggests that a user should only have the minimum access necessary to perform their job function?', 'Least Privilege', 10, 3, 'completed', '2026-06-15 02:34:15', NULL, '2026-06-14 21:09:54', '2026-06-15 02:34:15'),
(427, 12, 'Basic Networking Concepts // Grasp essential networking concepts including IP addresses, ports, and fundamental protocols like TCP/IP and HTTP/S.', 'What is the standard port number for HTTPS traffic?', '443', 10, 4, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(428, 12, 'Network Topologies & Devices // Learn about common network topologies (e.g., star, bus) and network devices such as hubs, switches, routers, and firewalls.', 'Which network device operates at Layer 3 of the OSI model and forwards packets between different networks?', 'Router', 10, 5, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(429, 12, 'OSI Model // Understand the 7 layers of the OSI model and the function of each layer.', 'Which layer of the OSI model is responsible for logical addressing (IP addresses)?', 'Network Layer', 10, 6, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(430, 12, 'Week 1 Revision & Quiz // Review all concepts covered in the first week to solidify understanding.', 'What is the primary goal of a Denial of Service (DoS) attack?', 'To make a service or resource unavailable to legitimate users', 10, 7, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(431, 12, 'Introduction to Linux // Get familiar with the Linux operating system, including basic commands (ls, cd, pwd, man) and file system navigation.', 'Which Linux command is used to display the current working directory?', 'pwd', 10, 8, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(432, 12, 'Linux File Permissions // Understand how file permissions work in Linux, including \'chmod\' and \'chown\' commands, and user groups.', 'In Linux, what numeric permission value represents read and write access?', '6', 10, 9, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(433, 12, 'Windows Security Basics // Learn about basic security features in Windows, such as user accounts, User Account Control (UAC), and Windows Defender.', 'What Windows feature helps prevent unauthorized changes to the operating system by prompting for administrative consent?', 'User Account Control (UAC)', 10, 10, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(434, 12, 'Password Security // Study best practices for creating strong passwords, the role of password managers, and concepts like hashing and salting.', 'What cryptographic process transforms a password into a fixed-size string of characters, making it irreversible?', 'Hashing', 10, 11, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(435, 12, 'Authentication & Authorization // Differentiate between authentication and authorization, and learn about Multi-Factor Authentication (MFA) and access control models (DAC, MAC, RBAC).', 'What is the process of verifying a user\'s identity?', 'Authentication', 10, 12, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(436, 12, 'Encryption Fundamentals // Understand the differences between symmetric and asymmetric encryption, hashing, and digital signatures.', 'What type of encryption uses a single key for both encryption and decryption?', 'Symmetric encryption', 10, 13, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(437, 12, 'Week 2 Revision & Quiz // Review all concepts covered in the second week.', 'Which type of authentication requires two or more distinct methods of verification?', 'Multi-Factor Authentication (MFA)', 10, 14, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(438, 12, 'Introduction to Web Technologies // Familiarize yourself with how the web works, including HTTP/S, URLs, and basic client-server interaction.', 'What protocol is used for secure communication over a computer network, commonly for web browsing?', 'HTTPS', 10, 15, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(439, 12, 'Common Web Vulnerabilities (OWASP Top 10) // Get an overview of SQL Injection, how it works, and its impact.', 'What type of web vulnerability involves an attacker manipulating database queries through input fields?', 'SQL Injection', 10, 16, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(440, 12, 'Common Web Vulnerabilities (OWASP Top 10) // Learn about Cross-Site Scripting (XSS), its types, and prevention methods.', 'What web vulnerability allows attackers to inject malicious client-side scripts into web pages viewed by other users?', 'Cross-Site Scripting (XSS)', 10, 17, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(441, 12, 'Common Web Vulnerabilities (OWASP Top 10) // Understand vulnerabilities related to Broken Authentication and Session Management.', 'What common attack involves capturing and replaying valid session IDs to hijack a user\'s session?', 'Session hijacking', 10, 18, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(442, 12, 'Network Security Devices // Deep dive into firewalls, including packet filtering and stateful inspection.', 'Which type of firewall inspects the context of a connection over time, not just individual packets?', 'Stateful firewall', 10, 19, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(443, 12, 'VPNs & Proxies // Learn about Virtual Private Networks (VPNs) and proxy servers, how they work, and their use cases for anonymity and security.', 'What technology creates a secure, encrypted connection over a less secure network like the internet?', 'Virtual Private Network (VPN)', 10, 20, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(444, 12, 'Week 3 Revision & Quiz // Review all concepts covered in the third week.', 'Which open community project regularly updates a list of the top 10 most critical web application security risks?', 'OWASP', 10, 21, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(445, 12, 'Introduction to Incident Response // Understand the phases of incident response (preparation, identification, containment, eradication, recovery, lessons learned) and basic steps.', 'What is the first phase in the incident response lifecycle?', 'Preparation', 10, 22, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(446, 12, 'Security Auditing & Logging // Grasp the importance of security logs, common log types (e.g., system, application, security), and their role in incident detection.', 'What vital information source can help identify security incidents by recording events on a system?', 'Logs', 10, 23, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(447, 12, 'Introduction to Vulnerability Scanning // Explore basic vulnerability scanning concepts and tools like Nmap (focus on basic port scanning).', 'What is a common open-source tool used for network discovery and security auditing, including port scanning?', 'Nmap', 10, 24, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(448, 12, 'Ethical Hacking Concepts // Get an introduction to the phases of ethical hacking (reconnaissance, scanning, gaining access, maintaining access, covering tracks) at a conceptual level.', 'What is the initial phase of ethical hacking, focused on gathering information about a target?', 'Reconnaissance', 10, 25, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(449, 12, 'Career Paths in Cyber Security // Discover various career roles in cyber security such as SOC analyst, penetration tester, security engineer, and security architect.', 'Which cyber security role is primarily responsible for monitoring, detecting, and responding to security incidents?', 'SOC Analyst', 10, 26, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(450, 12, 'Certifications & Further Learning // Learn about popular cyber security certifications (e.g., CompTIA Security+, CEH) and resources for continuous learning.', 'Which entry-level certification is often recommended for individuals starting in cyber security?', 'CompTIA Security+', 10, 27, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54');
INSERT INTO `roadmap_tasks` (`id`, `roadmap_id`, `title`, `question`, `answer`, `xp_reward`, `day_number`, `status`, `completed_at`, `deleted_at`, `created_at`, `updated_at`) VALUES
(451, 12, 'Mini-Project: Home Network Security Assessment (Conceptual) // Outline steps for a conceptual assessment of a home network, identifying potential vulnerabilities and recommending basic fixes.', 'What is a common vulnerability in home networks related to Wi-Fi security?', 'Using weak or default Wi-Fi passwords', 10, 28, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(452, 12, 'Cyber Security Best Practices // Review essential personal and organizational cyber security best practices, including regular updates, backups, and user awareness.', 'What best practice helps protect against data loss from hardware failure or cyber attacks?', 'Regular backups', 10, 29, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(453, 12, 'Final Review & Next Steps // Consolidate all learned knowledge and plan future learning goals based on identified interests.', 'What is the collective term for programs designed to disrupt, damage, or gain unauthorized access to computer systems?', 'Malware', 10, 30, 'pending', NULL, NULL, '2026-06-14 21:09:54', '2026-06-14 21:09:54'),
(454, 13, 'Introduction to DevOps // Understand the core principles, culture, and benefits of DevOps. Explore the \'infinity loop\' phases (Plan, Code, Build, Test, Release, Deploy, Operate, Monitor).', 'What is the primary cultural philosophy promoted by DevOps?', 'Collaboration and integration between development and operations teams.', 10, 1, 'completed', '2026-06-15 00:42:07', NULL, '2026-06-15 00:39:28', '2026-06-15 00:42:07'),
(455, 13, 'Linux Command Line Fundamentals // Learn basic Linux commands: navigating directories (ls, cd, pwd), file management (mkdir, rm, cp, mv), and viewing file content (cat, less).', 'Which command is used to display the current working directory in Linux?', 'pwd', 10, 2, 'completed', '2026-06-15 02:30:22', NULL, '2026-06-15 00:39:28', '2026-06-15 02:30:22'),
(456, 13, 'Linux File Permissions & Users // Understand Linux file ownership and permissions (rwx). Learn to use chmod and chown for modifying permissions and ownership.', 'What numeric value represents \'read\' permission for a file in chmod?', '4', 10, 3, 'completed', '2026-06-15 02:35:13', NULL, '2026-06-15 00:39:28', '2026-06-15 02:35:13'),
(457, 13, 'Basic Shell Scripting with Bash // Write simple bash scripts: variables, echo, basic conditionals (if-else), and executing scripts.', 'Which shebang line is commonly used at the beginning of a Bash script?', '#!/bin/bash', 10, 4, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(458, 13, 'Linux Text Processing Tools // Introduction to grep for searching text patterns and sed for stream editing.', 'Which command is used to search for patterns in text files in Linux?', 'grep', 10, 5, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(459, 13, 'Linux Package Management // Learn about package managers (apt for Debian/Ubuntu, yum/dnf for RHEL/CentOS). Practice installing, updating, and removing packages.', 'Which command is used to update the package list on a Debian-based Linux system?', 'sudo apt update', 10, 6, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(460, 13, 'Revision: Linux Fundamentals // Review all Linux commands, scripting basics, and file permissions. Practice scenarios.', 'How do you create a new directory named \'my_project\' in the current directory?', 'mkdir my_project', 10, 7, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(461, 13, 'Introduction to Version Control with Git // Understand what Git is, why it\'s used in DevOps, and the concept of distributed version control.', 'What is the primary purpose of Git?', 'Version control system', 10, 8, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(462, 13, 'Git Basic Commands // Learn to initialize a repository (git init), add files to staging (git add), and commit changes (git commit). View history with git log.', 'Which Git command is used to add changes to the staging area?', 'git add', 10, 9, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(463, 13, 'Git Branching and Merging // Understand the concept of branches. Practice creating, switching (git checkout), and merging branches (git merge).', 'Which Git command is used to create a new branch?', 'git branch [branch_name]', 10, 10, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(464, 13, 'Working with Remote Git Repositories // Learn about remote repositories (e.g., GitHub). Practice cloning (git clone), pushing (git push), and pulling (git pull) changes.', 'Which Git command is used to download a remote repository to your local machine?', 'git clone', 10, 11, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(465, 13, 'Basic Networking Concepts // Understand IP addresses, ports, DNS, and basic network utilities (ping, ifconfig/ip addr).', 'What is the primary function of DNS (Domain Name System)?', 'Translates human-readable domain names into IP addresses.', 10, 12, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(466, 13, 'Secure Shell (SSH) // Learn how SSH works for secure remote access. Practice connecting to a remote server using SSH.', 'What port does SSH typically use for communication?', '22', 10, 13, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(467, 13, 'Revision: Git and Networking // Review Git workflows, branching strategies, and basic networking concepts. Practice Git operations and SSH connections.', 'What command shows the commit history of a Git repository?', 'git log', 10, 14, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(468, 13, 'Introduction to CI/CD // Understand Continuous Integration (CI) and Continuous Delivery/Deployment (CD) concepts and their importance in DevOps.', 'What does CI stand for in CI/CD?', 'Continuous Integration', 10, 15, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(469, 13, 'Introduction to Docker // Learn what containers are and how Docker provides containerization. Understand the difference between containers and VMs.', 'What is the main benefit of using Docker containers?', 'Portability and consistent environments.', 10, 16, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(470, 13, 'Docker Installation and Basic Commands // Install Docker. Practice pulling images (docker pull), running containers (docker run), listing containers (docker ps), and images (docker images).', 'Which Docker command is used to list all running containers?', 'docker ps', 10, 17, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(471, 13, 'Creating Docker Images with Dockerfiles // Learn the structure of a Dockerfile. Write a simple Dockerfile to package a basic application.', 'What is the purpose of the FROM instruction in a Dockerfile?', 'Specifies the base image for the new image.', 10, 18, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(472, 13, 'Docker Compose for Multi-Container Apps // Introduction to Docker Compose for defining and running multi-container Docker applications. Write a simple docker-compose.yml file.', 'What file format is used to define multi-container applications with Docker Compose?', 'YAML', 10, 19, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(473, 13, 'Introduction to Jenkins // Understand what Jenkins is and its role as a popular CI/CD automation server. Explore basic concepts like jobs and pipelines (the idea, not implementation).', 'What is Jenkins primarily used for in a DevOps workflow?', 'Automation of CI/CD pipelines.', 10, 20, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(474, 13, 'Revision: Docker and CI/CD Concepts // Review Docker commands, Dockerfile creation, Docker Compose basics, and the principles of CI/CD. Consider a small project idea combining these.', 'What command would you use to build a Docker image from a Dockerfile in the current directory?', 'docker build .', 10, 21, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(475, 13, 'Introduction to Cloud Computing // Understand the fundamentals of cloud computing (IaaS, PaaS, SaaS). Explore common cloud providers (AWS, Azure, GCP) at a high level.', 'What does IaaS stand for in cloud computing?', 'Infrastructure as a Service', 10, 22, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(476, 13, 'Cloud Service Overview (AWS EC2 Focus) // Dive into a basic service of a major cloud provider, e.g., AWS EC2 (Elastic Compute Cloud) for virtual servers. Understand instances, AMIs, and security groups.', 'What type of computing resource does AWS EC2 provide?', 'Virtual servers (instances)', 10, 23, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(477, 13, 'Introduction to Infrastructure as Code (IaC) // Understand the concept and benefits of managing infrastructure through code (e.g., Terraform, Ansible).', 'What is the main advantage of Infrastructure as Code?', 'Automation, consistency, and versioning of infrastructure.', 10, 24, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(478, 13, 'Introduction to Ansible // Learn what Ansible is (a popular IaC tool for configuration management and orchestration). Understand its agentless architecture and YAML syntax.', 'What is a key characteristic of Ansible\'s architecture that differentiates it from some other configuration management tools?', 'Agentless', 10, 25, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(479, 13, 'Ansible Playbook Basics // Understand the structure of an Ansible Playbook. Write a very simple playbook to install a package on a remote host (conceptual, no execution needed for 60 min).', 'What file format is primarily used for writing Ansible Playbooks?', 'YAML', 10, 26, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(480, 13, 'Monitoring and Logging Concepts // Introduction to the importance of monitoring and logging in DevOps. Brief overview of tools like Prometheus, Grafana, and the ELK stack.', 'What is the primary goal of monitoring in a DevOps environment?', 'To track system performance and health.', 10, 27, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(481, 13, 'Basic Security in DevOps (DevSecOps) // Understand the principles of integrating security practices throughout the entire DevOps lifecycle. Concepts like \'shift left\'.', 'What does \'shift left\' mean in the context of DevSecOps?', 'Integrating security practices earlier in the development lifecycle.', 10, 28, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(482, 13, 'Comprehensive DevOps Tools and Workflow Review // Recap all major tools and concepts covered: Linux, Git, Docker, CI/CD, Cloud, IaC, Monitoring, Security. Understand how they fit together.', 'Which Git command is used to apply changes from one branch onto another?', 'git merge', 10, 29, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28'),
(483, 13, 'Next Steps and Project Ideas // Consolidate learning by identifying potential mini-projects to practice skills. Plan for deeper dives into specific tools or areas of interest. Resources for continuous learning.', 'What is a common tool used for creating container images?', 'Docker', 10, 30, 'pending', NULL, NULL, '2026-06-15 00:39:28', '2026-06-15 00:39:28');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `token_hash` varchar(255) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL COMMENT 'IPv4 or IPv6',
  `user_agent` varchar(512) DEFAULT NULL,
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `revoked_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `streak_freeze_tokens`
--

CREATE TABLE `streak_freeze_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `used_on_date` date DEFAULT NULL COMMENT 'NULL = not yet used',
  `week_number` int(11) NOT NULL,
  `year` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `streak_logs`
--

CREATE TABLE `streak_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `log_date` date NOT NULL,
  `tasks_completed_count` int(11) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 = at least 1 task done',
  `at_risk` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 = tasks not done yet today',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `streak_logs`
--

INSERT INTO `streak_logs` (`id`, `user_id`, `log_date`, `tasks_completed_count`, `is_active`, `at_risk`, `created_at`, `updated_at`) VALUES
(8, 4, '2026-06-15', 3, 1, 0, '2026-06-14 22:18:58', '2026-06-14 23:22:28'),
(9, 3, '2026-06-15', 3, 1, 0, '2026-06-15 00:42:07', '2026-06-15 02:35:13'),
(10, 8, '2026-06-15', 3, 1, 0, '2026-06-15 02:18:34', '2026-06-15 02:34:15');

-- --------------------------------------------------------

--
-- Table structure for table `threads`
--

CREATE TABLE `threads` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `group_id` bigint(20) UNSIGNED NOT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `thread_messages`
--

CREATE TABLE `thread_messages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `thread_id` bigint(20) UNSIGNED NOT NULL,
  `sender_id` bigint(20) UNSIGNED NOT NULL,
  `parent_message_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'For replies',
  `body` text NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `edited_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `full_name` varchar(120) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) DEFAULT NULL COMMENT 'NULL for OAuth-only users',
  `role` varchar(255) DEFAULT NULL,
  `avatar` varchar(500) DEFAULT NULL COMMENT 'Preset key or uploaded URL',
  `bio` text DEFAULT NULL,
  `timezone` varchar(60) NOT NULL DEFAULT 'UTC',
  `profession` varchar(255) DEFAULT NULL,
  `onboarding_completed` tinyint(1) NOT NULL DEFAULT 0,
  `email_verified` tinyint(1) NOT NULL DEFAULT 0,
  `failed_login_attempts` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `lockout_until` timestamp NULL DEFAULT NULL,
  `captcha_required` tinyint(1) NOT NULL DEFAULT 0,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `current_level` int(11) DEFAULT NULL,
  `total_xp` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `full_name`, `email`, `password_hash`, `role`, `avatar`, `bio`, `timezone`, `profession`, `onboarding_completed`, `email_verified`, `failed_login_attempts`, `lockout_until`, `captcha_required`, `deleted_at`, `created_at`, `updated_at`, `current_level`, `total_xp`) VALUES
(1, 'John Doe', 'john@example.com', '$2a$10$wL9jTJQ.5p58IG3Stp4AuOl497.nyXepSSQRKq1GKeFq/k2seg7yW', 'user', 'preset_01', NULL, 'UTC', 'student', 0, 0, 0, NULL, 0, NULL, '2026-06-04 10:22:20', '2026-06-04 10:22:20', 1, 0),
(2, 'Jane Doe', 'jane@example.com', '$2a$10$e.KbZD/0o98p3CGAN/pBSuqdFvdSe5b9FfeH/9WMeM6eUXIWkYS3a', 'user', 'preset_01', NULL, 'UTC', 'student', 0, 0, 0, NULL, 0, NULL, '2026-06-04 10:27:25', '2026-06-14 13:07:48', 1, 0),
(3, 'Admin', 'admin@skillos.com', '$2a$10$wOlvoX47UyWm5mdbYYmkseVCVqJcLvzeH7DnF6yEaQ93cRZBrfn7C', 'admin', 'preset_01', 'Admin Admin', 'UTC', 'self_learner', 0, 0, 0, NULL, 0, NULL, '2026-06-12 13:56:44', '2026-06-15 03:31:56', NULL, NULL),
(4, 'Sami', 'sami@example.com', '$2a$10$XEFJ5LdhadAHnU8e1txhZuxXSqIddQ8jQoi5Lz8/vf.PUMeDWfAZu', 'user', 'preset_01', '....!?', 'UTC', 'self_learner', 0, 0, 0, NULL, 0, NULL, '2026-06-13 05:41:14', '2026-06-14 19:18:50', NULL, NULL),
(5, 'Ruhanyat', 'ruhanyat@example.com', '$2a$10$qsrdhZfN5g.cZ//LXBMYxesBoDucq8fyzkpTuciruKqTrOlbRBX8.', 'user', 'preset_01', NULL, 'UTC', 'student', 0, 0, 0, NULL, 0, NULL, '2026-06-14 16:11:05', '2026-06-14 16:11:05', NULL, NULL),
(6, 'Hasib', 'hasib@example.com', '$2a$10$eT6b0AokG6iDVWn.2x/dVOtfvWm9dHix3/0H5vcEPI5rKB5D4Djd6', 'user', 'preset_01', NULL, 'UTC', 'student', 0, 0, 0, NULL, 0, NULL, '2026-06-14 16:57:02', '2026-06-14 16:57:02', NULL, NULL),
(7, 'Mahmud', 'mahmud@example.com', '$2a$10$x8iIgO3aeqGQpnbW4XRFvuNnBzPANl4yUMe5V5wgZtBpLHMrX/4gC', 'user', 'preset_01', NULL, 'UTC', 'student', 0, 0, 0, NULL, 0, NULL, '2026-06-14 16:57:47', '2026-06-14 16:57:47', NULL, NULL),
(8, 'Arif', 'arif@gmail.com', '$2a$10$Tb3aR/j.dfLJtFyB9/vl5eqkeA5AAbpRU2VZijokrkZKhn7y0dvQK', 'user', 'preset_04', '', 'UTC', 'student', 0, 0, 0, NULL, 0, NULL, '2026-06-14 17:03:39', '2026-06-14 17:11:26', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_achievements`
--

CREATE TABLE `user_achievements` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `achievement_id` bigint(20) UNSIGNED NOT NULL,
  `unlocked_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_achievements`
--

INSERT INTO `user_achievements` (`id`, `user_id`, `achievement_id`, `unlocked_at`, `created_at`, `updated_at`) VALUES
(30, 4, 1, '2026-06-14 18:15:34', '2026-06-14 18:15:34', '2026-06-14 18:15:34'),
(31, 8, 1, '2026-06-14 18:15:45', '2026-06-14 18:15:45', '2026-06-14 18:15:45'),
(32, 4, 7, '2026-06-14 23:22:28', '2026-06-14 23:22:28', '2026-06-14 23:22:28'),
(33, 3, 7, '2026-06-15 00:42:07', '2026-06-15 00:42:07', '2026-06-15 00:42:07'),
(34, 8, 6, '2026-06-15 02:18:34', '2026-06-15 02:18:34', '2026-06-15 02:18:34'),
(35, 8, 7, '2026-06-15 02:18:34', '2026-06-15 02:18:34', '2026-06-15 02:18:34'),
(36, 3, 1, '2026-06-15 03:07:59', '2026-06-15 03:07:59', '2026-06-15 03:07:59');

-- --------------------------------------------------------

--
-- Table structure for table `user_achievement_points`
--

CREATE TABLE `user_achievement_points` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `total_points` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `spent_points` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_achievement_points`
--

INSERT INTO `user_achievement_points` (`id`, `user_id`, `total_points`, `spent_points`, `created_at`, `updated_at`) VALUES
(30, 4, 5100, 500, '2026-06-14 18:15:34', '2026-06-14 23:22:28'),
(31, 8, 210, 0, '2026-06-14 18:15:45', '2026-06-15 02:18:34'),
(32, 3, 110, 0, '2026-06-15 00:42:07', '2026-06-15 03:07:59');

-- --------------------------------------------------------

--
-- Table structure for table `user_preferences`
--

CREATE TABLE `user_preferences` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `theme` enum('system','light','dark') NOT NULL DEFAULT 'system',
  `language` varchar(10) NOT NULL DEFAULT 'en' COMMENT 'ISO 639-1 code',
  `notification_email` tinyint(1) NOT NULL DEFAULT 1,
  `notification_push` tinyint(1) NOT NULL DEFAULT 1,
  `notification_peer_activity` tinyint(1) NOT NULL DEFAULT 1,
  `notification_daily_reminder` tinyint(1) NOT NULL DEFAULT 1,
  `notification_achievement` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_preferences`
--

INSERT INTO `user_preferences` (`id`, `user_id`, `theme`, `language`, `notification_email`, `notification_push`, `notification_peer_activity`, `notification_daily_reminder`, `notification_achievement`, `created_at`, `updated_at`) VALUES
(1, 4, 'light', 'en', 1, 1, 1, 1, 1, '2026-06-13 05:45:32', '2026-06-14 21:05:45'),
(2, 3, 'light', 'en', 1, 1, 1, 1, 1, '2026-06-14 13:07:06', '2026-06-14 13:15:03'),
(3, 5, 'system', 'en', 1, 1, 1, 1, 1, '2026-06-14 16:11:05', '2026-06-14 16:11:05'),
(4, 6, 'system', 'en', 1, 1, 1, 1, 1, '2026-06-14 16:57:02', '2026-06-14 16:57:02'),
(5, 7, 'system', 'en', 1, 1, 1, 1, 1, '2026-06-14 16:57:47', '2026-06-14 16:57:47'),
(6, 8, 'light', 'en', 1, 1, 1, 1, 1, '2026-06-14 17:03:39', '2026-06-14 19:14:02');

-- --------------------------------------------------------

--
-- Table structure for table `user_reward_purchases`
--

CREATE TABLE `user_reward_purchases` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `item_id` bigint(20) UNSIGNED NOT NULL,
  `points_spent` int(10) UNSIGNED NOT NULL,
  `expires_at` timestamp NULL DEFAULT NULL COMMENT 'NULL = permanent',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `purchased_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_reward_purchases`
--

INSERT INTO `user_reward_purchases` (`id`, `user_id`, `item_id`, `points_spent`, `expires_at`, `is_active`, `purchased_at`, `created_at`, `updated_at`) VALUES
(1, 4, 1, 500, NULL, 1, '2026-06-14 20:02:48', '2026-06-14 20:02:48', '2026-06-14 20:02:48');

-- --------------------------------------------------------

--
-- Table structure for table `user_stats`
--

CREATE TABLE `user_stats` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `current_streak` int(11) NOT NULL,
  `longest_streak` int(11) NOT NULL,
  `total_active_days` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `global_rank` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_stats`
--

INSERT INTO `user_stats` (`id`, `user_id`, `current_streak`, `longest_streak`, `total_active_days`, `global_rank`, `created_at`, `updated_at`) VALUES
(1, 4, 1, 1, 1, NULL, '2026-06-14 22:18:58', '2026-06-14 22:18:58'),
(2, 3, 1, 1, 1, NULL, '2026-06-15 00:42:07', '2026-06-15 00:42:07'),
(3, 8, 1, 1, 1, NULL, '2026-06-15 02:18:34', '2026-06-15 02:18:34');

-- --------------------------------------------------------

--
-- Table structure for table `user_study_timer`
--

CREATE TABLE `user_study_timer` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `timer_date` date NOT NULL,
  `elapsed_seconds` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `timer_status` enum('idle','running','paused') NOT NULL DEFAULT 'idle',
  `last_started_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_study_timer`
--

INSERT INTO `user_study_timer` (`id`, `user_id`, `timer_date`, `elapsed_seconds`, `timer_status`, `last_started_at`, `created_at`, `updated_at`) VALUES
(1, 2, '2026-06-05', 124, 'paused', NULL, '2026-06-05 11:28:19', '2026-06-05 11:30:23'),
(2, 4, '2026-06-13', 1843, 'paused', NULL, '2026-06-13 06:23:02', '2026-06-13 12:09:46'),
(3, 4, '2026-06-14', 8400, 'paused', NULL, '2026-06-14 12:49:22', '2026-06-14 15:55:47'),
(4, 3, '2026-06-14', 909, 'paused', NULL, '2026-06-14 13:07:06', '2026-06-14 13:30:06'),
(5, 5, '2026-06-14', 0, 'idle', NULL, '2026-06-14 16:11:05', '2026-06-14 16:11:05'),
(6, 6, '2026-06-14', 0, 'idle', NULL, '2026-06-14 16:57:02', '2026-06-14 16:57:02'),
(7, 7, '2026-06-14', 0, 'idle', NULL, '2026-06-14 16:57:47', '2026-06-14 16:57:47'),
(8, 8, '2026-06-14', 3, 'paused', NULL, '2026-06-14 17:03:39', '2026-06-14 17:04:51'),
(9, 8, '2026-06-15', 2478, 'paused', NULL, '2026-06-14 18:02:12', '2026-06-15 02:21:11'),
(10, 4, '2026-06-15', 2712, 'paused', NULL, '2026-06-14 18:04:27', '2026-06-14 21:50:49'),
(11, 7, '2026-06-15', 0, 'idle', NULL, '2026-06-14 20:41:04', '2026-06-14 20:41:04'),
(12, 3, '2026-06-15', 3, 'paused', NULL, '2026-06-15 00:18:39', '2026-06-15 05:11:59');

-- --------------------------------------------------------

--
-- Table structure for table `user_xp`
--

CREATE TABLE `user_xp` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `total_xp` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `current_level` smallint(5) UNSIGNED NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_xp`
--

INSERT INTO `user_xp` (`id`, `user_id`, `total_xp`, `current_level`, `created_at`, `updated_at`) VALUES
(1, 2, 8, 1, '2026-06-12 11:34:11', '2026-06-12 11:34:11'),
(43, 4, 330, 3, '2026-06-14 18:15:34', '2026-06-14 23:22:28'),
(44, 8, 1180, 5, '2026-06-14 18:15:45', '2026-06-15 02:34:15'),
(45, 3, 328, 3, '2026-06-15 00:42:07', '2026-06-15 05:06:41');

-- --------------------------------------------------------

--
-- Table structure for table `weekly_goals`
--

CREATE TABLE `weekly_goals` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `week_number` int(11) NOT NULL,
  `year` int(11) NOT NULL,
  `goal_text` text NOT NULL,
  `status` enum('hit','missed','partial') DEFAULT NULL COMMENT 'NULL = week not yet over',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `weekly_leaderboard_snapshots`
--

CREATE TABLE `weekly_leaderboard_snapshots` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `week_number` int(11) NOT NULL,
  `year` int(11) NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `xp_gained` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `user_rank` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `weekly_reviews`
--

CREATE TABLE `weekly_reviews` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `week_number` int(11) NOT NULL,
  `year` int(11) NOT NULL,
  `tasks_done` int(11) NOT NULL,
  `xp_earned` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `streak_days` int(11) NOT NULL,
  `hours_studied` decimal(6,2) NOT NULL DEFAULT 0.00,
  `score` int(11) NOT NULL,
  `ai_insight_text` text DEFAULT NULL,
  `peer_comparison_percent` decimal(6,2) DEFAULT NULL COMMENT 'Positive = above average',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `xp_logs`
--

CREATE TABLE `xp_logs` (
  `id` bigint(20) NOT NULL,
  `awarded_at` datetime(6) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `source_id` bigint(20) DEFAULT NULL,
  `source_type` varchar(255) DEFAULT NULL,
  `xp_amount` int(11) NOT NULL,
  `user_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `xp_transactions`
--

CREATE TABLE `xp_transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `source_type` enum('task','milestone','streak_bonus','note','flashcard_add','flashcard_review','achievement','project_task','achievement_unlocked') NOT NULL,
  `source_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'FK to the source row (task_id, milestone_id, etc.)',
  `xp_amount` int(11) NOT NULL,
  `awarded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `xp_transactions`
--

INSERT INTO `xp_transactions` (`id`, `user_id`, `source_type`, `source_id`, `xp_amount`, `awarded_at`, `created_at`, `updated_at`) VALUES
(4, 2, 'project_task', 1, 8, '2026-06-12 11:34:11', '2026-06-12 11:34:11', '2026-06-12 11:34:11'),
(46, 4, 'project_task', 28, 10, '2026-06-14 18:15:34', '2026-06-14 18:15:34', '2026-06-14 18:15:34'),
(47, 4, 'achievement_unlocked', 30, 50, '2026-06-14 18:15:34', '2026-06-14 18:15:34', '2026-06-14 18:15:34'),
(48, 8, 'project_task', 52, 5, '2026-06-14 18:15:45', '2026-06-14 18:15:45', '2026-06-14 18:15:45'),
(49, 8, 'achievement_unlocked', 31, 50, '2026-06-14 18:15:45', '2026-06-14 18:15:45', '2026-06-14 18:15:45'),
(50, 8, 'project_task', 50, 10, '2026-06-14 18:15:49', '2026-06-14 18:15:49', '2026-06-14 18:15:49'),
(51, 8, 'project_task', 54, 18, '2026-06-14 18:16:00', '2026-06-14 18:16:00', '2026-06-14 18:16:00'),
(52, 8, 'project_task', 51, 8, '2026-06-14 18:19:58', '2026-06-14 18:19:58', '2026-06-14 18:19:58'),
(53, 8, 'project_task', 53, 15, '2026-06-14 18:20:00', '2026-06-14 18:20:00', '2026-06-14 18:20:00'),
(54, 8, 'project_task', 55, 20, '2026-06-14 18:20:02', '2026-06-14 18:20:02', '2026-06-14 18:20:02'),
(55, 8, 'project_task', 56, 20, '2026-06-14 18:20:10', '2026-06-14 18:20:10', '2026-06-14 18:20:10'),
(56, 8, 'project_task', 57, 15, '2026-06-14 18:26:40', '2026-06-14 18:26:40', '2026-06-14 18:26:40'),
(57, 8, 'project_task', 58, 10, '2026-06-14 18:26:43', '2026-06-14 18:26:43', '2026-06-14 18:26:43'),
(58, 8, 'project_task', 59, 15, '2026-06-14 18:26:49', '2026-06-14 18:26:49', '2026-06-14 18:26:49'),
(59, 8, 'project_task', 60, 20, '2026-06-14 18:26:53', '2026-06-14 18:26:53', '2026-06-14 18:26:53'),
(60, 8, 'project_task', 61, 15, '2026-06-14 18:26:55', '2026-06-14 18:26:55', '2026-06-14 18:26:55'),
(61, 8, 'project_task', 62, 15, '2026-06-14 18:27:01', '2026-06-14 18:27:01', '2026-06-14 18:27:01'),
(62, 8, 'project_task', 63, 20, '2026-06-14 18:27:03', '2026-06-14 18:27:03', '2026-06-14 18:27:03'),
(63, 8, 'project_task', 64, 18, '2026-06-14 18:27:06', '2026-06-14 18:27:06', '2026-06-14 18:27:06'),
(64, 8, 'project_task', 65, 12, '2026-06-14 18:27:08', '2026-06-14 18:27:08', '2026-06-14 18:27:08'),
(65, 8, 'project_task', 66, 10, '2026-06-14 18:27:10', '2026-06-14 18:27:10', '2026-06-14 18:27:10'),
(66, 8, 'project_task', 67, 18, '2026-06-14 18:27:12', '2026-06-14 18:27:12', '2026-06-14 18:27:12'),
(67, 8, 'project_task', 68, 15, '2026-06-14 18:27:16', '2026-06-14 18:27:16', '2026-06-14 18:27:16'),
(68, 8, 'project_task', 70, 15, '2026-06-14 18:27:21', '2026-06-14 18:27:21', '2026-06-14 18:27:21'),
(69, 8, 'project_task', 69, 15, '2026-06-14 18:27:24', '2026-06-14 18:27:24', '2026-06-14 18:27:24'),
(70, 8, 'project_task', 71, 18, '2026-06-14 18:29:06', '2026-06-14 18:29:06', '2026-06-14 18:29:06'),
(71, 8, 'project_task', 72, 10, '2026-06-14 18:29:10', '2026-06-14 18:29:10', '2026-06-14 18:29:10'),
(72, 8, 'project_task', 73, 12, '2026-06-14 18:29:12', '2026-06-14 18:29:12', '2026-06-14 18:29:12'),
(73, 8, 'project_task', 74, 10, '2026-06-14 18:29:16', '2026-06-14 18:29:16', '2026-06-14 18:29:16'),
(74, 8, 'project_task', 75, 15, '2026-06-14 18:29:19', '2026-06-14 18:29:19', '2026-06-14 18:29:19'),
(75, 8, 'project_task', 76, 18, '2026-06-14 18:29:22', '2026-06-14 18:29:22', '2026-06-14 18:29:22'),
(76, 8, 'project_task', 77, 8, '2026-06-14 18:29:29', '2026-06-14 18:29:29', '2026-06-14 18:29:29'),
(77, 4, 'project_task', 78, 10, '2026-06-14 19:20:45', '2026-06-14 19:20:45', '2026-06-14 19:20:45'),
(78, 4, 'project_task', 79, 10, '2026-06-14 19:21:01', '2026-06-14 19:21:01', '2026-06-14 19:21:01'),
(79, 4, 'project_task', 80, 10, '2026-06-14 19:21:19', '2026-06-14 19:21:19', '2026-06-14 19:21:19'),
(80, 4, 'project_task', 81, 10, '2026-06-14 19:21:32', '2026-06-14 19:21:32', '2026-06-14 19:21:32'),
(86, 4, 'task', 244, 10, '2026-06-14 22:18:58', '2026-06-14 22:18:58', '2026-06-14 22:18:58'),
(87, 4, 'task', 245, 10, '2026-06-14 22:19:47', '2026-06-14 22:19:47', '2026-06-14 22:19:47'),
(88, 4, 'task', 274, 10, '2026-06-14 23:22:28', '2026-06-14 23:22:28', '2026-06-14 23:22:28'),
(89, 4, 'achievement_unlocked', 32, 200, '2026-06-14 23:22:28', '2026-06-14 23:22:28', '2026-06-14 23:22:28'),
(90, 3, 'task', 454, 10, '2026-06-15 00:42:07', '2026-06-15 00:42:07', '2026-06-15 00:42:07'),
(91, 3, 'achievement_unlocked', 33, 200, '2026-06-15 00:42:07', '2026-06-15 00:42:07', '2026-06-15 00:42:07'),
(92, 8, 'task', 424, 10, '2026-06-15 02:18:34', '2026-06-15 02:18:34', '2026-06-15 02:18:34'),
(93, 8, 'achievement_unlocked', 34, 500, '2026-06-15 02:18:34', '2026-06-15 02:18:34', '2026-06-15 02:18:34'),
(94, 8, 'achievement_unlocked', 35, 200, '2026-06-15 02:18:34', '2026-06-15 02:18:34', '2026-06-15 02:18:34'),
(95, 8, 'task', 425, 10, '2026-06-15 02:20:31', '2026-06-15 02:20:31', '2026-06-15 02:20:31'),
(96, 3, 'task', 455, 10, '2026-06-15 02:30:22', '2026-06-15 02:30:22', '2026-06-15 02:30:22'),
(97, 8, 'task', 426, 10, '2026-06-15 02:34:15', '2026-06-15 02:34:15', '2026-06-15 02:34:15'),
(98, 3, 'task', 456, 10, '2026-06-15 02:35:13', '2026-06-15 02:35:13', '2026-06-15 02:35:13'),
(99, 3, 'project_task', 95, 10, '2026-06-15 03:07:59', '2026-06-15 03:07:59', '2026-06-15 03:07:59'),
(100, 3, 'achievement_unlocked', 36, 50, '2026-06-15 03:07:59', '2026-06-15 03:07:59', '2026-06-15 03:07:59'),
(101, 3, 'task', 1, 15, '2026-06-15 04:09:07', '2026-06-15 04:09:07', '2026-06-15 04:09:07'),
(102, 3, 'project_task', 96, 8, '2026-06-15 04:09:30', '2026-06-15 04:09:30', '2026-06-15 04:09:30'),
(103, 3, 'project_task', 97, 15, '2026-06-15 05:06:41', '2026-06-15 05:06:41', '2026-06-15 05:06:41');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `achievement_definitions`
--
ALTER TABLE `achievement_definitions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ai_hub_interactions`
--
ALTER TABLE `ai_hub_interactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_ahi_user_id` (`user_id`),
  ADD KEY `idx_ahi_conversation` (`conversation_id`);

--
-- Indexes for table `ai_hub_logs`
--
ALTER TABLE `ai_hub_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_al_user_id` (`user_id`),
  ADD KEY `idx_al_action` (`action`),
  ADD KEY `idx_al_entity` (`entity_type`,`entity_id`);

--
-- Indexes for table `blacklisted_websites`
--
ALTER TABLE `blacklisted_websites`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_bw_domain` (`domain`),
  ADD KEY `fk_bw_admin` (`added_by`);

--
-- Indexes for table `custom_tasks`
--
ALTER TABLE `custom_tasks`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `daily_tasks`
--
ALTER TABLE `daily_tasks`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_daily_task_user_task_date` (`user_id`,`task_id`,`scheduled_date`),
  ADD KEY `idx_dt_user_date` (`user_id`,`scheduled_date`),
  ADD KEY `idx_dt_roadmap_id` (`roadmap_id`),
  ADD KEY `idx_dt_status` (`status`),
  ADD KEY `fk_dt_task` (`task_id`);

--
-- Indexes for table `direct_messages`
--
ALTER TABLE `direct_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_dm_sender` (`sender_id`),
  ADD KEY `idx_dm_receiver` (`receiver_id`),
  ADD KEY `idx_dm_convo` (`sender_id`,`receiver_id`);

--
-- Indexes for table `flashcards`
--
ALTER TABLE `flashcards`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_fc_user_id` (`user_id`),
  ADD KEY `idx_fc_skill` (`user_id`,`skill_name`),
  ADD KEY `idx_fc_difficulty` (`user_id`,`difficulty`),
  ADD KEY `fk_fc_roadmap` (`roadmap_id`);

--
-- Indexes for table `flashcard_batches`
--
ALTER TABLE `flashcard_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `flashcard_reviews`
--
ALTER TABLE `flashcard_reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_fcr_flashcard_id` (`flashcard_id`),
  ADD KEY `idx_fcr_user_id` (`user_id`);

--
-- Indexes for table `gantt_entries`
--
ALTER TABLE `gantt_entries`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_ge_project_id` (`project_id`);

--
-- Indexes for table `generation_jobs`
--
ALTER TABLE `generation_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_gj_job_id` (`job_id`),
  ADD KEY `idx_gj_user_id` (`user_id`),
  ADD KEY `idx_gj_status` (`status`),
  ADD KEY `idx_gj_job_type` (`job_type`);

--
-- Indexes for table `global_rankings`
--
ALTER TABLE `global_rankings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_gr_user` (`user_id`),
  ADD KEY `idx_gr_rank` (`global_rank`);

--
-- Indexes for table `kanban_boards`
--
ALTER TABLE `kanban_boards`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_kb_user_id` (`user_id`),
  ADD KEY `idx_kb_project_id` (`project_id`),
  ADD KEY `fk_kb_roadmap` (`roadmap_id`);

--
-- Indexes for table `kanban_cards`
--
ALTER TABLE `kanban_cards`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_kkc_column_id` (`column_id`),
  ADD KEY `idx_kkc_task_id` (`task_id`),
  ADD KEY `idx_kkc_project_task_id` (`project_task_id`),
  ADD KEY `idx_kkc_deleted_at` (`deleted_at`);

--
-- Indexes for table `kanban_columns`
--
ALTER TABLE `kanban_columns`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_kc_board_id` (`board_id`);

--
-- Indexes for table `levels`
--
ALTER TABLE `levels`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_level_number` (`level_number`),
  ADD KEY `idx_levels_xp` (`xp_required`);

--
-- Indexes for table `message_reactions`
--
ALTER TABLE `message_reactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_reaction_user_msg_emoji` (`message_id`,`user_id`,`reaction_emoji`),
  ADD KEY `idx_mr_user_id` (`user_id`);

--
-- Indexes for table `notes`
--
ALTER TABLE `notes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notes_user_id` (`user_id`),
  ADD KEY `idx_notes_roadmap_day` (`roadmap_id`,`day_number`),
  ADD KEY `idx_notes_flashcard_gen` (`user_id`,`used_for_flashcard_gen`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notif_user_id` (`user_id`),
  ADD KEY `idx_notif_is_read` (`user_id`,`is_read`),
  ADD KEY `idx_notif_created_at` (`user_id`,`created_at`);

--
-- Indexes for table `onboarding_progress`
--
ALTER TABLE `onboarding_progress`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_onboarding_user` (`user_id`);

--
-- Indexes for table `peers`
--
ALTER TABLE `peers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_peer_pair` (`user_id_a`,`user_id_b`),
  ADD KEY `idx_peers_user_b` (`user_id_b`);

--
-- Indexes for table `peer_groups`
--
ALTER TABLE `peer_groups`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `peer_group_members`
--
ALTER TABLE `peer_group_members`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pgm_group_user` (`group_id`,`user_id`),
  ADD KEY `idx_pgm_user_id` (`user_id`);

--
-- Indexes for table `peer_requests`
--
ALTER TABLE `peer_requests`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_peer_request` (`sender_id`,`receiver_id`),
  ADD KEY `idx_pr_receiver_id` (`receiver_id`);

--
-- Indexes for table `projects`
--
ALTER TABLE `projects`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_projects_user_id` (`user_id`),
  ADD KEY `idx_projects_status` (`status`),
  ADD KEY `idx_projects_deleted_at` (`deleted_at`);

--
-- Indexes for table `project_tasks`
--
ALTER TABLE `project_tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pt_project_id` (`project_id`),
  ADD KEY `fk_pt_gantt` (`gantt_entry_id`),
  ADD KEY `idx_pt_deleted_at` (`deleted_at`);

--
-- Indexes for table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UK_ghpmfn23vmxfu3spu3lfg4r2d` (`token`);

--
-- Indexes for table `reward_store_items`
--
ALTER TABLE `reward_store_items`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `roadmaps`
--
ALTER TABLE `roadmaps`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_roadmaps_user_id` (`user_id`),
  ADD KEY `idx_roadmaps_status` (`status`),
  ADD KEY `idx_roadmaps_deleted_at` (`deleted_at`);

--
-- Indexes for table `roadmap_tasks`
--
ALTER TABLE `roadmap_tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tasks_roadmap_id` (`roadmap_id`),
  ADD KEY `idx_tasks_day_number` (`roadmap_id`,`day_number`),
  ADD KEY `idx_tasks_status` (`status`),
  ADD KEY `idx_tasks_deleted_at` (`deleted_at`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_sessions_user_id` (`user_id`),
  ADD KEY `idx_sessions_token` (`token_hash`),
  ADD KEY `idx_sessions_expires` (`expires_at`);

--
-- Indexes for table `streak_freeze_tokens`
--
ALTER TABLE `streak_freeze_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_freeze_user_week` (`user_id`,`week_number`,`year`),
  ADD KEY `idx_sft_user_id` (`user_id`);

--
-- Indexes for table `streak_logs`
--
ALTER TABLE `streak_logs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_streak_user_date` (`user_id`,`log_date`),
  ADD KEY `idx_sl_user_id` (`user_id`),
  ADD KEY `idx_sl_log_date` (`log_date`);

--
-- Indexes for table `threads`
--
ALTER TABLE `threads`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_threads_group_id` (`group_id`),
  ADD KEY `fk_threads_author` (`created_by`);

--
-- Indexes for table `thread_messages`
--
ALTER TABLE `thread_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tm_thread_id` (`thread_id`),
  ADD KEY `idx_tm_sender_id` (`sender_id`),
  ADD KEY `idx_tm_parent` (`parent_message_id`),
  ADD KEY `idx_tm_deleted_at` (`deleted_at`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_users_email` (`email`),
  ADD KEY `idx_users_deleted_at` (`deleted_at`);

--
-- Indexes for table `user_achievements`
--
ALTER TABLE `user_achievements`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_ua_user_achievement` (`user_id`,`achievement_id`),
  ADD KEY `idx_ua_user_id` (`user_id`),
  ADD KEY `fk_ua_achievement` (`achievement_id`);

--
-- Indexes for table `user_achievement_points`
--
ALTER TABLE `user_achievement_points`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_uap_user` (`user_id`);

--
-- Indexes for table `user_preferences`
--
ALTER TABLE `user_preferences`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_up_user` (`user_id`);

--
-- Indexes for table `user_reward_purchases`
--
ALTER TABLE `user_reward_purchases`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_urp_user_id` (`user_id`),
  ADD KEY `idx_urp_item_id` (`item_id`);

--
-- Indexes for table `user_stats`
--
ALTER TABLE `user_stats`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_stats_user` (`user_id`);

--
-- Indexes for table `user_study_timer`
--
ALTER TABLE `user_study_timer`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_timer_user_date` (`user_id`,`timer_date`);

--
-- Indexes for table `user_xp`
--
ALTER TABLE `user_xp`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_user_xp` (`user_id`),
  ADD KEY `fk_uxp_level` (`current_level`);

--
-- Indexes for table `weekly_goals`
--
ALTER TABLE `weekly_goals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_wg_user_week` (`user_id`,`week_number`,`year`);

--
-- Indexes for table `weekly_leaderboard_snapshots`
--
ALTER TABLE `weekly_leaderboard_snapshots`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_wls_week_user` (`week_number`,`year`,`user_id`),
  ADD KEY `idx_wls_week_year` (`week_number`,`year`),
  ADD KEY `idx_wls_user_id` (`user_id`);

--
-- Indexes for table `weekly_reviews`
--
ALTER TABLE `weekly_reviews`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_wr_user_week` (`user_id`,`week_number`,`year`),
  ADD KEY `idx_wr_week_year` (`week_number`,`year`);

--
-- Indexes for table `xp_logs`
--
ALTER TABLE `xp_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `xp_transactions`
--
ALTER TABLE `xp_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_xp_user_id` (`user_id`),
  ADD KEY `idx_xp_awarded_at` (`user_id`,`awarded_at`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `achievement_definitions`
--
ALTER TABLE `achievement_definitions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `ai_hub_interactions`
--
ALTER TABLE `ai_hub_interactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ai_hub_logs`
--
ALTER TABLE `ai_hub_logs`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `blacklisted_websites`
--
ALTER TABLE `blacklisted_websites`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `custom_tasks`
--
ALTER TABLE `custom_tasks`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `daily_tasks`
--
ALTER TABLE `daily_tasks`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `direct_messages`
--
ALTER TABLE `direct_messages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `flashcards`
--
ALTER TABLE `flashcards`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `flashcard_batches`
--
ALTER TABLE `flashcard_batches`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `flashcard_reviews`
--
ALTER TABLE `flashcard_reviews`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `gantt_entries`
--
ALTER TABLE `gantt_entries`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `generation_jobs`
--
ALTER TABLE `generation_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `global_rankings`
--
ALTER TABLE `global_rankings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `kanban_boards`
--
ALTER TABLE `kanban_boards`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `kanban_cards`
--
ALTER TABLE `kanban_cards`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=114;

--
-- AUTO_INCREMENT for table `kanban_columns`
--
ALTER TABLE `kanban_columns`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `levels`
--
ALTER TABLE `levels`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `message_reactions`
--
ALTER TABLE `message_reactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notes`
--
ALTER TABLE `notes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT for table `onboarding_progress`
--
ALTER TABLE `onboarding_progress`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `peers`
--
ALTER TABLE `peers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `peer_groups`
--
ALTER TABLE `peer_groups`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `peer_group_members`
--
ALTER TABLE `peer_group_members`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `peer_requests`
--
ALTER TABLE `peer_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `projects`
--
ALTER TABLE `projects`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `project_tasks`
--
ALTER TABLE `project_tasks`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=114;

--
-- AUTO_INCREMENT for table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reward_store_items`
--
ALTER TABLE `reward_store_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `roadmaps`
--
ALTER TABLE `roadmaps`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `roadmap_tasks`
--
ALTER TABLE `roadmap_tasks`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=484;

--
-- AUTO_INCREMENT for table `sessions`
--
ALTER TABLE `sessions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `streak_freeze_tokens`
--
ALTER TABLE `streak_freeze_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `streak_logs`
--
ALTER TABLE `streak_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `threads`
--
ALTER TABLE `threads`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `thread_messages`
--
ALTER TABLE `thread_messages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `user_achievements`
--
ALTER TABLE `user_achievements`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `user_achievement_points`
--
ALTER TABLE `user_achievement_points`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `user_preferences`
--
ALTER TABLE `user_preferences`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `user_reward_purchases`
--
ALTER TABLE `user_reward_purchases`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `user_stats`
--
ALTER TABLE `user_stats`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `user_study_timer`
--
ALTER TABLE `user_study_timer`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `user_xp`
--
ALTER TABLE `user_xp`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

--
-- AUTO_INCREMENT for table `weekly_goals`
--
ALTER TABLE `weekly_goals`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `weekly_leaderboard_snapshots`
--
ALTER TABLE `weekly_leaderboard_snapshots`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `weekly_reviews`
--
ALTER TABLE `weekly_reviews`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `xp_logs`
--
ALTER TABLE `xp_logs`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `xp_transactions`
--
ALTER TABLE `xp_transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=104;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `ai_hub_interactions`
--
ALTER TABLE `ai_hub_interactions`
  ADD CONSTRAINT `fk_ahi_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `fk_al_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `blacklisted_websites`
--
ALTER TABLE `blacklisted_websites`
  ADD CONSTRAINT `fk_bw_admin` FOREIGN KEY (`added_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `daily_tasks`
--
ALTER TABLE `daily_tasks`
  ADD CONSTRAINT `fk_dt_roadmap` FOREIGN KEY (`roadmap_id`) REFERENCES `roadmaps` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_dt_task` FOREIGN KEY (`task_id`) REFERENCES `roadmap_tasks` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_dt_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `direct_messages`
--
ALTER TABLE `direct_messages`
  ADD CONSTRAINT `fk_dm_receiver` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_dm_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `flashcards`
--
ALTER TABLE `flashcards`
  ADD CONSTRAINT `fk_fc_roadmap` FOREIGN KEY (`roadmap_id`) REFERENCES `roadmaps` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_fc_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `flashcard_reviews`
--
ALTER TABLE `flashcard_reviews`
  ADD CONSTRAINT `fk_fcr_flashcard` FOREIGN KEY (`flashcard_id`) REFERENCES `flashcards` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_fcr_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `gantt_entries`
--
ALTER TABLE `gantt_entries`
  ADD CONSTRAINT `fk_ge_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `generation_jobs`
--
ALTER TABLE `generation_jobs`
  ADD CONSTRAINT `fk_gj_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `global_rankings`
--
ALTER TABLE `global_rankings`
  ADD CONSTRAINT `fk_gr_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `kanban_boards`
--
ALTER TABLE `kanban_boards`
  ADD CONSTRAINT `fk_kb_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_kb_roadmap` FOREIGN KEY (`roadmap_id`) REFERENCES `roadmaps` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_kb_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `kanban_cards`
--
ALTER TABLE `kanban_cards`
  ADD CONSTRAINT `fk_kkc_column` FOREIGN KEY (`column_id`) REFERENCES `kanban_columns` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_kkc_project_task` FOREIGN KEY (`project_task_id`) REFERENCES `project_tasks` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_kkc_roadmap_task` FOREIGN KEY (`task_id`) REFERENCES `roadmap_tasks` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `kanban_columns`
--
ALTER TABLE `kanban_columns`
  ADD CONSTRAINT `fk_kc_board` FOREIGN KEY (`board_id`) REFERENCES `kanban_boards` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `message_reactions`
--
ALTER TABLE `message_reactions`
  ADD CONSTRAINT `fk_mr_message` FOREIGN KEY (`message_id`) REFERENCES `thread_messages` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_mr_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notes`
--
ALTER TABLE `notes`
  ADD CONSTRAINT `fk_notes_roadmap` FOREIGN KEY (`roadmap_id`) REFERENCES `roadmaps` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_notes_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_notif_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `onboarding_progress`
--
ALTER TABLE `onboarding_progress`
  ADD CONSTRAINT `fk_onboarding_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `peers`
--
ALTER TABLE `peers`
  ADD CONSTRAINT `fk_peers_a` FOREIGN KEY (`user_id_a`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_peers_b` FOREIGN KEY (`user_id_b`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `peer_group_members`
--
ALTER TABLE `peer_group_members`
  ADD CONSTRAINT `fk_pgm_group` FOREIGN KEY (`group_id`) REFERENCES `peer_groups` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_pgm_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `peer_requests`
--
ALTER TABLE `peer_requests`
  ADD CONSTRAINT `fk_pr_receiver` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_pr_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `projects`
--
ALTER TABLE `projects`
  ADD CONSTRAINT `fk_projects_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `project_tasks`
--
ALTER TABLE `project_tasks`
  ADD CONSTRAINT `fk_pt_gantt` FOREIGN KEY (`gantt_entry_id`) REFERENCES `gantt_entries` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_pt_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `roadmaps`
--
ALTER TABLE `roadmaps`
  ADD CONSTRAINT `fk_roadmaps_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `roadmap_tasks`
--
ALTER TABLE `roadmap_tasks`
  ADD CONSTRAINT `fk_tasks_roadmap` FOREIGN KEY (`roadmap_id`) REFERENCES `roadmaps` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `sessions`
--
ALTER TABLE `sessions`
  ADD CONSTRAINT `fk_sessions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `streak_freeze_tokens`
--
ALTER TABLE `streak_freeze_tokens`
  ADD CONSTRAINT `fk_sft_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `streak_logs`
--
ALTER TABLE `streak_logs`
  ADD CONSTRAINT `fk_sl_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `threads`
--
ALTER TABLE `threads`
  ADD CONSTRAINT `fk_threads_author` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_threads_group` FOREIGN KEY (`group_id`) REFERENCES `peer_groups` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `thread_messages`
--
ALTER TABLE `thread_messages`
  ADD CONSTRAINT `fk_tm_parent` FOREIGN KEY (`parent_message_id`) REFERENCES `thread_messages` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tm_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tm_thread` FOREIGN KEY (`thread_id`) REFERENCES `threads` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_achievements`
--
ALTER TABLE `user_achievements`
  ADD CONSTRAINT `fk_ua_achievement` FOREIGN KEY (`achievement_id`) REFERENCES `achievement_definitions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ua_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_achievement_points`
--
ALTER TABLE `user_achievement_points`
  ADD CONSTRAINT `fk_uap_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_preferences`
--
ALTER TABLE `user_preferences`
  ADD CONSTRAINT `fk_up_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_reward_purchases`
--
ALTER TABLE `user_reward_purchases`
  ADD CONSTRAINT `fk_urp_item` FOREIGN KEY (`item_id`) REFERENCES `reward_store_items` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_urp_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_stats`
--
ALTER TABLE `user_stats`
  ADD CONSTRAINT `fk_stats_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_study_timer`
--
ALTER TABLE `user_study_timer`
  ADD CONSTRAINT `fk_timer_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_xp`
--
ALTER TABLE `user_xp`
  ADD CONSTRAINT `fk_uxp_level` FOREIGN KEY (`current_level`) REFERENCES `levels` (`level_number`),
  ADD CONSTRAINT `fk_uxp_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `weekly_goals`
--
ALTER TABLE `weekly_goals`
  ADD CONSTRAINT `fk_wg_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `weekly_leaderboard_snapshots`
--
ALTER TABLE `weekly_leaderboard_snapshots`
  ADD CONSTRAINT `fk_wls_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `weekly_reviews`
--
ALTER TABLE `weekly_reviews`
  ADD CONSTRAINT `fk_wr_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `xp_transactions`
--
ALTER TABLE `xp_transactions`
  ADD CONSTRAINT `fk_xp_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
