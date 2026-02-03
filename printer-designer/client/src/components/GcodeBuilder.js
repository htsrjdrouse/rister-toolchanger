import React, { useState, useEffect } from 'react';

function GcodeBuilder({ design, onSave, isPublisher = true }) {
  const [savedMacros, setSavedMacros] = useState(design.savedMacros || []);
  const [selectedObject, setSelectedObject] = useState('');
  const [arrayRow, setArrayRow] = useState(1);
  const [arrayColumn, setArrayColumn] = useState(1);
  const [macroName, setMacroName] = useState('');
  const [macroOutput, setMacroOutput] = useState('');
  const [selectedMacroIndices, setSelectedMacroIndices] = useState([]);

  const objects = design.objects || [];
  const tips = design.tips || [];
  const activeTipIndex = design.activeTipIndex || 0;
  const activeTip = tips[activeTipIndex] || { name: 'L0Tip0' };

  // Sync with design prop
  useEffect(() => {
    setSavedMacros(design.savedMacros || []);
  }, [design]);

  const saveToServer = (updatedMacros) => {
    onSave({ savedMacros: updatedMacros });
  };

  const getSequenceHeader = () => {
    const sequenceName = macroName || 'automation_sequence';
    return `; G-code Sequence: ${sequenceName}\n` +
           `; Generated: ${new Date().toISOString()}\n` +
           `; Ready to execute in Mainsail console\n\n`;
  };

  const appendGcode = (newCode) => {
    const currentGcode = macroOutput;
    if (!currentGcode.trim()) {
      setMacroOutput(getSequenceHeader() + newCode);
    } else {
      setMacroOutput(currentGcode + newCode);
    }
  };

  // Position to tip stations
  const positionToTipStation = (station) => {
    let x, y, z, stationName;
    
    if (station === 'DRYPAD') {
      x = activeTip.drypad_x || 92.0;
      y = activeTip.drypad_y || 335.0;
      z = activeTip.drypad_z || 70.0;
      stationName = 'DRYPAD';
    } else if (station === 'WASH') {
      x = activeTip.wash_x || 134.0;
      y = activeTip.wash_y || 374.5;
      z = activeTip.wash_z || 70.0;
      stationName = 'WASH';
    } else if (station === 'WASTE') {
      x = activeTip.waste_x || 170.0;
      y = activeTip.waste_y || 373.0;
      z = activeTip.waste_z || 92.0;
      stationName = 'WASTE';
    }

    const newCommand = 
      `; Move to ${stationName} (${activeTip.name || 'L0Tip0'})\n` +
      `G90  ; Absolute positioning\n` +
      `G1 X${x} Y${y} F3000  ; Move to ${stationName.toLowerCase()} XY position\n` +
      `G1 Z${z} F1500  ; Move to ${stationName.toLowerCase()} Z height\n` +
      `G4 P500  ; Pause 500ms for stabilization\n\n`;

    appendGcode(newCommand);
  };

  // Position to object
  const positionToObject = () => {
    if (!selectedObject) {
      alert('Please select an object from the dropdown');
      return;
    }

    const obj = objects.find(o => o.name === selectedObject);
    if (!obj) {
      alert('Object not found');
      return;
    }

    // Check if it's a tip station object
    const lowerName = selectedObject.toLowerCase();
    if (lowerName === 'wash' || lowerName === 'waste' || lowerName === 'drypad') {
      positionToTipStation(lowerName.toUpperCase());
      return;
    }

    const newCommand = 
      `; Move to ${obj.name}\n` +
      `G90  ; Absolute positioning\n` +
      `G1 X${obj.posx} Y${obj.posy} F3000  ; Move to object position\n` +
      (obj.ztrav !== "0" ? `G1 Z${obj.ztrav} F1500  ; Move to Z height\n` : '') +
      `G4 P500  ; Pause 500ms for stabilization\n\n`;

    appendGcode(newCommand);
  };

  // Position to array
  const positionToArray = () => {
    if (!selectedObject) {
      alert('Please select an object');
      return;
    }

    const row = arrayRow - 1;
    const col = arrayColumn - 1;

    if (row < 0 || col < 0) {
      alert('Please enter valid row and column numbers (starting from 1)');
      return;
    }

    const obj = objects.find(o => o.name === selectedObject);
    if (!obj) {
      alert('Object not found');
      return;
    }

    const maxRows = parseInt(obj.arrayrow);
    const maxCols = parseInt(obj.arraycolumn);

    if (row >= maxRows || col >= maxCols) {
      alert(`Array position out of bounds. Object has ${maxRows} rows and ${maxCols} columns.`);
      return;
    }

    // Calculate array position
    const rowSpacing = parseFloat(obj.arrayrowsp);
    const colSpacing = parseFloat(obj.arraycolumnsp);
    const marginX = parseFloat(obj.marginx);
    const marginY = parseFloat(obj.marginy);
    const baseX = parseFloat(obj.posx);
    const baseY = parseFloat(obj.posy);

    const arrayX = baseX + marginX + col * colSpacing;
    const arrayY = baseY + marginY + row * rowSpacing;
    const arrayName = String.fromCharCode(65 + row) + (col + 1);

    const newCommand = 
      `; Move to ${obj.name} array ${arrayName}\n` +
      `G90  ; Absolute positioning\n` +
      `G1 X${arrayX.toFixed(2)} Y${arrayY.toFixed(2)} F3000  ; Move to array position\n` +
      (obj.ztrav !== "0" ? `G1 Z${obj.ztrav} F1500  ; Move to Z height\n` : '') +
      `G4 P500  ; Pause 500ms for stabilization\n\n`;

    appendGcode(newCommand);
  };

  // Save macro
  const saveMacro = () => {
    const name = macroName.trim();
    const content = macroOutput.trim();

    if (!name) {
      alert('Please enter a sequence name');
      return;
    }

    if (!content) {
      alert('Please create some G-code content first');
      return;
    }

    const newMacros = [...savedMacros];
    const existingIndex = newMacros.findIndex(m => m.name === name);

    if (existingIndex !== -1) {
      if (!window.confirm(`Sequence "${name}" already exists. Overwrite?`)) {
        return;
      }
      newMacros[existingIndex] = { name, content };
    } else {
      newMacros.push({ name, content });
    }

    setSavedMacros(newMacros);
    saveToServer(newMacros);
    alert(`Sequence "${name}" saved!`);
  };

  // Copy G-code
  const copyGcode = () => {
    if (!macroOutput.trim()) {
      alert('No G-code to copy!');
      return;
    }

    navigator.clipboard.writeText(macroOutput).then(() => {
      alert('G-code copied to clipboard!');
    }).catch(() => {
      // Fallback
      const textArea = document.createElement('textarea');
      textArea.value = macroOutput;
      document.body.appendChild(textArea);
      textArea.select();
      document.execCommand('copy');
      document.body.removeChild(textArea);
      alert('G-code copied to clipboard!');
    });
  };

  // Download G-code
  const downloadGcode = () => {
    if (!macroOutput.trim()) {
      alert('No G-code to download!');
      return;
    }

    const sequenceName = macroName || 'sequence';
    const fileName = `${sequenceName}_${new Date().toISOString().slice(0, 10)}.gcode`;
    const blob = new Blob([macroOutput], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);

    const link = document.createElement('a');
    link.href = url;
    link.download = fileName;
    link.click();

    URL.revokeObjectURL(url);
  };

  // Load macro
  const loadMacro = () => {
    if (selectedMacroIndices.length !== 1) {
      alert('Please select exactly one sequence to load');
      return;
    }

    const macro = savedMacros[selectedMacroIndices[0]];
    setMacroName(macro.name);
    setMacroOutput(macro.content);
  };

  // Delete macro
  const deleteMacro = () => {
    if (selectedMacroIndices.length === 0) {
      alert('Please select sequence(s) to delete');
      return;
    }

    const names = selectedMacroIndices.map(i => savedMacros[i].name);
    if (!window.confirm(`Delete these sequences?\n${names.join('\n')}`)) {
      return;
    }

    const newMacros = savedMacros.filter((_, i) => !selectedMacroIndices.includes(i));
    setSavedMacros(newMacros);
    setSelectedMacroIndices([]);
    saveToServer(newMacros);
  };

  // Move macro
  const moveMacro = (direction) => {
    if (selectedMacroIndices.length !== 1) {
      alert('Please select exactly one sequence to move');
      return;
    }

    const index = selectedMacroIndices[0];
    const newIndex = index + direction;

    if (newIndex < 0 || newIndex >= savedMacros.length) {
      return;
    }

    const newMacros = [...savedMacros];
    [newMacros[index], newMacros[newIndex]] = [newMacros[newIndex], newMacros[index]];
    
    setSavedMacros(newMacros);
    setSelectedMacroIndices([newIndex]);
    saveToServer(newMacros);
  };

  // Combine macros
  const combineMacros = () => {
    if (selectedMacroIndices.length < 2) {
      alert('Please select at least 2 sequences to combine');
      return;
    }

    const selectedMacrosList = selectedMacroIndices.map(i => savedMacros[i]);

    let combined = `; Combined G-code Sequence\n`;
    combined += `; Generated: ${new Date().toISOString()}\n`;
    combined += `; Combined from: ${selectedMacrosList.map(m => m.name).join(', ')}\n\n`;

    selectedMacrosList.forEach((macro, i) => {
      combined += `; --- Sequence ${i + 1}: ${macro.name} ---\n`;
      
      const lines = macro.content.split('\n');
      lines.forEach(line => {
        const trimmed = line.trim();
        if (trimmed.startsWith('; Generated:') ||
            trimmed.startsWith('; G-code Sequence:') ||
            trimmed.startsWith('; Ready to execute') ||
            trimmed.startsWith('; Combined')) {
          return;
        }
        if (trimmed.length > 0) {
          combined += line + '\n';
        }
      });
      combined += '\n';
    });

    setMacroName('Combined_Sequence');
    setMacroOutput(combined);
  };

  // Handle multi-select
  const handleMacroSelect = (e) => {
    const options = Array.from(e.target.selectedOptions);
    setSelectedMacroIndices(options.map(opt => parseInt(opt.value)));
  };

  return (
    <div>
      {/* Position to Tip Stations */}
      <div className="section">
        <h3 className="section-title">🔸 Position to Tip Stations</h3>
        <p style={{ fontSize: '12px', color: '#666', marginBottom: '10px' }}>
          Active Tip: <strong>{activeTip.name || 'L0Tip0'}</strong>
        </p>
        <div className="btn-group">
          <button className="btn" style={{ background: '#9f7aea' }} onClick={() => positionToTipStation('DRYPAD')}>
            🔸 Drypad
          </button>
          <button className="btn btn-secondary" onClick={() => positionToTipStation('WASH')}>
            🧼 Wash
          </button>
          <button className="btn btn-warning" onClick={() => positionToTipStation('WASTE')}>
            🗑️ Waste
          </button>
        </div>
      </div>

      {/* Position to Object */}
      <div className="section">
        <h3 className="section-title">📍 Position to Object</h3>

        <div style={{ marginBottom: '10px' }}>
          <label>Select Object:</label>
          <select 
            value={selectedObject} 
            onChange={(e) => setSelectedObject(e.target.value)}
            style={{ width: '100%' }}
          >
            <option value="">Choose an object...</option>
            {objects.length === 0 ? (
              <option disabled>No objects found - create some in Object Editor</option>
            ) : (
              objects.map(obj => {
                const statusIcon = obj.status === 'on' ? '✅' : '❌';
                const arrayCount = parseInt(obj.arrayrow) * parseInt(obj.arraycolumn);
                return (
                  <option key={obj.name} value={obj.name}>
                    {obj.name} {statusIcon} ({arrayCount} arrays)
                  </option>
                );
              })
            )}
          </select>
        </div>

        <div className="form-row cols-2" style={{ marginBottom: '10px' }}>
          <div>
            <label>Array Row:</label>
            <input 
              type="number" 
              min="1" 
              value={arrayRow}
              onChange={(e) => setArrayRow(parseInt(e.target.value) || 1)}
            />
          </div>
          <div>
            <label>Array Column:</label>
            <input 
              type="number" 
              min="1" 
              value={arrayColumn}
              onChange={(e) => setArrayColumn(parseInt(e.target.value) || 1)}
            />
          </div>
        </div>

        <div className="btn-group">
          <button className="btn" onClick={positionToObject}>📦 Position to Object</button>
          <button className="btn btn-warning" onClick={positionToArray}>🎯 Position to Array</button>
        </div>
      </div>

      {/* G-code Sequence Builder */}
      <div className="section">
        <h3 className="section-title">⚙️ G-code Sequence Builder</h3>

        <div style={{ marginBottom: '10px' }}>
          <label>Sequence Name:</label>
          <input 
            type="text" 
            placeholder="my_automation_sequence"
            value={macroName}
            onChange={(e) => setMacroName(e.target.value)}
          />
        </div>

        <textarea 
          value={macroOutput}
          onChange={(e) => setMacroOutput(e.target.value)}
          style={{ 
            height: '200px', 
            fontFamily: 'monospace', 
            fontSize: '11px',
            width: '100%',
            padding: '10px',
            border: '1px solid #ddd',
            borderRadius: '6px'
          }} 
          placeholder="G-code will appear here... Click 'Position to Object' or 'Position to Array' to start building your sequence."
        />

        <div className="alert alert-info" style={{ marginTop: '10px', fontSize: '11px' }}>
          Ready-to-run G-code sequence. Copy to Mainsail console or download as .gcode file.
        </div>

        <div className="btn-group" style={{ marginTop: '10px' }}>
          {isPublisher && (
            <button className="btn" onClick={saveMacro}>💾 Save Sequence</button>
          )}
          <button className="btn btn-secondary" onClick={copyGcode}>📋 Copy</button>
        </div>

        <div className="btn-group">
          <button className="btn btn-warning" onClick={downloadGcode}>⬇️ Download .gcode</button>
          <button 
            className="btn" 
            style={{ background: '#888' }}
            onClick={() => {
              if (window.confirm('Clear the current G-code sequence?')) {
                setMacroOutput('');
              }
            }}
          >
            🗑️ Clear
          </button>
        </div>
      </div>

      {/* Saved Sequences */}
      <div className="section">
        <h3 className="section-title">📚 Saved G-code Sequences ({savedMacros.length})</h3>

        <select 
          multiple 
          size="8" 
          style={{ 
            width: '100%', 
            marginBottom: '10px', 
            fontFamily: 'monospace', 
            fontSize: '12px',
            padding: '5px'
          }}
          onChange={handleMacroSelect}
          value={selectedMacroIndices.map(String)}
        >
          {savedMacros.length === 0 ? (
            <option disabled style={{ color: '#666' }}>No saved sequences yet</option>
          ) : (
            savedMacros.map((macro, i) => (
              <option key={i} value={i}>{macro.name}</option>
            ))
          )}
        </select>

        <div className="btn-group" style={{ marginBottom: '10px' }}>
          <button className="btn btn-secondary" onClick={loadMacro}>📂 Load Selected</button>
          {isPublisher && (
            <button className="btn btn-danger" onClick={deleteMacro}>🗑️ Delete</button>
          )}
        </div>

        {isPublisher && (
          <>
            <div className="btn-group" style={{ marginBottom: '10px' }}>
              <button className="btn" style={{ background: '#9f7aea' }} onClick={() => moveMacro(-1)}>⬆️ Move Up</button>
              <button className="btn" style={{ background: '#9f7aea' }} onClick={() => moveMacro(1)}>⬇️ Move Down</button>
            </div>

            <button 
              className="btn" 
              style={{ width: '100%', background: '#888' }}
              onClick={combineMacros}
            >
              🔗 Combine Selected
            </button>
          </>
        )}
      </div>
    </div>
  );
}

export default GcodeBuilder;
