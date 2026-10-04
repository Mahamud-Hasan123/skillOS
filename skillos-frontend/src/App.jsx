import React from 'react';
import { AuthProvider } from './context/AuthContext';
import AppRouter from './routes/AppRouter';
import GlobalToasts from './components/GlobalToasts/GlobalToasts';
import './styles/global.css';

export default function App() {
  return (
    <AuthProvider>
      <AppRouter />
      <GlobalToasts />
    </AuthProvider>
  );
}
