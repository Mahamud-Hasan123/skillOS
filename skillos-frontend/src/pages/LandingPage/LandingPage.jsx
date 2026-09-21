import React, { useEffect, useRef } from 'react';
import { Link } from 'react-router-dom';
import Navbar from '../../components/Navbar/Navbar';
import Footer from '../../components/Footer/Footer';
import styles from './LandingPage.module.css';

export default function LandingPage() {
  const revealRefs = useRef([]);
  revealRefs.current = [];

  const addToRefs = (el) => {
    if (el && !revealRefs.current.includes(el)) {
      revealRefs.current.push(el);
    }
  };

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add(styles.visible);
          }
        });
      },
      { threshold: 0.12 }
    );

    revealRefs.current.forEach((el) => {
      observer.observe(el);
    });

    return () => {
      revealRefs.current.forEach((el) => {
        observer.unobserve(el);
      });
    };
  }, []);

  return (
    <div className={styles.landingWrapper}>
      <Navbar />

      {/* HERO SECTION */}
      <section className={styles.heroSection}>
        <div className={styles.hero}>
          {/* Left Side */}
          <div className={styles.heroLeft}>
            <div className={styles.heroBadge}>
              <span className={styles.heroBadgeDot}></span>
              AI-powered learning paths
            </div>
            <h1 className={styles.heroTitle}>
              Build skills.<br />
              Track progress.<br />
              <span className={styles.italic}>Stay accountable.</span>
            </h1>
            <p className={styles.heroSub}>
              Personalized roadmaps, peer accountability, and gamified progress — all in one beautifully designed learning OS.
            </p>
            <div className={styles.heroActions}>
              <Link className={styles.btnPrimary} to="/auth">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/>
                </svg>
                Get Started Free
              </Link>
              <a className={styles.btnGhost} href="#features">
                <div className={styles.playIcon}>
                  <svg viewBox="0 0 24 24">
                    <polygon points="5 3 19 12 5 21 5 3" fill="white"/>
                  </svg>
                </div>
                Watch Demo
              </a>
            </div>
            <div className={styles.heroSocialProof}>
              <div className={styles.avatarStack}>
                <div className={`${styles.avatarItem} ${styles.av1}`}>M</div>
                <div className={`${styles.avatarItem} ${styles.av2}`}>J</div>
                <div className={`${styles.avatarItem} ${styles.av3}`}>A</div>
                <div className={`${styles.avatarItem} ${styles.av4}`}>S</div>
              </div>
              <div>
                <div className={styles.stars}>★★★★★</div>
                <div className={styles.proofText}>
                  <strong>4.9/5</strong> from 2,100+ learners
                </div>
              </div>
            </div>
          </div>

          {/* Right Side - Preview Card */}
          <div className={styles.heroVisual}>
            <div style={{ position: 'relative' }}>
              <div className={styles.heroBgBlob}></div>
              <div className={styles.previewCard}>
                <div className={styles.previewCardHeader}>
                  <span className={styles.previewCardTitle}>Today's Focus</span>
                  <span className={styles.previewBadge}>3 tasks</span>
                </div>
                
                <div className={styles.previewTask}>
                  <div className={styles.taskInfo}>
                    <span className={styles.taskName}>Learn React Fundamentals</span>
                    <span className={styles.taskMeta}>Frontend · 45m</span>
                  </div>
                  <div className={styles.taskBarWrap}>
                    <div className={styles.taskBarBg}>
                      <div className={styles.taskBarFill} style={{ width: '78%', background: '#4f46e5' }}></div>
                    </div>
                  </div>
                  <span className={styles.taskPct}>78%</span>
                </div>

                <div className={styles.previewTask}>
                  <div className={styles.taskInfo}>
                    <span className={styles.taskName}>CSS Grid & Flexbox</span>
                    <span className={styles.taskMeta}>Frontend · 30m</span>
                  </div>
                  <div className={styles.taskBarWrap}>
                    <div className={styles.taskBarBg}>
                      <div className={styles.taskBarFill} style={{ width: '45%', background: '#10b981' }}></div>
                    </div>
                  </div>
                  <span className={styles.taskPct} style={{ color: '#10b981' }}>45%</span>
                </div>

                <div className={styles.previewTask}>
                  <div className={styles.taskInfo}>
                    <span className={styles.taskName}>JS Data Structures</span>
                    <span className={styles.taskMeta}>Backend · 60m</span>
                  </div>
                  <div className={styles.taskBarWrap}>
                    <div className={styles.taskBarBg}>
                      <div className={styles.taskBarFill} style={{ width: '20%', background: '#f59e0b' }}></div>
                    </div>
                  </div>
                  <span className={styles.taskPct} style={{ color: '#f59e0b' }}>20%</span>
                </div>
              </div>

              <div className={styles.previewFloatBadge}>
                <div>
                  <div className={styles.big}>+50 XP</div>
                  <div className={styles.sub}>earned today 🔥</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* FEATURES SECTION */}
      <section className={`${styles.featuresBg} ${styles.section}`} id="features">
        <div className={styles.sectionInner}>
          <div ref={addToRefs} className={`${styles.textCenter} ${styles.reveal}`}>
            <span className={styles.sectionTag}>Features</span>
            <h2 className={styles.sectionTitle}>Everything you need to learn</h2>
            <p className={styles.sectionSub}>
              From AI roadmaps to peer accountability — SkillOS keeps you focused, motivated, and on track.
            </p>
          </div>

          <div className={styles.featuresGrid}>
            <div ref={addToRefs} className={`${styles.featureCard} ${styles.reveal}`} style={{ transitionDelay: '0s' }}>
              <div className={styles.featureIcon}>
                <svg viewBox="0 0 24 24"><path d="M3 17l4-8 4 4 4-6 4 6"/><line x1="3" y1="21" x2="21" y2="21"/></svg>
              </div>
              <div className={styles.featureTitle}>AI Roadmaps</div>
              <div className={styles.featureDesc}>Personalized learning paths generated by AI, adapted to your goals, pace, and skill level.</div>
            </div>

            <div ref={addToRefs} className={`${styles.featureCard} ${styles.reveal}`} style={{ transitionDelay: '0.08s' }}>
              <div className={styles.featureIcon} style={{ background: '#ecfdf5' }}>
                <svg viewBox="0 0 24 24" style={{ stroke: '#10b981' }}><line x1="9" y1="11" x2="17" y2="11"/><line x1="9" y1="15" x2="17" y2="15"/><rect x="3" y="4" width="18" height="18" rx="2"/></svg>
              </div>
              <div className={styles.featureTitle}>Daily Tasks</div>
              <div className={styles.featureDesc}>Bite-sized tasks that fit your daily goals — never feel overwhelmed again.</div>
            </div>

            <div ref={addToRefs} className={`${styles.featureCard} ${styles.reveal}`} style={{ transitionDelay: '0.16s' }}>
              <div className={styles.featureIcon} style={{ background: '#fdf4ff' }}>
                <svg viewBox="0 0 24 24" style={{ stroke: '#a855f7' }}><circle cx="12" cy="8" r="4"/><path d="M6 20v-2a4 4 0 0 1 4-4h4a4 4 0 0 1 4 4v2"/></svg>
              </div>
              <div className={styles.featureTitle}>Peer Matching</div>
              <div className={styles.featureDesc}>Find accountability partners matched to your learning goals and timezone.</div>
            </div>

            <div ref={addToRefs} className={`${styles.featureCard} ${styles.reveal}`} style={{ transitionDelay: '0.24s' }}>
              <div className={styles.featureIcon} style={{ background: '#fffbeb' }}>
                <svg viewBox="0 0 24 24" style={{ stroke: '#f59e0b' }}><path d="M12 2l3 7h7l-5.5 4 2 7L12 16l-6.5 4 2-7L2 9h7z"/></svg>
              </div>
              <div className={styles.featureTitle}>Gamified XP</div>
              <div className={styles.featureDesc}>Earn XP, level up, and unlock achievements that make learning genuinely rewarding.</div>
            </div>

            <div ref={addToRefs} className={`${styles.featureCard} ${styles.reveal}`} style={{ transitionDelay: '0.32s' }}>
              <div className={styles.featureIcon} style={{ background: '#fef2f2' }}>
                <svg viewBox="0 0 24 24" style={{ stroke: '#ef4444' }}><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
              </div>
              <div className={styles.featureTitle}>Progress Tracking</div>
              <div className={styles.featureDesc}>Visual dashboards show exactly where you are and what to focus on next.</div>
            </div>

            <div ref={addToRefs} className={`${styles.featureCard} ${styles.reveal}`} style={{ transitionDelay: '0.4s' }}>
              <div className={styles.featureIcon} style={{ background: '#f0fdf4' }}>
                <svg viewBox="0 0 24 24" style={{ stroke: '#22c55e' }}><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
              </div>
              <div className={styles.featureTitle}>Knowledge Vault</div>
              <div className={styles.featureDesc}>Save notes, resources, and insights — build your personal knowledge base.</div>
            </div>
          </div>
        </div>
      </section>

      {/* PRICING SECTION */}
      <section className={styles.section} id="pricing">
        <div className={styles.sectionInner}>
          <div ref={addToRefs} className={`${styles.textCenter} ${styles.reveal}`}>
            <span className={styles.sectionTag}>Pricing</span>
            <h2 className={styles.sectionTitle}>Simple pricing</h2>
            <p className={styles.sectionSub}>
              Start free forever. Upgrade when you're ready to unlock the full learning experience.
            </p>
          </div>

          <div ref={addToRefs} className={`${styles.pricingGrid} ${styles.reveal}`}>
            {/* Free Plan */}
            <div className={styles.pricingCard}>
              <div className={styles.pricingPlan}>Free</div>
              <div className={styles.pricingPrice}>
                <span className={styles.dollar}>$</span>
                <span className={styles.amount}>0</span>
                <span className={styles.period}>/ month</span>
              </div>
              <div className={styles.pricingDesc}>Everything you need to get started on your learning journey.</div>
              <ul className={styles.pricingFeatures}>
                <li>
                  <svg viewBox="0 0 24 24" fill="none" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" stroke="#10b981"><polyline points="20 6 9 17 4 12"/></svg>
                  1 Active roadmap
                </li>
                <li>
                  <svg viewBox="0 0 24 24" fill="none" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" stroke="#10b981"><polyline points="20 6 9 17 4 12"/></svg>
                  Daily tasks
                </li>
                <li>
                  <svg viewBox="0 0 24 24" fill="none" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" stroke="#10b981"><polyline points="20 6 9 17 4 12"/></svg>
                  Basic XP tracking
                </li>
                <li>
                  <svg viewBox="0 0 24 24" fill="none" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" stroke="#10b981"><polyline points="20 6 9 17 4 12"/></svg>
                  Community access
                </li>
              </ul>
              <Link to="/auth" className={`${styles.btnPricing} ${styles.btnPricingOutline}`}>Start Free</Link>
            </div>

            {/* Pro Plan */}
            <div className={`${styles.pricingCard} ${styles.popular}`}>
              <span className={styles.popularBadge}>🔥 Most Popular</span>
              <div className={styles.pricingPlan} style={{ color: 'rgba(255,255,255,.7)' }}>Pro</div>
              <div className={styles.pricingPrice} style={{ color: '#fff' }}>
                <span className={styles.dollar}>$</span>
                <span className={styles.amount}>12</span>
                <span className={styles.period}>/ month</span>
              </div>
              <div className={styles.pricingDesc} style={{ color: 'rgba(255,255,255,.7)' }}>
                Unlock the full SkillOS experience with AI, peers & more.
              </div>
              <ul className={styles.pricingFeatures} style={{ color: '#fff' }}>
                <li>
                  <svg viewBox="0 0 24 24" fill="none" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" stroke="#a5f3fc"><polyline points="20 6 9 17 4 12"/></svg>
                  Unlimited roadmaps
                </li>
                <li>
                  <svg viewBox="0 0 24 24" fill="none" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" stroke="#a5f3fc"><polyline points="20 6 9 17 4 12"/></svg>
                  AI Task generation
                </li>
                <li>
                  <svg viewBox="0 0 24 24" fill="none" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" stroke="#a5f3fc"><polyline points="20 6 9 17 4 12"/></svg>
                  Priority peer matching
                </li>
                <li>
                  <svg viewBox="0 0 24 24" fill="none" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" stroke="#a5f3fc"><polyline points="20 6 9 17 4 12"/></svg>
                  All analytics reports
                </li>
                <li>
                  <svg viewBox="0 0 24 24" fill="none" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" stroke="#a5f3fc"><polyline points="20 6 9 17 4 12"/></svg>
                  Custom themes
                </li>
              </ul>
              <Link to="/auth" className={`${styles.btnPricing} ${styles.btnPricingWhite}`}>Go Pro</Link>
            </div>
          </div>
        </div>
      </section>

      {/* CTA BANNER */}
      <section className={styles.ctaSection} id="about">
        <div ref={addToRefs} className={`${styles.ctaInner} ${styles.reveal}`}>
          <h2 className={styles.ctaTitle}>Ready to <span className={styles.italic}>level up?</span></h2>
          <p className={styles.ctaSub}>Join 12,000+ learners building skills every day with SkillOS.</p>
          <Link className={styles.btnCta} to="/auth">
            Start Learning Free
            <svg viewBox="0 0 24 24"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
          </Link>
        </div>
      </section>

      <Footer />
    </div>
  );
}
