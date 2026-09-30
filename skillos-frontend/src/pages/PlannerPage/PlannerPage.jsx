import React, { useEffect, useState, useRef } from 'react';
import DashboardLayout from '../../layouts/DashboardLayout';
import { getPlannerDashboard, generateSchedule, updateProfile, createTask, createRoutine, getRoutines, deleteRoutine, updateTask, deleteTask, startEntry, completeEntry } from '../../services/plannerService';
import api from '../../services/api';
import { useAuth } from '../../hooks/useAuth';
import styles from './PlannerPage.module.css';

const LiveTimer = ({ startTime }) => {
  const [elapsed, setElapsed] = useState(0);

  useEffect(() => {
    if (!startTime) return;
    
    // Convert backend ISO string (which might be UTC or local) into a Date object safely
    // The backend uses LocalDateTime.now(), which is serialized as ISO. 
    const startMs = new Date(startTime).getTime();
    
    const update = () => {
      setElapsed(Math.max(0, Math.floor((Date.now() - startMs) / 1000)));
    };
    
    update();
    const interval = setInterval(update, 1000);
    return () => clearInterval(interval);
  }, [startTime]);

  const hrs = Math.floor(elapsed / 3600);
  const mins = Math.floor((elapsed % 3600) / 60);
  const secs = elapsed % 60;

  return (
    <div style={{ fontSize: '3rem', fontWeight: 'bold', textAlign: 'center', fontFamily: 'monospace', color: 'var(--accent)' }}>
      {String(hrs).padStart(2, '0')}:{String(mins).padStart(2, '0')}:{String(secs).padStart(2, '0')}
    </div>
  );
};

