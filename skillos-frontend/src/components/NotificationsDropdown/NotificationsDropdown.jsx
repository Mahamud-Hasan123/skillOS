import React, { useEffect, useRef } from 'react';
import styles from './NotificationsDropdown.module.css';

export default function NotificationsDropdown({ notifications, onClose, onMarkAllRead }) {
  const dropdownRef = useRef(null);

  // Close when clicking outside
  useEffect(() => {
    function handleClickOutside(event) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        onClose();
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [onClose]);

  const getIconForType = (type) => {
    switch (type) {
      case 'ACHIEVEMENT_UNLOCKED':
      case 'PEER_ACHIEVEMENT':
        return '🏆';
      case 'LEVEL_UP':
        return '🌟';
      case 'PEER_REQUEST_ACCEPTED':
      case 'PEER_REQUEST_RECEIVED':
        return '👥';
      case 'PEER_MESSAGE':
        return '💬';
      case 'PEER_STREAK_BROKEN':
        return '💔';
      case 'PEER_TASK_MISSED':
        return '⏰';
      default:
        return '🔔';
    }
  };

  const getIconClass = (type) => {
    if (type.includes('ACHIEVEMENT')) return styles.iconYellow;
    if (type.includes('PEER')) return styles.iconBlue;
    if (type.includes('LEVEL')) return styles.iconGreen;
    return styles.iconGray;
  };

  const formatTimeAgo = (dateString) => {
    const date = new Date(dateString);
    const now = new Date();
    const seconds = Math.floor((now - date) / 1000);
    
    if (seconds < 60) return `${seconds}s ago`;
    const minutes = Math.floor(seconds / 60);
    if (minutes < 60) return `${minutes}m ago`;
    const hours = Math.floor(minutes / 60);
    if (hours < 24) return `${hours}h ago`;
    const days = Math.floor(hours / 24);
    return `${days}d ago`;
  };

  return (
    <div className={styles.dropdownOverlay}>
      <div className={styles.dropdownContainer} ref={dropdownRef}>
        <div className={styles.header}>
          <h3>Notifications</h3>
          <button className={styles.markReadBtn} onClick={onMarkAllRead}>
            Mark all read
          </button>
        </div>
        
        <div className={styles.list}>
          {notifications.length === 0 ? (
            <div className={styles.emptyState}>No new notifications</div>
          ) : (
            notifications.map((notif) => (
              <div 
                key={notif.id} 
                className={`${styles.notificationItem} ${!notif.isRead ? styles.unread : ''}`}
              >
                <div className={`${styles.iconWrapper} ${getIconClass(notif.type)}`}>
                  {getIconForType(notif.type)}
                </div>
                <div className={styles.content}>
                  <div className={styles.titleRow}>
                    <p className={styles.title}>{notif.title}</p>
                    {!notif.isRead && <span className={styles.unreadDot}></span>}
                  </div>
                  <p className={styles.body}>{notif.body}</p>
                  <span className={styles.time}>{formatTimeAgo(notif.createdAt)}</span>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}
