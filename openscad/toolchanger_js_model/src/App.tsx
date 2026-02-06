import { useState, useEffect, useCallback, useRef, Suspense } from 'react';
import { Canvas } from '@react-three/fiber';
import { OrbitControls, Grid, PerspectiveCamera } from '@react-three/drei';
import * as THREE from 'three';
import { STLLoader } from 'three-stdlib';

interface ModelInfo {
  name: string;
  category: string;
  visible: boolean;
  color: string;
}

interface CategoryInfo {
  name: string;
  label: string;
  color: string;
}

const CATEGORIES: CategoryInfo[] = [
  { name: 'X_AXIS', label: 'X Axis', color: '#E91E63' },
  { name: 'Y_AXIS', label: 'Y Axis', color: '#9C27B0' },
  { name: 'XY_JOINTS', label: 'XY Joints', color: '#673AB7' },
  { name: 'EXTRUSIONS_HFSB5', label: 'Extrusions HFSB5', color: '#3F51B5' },
  { name: 'EXTRUSIONS_HGSB5', label: 'Extrusions HGSB5', color: '#2196F3' },
  { name: 'FRAME_CORNERS', label: 'Frame Corners', color: '#00BCD4' },
  { name: 'PANELS_SKIRTS', label: 'Panels & Skirts', color: '#009688' },
  { name: 'MOTOR_MOUNT_A', label: 'Motor Mount A', color: '#4CAF50' },
  { name: 'MOTOR_MOUNT_B', label: 'Motor Mount B', color: '#8BC34A' },
  { name: 'Z_AXIS', label: 'Z Axis', color: '#CDDC39' },
  { name: 'Z_CARRIAGES', label: 'Z Carriages', color: '#FFEB3B' },
  { name: 'ENDSTOPS', label: 'Endstops', color: '#FFC107' },
  { name: 'BELT_TENSIONERS', label: 'Belt Tensioners', color: '#FF9800' },
  { name: 'TOOLHEAD_CARRIAGE', label: 'Toolhead Carriage', color: '#FF5722' },
  { name: 'BED_ASSEMBLY', label: 'Bed Assembly', color: '#795548' },
  { name: 'LIQUID_DISPENSER', label: 'Liquid Dispenser', color: '#607D8B' },
  { name: 'LUERLOCK_NOZZLE', label: 'Luerlock Nozzle', color: '#F44336' },
  { name: 'PEEK_NOZZLE', label: 'PEEK Nozzle', color: '#9E9E9E' },
  { name: 'TIP_CASE', label: 'Tip Case', color: '#E0E0E0' },
  { name: 'CAMERA_TOOL', label: 'Camera Tool', color: '#00E676' },
  { name: 'EXTRUDER_TOOL0', label: 'Extruder Tool 0', color: '#651FFF' },
  { name: 'EXTRUDER_TOOL1', label: 'Extruder Tool 1', color: '#FF1744' },
  { name: 'SYRINGE_PUMP', label: 'Syringe Pump', color: '#2979FF' },
  { name: 'WASHSTATION', label: 'Washstation', color: '#18FFFF' },
  { name: 'MICROFLUIDICS', label: 'Microfluidics', color: '#FF9100' },
  { name: 'CABLING', label: 'Cabling', color: '#536DFE' },
  { name: 'KLICKY_PROBE', label: 'Klicky Probe', color: '#FFEA00' },
];

function StlObject({ url, color, visible }: { url: string; color: string; visible: boolean }) {
  const meshRef = useRef<THREE.Mesh>(null);

  useEffect(() => {
    if (!visible || !meshRef.current) return;

    const loader = new STLLoader();
    loader.load(
      url,
      (geometry) => {
        geometry.computeVertexNormals();
        if (meshRef.current) {
          meshRef.current.geometry = geometry;
        }
      },
      undefined,
      (err) => {
        console.warn('Error loading:', url, err.message);
      }
    );
  }, [url, visible]);

  if (!visible) return null;

  return (
    <mesh ref={meshRef} castShadow receiveShadow>
      <meshStandardMaterial color={color} metalness={0.3} roughness={0.7} />
    </mesh>
  );
}

