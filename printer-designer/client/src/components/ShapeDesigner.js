import React, { useState, useRef, useEffect, useCallback } from 'react';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';
import NumInput from './NumInput';

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
  dispenseAccel: 500,    // mm/s² - acceleration during dispensing
  restoreAccel: 3000,    // mm/s² - acceleration to restore after dispensing
  
  // Extruder settings
  eMultiplier: 1.0,      // fine-tune multiplier (1.0 = calibrated)
  eUnits: 'calibrated',  // 'calibrated' = 1 E = 1 µL (firmware calibrated), 'mm' = raw mm (use syringe area)
  
  // Per-line overrides
  perLineOverrides: [],  // Array of {delay, volume, speed} per line
  
  // Prime and post-dispense G-code
  primeGcode: '',        // G-code to insert before each dispense line
  postDispenseGcode: '', // G-code to insert after each dispense line
  
  // Print job sections
  beforePrintingGcode: '',    // G-code before entire print job
  afterPrintingGcode: '',     // G-code after entire print job
  beforeLineSetGcode: '',     // G-code before the group of lines (multi-line only)
  afterLineSetGcode: '',      // G-code after the group of lines (multi-line only)
  
  // Multi-line options
  zigzagLines: false,    // Alternate direction for faster printing

  // Arduino trigger mode
  triggerMode: false,       // Use Arduino trigger instead of Klipper extruder
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
  
  // Build plate size from design
  const bedW = design?.printerArea?.width || 380;
  const bedH = design?.printerArea?.height || 480;
  const bedMax = Math.max(bedW, bedH);
  
  const viewerRef = useRef(null);
  const sceneRef = useRef(null);
  const rendererRef = useRef(null);
  const controlsRef = useRef(null);
  const animationRef = useRef(null);
  const cameraRef = useRef(null);
  const linesGroupRef = useRef(null);
  const objectsGroupRef = useRef(null);
  const bedGroupRef = useRef(null);
  const [hoverCoords, setHoverCoords] = useState(null);
  const [sceneReady, setSceneReady] = useState(false);
  const raycasterRef = useRef(new THREE.Raycaster());
  const bedPlaneRef = useRef(new THREE.Plane(new THREE.Vector3(0, 1, 0), 0));

  // Keep raycaster plane at dispense height so hover coords match visual positions
  useEffect(() => {
    bedPlaneRef.current.constant = -(parseFloat(settings.zHeight) || 0);
  }, [settings.zHeight]);

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
    
    const cx = bedW / 2;
    const cz = bedH / 2;
    
    // Camera
    const camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 5000);
    camera.position.set(cx + bedMax * 0.4, bedMax * 0.5, cz + bedMax * 0.4);
    camera.lookAt(cx, 0, cz);
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
    controls.target.set(cx, 0, cz);
    controls.update();
    controlsRef.current = controls;
    
    // Lighting
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.6);
    scene.add(ambientLight);
    const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
    directionalLight.position.set(cx, bedMax, cz);
    scene.add(directionalLight);
    
    // Bed group (grid + plate) — replaced when bed size changes
    bedGroupRef.current = new THREE.Group();
    scene.add(bedGroupRef.current);
    
    // Objects group (design objects rendered on bed)
    objectsGroupRef.current = new THREE.Group();
    scene.add(objectsGroupRef.current);
    
    // Lines group
    linesGroupRef.current = new THREE.Group();
    scene.add(linesGroupRef.current);

    setSceneReady(true);
    
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

    // Mouse hover → bed coordinates
    const handleMouseMove = (e) => {
      const rect = renderer.domElement.getBoundingClientRect();
      const mouse = new THREE.Vector2(
        ((e.clientX - rect.left) / rect.width) * 2 - 1,
        -((e.clientY - rect.top) / rect.height) * 2 + 1
      );
      raycasterRef.current.setFromCamera(mouse, camera);
      const hit = new THREE.Vector3();
      if (raycasterRef.current.ray.intersectPlane(bedPlaneRef.current, hit)) {
        setHoverCoords({ x: hit.x, y: hit.z, z: hit.y });
      }
    };
    const handleMouseLeave = () => setHoverCoords(null);
    renderer.domElement.addEventListener('mousemove', handleMouseMove);
    renderer.domElement.addEventListener('mouseleave', handleMouseLeave);
    
    return () => {
      window.removeEventListener('resize', handleResize);
      renderer.domElement.removeEventListener('mousemove', handleMouseMove);
      renderer.domElement.removeEventListener('mouseleave', handleMouseLeave);
      cancelAnimationFrame(animationRef.current);
      renderer.dispose();
      container.removeChild(renderer.domElement);
    };
  }, []); // init once

  // Update bed grid + plate when design printer area changes
  useEffect(() => {
    const group = bedGroupRef.current;
    if (!group) return;
    while (group.children.length) group.remove(group.children[0]);

    const cx = bedW / 2;
    const cz = bedH / 2;
    const gridSize = Math.max(bedW, bedH);
    const divisions = Math.round(gridSize / 20);

    const gridHelper = new THREE.GridHelper(gridSize, divisions, 0x444444, 0x333333);
    gridHelper.position.set(cx, 0, cz);
    group.add(gridHelper);

    // Bed outline
    const plateGeo = new THREE.PlaneGeometry(bedW, bedH);
    const plateMat = new THREE.MeshBasicMaterial({ color: 0x2a2a4e, side: THREE.DoubleSide, transparent: true, opacity: 0.3 });
    const plate = new THREE.Mesh(plateGeo, plateMat);
    plate.rotation.x = -Math.PI / 2;
    plate.position.set(cx, -0.1, cz);
    group.add(plate);

    // Bed border
    const border = new THREE.LineLoop(
      new THREE.BufferGeometry().setFromPoints([
        new THREE.Vector3(0, 0.01, 0),
        new THREE.Vector3(bedW, 0.01, 0),
        new THREE.Vector3(bedW, 0.01, bedH),
        new THREE.Vector3(0, 0.01, bedH),
      ]),
      new THREE.LineBasicMaterial({ color: 0x666688 })
    );
    group.add(border);

    // Update camera/controls to frame the bed
    if (cameraRef.current && controlsRef.current) {
      const bMax = Math.max(bedW, bedH);
      cameraRef.current.position.set(cx + bMax * 0.4, bMax * 0.5, cz + bMax * 0.4);
      controlsRef.current.target.set(cx, 0, cz);
      controlsRef.current.update();
    }
  }, [bedW, bedH]);

  // Render design objects on the bed
  useEffect(() => {
    const group = objectsGroupRef.current;
    if (!group) return;
    while (group.children.length) group.remove(group.children[0]);

    const objects = design?.objects || [];
    objects.forEach((obj) => {
      if (obj.status === 'off') return;
      const px = parseFloat(obj.posx) || 0;
      const py = parseFloat(obj.posy) || 0;
      const sx = parseFloat(obj.X) || 10;
      const sy = parseFloat(obj.Y) || 10;
      const sz = parseFloat(obj.Z) || 1;
      const [r, g, b] = (obj.color || '99,87,101').split(',').map(c => parseInt(c.trim()));
      const color = new THREE.Color(r / 255, g / 255, b / 255);

      // 3D box: X=width, Y=height(Z), Z=depth
      const geo = new THREE.BoxGeometry(sx, sz, sy);
      const mat = new THREE.MeshPhongMaterial({
        color,
        transparent: true,
        opacity: 0.4,
        depthWrite: false,
      });
      const mesh = new THREE.Mesh(geo, mat);
      mesh.position.set(px + sx / 2, sz / 2, py + sy / 2);
      group.add(mesh);

      // Wireframe edges
      const edges = new THREE.LineSegments(
        new THREE.EdgesGeometry(geo),
        new THREE.LineBasicMaterial({ color, transparent: true, opacity: 0.6 })
      );
      edges.position.copy(mesh.position);
      group.add(edges);

      // Label on top
      if (obj.name) {
        const canvas = document.createElement('canvas');
        canvas.width = 256;
        canvas.height = 64;
        const ctx = canvas.getContext('2d');
        ctx.fillStyle = `rgb(${r},${g},${b})`;
        ctx.font = 'bold 28px sans-serif';
        ctx.fillText(obj.name, 4, 40);
        const tex = new THREE.CanvasTexture(canvas);
        const labelGeo = new THREE.PlaneGeometry(sx * 0.8, sx * 0.2);
        const labelMat = new THREE.MeshBasicMaterial({ map: tex, transparent: true, side: THREE.DoubleSide });
        const label = new THREE.Mesh(labelGeo, labelMat);
        label.rotation.x = -Math.PI / 2;
        label.position.set(px + sx / 2, sz + 0.5, py + sy / 2);
        group.add(label);
      }
    });
  }, [design?.objects, design?.printerArea, sceneReady]);

  // Update 3D preview when settings change
  const updatePreview = useCallback(() => {
    if (!linesGroupRef.current) return;
    
    // Clear existing lines
    while (linesGroupRef.current.children.length > 0) {
      linesGroupRef.current.remove(linesGroupRef.current.children[0]);
    }
    
    const s = settings;
    const endY = s.startY + s.lineLength;
    
    // Display dimensions for preview
    const displayWidth = Math.max(0.3, s.lineSpacing * 0.3);
    
    // Create line meshes with direction arrows
    for (let i = 0; i < s.numLines; i++) {
      const x = s.startX + i * s.lineSpacing;
      const isReverse = s.zigzagLines && (i % 2 === 1);
      const yStart = isReverse ? endY : s.startY;
      const yEnd = isReverse ? s.startY : endY;
      
      // Line as a thin 3D path (3D coords: X=gcode X, Y=gcode Z height, Z=gcode Y)
      const points = [
        new THREE.Vector3(x, s.zHeight, yStart),
        new THREE.Vector3(x, s.zHeight, yEnd),
      ];
      const lineGeo = new THREE.BufferGeometry().setFromPoints(points);
      const lineMat = new THREE.LineBasicMaterial({ color: 0x00d9ff, linewidth: 2 });
      const lineMesh = new THREE.Line(lineGeo, lineMat);
      linesGroupRef.current.add(lineMesh);
      
      // Thin box for visibility
      const boxGeo = new THREE.BoxGeometry(displayWidth, 0.3, s.lineLength);
      const boxMat = new THREE.MeshPhongMaterial({ color: 0x00d9ff, transparent: true, opacity: 0.5 });
      const box = new THREE.Mesh(boxGeo, boxMat);
      box.position.set(x, s.zHeight, s.startY + s.lineLength / 2);
      linesGroupRef.current.add(box);
      
      // Arrow showing dispense direction
      const dir = new THREE.Vector3(0, 0, yEnd > yStart ? 1 : -1);
      const arrowOrigin = new THREE.Vector3(x, s.zHeight + 0.5, (yStart + yEnd) / 2);
      const arrowLen = s.lineLength * 0.3;
      const arrow = new THREE.ArrowHelper(dir, arrowOrigin, arrowLen, 0x00ff88, arrowLen * 0.3, arrowLen * 0.15);
      linesGroupRef.current.add(arrow);
      
      // Travel move from previous line (dashed)
      if (i > 0) {
        const prevX = s.startX + (i - 1) * s.lineSpacing;
        const prevReverse = s.zigzagLines && ((i - 1) % 2 === 1);
        const prevEnd = prevReverse ? s.startY : endY;
        // Travel: lift → move XY → lower
        const travelPts = [
          new THREE.Vector3(prevX, s.zHeight, prevEnd),
          new THREE.Vector3(prevX, s.zTravel, prevEnd),
          new THREE.Vector3(x, s.zTravel, yStart),
          new THREE.Vector3(x, s.zHeight, yStart),
        ];
        const travelGeo = new THREE.BufferGeometry().setFromPoints(travelPts);
        const travelMat = new THREE.LineDashedMaterial({ color: 0xffaa00, dashSize: 3, gapSize: 2 });
        const travelLine = new THREE.Line(travelGeo, travelMat);
        travelLine.computeLineDistances();
        linesGroupRef.current.add(travelLine);
      }
    }
    
    // Start position marker (larger, at actual start position)
    const markerGeometry = new THREE.SphereGeometry(2, 16, 16);
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
    if (!s.triggerMode) {
      lines.push('G92 E0 ; reset extruder position to zero');
    }
    lines.push('');
    
    // Before printing section
    if (s.beforePrintingGcode && s.beforePrintingGcode.trim()) {
      lines.push('; === Before Printing ===');
      lines.push(s.beforePrintingGcode.trim());
      lines.push('');
    }
    
    // Move to start
    lines.push(`G1 X${s.startX.toFixed(3)} Y${s.startY.toFixed(3)} F${s.travelFeedrate} ; move to start XY`);
    lines.push(`G1 Z${s.startZ} F1000 ; move to start Z`);
    lines.push(`G1 Z${s.zHeight} F500 ; lower to dispense height`);
    lines.push('');
    
    // Before line set (multi-line only)
    const multiLine = s.numLines > 1;
    if (multiLine && s.beforeLineSetGcode && s.beforeLineSetGcode.trim()) {
      lines.push('; === Before Line Set ===');
      lines.push(s.beforeLineSetGcode.trim());
      lines.push('');
    }
    
    // Set initial acceleration
    lines.push(`M204 S${s.dispenseAccel} ; set dispense acceleration`);
    lines.push('');
    
    // Dispense lines (absolute E positions - POSITIVE for dispensing)
    // Syringe pump: dispense = positive E (pushes plunger down)
    let currentE = 0;
    let prevAccel = s.dispenseAccel;
    
    for (let i = 0; i < s.numLines; i++) {
      const x = s.startX + i * s.lineSpacing;
      
      // Get per-line overrides
      const override = (s.perLineOverrides || [])[i] || { 
        eMultiplier: parseFloat(s.eMultiplier) || 1.0, 
        accel: s.dispenseAccel 
      };
      const lineEMultiplier = parseFloat(override.eMultiplier) || 1.0;
      const lineAccel = parseInt(override.accel) || s.dispenseAccel;
      
      // Calculate E for this line using per-line multiplier
      const lineEDisplacement = isCalibrated 
        ? volumePerLine * lineEMultiplier
        : (volumePerLine / syringeArea) * lineEMultiplier;
      currentE += lineEDisplacement;
      
      // Determine direction based on zigzag setting
      const isReverse = s.zigzagLines && (i % 2 === 1);
      const yStart = isReverse ? endY : s.startY;
      const yEnd = isReverse ? s.startY : endY;
      
      lines.push(`; Line ${i + 1} (E mult: ${lineEMultiplier.toFixed(2)})`);
      
      if (i > 0) {
        lines.push(`G1 Z${s.zTravel} F500`);
        lines.push(`G1 X${x.toFixed(3)} Y${yStart.toFixed(3)} F${s.travelFeedrate}`);
        lines.push(`G1 Z${s.zHeight} F500`);
      }
      
      // Set acceleration if different from previous line
      if (lineAccel !== prevAccel) {
        lines.push(`M204 S${lineAccel}`);
        prevAccel = lineAccel;
      }
      
      // Insert prime G-code before dispense
      if (s.primeGcode && s.primeGcode.trim()) {
        lines.push(s.primeGcode.trim());
      }
      
      if (s.triggerMode) {
        lines.push(`G1 Y${yEnd.toFixed(3)} F${s.feedrate} ; XY move`);
      } else {
        lines.push(`G1 Y${yEnd.toFixed(3)} E${currentE.toFixed(2)} F${s.feedrate}`);
      }
      
      // Insert post-dispense G-code after dispense
      if (s.postDispenseGcode && s.postDispenseGcode.trim()) {
        lines.push(s.postDispenseGcode.trim());
      }
    }
    
    // Total volume calculation depends on E units mode
    const totalEDisplacement = currentE;  // Total E moved (positive = dispensed)
    const totalVolume = isCalibrated 
      ? totalEDisplacement                       // Calibrated: E = µL directly
      : totalEDisplacement * syringeArea;        // Raw mm: need area conversion
    
    lines.push('');
    lines.push(`G1 Z${s.zTravel} F500 ; lift to travel height`);
    lines.push(`M204 S${s.restoreAccel} ; restore acceleration`);
    
    // After line set (multi-line only)
    if (multiLine && s.afterLineSetGcode && s.afterLineSetGcode.trim()) {
      lines.push('');
      lines.push('; === After Line Set ===');
      lines.push(s.afterLineSetGcode.trim());
    }
    
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

  // Track which per-line overrides have been manually edited
  const [editedOverrides, setEditedOverrides] = useState(new Set());
  const [overridesExpanded, setOverridesExpanded] = useState(false);

  // Initialize per-line overrides when numLines changes
  useEffect(() => {
    const numLines = settings.numLines || 1;
    const currentOverrides = settings.perLineOverrides || [];
    
    if (currentOverrides.length !== numLines) {
      const newOverrides = Array.from({ length: numLines }, (_, i) => {
        if (i < currentOverrides.length && editedOverrides.has(i)) {
          return currentOverrides[i]; // Keep manually edited values
        }
        return {
          eMultiplier: settings.eMultiplier,
          accel: settings.dispenseAccel
        };
      });
      updateSetting('perLineOverrides', newOverrides);
    }
  }, [settings.numLines]);

  // Update non-edited overrides when global values change
  useEffect(() => {
    const overrides = settings.perLineOverrides || [];
    const updated = overrides.map((override, i) => {
      if (editedOverrides.has(i)) return override;
      return {
        eMultiplier: settings.eMultiplier,
        accel: settings.dispenseAccel
      };
    });
    if (JSON.stringify(updated) !== JSON.stringify(overrides)) {
      updateSetting('perLineOverrides', updated);
    }
  }, [settings.eMultiplier, settings.dispenseAccel]);

  const updateLineOverride = (lineIndex, field, value) => {
    const overrides = [...(settings.perLineOverrides || [])];
    overrides[lineIndex] = { ...overrides[lineIndex], [field]: value };
    updateSetting('perLineOverrides', overrides);
    setEditedOverrides(prev => new Set(prev).add(lineIndex));
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
                <NumInput
                  min="1"
                  max="100"
                  value={settings.numLines}
                  onChange={(v) => updateSetting('numLines', v)}
                  fallback={1}
                  integer
                />
              </label>
              <label>
                <span>Line Length (mm)</span>
                <NumInput
                  step="1"
                  min="1"
                  value={settings.lineLength}
                  onChange={(v) => updateSetting('lineLength', v)}
                  fallback={10}
                />
              </label>
              <label>
                <span>Line Spacing (mm)</span>
                <NumInput
                  step="0.1"
                  min="0.1"
                  value={settings.lineSpacing}
                  onChange={(v) => updateSetting('lineSpacing', v)}
                  fallback={0.5}
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
                <NumInput
                  step="0.5"
                  min="0.1"
                  value={settings.volumePerLine}
                  onChange={(v) => updateSetting('volumePerLine', v)}
                  fallback={1}
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
                <NumInput
                  step="1"
                  value={settings.startX}
                  onChange={(v) => updateSetting('startX', v)}
                  fallback={0}
                />
              </label>
              <label>
                <span>Y (mm)</span>
                <NumInput
                  step="1"
                  value={settings.startY}
                  onChange={(v) => updateSetting('startY', v)}
                  fallback={0}
                />
              </label>
            </div>
            <div className="settings-group horizontal">
              <label>
                <span>Z (mm)</span>
                <NumInput
                  step="1"
                  min="0"
                  value={settings.startZ}
                  onChange={(v) => updateSetting('startZ', v)}
                  fallback={0}
                />
              </label>
              <label>
                <span>E (µL remaining)</span>
                <NumInput
                  step="1"
                  min="0"
                  value={settings.startE}
                  onChange={(v) => updateSetting('startE', v)}
                  fallback={0}
                />
              </label>
            </div>
          </div>
          
          <div className="panel-header">
            <h3>🔧 Hardware</h3>
          </div>
          <div className="settings-section">
            <div className="settings-group">
              <label style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px' }}>
                <input
                  type="checkbox"
                  checked={settings.triggerMode || false}
                  onChange={(e) => updateSetting('triggerMode', e.target.checked)}
                />
                <span>Trigger Mode</span>
              </label>
              <small style={{ color: '#888', fontSize: '10px', display: 'block', marginBottom: '12px' }}>
                {settings.triggerMode
                  ? 'XY move only — dispense commands handled externally (Dispense Sequence panel)'
                  : 'Using Klipper extruder G1 E moves'}
              </small>

              {!settings.triggerMode && (<>
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
              </>)}
            </div>
          </div>
          
          <div className="panel-header">
            <h3>🚀 Motion</h3>
          </div>
          <div className="settings-section">
            <div className="settings-group">
              <label>
                <span>Dispense Speed (mm/min)</span>
                <NumInput
                  step="10"
                  min="10"
                  value={settings.feedrate}
                  onChange={(v) => updateSetting('feedrate', v)}
                  fallback={100}
                  integer
                />
              </label>
              <label>
                <span>Dispense Acceleration (mm/s²)</span>
                <NumInput
                  step="50"
                  min="50"
                  value={settings.dispenseAccel}
                  onChange={(v) => updateSetting('dispenseAccel', v)}
                  fallback={500}
                  integer
                />
              </label>
              <label>
                <span>Restore Acceleration (mm/s²)</span>
                <NumInput
                  step="100"
                  min="100"
                  value={settings.restoreAccel}
                  onChange={(v) => updateSetting('restoreAccel', v)}
                  fallback={3000}
                  integer
                />
              </label>
              <label>
                <span>Z Dispense (mm)</span>
                <NumInput
                  step="0.1"
                  min="0.1"
                  value={settings.zHeight}
                  onChange={(v) => updateSetting('zHeight', v)}
                  fallback={0.5}
                />
              </label>
              <label>
                <span>Z Travel (mm)</span>
                <NumInput
                  step="1"
                  min="1"
                  value={settings.zTravel}
                  onChange={(v) => updateSetting('zTravel', v)}
                  fallback={5}
                />
              </label>
            </div>
            {!settings.triggerMode && (
            <div className="settings-group">
              <label>
                <span>E Multiplier</span>
                <NumInput
                  step="0.01"
                  min="0"
                  value={settings.eMultiplier}
                  onChange={(v) => updateSetting('eMultiplier', v)}
                  fallback={1.0}
                  style={{ width: '80px' }}
                />
                <small style={{ color: '#888', fontSize: '10px' }}>1.0 = 100%, 0.1 = 10%, 0.01 = 1%</small>
              </label>
              
              <div style={{ marginTop: '16px' }}>
                <div 
                  onClick={() => setOverridesExpanded(!overridesExpanded)}
                  style={{ 
                    cursor: 'pointer', 
                    userSelect: 'none',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '6px',
                    fontWeight: '500'
                  }}
                >
                  <span>{overridesExpanded ? '▼' : '▶'}</span>
                  <span>Per-Line Overrides</span>
                </div>
                
                {overridesExpanded && (
                  <div style={{ marginTop: '8px', fontSize: '11px' }}>
                    <div style={{
                      display: 'grid',
                      gridTemplateColumns: '60px 1fr 1fr 1fr',
                      gap: '4px',
                      marginBottom: '4px',
                      fontWeight: 'bold',
                      color: '#888'
                    }}>
                      <div>Line</div>
                      <div>Delay (T50)</div>
                      <div>Volume (E100)</div>
                      <div>Speed (F9000)</div>
                    </div>
                    {Array.from({ length: settings.numLines }, (_, i) => {
                      const override = (settings.perLineOverrides || [])[i] || {
                        delay: 50,
                        volume: 100,
                        speed: 9000
                      };
                      return (
                        <div key={i} style={{
                          display: 'grid',
                          gridTemplateColumns: '60px 1fr 1fr 1fr',
                          gap: '4px',
                          marginBottom: '2px'
                        }}>
                          <div style={{ paddingTop: '4px' }}>Line {i + 1}</div>
                          <NumInput
                            step="1"
                            min="0"
                            value={override.delay}
                            onChange={(v) => updateLineOverride(i, 'delay', v)}
                            fallback={50}
                            style={{ width: '100%', padding: '2px 4px', fontSize: '11px' }}
                          />
                          <NumInput
                            step="1"
                            min="1"
                            value={override.volume}
                            onChange={(v) => updateLineOverride(i, 'volume', v)}
                            fallback={100}
                            style={{ width: '100%', padding: '2px 4px', fontSize: '11px' }}
                          />
                          <NumInput
                            step="100"
                            min="100"
                            value={override.speed}
                            onChange={(v) => updateLineOverride(i, 'speed', v)}
                            fallback={9000}
                            style={{ width: '100%', padding: '2px 4px', fontSize: '11px' }}
                            style={{ width: '100%', padding: '2px 4px', fontSize: '11px' }}
                          />
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>
            </div>
            )}
          </div>
          
          <div className="panel-header">
            <h3>⏱️ Timing Calculator</h3>
          </div>
          <div className="settings-section">
            <div style={{ fontSize: '12px', lineHeight: '1.8' }}>
              {(() => {
                const travelTime = (settings.lineLength || 70) * 60 / (settings.feedrate || 300);
                const travelFeedrate = settings.travelFeedrate || 3000;
                const spacing = settings.lineSpacing || 1;
                const hopTime = settings.numLines > 1 ? (spacing * 60 / travelFeedrate) : 0;

                const perLineTotal = travelTime + hopTime;
                const totalAllLines = perLineTotal * (settings.numLines || 1) - hopTime;

                return (
                  <>
                    <div style={{ color: '#2196F3' }}>
                      <strong>Travel:</strong> {settings.lineLength}mm @ {settings.feedrate}mm/min = <strong>{travelTime.toFixed(3)}s</strong>
                    </div>
                    {settings.numLines > 1 && (
                      <div style={{ color: '#FF9800' }}>
                        <strong>Hop:</strong> {spacing}mm @ {travelFeedrate}mm/min = <strong>{(hopTime * 1000).toFixed(1)}ms</strong>
                      </div>
                    )}
                    <div style={{ marginTop: '6px', padding: '6px 8px', background: 'rgba(102,126,234,0.1)', borderRadius: '4px', fontWeight: 'bold' }}>
                      Per line: {perLineTotal.toFixed(3)}s &nbsp;|&nbsp; Total ({settings.numLines} lines): {totalAllLines.toFixed(3)}s
                    </div>
                  </>
                );
              })()}
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
                    <span>Before Line Set (once before all lines)</span>
                    <textarea
                      rows="2"
                      placeholder="G4 P100  ; Pause before line set"
                      value={settings.beforeLineSetGcode}
                      onChange={(e) => updateSetting('beforeLineSetGcode', e.target.value)}
                      style={{ fontFamily: 'monospace', fontSize: '11px', width: '100%' }}
                    />
                  </label>
                  <label>
                    <span>After Line Set (once after all lines)</span>
                    <textarea
                      rows="2"
                      placeholder="G4 P100  ; Pause after line set"
                      value={settings.afterLineSetGcode}
                      onChange={(e) => updateSetting('afterLineSetGcode', e.target.value)}
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
          <div className="stl-viewer" ref={viewerRef} style={{ position: 'relative' }}>
            {hoverCoords && (
              <div style={{
                position: 'absolute', top: 8, left: 8,
                background: 'rgba(0,0,0,0.7)', color: '#0f0', padding: '4px 8px',
                borderRadius: 4, fontSize: 12, fontFamily: 'monospace', pointerEvents: 'none',
              }}>
                X: {hoverCoords.x.toFixed(1)} &nbsp; Y: {hoverCoords.y.toFixed(1)}
              </div>
            )}
          </div>
          <div className="viewer-info">
            <span>🟢 Start position</span>
            <span>🔵 Dispense lines</span>
            <span>🟠 Travel moves</span>
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
