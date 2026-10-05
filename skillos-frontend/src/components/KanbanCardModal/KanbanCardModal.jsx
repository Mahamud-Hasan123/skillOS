import React, { useState } from 'react';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import styles from './KanbanCardModal.module.css';

export default function KanbanCardModal({ card, onClose, onSave }) {
  const [isEditing, setIsEditing] = useState(false);
  const [title, setTitle] = useState(card.title || '');
  const [description, setDescription] = useState(card.description || '');

  const handleSave = async () => {
    await onSave(card.id, { title, description });
    setIsEditing(false);
  };

  return (
    <div className={styles.modalOverlay} onClick={onClose}>
      <div className={styles.modalContent} onClick={e => e.stopPropagation()}>
        <div className={styles.modalHeader}>
          {isEditing ? (
            <input 
              type="text" 
              className={styles.titleInput} 
              value={title} 
              onChange={e => setTitle(e.target.value)} 
              placeholder="Task Title"
            />
          ) : (
            <h2 className={styles.modalTitle}>{title}</h2>
          )}
          <button className={styles.closeBtn} onClick={onClose}>&times;</button>
        </div>

        <div className={styles.modalBody}>
          <div className={styles.metaInfo}>
            <span className={styles.badge}>{card.featureName || 'General'}</span>
            {card.dueDate && <span className={styles.dateText}>Due: {card.dueDate}</span>}
          </div>

          <div className={styles.descriptionHeader}>
            <h3>Description</h3>
            {!isEditing && (
              <button className={styles.editBtn} onClick={() => setIsEditing(true)}>Edit</button>
            )}
          </div>

          {isEditing ? (
            <textarea
              className={styles.descriptionInput}
              value={description}
              onChange={e => setDescription(e.target.value)}
              placeholder="Add markdown description, links, or sub-tasks here..."
              rows={12}
            />
          ) : (
            <div className={styles.markdownPreview}>
              {description ? (
                <ReactMarkdown remarkPlugins={[remarkGfm]}>
                  {description}
                </ReactMarkdown>
              ) : (
                <p className={styles.emptyState}>No description provided. Click Edit to add details.</p>
              )}
            </div>
          )}
        </div>

        {isEditing && (
          <div className={styles.modalFooter}>
            <button className={styles.cancelBtn} onClick={() => {
              setTitle(card.title || '');
              setDescription(card.description || '');
              setIsEditing(false);
            }}>Cancel</button>
            <button className={styles.saveBtn} onClick={handleSave}>Save Changes</button>
          </div>
        )}
      </div>
    </div>
  );
}