export default function PlannerPage() {
  const { user } = useAuth();
  const [loading, setLoading] = useState(true);
  const [generating, setGenerating] = useState(false);
  const [dashboardData, setDashboardData] = useState(null);
  const [showInfo, setShowInfo] = useState(false);

  // Task Input State (Quick Add)
  const [newTaskTitle, setNewTaskTitle] = useState('');
  const [newTaskTime, setNewTaskTime] = useState(30);
  const [newTaskPriority, setNewTaskPriority] = useState('medium');
  const [addingTask, setAddingTask] = useState(false);

  // Advanced Task Modal State
  const [showTaskModal, setShowTaskModal] = useState(false);
  const [editingTaskId, setEditingTaskId] = useState(null);
  const [advancedTaskData, setAdvancedTaskData] = useState({
    title: '',
    description: '',
    estimatedMinutes: 30,
    priority: 'medium',
    category: ''
  });

  // Routine Modal State
  const [showRoutineModal, setShowRoutineModal] = useState(false);
  const [userRoutines, setUserRoutines] = useState([]);
  const [activeDayTab, setActiveDayTab] = useState(new Date().getDay());
  const [routineData, setRoutineData] = useState({
    startTime: '09:00',
    endTime: '11:00',
    label: 'Focus Block'
  });

  // Execution Modal State
  const [activeTimelineEntry, setActiveTimelineEntry] = useState(null);
  const [isProcessingAction, setIsProcessingAction] = useState(false);

  useEffect(() => {
    // 1. Silently update user timezone to prevent Google Calendar offset bug
    const tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
    updateProfile({ timezone: tz }).catch(err => console.warn('Failed to sync timezone', err));

    // 2. Fetch today's planner dashboard
    fetchDashboard();
  }, []);

  useEffect(() => {
    if (showRoutineModal) {
      fetchRoutines();
    }
  }, [showRoutineModal]);

  const fetchRoutines = () => {
    getRoutines()
      .then(res => setUserRoutines(res.data || []))
      .catch(err => console.error("Failed to fetch routines", err));
  };

  const fetchDashboard = () => {
    setLoading(true);
    getPlannerDashboard()
      .then(res => setDashboardData(res))
      .catch(err => console.error(err))
      .finally(() => setLoading(false));
  };

  const handleGenerate = () => {
    setGenerating(true);
    generateSchedule()
      .then(() => {
        // Re-fetch dashboard after generating
        fetchDashboard();
      })
      .catch(err => alert("Failed to generate schedule. Make sure you have free time blocks set up!"))
      .finally(() => setGenerating(false));
  };

  const handleConnectGoogle = () => {
    // We already have the backend endpoint for this
    api.get('/integrations/google/auth-url')
      .then(res => {
        window.location.href = res.data.url;
      })
      .catch(err => alert('Failed to get Google Auth URL'));
  };

  const handleAddTask = () => {
    if (!newTaskTitle.trim()) return;
    setAddingTask(true);
    createTask({ 
      title: newTaskTitle, 
      estimatedMinutes: newTaskTime,
      priority: newTaskPriority
    })
      .then(() => {
        setNewTaskTitle('');
        setNewTaskTime(30);
        setNewTaskPriority('medium');
        fetchDashboard();
      })
      .catch(err => alert('Failed to create task'))
      .finally(() => setAddingTask(false));
  };

  const handleSaveAdvancedTask = () => {
    if (!advancedTaskData.title.trim()) return alert("Title is required!");
    setAddingTask(true);
    
    const request = editingTaskId 
      ? updateTask(editingTaskId, advancedTaskData)
      : createTask(advancedTaskData);
      
    request
      .then(() => {
        setShowTaskModal(false);
        setEditingTaskId(null);
        setAdvancedTaskData({
          title: '',
          description: '',
          estimatedMinutes: 30,
          priority: 'medium',
          category: ''
        });
        fetchDashboard();
      })
      .catch(err => alert(editingTaskId ? 'Failed to update task' : 'Failed to create advanced task'))
      .finally(() => setAddingTask(false));
  };

  const handleEditTask = (task) => {
    setEditingTaskId(task.id);
    setAdvancedTaskData({
      title: task.title,
      description: task.description || '',
      estimatedMinutes: task.estimatedMinutes,
      priority: task.priority || 'medium',
      category: task.category || ''
    });
    setShowTaskModal(true);
  };

  const handleDeleteTask = (e, id) => {
    e.stopPropagation();
    if (!window.confirm('Are you sure you want to delete this task?')) return;
    deleteTask(id)
      .then(() => {
        fetchDashboard();
      })
      .catch(err => alert('Failed to delete task'));
  };

  const handleSaveRoutine = () => {
    // Add seconds to time string for backend
    const payload = {
      ...routineData,
      dayOfWeek: activeDayTab,
      startTime: `${routineData.startTime}:00`,
      endTime: `${routineData.endTime}:00`,
      isAvailable: true
    };
    createRoutine(payload)
      .then(() => {
        fetchRoutines();
        setRoutineData({
          startTime: '09:00',
          endTime: '11:00',
          label: 'Focus Block'
        });
      })
      .catch(err => alert('Failed to save routine.'));
  };

  const handleDeleteRoutine = (id) => {
    if (!window.confirm("Delete this routine block?")) return;
    deleteRoutine(id)
      .then(() => fetchRoutines())
      .catch(err => alert("Failed to delete routine."));
  };

  const handleStartEntry = () => {
    if (!activeTimelineEntry) return;
    setIsProcessingAction(true);
    startEntry(activeTimelineEntry.id)
      .then(() => {
        fetchDashboard();
        setActiveTimelineEntry(prev => ({...prev, status: 'in_progress', startedAt: new Date().toISOString()}));
      })
      .catch(err => alert('Failed to start task'))
      .finally(() => setIsProcessingAction(false));
  };

  const handleCompleteEntry = () => {
    if (!activeTimelineEntry || !activeTimelineEntry.startedAt) return;
    setIsProcessingAction(true);
    
    const startMs = new Date(activeTimelineEntry.startedAt).getTime();
    const elapsedMinutes = Math.round((Date.now() - startMs) / 60000);
    const actualMinutes = Math.max(1, elapsedMinutes); // at least 1 minute
    
    completeEntry(activeTimelineEntry.id, actualMinutes)
      .then(() => {
        fetchDashboard();
        setActiveTimelineEntry(null);
      })
      .catch(err => alert('Failed to complete task'))
      .finally(() => setIsProcessingAction(false));
  };

  // Format HH:MM:SS to HH:MM AM/PM
  const formatTime = (timeStr) => {
    if (!timeStr) return '';
    const [h, m] = timeStr.split(':');
    const date = new Date();
    date.setHours(parseInt(h, 10));
    date.setMinutes(parseInt(m, 10));
    return date.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });
  };

  const scheduleEntries = dashboardData?.today?.entries || [];
  const pendingTasks = dashboardData?.pendingTasks || [];

  return (
    <DashboardLayout>
      <div className={styles.plannerContainer}>
        
        {/* ── LEFT PANE: CONTROLS & BACKLOG ── */}
        <div className={styles.leftPane}>
          <div className={styles.heroHeader}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', position: 'relative' }}>
              <h1 className={styles.greetingText} style={{ marginBottom: 0 }}>Daily Planner</h1>
              <div 
                className={styles.infoIconWrapper}
                onMouseEnter={() => setShowInfo(true)}
                onMouseLeave={() => setShowInfo(false)}
                onClick={() => setShowInfo(!showInfo)}
                style={{ cursor: 'pointer', color: 'var(--text-secondary)' }}
              >
                <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <circle cx="12" cy="12" r="10"></circle>
                  <line x1="12" y1="16" x2="12" y2="12"></line>
                  <line x1="12" y1="8" x2="12.01" y2="8"></line>
                </svg>
                {showInfo && (
                  <div className={styles.infoTooltip}>
                    <p style={{ margin: '0 0 8px 0', fontWeight: 'bold' }}>How it works:</p>
                    <ul style={{ margin: 0, paddingLeft: '16px', fontSize: '0.85rem', lineHeight: '1.4' }}>
                      <li style={{ marginBottom: '6px' }}><strong>Backlog:</strong> Add tasks with estimated completion times.</li>
                      <li style={{ marginBottom: '6px' }}><strong>Routine:</strong> Set up your free time blocks and sync your Google Calendar events.</li>
                      <li><strong>Generate:</strong> The AI will pack your tasks into your available time intelligently!</li>
                    </ul>
                  </div>
                )}
              </div>
            </div>
            <p className={styles.bannerSubtitle} style={{ marginTop: '8px' }}>
              {new Date().toLocaleDateString(undefined, { weekday: 'long', month: 'long', day: 'numeric' })}
            </p>
          </div>

          <button 
            className={styles.generateBtn}
            onClick={handleGenerate}
            disabled={generating}
          >
            {generating ? (
              <>
                <svg className={styles.generatingIcon} width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <line x1="12" y1="2" x2="12" y2="6"></line>
                  <line x1="12" y1="18" x2="12" y2="22"></line>
                  <line x1="4.93" y1="4.93" x2="7.76" y2="7.76"></line>
                  <line x1="16.24" y1="16.24" x2="19.07" y2="19.07"></line>
                  <line x1="2" y1="12" x2="6" y2="12"></line>
                  <line x1="18" y1="12" x2="22" y2="12"></line>
                  <line x1="4.93" y1="19.07" x2="7.76" y2="16.24"></line>
                  <line x1="16.24" y1="4.93" x2="19.07" y2="7.76"></line>
                </svg>
                AI Scheduling...
              </>
            ) : (
              <>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
                  <polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline>
                  <line x1="12" y1="22.08" x2="12" y2="12"></line>
                </svg>
                Generate Schedule
              </>
            )}
          </button>

          <div className={styles.tasksListContainer}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
              <h3 className={styles.tasksHeader} style={{ margin: 0 }}>Pending Backlog</h3>
            </div>

            <div className={styles.taskInputContainer}>
              <input 
                type="text" 
                className={styles.taskInput} 
                placeholder="Add a new task..." 
                value={newTaskTitle}
                onChange={e => setNewTaskTitle(e.target.value)}
                onKeyDown={e => e.key === 'Enter' && handleAddTask()}
              />
              <input 
                type="number" 
                className={styles.taskTimeInput} 
                value={newTaskTime}
                onChange={e => setNewTaskTime(e.target.value)}
                min="1"
                title="Minutes"
              />
              <select 
                className={styles.taskPrioritySelect}
                value={newTaskPriority}
                onChange={e => setNewTaskPriority(e.target.value)}
                title="Priority"
              >
                <option value="low">Low</option>
                <option value="medium">Med</option>
                <option value="high">High</option>
                <option value="critical">Crit</option>
              </select>
              <button 
                className={styles.taskAddBtn} 
                onClick={handleAddTask}
                disabled={addingTask || !newTaskTitle.trim()}
                title="Quick Add"
              >
                +
              </button>
              <button 
                className={styles.taskAdvancedBtn} 
                onClick={() => {
                  setEditingTaskId(null);
                  setAdvancedTaskData({
                    title: newTaskTitle,
                    description: '',
                    estimatedMinutes: newTaskTime,
                    priority: newTaskPriority,
                    category: ''
                  });
                  setShowTaskModal(true);
                }}
                title="Advanced Options"
              >
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M15 3h6v6"></path>
                  <path d="M9 21H3v-6"></path>
                  <path d="M21 3l-7 7"></path>
                  <path d="M3 21l7-7"></path>
                </svg>
              </button>
            </div>

            {pendingTasks.length === 0 ? (
              <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>No pending tasks! Add some roadmap goals or custom tasks.</p>
            ) : (
              pendingTasks.map(task => (
                <div key={task.id} className={styles.taskItem} onClick={() => handleEditTask(task)}>
                  <span className={styles.taskTitle}>{task.title}</span>
                  <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                    <span className={`${styles.taskPriorityBadge} ${styles['priority-' + (task.priority || 'medium').toLowerCase()]}`}>
                      {task.priority || 'medium'}
                    </span>
                    <span className={styles.taskDuration}>{task.estimatedMinutes}m</span>
                    <button 
                      className={styles.taskDeleteBtn} 
                      onClick={(e) => handleDeleteTask(e, task.id)}
                      title="Delete Task"
                    >
                      <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <line x1="18" y1="6" x2="6" y2="18"></line>
                        <line x1="6" y1="6" x2="18" y2="18"></line>
                      </svg>
                    </button>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        {/* ── RIGHT PANE: TIMELINE ── */}
        <div className={styles.rightPane}>
          <div className={styles.timelineHeader}>
            <h2 className={styles.timelineTitle}>
              Today's Timeline
            </h2>
            <div style={{ display: 'flex', gap: '8px' }}>
              <button className={styles.googleSyncBtn} onClick={() => setShowRoutineModal(true)}>
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <line x1="12" y1="5" x2="12" y2="19"></line>
                  <line x1="5" y1="12" x2="19" y2="12"></line>
                </svg>
                Add Routine
              </button>
              <button className={styles.googleSyncBtn} onClick={handleConnectGoogle}>
                <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor">
                  <path d="M12.545 10.239v3.821h5.445c-.712 2.315-2.757 3.951-5.445 3.951-3.178 0-5.759-2.581-5.759-5.759s2.581-5.759 5.759-5.759c1.479 0 2.825.556 3.864 1.468l2.883-2.883C17.433 3.398 15.176 2.5 12.545 2.5c-5.239 0-9.489 4.25-9.489 9.489s4.25 9.489 9.489 9.489c4.957 0 8.657-3.486 8.657-8.816 0-.671-.088-1.319-.245-1.934h-8.412z"/>
                </svg>
                Sync Calendar
              </button>
            </div>
          </div>

          <div className={styles.timelineScroll}>
            {loading ? (
              <div className={styles.emptyState}>Loading Timeline...</div>
            ) : scheduleEntries.length === 0 ? (
              <div className={styles.emptyState}>
                <div className={styles.emptyIcon}>✨</div>
                <p>Your timeline is clear. Hit generate to let AI plan your day!</p>
              </div>
            ) : (
              <div className={styles.timelineGrid}>
                {scheduleEntries.map((entry, idx) => {
                  const isExternal = entry.sourceType === 'external' || entry.sourceType === 'google_calendar';
                  return (
                    <div 
                      key={entry.id || idx} 
                      className={`${styles.timeBlock} ${isExternal ? styles.timeBlockGoogle : styles.timeBlockCustom}`}
                      onClick={() => {
                        if (!isExternal) setActiveTimelineEntry(entry);
                      }}
                      style={{ cursor: isExternal ? 'default' : 'pointer' }}
                    >
                      <div className={styles.timeBlockLeft}>
                        <div>{formatTime(entry.startTime)}</div>
                        <div style={{ fontSize: '0.7rem', opacity: 0.6 }}>to</div>
                        <div>{formatTime(entry.endTime)}</div>
                      </div>
                      <div className={styles.timeBlockRight}>
                        <div className={styles.blockTitle}>{entry.taskTitle || entry.title}</div>
                        <div className={`${styles.blockSource} ${isExternal ? styles.googleSource : styles.customSource}`}>
                          {isExternal ? 'Google Calendar' : 'SkillOS Task'}
                        </div>
                        {entry.status === 'in_progress' && !isExternal && (
                          <div style={{ marginTop: '8px', fontSize: '0.8rem', color: 'var(--accent)', fontWeight: 'bold' }}>
                            ▶ IN PROGRESS
                          </div>
                        )}
                        {entry.status === 'completed' && !isExternal && (
                          <div style={{ marginTop: '8px', fontSize: '0.8rem', color: 'var(--emerald)', fontWeight: 'bold' }}>
                            ✓ COMPLETED
                          </div>
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        </div>

      </div>

      {/* ── ROUTINE MODAL ── */}
      {showRoutineModal && (
        <div className={styles.modalOverlay}>
          <div className={styles.modalContent}>
            <div className={styles.modalHeader}>
              <h3 className={styles.modalTitle}>Configure Free Time</h3>
              <button className={styles.closeBtn} onClick={() => setShowRoutineModal(false)}>×</button>
            </div>
            {/* Tabs */}
            <div style={{ display: 'flex', borderBottom: '1px solid var(--border-dash)', marginBottom: '16px' }}>
              {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day, idx) => (
                <button
                  key={idx}
                  onClick={() => setActiveDayTab(idx)}
                  style={{
                    flex: 1, padding: '10px 0', background: 'none', border: 'none',
                    borderBottom: activeDayTab === idx ? '2px solid var(--accent)' : 'none',
                    color: activeDayTab === idx ? 'var(--accent)' : 'var(--text-secondary)',
                    fontWeight: activeDayTab === idx ? '600' : '400',
                    cursor: 'pointer'
                  }}
                >
                  {day}
                </button>
              ))}
            </div>

            {/* List Routines */}
            <div style={{ maxHeight: '250px', overflowY: 'auto', marginBottom: '20px' }}>
              {userRoutines.filter(r => r.dayOfWeek === activeDayTab).length === 0 ? (
                <p style={{ color: 'var(--text-muted)', textAlign: 'center', fontSize: '0.9rem', padding: '20px 0' }}>No routine blocks for this day.</p>
              ) : (
                userRoutines.filter(r => r.dayOfWeek === activeDayTab).map(r => (
                  <div key={r.id} style={{ display: 'flex', justifyContent: 'space-between', padding: '12px', border: '1px solid var(--border-dash)', borderRadius: '6px', marginBottom: '8px', background: 'var(--bg-dash)' }}>
                    <div>
                      <div style={{ fontWeight: '600', fontSize: '0.95rem', color: 'var(--text-primary)' }}>{r.label}</div>
                      <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>{r.startTime.substring(0, 5)} - {r.endTime.substring(0, 5)}</div>
                    </div>
                    <button onClick={() => handleDeleteRoutine(r.id)} style={{ background: 'none', border: 'none', color: 'var(--red)', cursor: 'pointer' }}>
                      <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                    </button>
                  </div>
                ))
              )}
            </div>

            {/* Inline Add Form */}
            <div style={{ borderTop: '1px solid var(--border-dash)', paddingTop: '16px' }}>
              <h4 style={{ fontSize: '0.9rem', marginBottom: '12px', color: 'var(--text-secondary)' }}>Add New Block</h4>
              <div style={{ display: 'flex', gap: '8px', marginBottom: '12px' }}>
                <input type="time" className={styles.formInput} style={{ flex: 1 }} value={routineData.startTime} onChange={e => setRoutineData({...routineData, startTime: e.target.value})} title="Start Time" />
                <input type="time" className={styles.formInput} style={{ flex: 1 }} value={routineData.endTime} onChange={e => setRoutineData({...routineData, endTime: e.target.value})} title="End Time" />
              </div>
              <div style={{ display: 'flex', gap: '8px' }}>
                <input type="text" className={styles.formInput} style={{ flex: 2 }} value={routineData.label} onChange={e => setRoutineData({...routineData, label: e.target.value})} placeholder="Label (e.g. Focus Block)" />
                <button className={styles.saveBtn} style={{ flex: 1, padding: '10px' }} onClick={handleSaveRoutine}>+ Add</button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* ── ADVANCED TASK MODAL ── */}
      {showTaskModal && (
        <div className={styles.modalOverlay}>
          <div className={styles.modalContent}>
            <div className={styles.modalHeader}>
              <h3 className={styles.modalTitle}>{editingTaskId ? 'Edit Task' : 'Create Detailed Task'}</h3>
              <button className={styles.closeBtn} onClick={() => {
                setShowTaskModal(false);
                setEditingTaskId(null);
              }}>×</button>
            </div>

            <div className={styles.formGroup}>
              <label className={styles.formLabel}>Title *</label>
              <input 
                type="text" 
                className={styles.formInput} 
                value={advancedTaskData.title}
                onChange={e => setAdvancedTaskData({...advancedTaskData, title: e.target.value})}
                placeholder="Task title..."
              />
            </div>

            <div className={styles.formGroup}>
              <label className={styles.formLabel}>Description</label>
              <textarea 
                className={styles.formInput} 
                value={advancedTaskData.description}
                onChange={e => setAdvancedTaskData({...advancedTaskData, description: e.target.value})}
                placeholder="Any specific details..."
                rows={3}
                style={{ resize: 'vertical' }}
              />
            </div>

            <div style={{ display: 'flex', gap: '16px', marginBottom: '16px' }}>
              <div style={{ flex: 1 }}>
                <label className={styles.formLabel}>Time (Mins)</label>
                <input 
                  type="number" 
                  className={styles.formInput} 
                  value={advancedTaskData.estimatedMinutes}
                  onChange={e => setAdvancedTaskData({...advancedTaskData, estimatedMinutes: e.target.value})}
                  min="1"
                />
              </div>
              <div style={{ flex: 1 }}>
                <label className={styles.formLabel}>Priority</label>
                <select 
                  className={styles.formSelect}
                  value={advancedTaskData.priority}
                  onChange={e => setAdvancedTaskData({...advancedTaskData, priority: e.target.value})}
                >
                  <option value="low">Low</option>
                  <option value="medium">Medium</option>
                  <option value="high">High</option>
                  <option value="critical">Critical</option>
                </select>
              </div>
            </div>

            <div className={styles.formGroup}>
              <label className={styles.formLabel}>Category</label>
              <input 
                type="text" 
                className={styles.formInput} 
                value={advancedTaskData.category}
                onChange={e => setAdvancedTaskData({...advancedTaskData, category: e.target.value})}
                placeholder="e.g. Work, Study, Health"
              />
            </div>

            <div className={styles.modalActions}>
              <button className={styles.cancelBtn} onClick={() => {
                setShowTaskModal(false);
                setEditingTaskId(null);
              }}>Cancel</button>
              <button 
                className={styles.saveBtn} 
                onClick={handleSaveAdvancedTask}
                disabled={addingTask}
              >
                {editingTaskId ? 'Save Changes' : 'Create Task'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ── EXECUTION MODAL ── */}
      {activeTimelineEntry && (
        <div className={styles.modalOverlay}>
          <div className={styles.modalContent} style={{ textAlign: 'center' }}>
            <div className={styles.modalHeader} style={{ justifyContent: 'center', position: 'relative' }}>
              <h3 className={styles.modalTitle}>Execution Tracker</h3>
              <button 
                className={styles.closeBtn} 
                onClick={() => setActiveTimelineEntry(null)}
                style={{ position: 'absolute', right: 0 }}
              >
                ×
              </button>
            </div>

            <div style={{ margin: '20px 0' }}>
              <h2 style={{ marginBottom: '8px', color: 'var(--text-primary)' }}>{activeTimelineEntry.taskTitle || activeTimelineEntry.title}</h2>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
                Estimated: {activeTimelineEntry.estimatedMinutes} minutes
              </p>
            </div>

            {activeTimelineEntry.status === 'in_progress' ? (
              <div style={{ margin: '32px 0' }}>
                <LiveTimer startTime={activeTimelineEntry.startedAt} />
                <p style={{ color: 'var(--text-muted)', fontSize: '0.8rem', marginTop: '12px' }}>
                  Keep focusing! Close this popup anytime; the timer runs in the background.
                </p>
              </div>
            ) : activeTimelineEntry.status === 'completed' ? (
              <div style={{ margin: '32px 0' }}>
                <div style={{ fontSize: '3rem', color: 'var(--emerald)' }}>✓</div>
                <h3 style={{ color: 'var(--text-primary)', marginTop: '8px' }}>Task Finished!</h3>
                <p style={{ color: 'var(--text-secondary)' }}>
                  Actual time: {activeTimelineEntry.actualMinutes || 0} minutes
                </p>
              </div>
            ) : (
              <div style={{ margin: '32px 0', color: 'var(--text-secondary)' }}>
                Ready to start working? The AI will track your actual time to improve future estimates.
              </div>
            )}

            <div style={{ display: 'flex', justifyContent: 'center', gap: '16px', marginTop: '24px' }}>
              {activeTimelineEntry.status === 'pending' && (
                <button 
                  className={styles.saveBtn} 
                  style={{ width: '100%', padding: '16px', fontSize: '1.1rem' }}
                  onClick={handleStartEntry}
                  disabled={isProcessingAction}
                >
                  ▶ Start Task
                </button>
              )}
              {activeTimelineEntry.status === 'in_progress' && (
                <button 
                  className={styles.saveBtn} 
                  style={{ width: '100%', padding: '16px', fontSize: '1.1rem', background: 'var(--emerald)' }}
                  onClick={handleCompleteEntry}
                  disabled={isProcessingAction}
                >
                  ✅ Finish Task
                </button>
              )}
            </div>
          </div>
        </div>
      )}

    </DashboardLayout>
  );
}
