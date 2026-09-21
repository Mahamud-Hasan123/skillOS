import React, { useState, useEffect } from 'react';
import { generateFlashcards, getGenerationStatus, getAllFlashcards } from '../../services/flashcardService';
import StudySession from './StudySession';
import CreateManualFlashcardModal from '../../components/CreateManualFlashcardModal/CreateManualFlashcardModal';
import styles from './FlashcardsView.module.css';

export default function FlashcardsView() {
  const [isStudying, setIsStudying] = useState(false);
  const [studyLimit, setStudyLimit] = useState(10);
  const [studySkill, setStudySkill] = useState('');

  const [isGenerating, setIsGenerating] = useState(false);
  const [genProgress, setGenProgress] = useState(0);
  const [genError, setGenError] = useState('');

  const [isManualModalOpen, setIsManualModalOpen] = useState(false);
  const [editingFlashcard, setEditingFlashcard] = useState(null);

  const [flashcards, setFlashcards] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchFlashcards = async () => {
    try {
      setLoading(true);
      const res = await getAllFlashcards();
      setFlashcards(res.data || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchFlashcards();
  }, []);

  const handleGenerate = async () => {
    try {
      setIsGenerating(true);
      setGenError('');
      setGenProgress(0);
      // Pass empty object or null for skillName
      const res = await generateFlashcards();
      const jobId = res.data.job_id;
      pollGeneration(jobId);
    } catch (err) {
      setIsGenerating(false);
      setGenError(err.response?.data?.message || err.response?.data?.error || 'Failed to start generation job. You may have no unused notes!');
      console.error(err);
    }
  };

  const pollGeneration = async (jobId) => {
    try {
      const res = await getGenerationStatus(jobId);
      const { status, progress_percent, error } = res.data;

      setGenProgress(progress_percent || 0);

      if (status === 'complete') {
        setIsGenerating(false);
        setGenProgress(100);
        fetchFlashcards(); // Refresh the list
        alert('Flashcards generated successfully!');
      } else if (status === 'failed') {
        setIsGenerating(false);
        setGenError(error || 'Generation failed.');
      } else {
        setTimeout(() => pollGeneration(jobId), 2000);
      }
    } catch (err) {
      console.error(err);
      setIsGenerating(false);
      setGenError('Failed to poll status.');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Are you sure you want to delete this flashcard?")) return;
    try {
      // Import the service method if not already, wait, it might not be imported at the top!
      // We'll use window.deleteFlashcard or just import it manually.
      // Wait, we need to import `deleteFlashcard` at the top. Let's do that in another chunk.
      // Assuming it's imported:
      await import('../../services/flashcardService').then(m => m.deleteFlashcard(id));
      setFlashcards(prev => prev.filter(c => c.id !== id));
    } catch (err) {
      console.error(err);
      alert('Failed to delete flashcard.');
    }
  };

  if (isStudying) {
    return (
      <StudySession 
        limit={studyLimit} 
        skillName={studySkill} 
        onFinish={() => setIsStudying(false)} 
      />
    );
  }

  return (
    <div className={styles.container}>
      <div className={styles.hubGrid}>
        
        {/* Study Section */}
        <div className={styles.card}>
          <div className={styles.iconBox}>🧠</div>
          <h2>Study Mode</h2>
          <p>Review your flashcards using spaced repetition.</p>
          
          <div className={styles.formGroup}>
            <label>Filter by Skill (optional)</label>
            <input 
              type="text" 
              placeholder="e.g., Python" 
              value={studySkill}
              onChange={(e) => setStudySkill(e.target.value)}
              className={styles.inputField}
            />
          </div>

          <div className={styles.formGroup}>
            <label>Number of Cards</label>
            <select 
              value={studyLimit} 
              onChange={(e) => setStudyLimit(Number(e.target.value))}
              className={styles.inputField}
            >
              <option value={5}>5 Cards</option>
              <option value={10}>10 Cards</option>
              <option value={20}>20 Cards</option>
              <option value={50}>50 Cards</option>
            </select>
          </div>

          <button className={styles.studyBtn} onClick={() => setIsStudying(true)}>
            Start Study Session
          </button>

          <button className={styles.manualBtn} onClick={() => setIsManualModalOpen(true)}>
            Create Manual Flashcard
          </button>
        </div>

        {/* Generate Section */}
        <div className={styles.card}>
          <div className={styles.iconBox}>✨</div>
          <h2>AI Generation</h2>
          <p>Turn your unused vault notes into flashcards automatically.</p>

          {isGenerating ? (
            <div className={styles.progressContainer}>
              <div className={styles.progressBar}>
                <div 
                  className={styles.progressFill} 
                  style={{ width: `${genProgress}%` }}
                ></div>
              </div>
              <span className={styles.progressText}>Generating... {genProgress}%</span>
            </div>
          ) : (
            <button className={styles.giantGenerateBtn} onClick={handleGenerate}>
              <div className={styles.giantIcon}>
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                  <line x1="12" y1="2" x2="12" y2="22"></line>
                  <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
                </svg>
              </div>
              <span>Generate AI<br/>Flashcards</span>
            </button>
          )}
          
          {genError && <div className={styles.errorText}>{genError}</div>}
        </div>

      </div>

      {/* Flashcards List Section */}
      <div className={styles.listSection}>
        <div className={styles.listHeader}>
          <h2>Your Flashcards ({flashcards.length})</h2>
        </div>

        {loading ? (
          <div className={styles.loadingText}>Loading flashcards...</div>
        ) : flashcards.length === 0 ? (
          <div className={styles.emptyList}>
            <p>You haven't created any flashcards yet. Generate some with AI or create them manually!</p>
          </div>
        ) : (
          <div className={styles.flashcardsGrid}>
            {flashcards.map(card => (
              <div key={card.id} className={styles.fcCard}>
                <div className={styles.fcHeader}>
                  <div className={styles.fcDifficulty}>
                    {card.difficulty ? (
                      <span className={styles[`diffBadge_${card.difficulty}`] || styles.diffBadge}>
                        {card.difficulty}
                      </span>
                    ) : (
                      <span className={styles.diffBadge_new}>new</span>
                    )}
                  </div>
                  <div className={styles.fcHeaderActions}>
                    <button 
                      className={styles.actionBtn} 
                      title="Edit Flashcard"
                      onClick={() => {
                        setEditingFlashcard(card);
                        setIsManualModalOpen(true);
                      }}
                    >
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                        <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                      </svg>
                    </button>
                    {card.skillName && (
                      <span className={styles.fcSkillBadge}>{card.skillName}</span>
                    )}
                    <button 
                      className={styles.actionBtnDelete} 
                      title="Delete Flashcard"
                      onClick={() => handleDelete(card.id)}
                    >
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <polyline points="3 6 5 6 21 6"></polyline>
                        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                        <line x1="10" y1="11" x2="10" y2="17"></line>
                        <line x1="14" y1="11" x2="14" y2="17"></line>
                      </svg>
                    </button>
                  </div>
                </div>

                <div className={styles.fcBody}>
                  <div className={styles.fcLabel}>Question</div>
                  <div className={styles.fcQuestionText}>{card.question}</div>
                  
                  <div className={styles.fcLabel}>Answer</div>
                  <div className={styles.fcAnswerText}>{card.answer}</div>
                </div>

                <div className={styles.fcFooter}>
                  <div className={styles.fcMasteryText}>Mastery: {card.mastery}%</div>
                  <div className={styles.progressBarTrack}>
                    <div 
                      className={styles.progressBarFill} 
                      style={{ width: `${card.mastery}%` }}
                    ></div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {isManualModalOpen && (
        <CreateManualFlashcardModal
          initialData={editingFlashcard}
          onClose={() => {
            setIsManualModalOpen(false);
            setEditingFlashcard(null);
          }}
          onSuccess={() => {
            alert(editingFlashcard ? 'Flashcard updated successfully!' : 'Flashcard created successfully!');
            setIsManualModalOpen(false);
            setEditingFlashcard(null);
            fetchFlashcards(); // Refresh the list
          }}
        />
      )}
    </div>
  );
}
