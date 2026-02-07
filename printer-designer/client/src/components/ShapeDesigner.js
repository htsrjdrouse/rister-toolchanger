import React, { useState, useRef, useEffect, useCallback } from 'react';
import * as THREE from 'three';
import { STLLoader } from 'three/examples/jsm/loaders/STLLoader';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';

// Default JSCAD template for nanoarray lines
// Lines rotated 90° around Y-axis - lines run along Z-direction for dispensing
const DEFAULT_CODE = `// Nanoarray Line Generator – lines rotated 90° around Y-axis
// Lines now run along Z-direction, spaced along X
// This orientation matches dispenser toolhead movement

const jscad = require('@jscad/modeling');
const { cuboid } = jscad.primitives;
const { translate } = jscad.transforms;
const { union } = jscad.booleans;

// Parameters – adjust these values
const LINE_LENGTH = 50;       // Length along Z-axis in mm
const LINE_WIDTH = 0.1;       // Thickness in X direction (100 µm)
const LINE_HEIGHT = 0.05;     // Thickness in Y direction (50 µm)
const LINE_SPACING = 1.0;     // Spacing between lines along X
const NUM_LINES = 10;         // Number of parallel lines

// Substrate dimensions (for reference / visualization)
const SUBSTRATE_SIZE = 100;   // 100 × 100 mm

// Calculate starting position to center the pattern
const patternWidth = (NUM_LINES - 1) * LINE_SPACING;
const startX = -patternWidth / 2;  // Spacing direction is now X

function main() {
  const lines = [];
  
  for (let i = 0; i < NUM_LINES; i++) {
    const x = startX + (i * LINE_SPACING);
    // Create thin cuboid lying along Z-axis
    const line = cuboid({
      size: [LINE_WIDTH, LINE_HEIGHT, LINE_LENGTH],  // [X, Y, Z]
      center: [x, 0, 0]
    });
    lines.push(line);
  }
  
  return union(lines);
}

module.exports = { main };
`;

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
  const [code, setCode] = useState(DEFAULT_CODE);
  const [stlData, setStlData] = useState(null);
  const [gcode, setGcode] = useState('');
  const [compiling, setCompiling] = useState(false);
  const [slicing, setSlicing] = useState(false);
  const [logs, setLogs] = useState('');
  const [error, setError] = useState('');
  const [gcodeStats, setGcodeStats] = useState(null);
  
  // Dispenser settings (replaces slicer for liquid dispensing)
  const [dispenserSettings, setDispenserSettings] = useState({
    // Line pattern
    lineLength: 70,        // mm - length of each line
    lineSpacing: 1.0,      // mm - spacing between lines
    numLines: 10,          // number of parallel lines
    lineWidth: 0.3,        // mm - target line width on substrate
    lineHeight: 0.05,      // mm - target line height/thickness
    
    // Dispenser hardware
    needleGauge: '25G',    // needle size
    syringeSize: '1ml',    // syringe volume
    
    // Motion
    feedrate: 300,         // mm/min - travel speed while dispensing
    travelFeedrate: 3000,  // mm/min - travel speed (no dispensing)
    zHeight: 0.5,          // mm - nozzle height above substrate
    zTravel: 5,            // mm - Z height for travel moves
    
    // Substrate position (centered on 200x200 bed)
    substrateX: 100,       // mm - substrate center X
    substrateY: 100,       // mm - substrate center Y
    
    // Extruder settings
    extruderIndex: 2,      // T2 for syringe pump
    eMultiplier: 1.0,      // extrusion multiplier for tuning
  });
  
  // Legacy slicer settings (kept for compatibility)
  const [slicerSettings, setSlicerSettings] = useState({
    layerHeight: 0.05,
    extrusionWidth: 0.1,
    perimeterSpeed: 5
  });
  const [buildPlate, setBuildPlate] = useState({
    width: 100,
    height: 100
  });
  
  const viewerRef = useRef(null);
  const sceneRef = useRef(null);
  const rendererRef = useRef(null);
  const meshRef = useRef(null);
  const controlsRef = useRef(null);
  const animationRef = useRef(null);
  const gridRef = useRef(null);
  const substrateRef = useRef(null);
  const cameraRef = useRef(null);

  // Initialize Three.js scene
  useEffect(() => {
    if (!viewerRef.current) return;
    
    // Scene
    const scene = new THREE.Scene();
    scene.background = new THREE.Color(0x1a1a2e);
    sceneRef.current = scene;
    
    // Camera
    const camera = new THREE.PerspectiveCamera(
      50,
      viewerRef.current.clientWidth / viewerRef.current.clientHeight,
      0.1,
      1000
    );
    camera.position.set(80, 80, 80);
    
    // Renderer
    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(viewerRef.current.clientWidth, viewerRef.current.clientHeight);
    renderer.setPixelRatio(window.devicePixelRatio);
    viewerRef.current.appendChild(renderer.domElement);
    rendererRef.current = renderer;
    
    // Controls
    const controls = new OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.dampingFactor = 0.05;
    controls.target.set(0, 0, 0);
    controlsRef.current = controls;
    cameraRef.current = camera;
    
    // Lighting
    const ambientLight = new THREE.AmbientLight(0x404040, 0.8);
    scene.add(ambientLight);
    
    const directionalLight = new THREE.DirectionalLight(0xffffff, 1);
    directionalLight.position.set(50, 100, 50);
    scene.add(directionalLight);
    
    const directionalLight2 = new THREE.DirectionalLight(0xffffff, 0.5);
    directionalLight2.position.set(-50, 50, -50);
    scene.add(directionalLight2);
    
    // Grid helper (initial size, will be updated by buildPlate effect)
    const gridHelper = new THREE.GridHelper(100, 20, 0x444444, 0x333333);
    gridHelper.rotation.x = Math.PI / 2;
    scene.add(gridHelper);
    gridRef.current = gridHelper;
    
    // Substrate outline
    const substrateGeometry = new THREE.PlaneGeometry(100, 100);
    const substrateMaterial = new THREE.MeshBasicMaterial({ 
      color: 0x16213e, 
      side: THREE.DoubleSide,
      transparent: true,
      opacity: 0.5
    });
    const substrate = new THREE.Mesh(substrateGeometry, substrateMaterial);
    substrate.position.z = -0.01;
    scene.add(substrate);
    substrateRef.current = substrate;
    
    // Animation loop
    const animate = () => {
      animationRef.current = requestAnimationFrame(animate);
      controls.update();
      renderer.render(scene, camera);
    };
    animate();
    
    // Handle resize
    const handleResize = () => {
      if (!viewerRef.current) return;
      const width = viewerRef.current.clientWidth;
      const height = viewerRef.current.clientHeight;
      camera.aspect = width / height;
      camera.updateProjectionMatrix();
      renderer.setSize(width, height);
    };
    window.addEventListener('resize', handleResize);
    
    // Cleanup
    return () => {
      window.removeEventListener('resize', handleResize);
      cancelAnimationFrame(animationRef.current);
      renderer.dispose();
      if (viewerRef.current && renderer.domElement) {
        viewerRef.current.removeChild(renderer.domElement);
      }
    };
  }, []);

  // Update grid and substrate when buildPlate changes
  useEffect(() => {
    if (!sceneRef.current || !gridRef.current || !substrateRef.current) return;
    
    const scene = sceneRef.current;
    const maxDim = Math.max(buildPlate.width, buildPlate.height);
    const divisions = Math.max(10, Math.floor(maxDim / 5)); // Grid line every 5mm minimum
    
    // Remove old grid
    scene.remove(gridRef.current);
    gridRef.current.dispose();
    
    // Create new grid with updated size
    const newGrid = new THREE.GridHelper(maxDim, divisions, 0x444444, 0x333333);
    newGrid.rotation.x = Math.PI / 2;
    scene.add(newGrid);
    gridRef.current = newGrid;
    
    // Update substrate plane
    substrateRef.current.geometry.dispose();
    substrateRef.current.geometry = new THREE.PlaneGeometry(buildPlate.width, buildPlate.height);
    
    // Adjust camera position based on build plate size
    if (cameraRef.current && controlsRef.current) {
      const distance = maxDim * 1.5;
      cameraRef.current.position.set(distance, distance, distance);
      controlsRef.current.update();
    }
    
  }, [buildPlate]);

  // Load STL into scene when stlData changes
  useEffect(() => {
    if (!stlData || !sceneRef.current) return;
    
    // Remove old mesh
    if (meshRef.current) {
      sceneRef.current.remove(meshRef.current);
      meshRef.current.geometry.dispose();
      meshRef.current.material.dispose();
    }
    
    // Load new STL
    const loader = new STLLoader();
    const buffer = Uint8Array.from(atob(stlData), c => c.charCodeAt(0)).buffer;
    
    try {
      const geometry = loader.parse(buffer);
      geometry.computeVertexNormals();
      
      // Center the geometry
      geometry.computeBoundingBox();
      const center = new THREE.Vector3();
      geometry.boundingBox.getCenter(center);
      geometry.translate(-center.x, -center.y, 0);
      
      const material = new THREE.MeshStandardMaterial({
        color: 0x00d4ff,
        metalness: 0.3,
        roughness: 0.6
      });
      
      const mesh = new THREE.Mesh(geometry, material);
      mesh.rotation.x = -Math.PI / 2; // Rotate to lay flat
      sceneRef.current.add(mesh);
      meshRef.current = mesh;
      
      // Fit camera to object
      const box = new THREE.Box3().setFromObject(mesh);
      const size = box.getSize(new THREE.Vector3());
      const maxDim = Math.max(size.x, size.y, size.z);
      const distance = maxDim * 2;
      
      if (controlsRef.current) {
        controlsRef.current.target.set(0, 0, size.z / 2);
        controlsRef.current.object.position.set(distance, distance, distance);
        controlsRef.current.update();
      }
      
      setLogs(prev => prev + '\nSTL loaded successfully');
    } catch (err) {
      setError('Failed to parse STL: ' + err.message);
    }
  }, [stlData]);

  // Compile JSCAD to STL
  const handleCompile = async () => {
    setCompiling(true);
    setError('');
    setLogs('Compiling JSCAD...');
    
    try {
      const response = await fetch('/api/shape/compile', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ code })
      });
      
      const result = await response.json();
      
      if (result.success) {
        setStlData(result.stl);
        setLogs(prev => prev + '\n' + result.logs);
      } else {
        setError(result.error);
        setLogs(prev => prev + '\nError: ' + result.logs);
      }
    } catch (err) {
      setError('Compilation failed: ' + err.message);
    } finally {
      setCompiling(false);
    }
  };

  // Generate G-code directly for dispenser (no slicer needed)
  const generateDispenserGcode = () => {
    const s = dispenserSettings;
    const syringeDiameter = SYRINGE_SIZES[s.syringeSize] || 4.78;
    const needleDiameter = NEEDLE_GAUGES[s.needleGauge] || 0.260;
    
    // Calculate extrusion: E per mm of line
    // Volume of line per mm = lineWidth × lineHeight × 1mm
    // E = volume / plunger_area (how far plunger must move)
    const plungerArea = Math.PI * Math.pow(syringeDiameter / 2, 2);
    const lineVolumePerMm = s.lineWidth * s.lineHeight; // mm³ per mm of line
    const ePerMm = (lineVolumePerMm / plungerArea) * s.eMultiplier;
    
    // Calculate pattern dimensions
    const patternWidth = (s.numLines - 1) * s.lineSpacing;
    const startX = s.substrateX - patternWidth / 2;
    const startY = s.substrateY - s.lineLength / 2;
    const endY = s.substrateY + s.lineLength / 2;
    
    // Build G-code
    const lines = [];
    const timestamp = new Date().toISOString();
    
    // Header
    lines.push('; Nanoarray Dispenser G-code');
    lines.push(`; Generated: ${timestamp}`);
    lines.push(';');
    lines.push('; === Pattern Parameters ===');
    lines.push(`; Lines: ${s.numLines}`);
    lines.push(`; Line length: ${s.lineLength} mm`);
    lines.push(`; Line spacing: ${s.lineSpacing} mm`);
    lines.push(`; Line width: ${s.lineWidth} mm`);
    lines.push(`; Line height: ${s.lineHeight} mm`);
    lines.push(';');
    lines.push('; === Dispenser Settings ===');
    lines.push(`; Needle: ${s.needleGauge} (ID: ${needleDiameter.toFixed(3)} mm)`);
    lines.push(`; Syringe: ${s.syringeSize} (ID: ${syringeDiameter.toFixed(2)} mm)`);
    lines.push(`; Plunger area: ${plungerArea.toFixed(3)} mm²`);
    lines.push(`; E per mm: ${ePerMm.toFixed(6)} mm`);
    lines.push(`; Feedrate: ${s.feedrate} mm/min`);
    lines.push(`; Z height: ${s.zHeight} mm`);
    lines.push(';');
    lines.push('; === Calculated Values ===');
    lines.push(`; Total line length: ${(s.lineLength * s.numLines).toFixed(1)} mm`);
    lines.push(`; Total E: ${(ePerMm * s.lineLength * s.numLines).toFixed(4)} mm`);
    lines.push(`; Approx volume: ${(lineVolumePerMm * s.lineLength * s.numLines).toFixed(4)} mm³`);
    lines.push(';');
    lines.push('');
    
    // Setup
    lines.push('; === Setup ===');
    lines.push('G21 ; mm units');
    lines.push('G90 ; absolute positioning');
    lines.push('M83 ; relative extrusion');
    lines.push(`T${s.extruderIndex} ; select syringe pump extruder`);
    lines.push('');
    
    // Move to start position
    lines.push('; === Move to start ===');
    lines.push(`G1 Z${s.zTravel} F1000 ; raise Z for travel`);
    lines.push(`G1 X${startX.toFixed(3)} Y${startY.toFixed(3)} F${s.travelFeedrate} ; move to first line start`);
    lines.push(`G1 Z${s.zHeight} F500 ; lower to dispense height`);
    lines.push('');
    
    // Generate lines
    lines.push('; === Dispense Lines ===');
    let totalE = 0;
    
    for (let i = 0; i < s.numLines; i++) {
      const x = startX + i * s.lineSpacing;
      const eForLine = ePerMm * s.lineLength;
      totalE += eForLine;
      
      lines.push(`; Line ${i + 1}/${s.numLines}`);
      
      if (i > 0) {
        // Travel to next line start (at travel Z)
        lines.push(`G1 Z${s.zTravel} F500 ; raise for travel`);
        lines.push(`G1 X${x.toFixed(3)} Y${startY.toFixed(3)} F${s.travelFeedrate} ; move to line start`);
        lines.push(`G1 Z${s.zHeight} F500 ; lower to dispense`);
      }
      
      // Dispense line (Y direction)
      lines.push(`G1 Y${endY.toFixed(3)} E${eForLine.toFixed(6)} F${s.feedrate} ; dispense line`);
    }
    
    lines.push('');
    
    // End
    lines.push('; === Finish ===');
    lines.push(`G1 Z${s.zTravel} F500 ; raise Z`);
    lines.push(`G1 X${s.substrateX} Y${s.substrateY} F${s.travelFeedrate} ; move to center`);
    lines.push('');
    lines.push(`; Total E: ${totalE.toFixed(6)} mm`);
    lines.push('; Done');
    
    const gcodeText = lines.join('\n');
    
    // Update state
    setGcode(gcodeText);
    setGcodeStats({
      totalLines: lines.length,
      moveCount: s.numLines * 2 + 4, // approximate
      layerCount: 1,
      bounds: {
        x: { min: startX, max: startX + patternWidth },
        y: { min: startY, max: endY },
        z: { min: s.zHeight, max: s.zTravel }
      },
      // Additional dispenser stats
      totalE: totalE,
      volumeMm3: lineVolumePerMm * s.lineLength * s.numLines,
      ePerMm: ePerMm,
    });
    setLogs(prev => prev + `\nGenerated dispenser G-code: ${s.numLines} lines, total E: ${totalE.toFixed(4)} mm`);
    setError('');
  };

  // Slice STL to G-code (legacy - use slicer)
  const handleSlice = async () => {
    if (!stlData) {
      setError('No STL to slice. Compile first.');
      return;
    }
    
    setSlicing(true);
    setError('');
    setLogs(prev => prev + '\nSlicing...');
    
    try {
      const response = await fetch('/api/shape/slice', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          stl: stlData,
          profile: 'nanoarray-base.ini',
          settings: slicerSettings
        })
      });
      
      const result = await response.json();
      
      if (result.success) {
        setGcode(result.gcode);
        setGcodeStats(result.stats);
        setLogs(prev => prev + '\nSlicing complete!\n' + result.logs);
      } else {
        setError(result.error);
        setLogs(prev => prev + '\nSlicing error: ' + result.logs);
      }
    } catch (err) {
      setError('Slicing failed: ' + err.message);
    } finally {
      setSlicing(false);
    }
  };

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

  // Download STL
  const downloadStl = () => {
    if (!stlData) return;
    
    const blob = new Blob([Uint8Array.from(atob(stlData), c => c.charCodeAt(0))], { type: 'application/octet-stream' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'nanoarray.stl';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  };

  return (
    <div className="shape-designer">
      <div className="shape-designer-header">
        <h2>🔬 Shape Designer</h2>
        <p>Design nanoarray patterns for perovskite deposition</p>
      </div>
      
      <div className="shape-designer-content">
        {/* Left Panel - Code Editor */}
        <div className="shape-panel code-panel">
          <div className="panel-header">
            <h3>📝 JSCAD Code</h3>
            <div className="panel-actions">
              <button 
                className="btn btn-primary" 
                onClick={handleCompile}
                disabled={compiling}
              >
                {compiling ? '⏳ Compiling...' : '▶️ Compile'}
              </button>
            </div>
          </div>
          <textarea
            className="code-editor"
            value={code}
            onChange={(e) => setCode(e.target.value)}
            spellCheck={false}
          />
        </div>
        
        {/* Center Panel - STL Viewer */}
        <div className="shape-panel viewer-panel">
          <div className="panel-header">
            <h3>🔍 3D Preview</h3>
            <div className="panel-actions">
              {stlData && (
                <button className="btn btn-secondary" onClick={downloadStl}>
                  💾 Download STL
                </button>
              )}
            </div>
          </div>
          <div className="stl-viewer" ref={viewerRef}></div>
          <div className="viewer-controls-info">
            <span>🖱️ Left: Rotate | Right: Pan | Scroll: Zoom</span>
          </div>
          {/* Build Plate Settings */}
          <div className="build-plate-settings">
            <span className="settings-label">📐 Build Plate:</span>
            <label>
              W:
              <input
                type="number"
                step="10"
                min="10"
                max="500"
                value={buildPlate.width}
                onChange={(e) => setBuildPlate(bp => ({ ...bp, width: parseInt(e.target.value) || 100 }))}
              />
              mm
            </label>
            <label>
              H:
              <input
                type="number"
                step="10"
                min="10"
                max="500"
                value={buildPlate.height}
                onChange={(e) => setBuildPlate(bp => ({ ...bp, height: parseInt(e.target.value) || 100 }))}
              />
              mm
            </label>
          </div>
        </div>
        
        {/* Right Panel - Dispenser G-code Generator */}
        <div className="shape-panel gcode-panel">
          <div className="panel-header">
            <h3>💧 Dispenser G-code</h3>
            <div className="panel-actions">
              <button 
                className="btn btn-primary" 
                onClick={generateDispenserGcode}
              >
                🔧 Generate G-code
              </button>
              {gcode && (
                <button className="btn btn-success" onClick={downloadGcode}>
                  💾 Download
                </button>
              )}
            </div>
          </div>
          
          {/* Dispenser Settings */}
          <div className="slicer-settings dispenser-settings">
            <h4>📏 Line Pattern</h4>
            <div className="settings-row">
              <label>
                Lines:
                <input
                  type="number"
                  min="1"
                  max="100"
                  value={dispenserSettings.numLines}
                  onChange={(e) => setDispenserSettings(s => ({ ...s, numLines: parseInt(e.target.value) || 1 }))}
                />
              </label>
              <label>
                Length (mm):
                <input
                  type="number"
                  step="1"
                  min="1"
                  value={dispenserSettings.lineLength}
                  onChange={(e) => setDispenserSettings(s => ({ ...s, lineLength: parseFloat(e.target.value) || 10 }))}
                />
              </label>
              <label>
                Spacing (mm):
                <input
                  type="number"
                  step="0.1"
                  min="0.1"
                  value={dispenserSettings.lineSpacing}
                  onChange={(e) => setDispenserSettings(s => ({ ...s, lineSpacing: parseFloat(e.target.value) || 0.5 }))}
                />
              </label>
            </div>
            <div className="settings-row">
              <label>
                Width (mm):
                <input
                  type="number"
                  step="0.01"
                  min="0.01"
                  value={dispenserSettings.lineWidth}
                  onChange={(e) => setDispenserSettings(s => ({ ...s, lineWidth: parseFloat(e.target.value) || 0.1 }))}
                />
              </label>
              <label>
                Height (mm):
                <input
                  type="number"
                  step="0.01"
                  min="0.01"
                  value={dispenserSettings.lineHeight}
                  onChange={(e) => setDispenserSettings(s => ({ ...s, lineHeight: parseFloat(e.target.value) || 0.05 }))}
                />
              </label>
            </div>
            
            <h4>🔧 Hardware</h4>
            <div className="settings-row">
              <label>
                Needle:
                <select
                  value={dispenserSettings.needleGauge}
                  onChange={(e) => setDispenserSettings(s => ({ ...s, needleGauge: e.target.value }))}
                >
                  {Object.entries(NEEDLE_GAUGES).map(([gauge, id]) => (
                    <option key={gauge} value={gauge}>{gauge} ({id}mm)</option>
                  ))}
                </select>
              </label>
              <label>
                Syringe:
                <select
                  value={dispenserSettings.syringeSize}
                  onChange={(e) => setDispenserSettings(s => ({ ...s, syringeSize: e.target.value }))}
                >
                  {Object.entries(SYRINGE_SIZES).map(([size, id]) => (
                    <option key={size} value={size}>{size} (⌀{id}mm)</option>
                  ))}
                </select>
              </label>
            </div>
            
            <h4>🚀 Motion</h4>
            <div className="settings-row">
              <label>
                Feedrate (mm/min):
                <input
                  type="number"
                  step="10"
                  min="10"
                  value={dispenserSettings.feedrate}
                  onChange={(e) => setDispenserSettings(s => ({ ...s, feedrate: parseInt(e.target.value) || 100 }))}
                />
              </label>
              <label>
                Z Height (mm):
                <input
                  type="number"
                  step="0.1"
                  min="0.1"
                  value={dispenserSettings.zHeight}
                  onChange={(e) => setDispenserSettings(s => ({ ...s, zHeight: parseFloat(e.target.value) || 0.5 }))}
                />
              </label>
            </div>
            <div className="settings-row">
              <label>
                E Multiplier:
                <input
                  type="number"
                  step="0.1"
                  min="0.1"
                  value={dispenserSettings.eMultiplier}
                  onChange={(e) => setDispenserSettings(s => ({ ...s, eMultiplier: parseFloat(e.target.value) || 1.0 }))}
                />
              </label>
              <label>
                Extruder (T):
                <input
                  type="number"
                  min="0"
                  max="5"
                  value={dispenserSettings.extruderIndex}
                  onChange={(e) => setDispenserSettings(s => ({ ...s, extruderIndex: parseInt(e.target.value) || 0 }))}
                />
              </label>
            </div>
            
            <h4>📍 Position</h4>
            <div className="settings-row">
              <label>
                Center X (mm):
                <input
                  type="number"
                  step="1"
                  value={dispenserSettings.substrateX}
                  onChange={(e) => setDispenserSettings(s => ({ ...s, substrateX: parseFloat(e.target.value) || 100 }))}
                />
              </label>
              <label>
                Center Y (mm):
                <input
                  type="number"
                  step="1"
                  value={dispenserSettings.substrateY}
                  onChange={(e) => setDispenserSettings(s => ({ ...s, substrateY: parseFloat(e.target.value) || 100 }))}
                />
              </label>
            </div>
          </div>
          
          {/* Legacy Slicer Settings - collapsed */}
          <details className="legacy-slicer">
            <summary>🔪 PrusaSlicer (for complex shapes)</summary>
            <div className="slicer-settings">
              <button 
                className="btn btn-secondary btn-sm" 
                onClick={handleSlice}
                disabled={slicing || !stlData}
              >
                {slicing ? '⏳ Slicing...' : 'Slice with PrusaSlicer'}
              </button>
              <label>
                Layer Height (mm):
                <input
                  type="number"
                  step="0.01"
                  value={slicerSettings.layerHeight}
                  onChange={(e) => setSlicerSettings(s => ({ ...s, layerHeight: parseFloat(e.target.value) }))}
                />
              </label>
              <label>
                Extrusion Width (mm):
                <input
                  type="number"
                  step="0.01"
                  value={slicerSettings.extrusionWidth}
                  onChange={(e) => setSlicerSettings(s => ({ ...s, extrusionWidth: parseFloat(e.target.value) }))}
                />
              </label>
              <label>
                Speed (mm/s):
                <input
                  type="number"
                  step="1"
                  value={slicerSettings.perimeterSpeed}
                  onChange={(e) => setSlicerSettings(s => ({ ...s, perimeterSpeed: parseInt(e.target.value) }))}
                />
              </label>
            </div>
          </details>
          
          {/* G-code Stats */}
          {gcodeStats && (
            <div className="gcode-stats">
              <h4>📊 Statistics</h4>
              <div className="stats-grid">
                <span>G-code Lines: {gcodeStats.totalLines}</span>
                <span>Moves: {gcodeStats.moveCount}</span>
                {gcodeStats.totalE && <span>Total E: {gcodeStats.totalE.toFixed(4)} mm</span>}
                {gcodeStats.volumeMm3 && <span>Volume: {gcodeStats.volumeMm3.toFixed(4)} mm³</span>}
                {gcodeStats.ePerMm && <span>E/mm: {gcodeStats.ePerMm.toFixed(6)}</span>}
                <span>X: {gcodeStats.bounds.x.min.toFixed(2)} → {gcodeStats.bounds.x.max.toFixed(2)}</span>
                <span>Y: {gcodeStats.bounds.y.min.toFixed(2)} → {gcodeStats.bounds.y.max.toFixed(2)}</span>
                <span>Z: {gcodeStats.bounds.z.min.toFixed(2)} → {gcodeStats.bounds.z.max.toFixed(2)}</span>
              </div>
            </div>
          )}
          
          {/* G-code Preview */}
          <div className="gcode-preview">
            <h4>📄 G-code Output</h4>
            <textarea
              className="gcode-output"
              value={gcode}
              readOnly
              placeholder="Click 'Generate G-code' to create dispenser commands..."
            />
          </div>
        </div>
      </div>
      
      {/* Bottom Panel - Logs & Errors */}
      <div className="shape-logs">
        {error && <div className="error-message">❌ {error}</div>}
        <div className="logs-output">
          <strong>📋 Logs:</strong>
          <pre>{logs}</pre>
        </div>
      </div>
    </div>
  );
}

export default ShapeDesigner;
