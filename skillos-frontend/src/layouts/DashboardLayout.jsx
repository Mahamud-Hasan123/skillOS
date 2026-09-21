import React, { useState } from 'react';
import Sidebar from '../components/Sidebar/Sidebar';
import Topbar from '../components/Topbar/Topbar';
import styles from './DashboardLayout.module.css';

export default function DashboardLayout({ children }) {
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);

  const handleToggleSidebar = () => {
    setSidebarCollapsed(!sidebarCollapsed);
  };

  return (
    <div className={styles.layoutContainer}>
      <Sidebar collapsed={sidebarCollapsed} onToggle={handleToggleSidebar} />
      
      <div className={`${styles.mainContent} ${sidebarCollapsed ? styles.collapsed : ''}`}>
        <Topbar onToggleSidebar={handleToggleSidebar} />
        <main className={styles.contentBody}>
          {children}
        </main>
      </div>
    </div>
  );
}
