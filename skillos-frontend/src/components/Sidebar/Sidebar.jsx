import React from 'react';
import { NavLink } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';
import styles from './Sidebar.module.css';

export default function Sidebar({ collapsed, onToggle }) {
  const { user } = useAuth();

  const userName = user?.fullName || 'demo';
  const userInitials = userName.charAt(0).toUpperCase();

  return (
    <aside className={`${styles.sidebar} ${collapsed ? styles.collapsed : ''}`}>
      <div className={styles.logo}>
        <div className={styles.logoIcon}>S</div>
        <span className={styles.logoText}>SkillOS</span>
        <button 
          className={styles.collapseBtn} 
          onClick={onToggle}
          title={collapsed ? "Expand sidebar" : "Collapse sidebar"}
        >
          <svg viewBox="0 0 24 24" style={{ transform: collapsed ? 'rotate(180deg)' : 'none' }}>
            <polyline points="15 18 9 12 15 6" />
          </svg>
        </button>
      </div>

      <nav className={styles.navMenu}>
        <NavLink 
          to="/dashboard" 
          className={({ isActive }) => `${styles.navItem} ${isActive ? styles.active : ''}`}
        >
          <span className={styles.navIcon}>
            <svg viewBox="0 0 24 24">
              <rect x="3" y="3" width="7" height="9" />
              <rect x="14" y="3" width="7" height="5" />
              <rect x="14" y="12" width="7" height="9" />
              <rect x="3" y="16" width="7" height="5" />
            </svg>
          </span>
          <span className={styles.navLabel}>Dashboard</span>
        </NavLink>

        <NavLink 
          to="/roadmaps" 
          className={({ isActive }) => `${styles.navItem} ${isActive ? styles.active : ''}`}
        >
          <span className={styles.navIcon}>
            <svg viewBox="0 0 24 24">
              <polygon points="12 2 2 7 12 12 22 7 12 2" />
              <polyline points="2 17 12 22 22 17" />
              <polyline points="2 12 12 17 22 12" />
            </svg>
          </span>
          <span className={styles.navLabel}>Roadmap</span>
        </NavLink>

        <NavLink 
          to="/knowledge" 
          className={({ isActive }) => `${styles.navItem} ${isActive ? styles.active : ''}`}
        >
          <span className={styles.navIcon}>
            <svg viewBox="0 0 24 24">
              <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z" />
              <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z" />
            </svg>
          </span>
          <span className={styles.navLabel}>Knowledge</span>
        </NavLink>
      </nav>

      <div className={styles.sidebarBottom}>
        <div className={styles.userCard}>
          <div className={styles.userAvatar}>{userInitials}</div>
          <div className={styles.userInfo}>
            <div className={styles.userName}>{userName}</div>
          </div>
        </div>
      </div>
    </aside>
  );
}