function Scene({ models }: { models: ModelInfo[] }) {
  // Force re-mount when visible count changes to clear cached geometries
  const visibleCount = models.filter(m => m.visible).length;
  const visibleModels = models.filter(m => m.visible);

  return (
    <>
      <ambientLight intensity={0.5} />
      <directionalLight position={[50, 100, 50]} intensity={0.8} castShadow />
      <directionalLight position={[-50, 50, -50]} intensity={0.3} />
      
      <group key={`scene-${visibleCount}`} position={[0, 0, 0]}>
        {visibleModels.map((m) => (
          <StlObject key={m.name} url={`/models/${m.name}`} color={m.color} visible={m.visible} />
        ))}
      </group>

      <Grid args={[400, 400]} cellSize={20} cellColor="#444" sectionSize={100} sectionColor="#666" fadeDistance={400} position={[0, 0, 0]} />
      <OrbitControls makeDefault minDistance={5} maxDistance={2000} target={[0, 100, 0]} />
    </>
  );
}

function Loading() {
  return (
    <mesh>
      <boxGeometry args={[1, 1, 1]} />
      <meshBasicMaterial color="#444" wireframe />
    </mesh>
  );
}

function Toggle({ checked, onChange, color }: { checked: boolean; onChange: (v: boolean) => void; color: string }) {
  return (
    <button
      onClick={() => onChange(!checked)}
      style={{
        width: '48px',
        height: '24px',
        borderRadius: '12px',
        border: 'none',
        background: checked ? color : '#333',
        cursor: 'pointer',
        position: 'relative',
        transition: 'background 0.2s',
      }}
    >
      <div style={{
        position: 'absolute',
        top: '2px',
        left: checked ? '26px' : '2px',
        width: '20px',
        height: '20px',
        borderRadius: '10px',
        background: '#fff',
        transition: 'left 0.2s',
      }} />
    </button>
  );
}

function Checkbox({ checked, onChange }: { checked: boolean; onChange: (v: boolean) => void }) {
  return (
    <button
      onClick={() => onChange(!checked)}
      style={{
        width: '16px',
        height: '16px',
        borderRadius: '3px',
        border: checked ? '2px solid #4CAF50' : '2px solid #555',
        background: checked ? '#4CAF50' : 'transparent',
        cursor: 'pointer',
        marginRight: '8px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: 0,
      }}
    >
      {checked && <span style={{ color: '#fff', fontSize: '10px', lineHeight: 1 }}>✓</span>}
    </button>
  );
}

