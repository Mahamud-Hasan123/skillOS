import React, { useState, useEffect, useCallback } from 'react';
import DashboardLayout from '../../layouts/DashboardLayout';
import GenerateRoadmapModal from '../../components/GenerateRoadmapModal/GenerateRoadmapModal';
import SwitchRoadmapModal from '../../components/SwitchRoadmapModal/SwitchRoadmapModal';
import CreateNoteModal from '../../components/CreateNoteModal/CreateNoteModal';
import { getRoadmaps, getRoadmap, updateRoadmap, completeTask } from '../../services/roadmapService';
import { useAuth } from '../../hooks/useAuth';
import styles from './RoadmapListPage.module.css';

export default function RoadmapListPage() {
  const { user } = useAuth();

  const [allRoadmaps, setAllRoadmaps] = useState([]);
  const [activeRoadmap, setActiveRoadmap] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const [isGenerateModalOpen, setIsGenerateModalOpen] = useState(false);
  const [isSwitchModalOpen, setIsSwitchModalOpen] = useState(false);
  const [noteModalData, setNoteModalData] = useState(null);

  const [activeTask, setActiveTask] = useState(null);
  const [userAnswer, setUserAnswer] = useState('');
  const [answerFeedback, setAnswerFeedback] = useState(null);

  const fetchData = useCallback(async () => {
    try {
      setLoading(true);
      const res = await getRoadmaps();
      const list = Array.isArray(res?.data) ? res.data : [];
      setAllRoadmaps(list);

      const active = list.find(r => r.status === 'active');

      if (active) {
        const detailRes = await getRoadmap(active.id);
        setActiveRoadmap(detailRes?.data || null);
      } else {
        setActiveRoadmap(null);
      }
    } catch (err) {
      console.error(err);
      setError('Failed to load roadmap data.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const id = activeRoadmap?.id;
  const tasksList = activeRoadmap?.tasks || [];

  const sortedTasksList = [...tasksList].sort((a, b) => (a.dayNumber || 0) - (b.dayNumber || 0));

  const groupedTasks = {};
  sortedTasksList.forEach((task, index) => {
    let isLocked = false;
    if (index > 0) {
      const prevTask = sortedTasksList[index - 1];
      if (prevTask.status !== 'completed') {
        isLocked = true;
      }
    }
    task._isLocked = isLocked;

    const week = Math.ceil((task.dayNumber || 1) / 7);
    if (!groupedTasks[week]) {
      groupedTasks[week] = [];
    }
    groupedTasks[week].push(task);
  });

  const totalTasks = tasksList.length;
  const completedCount = tasksList.filter(t => t.status === 'completed').length;
  const progressPercent = totalTasks > 0 ? Math.round((completedCount / totalTasks) * 100) : 0;

  const handleOpenTask = (task) => {
    setActiveTask(task);
    setUserAnswer('');
    setAnswerFeedback(null);
  };

  const handleVerifyAnswer = async () => {
    if (!activeTask || !activeTask.answer) return;
    const correctAnswer = activeTask.answer.trim().toLowerCase();
    const providedAnswer = userAnswer.trim().toLowerCase();

    if (providedAnswer === correctAnswer) {
      setAnswerFeedback('success');

      try {
        await completeTask(activeTask.id, { userAnswer: providedAnswer });

        // Refresh data to get the updated task status and xp
        await fetchData();

      } catch (err) {
        console.error("Failed to sync progress to backend", err);
      }

      setTimeout(() => setActiveTask(null), 1500);
    } else {
      setAnswerFeedback('error');
    }
  };

  const renderContent = () => {
    if (loading) {
      return (
        <div className={styles.loadingBox}>
          <div className={styles.spinner}></div>
          <p>Loading your roadmap timeline...</p>
        </div>
      );
    }

    if (error) {
      return <div className={styles.errorBox}>{error}</div>;
    }

    if (allRoadmaps.length === 0) {
      return (
        <div className={styles.emptyState}>
          <div className={styles.emptyIcon}>🗺️</div>
          <h2>No Roadmaps Yet</h2>
          <p>Generate a personalized learning path to start tracking your progress.</p>
          <button className={styles.generateBtnLg} onClick={() => setIsGenerateModalOpen(true)}>
            Generate Your First Roadmap
          </button>
        </div>
      );
    }

    if (!activeRoadmap) {
      return (
        <div className={styles.emptyState}>
          <div className={styles.emptyIcon}>🎯</div>
          <h2>No Active Roadmap</h2>
          <p>You have generated roadmaps, but none are currently set as active.</p>
          <div className={styles.actionGroup}>
            <button className={styles.switchBtn} onClick={() => setIsSwitchModalOpen(true)}>
              Choose Active Roadmap
            </button>
            <button className={styles.generateBtnLg} onClick={() => setIsGenerateModalOpen(true)}>
              Generate New Roadmap
            </button>
          </div>
        </div>
      );
    }

    return (
      <>
        <div className={styles.roadmapHeader}>
          <div className={styles.headerInfo}>
            <span className={`${styles.levelBadge} ${styles[activeRoadmap.level] || styles.beginner}`}>
              {activeRoadmap.level ? activeRoadmap.level.toUpperCase() : 'UNKNOWN'}
            </span>
            <h1>{activeRoadmap.title}</h1>
            <p className={styles.goalText}>🎯 Target Skills: {activeRoadmap.skillGoal}</p>

            <div className={styles.metaRow}>
              <span>⏱️ {activeRoadmap.dailyTimeMinutes}m / day</span>
              <span>📅 {activeRoadmap.durationMonths} MonthPlan</span>
              <span>📚 {activeRoadmap.totalDays} Total Lessons</span>
            </div>
          </div>

          <div className={styles.progressCircle}>
            <svg viewBox="0 0 36 36" className={styles.circularChart}>
              <defs>
                <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
                  <stop offset="0%" stopColor="#7e22ce" />
                  <stop offset="100%" stopColor="#480082" />
                </linearGradient>
              </defs>
              <path className={styles.circleBg}
                d="M18 2.0845
                  a 15.9155 15.9155 0 0 1 0 31.831
                  a 15.9155 15.9155 0 0 1 0 -31.831"
              />
              <path className={styles.circle}
                strokeDasharray={`${progressPercent}, 100`}
                d="M18 2.0845
                  a 15.9155 15.9155 0 0 1 0 31.831
                  a 15.9155 15.9155 0 0 1 0 -31.831"
              />
            </svg>
            <div className={styles.percentage}>{progressPercent}%</div>
          </div>
        </div>

        <div className={styles.timeline}>
          {Object.keys(groupedTasks).map((weekNum) => (
            <div key={weekNum} className={styles.weekSection}>
              <h3 className={styles.weekTitle}>Week {weekNum}</h3>
              <div className={styles.daysTimeline}>
                {groupedTasks[weekNum].map((task) => {
                  const isCompleted = task.status === 'completed';
                  const isLocked = task._isLocked;
                  return (
                    <div
                      key={task.id}
                      className={`${styles.timelineNode} ${isCompleted ? styles.nodeCompleted : ''} ${isLocked ? styles.nodeLocked : ''}`}
                      onClick={() => {
                        if (isLocked) {
                          alert('🔒 This lesson is locked. Please complete the previous days first!');
                          return;
                        }
                        handleOpenTask(task);
                      }}
                    >
                      <div className={styles.nodeIcon}>
                        {isCompleted ? '✓' : (isLocked ? '🔒' : task.dayNumber)}
                      </div>
                      <div className={styles.nodeContent}>
                        {(() => {
                          const parts = task.title.split('//');
                          const heading = parts[0].trim();
                          const taskDesc = parts.length > 1 ? parts.slice(1).join('//').trim() : task.description;
                          return (
                            <>
                              <h4>{heading}</h4>
                              <p>{taskDesc}</p>
                            </>
                          );
                        })()}
                      </div>
                      {!isLocked && (
                        <button
                          className={styles.addNoteBtn}
                          onClick={(e) => {
                            e.stopPropagation();
                            setNoteModalData({
                              roadmapId: activeRoadmap.id,
                              dayNumber: task.dayNumber,
                              skillName: activeRoadmap.title
                            });
                          }}
                          title="Add Note for this Day"
                        >
                          +
                        </button>
                      )}
                    </div>
                  );
                })}
              </div>
            </div>
          ))}
        </div>
      </>
    );
  };

  return (
    <DashboardLayout>
      <div className={styles.container}>
        <div className={styles.pageActions}>
          <button className={styles.switchBtnTop} onClick={() => setIsSwitchModalOpen(true)}>
            🔄 Switch Roadmap
          </button>
          <button className={styles.generateBtn} onClick={() => setIsGenerateModalOpen(true)}>
            <span className={styles.btnIcon}>+</span> Generate New Roadmap
          </button>
        </div>

        {renderContent()}

        {activeTask && (
          <div className={styles.modalBackdrop} onClick={() => setActiveTask(null)}>
            <div className={styles.modalContent} onClick={e => e.stopPropagation()}>
              <div className={styles.modalHeader}>
                <h3>Day {activeTask.dayNumber}: {activeTask.title}</h3>
                <button className={styles.closeBtn} onClick={() => setActiveTask(null)}>×</button>
              </div>
              <div className={styles.modalBody}>
                <div className={styles.taskDescBox}>
                  <p><strong>Practice:</strong> {activeTask.question}</p>
                </div>

                <div className={styles.answerSection}>
                  <label>Your Answer</label>
                  <input
                    type="text"
                    value={userAnswer}
                    onChange={(e) => setUserAnswer(e.target.value)}
                    placeholder="Enter your answer..."
                    className={answerFeedback === 'error' ? styles.inputError : ''}
                  />
                  {answerFeedback === 'error' && (
                    <span className={styles.errorText}>Incorrect. Try again!</span>
                  )}
                  {answerFeedback === 'success' && (
                    <span className={styles.successText}>Correct! Amazing job!</span>
                  )}
                  <button
                    className={styles.verifyBtn}
                    onClick={handleVerifyAnswer}
                    disabled={!userAnswer.trim()}
                  >
                    Verify Answer
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        {isGenerateModalOpen && (
          <GenerateRoadmapModal
            onClose={() => setIsGenerateModalOpen(false)}
            onSuccess={(result_id) => {
              setIsGenerateModalOpen(false);
              fetchData();
            }}
          />
        )}

        {isSwitchModalOpen && (
          <SwitchRoadmapModal
            roadmaps={allRoadmaps}
            onClose={() => setIsSwitchModalOpen(false)}
            onUpdate={() => {
              fetchData();
            }}
          />
        )}

        {noteModalData && (
          <CreateNoteModal
            roadmapId={noteModalData.roadmapId}
            dayNumber={noteModalData.dayNumber}
            skillName={noteModalData.skillName}
            onClose={() => setNoteModalData(null)}
            onSuccess={() => {
              // Optionally show a toast here. Alert used for simplicity.
              alert('Note created successfully!');
              setNoteModalData(null);
            }}
          />
        )}
      </div>
    </DashboardLayout>
  );
}
