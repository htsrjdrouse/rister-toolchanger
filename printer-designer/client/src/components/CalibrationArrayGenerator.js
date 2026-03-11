import React, { useState, useEffect } from 'react';
import '../styles/calibration.css';

function CalibrationArrayGenerator() {
  const [settings, setSettings] = useState({
    // Shared hardware
    lineLen: 90,
    spacing: 2.2,
    volPerLine: 5.0,
    xySpeed: 6000,
    restoreAccel: 3000,
    startX: 101,
    startY: 127,
    zDisp: 53.2,
    zTravel: 65,
    sweepGap: 15,
    beforeLineSet: 'G92 E0\nG1 E2.5 F300\nG92 E0',
    afterLineSet: 'G1 Z70 F2000\nG4 P10\nVALVE_BYPASS MASK=1111\nG4 P10',
    
    // Active sweep selection
    activeSweep: 'sweep1', // 'sweep1', 'sweep2', or 'both'
    
    // Sweep 1: E multiplier
    s1Accel: 600,
    s1Center: 1.50,
    s1Step: 0.10,
    
    // Sweep 2: Acceleration
    s2EMult: 1.50,
    s2Center: 600,
    s2Step: 150
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
    const { lineLen, spacing, volPerLine, xySpeed, zDisp, zTravel, restoreAccel, beforeLineSet, afterLineSet } = settings;
    
    let gc = [];
    gc.push(`; === ${label} ===`);
    gc.push(`G1 Z${zTravel} F2000`);
    gc.push(`G1 X${startX.toFixed(3)} Y${startY.toFixed(3)} F3000 ; move to sweep start`);
    gc.push(`G1 Z${zDisp} F500 ; lower to dispense height`);
    gc.push(``);
    gc.push(`; Before Line Set`);
    if (beforeLineSet) beforeLineSet.split('\n').forEach(l => gc.push(l.trim()));
    gc.push(``);

    let eAccum = 0;
    let lastAccel = null;

    lines.forEach((line, i) => {
      const { eMult, accel } = line;
      const eForLine = volPerLine * eMult;
      eAccum += eForLine;

      const x = startX + i * spacing;
      const yStart = (i % 2 === 0) ? startY : startY + lineLen;
      const yEnd = (i % 2 === 0) ? startY + lineLen : startY;

      gc.push(`; Line ${i+1} | E×${eMult.toFixed(2)} | Accel S${Math.round(accel)} | E delta: ${eForLine.toFixed(2)}µL`);

      if (i > 0) {
        gc.push(`G1 Z${zDisp} F500`);
        gc.push(`G1 X${x.toFixed(3)} Y${yStart.toFixed(3)} F3000`);
        gc.push(`G1 Z${zDisp} F500`);
      }

      if (accel !== lastAccel) {
        gc.push(`M204 S${Math.round(accel)}`);
        lastAccel = accel;
      }

      gc.push(`G1 Y${yEnd.toFixed(3)} E${eAccum.toFixed(2)} F${xySpeed}`);
      gc.push(``);
    });

    gc.push(`G1 Z${zDisp} F500 ; lift`);
    gc.push(`M204 S${restoreAccel} ; restore acceleration`);
    gc.push(``);
    gc.push(`; After Line Set`);
    if (afterLineSet) afterLineSet.split('\n').forEach(l => gc.push(l.trim()));
    gc.push(``);

    return gc.join('\n');
  };

  const generate = () => {
    const { startX, startY, spacing, sweepGap, zTravel, s1Accel, s2EMult, activeSweep } = settings;
    
    const s1Vals = getSweep1Values();
    const sweep1Lines = s1Vals.map(v => ({ eMult: v, accel: s1Accel }));
    
    const s2Vals = getSweep2Values();
    const sweep2Lines = s2Vals.map(v => ({ eMult: s2EMult, accel: v }));
    
    const sweep1Width = (sweep1Lines.length - 1) * spacing;
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
    gc.push(`; === Before Printing ===`);
    gc.push(`G1 Z${zTravel} F2000`);
    gc.push(``);

    if (activeSweep === 'sweep1' || activeSweep === 'both') {
      gc.push(generateSweepGcode(sweep1Lines, startX, startY, 'SWEEP 1 — E Multiplier (Accel fixed at S' + Math.round(s1Accel) + ')'));
    }
    
    if (activeSweep === 'sweep2' || activeSweep === 'both') {
      const s2StartX = activeSweep === 'both' ? sweep2StartX : startX;
      gc.push(generateSweepGcode(sweep2Lines, s2StartX, startY, 'SWEEP 2 — Acceleration (E Mult fixed at ×' + s2EMult.toFixed(2) + ')'));
    }

    gc.push(`; === After Printing ===`);
    gc.push(`G1 Z130 F2000`);
    gc.push(`G1 X250 Y300 F3000`);

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
        {/* Shared Settings */}
        <div className="cal-card shared">
          <h3>🔧 Hardware & Motion (Shared)</h3>
          
          {/* Sweep Selection Radio Buttons */}
          <div style={{ marginBottom: '1rem', padding: '0.75rem', background: '#ffffff08', borderRadius: '4px' }}>
            <label style={{ display: 'block', marginBottom: '0.5rem', color: '#fff', fontSize: '0.8rem', fontWeight: '600' }}>
              Active Sweep:
            </label>
            <div style={{ display: 'flex', gap: '1.5rem', flexWrap: 'wrap' }}>
              <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer', fontSize: '0.85rem' }}>
                <input 
                  type="radio" 
                  name="activeSweep" 
                  value="sweep1" 
                  checked={settings.activeSweep === 'sweep1'}
                  onChange={(e) => updateSetting('activeSweep', e.target.value)}
                />
                <span>Sweep 1 Only (E Multiplier)</span>
              </label>
              <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer', fontSize: '0.85rem' }}>
                <input 
                  type="radio" 
                  name="activeSweep" 
                  value="sweep2" 
                  checked={settings.activeSweep === 'sweep2'}
                  onChange={(e) => updateSetting('activeSweep', e.target.value)}
                />
                <span>Sweep 2 Only (Acceleration)</span>
              </label>
              <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer', fontSize: '0.85rem' }}>
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
            <label>Line Length (mm)<input type="number" value={settings.lineLen} onChange={(e) => updateSetting('lineLen', parseFloat(e.target.value))}/></label>
            <label>Line Spacing (mm)<input type="number" step="0.1" value={settings.spacing} onChange={(e) => updateSetting('spacing', parseFloat(e.target.value))}/></label>
            <label>Vol per Line (µL)<input type="number" step="0.1" value={settings.volPerLine} onChange={(e) => updateSetting('volPerLine', parseFloat(e.target.value))}/></label>
            <label>XY Speed (mm/min)<input type="number" value={settings.xySpeed} onChange={(e) => updateSetting('xySpeed', parseFloat(e.target.value))}/></label>
            <label>Restore Accel (mm/s²)<input type="number" value={settings.restoreAccel} onChange={(e) => updateSetting('restoreAccel', parseFloat(e.target.value))}/></label>
          </div>
          <div className="field-row">
            <label>Start X (mm)<input type="number" value={settings.startX} onChange={(e) => updateSetting('startX', parseFloat(e.target.value))}/></label>
            <label>Start Y (mm)<input type="number" value={settings.startY} onChange={(e) => updateSetting('startY', parseFloat(e.target.value))}/></label>
            <label>Z Dispense (mm)<input type="number" step="0.1" value={settings.zDisp} onChange={(e) => updateSetting('zDisp', parseFloat(e.target.value))}/></label>
            <label>Z Travel (mm)<input type="number" step="0.1" value={settings.zTravel} onChange={(e) => updateSetting('zTravel', parseFloat(e.target.value))}/></label>
            <label>Sweep Gap (mm)<input type="number" value={settings.sweepGap} onChange={(e) => updateSetting('sweepGap', parseFloat(e.target.value))}/></label>
          </div>
          <div className="field-row">
            <label style={{gridColumn: '1/-1'}}>Before Line Set G-code<textarea rows="2" value={settings.beforeLineSet} onChange={(e) => updateSetting('beforeLineSet', e.target.value)}/></label>
          </div>
          <div className="field-row">
            <label style={{gridColumn: '1/-1'}}>After Line Set G-code<textarea rows="2" value={settings.afterLineSet} onChange={(e) => updateSetting('afterLineSet', e.target.value)}/></label>
          </div>
        </div>

        {/* Sweep 1 */}
        <div className="cal-card sweep1">
          <h3>Sweep 1 <span className="tag e">E Multiplier</span></h3>
          <p className="note">Fixed acceleration. Vary E multiplier across 5 lines.</p>
          <div className="field-row">
            <label>Fixed Accel (mm/s²)<input type="number" value={settings.s1Accel} onChange={(e) => updateSetting('s1Accel', parseFloat(e.target.value))}/></label>
            <label>Center E Mult<input type="number" step="0.05" value={settings.s1Center} onChange={(e) => updateSetting('s1Center', parseFloat(e.target.value))}/></label>
            <label>Step Size<input type="number" step="0.01" value={settings.s1Step} onChange={(e) => updateSetting('s1Step', parseFloat(e.target.value))}/></label>
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
            <label>Fixed E Mult<input type="number" step="0.05" value={settings.s2EMult} onChange={(e) => updateSetting('s2EMult', parseFloat(e.target.value))}/></label>
            <label>Center Accel (mm/s²)<input type="number" value={settings.s2Center} onChange={(e) => updateSetting('s2Center', parseFloat(e.target.value))}/></label>
            <label>Step Size (mm/s²)<input type="number" value={settings.s2Step} onChange={(e) => updateSetting('s2Step', parseFloat(e.target.value))}/></label>
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
