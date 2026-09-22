import React, { createContext, useState, useEffect, useCallback } from 'react';
import { getCurrentUser } from '../services/authService';

export const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    const stored = localStorage.getItem('skillos_user');
    return stored ? JSON.parse(stored) : null;
  });
  const [loading, setLoading] = useState(true);

  const login = useCallback((token, userData) => {
    localStorage.setItem('skillos_token', token);
    localStorage.setItem('skillos_user', JSON.stringify(userData));
    setUser(userData);
  }, []);

  const logout = useCallback(() => {
    localStorage.removeItem('skillos_token');
    localStorage.removeItem('skillos_user');
    setUser(null);
  }, []);

  useEffect(() => {
    const token = localStorage.getItem('skillos_token');
    if (token) {
      getCurrentUser()
        .then((res) => {
          setUser(res.data);
          localStorage.setItem('skillos_user', JSON.stringify(res.data));
        })
        .catch(() => {
          logout();
        })
        .finally(() => setLoading(false));
    } else {
      setLoading(false);
    }
  }, [logout]);

  return (
    <AuthContext.Provider value={{ user, login, logout, loading, isAuthenticated: !!user, setUser }}>
      {children}
    </AuthContext.Provider>
  );
}
