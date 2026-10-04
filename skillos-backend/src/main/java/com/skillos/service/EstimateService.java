package com.skillos.service;

import com.skillos.repository.DurationHistoryRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * Provides adjusted time estimates based on historical duration data.
 *
 * MVP strategy:
 *   - If we have >= 5 records for a user + category, use the average actual_minutes
 *   - Otherwise, return the default estimate
 *
 * This can be replaced with a trained prediction model once enough data is collected.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class EstimateService {

    private final DurationHistoryRepository durationHistoryRepository;

    // Minimum number of records needed before we trust the average
    private static final long MIN_RECORDS_FOR_ADJUSTMENT = 5;

    /**
     * Get an adjusted time estimate for a task based on historical data.
     *
     * @param userId          The user's ID
     * @param category        The task category (e.g., "Python", "DevOps")
     * @param defaultEstimate The original estimated minutes
     * @return                Adjusted estimate if enough data exists, otherwise defaultEstimate
     */
    public int getAdjustedEstimate(Long userId, String category, int defaultEstimate) {
        if (category == null || category.isBlank()) {
            return defaultEstimate;
        }

        long recordCount = durationHistoryRepository.countByUserIdAndCategory(userId, category);

        if (recordCount < MIN_RECORDS_FOR_ADJUSTMENT) {
            log.debug("Not enough data for user {} category '{}' ({} records). Using default: {} min",
                    userId, category, recordCount, defaultEstimate);
            return defaultEstimate;
        }

        Double averageActual = durationHistoryRepository
                .findAverageActualMinutesByUserIdAndCategory(userId, category);

        if (averageActual == null) {
            return defaultEstimate;
        }

        int adjusted = (int) Math.round(averageActual);
        log.info("Adjusted estimate for user {} category '{}': {} min → {} min (based on {} records)",
                userId, category, defaultEstimate, adjusted, recordCount);

        return adjusted;
    }
}
