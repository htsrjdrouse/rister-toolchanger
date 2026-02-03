import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';

function LoginModal({ isOpen, onClose }) {
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();

  if (!isOpen) return null;

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    const result = await login(password);

    setLoading(false);

    if (result.success) {
      setPassword('');
      onClose();
    } else {
      setError(result.error || 'Login failed');
    }
  };

  const handleOverlayClick = (e) => {
    if (e.target === e.currentTarget) {
      onClose();
    }
  };

  return (
    <div className="modal-overlay" onClick={handleOverlayClick}>
      <div className="modal-content">
        <h2 style={{ color: '#00d4ff', marginBottom: '20px' }}>
          🔐 Publisher Login
        </h2>
        
        <p style={{ color: '#888', marginBottom: '20px', fontSize: '14px' }}>
          Enter the publisher password to enable editing features.
        </p>

        <form onSubmit={handleSubmit}>
          <div style={{ marginBottom: '15px' }}>
            <label>Password:</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Enter publisher password"
              autoFocus
            />
          </div>

          {error && (
            <div className="alert" style={{ 
              background: 'rgba(245, 101, 101, 0.1)',
              border: '1px solid rgba(245, 101, 101, 0.3)',
              color: '#f56565',
              marginBottom: '15px'
            }}>
              {error}
            </div>
          )}

          <div className="btn-group" style={{ marginBottom: 0 }}>
            <button 
              type="submit" 
              className="btn" 
              disabled={loading || !password}
            >
              {loading ? 'Logging in...' : '🔓 Login'}
            </button>
            <button 
              type="button" 
              className="btn btn-secondary" 
              onClick={onClose}
            >
              Cancel
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default LoginModal;
