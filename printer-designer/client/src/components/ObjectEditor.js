import React, { useState, useEffect, useRef, useCallback } from 'react';

function ObjectEditor({ design, onSave, isPublisher = true }) {
  const [objects, setObjects] = useState(design.objects || []);
  const [printerArea, setPrinterArea] = useState(design.printerArea || { width: 380, height: 480 });
  const [selectedIndex, setSelectedIndex] = useState(-1);
  const canvasRef = useRef(null);
  const [mouseCoords, setMouseCoords] = useState(null);
  const [hoveredObject, setHoveredObject] = useState(null);
  const [designName, setDesignName] = useState(design.name || '');
  const [designDescription, setDesignDescription] = useState(design.description || '');

  // Sync with design prop
  useEffect(() => {
    setObjects(design.objects || []);
    setPrinterArea(design.printerArea || { width: 380, height: 480 });
    setDesignName(design.name || '');
    setDesignDescription(design.description || '');
  }, [design]);

  const saveDesignMeta = () => {
    onSave({
      name: designName,
      description: designDescription
    });
    alert('Design info saved!');
  };

  // Draw canvas
  const drawCanvas = useCallback(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    const container = canvas.parentElement;
    const containerWidth = container.clientWidth - 4;
    const canvasWidth = Math.min(containerWidth, 1200);
    const canvasHeight = Math.min(canvasWidth * 0.6, 600);

    canvas.width = canvasWidth;
    canvas.height = canvasHeight;

    const scale = Math.min(canvasWidth / printerArea.width, canvasHeight / printerArea.height);

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // Draw printer area
    ctx.fillStyle = '#ffffff';
    ctx.fillRect(0, 0, printerArea.width * scale, printerArea.height * scale);
    ctx.strokeStyle = '#333';
    ctx.lineWidth = 2;
    ctx.strokeRect(0, 0, printerArea.width * scale, printerArea.height * scale);

    // Draw grid
    ctx.strokeStyle = '#e0e0e0';
    ctx.lineWidth = 0.5;
    for (let i = 0; i <= printerArea.width; i += 20) {
      ctx.beginPath();
      ctx.moveTo(i * scale, 0);
      ctx.lineTo(i * scale, printerArea.height * scale);
      ctx.stroke();
    }
    for (let i = 0; i <= printerArea.height; i += 20) {
      ctx.beginPath();
      ctx.moveTo(0, i * scale);
      ctx.lineTo(printerArea.width * scale, i * scale);
      ctx.stroke();
    }

    // Draw objects
    objects.forEach((obj, index) => {
      if (obj.status === 'off') return;

      const x = (printerArea.width - parseFloat(obj.posx) - parseFloat(obj.X)) * scale;
      const y = parseFloat(obj.posy) * scale;
      const width = parseFloat(obj.X) * scale;
      const height = parseFloat(obj.Y) * scale;

      const [r, g, b] = (obj.color || '99,87,101').split(',').map(c => parseInt(c.trim()));

      ctx.fillStyle = `rgba(${r}, ${g}, ${b}, 0.7)`;
      ctx.strokeStyle = index === selectedIndex ? '#ffff00' : '#000';
      ctx.lineWidth = index === selectedIndex ? 3 : 1;

      ctx.fillRect(x, y, width, height);
      ctx.strokeRect(x, y, width, height);

      // Draw arrays
      drawArrays(ctx, obj, scale);
    });
  }, [objects, printerArea, selectedIndex]);

  const drawArrays = (ctx, obj, scale) => {
    const rows = parseInt(obj.arrayrow) || 1;
    const cols = parseInt(obj.arraycolumn) || 1;
    const arraySizeX = parseFloat(obj.shapex || 7) * scale;
    const arraySizeY = parseFloat(obj.shapey || 7) * scale;

    ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
    ctx.strokeStyle = '#000';
    ctx.lineWidth = 0.5;

    for (let row = 0; row < rows; row++) {
      for (let col = 0; col < cols; col++) {
        const arrayX = parseFloat(obj.posx) + parseFloat(obj.marginx || 0) + col * parseFloat(obj.arraycolumnsp || 9);
        const arrayY = parseFloat(obj.posy) + parseFloat(obj.marginy || 0) + row * parseFloat(obj.arrayrowsp || 9);

        const displayX = (printerArea.width - arrayX) * scale - arraySizeX / 2;
        const displayY = arrayY * scale - arraySizeY / 2;

        if (obj.arrayshape === 'ellipse') {
          ctx.beginPath();
          ctx.ellipse(displayX + arraySizeX / 2, displayY + arraySizeY / 2,
            arraySizeX / 2, arraySizeY / 2, 0, 0, 2 * Math.PI);
          ctx.fill();
          ctx.stroke();
        } else {
          ctx.fillRect(displayX, displayY, arraySizeX, arraySizeY);
          ctx.strokeRect(displayX, displayY, arraySizeX, arraySizeY);
        }
      }
    }
  };

  useEffect(() => {
    drawCanvas();
    window.addEventListener('resize', drawCanvas);
    return () => window.removeEventListener('resize', drawCanvas);
  }, [drawCanvas]);

  const handleCanvasMouseMove = (e) => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const rect = canvas.getBoundingClientRect();
    const mouseX = e.clientX - rect.left;
    const mouseY = e.clientY - rect.top;
    const scale = Math.min(canvas.width / printerArea.width, canvas.height / printerArea.height);

    const printerX = printerArea.width - (mouseX / scale);
    const printerY = mouseY / scale;

    setMouseCoords({ x: printerX.toFixed(1), y: printerY.toFixed(1) });

    // Find object under cursor
    let foundObject = null;
    for (let i = objects.length - 1; i >= 0; i--) {
      const obj = objects[i];
      if (obj.status === 'off') continue;

      const objX = parseFloat(obj.posx);
      const objY = parseFloat(obj.posy);
      const objW = parseFloat(obj.X);
      const objH = parseFloat(obj.Y);

      // Check if printer coords are within object bounds
      if (printerX >= objX && printerX <= objX + objW &&
          printerY >= objY && printerY <= objY + objH) {
        foundObject = obj;
        break;
      }
    }
    setHoveredObject(foundObject);
  };

  const handleCanvasMouseLeave = () => {
    setMouseCoords(null);
    setHoveredObject(null);
  };

  const saveToServer = (updatedObjects, updatedPrinterArea) => {
    onSave({
      objects: updatedObjects,
      printerArea: updatedPrinterArea
    });
  };

  const updatePrinterArea = () => {
    const width = parseFloat(document.getElementById('printer-width').value);
    const height = parseFloat(document.getElementById('printer-height').value);

    if (width < 100 || height < 100) {
      alert('Dimensions must be at least 100mm');
      return;
    }

    const newArea = { width, height };
    setPrinterArea(newArea);
    saveToServer(objects, newArea);
    alert('Printer area updated!');
  };

  const createNewObject = () => {
    const newObj = {
      id: Date.now(),
      name: `object_${objects.length + 1}`,
      catalog: '',
      status: 'on',
      posx: '100',
      posy: '100',
      X: '75',
      Y: '20',
      Z: '29',
      marginx: '2',
      marginy: '10',
      shimx: '0',
      shimy: '0',
      arrayrow: '1',
      arraycolumn: '8',
      arrayrowsp: '9',
      arraycolumnsp: '9',
      shapex: '7.05',
      shapey: '7.05',
      arrayshape: 'ellipse',
      color: '99,87,101',
      ztrav: '0'
    };

    const newObjects = [...objects, newObj];
    setObjects(newObjects);
    setSelectedIndex(newObjects.length - 1);
    saveToServer(newObjects, printerArea);
  };

  const cloneObject = () => {
    if (selectedIndex === -1) {
      alert('Please select an object to clone');
      return;
    }

    const original = objects[selectedIndex];
    const cloned = {
      ...original,
      id: Date.now(),
      name: original.name + '_copy',
      posx: (parseFloat(original.posx) + 20).toString(),
      posy: (parseFloat(original.posy) + 20).toString()
    };

    const newObjects = [...objects, cloned];
    setObjects(newObjects);
    setSelectedIndex(newObjects.length - 1);
    saveToServer(newObjects, printerArea);
  };

  const deleteObject = () => {
    if (selectedIndex === -1) {
      alert('Please select an object to delete');
      return;
    }

    if (!window.confirm(`Delete "${objects[selectedIndex].name}"?`)) return;

    const newObjects = objects.filter((_, i) => i !== selectedIndex);
    setObjects(newObjects);
    setSelectedIndex(-1);
    saveToServer(newObjects, printerArea);
  };

  const updateObject = (field, value) => {
    if (selectedIndex === -1) return;

    const newObjects = [...objects];
    newObjects[selectedIndex] = {
      ...newObjects[selectedIndex],
      [field]: value
    };
    setObjects(newObjects);
    saveToServer(newObjects, printerArea);
  };

  const selectedObj = selectedIndex >= 0 ? objects[selectedIndex] : null;

  const hexToRgb = (hex) => {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
      r: parseInt(result[1], 16),
      g: parseInt(result[2], 16),
      b: parseInt(result[3], 16)
    } : null;
  };

  const rgbToHex = (rgb) => {
    const [r, g, b] = rgb.split(',').map(c => parseInt(c.trim()));
    return '#' + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
  };

  return (
    <div>
      {/* Design Info */}
      <div className="section">
        <h3 className="section-title">📝 Design Info</h3>
        <div className="form-row cols-2">
          <div>
            <label>Design Name:</label>
            <input
              type="text"
              value={designName}
              onChange={(e) => setDesignName(e.target.value)}
              placeholder="My Design"
              disabled={!isPublisher}
            />
          </div>
          <div>
            <label>Description:</label>
            <input
              type="text"
              value={designDescription}
              onChange={(e) => setDesignDescription(e.target.value)}
              placeholder="Optional description..."
              disabled={!isPublisher}
            />
          </div>
        </div>
        {isPublisher && (
          <button className="btn" onClick={saveDesignMeta}>💾 Save Design Info</button>
        )}
      </div>

      {/* Printer Area Settings */}
      <div className="section">
        <h3 className="section-title">⚙️ Printer Area Settings</h3>
        <div className="form-row cols-2">
          <div>
            <label>Width (mm):</label>
            <input type="number" id="printer-width" defaultValue={printerArea.width} min="100" disabled={!isPublisher} />
          </div>
          <div>
            <label>Height (mm):</label>
            <input type="number" id="printer-height" defaultValue={printerArea.height} min="100" disabled={!isPublisher} />
          </div>
        </div>
        {isPublisher && (
          <button className="btn btn-warning" onClick={updatePrinterArea}>Update Printer Area</button>
        )}
      </div>

      {/* Canvas Visualization */}
      <div className="section">
        <h3 className="section-title">
          📐 Printer Bed ({printerArea.width}×{printerArea.height}mm)
          {mouseCoords && (
            <span style={{ marginLeft: '15px', fontSize: '14px', color: '#667eea', fontWeight: 'normal' }}>
              X: {mouseCoords.x}mm, Y: {mouseCoords.y}mm
            </span>
          )}
          {hoveredObject && (
            <span style={{ 
              marginLeft: '15px', 
              fontSize: '14px', 
              color: '#48bb78', 
              fontWeight: '600',
              background: 'rgba(72, 187, 120, 0.1)',
              padding: '2px 8px',
              borderRadius: '4px'
            }}>
              📦 {hoveredObject.name}
              <span style={{ fontWeight: 'normal', marginLeft: '8px', color: '#888' }}>
                ({hoveredObject.arrayrow}×{hoveredObject.arraycolumn} array, Z:{hoveredObject.Z}mm)
              </span>
            </span>
          )}
        </h3>
        <div className="canvas-wrapper">
          <canvas
            ref={canvasRef}
            onMouseMove={handleCanvasMouseMove}
            onMouseLeave={handleCanvasMouseLeave}
            style={{ cursor: 'crosshair' }}
          />
        </div>
      </div>

      {/* Object Management */}
      <div className="section">
        <h3 className="section-title">📦 Object Management</h3>
        {isPublisher && (
          <div className="btn-group">
            <button className="btn" onClick={createNewObject}>➕ New Object</button>
            <button className="btn btn-secondary" onClick={cloneObject}>📋 Clone</button>
            <button className="btn btn-danger" onClick={deleteObject}>🗑️ Delete</button>
          </div>
        )}

        <div className="list-container">
          {objects.length === 0 ? (
            <div style={{ padding: '20px', textAlign: 'center', color: '#999' }}>
              No objects created yet
            </div>
          ) : (
            objects.map((obj, index) => (
              <div
                key={obj.id || index}
                className={`list-item ${index === selectedIndex ? 'selected' : ''}`}
                onClick={() => setSelectedIndex(index)}
              >
                <div className="list-item-title">
                  {obj.status === 'on' ? '✅' : '❌'} {obj.name}
                </div>
                <div className="list-item-details">
                  Pos: ({obj.posx}, {obj.posy}) | Size: {obj.X}×{obj.Y} | Arrays: {obj.arrayrow}×{obj.arraycolumn}
                </div>
              </div>
            ))
          )}
        </div>
      </div>

      {/* Object Editor Form */}
      {selectedObj && (
        <div className="section">
          <h3 className="section-title">✏️ Edit: {selectedObj.name}</h3>

          <div className="form-row cols-2">
            <div>
              <label>Name:</label>
              <input
                type="text"
                value={selectedObj.name}
                onChange={(e) => updateObject('name', e.target.value)}
              />
            </div>
            <div>
              <label>Status:</label>
              <select
                value={selectedObj.status}
                onChange={(e) => updateObject('status', e.target.value)}
              >
                <option value="on">Active</option>
                <option value="off">Inactive</option>
              </select>
            </div>
          </div>

          <div className="form-row cols-3">
            <div>
              <label>Position X:</label>
              <input
                type="number"
                value={selectedObj.posx}
                onChange={(e) => updateObject('posx', e.target.value)}
                step="0.1"
              />
            </div>
            <div>
              <label>Position Y:</label>
              <input
                type="number"
                value={selectedObj.posy}
                onChange={(e) => updateObject('posy', e.target.value)}
                step="0.1"
              />
            </div>
            <div>
              <label>Z Height:</label>
              <input
                type="number"
                value={selectedObj.Z}
                onChange={(e) => updateObject('Z', e.target.value)}
                step="0.1"
              />
            </div>
          </div>

          <div className="form-row cols-2">
            <div>
              <label>Object Size X (mm):</label>
              <input
                type="number"
                value={selectedObj.X}
                onChange={(e) => updateObject('X', e.target.value)}
                step="0.1"
              />
            </div>
            <div>
              <label>Object Size Y (mm):</label>
              <input
                type="number"
                value={selectedObj.Y}
                onChange={(e) => updateObject('Y', e.target.value)}
                step="0.1"
              />
            </div>
          </div>

          <h4 style={{ color: '#667eea', margin: '20px 0 10px 0' }}>Array Configuration</h4>

          <div className="form-row cols-2">
            <div>
              <label>Array Rows:</label>
              <input
                type="number"
                value={selectedObj.arrayrow}
                onChange={(e) => updateObject('arrayrow', e.target.value)}
                min="1"
              />
            </div>
            <div>
              <label>Array Columns:</label>
              <input
                type="number"
                value={selectedObj.arraycolumn}
                onChange={(e) => updateObject('arraycolumn', e.target.value)}
                min="1"
              />
            </div>
          </div>

          <div className="form-row cols-2">
            <div>
              <label>Row Spacing (mm):</label>
              <input
                type="number"
                value={selectedObj.arrayrowsp}
                onChange={(e) => updateObject('arrayrowsp', e.target.value)}
                step="0.1"
              />
            </div>
            <div>
              <label>Column Spacing (mm):</label>
              <input
                type="number"
                value={selectedObj.arraycolumnsp}
                onChange={(e) => updateObject('arraycolumnsp', e.target.value)}
                step="0.1"
              />
            </div>
          </div>

          <div className="form-row cols-4">
            <div>
              <label>Margin X:</label>
              <input
                type="number"
                value={selectedObj.marginx}
                onChange={(e) => updateObject('marginx', e.target.value)}
                step="0.1"
              />
            </div>
            <div>
              <label>Margin Y:</label>
              <input
                type="number"
                value={selectedObj.marginy}
                onChange={(e) => updateObject('marginy', e.target.value)}
                step="0.1"
              />
            </div>
            <div>
              <label>Array Size X:</label>
              <input
                type="number"
                value={selectedObj.shapex}
                onChange={(e) => updateObject('shapex', e.target.value)}
                step="0.01"
              />
            </div>
            <div>
              <label>Array Size Y:</label>
              <input
                type="number"
                value={selectedObj.shapey}
                onChange={(e) => updateObject('shapey', e.target.value)}
                step="0.01"
              />
            </div>
          </div>

          <div className="form-row cols-2">
            <div>
              <label>Array Shape:</label>
              <select
                value={selectedObj.arrayshape}
                onChange={(e) => updateObject('arrayshape', e.target.value)}
              >
                <option value="ellipse">Ellipse (Round)</option>
                <option value="square">Square</option>
              </select>
            </div>
            <div>
              <label>Color:</label>
              <input
                type="color"
                value={rgbToHex(selectedObj.color || '99,87,101')}
                onChange={(e) => {
                  const rgb = hexToRgb(e.target.value);
                  if (rgb) updateObject('color', `${rgb.r},${rgb.g},${rgb.b}`);
                }}
                style={{ height: '38px' }}
              />
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default ObjectEditor;
