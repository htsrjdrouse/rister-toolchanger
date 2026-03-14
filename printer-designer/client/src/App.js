import React, { useState, useEffect } from 'react';
import { AuthProvider, useAuth } from './context/AuthContext';
import DesignList from './components/DesignList';
import ObjectEditor from './components/ObjectEditor';
import TipManagement from './components/TipManagement';
import GcodeBuilder from './components/GcodeBuilder';
import ShapeDesigner from './components/ShapeDesigner';
import CalibrationArrayGenerator from './components/CalibrationArrayGenerator';
import LoginModal from './components/LoginModal';

function AppContent() {
  const [activeTab, setActiveTab] = useState('designs');
  const [currentDesign, setCurrentDesign] = useState(null);
  const [designs, setDesigns] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showLogin, setShowLogin] = useState(false);
  const [publishedDesignId, setPublishedDesignId] = useState(null);

  const { isPublisher, passwordRequired, loading: authLoading, logout, authFetch } = useAuth();

  // Load designs and check for published design on mount
  useEffect(() => {
    loadDesigns();
    checkPublished();
    // Auto-load last used design
    const lastId = localStorage.getItem('lastDesignId');
    if (lastId) loadDesign(lastId);
  }, []);

  // Listen for navigation events
  useEffect(() => {
    const handleNavigate = () => setActiveTab('calibration');
    window.addEventListener('navigate-to-calibration', handleNavigate);
    return () => window.removeEventListener('navigate-to-calibration', handleNavigate);
  }, []);

  // Auto-load published design for viewers
  useEffect(() => {
    if (!authLoading && !isPublisher && publishedDesignId && !currentDesign) {
      loadDesign(publishedDesignId);
    }
  }, [authLoading, isPublisher, publishedDesignId]);

  const checkPublished = async () => {
    try {
      const response = await fetch('/api/published/status');
      const data = await response.json();
      setPublishedDesignId(data.publishedDesignId);
    } catch (err) {
      console.error('Failed to check published status:', err);
    }
  };

  const loadDesigns = async () => {
    try {
      const response = await fetch('/api/designs');
      const data = await response.json();
      setDesigns(data);
    } catch (err) {
      console.error('Failed to load designs:', err);
    } finally {
      setLoading(false);
    }
  };

  const loadDesign = async (id) => {
    try {
      const response = await fetch(`/api/designs/${id}`);
      const data = await response.json();
      setCurrentDesign(data);
      setActiveTab('objects');
      localStorage.setItem('lastDesignId', id);
    } catch (err) {
      console.error('Failed to load design:', err);
    }
  };

  const saveDesign = async (updates) => {
    if (!currentDesign) return;
    
    try {
      const response = await authFetch(`/api/designs/${currentDesign.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ...currentDesign, ...updates })
      });
      
      if (response.status === 403) {
        alert('Publisher access required to save changes');
        return;
      }
      
      const data = await response.json();
      setCurrentDesign(data);
      loadDesigns();
    } catch (err) {
      console.error('Failed to save design:', err);
    }
  };

  const createDesign = async (name = 'New Design') => {
    try {
      const response = await authFetch('/api/designs', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name })
      });
      
      if (response.status === 403) {
        alert('Publisher access required to create designs');
        return;
      }
      
      const data = await response.json();
      setCurrentDesign(data);
      setActiveTab('objects');
      loadDesigns();
    } catch (err) {
      console.error('Failed to create design:', err);
    }
  };

  const closeDesign = () => {
    setCurrentDesign(null);
    setActiveTab('designs');
  };

  if (authLoading) {
    return (
      <div className="app">
        <div className="loading">Loading...</div>
      </div>
    );
  }

  return (
    <div className="app">
      <header className="app-header">
        <h1>🖨️ Printer Designer</h1>
        <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
          {currentDesign && (
            <div className="current-design">
              <span className="design-name">{currentDesign.name}</span>
              <button className="btn btn-sm" onClick={closeDesign}>✕ Close</button>
            </div>
          )}
          
          {/* Auth Status */}
          {isPublisher ? (
            <div className="auth-badge publisher">
              ✏️ Publisher
              {passwordRequired && (
                <button 
                  className="btn btn-sm btn-secondary" 
                  onClick={logout}
                  style={{ marginLeft: '8px', padding: '3px 8px' }}
                >
                  Logout
                </button>
              )}
            </div>
          ) : (
            <div className="auth-badge viewer">
              👁️ Viewer
              {passwordRequired && (
                <button 
                  className="btn btn-sm" 
                  onClick={() => setShowLogin(true)}
                  style={{ marginLeft: '8px', padding: '3px 8px' }}
                >
                  Login
                </button>
              )}
            </div>
          )}
        </div>
      </header>

      <nav className="tab-nav">
        <button 
          className={`tab-btn ${activeTab === 'designs' ? 'active' : ''}`}
          onClick={() => setActiveTab('designs')}
        >
          📁 Designs
        </button>
        <button 
          className={`tab-btn ${activeTab === 'objects' ? 'active' : ''}`}
          onClick={() => setActiveTab('objects')}
          disabled={!currentDesign}
        >
          📦 Object Editor
        </button>
        <button 
          className={`tab-btn ${activeTab === 'tips' ? 'active' : ''}`}
          onClick={() => setActiveTab('tips')}
          disabled={!currentDesign}
        >
          💧 Tip Management
        </button>
        <button 
          className={`tab-btn ${activeTab === 'gcode' ? 'active' : ''}`}
          onClick={() => setActiveTab('gcode')}
          disabled={!currentDesign}
        >
          ⚙️ G-code Builder
        </button>
        <button 
          className={`tab-btn ${activeTab === 'shapes' ? 'active' : ''}`}
          onClick={() => setActiveTab('shapes')}
        >
          🔬 Shape Designer
        </button>
        <button 
          className={`tab-btn ${activeTab === 'calibration' ? 'active' : ''}`}
          onClick={() => setActiveTab('calibration')}
        >
          ⚗️ Calibration Array
        </button>
      </nav>

      <main className="main-content">
        {/* Viewer Banner */}
        {!isPublisher && passwordRequired && (
          <div className="viewer-banner">
            <span>👁️ Viewing in read-only mode. Login to make changes.</span>
            <button className="btn btn-sm" onClick={() => setShowLogin(true)}>
              🔐 Login as Publisher
            </button>
          </div>
        )}

        {loading ? (
          <div className="loading">Loading...</div>
        ) : (
          <>
            {activeTab === 'designs' && (
              <DesignList 
                designs={designs}
                onLoadDesign={loadDesign}
                onCreateDesign={createDesign}
                onRefresh={() => { loadDesigns(); checkPublished(); }}
                isPublisher={isPublisher}
                publishedDesignId={publishedDesignId}
                onPublishChange={checkPublished}
              />
            )}
            {activeTab === 'objects' && currentDesign && (
              <ObjectEditor 
                design={currentDesign}
                onSave={saveDesign}
                isPublisher={isPublisher}
              />
            )}
            {activeTab === 'tips' && currentDesign && (
              <TipManagement 
                design={currentDesign}
                onSave={saveDesign}
                isPublisher={isPublisher}
              />
            )}
            {activeTab === 'gcode' && currentDesign && (
              <GcodeBuilder 
                design={currentDesign}
                onSave={saveDesign}
                isPublisher={isPublisher}
              />
            )}
            {activeTab === 'shapes' && (
              <ShapeDesigner 
                design={currentDesign}
                onSave={saveDesign}
                isPublisher={isPublisher}
              />
            )}
            {activeTab === 'calibration' && (
              <CalibrationArrayGenerator />
            )}
          </>
        )}
      </main>

      <LoginModal 
        isOpen={showLogin} 
        onClose={() => setShowLogin(false)} 
      />
    </div>
  );
}

function App() {
  return (
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  );
}

export default App;
