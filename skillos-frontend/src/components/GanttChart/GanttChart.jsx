import React from 'react';
import styles from './GanttChart.module.css';

export default function GanttChart({ project, entries }) {
  if (!project || !entries) return null;

  const totalDays = project.deadlineDays || 30;
  
  // Create array of days for the timeline header
  const daysArray = Array.from({ length: totalDays }, (_, i) => i + 1);

  const getBarClass = (color) => {
    switch(color) {
      case 'cyan': return styles.cyanBar;
      case 'green': return styles.greenBar;
      case 'orange': return styles.orangeBar;
      case 'red': return styles.redBar;
      default: return styles.blueBar;
    }
  };

  const barColorClass = getBarClass(project.color);

  // Sort entries by orderIndex
  const sortedEntries = [...entries].sort((a, b) => a.orderIndex - b.orderIndex);

  return (
    <div className={styles.ganttContainer}>
      <h2 className={styles.ganttHeader}>{project.name} &middot; Gantt Chart</h2>
      
      {sortedEntries.length === 0 ? (
        <div className={styles.emptyState}>No Gantt entries found for this project.</div>
      ) : (
        <div className={styles.ganttGrid}>
          
          {/* Y-Axis (Feature Names) */}
          <div className={styles.yAxis}>
            <div className={styles.yAxisHeader}>Features</div>
            {sortedEntries.map(entry => (
              <div key={entry.id} className={styles.yAxisRow} title={entry.featureName}>
                {entry.featureName}
              </div>
            ))}
          </div>

          {/* Timeline Grid */}
          <div className={styles.timeline}>
            
            {/* Header: Days */}
            <div className={styles.timelineHeader}>
              {daysArray.map(day => (
                <div key={day} className={styles.dayCell}>D{day}</div>
              ))}
            </div>

            {/* Rows with Bars */}
            {sortedEntries.map(entry => {
              // Calculate width and left offset based on percentages of total days
              const startPercent = (entry.startDay / totalDays) * 100;
              const widthPercent = (entry.durationDays / totalDays) * 100;
              
              return (
                <div key={entry.id} className={styles.timelineRow}>
                  {/* Background Grid Lines */}
                  {daysArray.map(day => (
                    <div key={day} className={styles.gridLine}></div>
                  ))}
                  
                  {/* Actual Gantt Bar */}
                  <div 
                    className={`${styles.ganttBar} ${barColorClass}`}
                    style={{
                      left: `${Math.max(0, startPercent)}%`,
                      width: `${Math.min(100 - startPercent, widthPercent)}%`
                    }}
                    title={`${entry.featureName} (Days ${entry.startDay + 1}-${entry.startDay + entry.durationDays})`}
                  >
                    {entry.durationDays}d
                  </div>
                </div>
              );
            })}
          </div>

        </div>
      )}
    </div>
  );
}
