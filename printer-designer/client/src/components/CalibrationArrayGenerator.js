import React, { useState, useEffect } from 'react';
import '../styles/calibration.css';
import NumInput from './NumInput';

function CalibrationArrayGenerator() {
  // Load settings from Shape Designer's localStorage
  const loadShapeSettings = () => {
    try {
      const saved = localStorage.getItem('shapeDesignerSettings');
      if (saved) {
        return JSON.parse(saved);
      }
    } catch (e) {
      console.warn('Failed to load Shape Designer settings:', e);
    }
    return null;
  };

  const [settings, setSettings] = useState({
    // Active sweep selection
    activeSweep: 'sweep1', // 'sweep1', 'sweep2', or 'both'
    
    // Sweep 1: E multiplier
    s1Accel: 600,
    s1Center: 1.50,
    s1Step: 0.10,
    
    // Sweep 2: Acceleration
    s2EMult: 1.50,
    s2Center: 600,
    s2Step: 150,
    
    // Sweep gap
    sweepGap: 15
  });

  const [gcode, setGcode] = useState('');

  const updateSetting = (key, value) => {
    setSettings(s => ({ ...s, [key]: value }));
  };

  const getSweep1Values = () => {
    const { s1Center, s1Step } = settings;
    return [
      s1Center - 2*s1Step,
      s1Center - s1Step,
      s1Center,
      s1Center + s1Step,
      s1Center + 2*s1Step
    ];
  };

  const getSweep2Values = () => {
    const { s2Center, s2Step } = settings;
    return [
      s2Center - 2*s2Step,
      s2Center - s2Step,
      s2Center,
      s2Center + s2Step,
      s2Center + 2*s2Step
    ];
  };

  const generateSweepGcode = (lines, startX, startY, label) => {
    const shapeSettings = loadShapeSettings();
    if (!shapeSettings) {
      alert('Please configure settings in Shape Designer first!');
      return '';
    }
    
    const { lineLength, feedrate, zHeight, zTravel, restoreAccel, volumePerLine, 
            zigzagLines, primeGcode, postDispenseGcode, beforeLineSetGcode, afterLineSetGcode } = shapeSettings;
    
    let gc = [];
    gc.push(`; === ${label} ===`);
    gc.push(`G1 Z${zTravel} F2000`);
    gc.push(`G1 X${startX.toFixed(3)} Y${startY.toFixed(3)} F3000 ; move to sweep start`);
    gc.push(`G1 Z${zHeight} F500 ; lower to dispense height`);
    gc.push(``);
    
    if (beforeLineSetGcode && beforeLineSetGcode.trim()) {
      gc.push(`; Before Line Set`);
      beforeLineSetGcode.split('\n').forEach(l => gc.push(l.trim()));
      gc.push(``);
    }

    let eAccum = 0;
    let lastAccel = null;

    lines.forEach((line, i) => {
      const { eMult, accel } = line;
      const eForLine = volumePerLine * eMult;
      eAccum += eForLine;

      const x = startX + i * shapeSettings.lineSpacing;
      const isReverse = zigzagLines && (i % 2 === 1);
      const yStart = isReverse ? startY + lineLength : startY;
      const yEnd = isReverse ? startY : startY + lineLength;

      gc.push(`; Line ${i+1} | E×${eMult.toFixed(2)} | Accel S${Math.round(accel)} | E delta: ${eForLine.toFixed(2)}µL`);

      if (i > 0) {
        gc.push(`G1 Z${zTravel} F500`);
        gc.push(`G1 X${x.toFixed(3)} Y${yStart.toFixed(3)} F3000`);
        gc.push(`G1 Z${zHeight} F500`);
      }

      if (accel !== lastAccel) {
        gc.push(`M204 S${Math.round(accel)}`);
        lastAccel = accel;
      }

      if (primeGcode && primeGcode.trim()) {
        primeGcode.split('\n').forEach(l => gc.push(l.trim()));
      }

      gc.push(`G1 Y${yEnd.toFixed(3)} E${eAccum.toFixed(2)} F${feedrate}`);

      if (postDispenseGcode && postDispenseGcode.trim()) {
        postDispenseGcode.split('\n').forEach(l => gc.push(l.trim()));
      }
      
      gc.push(``);
    });

    gc.push(`G1 Z${zTravel} F500 ; lift`);
    gc.push(`M204 S${restoreAccel} ; restore acceleration`);
    gc.push(``);
    
    if (afterLineSetGcode && afterLineSetGcode.trim()) {
      gc.push(`; After Line Set`);
      afterLineSetGcode.split('\n').forEach(l => gc.push(l.trim()));
      gc.push(``);
    }

    return gc.join('\n');
  };

  const generate = () => {
    const shapeSettings = loadShapeSettings();
    if (!shapeSettings) {
      alert('Please configure settings in Shape Designer first!');
      return;
    }
    
    const { startX, startY, lineSpacing, zTravel, beforePrintingGcode, afterPrintingGcode } = shapeSettings;
    const { sweepGap, activeSweep, s1Accel, s2EMult } = settings;
    
    const s1Vals = getSweep1Values();
    const sweep1Lines = s1Vals.map(v => ({ eMult: v, accel: s1Accel }));
    
    const s2Vals = getSweep2Values();
    const sweep2Lines = s2Vals.map(v => ({ eMult: s2EMult, accel: v }));
    
    const sweep1Width = (sweep1Lines.length - 1) * lineSpacing;
    const sweep2StartX = startX + sweep1Width + sweepGap;

    const now = new Date().toISOString();
    let gc = [];
    gc.push(`; Calibration Array G-code`);
    gc.push(`; Generated: ${now}`);
    
    if (activeSweep === 'sweep1' || activeSweep === 'both') {
      gc.push(`; Sweep 1: E Multiplier sweep (fixed accel)`);
    }
    if (activeSweep === 'sweep2' || activeSweep === 'both') {
      gc.push(`; Sweep 2: Acceleration sweep (fixed E mult)`);
    }
    gc.push(`; ★ = center value (current best)`);
    gc.push(`;`);

    if (activeSweep === 'sweep1' || activeSweep === 'both') {
      gc.push(`; Sweep 1 — Fixed Accel: S${s1Accel}`);
      s1Vals.forEach((v,i) => gc.push(`;   Line ${i+1}: E×${v.toFixed(2)}${Math.abs(v-settings.s1Center)<0.001?' ★':''}`));
      gc.push(`;`);
    }
    
    if (activeSweep === 'sweep2' || activeSweep === 'both') {
      gc.push(`; Sweep 2 — Fixed E Mult: ×${s2EMult.toFixed(2)}`);
      s2Vals.forEach((v,i) => gc.push(`;   Line ${i+1}: Accel S${Math.round(v)}${Math.abs(v-settings.s2Center)<1?' ★':''}`));
      gc.push(`;`);
    }

    gc.push(`G21 ; mm units`);
    gc.push(`G90 ; absolute positioning`);
    gc.push(`G92 E0 ; reset extruder`);
    gc.push(``);
    
    if (beforePrintingGcode && beforePrintingGcode.trim()) {
      gc.push(`; === Before Printing ===`);
      beforePrintingGcode.split('\n').forEach(l => gc.push(l.trim()));
      gc.push(``);
    }
    
    gc.push(`G1 Z${zTravel} F2000`);
    gc.push(``);

    if (activeSweep === 'sweep1' || activeSweep === 'both') {
      gc.push(generateSweepGcode(sweep1Lines, startX, startY, 'SWEEP 1 — E Multiplier (Accel fixed at S' + Math.round(s1Accel) + ')'));
    }
    
    if (activeSweep === 'sweep2' || activeSweep === 'both') {
      const s2StartX = activeSweep === 'both' ? sweep2StartX : startX;
      gc.push(generateSweepGcode(sweep2Lines, s2StartX, startY, 'SWEEP 2 — Acceleration (E Mult fixed at ×' + s2EMult.toFixed(2) + ')'));
    }

    if (afterPrintingGcode && afterPrintingGcode.trim()) {
      gc.push(`; === After Printing ===`);
      afterPrintingGcode.split('\n').forEach(l => gc.push(l.trim()));
    }

    setGcode(gc.join('\n'));
  };

  const copyGcode = () => {
    navigator.clipboard.writeText(gcode).then(() => {
      alert('G-code copied to clipboard!');
    });
  };

  const downloadGcode = () => {
    const blob = new Blob([gcode], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `calibration_array_${Date.now()}.gcode`;
    a.click();
    URL.revokeObjectURL(url);
  };

  const s1Vals = getSweep1Values();
  const s2Vals = getSweep2Values();

  return (
    <div className="calibration-generator">
      <div className="calibration-header">
        <h2>⚗️ Line Calibration Array Generator</h2>
        <p className="subtitle">Sweep E multiplier and acceleration around your current best values — find the optimum in one run</p>
      </div>

      <div className="cal-grid">
        {/* Sweep Selection */}
        <div className="cal-card shared">
          <h3>🔧 Calibration Settings</h3>
          
          {/* Sweep Selection Radio Buttons */}
          <div style={{ marginBottom: '1rem', padding: '0.75rem', background: '#ffffff08', borderRadius: '4px' }}>
            <label style={{ display: 'block', marginBottom: '0.5rem', color: '#fff', fontSize: '0.8rem', fontWeight: '600' }}>
              Active Sweep:
            </label>
            <div style={{ display: 'flex', gap: '1.5rem', flexWrap: 'wrap' }}>
              <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer', fontSize: '0.85rem', color: '#e2e8f0' }}>
                <input 
                  type="radio" 
                  name="activeSweep" 
                  value="sweep1" 
                  checked={settings.activeSweep === 'sweep1'}
                  onChange={(e) => updateSetting('activeSweep', e.target.value)}
                />
                <span>Sweep 1 Only (E Multiplier)</span>
              </label>
              <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer', fontSize: '0.85rem', color: '#e2e8f0' }}>
                <input 
                  type="radio" 
                  name="activeSweep" 
                  value="sweep2" 
                  checked={settings.activeSweep === 'sweep2'}
                  onChange={(e) => updateSetting('activeSweep', e.target.value)}
                />
                <span>Sweep 2 Only (Acceleration)</span>
              </label>
              <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer', fontSize: '0.85rem', color: '#e2e8f0' }}>
                <input 
                  type="radio" 
                  name="activeSweep" 
                  value="both" 
                  checked={settings.activeSweep === 'both'}
                  onChange={(e) => updateSetting('activeSweep', e.target.value)}
                />
                <span>Both Sweeps</span>
              </label>
            </div>
          </div>
          
          <div className="field-row">
            <label>Sweep Gap (mm) <small style={{color: '#888', fontSize: '0.65rem'}}>(spacing between sweeps when both selected)</small>
              <NumInput value={settings.sweepGap} onChange={(v) => updateSetting('sweepGap', v)} fallback={10}/>
            </label>
          </div>
          
          <p className="note" style={{marginTop: '1rem', padding: '0.75rem', background: '#ffffff08', borderRadius: '4px'}}>
            ℹ️ All other settings (line length, spacing, volume, speeds, Z heights, prime/post G-code, etc.) are synced from <strong>Shape Designer</strong> tab. Configure them there first.
          </p>
        </div>

        {/* Sweep 1 */}
        <div className="cal-card sweep1">
          <h3>Sweep 1 <span className="tag e">E Multiplier</span></h3>
          <p className="note">Fixed acceleration. Vary E multiplier across 5 lines.</p>
          <div className="field-row">
            <label>Fixed Accel (mm/s²)<NumInput value={settings.s1Accel} onChange={(v) => updateSetting('s1Accel', v)} fallback={500} integer/></label>
            <label>Center E Mult<NumInput step="0.05" value={settings.s1Center} onChange={(v) => updateSetting('s1Center', v)} fallback={1.0}/></label>
            <label>Step Size<NumInput step="0.01" value={settings.s1Step} onChange={(v) => updateSetting('s1Step', v)} fallback={0.1}/></label>
          </div>
          <table className="sweep-table">
            <thead><tr><th>Line</th><th>E Multiplier</th><th>Accel (mm/s²)</th></tr></thead>
            <tbody>
              {s1Vals.map((v, i) => (
                <tr key={i}><td>Line {i+1}{i===2?' ★':''}</td><td>{v.toFixed(2)}</td><td>{settings.s1Accel}</td></tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Sweep 2 */}
        <div className="cal-card sweep2">
          <h3>Sweep 2 <span className="tag a">Acceleration</span></h3>
          <p className="note">Fixed E multiplier. Vary acceleration across 5 lines.</p>
          <div className="field-row">
            <label>Fixed E Mult<NumInput step="0.05" value={settings.s2EMult} onChange={(v) => updateSetting('s2EMult', v)} fallback={1.0}/></label>
            <label>Center Accel (mm/s²)<NumInput value={settings.s2Center} onChange={(v) => updateSetting('s2Center', v)} fallback={600} integer/></label>
            <label>Step Size (mm/s²)<NumInput value={settings.s2Step} onChange={(v) => updateSetting('s2Step', v)} fallback={150} integer/></label>
          </div>
          <table className="sweep-table">
            <thead><tr><th>Line</th><th>E Multiplier</th><th>Accel (mm/s²)</th></tr></thead>
            <tbody>
              {s2Vals.map((v, i) => (
                <tr key={i}><td>Line {i+1}{i===2?' ★':''}</td><td>{settings.s2EMult.toFixed(2)}</td><td>{Math.round(v)}</td></tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      <div className="btn-row">
        <button className="btn btn-primary" onClick={generate}>⚡ Generate Calibration G-code</button>
      </div>

      <div className="output-wrap">
        <textarea className="gcode-output" value={gcode} readOnly placeholder="G-code will appear here..."/>
        {gcode && (
          <div className="output-actions">
            <button className="btn btn-success" onClick={copyGcode}>📋 Copy</button>
            <button className="btn btn-success" onClick={downloadGcode}>💾 Download</button>
          </div>
        )}
      </div>
    </div>
  );
}

export default CalibrationArrayGenerator;
