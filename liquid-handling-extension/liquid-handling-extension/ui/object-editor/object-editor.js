export class ObjectEditor {
  constructor(storage, api) {
    this.storage = storage;
    this.api = api;
    this.objects = [];
    this.selectedIndex = -1;
    this.printerArea = { width: 380, height: 480 };
    this.currentObjectId = 0;
  }

  async initialize() {
    const config = this.storage.getAll();
    this.objects = config.objects || [];
    this.printerArea = config.printerArea || { width: 380, height: 480 };
    
    if (this.objects.length > 0) {
      this.currentObjectId = Math.max(...this.objects.map(o => o.id || 0)) + 1;
    }

    this.render();
    this.attachEventListeners();
    
    // Add window resize listener to redraw canvas
    window.addEventListener('resize', () => {
      this.drawCanvas();
    });
  }

  render() {
    const container = document.getElementById('object-editor-content');
    container.innerHTML = `
      <!-- Printer Area Settings -->
      <div class="section">
        <h3 class="section-title">⚙️ Printer Area Settings</h3>
        <div class="form-row cols-2">
          <div>
            <label>Width (mm):</label>
            <input type="number" id="printer-width" value="${this.printerArea.width}" step="1" min="100">
          </div>
          <div>
            <label>Height (mm):</label>
            <input type="number" id="printer-height" value="${this.printerArea.height}" step="1" min="100">
          </div>
        </div>
        <button id="update-printer-area" class="btn btn-warning">Update Printer Area</button>
      </div>

      <!-- Canvas Visualization -->
      <div class="section">
        <h3 class="section-title">📐 Printer Bed (<span id="area-display">${this.printerArea.width}x${this.printerArea.height}</span>mm)</h3>
        <div class="canvas-wrapper">
          <canvas id="printer-canvas" style="width: 100%; height: auto;"></canvas>
        </div>
        <div class="alert alert-info">
          Visual representation - use position fields below to move objects
        </div>
      </div>

      <!-- Object Management -->
      <div class="section">
        <h3 class="section-title">📦 Object Management</h3>
        <div class="btn-group">
          <button id="new-object" class="btn">➕ New Object</button>
          <button id="clone-object" class="btn btn-secondary">📋 Clone</button>
          <button id="delete-object" class="btn btn-danger">🗑️ Delete</button>
        </div>
        
        <div class="list-container" id="object-list">
          ${this.renderObjectList()}
        </div>
      </div>

      <!-- Object Editor -->
      <div class="section">
        <h3 class="section-title">✏️ Object Properties</h3>
        <div id="edit-status" class="alert alert-info">
          Click "New Object" to create or select an object from the list above
        </div>
        
        <div id="object-form">
          ${this.renderObjectForm()}
        </div>
      </div>

      <!-- Coordinates Output -->
      <div class="section">
        <h3 class="section-title">📋 Object Coordinates</h3>
        <textarea id="coordinates-output" readonly style="height: 150px; font-family: monospace; font-size: 11px;">${this.generateCoordinates()}</textarea>
      </div>
    `;

    this.drawCanvas();
  }

  renderObjectList() {
    if (this.objects.length === 0) {
      return '<div style="padding: 20px; text-align: center; color: #999;">No objects created yet</div>';
    }

    return this.objects.map((obj, index) => `
      <div class="list-item ${index === this.selectedIndex ? 'selected' : ''}" data-index="${index}">
        <div class="list-item-title">
          ${obj.status === 'on' ? '✅' : '❌'} ${obj.name}
        </div>
        <div class="list-item-details">
          Pos: (${obj.posx}, ${obj.posy}) | Size: ${obj.X}×${obj.Y} | Arrays: ${obj.arrayrow}×${obj.arraycolumn}
        </div>
      </div>
    `).join('');
  }

  renderObjectForm() {
    if (this.selectedIndex === -1) {
      return '';
    }

    const obj = this.objects[this.selectedIndex];
    
    return `
      <div class="form-row cols-2">
        <div>
          <label>Name:</label>
          <input type="text" id="obj-name" value="${obj.name}">
        </div>
        <div>
          <label>Catalog:</label>
          <input type="text" id="obj-catalog" value="${obj.catalog || ''}">
        </div>
      </div>

      <div style="margin-bottom: 15px;">
        <label>Status:</label>
        <label style="display: inline; margin-right: 15px;">
          <input type="radio" name="obj-status" value="on" ${obj.status === 'on' ? 'checked' : ''}> Active
        </label>
        <label style="display: inline;">
          <input type="radio" name="obj-status" value="off" ${obj.status === 'off' ? 'checked' : ''}> Inactive
        </label>
      </div>

      <div class="form-row cols-2">
        <div>
          <label>Object Size X (mm):</label>
          <input type="number" id="obj-X" value="${obj.X}" step="0.1">
        </div>
        <div>
          <label>Object Size Y (mm):</label>
          <input type="number" id="obj-Y" value="${obj.Y}" step="0.1">
        </div>
      </div>

      <div class="form-row cols-2">
        <div>
          <label>Position X:</label>
          <input type="number" id="obj-posx" value="${obj.posx}" step="0.1">
        </div>
        <div>
          <label>Position Y:</label>
          <input type="number" id="obj-posy" value="${obj.posy}" step="0.1">
        </div>
      </div>
      
      <div style="margin-bottom: 15px;">
        <label>Position Z (bed height, mm):</label>
        <input type="number" id="obj-Z" value="${obj.Z}" step="0.1">
      </div>

      <h4 style="margin: 20px 0 10px 0; color: #667eea;">Array Configuration</h4>

      <div class="form-row cols-2">
        <div>
          <label>Array Rows:</label>
          <input type="number" id="obj-arrayrow" value="${obj.arrayrow}" min="1">
        </div>
        <div>
          <label>Array Columns:</label>
          <input type="number" id="obj-arraycolumn" value="${obj.arraycolumn}" min="1">
        </div>
      </div>

      <div class="form-row cols-2">
        <div>
          <label>Row Spacing (mm):</label>
          <input type="number" id="obj-arrayrowsp" value="${obj.arrayrowsp}" step="0.1">
        </div>
        <div>
          <label>Column Spacing (mm):</label>
          <input type="number" id="obj-arraycolumnsp" value="${obj.arraycolumnsp}" step="0.1">
        </div>
      </div>

      <div class="form-row cols-4">
        <div>
          <label>Margin X:</label>
          <input type="number" id="obj-marginx" value="${obj.marginx}" step="0.1">
        </div>
        <div>
          <label>Margin Y:</label>
          <input type="number" id="obj-marginy" value="${obj.marginy}" step="0.1">
        </div>
        <div>
          <label>Shim X:</label>
          <input type="number" id="obj-shimx" value="${obj.shimx}" step="0.1">
        </div>
        <div>
          <label>Shim Y:</label>
          <input type="number" id="obj-shimy" value="${obj.shimy}" step="0.1">
        </div>
      </div>

      <div style="margin-bottom: 15px;">
        <label>Array Shape:</label>
        <label style="display: inline; margin-right: 15px;">
          <input type="radio" name="array-shape" value="ellipse" ${obj.arrayshape === 'ellipse' ? 'checked' : ''}> Ellipse (Round)
        </label>
        <label style="display: inline;">
          <input type="radio" name="array-shape" value="square" ${obj.arrayshape === 'square' ? 'checked' : ''}> Square
        </label>
      </div>

      <div class="form-row cols-3">
        <div>
          <label>Array Size X (mm):</label>
          <input type="number" id="obj-shapex" value="${obj.shapex}" step="0.01">
        </div>
        <div>
          <label>Array Size Y (mm):</label>
          <input type="number" id="obj-shapey" value="${obj.shapey}" step="0.01">
        </div>
        <div>
          <label>Z Travel (mm):</label>
          <input type="number" id="obj-ztrav" value="${obj.ztrav}" step="0.1">
        </div>
      </div>

      <div style="margin-bottom: 15px;">
        <label>Color:</label>
        <div style="display: flex; gap: 10px; align-items: center;">
          <input type="color" id="obj-color-picker" value="${this.rgbToHex(obj.color)}" 
                 style="width: 50px; height: 35px; cursor: pointer;">
          <input type="text" id="obj-color" value="${obj.color}" readonly 
                 style="flex: 1; background: #f9f9f9;">
        </div>
      </div>

      <div class="btn-group">
        <button id="save-object" class="btn">💾 Save Changes</button>
        <button id="cancel-edit" class="btn btn-gray">❌ Cancel</button>
      </div>
    `;
  }

  attachEventListeners() {
    const container = document.getElementById('object-editor-content');

    // Printer area update
    container.querySelector('#update-printer-area')?.addEventListener('click', () => {
      this.updatePrinterArea();
    });

    // Object management
    container.querySelector('#new-object')?.addEventListener('click', () => {
      this.createNewObject();
    });

    container.querySelector('#clone-object')?.addEventListener('click', () => {
      this.cloneObject();
    });

    container.querySelector('#delete-object')?.addEventListener('click', () => {
      this.deleteObject();
    });

    // Object list clicks
    container.querySelectorAll('.list-item').forEach(item => {
      item.addEventListener('click', () => {
        const index = parseInt(item.dataset.index);
        this.selectObject(index);
      });
    });

    // Object form
    container.querySelector('#save-object')?.addEventListener('click', () => {
      this.saveObject();
    });

    container.querySelector('#cancel-edit')?.addEventListener('click', () => {
      this.render();
    });

    // Color picker
    container.querySelector('#obj-color-picker')?.addEventListener('change', (e) => {
      const rgb = this.hexToRgb(e.target.value);
      if (rgb) {
        document.getElementById('obj-color').value = `${rgb.r},${rgb.g},${rgb.b}`;
      }
    });
    
    // Auto-save setup
    this.setupPrinterAreaAutoSave();
    this.setupObjectAutoSave();
    
    // Canvas hover tooltips
    this.setupCanvasTooltips();
  }
  
  // Auto-save object fields on change
  setupObjectAutoSave() {
    if (this.selectedIndex === -1) return;
    
    const container = document.getElementById('object-editor-content');
    const fields = [
      'obj-name', 'obj-catalog', 'obj-X', 'obj-Y', 'obj-Z',
      'obj-posx', 'obj-posy', 'obj-arrayrow', 'obj-arraycolumn',
      'obj-arrayrowsp', 'obj-arraycolumnsp', 'obj-marginx', 'obj-marginy',
      'obj-shimx', 'obj-shimy', 'obj-shapex', 'obj-shapey', 'obj-ztrav'
    ];
    
    fields.forEach(fieldId => {
      const element = container.querySelector(`#${fieldId}`);
      element?.addEventListener('change', () => this.autoSaveObject());
    });
    
    // Radio buttons
    container.querySelectorAll('input[name="obj-status"]').forEach(radio => {
      radio.addEventListener('change', () => this.autoSaveObject());
    });
    
    container.querySelectorAll('input[name="array-shape"]').forEach(radio => {
      radio.addEventListener('change', () => this.autoSaveObject());
    });
  }
  
  async autoSaveObject() {
    if (this.selectedIndex === -1) return;

    const obj = this.objects[this.selectedIndex];
    const container = document.getElementById('object-editor-content');

    obj.name = container.querySelector('#obj-name')?.value || obj.name;
    obj.catalog = container.querySelector('#obj-catalog')?.value || obj.catalog;
    obj.status = container.querySelector('input[name="obj-status"]:checked')?.value || obj.status;
    obj.X = container.querySelector('#obj-X')?.value || obj.X;
    obj.Y = container.querySelector('#obj-Y')?.value || obj.Y;
    obj.Z = container.querySelector('#obj-Z')?.value || obj.Z;
    obj.posx = container.querySelector('#obj-posx')?.value || obj.posx;
    obj.posy = container.querySelector('#obj-posy')?.value || obj.posy;
    obj.arrayrow = container.querySelector('#obj-arrayrow')?.value || obj.arrayrow;
    obj.arraycolumn = container.querySelector('#obj-arraycolumn')?.value || obj.arraycolumn;
    obj.arrayrowsp = container.querySelector('#obj-arrayrowsp')?.value || obj.arrayrowsp;
    obj.arraycolumnsp = container.querySelector('#obj-arraycolumnsp')?.value || obj.arraycolumnsp;
    obj.marginx = container.querySelector('#obj-marginx')?.value || obj.marginx;
    obj.marginy = container.querySelector('#obj-marginy')?.value || obj.marginy;
    obj.shimx = container.querySelector('#obj-shimx')?.value || obj.shimx;
    obj.shimy = container.querySelector('#obj-shimy')?.value || obj.shimy;
    obj.shapex = container.querySelector('#obj-shapex')?.value || obj.shapex;
    obj.shapey = container.querySelector('#obj-shapey')?.value || obj.shapey;
    obj.ztrav = container.querySelector('#obj-ztrav')?.value || obj.ztrav;
    obj.arrayshape = container.querySelector('input[name="array-shape"]:checked')?.value || obj.arrayshape;
    
    const colorPicker = container.querySelector('#obj-color-picker');
    if (colorPicker) {
      const rgb = this.hexToRgb(colorPicker.value);
      if (rgb) obj.color = `${rgb.r},${rgb.g},${rgb.b}`;
    }

    await this.storage.setObjects(this.objects);
    this.drawCanvas();
    console.log('Auto-saved object:', obj.name);
  }

  createNewObject() {
    const newObj = {
      id: this.currentObjectId++,
      name: `object_${this.objects.length + 1}`,
      catalog: "",
      status: "on",
      posx: "100",
      posy: "100",
      X: "75",
      Y: "20",
      Z: "29",
      marginx: "2",
      marginy: "10",
      shimx: "0",
      shimy: "0",
      arrayrow: "1",
      arraycolumn: "8",
      arrayrowsp: "9",
      arraycolumnsp: "9",
      shape: "square",
      shapex: "7.05",
      shapey: "7.05",
      arrayshape: "ellipse",
      color: "99,87,101",
      ztrav: "0"
    };

    this.objects.push(newObj);
    this.selectedIndex = this.objects.length - 1;
    this.storage.setObjects(this.objects);
    this.render();
    this.attachEventListeners();
  }

  cloneObject() {
    if (this.selectedIndex === -1) {
      alert('Please select an object to clone');
      return;
    }

    const original = this.objects[this.selectedIndex];
    const cloned = { ...original };
    cloned.id = this.currentObjectId++;
    cloned.name = original.name + '_copy';
    cloned.posx = (parseFloat(original.posx) + 20).toString();
    cloned.posy = (parseFloat(original.posy) + 20).toString();

    this.objects.push(cloned);
    this.selectedIndex = this.objects.length - 1;
    this.storage.setObjects(this.objects);
    this.render();
    this.attachEventListeners();
  }

  deleteObject() {
    if (this.selectedIndex === -1) {
      alert('Please select an object to delete');
      return;
    }

    const objName = this.objects[this.selectedIndex].name;
    if (confirm(`Delete "${objName}"?`)) {
      this.objects.splice(this.selectedIndex, 1);
      this.selectedIndex = -1;
      this.storage.setObjects(this.objects);
      this.render();
      this.attachEventListeners();
    }
  }

  selectObject(index) {
    this.selectedIndex = index;
    this.render();
    this.attachEventListeners();

    document.getElementById('edit-status').className = 'alert alert-success';
    document.getElementById('edit-status').textContent = `Editing: ${this.objects[index].name}`;
  }

  async saveObject() {
    if (this.selectedIndex === -1) return;

    const obj = this.objects[this.selectedIndex];
    const container = document.getElementById('object-editor-content');

    obj.name = container.querySelector('#obj-name').value;
    obj.catalog = container.querySelector('#obj-catalog').value;
    obj.status = container.querySelector('input[name="obj-status"]:checked').value;
    obj.X = container.querySelector('#obj-X').value;
    obj.Y = container.querySelector('#obj-Y').value;
    obj.Z = container.querySelector('#obj-Z').value;
    obj.posx = container.querySelector('#obj-posx').value;
    obj.posy = container.querySelector('#obj-posy').value;
    obj.arrayrow = container.querySelector('#obj-arrayrow').value;
    obj.arraycolumn = container.querySelector('#obj-arraycolumn').value;
    obj.arrayrowsp = container.querySelector('#obj-arrayrowsp').value;
    obj.arraycolumnsp = container.querySelector('#obj-arraycolumnsp').value;
    obj.marginx = container.querySelector('#obj-marginx').value;
    obj.marginy = container.querySelector('#obj-marginy').value;
    obj.shimx = container.querySelector('#obj-shimx').value;
    obj.shimy = container.querySelector('#obj-shimy').value;
    obj.shapex = container.querySelector('#obj-shapex').value;
    obj.shapey = container.querySelector('#obj-shapey').value;
    obj.ztrav = container.querySelector('#obj-ztrav').value;
    obj.arrayshape = container.querySelector('input[name="array-shape"]:checked').value;
    obj.color = container.querySelector('#obj-color').value;

    await this.storage.setObjects(this.objects);
    
    // If this is the drypad object, sync grid configuration to Klipper
    if (obj.name === 'drypad') {
      await this.saveDrypadGridToKlipper(obj);
    }
    
    this.render();
    this.attachEventListeners();
    alert('Object saved successfully!');
  }

  async saveDrypadGridToKlipper(drypadObj) {
    // Extract drypad grid configuration
    const baseX = parseFloat(drypadObj.posx) + parseFloat(drypadObj.marginx);
    const baseY = parseFloat(drypadObj.posy) + parseFloat(drypadObj.marginy);
    const columns = parseInt(drypadObj.arraycolumn);
    const rows = parseInt(drypadObj.arrayrow);
    const xSpacing = parseFloat(drypadObj.arraycolumnsp);
    const ySpacing = parseFloat(drypadObj.arrayrowsp);
    const totalPositions = columns * rows;

    // Send grid configuration to Klipper
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=drypad_base_x VALUE=${baseX}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=drypad_base_y VALUE=${baseY}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=drypad_columns VALUE=${columns}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=drypad_rows VALUE=${rows}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=drypad_x_spacing VALUE=${xSpacing}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=drypad_y_spacing VALUE=${ySpacing}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=drypad_total_positions VALUE=${totalPositions}`);

    // Get active tip drypad settings from storage and save to variables
    const config = this.storage.getAll();
    const activeTipIndex = config.activeTipIndex || 0;
    const activeTip = config.tips?.[activeTipIndex];
    
    if (activeTip) {
      await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=drypad_z VALUE=${activeTip.drypad_z || 70.0}`);
      await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=drypad_servo VALUE=${activeTip.drypad_servo || 115}`);
      await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=drypad_time VALUE=${activeTip.drypad_time || 3000}`);
      await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=drypad_linear_pos VALUE=${activeTip.drypad_linear_pos || 115}`);
      await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=drypad_delay VALUE=${activeTip.drypad_delay || 2000}`);
    }

    console.log('Drypad configuration saved to Klipper:', {
      grid: { baseX, baseY, columns, rows, xSpacing, ySpacing, totalPositions },
      activeTip: activeTip ? {
        z: activeTip.drypad_z,
        servo: activeTip.drypad_servo,
        time: activeTip.drypad_time,
        linearPos: activeTip.drypad_linear_pos,
        delay: activeTip.drypad_delay
      } : 'none'
    });
  }

  updatePrinterArea() {
    const width = parseFloat(document.getElementById('printer-width').value);
    const height = parseFloat(document.getElementById('printer-height').value);

    if (width < 100 || height < 100) {
      alert('Dimensions must be at least 100mm');
      return;
    }

    this.printerArea = { width, height };
    this.storage.setPrinterArea(width, height);
    this.render();
    this.attachEventListeners();
    this.showNotification('Printer area updated!');
  }
  
  // Auto-save printer area on input change
  setupPrinterAreaAutoSave() {
    const widthInput = document.getElementById('printer-width');
    const heightInput = document.getElementById('printer-height');
    
    const autoSave = () => {
      const width = parseFloat(widthInput.value);
      const height = parseFloat(heightInput.value);
      
      if (width >= 100 && height >= 100) {
        this.printerArea = { width, height };
        this.storage.setPrinterArea(width, height);
        console.log('Auto-saved printer area:', width, 'x', height);
      }
    };
    
    widthInput?.addEventListener('change', autoSave);
    heightInput?.addEventListener('change', autoSave);
  }
  
  setupCanvasTooltips() {
    const canvas = document.getElementById('printer-canvas');
    if (!canvas) return;
    
    // Create tooltip element
    let tooltip = document.getElementById('canvas-tooltip');
    if (!tooltip) {
      tooltip = document.createElement('div');
      tooltip.id = 'canvas-tooltip';
      tooltip.style.position = 'absolute';
      tooltip.style.display = 'none';
      tooltip.style.backgroundColor = 'rgba(0, 0, 0, 0.9)';
      tooltip.style.color = '#fff';
      tooltip.style.padding = '8px 12px';
      tooltip.style.borderRadius = '6px';
      tooltip.style.fontSize = '14px';
      tooltip.style.fontWeight = 'bold';
      tooltip.style.pointerEvents = 'none';
      tooltip.style.zIndex = '10000';
      tooltip.style.boxShadow = '0 2px 8px rgba(0,0,0,0.3)';
      tooltip.style.whiteSpace = 'nowrap';
      document.body.appendChild(tooltip);
    }
    
    // Mouse move handler
    const handleMouseMove = (e) => {
      const rect = canvas.getBoundingClientRect();
      const mouseX = e.clientX - rect.left;
      const mouseY = e.clientY - rect.top;
      
      const scale = Math.min(canvas.width / this.printerArea.width, canvas.height / this.printerArea.height);
      
      // Check if mouse is over any object
      let hoveredObject = null;
      for (let i = this.objects.length - 1; i >= 0; i--) {
        const obj = this.objects[i];
        if (obj.status === 'off') continue;
        
        const x = (this.printerArea.width - parseFloat(obj.posx) - parseFloat(obj.X)) * scale;
        const y = parseFloat(obj.posy) * scale;
        const width = parseFloat(obj.X) * scale;
        const height = parseFloat(obj.Y) * scale;
        
        if (mouseX >= x && mouseX <= x + width && mouseY >= y && mouseY <= y + height) {
          hoveredObject = obj;
          break;
        }
      }
      
      if (hoveredObject) {
        // Show tooltip
        tooltip.textContent = hoveredObject.name;
        tooltip.style.display = 'block';
        tooltip.style.left = (e.clientX + 15) + 'px';
        tooltip.style.top = (e.clientY - 30) + 'px';
        canvas.style.cursor = 'pointer';
      } else {
        // Hide tooltip
        tooltip.style.display = 'none';
        canvas.style.cursor = 'default';
      }
    };
    
    // Mouse leave handler
    const handleMouseLeave = () => {
      tooltip.style.display = 'none';
      canvas.style.cursor = 'default';
    };
    
    // Remove old listeners if they exist
    canvas.removeEventListener('mousemove', handleMouseMove);
    canvas.removeEventListener('mouseleave', handleMouseLeave);
    
    // Add new listeners
    canvas.addEventListener('mousemove', handleMouseMove);
    canvas.addEventListener('mouseleave', handleMouseLeave);
  }

  drawCanvas() {
    const canvas = document.getElementById('printer-canvas');
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    
    // Get container width and calculate responsive size
    const container = canvas.parentElement;
    const containerWidth = container.clientWidth - 4; // Account for border
    const canvasWidth = Math.min(containerWidth, 1200); // Max width 1200px
    const canvasHeight = Math.min(canvasWidth * 0.6, 600); // Maintain aspect ratio
    
    // Set canvas size
    canvas.width = canvasWidth;
    canvas.height = canvasHeight;
    
    const scale = Math.min(canvasWidth / this.printerArea.width, canvasHeight / this.printerArea.height);

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // Draw printer area
    ctx.fillStyle = '#ffffff';
    ctx.fillRect(0, 0, this.printerArea.width * scale, this.printerArea.height * scale);
    ctx.strokeStyle = '#333';
    ctx.lineWidth = 2;
    ctx.strokeRect(0, 0, this.printerArea.width * scale, this.printerArea.height * scale);

    // Draw grid
    ctx.strokeStyle = '#e0e0e0';
    ctx.lineWidth = 0.5;
    for (let i = 0; i <= this.printerArea.width; i += 20) {
      ctx.beginPath();
      ctx.moveTo(i * scale, 0);
      ctx.lineTo(i * scale, this.printerArea.height * scale);
      ctx.stroke();
    }
    for (let i = 0; i <= this.printerArea.height; i += 20) {
      ctx.beginPath();
      ctx.moveTo(0, i * scale);
      ctx.lineTo(this.printerArea.width * scale, i * scale);
      ctx.stroke();
    }

    // Draw objects
    this.objects.forEach((obj, index) => {
      if (obj.status === 'off') return;

      const x = (this.printerArea.width - parseFloat(obj.posx) - parseFloat(obj.X)) * scale;
      const y = parseFloat(obj.posy) * scale;
      const width = parseFloat(obj.X) * scale;
      const height = parseFloat(obj.Y) * scale;

      const [r, g, b] = obj.color.split(',').map(c => parseInt(c.trim()));

      ctx.fillStyle = `rgba(${r}, ${g}, ${b}, 0.7)`;
      ctx.strokeStyle = index === this.selectedIndex ? '#ffff00' : '#000';
      ctx.lineWidth = index === this.selectedIndex ? 3 : 1;

      ctx.fillRect(x, y, width, height);
      ctx.strokeRect(x, y, width, height);

      // No labels - tooltips show names on hover

      // Draw arrays
      this.drawArrays(ctx, obj, x, y, scale);
    });
  }

  drawArrays(ctx, obj, objX, objY, scale) {
    const rows = parseInt(obj.arrayrow);
    const cols = parseInt(obj.arraycolumn);
    const arraySizeX = parseFloat(obj.shapex) * scale;
    const arraySizeY = parseFloat(obj.shapey) * scale;
    
    const baseX = parseFloat(obj.posx);
    const baseY = parseFloat(obj.posy);

    ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
    ctx.strokeStyle = '#000';
    ctx.lineWidth = 0.5;

    for (let row = 0; row < rows; row++) {
      for (let col = 0; col < cols; col++) {
        const arrayX = baseX + parseFloat(obj.marginx) + col * parseFloat(obj.arraycolumnsp);
        const arrayY = baseY + parseFloat(obj.marginy) + row * parseFloat(obj.arrayrowsp);

        const displayX = (this.printerArea.width - arrayX) * scale - arraySizeX / 2;
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
  }

  generateCoordinates() {
    let output = `; Object Coordinates for Lab Automation\n`;
    output += `; Total active objects: ${this.objects.filter(o => o.status === 'on').length}\n`;
    output += `; Generated: ${new Date().toISOString()}\n\n`;

    this.objects.forEach((obj, index) => {
      if (obj.status === 'on') {
        output += `; Object ${index + 1}: ${obj.name}\n`;
        output += `; Position: X${obj.posx} Y${obj.posy} Z${obj.Z}\n`;
        output += `; Size: ${obj.X} x ${obj.Y} x ${obj.Z}mm\n`;

        if (parseInt(obj.arrayrow) > 1 || parseInt(obj.arraycolumn) > 1) {
          output += `; Arrays: ${obj.arrayrow} rows x ${obj.arraycolumn} columns\n`;

          const coords = this.storage.getArrayCoordinates(obj.name);
          coords.forEach(coord => {
            output += `;   Array ${coord.name}: X${coord.x.toFixed(2)} Y${coord.y.toFixed(2)}\n`;
          });
        }
        output += '\n';
      }
    });

    return output;
  }

  hexToRgb(hex) {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
      r: parseInt(result[1], 16),
      g: parseInt(result[2], 16),
      b: parseInt(result[3], 16)
    } : null;
  }

  rgbToHex(rgb) {
    const [r, g, b] = rgb.split(',').map(c => parseInt(c.trim()));
    return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
  }
  
  showNotification(message) {
    console.log('ObjectEditor:', message);
  }
}
