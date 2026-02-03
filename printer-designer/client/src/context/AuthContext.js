import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [authState, setAuthState] = useState({
    loading: true,
    isPublisher: false,
    passwordRequired: false,
    token: localStorage.getItem('publisherToken') || null
  });

  // Check auth status on mount and when token changes
  const checkAuthStatus = useCallback(async () => {
    try {
      const headers = {};
      if (authState.token) {
        headers['Authorization'] = `Bearer ${authState.token}`;
      }

      const response = await fetch('/api/auth/status', { headers });
      const data = await response.json();

      setAuthState(prev => ({
        ...prev,
        loading: false,
        isPublisher: data.isPublisher,
        passwordRequired: data.passwordRequired
      }));
    } catch (err) {
      console.error('Failed to check auth status:', err);
      setAuthState(prev => ({
        ...prev,
        loading: false,
        isPublisher: false
      }));
    }
  }, [authState.token]);

  useEffect(() => {
    checkAuthStatus();
  }, [checkAuthStatus]);

  // Login function
  const login = async (password) => {
    try {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ password })
      });

      const data = await response.json();

      if (data.success) {
        if (data.token) {
          localStorage.setItem('publisherToken', data.token);
        }
        setAuthState(prev => ({
          ...prev,
          isPublisher: true,
          token: data.token
        }));
        return { success: true };
      } else {
        return { success: false, error: data.error };
      }
    } catch (err) {
      return { success: false, error: err.message };
    }
  };

  // Logout function
  const logout = async () => {
    try {
      const headers = {};
      if (authState.token) {
        headers['Authorization'] = `Bearer ${authState.token}`;
      }

      await fetch('/api/auth/logout', {
        method: 'POST',
        headers
      });
    } catch (err) {
      console.error('Logout error:', err);
    }

    localStorage.removeItem('publisherToken');
    setAuthState(prev => ({
      ...prev,
      isPublisher: false,
      token: null
    }));
  };

  // Get auth headers for API requests
  const getAuthHeaders = () => {
    if (authState.token) {
      return { 'Authorization': `Bearer ${authState.token}` };
    }
    return {};
  };

  // Fetch wrapper that includes auth headers
  const authFetch = async (url, options = {}) => {
    const headers = {
      ...options.headers,
      ...getAuthHeaders()
    };

    const response = await fetch(url, { ...options, headers });

    // If we get a 403, we're no longer authenticated
    if (response.status === 403) {
      const data = await response.json();
      if (data.code === 'PUBLISHER_REQUIRED') {
        setAuthState(prev => ({
          ...prev,
          isPublisher: false
        }));
      }
    }

    return response;
  };

  const value = {
    ...authState,
    login,
    logout,
    authFetch,
    getAuthHeaders,
    refresh: checkAuthStatus
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
