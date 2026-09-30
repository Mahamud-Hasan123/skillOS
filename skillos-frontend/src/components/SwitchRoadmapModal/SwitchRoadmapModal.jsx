import React, { useState } from 'react';
import { updateRoadmap, deleteRoadmap } from '../../services/roadmapService';
import styles from './SwitchRoadmapModal.module.css';

export default function SwitchRoadmapModal({ roadmaps, onClose, onUpdate }) {
  const [loadingId, setLoadingId] = useState(null);

  const handleSetActive = async (id) => {
    try {
      setLoadingId(id);
      await updateRoadmap(id, { status: 'active' });
      onUpdate(); // Triggers parent to fetch roadmaps again
      onClose();  // Close modal so page refreshes immediately
    } catch (err) {
      console.error(err);
      alert('Failed to set active roadmap');
      setLoadingId(null);
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Are you sure you want to delete this roadmap? This action cannot be undone.')) {
      return;
    }
    
    try {
      setLoadingId(id);
      await deleteRoadmap(id);
      onUpdate(); // Refresh the list
    } catch (err) {
      console.error(err);
      alert('Failed to delete roadmap');
      setLoadingId(null);
    }
  };

  return (
    <div className={styles.modalBackdrop} onClick={onClose}>
      <div className={styles.modalContent} onClick={(e) => e.stopPropagation()}>
        <div className={styles.modalHeader}>
          <h3>Switch Roadmap</h3>
          <button className={styles.closeBtn} onClick={onClose}>×</button>
        </div>

        <div className={styles.modalBody}>
          {roadmaps.length === 0 ? (
            <p className={styles.emptyText}>You haven't generated any roadmaps yet.</p>
          ) : (
            <div className={styles.list}>
              {roadmaps.map((rm) => {
                const isActive = rm.status === 'active';
                return (
                  <div key={rm.id} className={`${styles.roadmapItem} ${isActive ? styles.activeItem : ''}`}>
                    
                    <div className={styles.itemInfo}>
                      <div className={styles.itemHeader}>
                        <h4>{rm.title}</h4>
                      </div>
                      <p className={styles.itemMeta}>🎯 {rm.skillGoal} • 📅 {rm.durationMonths} Months</p>
                    </div>

                    <div className={styles.itemActions}>
                      <button
                        className={isActive ? styles.activeToggle : styles.activateBtn}
                        onClick={() => !isActive && handleSetActive(rm.id)}
                        disabled={loadingId === rm.id || isActive}
                        title={isActive ? 'Currently active' : 'Set as active roadmap'}
                      >
                        {loadingId === rm.id ? '...' : isActive ? 'Active ✓' : 'Set Active'}
                      </button>
                      
                      <button 
                        className={styles.deleteBtn}
                        onClick={() => handleDelete(rm.id)}
                        title="Delete Roadmap"
                        disabled={loadingId === rm.id}
                      >
                        <svg viewBox="0 0 24 24" width="18" height="18" stroke="currentColor" fill="none" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                          <polyline points="3 6 5 6 21 6"></polyline>
                          <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                        </svg>
                      </button>
                    </div>

                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
