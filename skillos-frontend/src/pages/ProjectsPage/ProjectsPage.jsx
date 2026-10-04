import React, { useState, useEffect } from 'react';
import DashboardLayout from '../../layouts/DashboardLayout';
import { getUserProjects, setActiveProject, getKanbanBoard, moveKanbanCard, getProjectGanttEntries, deleteProject } from '../../services/projectService';
import CreateProjectModal from '../../components/CreateProjectModal/CreateProjectModal';
import KanbanBoard from '../../components/KanbanBoard/KanbanBoard';
import GanttChart from '../../components/GanttChart/GanttChart';
import styles from './ProjectsPage.module.css';

export default function ProjectsPage() {
  const [projects, setProjects] = useState([]);
  const [activeProject, setActiveProjectState] = useState(null);
  const [kanbanData, setKanbanData] = useState(null);
  const [ganttData, setGanttData] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [loading, setLoading] = useState(true);
  const [menuOpenId, setMenuOpenId] = useState(null);
  const [viewMode, setViewMode] = useState('kanban'); // 'kanban' or 'gantt'

  const fetchProjects = async () => {
    try {
      setLoading(true);
      const res = await getUserProjects();
      const projectList = res.data?.data || [];
      setProjects(projectList);
      
      const active = projectList.find(p => p.status === 'active');
      if (active) {
        setActiveProjectState(active);
        fetchKanbanBoard(active.id);
        fetchGanttData(active.id);
      } else {
        setActiveProjectState(null);
        setKanbanData(null);
        setGanttData(null);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const fetchKanbanBoard = async (projectId) => {
    try {
      const res = await getKanbanBoard(projectId);
      setKanbanData(res.data);
    } catch (err) {
      console.error("Failed to load Kanban board", err);
    }
  };

  const fetchGanttData = async (projectId) => {
    try {
      const res = await getProjectGanttEntries(projectId);
      setGanttData(res.data?.data || []);
    } catch (err) {
      console.error("Failed to load Gantt data", err);
    }
  };

  useEffect(() => {
    fetchProjects();
  }, []);

  const handleSetActive = async (projectId) => {
    try {
      await setActiveProject(projectId);
      setMenuOpenId(null);
      fetchProjects();
    } catch (err) {
      console.error(err);
      alert("Failed to set active project");
    }
  };

  const handleDeleteProject = async (projectId) => {
    if (window.confirm("Are you sure you want to delete this project?")) {
      try {
        await deleteProject(projectId);
        setMenuOpenId(null);
        fetchProjects();
      } catch (err) {
        console.error("Failed to delete project", err);
        alert("Failed to delete project");
      }
    }
  };

  const handleMoveCard = async (cardId, targetColumnId) => {
    try {
      setKanbanData(prev => {
        if (!prev) return prev;
        const newCols = prev.columns.map(colData => {
          const filteredCards = colData.cards.filter(c => c.id !== cardId);
          return { ...colData, cards: filteredCards };
        });
        
        let cardToMove = null;
        prev.columns.forEach(colData => {
          const found = colData.cards.find(c => c.id === cardId);
          if (found) cardToMove = found;
        });

        if (cardToMove) {
          const targetCol = newCols.find(c => c.column.id === targetColumnId);
          if (targetCol) {
            targetCol.cards.push(cardToMove);
          }
        }
        return { ...prev, columns: newCols };
      });

      await moveKanbanCard(cardId, { targetColumnId, targetOrderIndex: 0 });
    } catch (err) {
      console.error("Failed to move card", err);
      fetchKanbanBoard(activeProject.id);
    }
  };

  const getBorderClass = (color) => {
    switch(color) {
      case 'cyan': return styles.cyanBorder;
      case 'green': return styles.greenBorder;
      case 'orange': return styles.orangeBorder;
      case 'red': return styles.redBorder;
      default: return styles.blueBorder;
    }
  };

  const getFillClass = (color) => {
    switch(color) {
      case 'cyan': return styles.cyanFill;
      case 'green': return styles.greenFill;
      case 'orange': return styles.orangeFill;
      case 'red': return styles.redFill;
      default: return styles.blueFill;
    }
  };

  const formatDate = (dateStr) => {
    if (!dateStr) return '';
    const date = new Date(dateStr);
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
  };

  const numCompleted = projects.filter(p => p.status === 'completed').length;

  return (
    <DashboardLayout>
      <div className={styles.container}>
        <div className={styles.header}>
          <div className={styles.headerLeft}>
            <h1>My Projects</h1>
            <p>{projects.length} projects &middot; {numCompleted} completed</p>
          </div>
          <button className={styles.newProjectBtn} onClick={() => setIsModalOpen(true)}>
            <span>+</span> New Project
          </button>
        </div>

        <div className={styles.grid}>
          {projects.map(project => {
            const isActive = project.status === 'active';
            const progress = project.progressPercent || 0;
            
            return (
              <div key={project.id} className={styles.card}>
                <div className={`${styles.cardTopBorder} ${getBorderClass(project.color)}`}></div>
                
                <div className={styles.cardHeader}>
                  <h3>{project.name}</h3>
                  <div style={{ position: 'relative' }}>
                    <button 
                      className={styles.menuBtn}
                      onClick={() => setMenuOpenId(menuOpenId === project.id ? null : project.id)}
                    >
                      &#8942;
                    </button>
                    {menuOpenId === project.id && (
                      <div className={styles.activeMenu}>
                        <button 
                          className={styles.activeMenuItem}
                          onClick={() => handleSetActive(project.id)}
                        >
                          Set Active
                        </button>
                        <button 
                          className={styles.activeMenuItem}
                          onClick={() => handleDeleteProject(project.id)}
                          style={{ color: 'red' }}
                        >
                          Delete
                        </button>
                      </div>
                    )}
                  </div>
                </div>
                
                <p className={styles.subtitle}>{project.description || project.skillName || 'Project'}</p>
                
                <div className={styles.progressTrack}>
                  <div 
                    className={`${styles.progressFill} ${getFillClass(project.color)}`} 
                    style={{ width: `${progress}%` }}
                  ></div>
                </div>
                
                <div className={styles.cardFooter}>
                  <span>{progress}%</span>
                  <span>{formatDate(project.dueDate)}</span>
                </div>
                
                {isActive && <div className={styles.activeBadge}>Active</div>}
              </div>
            );
          })}

          <div className={styles.newProjectCard} onClick={() => setIsModalOpen(true)}>
            <div className={styles.newProjectIcon}>+</div>
            <div className={styles.newProjectText}>New Project</div>
          </div>
        </div>

        {/* ACTIVE PROJECT VIEW TOGGLE */}
        {activeProject && (
          <div className={styles.viewToggleContainer}>
            <button 
              className={`${styles.viewToggleBtn} ${viewMode === 'kanban' ? styles.activeView : ''}`}
              onClick={() => setViewMode('kanban')}
            >
              Kanban Board
            </button>
            <button 
              className={`${styles.viewToggleBtn} ${viewMode === 'gantt' ? styles.activeView : ''}`}
              onClick={() => setViewMode('gantt')}
            >
              Gantt Chart
            </button>
          </div>
        )}

        {/* ACTIVE PROJECT VIEWS */}
        {activeProject && viewMode === 'kanban' && kanbanData && (
          <KanbanBoard 
            project={activeProject} 
            columnsData={kanbanData.columns} 
            onMoveCard={handleMoveCard}
          />
        )}

        {activeProject && viewMode === 'gantt' && ganttData && (
          <GanttChart 
            project={activeProject} 
            entries={ganttData} 
          />
        )}

      </div>

      {isModalOpen && (
        <CreateProjectModal 
          onClose={() => setIsModalOpen(false)}
          onSuccess={() => {
            setIsModalOpen(false);
            fetchProjects();
          }}
        />
      )}
    </DashboardLayout>
  );
}
