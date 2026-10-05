import React, { useState } from 'react';
import KanbanCardModal from '../KanbanCardModal/KanbanCardModal';
import styles from './KanbanBoard.module.css';

export default function KanbanBoard({ project, columnsData, onMoveCard, onTogglePin }) {
  const [draggedCardId, setDraggedCardId] = useState(null);
  const [dragOverCellId, setDragOverCellId] = useState(null);
  const [selectedCard, setSelectedCard] = useState(null);

  if (!project || !columnsData) return null;

  const allCards = columnsData.flatMap(c => c.cards || []);
  const uniqueFeatures = [...new Set(allCards.map(c => c.featureName || 'General'))];

  const handleDragStart = (e, cardId) => {
    setDraggedCardId(cardId);
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/plain', cardId);
  };

  const handleDragOver = (e, feature, colId) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
    const cellId = `${feature}-${colId}`;
    if (dragOverCellId !== cellId) {
      setDragOverCellId(cellId);
    }
  };

  const handleDragLeave = () => {
    setDragOverCellId(null);
  };

  const handleDrop = (e, feature, targetColumnId) => {
    e.preventDefault();
    setDragOverCellId(null);
    if (draggedCardId) {
      // Find current column of the dragged card
      const sourceCol = columnsData.find(c => c.cards.some(card => card.id === draggedCardId));
      if (sourceCol && sourceCol.column.id !== targetColumnId) {
        onMoveCard(draggedCardId, targetColumnId);
      }
    }
    setDraggedCardId(null);
  };

  const handleDragEnd = () => {
    setDraggedCardId(null);
    setDragOverCellId(null);
  };

  return (
    <div className={styles.boardContainer}>
      <h2 className={styles.boardHeader}>{project.name} &middot; Kanban</h2>

      <div className={styles.swimlanesWrapper}>
        {/* Headers */}
        <div className={styles.swimlaneHeaderRow}>
          <div className={styles.featureHeaderSpace}></div>
          {columnsData.map(colData => {
            const col = colData.column;
            return (
              <div key={col.id} className={styles.swimlaneColHeader}>
                <span className={styles.columnTitle}>{col.title}</span>
                <span className={styles.cardCount}>
                  {(colData.cards || []).length}
                </span>
              </div>
            );
          })}
        </div>

        {/* Swimlanes by Feature */}
        {uniqueFeatures.map(feature => (
          <div key={feature} className={styles.swimlaneRow}>
            {/* Feature Name Column */}
            <div className={styles.swimlaneFeatureName}>
              <div className={styles.featureTitleWrapper}>
                <h3>{feature}</h3>
              </div>
            </div>

            {/* Column Cells */}
            {columnsData.map(colData => {
              const col = colData.column;
              const cellId = `${feature}-${col.id}`;
              const cardsInCell = (colData.cards || []).filter(c => (c.featureName || 'General') === feature);

              return (
                <div
                  key={col.id}
                  className={`${styles.swimlaneCell} ${dragOverCellId === cellId ? styles.dragOver : ''}`}
                  onDragOver={(e) => handleDragOver(e, feature, col.id)}
                  onDragLeave={handleDragLeave}
                  onDrop={(e) => handleDrop(e, feature, col.id)}
                >
                  <div className={styles.cardsContainer}>
                    {cardsInCell.map(card => (
                      <div
                        key={card.id}
                        className={`${styles.kanbanCard} ${draggedCardId === card.id ? styles.isDragging : ''}`}
                        draggable
                        onDragStart={(e) => handleDragStart(e, card.id)}
                        onDragEnd={handleDragEnd}
                        onClick={() => setSelectedCard(card)}
                      >
                        <div className={styles.cardTop}>
                          <div className={styles.cardTopLeft}>
                            <div className={`${styles.cardDot} ${col.title.toLowerCase() === 'done' ? styles.green : styles.red}`}></div>
                            <h4 className={styles.cardTitle}>{card.title}</h4>
                          </div>
                          <button
                            className={`${styles.pinBtn} ${card.isPinnedToToday ? styles.pinned : ''}`}
                            onClick={(e) => { e.stopPropagation(); if (onTogglePin) onTogglePin(card.id); }}
                            title="Pin to Today's Focus"
                          >
                            📌
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              );
            })}
          </div>
        ))}
      </div>

      {selectedCard && (
        <KanbanCardModal
          card={selectedCard}
          onClose={() => setSelectedCard(null)}
          onSave={async (cardId, updates) => {
            try {
              const { updateKanbanCard } = await import('../../services/projectService');
              const res = await updateKanbanCard(cardId, updates);
              // Instead of mutating locally, force a re-fetch or find a way to update the parent
              // For simplicity, we can reload or call a method. The easiest is reloading since we don't have an explicit re-fetch passed.
              window.location.reload();
            } catch (err) {
              console.error("Failed to update card", err);
            }
          }}
        />
      )}
    </div>
  );
}
