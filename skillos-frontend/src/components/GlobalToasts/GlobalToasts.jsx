import React, { useEffect, useState } from 'react';
import { wsEvents } from '../../services/websocketService';
import styles from './GlobalToasts.module.css';

export default function GlobalToasts() {
  const [toasts, setToasts] = useState([]);

  useEffect(() => {
    const handleNotification = (e) => {
      const data = e.detail;
      addToast(data.title || 'New Notification', data.body || 'You have a new notification.');
    };

    const handleMessage = (e) => {
      const data = e.detail;
      // We don't want to show a toast if the user is currently chatting with this person.
      // But for simplicity, we'll show it. In a real app, we'd check the current route.
      addToast('New Message', data.body || 'You received a new message.');
    };

    wsEvents.addEventListener('ws-notification', handleNotification);
    wsEvents.addEventListener('ws-message', handleMessage);

    return () => {
      wsEvents.removeEventListener('ws-notification', handleNotification);
      wsEvents.removeEventListener('ws-message', handleMessage);
    };
  }, []);

  const addToast = (title, message) => {
    const id = Date.now();
    setToasts((prev) => [...prev, { id, title, message }]);
    
    // Auto-dismiss after 4 seconds
    setTimeout(() => {
      setToasts((prev) => prev.filter((t) => t.id !== id));
    }, 4000);
  };

  const removeToast = (id) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  };

  if (toasts.length === 0) return null;

  return (
    <div className={styles.toastContainer}>
      {toasts.map((toast) => (
        <div key={toast.id} className={styles.toast}>
          <div className={styles.toastContent}>
            <strong>{toast.title}</strong>
            <p>{toast.message}</p>
          </div>
          <button className={styles.closeBtn} onClick={() => removeToast(toast.id)}>
            &times;
          </button>
        </div>
      ))}
    </div>
  );
}
