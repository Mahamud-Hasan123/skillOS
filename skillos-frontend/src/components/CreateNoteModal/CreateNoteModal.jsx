import React, { useState } from 'react';
import { createNote, updateNote } from '../../services/noteService';
import styles from './CreateNoteModal.module.css';

export default function CreateNoteModal({ roadmapId, dayNumber, skillName, initialData, onClose, onSuccess }) {
  const [content, setContent] = useState(initialData?.content || '');
  const [linksText, setLinksText] = useState(initialData?.resourceLinks?.join(', ') || '');
  const [skillInput, setSkillInput] = useState(initialData?.skillName || skillName || '');
  const [dayInput, setDayInput] = useState(initialData?.dayNumber || dayNumber || '');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');
  
  const isEditing = !!initialData;

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    if (!content.trim()) {
      setError('Note content is required.');
      return;
    }

    const resourceLinks = linksText
      .split(',')
      .map(link => link.trim())
      .filter(link => link.length > 0);

    const payload = {
      roadmapId,
      dayNumber: dayInput ? parseInt(dayInput, 10) : null,
      skillName: skillInput,
      content,
      resourceLinks: resourceLinks.length > 0 ? resourceLinks : []
    };

    setSubmitting(true);
    try {
      if (isEditing) {
        await updateNote(initialData.id, payload);
      } else {
        await createNote(payload);
      }
      if (onSuccess) onSuccess();
      onClose();
    } catch (err) {
      console.error(err);
      setError(err.response?.data?.message || err.response?.data?.error || 'Failed to save note. Ensure your links are valid and not blacklisted.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className={styles.modalBackdrop} onClick={onClose}>
      <div className={styles.modalContent} onClick={e => e.stopPropagation()}>
        <button className={styles.closeBtn} onClick={onClose}>×</button>

        <div className={styles.formContainer}>
          <div className={styles.header}>
            <div className={styles.iconBox}>
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path>
                <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path>
              </svg>
            </div>
            <h2 className={styles.title}>{isEditing ? 'Edit Note' : 'Create New Note'}</h2>
          </div>

          {error && <div className={styles.errorAlert}>{error}</div>}

          <form onSubmit={handleSubmit} className={styles.form}>
            <div className={styles.formGroup}>
              <label htmlFor="note-content" className={styles.mainLabel}>Content</label>
              <textarea
                id="note-content"
                placeholder="Write your notes here..."
                value={content}
                onChange={(e) => setContent(e.target.value)}
                required
                className={styles.textareaInput}
                rows={7}
              />
            </div>

            <div className={styles.metaRow}>
              <div className={styles.metaGroup}>
                <label htmlFor="skill-input" className={styles.metaLabel}>
                  <svg className={styles.metaIcon} style={{color: '#3b82f6'}} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path>
                    <line x1="7" y1="7" x2="7.01" y2="7"></line>
                  </svg>
                  Skill
                </label>
                <input
                  id="skill-input"
                  type="text"
                  placeholder="e.g., React, JavaScript"
                  value={skillInput}
                  onChange={(e) => setSkillInput(e.target.value)}
                  className={styles.textInput}
                />
              </div>

              <div className={styles.metaGroup}>
                <label htmlFor="resource-links" className={styles.metaLabel}>
                  <svg className={styles.metaIcon} style={{color: '#8b5cf6'}} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path>
                    <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path>
                  </svg>
                  Links/URLs
                </label>
                <input
                  id="resource-links"
                  type="text"
                  placeholder="Reference URLs"
                  value={linksText}
                  onChange={(e) => setLinksText(e.target.value)}
                  className={styles.textInput}
                />
              </div>

              <div className={styles.metaGroup}>
                <label htmlFor="day-input" className={styles.metaLabel}>
                  <svg className={styles.metaIcon} style={{color: '#10b981'}} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                    <line x1="16" y1="2" x2="16" y2="6"></line>
                    <line x1="8" y1="2" x2="8" y2="6"></line>
                    <line x1="3" y1="10" x2="21" y2="10"></line>
                  </svg>
                  Day
                </label>
                <input
                  id="day-input"
                  type="number"
                  placeholder="e.g., 1"
                  value={dayInput}
                  onChange={(e) => setDayInput(e.target.value)}
                  className={styles.textInput}
                />
              </div>
            </div>

            <div className={styles.actions}>
              <button type="button" className={styles.cancelBtn} onClick={onClose} disabled={submitting}>Cancel</button>
              <button type="submit" className={styles.submitBtn} disabled={submitting}>
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path>
                  <polyline points="17 21 17 13 7 13 7 21"></polyline>
                  <polyline points="7 3 7 8 15 8"></polyline>
                </svg>
                {submitting ? 'Saving...' : 'Save Note'}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
