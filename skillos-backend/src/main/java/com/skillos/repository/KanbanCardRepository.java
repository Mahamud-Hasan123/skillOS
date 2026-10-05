package com.skillos.repository;

import com.skillos.entity.KanbanCard;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface KanbanCardRepository extends JpaRepository<KanbanCard, Long> {
    List<KanbanCard> findByColumnIdOrderByOrderIndexAsc(Long columnId);

    @Query("SELECT COUNT(k) FROM KanbanCard k WHERE k.column.board.user.id = :userId AND k.isDone = true AND k.updatedAt >= :startDate AND k.updatedAt <= :endDate")
    Integer countCompletedCardsByUserIdAndDateRange(@Param("userId") Long userId, @Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    @Query("SELECT k FROM KanbanCard k WHERE k.column.board.user.id = :userId AND k.isPinnedToToday = true AND k.isDone = false AND k.column.board.project.status = 'active' AND k.column.board.project.deletedAt IS NULL")
    List<KanbanCard> findPinnedCardsByUserId(@Param("userId") Long userId);
}
