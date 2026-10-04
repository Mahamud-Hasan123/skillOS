import React from 'react';
import styles from './ChatHistory.module.css';

export default function ChatHistory({ historyItems, activeId, onSelect, onNewChat }) {
  return (
    <div className={styles.historyPanel}>
      <div className={styles.header}>
        <button className={styles.newChatBtn} onClick={onNewChat}>
          <span className={styles.btnIcon}>+</span> New Chat
        </button>
        <div className={styles.searchWrap}>
          <svg className={styles.searchIcon} viewBox="0 0 24 24">
            <circle cx="11" cy="11" r="8" />
            <line x1="21" y1="21" x2="16.65" y2="16.65" />
          </svg>
          <input type="text" placeholder="Search chats..." />
        </div>
      </div>

      <div className={styles.historyList}>
        {historyItems.map((item) => (
          <div 
            key={item.id} 
            className={`${styles.historyItem} ${item.id === activeId ? styles.activeItem : ''}`}
            onClick={() => onSelect(item.id)}
          >
            <div className={styles.itemIcon}>💬</div>
            <div className={styles.itemContent}>
              <div className={styles.itemTitle}>{item.title}</div>
              <div className={styles.itemMeta}>AI Assistant</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
