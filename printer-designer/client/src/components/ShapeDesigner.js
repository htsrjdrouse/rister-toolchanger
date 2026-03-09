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

// Default settings
const DEFAULT_SETTINGS = {
  // Line pattern
  numLines: 10,          // number of parallel lines
  lineLength: 70,        // mm - length of each line
  lineSpacing: 1.0,      // mm - spacing between lines
  
  // Volume settings (calibrated: 1 E unit = 1 µL)
  volumePerLine: 5,      // µL - total volume to dispense per line
  
  // Start position (G-code coordinates)
  startX: 65,            // mm - X position of first line
  startY: 65,            // mm - Y position where lines start
  startZ: 5,             // mm - Z starting height
  startE: 100,           // µL - E starting position (syringe volume remaining)
  
  // Dispenser hardware
  needleGauge: '25G',    // needle size
  syringeSize: '1ml',    // syringe volume
  
  // Motion
  feedrate: 300,         // mm/min - travel speed while dispensing
  travelFeedrate: 3000,  // mm/min - travel speed (no dispensing)
  zHeight: 0.5,          // mm - nozzle height above substrate
  zTravel: 5,            // mm - Z height for travel moves
  
  // Extruder settings
  eMultiplier: 1.0,      // fine-tune multiplier (1.0 = calibrated)
  eUnits: 'calibrated',  // 'calibrated' = 1 E = 1 µL (firmware calibrated), 'mm' = raw mm (use syringe area)
  
  // Prime and post-dispense G-code
  primeGcode: '',        // G-code to insert before each dispense line
  postDispenseGcode: '', // G-code to insert after each dispense line
  
  // Print job sections
  beforePrintingGcode: '',    // G-code before entire print job
  afterPrintingGcode: '',     // G-code after entire print job
  beforeLineSegmentGcode: '', // G-code before each line (multi-line only)
  afterLineSegmentGcode: '',  // G-code after each line (multi-line only)
  
  // Multi-line options
  zigzagLines: false,    // Alternate direction for faster printing
};

const STORAGE_KEY = 'shapeDesignerSettings';

// Load settings from localStorage
const loadSettings = () => {
  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (saved) {
      const parsed = JSON.parse(saved);
      // Merge with defaults to handle any new settings added later
      return { ...DEFAULT_SETTINGS, ...parsed };
    }
  } catch (e) {
    console.warn('Failed to load settings from localStorage:', e);
  }
  return DEFAULT_SETTINGS;
};

