import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import DashboardLayout from '../../layouts/DashboardLayout';
import GenerateRoadmapModal from '../../components/GenerateRoadmapModal/GenerateRoadmapModal';
import CreateNoteModal from '../../components/CreateNoteModal/CreateNoteModal';
import { getDashboard } from '../../services/dashboardService';
import { getPlannerDashboard } from '../../services/plannerService';
import { useAuth } from '../../hooks/useAuth';
import styles from './DashboardPage.module.css';

export default function DashboardPage() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [data, setData] = useState(null);
  const [plannerData, setPlannerData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [isGenerateModalOpen, setIsGenerateModalOpen] = useState(false);
  const [isNoteModalOpen, setIsNoteModalOpen] = useState(false);

  useEffect(() => {
    Promise.all([
      getDashboard(),
      getPlannerDashboard()
    ])
      .then(([dashboardRes, plannerRes]) => {
        setData(dashboardRes.data);
        setPlannerData(plannerRes);
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

  const getUpcomingTasks = () => {
    if (!plannerData?.today?.entries) return [];
    const now = new Date();
    const currentMinutes = now.getHours() * 60 + now.getMinutes();

    return plannerData.today.entries.filter(entry => {
      if (entry.status === 'completed') return false;
      const [eh, em] = entry.endTime.split(':');
      const endMinutes = parseInt(eh) * 60 + parseInt(em);
      return endMinutes > currentMinutes; // Upcoming or currently active
    }).slice(0, 4);
  };
  const upcomingPlannerTasks = getUpcomingTasks();

  const formatTime = (timeStr) => {
    if (!timeStr) return '';
    const [h, m] = timeStr.split(':');
    const d = new Date();
    d.setHours(parseInt(h, 10));
    d.setMinutes(parseInt(m, 10));
    return d.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });
  };

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

          {/* Upcoming Planner Tasks */}
          <div className={styles.sectionBox}>
            <h3 className={styles.sectionTitle}>Upcoming in Planner</h3>
            {upcomingPlannerTasks.length === 0 ? (
              <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem', marginTop: '10px' }}>
                No upcoming tasks today.
              </p>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', marginTop: '12px' }}>
                {upcomingPlannerTasks.map(task => {
                  const isExternal = task.sourceType === 'external' || task.sourceType === 'google_calendar';
                  return (
                    <div key={task.id} className={styles.upcomingTaskItem} onClick={() => navigate('/planner')}>
                      <div className={styles.upcomingTaskTime}>
                        {formatTime(task.startTime)}
                      </div>
                      <div className={styles.upcomingTaskInfo}>
                        <div className={styles.upcomingTaskTitle}>{task.taskTitle || task.title}</div>
                        <div className={`${styles.upcomingTaskBadge} ${isExternal ? styles.badgeExternal : styles.badgeCustom}`}>
                          {isExternal ? 'Calendar' : 'SkillOS'}
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
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
