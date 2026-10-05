package com.skillos.repository;

import com.skillos.entity.XpTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDateTime;
import java.util.List;
import com.skillos.dto.response.XpChartData;

@Repository
public interface XpTransactionRepository extends JpaRepository<XpTransaction, Long> {
    Page<XpTransaction> findByUserId(Long userId, Pageable pageable);

    @Query(value = "SELECT DATE(awarded_at) as label, SUM(xp_amount) as totalXp " +
                   "FROM xp_transactions " +
                   "WHERE user_id = :userId AND awarded_at >= :startDate " +
                   "GROUP BY DATE(awarded_at) " +
                   "ORDER BY label ASC", nativeQuery = true)
    List<XpChartData> getXpChartDataByDay(@Param("userId") Long userId, @Param("startDate") LocalDateTime startDate);

    @Query("SELECT COALESCE(SUM(x.xpAmount), 0) FROM XpTransaction x WHERE x.user.id = :userId AND x.awardedAt >= :startDate AND x.awardedAt <= :endDate")
    Integer sumXpByUserIdAndDateRange(@Param("userId") Long userId, @Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
}