function ShapeDesigner({ design, onSave, isPublisher }) {
  const [gcode, setGcode] = useState('');
  const [logs, setLogs] = useState('Ready');
  const [error, setError] = useState('');
  const [gcodeStats, setGcodeStats] = useState(null);
  
  // Dispenser settings - load from localStorage
  const [settings, setSettings] = useState(loadSettings);
  
  // Save settings to localStorage whenever they change
  useEffect(() => {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(settings));
    } catch (e) {
      console.warn('Failed to save settings to localStorage:', e);
    }
  }, [settings]);
  
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
    
    // Display dimensions for preview (visual only, not actual line size)
    const displayWidth = Math.max(0.3, s.lineSpacing * 0.3);  // Scale with spacing
    const displayHeight = 0.5;  // Fixed visual height
    
    // Create line meshes
    for (let i = 0; i < s.numLines; i++) {
      const x = s.startX + i * s.lineSpacing;
      
      // Line geometry (thin box along Y axis)
      const geometry = new THREE.BoxGeometry(
        displayWidth,     // X (visual width)
        displayHeight,    // Y (visual height)
        s.lineLength      // Z (length in Y direction shown as Z in 3D)
      );
      
      const material = new THREE.MeshPhongMaterial({ 
        color: 0x00d9ff,
        transparent: true,
        opacity: 0.8
      });
      
      const line = new THREE.Mesh(geometry, material);
      // Position: X as specified, Y at half height, Z centered on line
      line.position.set(x, s.zHeight + displayHeight / 2, s.startY + s.lineLength / 2);
      
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
    const needleDiameter = NEEDLE_GAUGES[s.needleGauge] || 0.260;
    const syringeDiameter = SYRINGE_SIZES[s.syringeSize] || 4.78;  // mm
    
    // Calculate syringe cross-sectional area (mm²) - only used in 'mm' mode
    const syringeArea = Math.PI * Math.pow(syringeDiameter / 2, 2);  // mm²
    
    // Ensure eMultiplier is a valid number
    const eMultiplier = parseFloat(s.eMultiplier) || 1.0;
    
    // E units mode:
    // 'calibrated' = firmware already calibrated so 1 E = 1 µL (no area math needed)
    // 'mm' = E is raw mm of plunger travel, need syringe area to convert
    // Default to calibrated if eUnits is undefined (old localStorage)
    const isCalibrated = (s.eUnits || 'calibrated') === 'calibrated';
    
    // Volume calculation depends on E units mode
    const volumePerLine = s.volumePerLine;  // µL per line (requested)
    let eDisplacementPerLine;
    let actualVolumePerLine;
    
    if (isCalibrated) {
      // Calibrated mode: 1 E = 1 µL, so E displacement = volume directly
      eDisplacementPerLine = volumePerLine * eMultiplier;  // E units (= µL)
      actualVolumePerLine = eDisplacementPerLine;          // µL dispensed
    } else {
      // Raw mm mode: E is in mm, need syringe area to calculate volume
      eDisplacementPerLine = (volumePerLine / syringeArea) * eMultiplier;  // mm of E movement
      actualVolumePerLine = eDisplacementPerLine * syringeArea;            // µL dispensed
    }
    const flowRate = (actualVolumePerLine / s.lineLength) * (s.feedrate / 60);  // µL per second
    
    const endY = s.startY + s.lineLength;
    
    // Build G-code
    const lines = [];
    const timestamp = new Date().toISOString();
    
    // Header
    lines.push('; Nanoarray Dispenser G-code');
    lines.push(`; Generated: ${timestamp}`);
    lines.push(`; Syringe: ${s.syringeSize} (${syringeDiameter.toFixed(2)}mm ID${isCalibrated ? '' : `, area: ${syringeArea.toFixed(2)} mm²`})`);
    lines.push(`; E Units: ${isCalibrated ? 'Calibrated (1 E = 1 µL)' : 'Raw mm (using syringe area)'}`);
    lines.push(`;`);
    lines.push('; === Pattern ===');
    lines.push(`; Lines: ${s.numLines} × ${s.lineLength}mm`);
    lines.push(`; Spacing: ${s.lineSpacing}mm`);
    lines.push(`; Start: X${s.startX} Y${s.startY}`);
    lines.push(';');
    lines.push('; === Volume ===');
    lines.push(`; Per line: ${actualVolumePerLine.toFixed(2)} µL (E: ${eDisplacementPerLine.toFixed(3)}${isCalibrated ? ' µL' : ' mm'})`);
    lines.push(`; Flow rate: ${flowRate.toFixed(4)} µL/s`);
    lines.push(`; Needle: ${s.needleGauge} (${needleDiameter}mm ID)`);
    lines.push(`; E Multiplier: ${eMultiplier}`);
    lines.push(';');
    lines.push('');
    
    // Setup
    lines.push('G21 ; mm units');
    lines.push('G90 ; absolute positioning (XYZ)');
    lines.push('G92 E0 ; reset extruder position to zero');
    lines.push('');
    
    // Before printing section
    if (s.beforePrintingGcode && s.beforePrintingGcode.trim()) {
      lines.push('; === Before Printing ===');
      lines.push(s.beforePrintingGcode.trim());
      lines.push('');
    }
    
    // Move to start
    lines.push(`G1 Z${s.startZ} F1000 ; move to start Z`);
    lines.push(`G1 X${s.startX.toFixed(3)} Y${s.startY.toFixed(3)} F${s.travelFeedrate} ; move to start XY`);
    lines.push(`G1 Z${s.zHeight} F500 ; lower to dispense height`);
    lines.push('');
    
    // Dispense lines (absolute E positions - POSITIVE for dispensing)
    // Syringe pump: dispense = positive E (pushes plunger down)
    const multiLine = s.numLines > 1;
    let currentE = 0;
    
    for (let i = 0; i < s.numLines; i++) {
      const x = s.startX + i * s.lineSpacing;
      currentE += eDisplacementPerLine;  // Increase E for each dispense
      
      // Determine direction based on zigzag setting
      const isReverse = s.zigzagLines && (i % 2 === 1);
      const yStart = isReverse ? endY : s.startY;
      const yEnd = isReverse ? s.startY : endY;
      
      lines.push(`; Line ${i + 1} (${actualVolumePerLine.toFixed(2)} µL)`);
      
      // Before line segment (multi-line only)
      if (multiLine && s.beforeLineSegmentGcode && s.beforeLineSegmentGcode.trim()) {
        lines.push(s.beforeLineSegmentGcode.trim());
      }
      
      if (i > 0) {
        lines.push(`G1 Z${s.zTravel} F500`);
        lines.push(`G1 X${x.toFixed(3)} Y${yStart.toFixed(3)} F${s.travelFeedrate}`);
        lines.push(`G1 Z${s.zHeight} F500`);
      }
      
      // Insert prime G-code before dispense
      if (s.primeGcode && s.primeGcode.trim()) {
        lines.push(s.primeGcode.trim());
      }
      
      lines.push(`G1 Y${yEnd.toFixed(3)} E${currentE.toFixed(2)} F${s.feedrate}`);
      
      // Insert post-dispense G-code after dispense
      if (s.postDispenseGcode && s.postDispenseGcode.trim()) {
        lines.push(s.postDispenseGcode.trim());
      }
      
      // After line segment (multi-line only)
      if (multiLine && s.afterLineSegmentGcode && s.afterLineSegmentGcode.trim()) {
        lines.push(s.afterLineSegmentGcode.trim());
      }
    }
    
    // Total volume calculation depends on E units mode
    const totalEDisplacement = currentE;  // Total E moved (positive = dispensed)
    const totalVolume = isCalibrated 
      ? totalEDisplacement                       // Calibrated: E = µL directly
      : totalEDisplacement * syringeArea;        // Raw mm: need area conversion
    
    lines.push('');
    lines.push(`G1 Z${s.zTravel} F500 ; lift to travel height`);
    lines.push(`; Total dispensed: ${totalVolume.toFixed(2)} µL (E: 0 -> ${currentE.toFixed(2)}, Δ${totalEDisplacement.toFixed(2)}${isCalibrated ? ' µL' : ' mm'})`);
    
    // After printing section
    if (s.afterPrintingGcode && s.afterPrintingGcode.trim()) {
      lines.push('');
      lines.push('; === After Printing ===');
      lines.push(s.afterPrintingGcode.trim());
    }
    
    const gcodeText = lines.join('\n');
    setGcode(gcodeText);
    setGcodeStats({
      lines: s.numLines,
      totalLength: s.lineLength * s.numLines,
      totalVolume: totalVolume,
      volumePerLine: actualVolumePerLine,
      flowRate: flowRate,
      startE: 0,
      finalE: currentE,
      eDisplacement: totalEDisplacement,
      syringeArea: syringeArea,
      eMultiplier: eMultiplier,
      eUnits: isCalibrated ? 'µL' : 'mm',
      bounds: {
        x: { min: s.startX, max: s.startX + (s.numLines - 1) * s.lineSpacing },
        y: { min: s.startY, max: endY },
      }
    });
    setLogs(`Generated ${s.numLines} lines, Total: ${totalVolume.toFixed(2)} µL (ΔE: ${totalEDisplacement.toFixed(2)} ${isCalibrated ? 'µL' : 'mm'})`);
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
            
          </div>
          
          <div className="panel-header">
            <h3>💧 Volume Settings</h3>
          </div>
          <div className="settings-section">
            <div className="settings-group">
              <label>
                <span>Volume per Line (µL)</span>
                <input
                  type="number"
                  step="0.5"
                  min="0.1"
                  value={settings.volumePerLine}
                  onChange={(e) => updateSetting('volumePerLine', parseFloat(e.target.value) || 1)}
                />
              </label>
              {(() => {
                const eMultiplier = parseFloat(settings.eMultiplier) || 1.0;
                const isCalibrated = (settings.eUnits || 'calibrated') === 'calibrated';
                const syringeDia = SYRINGE_SIZES[settings.syringeSize] || 4.78;
                const syringeArea = Math.PI * Math.pow(syringeDia / 2, 2);
                
                // E per line depends on mode
                const ePerLine = isCalibrated 
                  ? settings.volumePerLine * eMultiplier  // calibrated: E = µL
                  : (settings.volumePerLine / syringeArea) * eMultiplier;  // raw mm
                
                const totalVol = settings.volumePerLine * settings.numLines * eMultiplier;
                const totalE = ePerLine * settings.numLines;
                
                return (
                  <>
                    <div style={{ fontSize: '11px', color: '#888', marginTop: '4px' }}>
                      Flow rate: {((settings.volumePerLine * eMultiplier / settings.lineLength) * (settings.feedrate / 60)).toFixed(4)} µL/s
                    </div>
                    <div style={{ fontSize: '11px', color: '#888' }}>
                      E per line: {ePerLine.toFixed(3)} {isCalibrated ? 'µL' : 'mm'}
                    </div>
                    <div style={{ fontSize: '11px', color: '#4CAF50', fontWeight: 'bold' }}>
                      Total: {totalVol.toFixed(2)} µL ({totalE.toFixed(2)} {isCalibrated ? 'µL' : 'mm'} E)
                    </div>
                  </>
                );
              })()}
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
            <div className="settings-group horizontal">
              <label>
                <span>Z (mm)</span>
                <input
                  type="number"
                  step="1"
                  min="0"
                  value={settings.startZ}
                  onChange={(e) => updateSetting('startZ', parseFloat(e.target.value) || 0)}
                />
              </label>
              <label>
                <span>E (µL remaining)</span>
                <input
                  type="number"
                  step="1"
                  min="0"
                  value={settings.startE}
                  onChange={(e) => updateSetting('startE', parseFloat(e.target.value) || 0)}
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
                <span>E Units Mode</span>
                <select
                  value={settings.eUnits || 'calibrated'}
                  onChange={(e) => updateSetting('eUnits', e.target.value)}
                >
                  <option value="calibrated">Calibrated (1 E = 1 µL)</option>
                  <option value="mm">Raw mm (use syringe area)</option>
                </select>
                <small style={{ color: '#888', fontSize: '10px' }}>
                  {settings.eUnits === 'mm' 
                    ? 'E is raw plunger mm, converted via syringe area' 
                    : 'Firmware calibrated: 1 E unit = 1 µL directly'}
                </small>
              </label>
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
                <span>Z Dispense (mm)</span>
                <input
                  type="number"
                  step="0.1"
                  min="0.1"
                  value={settings.zHeight}
                  onChange={(e) => updateSetting('zHeight', parseFloat(e.target.value) || 0.5)}
                />
              </label>
              <label>
                <span>Z Travel (mm)</span>
                <input
                  type="number"
                  step="1"
                  min="1"
                  value={settings.zTravel}
                  onChange={(e) => updateSetting('zTravel', parseFloat(e.target.value) || 5)}
                />
              </label>
            </div>
            <div className="settings-group">
              <label>
                <span>E Multiplier</span>
                <input
                  type="text"
                  inputMode="decimal"
                  pattern="[0-9]*\.?[0-9]*"
                  value={settings.eMultiplier}
                  onChange={(e) => {
                    const val = e.target.value;
                    // Allow empty or partial input while typing
                    if (val === '' || val === '.' || val === '0.' || val === '0.0') {
                      updateSetting('eMultiplier', val);
                    } else {
                      const num = parseFloat(val);
                      if (!isNaN(num) && num >= 0) {
                        updateSetting('eMultiplier', val);
                      }
                    }
                  }}
                  onBlur={(e) => {
                    // On blur, ensure valid number
                    const num = parseFloat(e.target.value);
                    if (isNaN(num) || num <= 0) {
                      updateSetting('eMultiplier', 1.0);
                    } else {
                      updateSetting('eMultiplier', num);
                    }
                  }}
                  style={{ width: '80px' }}
                />
                <small style={{ color: '#888', fontSize: '10px' }}>1.0 = 100%, 0.1 = 10%, 0.01 = 1%</small>
              </label>
            </div>
          </div>
          
          <div className="panel-header">
            <h3>🔧 Prime & Post-Dispense</h3>
          </div>
          <div className="settings-section">
            <div className="settings-group">
              <label>
                <span>Prime G-code (before each line)</span>
                <textarea
                  rows="4"
                  placeholder="G4 P10  ; Pause 50ms&#10; Prime&#10;VALVE_OUTPUT MASK=1111; G4 P10"
                  value={settings.primeGcode}
                  onChange={(e) => updateSetting('primeGcode', e.target.value)}
                  style={{ fontFamily: 'monospace', fontSize: '11px', width: '100%' }}
                />
              </label>
              <label>
                <span>Post-Dispense G-code (after each line)</span>
                <textarea
                  rows="4"
                  placeholder="G4 P10  ; Pause 10ms&#10;VALVE_BYPASS MASK=1111&#10;G4 P10  ; Pause 10ms"
                  value={settings.postDispenseGcode}
                  onChange={(e) => updateSetting('postDispenseGcode', e.target.value)}
                  style={{ fontFamily: 'monospace', fontSize: '11px', width: '100%' }}
                />
              </label>
            </div>
          </div>
          
          <div className="panel-header">
            <h3>📋 Print Job Sections</h3>
          </div>
          <div className="settings-section">
            <div className="settings-group">
              <label>
                <span>Before Printing (start of job)</span>
                <textarea
                  rows="3"
                  placeholder="M117 Starting print...&#10;G4 P1000"
                  value={settings.beforePrintingGcode}
                  onChange={(e) => updateSetting('beforePrintingGcode', e.target.value)}
                  style={{ fontFamily: 'monospace', fontSize: '11px', width: '100%' }}
                />
              </label>
              <label>
                <span>After Printing (end of job)</span>
                <textarea
                  rows="3"
                  placeholder="M117 Print complete&#10;G4 P1000"
                  value={settings.afterPrintingGcode}
                  onChange={(e) => updateSetting('afterPrintingGcode', e.target.value)}
                  style={{ fontFamily: 'monospace', fontSize: '11px', width: '100%' }}
                />
              </label>
            </div>
          </div>
          
          {settings.numLines > 1 && (
            <>
              <div className="panel-header">
                <h3>🔄 Multi-Line Options</h3>
              </div>
              <div className="settings-section">
                <div className="settings-group">
                  <label style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <input
                      type="checkbox"
                      checked={settings.zigzagLines}
                      onChange={(e) => updateSetting('zigzagLines', e.target.checked)}
                    />
                    <span>Zigzag printing (alternate direction)</span>
                  </label>
                  <small style={{ color: '#888', fontSize: '10px', marginLeft: '24px' }}>
                    Faster: prints back and forth instead of returning to start
                  </small>
                  
                  <label style={{ marginTop: '12px' }}>
                    <span>Before Line Segment</span>
                    <textarea
                      rows="2"
                      placeholder="G4 P50  ; Pause before line"
                      value={settings.beforeLineSegmentGcode}
                      onChange={(e) => updateSetting('beforeLineSegmentGcode', e.target.value)}
                      style={{ fontFamily: 'monospace', fontSize: '11px', width: '100%' }}
                    />
                  </label>
                  <label>
                    <span>After Line Segment</span>
                    <textarea
                      rows="2"
                      placeholder="G4 P50  ; Pause after line"
                      value={settings.afterLineSegmentGcode}
                      onChange={(e) => updateSetting('afterLineSegmentGcode', e.target.value)}
                      style={{ fontFamily: 'monospace', fontSize: '11px', width: '100%' }}
                    />
                  </label>
                </div>
              </div>
            </>
          )}
          
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
              <div className="stat"><span>Total Volume:</span> {gcodeStats.totalVolume.toFixed(2)} µL</div>
              <div className="stat"><span>Per Line:</span> {gcodeStats.volumePerLine.toFixed(2)} µL</div>
              <div className="stat"><span>Flow Rate:</span> {gcodeStats.flowRate.toFixed(4)} µL/s</div>
              <div className="stat"><span>E:</span> {gcodeStats.startE} → {gcodeStats.finalE.toFixed(2)} µL</div>
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
