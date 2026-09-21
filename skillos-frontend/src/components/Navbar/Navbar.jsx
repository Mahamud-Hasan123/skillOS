import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import styles from './Navbar.module.css';

export default function Navbar() {
  const [mobileOpen, setMobileOpen] = useState(false);
  const navigate = useNavigate();

  const handleMobileToggle = () => {
    setMobileOpen(!mobileOpen);
  };

  return (
    <nav className={styles.nav}>
      <Link className={styles.navLogo} to="/">
        <div className={styles.navLogoMark}>S</div>
        <span className={styles.navLogoText}>SkillOS</span>
      </Link>
      
      <div className={`${styles.navLinks} ${mobileOpen ? styles.mobileOpen : ''}`}>
        <a href="#features" onClick={() => setMobileOpen(false)}>Features</a>
        <a href="#pricing" onClick={() => setMobileOpen(false)}>Pricing</a>
        <a href="#about" onClick={() => setMobileOpen(false)}>About</a>
        {mobileOpen && (
          <Link className={styles.navCtaMobile} to="/auth" onClick={() => setMobileOpen(false)}>
            Get Started Free
          </Link>
        )}
      </div>

      <Link className={styles.navCta} to="/auth">Get Started Free</Link>
      
      <button 
        className={`${styles.navMobileBtn} ${mobileOpen ? styles.btnActive : ''}`} 
        onClick={handleMobileToggle}
        aria-label="Menu"
      >
        <span></span>
        <span></span>
        <span></span>
      </button>
    </nav>
  );
}
