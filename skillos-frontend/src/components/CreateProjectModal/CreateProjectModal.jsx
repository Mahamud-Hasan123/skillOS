import React, { useState, useEffect } from 'react';
import { createProject, getProjectGenerationStatus } from '../../services/projectService';
import styles from './CreateProjectModal.module.css';

const COLORS = ['blue', 'cyan', 'green', 'orange', 'red'];
const COLOR_HEX = {
  blue: '#3b82f6',
  cyan: '#06b6d4',
  green: '#10b981',
  orange: '#f59e0b',
  red: '#ef4444'
};

export default function CreateProjectModal({ onClose, onSuccess }) {
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    skillName: '',
    deadlineDays: 7,
    color: 'blue'
  });
  
  const [loading, setLoading] = useState(false);
  const [progress, setProgress] = useState(0);
  const [jobId, setJobId] = useState(null);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleColorSelect = (color) => {
    setFormData(prev => ({ ...prev, color }));
  };

  const startPolling = (id) => {
    const interval = setInterval(async () => {
      try {
        const res = await getProjectGenerationStatus(id);
        const data = res.data;
        if (data) {
          setProgress(data.progress_percent || 0);
          if (data.status === 'complete') {
            clearInterval(interval);
            onSuccess(); // Close and refresh list
          } else if (data.status === 'failed') {
            clearInterval(interval);
            alert("Project generation failed: " + data.error);
            setLoading(false);
          }
        }
      } catch (err) {
        console.error("Polling error", err);
      }
    }, 2000);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.name.trim()) return;
    
    setLoading(true);
    setProgress(10);
    
    try {
      const payload = {
        ...formData,
        deadlineDays: parseInt(formData.deadlineDays) || 7
      };
      const res = await createProject(payload);
      if (res.data?.job_id) {
        setJobId(res.data.job_id);
        startPolling(res.data.job_id);
      } else {
        // Fallback if no job id
        onSuccess();
      }
    } catch (err) {
      console.error(err);
      alert("Failed to create project");
      setLoading(false);
    }
  };

  return (
    <div className={styles.modalOverlay}>
      <div className={styles.modalContent}>
        <div className={styles.modalHeader}>
          <h2>New Project</h2>
          {!loading && (
            <button className={styles.closeBtn} onClick={onClose}>
              &times;
            </button>
          )}
        </div>

        {loading ? (
          <div className={styles.generatingView}>
            <div className={styles.genSpinner}>✨</div>
            <h3>Generating Project...</h3>
            <p className={styles.progressText}>AI is crafting your tasks and Kanban board</p>
            <div className={styles.progressWrapper}>
              <div 
                className={styles.progressBar} 
                style={{ width: `${progress}%` }}
              ></div>
            </div>
          </div>
        ) : (
          <form onSubmit={handleSubmit}>
            <div className={styles.formGroup}>
              <label>Project Name</label>
              <input 
                type="text" 
                name="name"
                value={formData.name}
                onChange={handleChange}
                placeholder="e.g. Portfolio v2"
                className={styles.inputField}
                required
              />
            </div>

            <div className={styles.formGroup}>
              <label>Description</label>
              <input 
                type="text" 
                name="description"
                value={formData.description}
                onChange={handleChange}
                placeholder="Personal portfolio site rebuild"
                className={styles.inputField}
              />
            </div>

            <div className={styles.formGroup}>
              <label>Target Skill</label>
              <input 
                type="text" 
                name="skillName"
                value={formData.skillName}
                onChange={handleChange}
                placeholder="e.g. React"
                className={styles.inputField}
              />
            </div>

            <div className={styles.formGroup}>
              <label>Deadline (Days)</label>
              <input 
                type="number" 
                name="deadlineDays"
                value={formData.deadlineDays}
                onChange={handleChange}
                min="1"
                className={styles.inputField}
                required
              />
            </div>

            <div className={styles.formGroup}>
              <label>Project Color</label>
              <div className={styles.colorPicker}>
                {COLORS.map(c => (
                  <button
                    key={c}
                    type="button"
                    className={`${styles.colorOption} ${formData.color === c ? styles.selected : ''}`}
                    style={{ backgroundColor: COLOR_HEX[c] }}
                    onClick={() => handleColorSelect(c)}
                  />
                ))}
              </div>
            </div>

            <button type="submit" className={styles.btnPrimary} disabled={!formData.name.trim()}>
              Generate Project
            </button>
          </form>
        )}
      </div>
    </div>
  );
}
