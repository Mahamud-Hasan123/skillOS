import React, { useState } from 'react';
import { createManualFlashcard, updateFlashcard } from '../../services/flashcardService';
import styles from './CreateManualFlashcardModal.module.css';

export default function CreateManualFlashcardModal({ initialData, onClose, onSuccess }) {
  const [skillName, setSkillName] = useState(initialData?.skillName || '');
  const [question, setQuestion] = useState(initialData?.question || '');
  const [answer, setAnswer] = useState(initialData?.answer || '');
  const [difficulty, setDifficulty] = useState(initialData?.difficulty || '');
  const [loading, setLoading] = useState(false);
  
  const isEditing = !!initialData;

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!question.trim() || !answer.trim()) {
      alert("Question and Answer are required!");
      return;
    }
    try {
      setLoading(true);
      const payload = {
        skillName: skillName || null,
        question,
        answer,
        difficulty: difficulty || null
      };
      
      if (isEditing) {
        await updateFlashcard(initialData.id, payload);
      } else {
        await createManualFlashcard(payload);
      }
      onSuccess();
    } catch (err) {
      console.error(err);
      alert('Failed to create flashcard. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={styles.modalOverlay} onClick={onClose}>
      <div className={styles.modalContent} onClick={e => e.stopPropagation()}>
        
        <div className={styles.modalHeader}>
          <h2>{isEditing ? 'Edit Flashcard' : 'Create Flashcard'}</h2>
          <button className={styles.closeBtn} onClick={onClose}>×</button>
        </div>

        <form onSubmit={handleSubmit}>
          
          <div className={styles.formGroup}>
            <label>Skill Name (Optional)</label>
            <input 
              type="text" 
              placeholder="e.g., Python" 
              value={skillName}
              onChange={e => setSkillName(e.target.value)}
            />
          </div>

          <div className={styles.formGroup}>
            <label>Question *</label>
            <textarea 
              placeholder="Enter the front side of the flashcard..." 
              value={question}
              onChange={e => setQuestion(e.target.value)}
              required
              rows={3}
            />
          </div>

          <div className={styles.formGroup}>
            <label>Answer *</label>
            <textarea 
              placeholder="Enter the back side of the flashcard..." 
              value={answer}
              onChange={e => setAnswer(e.target.value)}
              required
              rows={4}
            />
          </div>

          <div className={styles.formGroup}>
            <label>Initial Difficulty (Optional)</label>
            <select value={difficulty} onChange={e => setDifficulty(e.target.value)}>
              <option value="">None</option>
              <option value="easy">Easy</option>
              <option value="medium">Medium</option>
              <option value="hard">Hard</option>
            </select>
          </div>

          <button 
            type="submit" 
            className={styles.submitBtn}
            disabled={loading}
          >
            {loading ? 'Saving...' : (isEditing ? 'Save Changes' : 'Create Flashcard')}
          </button>
        </form>

      </div>
    </div>
  );
}
