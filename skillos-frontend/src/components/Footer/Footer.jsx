import React from 'react';
import { Link } from 'react-router-dom';
import styles from './Footer.module.css';

export default function Footer() {
  return (
    <footer className={styles.footer}>
      <div className={styles.footerGrid}>
        <div className={styles.footerBrand}>
          <Link className={styles.navLogo} to="/">
            <div className={styles.navLogoMark}>S</div>
            <span className={styles.navLogoText}>SkillOS</span>
          </Link>
          <p>Your personal learning operating system. Build skills, track progress, and stay accountable — every day.</p>
        </div>
        <div className={styles.footerCol}>
          <h4>Product</h4>
          <a href="#features">Features</a>
          <a href="#pricing">Pricing</a>
          <a href="#about">Roadmap</a>
          <a href="#about">Changelog</a>
        </div>
        <div className={styles.footerCol}>
          <h4>Company</h4>
          <a href="#about">About</a>
          <a href="#about">Blog</a>
          <a href="#about">Careers</a>
          <a href="#about">Contact</a>
        </div>
        <div className={styles.footerCol}>
          <h4>Resources</h4>
          <a href="#about">Docs</a>
          <a href="#about">Community</a>
          <a href="#about">Support</a>
          <a href="#about">Status</a>
        </div>
      </div>
      <div className={styles.footerBottom}>
        <span>© 2026 SkillOS. All rights reserved.</span>
        <span>Privacy · Terms · Cookies</span>
      </div>
    </footer>
  );
}