export default function App() {
  const [models, setModels] = useState<ModelInfo[]>([]);
  const [expandedCats, setExpandedCats] = useState<Record<string, boolean>>(() => {
    const saved = localStorage.getItem('viewer_expanded');
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch {
        return {};
      }
    }
    return { X_AXIS: true, Y_AXIS: true, XY_JOINTS: true };
  });
  const [search, setSearch] = useState('');

  useEffect(() => {
    Promise.all([
      fetch('/models/category_mapping.json').then(r => r.json()),
      fetch('/models/list.json').then(r => r.json())
    ]).then(([mapping, allFiles]) => {
      const loaded: ModelInfo[] = [];
      
      CATEGORIES.forEach(cat => {
        const files = mapping[cat.name] || [];
        files.forEach((file: string) => {
          if (allFiles.includes(file)) {
            loaded.push({
              name: file,
              category: cat.name,
              visible: true,
              color: cat.color
            });
          }
        });
      });
      
      setModels(loaded);
    }).catch(err => {
      console.error('Error loading mappings:', err);
      setModels([]);
    });
  }, []);

  const toggleFile = useCallback((name: string) => {
    setModels(prev => prev.map(m => m.name === name ? { ...m, visible: !m.visible } : m));
  }, []);

  const toggleCategory = useCallback((cat: string, value: boolean) => {
    setModels(prev => prev.map(m => m.category === cat ? { ...m, visible: value } : m));
  }, []);

  const toggleExpanded = useCallback((cat: string) => {
    setExpandedCats(prev => ({ ...prev, [cat]: !prev[cat] }));
  }, []);

  const showAll = useCallback(() => {
    setModels(prev => prev.map(m => ({ ...m, visible: true })));
  }, []);

  const hideAll = useCallback(() => {
    setModels(prev => prev.map(m => ({ ...m, visible: false })));
  }, []);

  // Group models by category
  const modelsByCategory = CATEGORIES.map(cat => ({
    ...cat,
    models: models.filter(m => m.category === cat.name)
  })).filter(c => c.models.length > 0);

  // Filter by search
  const filteredCategories = search 
    ? modelsByCategory.map(cat => ({
        ...cat,
        models: cat.models.filter(m => 
          m.name.toLowerCase().includes(search.toLowerCase())
        )
      })).filter(c => c.models.length > 0)
    : modelsByCategory;

  const visibleCount = models.filter(m => m.visible).length;

  return (
    <div style={{ width: '100vw', height: '100vh', display: 'flex', background: '#1a1a1a', fontFamily: 'system-ui, -apple-system, sans-serif' }}>
      {/* Sidebar */}
      <div style={{ width: '360px', background: '#252525', display: 'flex', flexDirection: 'column', borderRight: '1px solid #333' }}>
        <div style={{ padding: '16px', borderBottom: '1px solid #333' }}>
          <h1 style={{ fontSize: '16px', color: '#fff', margin: 0 }}>Rister Toolchanger</h1>
          <p style={{ fontSize: '11px', color: '#888', marginTop: '4px' }}>{visibleCount} / {models.length} visible</p>
        </div>

        <input
          type="text"
          placeholder="Search files..."
          value={search}
          onChange={e => setSearch(e.target.value)}
          style={{ margin: '12px', padding: '10px', background: '#333', border: 'none', borderRadius: '4px', color: '#fff', width: 'calc(100% - 24px)' }}
        />

        <div style={{ display: 'flex', gap: '8px', padding: '0 12px 12px' }}>
          <button onClick={showAll} style={{ flex: 1, padding: '8px', background: '#4CAF50', color: '#fff', border: 'none', borderRadius: '4px', cursor: 'pointer', fontSize: '11px' }}>Show All</button>
          <button onClick={hideAll} style={{ flex: 1, padding: '8px', background: '#f44336', color: '#fff', border: 'none', borderRadius: '4px', cursor: 'pointer', fontSize: '11px' }}>Hide All</button>
        </div>

        <div style={{ flex: 1, overflowY: 'auto', padding: '0 12px 12px' }}>
          {filteredCategories.map(cat => (
            <div key={cat.name} style={{ marginBottom: '8px' }}>
              <div
                onClick={() => toggleExpanded(cat.name)}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  padding: '10px',
                  cursor: 'pointer',
                  borderRadius: '4px',
                  background: 'rgba(255,255,255,0.03)',
                }}
              >
                <span style={{ 
                  color: '#888', 
                  fontSize: '10px', 
                  marginRight: '6px',
                  transform: expandedCats[cat.name] ? 'rotate(90deg)' : 'rotate(0deg)',
                  transition: 'transform 0.2s',
                }}>▶</span>
                <Toggle 
                  checked={cat.models.some(m => m.visible)} 
                  onChange={(v) => toggleCategory(cat.name, v)}
                  color={cat.color}
                />
                <span style={{ flex: 1, fontSize: '12px', color: '#ddd', marginLeft: '10px' }}>
                  {cat.label}
                </span>
                <span style={{ fontSize: '10px', color: '#666' }}>{cat.models.filter(m => m.visible).length}/{cat.models.length}</span>
              </div>
              
              {expandedCats[cat.name] && cat.models.length > 0 && (
                <div style={{ paddingLeft: '28px', marginTop: '4px', maxHeight: '200px', overflowY: 'auto' }}>
                  {cat.models.map(m => (
                    <div
                      key={m.name}
                      onClick={() => toggleFile(m.name)}
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        padding: '6px 8px',
                        cursor: 'pointer',
                        borderRadius: '3px',
                        marginBottom: '2px',
                        background: m.visible ? 'rgba(255,255,255,0.03)' : 'transparent',
                      }}
                    >
                      <Checkbox checked={m.visible} onChange={() => {}} />
                      <span style={{ 
                        fontSize: '11px', 
                        color: m.visible ? '#ddd' : '#555',
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                        whiteSpace: 'nowrap',
                      }}>
                        {m.name.replace('.stl', '')}
                      </span>
                    </div>
                  ))}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Canvas */}
      <div style={{ flex: 1, position: 'relative' }}>
        <Canvas shadows>
          <PerspectiveCamera makeDefault position={[80, 80, 80]} fov={50} />
          <Suspense fallback={<Loading />}>
            <Scene models={models} />
          </Suspense>
        </Canvas>

        <div style={{ position: 'absolute', bottom: '16px', left: '16px', background: 'rgba(0,0,0,0.7)', padding: '12px 16px', borderRadius: '8px', fontSize: '12px', color: '#aaa' }}>
          <strong style={{ color: '#fff' }}>Controls</strong>
          <div>Left drag: rotate</div>
          <div>Right drag: pan</div>
          <div>Scroll: zoom</div>
        </div>
      </div>
    </div>
  );
}
