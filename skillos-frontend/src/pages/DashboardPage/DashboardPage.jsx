import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import DashboardLayout from '../../layouts/DashboardLayout';
import GenerateRoadmapModal from '../../components/GenerateRoadmapModal/GenerateRoadmapModal';
import CreateNoteModal from '../../components/CreateNoteModal/CreateNoteModal';
import { getDashboard } from '../../services/dashboardService';
import { useAuth } from '../../hooks/useAuth';
import styles from './DashboardPage.module.css';

export default function DashboardPage() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [isGenerateModalOpen, setIsGenerateModalOpen] = useState(false);
  const [isNoteModalOpen, setIsNoteModalOpen] = useState(false);

  useEffect(() => {
    getDashboard()
      .then((res) => {
        setData(res.data);
      })
      .catch((err) => {
        console.warn('Dashboard fetch failed', err);
      })
      .finally(() => {
        setLoading(false);
      });
  }, [user]);

  if (loading || !data) {
    return (
      <DashboardLayout>
        <div className={styles.loadingContainer}>Loading Dashboard...</div>
      </DashboardLayout>
    );
  }

  const {
    greeting,
    targetGoal,
    activeRoadmap,
  } = data;

  return (
    <DashboardLayout>
      <div className={styles.dashboardContainer}>
        {/* ── HERO BANNER ── */}
        <div className={styles.heroBanner}>
          <div className={styles.heroHeader}>
            <h1 className={styles.greetingText}>{greeting || `Welcome back, ${user?.fullName}!`}</h1>
            <p className={styles.bannerSubtitle}>
              You're working toward: {targetGoal || 'Mastering your skills'}
            </p>
          </div>
        </div>

        {/* ── MIDDLE CARDS ROW ── */}
        <div className={styles.middleCardsRow}>
          {/* Active Roadmap */}
          <div className={styles.cardBox}>
            <div className={styles.cardHeader}>
              <span className={styles.cardIcon}>✨</span>
              <span>ACTIVE ROADMAP</span>
            </div>
            <h3 className={styles.cardTitle}>{activeRoadmap?.title || 'No Roadmap'}</h3>
            <p className={styles.roadmapSubtitle}>{activeRoadmap?.subtitle || '0% complete'}</p>
            <div className={styles.progressContainer}>
              <div 
                className={styles.progressFill} 
                style={{ width: `${activeRoadmap?.percent || 0}%` }}
              ></div>
            </div>
            <div className={styles.continueLink} onClick={() => navigate('/roadmaps')}>
              Continue {'>'}
            </div>
          </div>
        </div>

        {/* ── BOTTOM GRID ── */}
        <div className={styles.bottomGrid}>
          {/* Quick Actions */}
          <div className={styles.sectionBox}>
            <h3 className={styles.sectionTitle}>Quick Actions</h3>
            <div className={styles.quickActionsGrid}>
              <div className={styles.actionCard} onClick={() => setIsNoteModalOpen(true)}>
                <div className={styles.actionCardIcon} style={{ color: '#f59e0b' }}>📄</div>
                <div className={styles.actionCardText}>Add Note</div>
              </div>
              <div className={styles.actionCard} onClick={() => navigate('/roadmaps')}>
                <div className={styles.actionCardIcon} style={{ color: '#10b981' }}>🧠</div>
                <div className={styles.actionCardText}>Study Roadmaps</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {isGenerateModalOpen && (
        <GenerateRoadmapModal 
          onClose={() => setIsGenerateModalOpen(false)}
          onSuccess={() => {
            setIsGenerateModalOpen(false);
            navigate('/roadmaps');
          }}
        />
      )}

      {isNoteModalOpen && (
        <CreateNoteModal 
          onClose={() => setIsNoteModalOpen(false)}
          onSuccess={() => {
            setIsNoteModalOpen(false);
          }}
        />
      )}
    </DashboardLayout>
  );
}
