package com.skillos.service;

import com.skillos.entity.User;
import com.skillos.entity.UserXp;
import com.skillos.entity.XpTransaction;
import com.skillos.repository.UserXpRepository;
import com.skillos.repository.XpTransactionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class XpEngineService {

    private final UserXpRepository userXpRepository;
    private final XpTransactionRepository xpTransactionRepository;

    @Transactional
    public void awardXp(User user, int amount, String sourceType, Long sourceId) {
        if (amount <= 0) return;

        // Log the XP
        XpTransaction xpTransaction = XpTransaction.builder()
                .user(user)
                .sourceType(sourceType)
                .sourceId(sourceId)
                .xpAmount(amount)
                .awardedAt(java.time.LocalDateTime.now())
                .build();
        xpTransactionRepository.save(xpTransaction);

        // Get or Create UserXp
        UserXp userXp = userXpRepository.findByUserId(user.getId()).orElse(null);
        if (userXp == null) {
            userXp = UserXp.builder()
                    .user(user)
                    .totalXp(0)
                    .currentLevel(1)
                    .build();
        }

        // Update User total XP
        int newTotalXp = userXp.getTotalXp() + amount;
        userXp.setTotalXp(newTotalXp);

        // Check for level up (simple formula: 1 level per 100 XP)
        int newLevel = (newTotalXp / 100) + 1;

        if (newLevel > userXp.getCurrentLevel()) {
            userXp.setCurrentLevel(newLevel);
            log.info("User {} leveled up to {}", user.getId(), newLevel);
        }

        userXpRepository.save(userXp);
    }
}
