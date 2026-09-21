import React, { useState } from 'react';
import DashboardLayout from '../../layouts/DashboardLayout';
import NotesView from './NotesView';
import FlashcardsView from './FlashcardsView';
import styles from './KnowledgePage.module.css';

export default function KnowledgePage() {
  const [activeTab, setActiveTab] = useState('vault'); // 'vault' | 'flashcards'

  return (
    <DashboardLayout>
      <div className={styles.container}>
        
        {/* Tab Navigation */}
        <div className={styles.tabsWrapper}>
          <div className={styles.tabsContainer}>
            <button
              className={`${styles.tabBtn} ${activeTab === 'vault' ? styles.activeTab : ''}`}
              onClick={() => setActiveTab('vault')}
            >
              <svg className={styles.tabIcon} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                <polyline points="14 2 14 8 20 8"></polyline>
                <line x1="16" y1="13" x2="8" y2="13"></line>
                <line x1="16" y1="17" x2="8" y2="17"></line>
                <polyline points="10 9 9 9 8 9"></polyline>
              </svg>
              Vault
            </button>
            <button
              className={`${styles.tabBtn} ${activeTab === 'flashcards' ? styles.activeTab : ''}`}
              onClick={() => setActiveTab('flashcards')}
            >
              <svg className={styles.tabIcon} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
                <circle cx="8.5" cy="8.5" r="1.5"></circle>
                <polyline points="21 15 16 10 5 21"></polyline>
              </svg>
              Flashcards
            </button>
          </div>
        </div>

        {/* Content Area */}
        <div className={styles.contentArea}>
          {activeTab === 'vault' && <NotesView />}
          {activeTab === 'flashcards' && <FlashcardsView />}
        </div>

      </div>
    </DashboardLayout>
  );
}
