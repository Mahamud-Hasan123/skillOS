import React, { useState, useEffect, useCallback } from 'react';
import { getStudyBatch, submitReview } from '../../services/flashcardService';
import styles from './StudySession.module.css';

export default function StudySession({ limit, skillName, onFinish }) {
  const [cards, setCards] = useState([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isFlipped, setIsFlipped] = useState(false);
  
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const fetchCards = useCallback(async () => {
    try {
      setLoading(true);
      const res = await getStudyBatch(skillName, limit);
      const fetchedCards = res.data?.data || [];
      setCards(fetchedCards);
    } catch (err) {
      console.error(err);
      setError('Failed to load flashcards for study.');
    } finally {
      setLoading(false);
    }
  }, [skillName, limit]);

  useEffect(() => {
    fetchCards();
  }, [fetchCards]);

  const handleReview = async (difficulty) => {
    const currentCard = cards[currentIndex];
    try {
      setSubmitting(true);
      await submitReview(currentCard.id, difficulty);
      
      // Move to next card
      if (currentIndex < cards.length - 1) {
        setIsFlipped(false);
        setCurrentIndex(prev => prev + 1);
      } else {
        // Session complete
        setCurrentIndex(cards.length); // triggers completion state
      }
    } catch (err) {
      console.error(err);
      alert('Failed to submit review. Please try again.');
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <div className={styles.container}>
        <div className={styles.loadingText}>Loading your flashcards...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className={styles.container}>
        <div className={styles.errorText}>{error}</div>
        <button className={styles.backBtn} onClick={onFinish}>Return to Hub</button>
      </div>
    );
  }

  if (cards.length === 0) {
    return (
      <div className={styles.container}>
        <div className={styles.emptyState}>
          <h2>No Flashcards Found</h2>
          <p>We couldn't find any flashcards for your current selection.</p>
          <button className={styles.backBtn} onClick={onFinish}>Return to Hub</button>
        </div>
      </div>
    );
  }

  // Session Complete State
  if (currentIndex >= cards.length) {
    return (
      <div className={styles.container}>
        <div className={styles.summaryBox}>
          <div className={styles.iconBox}>🎉</div>
          <h2>Session Complete!</h2>
          <p>You have successfully reviewed {cards.length} flashcards.</p>
          <button className={styles.backBtn} onClick={onFinish}>Return to Hub</button>
        </div>
      </div>
    );
  }

  const card = cards[currentIndex];

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <button className={styles.closeBtn} onClick={onFinish}>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <line x1="18" y1="6" x2="6" y2="18"></line>
            <line x1="6" y1="6" x2="18" y2="18"></line>
          </svg>
          Exit Session
        </button>
        <div className={styles.progressCounter}>
          Card {currentIndex + 1} of {cards.length}
        </div>
      </div>

      <div className={`${styles.flashcard} ${isFlipped ? styles.flipped : ''}`}>
        <div className={styles.cardInner}>
          
          {/* FRONT */}
          <div className={styles.cardFront}>
            <div className={styles.cardMeta}>
              {card.skillName && <span className={styles.badgeSkill}>{card.skillName}</span>}
              <div className={styles.masteryWrapper}>
                <span className={styles.masteryText}>Mastery: {card.mastery}%</span>
                <div className={styles.masteryBar}>
                  <div className={styles.masteryFill} style={{ width: `${card.mastery}%` }}></div>
                </div>
              </div>
            </div>
            
            <div className={styles.questionText}>
              <h3>{card.question}</h3>
            </div>

            <button 
              className={styles.flipBtn}
              onClick={() => setIsFlipped(true)}
            >
              Show Answer
            </button>
          </div>

          {/* BACK */}
          <div className={styles.cardBack}>
            <div className={styles.cardMeta}>
              <span className={styles.badgeAnswer}>Answer</span>
              {card.difficulty && (
                <span className={styles.badgeDifficulty}>Previous: {card.difficulty}</span>
              )}
            </div>

            <div className={styles.answerText}>
              <p>{card.answer}</p>
            </div>

            <div className={styles.reviewSection}>
              <p className={styles.reviewPrompt}>How well did you know this?</p>
              <div className={styles.reviewButtons}>
                <button 
                  className={styles.btnForgot} 
                  onClick={() => handleReview('forgot')}
                  disabled={submitting}
                >
                  Forgot (Reset)
                </button>
                <button 
                  className={styles.btnHard} 
                  onClick={() => handleReview('hard')}
                  disabled={submitting}
                >
                  Hard
                </button>
                <button 
                  className={styles.btnMedium} 
                  onClick={() => handleReview('medium')}
                  disabled={submitting}
                >
                  Medium
                </button>
                <button 
                  className={styles.btnEasy} 
                  onClick={() => handleReview('easy')}
                  disabled={submitting}
                >
                  Easy
                </button>
              </div>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}
