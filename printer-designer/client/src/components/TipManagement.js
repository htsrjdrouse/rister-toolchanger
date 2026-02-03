import React, { useState, useEffect } from 'react';

function TipManagement({ design, onSave, isPublisher = true }) {
  const [tips, setTips] = useState(design.tips || []);
  const [activeTipIndex, setActiveTipIndex] = useState(design.activeTipIndex || 0);
  const [selectedTipIndex, setSelectedTipIndex] = useState(-1);

  // Sync with design prop
  useEffect(() => {
    setTips(design.tips || []);
    setActiveTipIndex(design.activeTipIndex || 0);
  }, [design]);

  const saveToServer = (updatedTips, newActiveTipIndex) => {
    onSave({
      tips: updatedTips,
      activeTipIndex: newActiveTipIndex !== undefined ? newActiveTipIndex : activeTipIndex
    });
  };

  const createDefaultTip = () => ({
    name: `L0Tip${tips.length}`,
    drypad_x: 92.0,
    drypad_y: 335.0,
    drypad_z: 70.0,
    drypad_servo_move: 0,
    drypad_servo_touch: 115,
    drypad_time: 3000,
    drypad_delay: 2000,
    wash_x: 134.0,
    wash_y: 374.5,
    wash_z: 70.0,
    wash_servo_move: 0,
    wash_servo_wash: 120,
    waste_x: 170.0,
    waste_y: 373.0,
    waste_z: 92.0,
    waste_servo_move: 0,
    waste_servo_waste: 170,
    eject_x: 65.0,
    eject_y: 340.0,
    eject_z: 40.0,
    eject_servo_move: 0,
    eject_servo_eject: 150
  });

  const createNewTip = () => {
    const newTip = createDefaultTip();
    const newTips = [...tips, newTip];
    setTips(newTips);
    setSelectedTipIndex(newTips.length - 1);
    saveToServer(newTips);
  };

  const cloneTip = () => {
    if (selectedTipIndex === -1) {
      alert('Please select a tip to clone');
      return;
    }

    const cloned = { ...tips[selectedTipIndex], name: tips[selectedTipIndex].name + '_copy' };
    const newTips = [...tips, cloned];
    setTips(newTips);
    setSelectedTipIndex(newTips.length - 1);
    saveToServer(newTips);
  };

  const deleteTip = () => {
    if (selectedTipIndex === -1) {
      alert('Please select a tip to delete');
      return;
    }

    if (tips.length <= 1) {
      alert('Cannot delete the last tip');
      return;
    }

    if (!window.confirm(`Delete "${tips[selectedTipIndex].name}"?`)) return;

    const newTips = tips.filter((_, i) => i !== selectedTipIndex);
    const newActiveIndex = activeTipIndex >= newTips.length ? newTips.length - 1 : activeTipIndex;
    
    setTips(newTips);
    setSelectedTipIndex(-1);
    setActiveTipIndex(newActiveIndex);
    saveToServer(newTips, newActiveIndex);
  };

  const setAsActive = () => {
    const selectEl = document.getElementById('active-tip-select');
    const newIndex = parseInt(selectEl.value);
    setActiveTipIndex(newIndex);
    saveToServer(tips, newIndex);
    alert(`Active tip set to: ${tips[newIndex].name}`);
  };

  const updateTip = (field, value) => {
    if (selectedTipIndex === -1) return;

    const newTips = [...tips];
    newTips[selectedTipIndex] = {
      ...newTips[selectedTipIndex],
      [field]: value
    };
    setTips(newTips);
    saveToServer(newTips);
  };

  const selectedTip = selectedTipIndex >= 0 ? tips[selectedTipIndex] : null;

  // Ensure at least one tip exists
  useEffect(() => {
    if (tips.length === 0) {
      const defaultTip = createDefaultTip();
      const newTips = [defaultTip];
      setTips(newTips);
      saveToServer(newTips, 0);
    }
  }, []);

  return (
    <div>
      {/* Tip Management */}
      <div className="section">
        <h3 className="section-title">💧 Tip Management</h3>

        {isPublisher && (
          <div className="btn-group">
            <button className="btn" onClick={createNewTip}>➕ New Tip</button>
            <button className="btn btn-secondary" onClick={cloneTip}>📋 Clone</button>
            <button className="btn btn-danger" onClick={deleteTip}>🗑️ Delete</button>
          </div>
        )}

        <div className="list-container" style={{ marginBottom: '15px' }}>
          {tips.length === 0 ? (
            <div style={{ padding: '20px', textAlign: 'center', color: '#999' }}>
              No tips created yet
            </div>
          ) : (
            tips.map((tip, index) => (
              <div
                key={index}
                className={`list-item ${index === selectedTipIndex ? 'selected' : ''}`}
                onClick={() => setSelectedTipIndex(index)}
              >
                <div className="list-item-title">
                  {index === activeTipIndex ? '★ ' : ''}{tip.name}
                  {index === activeTipIndex && (
                    <span style={{ color: '#48bb78', fontSize: '10px', marginLeft: '8px' }}>ACTIVE</span>
                  )}
                </div>
                <div className="list-item-details">
                  Drypad Z: {tip.drypad_z} | Wash: ({tip.wash_x}, {tip.wash_y})
                </div>
              </div>
            ))
          )}
        </div>

        {/* Active Tip Selector */}
        <div style={{ background: 'rgba(72, 187, 120, 0.1)', padding: '12px', borderRadius: '6px', border: '1px solid rgba(72, 187, 120, 0.3)' }}>
          <label style={{ fontWeight: 600, marginBottom: '8px', display: 'block' }}>Active Tip:</label>
          <div style={{ display: 'flex', gap: '8px' }}>
            <select id="active-tip-select" defaultValue={activeTipIndex} style={{ flex: 1 }} disabled={!isPublisher}>
              {tips.map((tip, i) => (
                <option key={i} value={i}>
                  {tip.name} {i === activeTipIndex ? '★' : ''}
                </option>
              ))}
            </select>
            {isPublisher && (
              <button className="btn" onClick={setAsActive}>Set Active</button>
            )}
          </div>
        </div>
      </div>

      {/* Tip Editor */}
      {selectedTip && (
        <div className="section">
          <h3 className="section-title">{isPublisher ? '✏️ Edit' : '👁️ View'} Tip: {selectedTip.name}</h3>

          <div style={{ marginBottom: '15px' }}>
            <label>Tip Name:</label>
            <input
              type="text"
              value={selectedTip.name}
              onChange={(e) => updateTip('name', e.target.value)}
              disabled={!isPublisher}
            />
          </div>

          {/* Drypad Section */}
          <h4 style={{ color: '#9f7aea', margin: '15px 0 10px 0' }}>🔸 DRYPAD</h4>
          <div className="form-row cols-3">
            <div>
              <label>X:</label>
              <input
                type="number"
                value={selectedTip.drypad_x}
                onChange={(e) => updateTip('drypad_x', parseFloat(e.target.value))}
                step="0.1"
              />
            </div>
            <div>
              <label>Y:</label>
              <input
                type="number"
                value={selectedTip.drypad_y}
                onChange={(e) => updateTip('drypad_y', parseFloat(e.target.value))}
                step="0.1"
              />
            </div>
            <div>
              <label>Z:</label>
              <input
                type="number"
                value={selectedTip.drypad_z}
                onChange={(e) => updateTip('drypad_z', parseFloat(e.target.value))}
                step="0.1"
              />
            </div>
          </div>
          <div className="form-row cols-4">
            <div>
              <label>Move°:</label>
              <input
                type="number"
                value={selectedTip.drypad_servo_move}
                onChange={(e) => updateTip('drypad_servo_move', parseInt(e.target.value))}
                min="0"
                max="180"
              />
            </div>
            <div>
              <label>Touch°:</label>
              <input
                type="number"
                value={selectedTip.drypad_servo_touch}
                onChange={(e) => updateTip('drypad_servo_touch', parseInt(e.target.value))}
                min="0"
                max="180"
              />
            </div>
            <div>
              <label>Time (ms):</label>
              <input
                type="number"
                value={selectedTip.drypad_time}
                onChange={(e) => updateTip('drypad_time', parseInt(e.target.value))}
              />
            </div>
            <div>
              <label>Delay (ms):</label>
              <input
                type="number"
                value={selectedTip.drypad_delay}
                onChange={(e) => updateTip('drypad_delay', parseInt(e.target.value))}
              />
            </div>
          </div>

          {/* Wash Section */}
          <h4 style={{ color: '#4299e1', margin: '15px 0 10px 0' }}>🧼 WASH</h4>
          <div className="form-row cols-3">
            <div>
              <label>X:</label>
              <input
                type="number"
                value={selectedTip.wash_x}
                onChange={(e) => updateTip('wash_x', parseFloat(e.target.value))}
                step="0.1"
              />
            </div>
            <div>
              <label>Y:</label>
              <input
                type="number"
                value={selectedTip.wash_y}
                onChange={(e) => updateTip('wash_y', parseFloat(e.target.value))}
                step="0.1"
              />
            </div>
            <div>
              <label>Z:</label>
              <input
                type="number"
                value={selectedTip.wash_z}
                onChange={(e) => updateTip('wash_z', parseFloat(e.target.value))}
                step="0.1"
              />
            </div>
          </div>
          <div className="form-row cols-2">
            <div>
              <label>Move°:</label>
              <input
                type="number"
                value={selectedTip.wash_servo_move}
                onChange={(e) => updateTip('wash_servo_move', parseInt(e.target.value))}
                min="0"
                max="180"
              />
            </div>
            <div>
              <label>Wash°:</label>
              <input
                type="number"
                value={selectedTip.wash_servo_wash}
                onChange={(e) => updateTip('wash_servo_wash', parseInt(e.target.value))}
                min="0"
                max="180"
              />
            </div>
          </div>

          {/* Waste Section */}
          <h4 style={{ color: '#ed8936', margin: '15px 0 10px 0' }}>🗑️ WASTE</h4>
          <div className="form-row cols-3">
            <div>
              <label>X:</label>
              <input
                type="number"
                value={selectedTip.waste_x}
                onChange={(e) => updateTip('waste_x', parseFloat(e.target.value))}
                step="0.1"
              />
            </div>
            <div>
              <label>Y:</label>
              <input
                type="number"
                value={selectedTip.waste_y}
                onChange={(e) => updateTip('waste_y', parseFloat(e.target.value))}
                step="0.1"
              />
            </div>
            <div>
              <label>Z:</label>
              <input
                type="number"
                value={selectedTip.waste_z}
                onChange={(e) => updateTip('waste_z', parseFloat(e.target.value))}
                step="0.1"
              />
            </div>
          </div>
          <div className="form-row cols-2">
            <div>
              <label>Move°:</label>
              <input
                type="number"
                value={selectedTip.waste_servo_move}
                onChange={(e) => updateTip('waste_servo_move', parseInt(e.target.value))}
                min="0"
                max="180"
              />
            </div>
            <div>
              <label>Waste°:</label>
              <input
                type="number"
                value={selectedTip.waste_servo_waste}
                onChange={(e) => updateTip('waste_servo_waste', parseInt(e.target.value))}
                min="0"
                max="180"
              />
            </div>
          </div>

          {/* Eject Section */}
          <h4 style={{ color: '#f56565', margin: '15px 0 10px 0' }}>⏏️ EJECT</h4>
          <div className="form-row cols-3">
            <div>
              <label>X:</label>
              <input
                type="number"
                value={selectedTip.eject_x}
                onChange={(e) => updateTip('eject_x', parseFloat(e.target.value))}
                step="0.1"
              />
            </div>
            <div>
              <label>Y:</label>
              <input
                type="number"
                value={selectedTip.eject_y}
                onChange={(e) => updateTip('eject_y', parseFloat(e.target.value))}
                step="0.1"
              />
            </div>
            <div>
              <label>Z:</label>
              <input
                type="number"
                value={selectedTip.eject_z}
                onChange={(e) => updateTip('eject_z', parseFloat(e.target.value))}
                step="0.1"
              />
            </div>
          </div>
          <div className="form-row cols-2">
            <div>
              <label>Move°:</label>
              <input
                type="number"
                value={selectedTip.eject_servo_move}
                onChange={(e) => updateTip('eject_servo_move', parseInt(e.target.value))}
                min="0"
                max="180"
              />
            </div>
            <div>
              <label>Eject°:</label>
              <input
                type="number"
                value={selectedTip.eject_servo_eject}
                onChange={(e) => updateTip('eject_servo_eject', parseInt(e.target.value))}
                min="0"
                max="180"
              />
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default TipManagement;
