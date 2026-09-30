import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { generateRoadmap, getRoadmapGenerationStatus } from '../../services/roadmapService';
import styles from './GenerateRoadmapModal.module.css';

export default function GenerateRoadmapModal({ onClose, onSuccess }) {
  const navigate = useNavigate();

  // Form Fields
  const [skillGoal, setSkillGoal] = useState('');
  const [dailyTimeMinutes, setDailyTimeMinutes] = useState(60);
  const [durationMonths, setDurationMonths] = useState(3);
  const [goalPurpose, setGoalPurpose] = useState('job');
  const [level, setLevel] = useState('beginner');
  const [experienceDescription, setExperienceDescription] = useState('');
  const [focusAreasText, setFocusAreasText] = useState('');

  // UI State
  const [generating, setGenerating] = useState(false);
  const [status, setStatus] = useState('');
  const [progress, setProgress] = useState(0);
  const [error, setError] = useState('');

  const handleStartGeneration = async (e) => {
    e.preventDefault();
    setError('');

    if (!skillGoal.trim()) {
      setError('Please enter a learning goal (e.g. React Frontend Developer).');
      return;
    }

    const focusAreas = focusAreasText
      .split(',')
      .map(tag => tag.trim())
      .filter(tag => tag.length > 0);

    const payload = {
      skillGoal,
      dailyTimeMinutes,
      durationMonths,
      goalPurpose,
      level,
      experienceDescription: experienceDescription || null,
      focusAreas: focusAreas.length > 0 ? focusAreas : null
    };

    setGenerating(true);
    setProgress(5);
    setStatus('Initializing AI Generator...');

    try {
      const res = await generateRoadmap(payload);
      const { job_id } = res.data;
      setStatus('Prompt sent to Gemini AI...');
      setProgress(15);
      
      startPolling(job_id);
    } catch (err) {
      console.error(err);
      setError(err.response?.data?.message || err.response?.data?.error || 'Failed to submit roadmap request. Please try again.');
      setGenerating(false);
    }
  };

  const startPolling = (id) => {
    let attempts = 0;
    const interval = setInterval(async () => {
      attempts++;
      if (attempts > 150) {
        clearInterval(interval);
        setError('Roadmap generation timed out. Please try again later.');
        setGenerating(false);
        return;
      }

      try {
        const statusRes = await getRoadmapGenerationStatus(id);
        const { status: jobStatus, progress_percent, result_id, error: jobError } = statusRes.data;

        setProgress(progress_percent || 20);

        if (jobStatus === 'processing') {
          setStatus('AI is constructing curriculum chapters and daily lessons...');
        } else if (jobStatus === 'complete') {
          setStatus('Roadmap created successfully! Loading timeline...');
          clearInterval(interval);
          setTimeout(() => {
            if (onSuccess) onSuccess(result_id);
            else onClose();
          }, 1000);
        } else if (jobStatus === 'failed') {
          setError(jobError || 'Gemini AI failed to structure the roadmap. Please try again.');
          clearInterval(interval);
          setGenerating(false);
        }
      } catch (err) {
        console.error('Polling error:', err);
        if (attempts > 10) {
          clearInterval(interval);
          setError('Lost connection to backend server. Roadmap generation may still be running.');
          setGenerating(false);
        }
      }
    }, 2500);
  };

  return (
    <div className={styles.modalBackdrop} onClick={onClose}>
      <div className={styles.modalContent} onClick={e => e.stopPropagation()}>
        <button className={styles.closeBtn} onClick={onClose}>×</button>
        
        {!generating ? (
          <div className={styles.formContainer}>
            <div className={styles.header}>
              <div className={styles.iconBox}>🤖</div>
              <div>
                <h2 className={styles.title}>Generate New Roadmap</h2>
                <p className={styles.subtitle}>Provide your goals, and let AI build a custom daily study plan.</p>
              </div>
            </div>

            {error && <div className={styles.errorAlert}>{error}</div>}

            <form onSubmit={handleStartGeneration} className={styles.form}>
              
              <div className={styles.formGroup}>
                <div className={styles.labelRow}>
                  <label htmlFor="skill-goal">Target Skill / Goal <span className={styles.required}>*</span></label>
                  <div className={styles.tooltipWrapper}>
                    <span className={styles.infoIcon}>i</span>
                    <div className={styles.tooltipContent}>This defines the core theme of your roadmap. Be as specific as you like.</div>
                  </div>
                </div>
                <input 
                  id="skill-goal"
                  type="text" 
                  placeholder="e.g. Fullstack Web Developer, Machine Learning" 
                  value={skillGoal}
                  onChange={(e) => setSkillGoal(e.target.value)}
                  required
                  className={styles.textInput}
                />
              </div>

              <div className={styles.grid2}>
                <div className={styles.formGroup}>
                  <div className={styles.labelRow}>
                    <label htmlFor="level">Experience Level <span className={styles.required}>*</span></label>
                    <div className={styles.tooltipWrapper}>
                      <span className={styles.infoIcon}>i</span>
                      <div className={styles.tooltipContent}>"Beginner" starts from absolute basics, while "Advanced" skips fundamentals.</div>
                    </div>
                  </div>
                  <select id="level" value={level} onChange={(e) => setLevel(e.target.value)} className={styles.selectInput}>
                    <option value="beginner">Beginner</option>
                    <option value="intermediate">Intermediate</option>
                    <option value="advanced">Advanced</option>
                  </select>
                </div>

                <div className={styles.formGroup}>
                  <div className={styles.labelRow}>
                    <label htmlFor="purpose">Goal Purpose <span className={styles.required}>*</span></label>
                    <div className={styles.tooltipWrapper}>
                      <span className={styles.infoIcon}>i</span>
                      <div className={styles.tooltipContent}>Helps the AI tailor projects towards portfolio-building vs theoretical learning.</div>
                    </div>
                  </div>
                  <select id="purpose" value={goalPurpose} onChange={(e) => setGoalPurpose(e.target.value)} className={styles.selectInput}>
                    <option value="job">Career / Find a Job</option>
                    <option value="education">Academic / School</option>
                    <option value="other">Hobby / Personal Interest</option>
                  </select>
                </div>
              </div>

              <div className={styles.grid2}>
                <div className={styles.formGroup}>
                  <div className={styles.labelRow}>
                    <label htmlFor="daily-time">Daily Commitment <span className={styles.required}>*</span></label>
                    <div className={styles.tooltipWrapper}>
                      <span className={styles.infoIcon}>i</span>
                      <div className={styles.tooltipContent}>The AI will break down daily tasks to fit inside this time constraint.</div>
                    </div>
                  </div>
                  <select id="daily-time" value={dailyTimeMinutes} onChange={(e) => setDailyTimeMinutes(parseInt(e.target.value))} className={styles.selectInput}>
                    <option value="15">15 mins/day</option>
                    <option value="30">30 mins/day</option>
                    <option value="60">1 hour/day</option>
                    <option value="120">2 hours/day</option>
                    <option value="240">4 hours/day</option>
                  </select>
                </div>

                <div className={styles.formGroup}>
                  <div className={styles.labelRow}>
                    <label htmlFor="duration">Target Duration <span className={styles.required}>*</span></label>
                    <div className={styles.tooltipWrapper}>
                      <span className={styles.infoIcon}>i</span>
                      <div className={styles.tooltipContent}>How long you plan to study before achieving mastery in this skill.</div>
                    </div>
                  </div>
                  <select id="duration" value={durationMonths} onChange={(e) => setDurationMonths(parseInt(e.target.value))} className={styles.selectInput}>
                    <option value="1">1 Month</option>
                    <option value="2">2 Months</option>
                    <option value="3">3 Months</option>
                    <option value="4">4 Months</option>
                    <option value="5">5 Months</option>
                    <option value="6">6 Months</option>
                    <option value="12">1 Year</option>
                  </select>
                </div>
              </div>

              <div className={styles.formGroup}>
                <div className={styles.labelRow}>
                  <label htmlFor="focus-areas">Focus Areas</label>
                  <div className={styles.tooltipWrapper}>
                    <span className={styles.infoIcon}>i</span>
                    <div className={styles.tooltipContent}>Optional. Comma-separated list of specific sub-topics you want the AI to ensure are covered.</div>
                  </div>
                </div>
                <input 
                  id="focus-areas"
                  type="text" 
                  placeholder="e.g. NextJS, PostgreSQL, React Router" 
                  value={focusAreasText}
                  onChange={(e) => setFocusAreasText(e.target.value)}
                  className={styles.textInput}
                />
              </div>

              <div className={styles.formGroup}>
                <div className={styles.labelRow}>
                  <label htmlFor="experience">Current Experience</label>
                  <div className={styles.tooltipWrapper}>
                    <span className={styles.infoIcon}>i</span>
                    <div className={styles.tooltipContent}>Optional. Describe what you already know so the AI doesn't waste days teaching it.</div>
                  </div>
                </div>
                <textarea 
                  id="experience"
                  placeholder="I already know HTML/CSS but struggle with JS..." 
                  value={experienceDescription}
                  onChange={(e) => setExperienceDescription(e.target.value)}
                  className={styles.textareaInput}
                  rows={2}
                />
              </div>

              <div className={styles.actions}>
                <button type="button" className={styles.cancelBtn} onClick={onClose}>Cancel</button>
                <button type="submit" className={styles.submitBtn}>
                  Generate Roadmap
                </button>
              </div>
            </form>
          </div>
        ) : (
          <div className={styles.loadingContainer}>
            <div className={styles.loaderBox}>
              <div className={styles.loaderSpinner}></div>
              <div className={styles.glowingBrain}>🧠</div>
            </div>
            
            <h3 className={styles.loadingTitle}>Building Your Curriculum...</h3>
            <p className={styles.statusText}>{status}</p>
            
            <div className={styles.loadingBarBg}>
              <div className={styles.loadingBarFill} style={{ width: `${progress}%` }}></div>
            </div>
            
            <span className={styles.pctText}>{progress}% Completed</span>
            <p className={styles.infoNote}>Please wait while our AI engine researches and structures your personalized daily study plan. This typically takes 10-25 seconds.</p>
          </div>
        )}
      </div>
    </div>
  );
}
