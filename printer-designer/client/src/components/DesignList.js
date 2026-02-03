import React, { useState, useRef } from 'react';
import { useAuth } from '../context/AuthContext';

function DesignList({ designs, onLoadDesign, onCreateDesign, onRefresh, isPublisher, publishedDesignId, onPublishChange }) {
  const [newName, setNewName] = useState('');
  const fileInputRef = useRef(null);
  const { authFetch } = useAuth();

  const handlePublish = async (id, name) => {
    if (!isPublisher) {
      alert('Publisher access required');
      return;
    }
    
    if (!window.confirm(`Publish "${name}"? Viewers will automatically see this design.`)) return;
    
    try {
      const response = await authFetch(`/api/designs/${id}/publish`, { method: 'POST' });
      if (response.ok) {
        alert(`"${name}" is now published!`);
        onPublishChange();
      } else {
        alert('Failed to publish');
      }
    } catch (err) {
      console.error('Failed to publish:', err);
    }
  };

  const handleUnpublish = async () => {
    if (!isPublisher) return;
    
    if (!window.confirm('Unpublish? Viewers will no longer auto-load any design.')) return;
    
    try {
      const response = await authFetch('/api/published/unpublish', { method: 'POST' });
      if (response.ok) {
        alert('Design unpublished');
        onPublishChange();
      }
    } catch (err) {
      console.error('Failed to unpublish:', err);
    }
  };

  const handleCreate = () => {
    const name = newName.trim() || 'New Design';
    onCreateDesign(name);
    setNewName('');
  };

  const handleDelete = async (id, name) => {
    if (!isPublisher) {
      alert('Publisher access required to delete designs');
      return;
    }
    if (!window.confirm(`Delete "${name}"? This cannot be undone.`)) return;
    
    try {
      const response = await authFetch(`/api/designs/${id}`, { method: 'DELETE' });
      if (response.status === 403) {
        alert('Publisher access required');
        return;
      }
      onRefresh();
    } catch (err) {
      console.error('Failed to delete:', err);
    }
  };

  const handleClone = async (id) => {
    if (!isPublisher) {
      alert('Publisher access required to clone designs');
      return;
    }
    try {
      const response = await authFetch(`/api/designs/${id}/clone`, { method: 'POST' });
      if (response.status === 403) {
        alert('Publisher access required');
        return;
      }
      onRefresh();
    } catch (err) {
      console.error('Failed to clone:', err);
    }
  };

  const handleExport = (id, name) => {
    window.open(`/api/designs/${id}/export`, '_blank');
  };

  const handleImport = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    if (!isPublisher) {
      alert('Publisher access required to import designs');
      e.target.value = '';
      return;
    }

    try {
      const text = await file.text();
      const data = JSON.parse(text);
      
      const response = await authFetch('/api/designs/import', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
      });
      
      if (response.status === 403) {
        alert('Publisher access required');
      } else {
        onRefresh();
      }
    } catch (err) {
      alert('Failed to import: ' + err.message);
    }
    
    e.target.value = '';
  };

  const formatDate = (dateStr) => {
    return new Date(dateStr).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  return (
    <div>
      {/* Create New Design - Publisher Only */}
      {isPublisher && (
        <div className="section">
          <h3 className="section-title">➕ Create New Design</h3>
          <div style={{ display: 'flex', gap: '10px' }}>
            <input
              type="text"
              placeholder="Design name..."
              value={newName}
              onChange={(e) => setNewName(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && handleCreate()}
              style={{ flex: 1 }}
            />
            <button className="btn" onClick={handleCreate}>Create</button>
          </div>
        </div>
      )}

      {/* Import/Export */}
      <div className="section">
        <h3 className="section-title">📁 {isPublisher ? 'Import / Export' : 'Export'}</h3>
        <div className="btn-group">
          {isPublisher && (
            <>
              <button className="btn btn-secondary" onClick={() => fileInputRef.current?.click()}>
                📥 Import Design
              </button>
              <input
                ref={fileInputRef}
                type="file"
                accept=".json"
                onChange={handleImport}
                style={{ display: 'none' }}
              />
            </>
          )}
          <button className="btn btn-secondary" onClick={onRefresh}>
            🔄 Refresh List
          </button>
        </div>
      </div>

      {/* Design List */}
      <div className="section">
        <h3 className="section-title">📋 Saved Designs ({designs.length})</h3>
        
        {designs.length === 0 ? (
          <div className="alert alert-info">
            No designs yet. Create one above to get started!
          </div>
        ) : (
          <div className="design-grid">
            {designs.map((design) => (
              <div key={design.id} className="design-card" style={publishedDesignId === design.id ? { borderColor: '#48bb78', borderWidth: '2px' } : {}}>
                <div className="design-card-title">
                  {publishedDesignId === design.id && <span style={{ color: '#48bb78', marginRight: '8px' }}>📢</span>}
                  {design.name}
                  {publishedDesignId === design.id && (
                    <span style={{ 
                      background: 'rgba(72, 187, 120, 0.2)', 
                      color: '#48bb78', 
                      fontSize: '10px', 
                      padding: '2px 6px', 
                      borderRadius: '4px', 
                      marginLeft: '8px' 
                    }}>
                      PUBLISHED
                    </span>
                  )}
                </div>
                <div className="design-card-meta">
                  {design.description || 'No description'}
                </div>
                <div className="design-card-stats">
                  <span className="design-card-stat">
                    📦 {design.objectCount} objects
                  </span>
                  <span className="design-card-stat">
                    💧 {design.tipCount} tips
                  </span>
                  <span className="design-card-stat">
                    ⚙️ {design.macroCount || 0} macros
                  </span>
                </div>
                <div className="design-card-meta">
                  Updated: {formatDate(design.updatedAt)}
                </div>
                <div className="btn-group" style={{ marginTop: '15px', marginBottom: 0 }}>
                  <button className="btn btn-sm" onClick={() => onLoadDesign(design.id)}>
                    {isPublisher ? '✏️ Edit' : '👁️ View'}
                  </button>
                  {isPublisher && (
                    <>
                      {publishedDesignId === design.id ? (
                        <button className="btn btn-sm btn-secondary" onClick={handleUnpublish}>
                          📢 Unpublish
                        </button>
                      ) : (
                        <button className="btn btn-sm btn-success" onClick={() => handlePublish(design.id, design.name)}>
                          📢 Publish
                        </button>
                      )}
                      <button className="btn btn-sm btn-secondary" onClick={() => handleClone(design.id)}>
                        📋 Clone
                      </button>
                    </>
                  )}
                  <button className="btn btn-sm btn-warning" onClick={() => handleExport(design.id, design.name)}>
                    📤 Export
                  </button>
                  {isPublisher && (
                    <button className="btn btn-sm btn-danger" onClick={() => handleDelete(design.id, design.name)}>
                      🗑️
                    </button>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

export default DesignList;
