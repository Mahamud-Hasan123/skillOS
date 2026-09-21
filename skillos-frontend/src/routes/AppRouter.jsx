import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import LandingPage from '../pages/LandingPage/LandingPage';
import AuthPage from '../pages/AuthPage/AuthPage';
import DashboardPage from '../pages/DashboardPage/DashboardPage';
import RoadmapListPage from '../pages/RoadmapListPage/RoadmapListPage';
import KnowledgePage from '../pages/KnowledgePage/KnowledgePage';
import { ErrorBoundary } from '../components/ErrorBoundary';
import ProtectedRoute from './ProtectedRoute';

import DashboardLayout from '../layouts/DashboardLayout';

const Placeholder = ({ title }) => (
  <DashboardLayout>
    <div style={{ padding: '40px', textAlign: 'center' }}>
      <h2>{title}</h2>
      <p style={{ color: 'var(--text-muted)' }}>This page is coming soon.</p>
    </div>
  </DashboardLayout>
);

export default function AppRouter() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/auth" element={<AuthPage />} />
        <Route path="/dashboard" element={<ProtectedRoute><DashboardPage /></ProtectedRoute>} />
        
        {/* New Sidebar Routes */}
        <Route path="/roadmaps" element={
          <ErrorBoundary>
            <ProtectedRoute><RoadmapListPage /></ProtectedRoute>
          </ErrorBoundary>
        } />

        <Route path="/knowledge" element={
          <ErrorBoundary>
            <ProtectedRoute><KnowledgePage /></ProtectedRoute>
          </ErrorBoundary>
        } />
      </Routes>
    </BrowserRouter>
  );
}
