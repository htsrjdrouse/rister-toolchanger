import React, { useState, useRef, useEffect, useCallback } from 'react';
import * as THREE from 'three';
import { STLLoader } from 'three/examples/jsm/loaders/STLLoader';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';

// Default JSCAD template for nanoarray lines
const DEFAULT_CODE = `// Nanoarray Line Generator
// Creates parallel lines for perovskite deposition on 100x100mm substrate

const jscad = require('@jscad/modeling');
const { cuboid } = jscad.primitives;
const { translate, rotateZ } = jscad.transforms;
const { union } = jscad.booleans;

// Parameters - adjust these values
const LINE_LENGTH = 50;       // Line length in mm
const LINE_WIDTH = 0.1;       // Line width in mm (100 microns)
const LINE_HEIGHT = 0.05;     // Line height in mm (50 microns)
const LINE_SPACING = 1.0;     // Spacing between lines in mm
const NUM_LINES = 10;         // Number of lines

// Substrate dimensions (for reference)
const SUBSTRATE_SIZE = 100;   // 100mm x 100mm

// Calculate starting position to center the pattern
const patternWidth = (NUM_LINES - 1) * LINE_SPACING;
const startY = -patternWidth / 2;
const startX = -LINE_LENGTH / 2;

function main() {
  const lines = [];
  
  for (let i = 0; i < NUM_LINES; i++) {
    const y = startY + (i * LINE_SPACING);
    const line = translate(
      [startX + LINE_LENGTH/2, y, LINE_HEIGHT/2],
      cuboid({ size: [LINE_LENGTH, LINE_WIDTH, LINE_HEIGHT] })
    );
    lines.push(line);
  }
  
  return union(lines);
}

module.exports = { main };
`;

function ShapeDesigner({ design, onSave, isPublisher }) {
  const [code, setCode] = useState(DEFAULT_CODE);
  const [stlData, setStlData] = useState(null);
  const [gcode, setGcode] = useState('');
  const [compiling, setCompiling] = useState(false);
  const [slicing, setSlicing] = useState(false);
  const [logs, setLogs] = useState('');
  const [error, setError] = useState('');
  const [gcodeStats, setGcodeStats] = useState(null);
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

  // Slice STL to G-code
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
        
        {/* Right Panel - Slicer & G-code */}
        <div className="shape-panel gcode-panel">
          <div className="panel-header">
            <h3>⚙️ Slicer</h3>
            <div className="panel-actions">
              <button 
                className="btn btn-primary" 
                onClick={handleSlice}
                disabled={slicing || !stlData}
              >
                {slicing ? '⏳ Slicing...' : '🔪 Slice'}
              </button>
              {gcode && (
                <button className="btn btn-success" onClick={downloadGcode}>
                  💾 Download G-code
                </button>
              )}
            </div>
          </div>
          
          {/* Slicer Settings */}
          <div className="slicer-settings">
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
          
          {/* G-code Stats */}
          {gcodeStats && (
            <div className="gcode-stats">
              <h4>📊 Statistics</h4>
              <div className="stats-grid">
                <span>Lines: {gcodeStats.totalLines}</span>
                <span>Moves: {gcodeStats.moveCount}</span>
                <span>Layers: {gcodeStats.layerCount}</span>
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
              placeholder="G-code will appear here after slicing..."
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
