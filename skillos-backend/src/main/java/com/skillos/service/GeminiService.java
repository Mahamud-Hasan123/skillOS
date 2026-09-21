package com.skillos.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class GeminiService {

  private final RestTemplate restTemplate;
  private final ObjectMapper objectMapper;

  @Value("${application.gemini.api-key}")
  private String apiKey;

  @Value("${application.gemini.model}")
  private String model;

  // Roadmap generation using Gemini
  public String generateRoadmapJson(String skillGoal, int dailyTimeMin, int durationMonths, String level,
      List<String> focusAreas) {
    String url = "https://generativelanguage.googleapis.com/v1beta/models/" + model + ":generateContent"; // was
                                                                                                          // ":generateContent?key="+apiKey

    int totalDays = durationMonths * 30;

    // Api bypassing, will change it after valid api key

    // if (apiKey.startsWith("AQ.") || apiKey.startsWith("Api_key")) {
    // return """
    // {
    // "title": "Master %s in %d Days (MOCKED)",
    // "skill_goal": "%s",
    // "level": "%s",
    // "total_days": %d,
    // "tasks": [
    // {
    // "day_number": 1,
    // "title": "Introduction to %s",
    // "question": "What is the main purpose of this skill?",
    // "answer": "To build awesome projects."
    // },
    // {
    // "day_number": 2,
    // "title": "Core Concepts",
    // "question": "Name one core concept.",
    // "answer": "Fundamentals."
    // }
    // ]
    // }
    // """.formatted(skillGoal, totalDays, skillGoal, level, totalDays, skillGoal);
    // }
    // Will replace with custom prompt--(whatsapp)

    // Roadmap Prompt
    String prompt = String.format(
        "You are an expert AI Learning Roadmap Generator specialized in:\n" +
            "1.Personalized education planning\n" +
            "2.Skill progression design\n" +
            "3.Curriculum engineering\n" +
            "4.Beginner-to-advanced learning paths\n" +
            "5.Career-focused roadmap creation\n" +
            "6.Time-constrained learning optimization\n" +
            "Your task is to generate a STRICT JSON roadmap for the user." +
            "The roadmap must:\n" +
            "\n" +
            "Be personalized\n" +
            "Match the user's experience level\n" +
            "Match the user's available daily study time\n" +
            "Match the user's goal\n" +
            "Fit EXACTLY within the given deadline\n" +
            "Progress logically from beginner → advanced\n" +
            "Be realistic and achievable\n" +
            "Avoid repetition\n" +
            "Keep tasks appropriately sized for the daily available time" +
            "Instructions regarding generating Questions : \n" +
            "A question related to that day's learning\n" +
            "Must have ONLY ONE correct answer\n" +
            "Must NOT be subjective\n" +
            "Must NOT be ambiguous\n" +
            "Must NOT have multiple valid interpretations\n" +
            "Instructions regarding the answer of the questions:\n" +
            "Exact answer to the question\n" +
            "Deterministic\n" +
            "Concise\n" +
            "Machine-verifiable if possible\n" +

            "Questions MUST:\n" +
            "\n" +
            "Have one exact answer\n" +
            "Be beginner-friendly when needed\n" +
            "Match the task\n" +
            "Avoid opinion-based questions\n" +
            "Avoid open-ended questions\n" +
            "Avoid essay questions\n" +
            "Avoid multiple-correct-answer questions\n" +
            "\n" +
            "GOOD EXAMPLE:\n" +
            "Question:\n" +
            "\"What keyword is used to define a function in Python?\"\n" +
            "\n" +
            "Answer:\n" +
            "\"def\"\n" +
            "\n" +
            "BAD EXAMPLE:\n" +
            "Question:\n" +
            "\"What are the advantages of Python?\"\n" +
            "\n" +
            "This is invalid because it has multiple possible answers." +

            "TASK(title) GENERATION RULES\n" +
            "\n" +
            "Tasks MUST:\n" +
            "\n" +
            "* Build progressively\n" +
            "* Start from fundamentals if user is beginner\n" +
            "* Adapt to user's previous experience\n" +
            "* Adapt to user's goal\n" +
            "* Adapt to user's available time\n" +
            "* Be realistic\n" +
            "* Avoid overwhelming the user\n" +
            "* Include revision days occasionally\n" +
            "* Include project/practice days where appropriate\n" +
            "\n" +
            "For career-focused goals:\n" +
            "\n" +
            "* Include interview preparation\n" +
            "* Include portfolio projects\n" +
            "* Include practical exercises\n" +
            "\n" +
            "For academic goals:\n" +
            "\n" +
            "* Include theoretical understanding\n" +
            "* Include exercises and revision" +

            "# OUTPUT VALIDATION RULES\n" +
            "\n" +
            "Before generating final output ensure:\n" +
            "\n" +
            "* JSON is valid\n" +
            "* No trailing commas\n" +
            "* All days are sequential\n" +
            "* Total number of days matches duration exactly\n" +
            "* Every object contains:\n" +
            "\n" +
            "* day\n" +
            "* task\n" +
            "* question\n" +
            "* answer\n" +
            "* No duplicate day numbers\n" +
            "* No missing days\n" +
            "* No extra text outside JSON\n" +
            "* Questions are non-ambiguous\n" +
            "* Answers are exact\n" +
            "\n" +
            "---\n" +
            "\n" +
            "# FAILURE CONDITIONS\n" +
            "\n" +
            "Your response is INVALID if:\n" +
            "\n" +
            "* JSON is malformed\n" +
            "* Output contains markdown\n" +
            "* Output contains explanations\n" +
            "* Day count is incorrect\n" +
            "* Questions are ambiguous\n" +
            "* Answers are subjective\n" +
            "* Days are missing\n" +
            "* Tasks are unrealistic\n" +
            "* Roadmap ignores user's experience or goal" +

            "Generate a complete study roadmap for learning '%s'.\n" +
            "Target Level: %s. Duration: %d days. Daily commitment: %d minutes.\n" +
            "Focus areas: %s.\n\n" +
            "You must output ONLY valid JSON in the exact structure below, with no markdown formatting or backticks around it:\n"
            +
            "{\n" +
            "  \"title\": \"String (e.g. Bad Exmaples of title: Master Python in 90 Days or Python For Data Science or Learn Data Engineering, Good Example Of title: Python or Data Science or Data Engineering etc.)\",\n"
            +
            "  \"skill_goal\": \"String\",\n" +
            "  \"level\": \"String\",\n" +
            "  \"total_days\": %d,\n" +
            "  \"tasks\": [\n" +
            "    {\n" +
            "      \"day_number\": 1,\n" +
            "      \"title\": \"String (the topic and task for the day. keep the topic and task both inside this section, may use '//' between tittle and task to deifferentiate them. e.g. Learn Basics of Python // Learn about variables, operators, loops, functions.)\",\n"
            +
            "      \"question\": \"String (a flashcard question for this day)\",\n" +
            "      \"answer\": \"String (the answer to the flashcard question)\"\n" +
            "    }\n" +
            "  ]\n" +
            "}\n" +
            "Generate tasks for all %d days.DO NOT generate fewer days.\n" +
            "DO NOT skip days.",
        skillGoal, level, totalDays, dailyTimeMin, focusAreas != null ? focusAreas : "None", totalDays, totalDays);

    return callGemini(url, prompt);
  }

  // Flashcard generation using gemini
  public String generateFlashcardsJson(String notesContent) {
    /*
     * if (apiKey == null || apiKey.isBlank() || apiKey.startsWith("AQ.") ||
     * apiKey.equals("api_key")) {
     * log.
     * warn("Using mock Gemini API response for Flashcards due to invalid/missing API key"
     * );
     * return """
     * [
     * {
     * "question": "What is the primary purpose of the 'html' tag?",
     * "answer": "It represents the root of an HTML document."
     * },
     * {
     * "question": "Which tag is used for the largest heading?",
     * "answer": "h1"
     * }
     * ]
     * """;
     * }
     */
    // Updated better prompt needed
    String prompt = String.format(
        "You are an expert AI tutor. Generate a list of flashcards based on the following study notes.\n" +
            "Notes Content:\n%s\n\n" +
            "You must output ONLY valid JSON in the exact structure below, with no markdown formatting or backticks around it:\n"
            +
            "[\n" +
            "  {\n" +
            "    \"question\": \"String (the flashcard question)\",\n" +
            "    \"answer\": \"String (the answer)\"\n" +
            "  }\n" +
            "]",
        notesContent);

    String url = "https://generativelanguage.googleapis.com/v1beta/models/" + model + ":generateContent"; // was
                                                                                                          // ":generateContent?key="+apiKey

    return callGemini(url, prompt);
  }

  private String callGemini(String url, String prompt) {
    Map<String, Object> requestBody = new HashMap<>();
    Map<String, Object> content = new HashMap<>();
    Map<String, Object> part = new HashMap<>();
    part.put("text", prompt);
    content.put("parts", List.of(part));
    requestBody.put("contents", List.of(content));

    HttpHeaders headers = new HttpHeaders();
    headers.setContentType(MediaType.APPLICATION_JSON);
    headers.set("x-goog-api-key", apiKey);

    HttpEntity<Map<String, Object>> request = new HttpEntity<>(requestBody, headers);

    try {
      String responseStr = restTemplate.postForObject(url, request, String.class);
      JsonNode root = objectMapper.readTree(responseStr);
      JsonNode textNode = root.path("candidates").path(0).path("content").path("parts").path(0).path("text");

      String jsonOutput = textNode.asText();

      if (jsonOutput.startsWith("```json")) {
        jsonOutput = jsonOutput.substring(7);
      }
      if (jsonOutput.startsWith("```")) {
        jsonOutput = jsonOutput.substring(3);
      }
      if (jsonOutput.endsWith("```")) {
        jsonOutput = jsonOutput.substring(0, jsonOutput.length() - 3);
      }

      return jsonOutput.trim();
    } catch (Exception e) {
      log.error("Failed to parse JSON from Gemini API", e);
      throw new RuntimeException("Failed to parse JSON from Gemini API", e);
    }
  }
}
