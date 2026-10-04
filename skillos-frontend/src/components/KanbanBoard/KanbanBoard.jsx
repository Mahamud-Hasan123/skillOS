import React, { useState } from 'react';
import styles from './KanbanBoard.module.css';

export default function KanbanBoard({ project, columnsData, onMoveCard }) {
  const [draggedCardId, setDraggedCardId] = useState(null);
  const [dragOverColId, setDragOverColId] = useState(null);

  if (!project || !columnsData) return null;

  const handleDragStart = (e, cardId) => {
    setDraggedCardId(cardId);
    e.dataTransfer.effectAllowed = 'move';
    // Required for Firefox
    e.dataTransfer.setData('text/plain', cardId);
  };

  const handleDragOver = (e, colId) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
    if (dragOverColId !== colId) {
      setDragOverColId(colId);
    }
  };

  const handleDragLeave = () => {
    setDragOverColId(null);
  };

  const handleDrop = (e, targetColumnId) => {
    e.preventDefault();
    setDragOverColId(null);
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
    setDragOverColId(null);
  };

  return (
    <div className={styles.boardContainer}>
      <h2 className={styles.boardHeader}>{project.name} &middot; Kanban</h2>
      
      <div className={styles.columnsWrapper}>
        {columnsData.map(colData => {
          const col = colData.column;
          const cards = colData.cards || [];
          
          return (
            <div 
              key={col.id} 
              className={`${styles.column} ${dragOverColId === col.id ? styles.dragOver : ''}`}
              onDragOver={(e) => handleDragOver(e, col.id)}
              onDragLeave={handleDragLeave}
              onDrop={(e) => handleDrop(e, col.id)}
            >
              <div className={styles.columnHeader}>
                <span className={styles.columnTitle}>{col.title}</span>
                <span className={styles.cardCount}>{cards.length}</span>
              </div>
              
              <div className={styles.cardsContainer}>
                {cards.map(card => (
                  <div 
                    key={card.id} 
                    className={`${styles.kanbanCard} ${draggedCardId === card.id ? styles.isDragging : ''}`}
                    draggable
                    onDragStart={(e) => handleDragStart(e, card.id)}
                    onDragEnd={handleDragEnd}
                  >
                    <div className={styles.cardTop}>
                      <div className={`${styles.cardDot} ${col.title.toLowerCase() === 'done' ? styles.green : styles.red}`}></div>
                      <h4 className={styles.cardTitle}>{card.title}</h4>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
