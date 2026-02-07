import React, { useState, useRef, useEffect, useCallback } from 'react';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';

// Needle gauge to inner diameter (mm)
const NEEDLE_GAUGES = {
  '18G': 0.838,
  '20G': 0.603,
  '21G': 0.514,
  '22G': 0.413,
  '23G': 0.337,
  '25G': 0.260,
  '27G': 0.210,
  '30G': 0.159,
  '32G': 0.108,
  '34G': 0.082,
};

// Common syringe sizes - inner diameter (mm)
const SYRINGE_SIZES = {
  '1ml': 4.78,
  '3ml': 8.66,
  '5ml': 12.06,
  '10ml': 14.5,
  '20ml': 19.13,
};

function ShapeDesigner({ design, onSave, isPublisher }) {
  const [gcode, setGcode] = useState('');
  const [logs, setLogs] = useState('Ready');
  const [error, setError] = useState('');
  const [gcodeStats, setGcodeStats] = useState(null);
  
  // Dispenser settings
  const [settings, setSettings] = useState({
    // Line pattern
    numLines: 10,          // number of parallel lines
    lineLength: 70,        // mm - length of each line
    lineSpacing: 1.0,      // mm - spacing between lines
    lineWidth: 0.3,        // mm - target line width on substrate
    lineHeight: 0.05,      // mm - target line height/thickness
    
    // Start position (G-code coordinates)
    startX: 65,            // mm - X position of first line
    startY: 65,            // mm - Y position where lines start
    
    // Dispenser hardware
    needleGauge: '25G',    // needle size
    syringeSize: '1ml',    // syringe volume
    
    // Motion
    feedrate: 300,         // mm/min - travel speed while dispensing
    travelFeedrate: 3000,  // mm/min - travel speed (no dispensing)
    zHeight: 0.5,          // mm - nozzle height above substrate
    zTravel: 5,            // mm - Z height for travel moves
    
    // Extruder settings
    extruderIndex: 2,      // T2 for syringe pump
    eMultiplier: 1.0,      // extrusion multiplier for tuning
  });
  
  // Build plate size for preview
  const [buildPlate, setBuildPlate] = useState({ width: 200, height: 200 });
  
  const viewerRef = useRef(null);
  const sceneRef = useRef(null);
  const rendererRef = useRef(null);
  const controlsRef = useRef(null);
  const animationRef = useRef(null);
  const cameraRef = useRef(null);
  const linesGroupRef = useRef(null);

  // Initialize Three.js scene
  useEffect(() => {
    if (!viewerRef.current) return;
    
    const container = viewerRef.current;
    const width = container.clientWidth;
    const height = container.clientHeight;
    
    // Scene
    const scene = new THREE.Scene();
    scene.background = new THREE.Color(0x1a1a2e);
    sceneRef.current = scene;
    
    // Camera
    const camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 2000);
    camera.position.set(150, 150, 150);
    camera.lookAt(100, 0, 100);
    cameraRef.current = camera;
    
    // Renderer
    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(width, height);
    renderer.setPixelRatio(window.devicePixelRatio);
    container.appendChild(renderer.domElement);
    rendererRef.current = renderer;
    
    // Controls
    const controls = new OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.dampingFactor = 0.05;
    controls.target.set(100, 0, 100);
    controls.update();
    controlsRef.current = controls;
    
    // Lighting
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.6);
    scene.add(ambientLight);
    const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
    directionalLight.position.set(100, 200, 100);
    scene.add(directionalLight);
    
    // Grid (build plate)
    const gridHelper = new THREE.GridHelper(200, 20, 0x444444, 0x333333);
    gridHelper.position.set(100, 0, 100);
    scene.add(gridHelper);
    
    // Build plate outline
    const plateGeometry = new THREE.PlaneGeometry(200, 200);
    const plateMaterial = new THREE.MeshBasicMaterial({ 
      color: 0x2a2a4e, 
      side: THREE.DoubleSide,
      transparent: true,
      opacity: 0.3
    });
    const plate = new THREE.Mesh(plateGeometry, plateMaterial);
    plate.rotation.x = -Math.PI / 2;
    plate.position.set(100, -0.1, 100);
    scene.add(plate);
    
    // Lines group
    linesGroupRef.current = new THREE.Group();
    scene.add(linesGroupRef.current);
    
    // Animation loop
    const animate = () => {
      animationRef.current = requestAnimationFrame(animate);
      controls.update();
      renderer.render(scene, camera);
    };
    animate();
    
    // Handle resize
    const handleResize = () => {
      const w = container.clientWidth;
      const h = container.clientHeight;
      camera.aspect = w / h;
      camera.updateProjectionMatrix();
      renderer.setSize(w, h);
    };
    window.addEventListener('resize', handleResize);
    
    return () => {
      window.removeEventListener('resize', handleResize);
      cancelAnimationFrame(animationRef.current);
      renderer.dispose();
      container.removeChild(renderer.domElement);
    };
  }, []);

  // Update 3D preview when settings change
  const updatePreview = useCallback(() => {
    if (!linesGroupRef.current) return;
    
    // Clear existing lines
    while (linesGroupRef.current.children.length > 0) {
      linesGroupRef.current.remove(linesGroupRef.current.children[0]);
    }
    
    const s = settings;
    const endY = s.startY + s.lineLength;
    
    // Create line meshes
    for (let i = 0; i < s.numLines; i++) {
      const x = s.startX + i * s.lineSpacing;
      
      // Line geometry (thin box along Y axis)
      const geometry = new THREE.BoxGeometry(
        s.lineWidth,      // X
        s.lineHeight,     // Y (height)
        s.lineLength      // Z (length in Y direction shown as Z in 3D)
      );
      
      const material = new THREE.MeshPhongMaterial({ 
        color: 0x00d9ff,
        transparent: true,
        opacity: 0.8
      });
      
      const line = new THREE.Mesh(geometry, material);
      // Position: X as specified, Y at half height, Z centered on line
      line.position.set(x, s.zHeight + s.lineHeight / 2, s.startY + s.lineLength / 2);
      
      linesGroupRef.current.add(line);
    }
    
    // Add start position marker
    const markerGeometry = new THREE.SphereGeometry(1, 16, 16);
    const markerMaterial = new THREE.MeshBasicMaterial({ color: 0x00ff00 });
    const marker = new THREE.Mesh(markerGeometry, markerMaterial);
    marker.position.set(s.startX, s.zHeight, s.startY);
    linesGroupRef.current.add(marker);
    
  }, [settings]);

  // Update preview when settings change
  useEffect(() => {
    updatePreview();
  }, [settings, updatePreview]);

  // Generate G-code
  const generateGcode = useCallback(() => {
    const s = settings;
    const syringeDiameter = SYRINGE_SIZES[s.syringeSize] || 4.78;
    const needleDiameter = NEEDLE_GAUGES[s.needleGauge] || 0.260;
    
    // Calculate extrusion: E per mm of line
    const plungerArea = Math.PI * Math.pow(syringeDiameter / 2, 2);
    const lineVolumePerMm = s.lineWidth * s.lineHeight;
    const ePerMm = (lineVolumePerMm / plungerArea) * s.eMultiplier;
    
    const endY = s.startY + s.lineLength;
    
    // Build G-code
    const lines = [];
    const timestamp = new Date().toISOString();
    
    // Header
    lines.push('; Nanoarray Dispenser G-code');
    lines.push(`; Generated: ${timestamp}`);
    lines.push(';');
    lines.push('; === Pattern ===');
    lines.push(`; Lines: ${s.numLines} × ${s.lineLength}mm`);
    lines.push(`; Spacing: ${s.lineSpacing}mm`);
    lines.push(`; Start: X${s.startX} Y${s.startY}`);
    lines.push(';');
    lines.push('; === Hardware ===');
    lines.push(`; Needle: ${s.needleGauge} (${needleDiameter}mm ID)`);
    lines.push(`; Syringe: ${s.syringeSize} (${syringeDiameter}mm plunger)`);
    lines.push(`; E/mm: ${ePerMm.toFixed(6)}`);
    lines.push(';');
    lines.push('');
    
    // Setup
    lines.push('G21 ; mm units');
    lines.push('G90 ; absolute positioning');
    lines.push('M83 ; relative extrusion');
    lines.push(`T${s.extruderIndex} ; select extruder`);
    lines.push('');
    
    // Move to start
    lines.push(`G1 Z${s.zTravel} F1000`);
    lines.push(`G1 X${s.startX.toFixed(3)} Y${s.startY.toFixed(3)} F${s.travelFeedrate}`);
    lines.push(`G1 Z${s.zHeight} F500`);
    lines.push('');
    
    // Dispense lines
    let totalE = 0;
    for (let i = 0; i < s.numLines; i++) {
      const x = s.startX + i * s.lineSpacing;
      const eForLine = ePerMm * s.lineLength;
      totalE += eForLine;
      
      lines.push(`; Line ${i + 1}`);
      if (i > 0) {
        lines.push(`G1 Z${s.zTravel} F500`);
        lines.push(`G1 X${x.toFixed(3)} Y${s.startY.toFixed(3)} F${s.travelFeedrate}`);
        lines.push(`G1 Z${s.zHeight} F500`);
      }
      lines.push(`G1 Y${endY.toFixed(3)} E${eForLine.toFixed(6)} F${s.feedrate}`);
    }
    
    lines.push('');
    lines.push(`G1 Z${s.zTravel} F500`);
    lines.push(`; Total E: ${totalE.toFixed(6)}mm`);
    
    const gcodeText = lines.join('\n');
    setGcode(gcodeText);
    setGcodeStats({
      lines: s.numLines,
      totalLength: s.lineLength * s.numLines,
      totalE: totalE,
      ePerMm: ePerMm,
      volume: lineVolumePerMm * s.lineLength * s.numLines,
      bounds: {
        x: { min: s.startX, max: s.startX + (s.numLines - 1) * s.lineSpacing },
        y: { min: s.startY, max: endY },
      }
    });
    setLogs(`Generated ${s.numLines} lines, Total E: ${totalE.toFixed(4)}mm`);
    setError('');
  }, [settings]);

  // Download G-code
  const downloadGcode = () => {
    if (!gcode) return;
    const blob = new Blob([gcode], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'nanoarray.gcode';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  };

  // Update a setting
  const updateSetting = (key, value) => {
    setSettings(s => ({ ...s, [key]: value }));
  };

  return (
    <div className="shape-designer">
      <div className="shape-designer-header">
        <h2>💧 Dispenser Line Generator</h2>
        <p>Generate G-code for parallel line dispensing</p>
      </div>
      
      <div className="shape-designer-content">
        {/* Left Panel - Settings */}
        <div className="shape-panel settings-panel">
          <div className="panel-header">
            <h3>📏 Line Pattern</h3>
          </div>
          
          <div className="settings-section">
            <div className="settings-group">
              <label>
                <span>Number of Lines</span>
                <input
                  type="number"
                  min="1"
                  max="100"
                  value={settings.numLines}
                  onChange={(e) => updateSetting('numLines', parseInt(e.target.value) || 1)}
                />
              </label>
              <label>
                <span>Line Length (mm)</span>
                <input
                  type="number"
                  step="1"
                  min="1"
                  value={settings.lineLength}
                  onChange={(e) => updateSetting('lineLength', parseFloat(e.target.value) || 10)}
                />
              </label>
              <label>
                <span>Line Spacing (mm)</span>
                <input
                  type="number"
                  step="0.1"
                  min="0.1"
                  value={settings.lineSpacing}
                  onChange={(e) => updateSetting('lineSpacing', parseFloat(e.target.value) || 0.5)}
                />
              </label>
            </div>
            
            <div className="settings-group">
              <label>
                <span>Line Width (mm)</span>
                <input
                  type="number"
                  step="0.01"
                  min="0.01"
                  value={settings.lineWidth}
                  onChange={(e) => updateSetting('lineWidth', parseFloat(e.target.value) || 0.1)}
                />
              </label>
              <label>
                <span>Line Height (mm)</span>
                <input
                  type="number"
                  step="0.01"
                  min="0.01"
                  value={settings.lineHeight}
                  onChange={(e) => updateSetting('lineHeight', parseFloat(e.target.value) || 0.05)}
                />
              </label>
            </div>
          </div>
          
          <div className="panel-header">
            <h3>📍 Start Position</h3>
          </div>
          <div className="settings-section">
            <div className="settings-group horizontal">
              <label>
                <span>X (mm)</span>
                <input
                  type="number"
                  step="1"
                  value={settings.startX}
                  onChange={(e) => updateSetting('startX', parseFloat(e.target.value) || 0)}
                />
              </label>
              <label>
                <span>Y (mm)</span>
                <input
                  type="number"
                  step="1"
                  value={settings.startY}
                  onChange={(e) => updateSetting('startY', parseFloat(e.target.value) || 0)}
                />
              </label>
            </div>
          </div>
          
          <div className="panel-header">
            <h3>🔧 Hardware</h3>
          </div>
          <div className="settings-section">
            <div className="settings-group">
              <label>
                <span>Needle Gauge</span>
                <select
                  value={settings.needleGauge}
                  onChange={(e) => updateSetting('needleGauge', e.target.value)}
                >
                  {Object.entries(NEEDLE_GAUGES).map(([gauge, id]) => (
                    <option key={gauge} value={gauge}>{gauge} ({id}mm)</option>
                  ))}
                </select>
              </label>
              <label>
                <span>Syringe Size</span>
                <select
                  value={settings.syringeSize}
                  onChange={(e) => updateSetting('syringeSize', e.target.value)}
                >
                  {Object.entries(SYRINGE_SIZES).map(([size, id]) => (
                    <option key={size} value={size}>{size} (⌀{id}mm)</option>
                  ))}
                </select>
              </label>
            </div>
          </div>
          
          <div className="panel-header">
            <h3>🚀 Motion</h3>
          </div>
          <div className="settings-section">
            <div className="settings-group">
              <label>
                <span>Dispense Speed (mm/min)</span>
                <input
                  type="number"
                  step="10"
                  min="10"
                  value={settings.feedrate}
                  onChange={(e) => updateSetting('feedrate', parseInt(e.target.value) || 100)}
                />
              </label>
              <label>
                <span>Z Height (mm)</span>
                <input
                  type="number"
                  step="0.1"
                  min="0.1"
                  value={settings.zHeight}
                  onChange={(e) => updateSetting('zHeight', parseFloat(e.target.value) || 0.5)}
                />
              </label>
            </div>
            <div className="settings-group horizontal">
              <label>
                <span>E Multiplier</span>
                <input
                  type="number"
                  step="0.1"
                  min="0.1"
                  value={settings.eMultiplier}
                  onChange={(e) => updateSetting('eMultiplier', parseFloat(e.target.value) || 1.0)}
                />
              </label>
              <label>
                <span>Extruder (T)</span>
                <input
                  type="number"
                  min="0"
                  max="5"
                  value={settings.extruderIndex}
                  onChange={(e) => updateSetting('extruderIndex', parseInt(e.target.value) || 0)}
                />
              </label>
            </div>
          </div>
          
          <div className="generate-button">
            <button className="btn btn-primary btn-large" onClick={generateGcode}>
              ⚡ Generate G-code
            </button>
          </div>
        </div>
        
        {/* Center Panel - 3D Preview */}
        <div className="shape-panel viewer-panel">
          <div className="panel-header">
            <h3>🔍 Preview</h3>
          </div>
          <div className="stl-viewer" ref={viewerRef}></div>
          <div className="viewer-info">
            <span>🟢 Start position</span>
            <span>🔵 Dispense lines</span>
          </div>
        </div>
        
        {/* Right Panel - G-code Output */}
        <div className="shape-panel gcode-panel">
          <div className="panel-header">
            <h3>📄 G-code</h3>
            {gcode && (
              <button className="btn btn-success" onClick={downloadGcode}>
                💾 Download
              </button>
            )}
          </div>
          
          {gcodeStats && (
            <div className="gcode-stats">
              <div className="stat"><span>Lines:</span> {gcodeStats.lines}</div>
              <div className="stat"><span>Length:</span> {gcodeStats.totalLength.toFixed(1)}mm</div>
              <div className="stat"><span>Total E:</span> {gcodeStats.totalE.toFixed(4)}mm</div>
              <div className="stat"><span>Volume:</span> {gcodeStats.volume.toFixed(4)}mm³</div>
              <div className="stat"><span>X:</span> {gcodeStats.bounds.x.min.toFixed(1)} → {gcodeStats.bounds.x.max.toFixed(1)}</div>
              <div className="stat"><span>Y:</span> {gcodeStats.bounds.y.min.toFixed(1)} → {gcodeStats.bounds.y.max.toFixed(1)}</div>
            </div>
          )}
          
          <textarea
            className="gcode-output"
            value={gcode}
            readOnly
            placeholder="Click 'Generate G-code' to create dispenser commands..."
          />
        </div>
      </div>
      
      {/* Status Bar */}
      <div className="shape-status">
        {error ? (
          <span className="status-error">❌ {error}</span>
        ) : (
          <span className="status-info">📋 {logs}</span>
        )}
      </div>
    </div>
  );
}

export default ShapeDesigner;
