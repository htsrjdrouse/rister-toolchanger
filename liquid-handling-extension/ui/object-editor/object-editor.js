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

  // --- Target Array + Blocks-of-spots model helpers ---------------------
  //
  // Every object is treated as a Target Array: a rows x columns grid of
  // targets (e.g. slides) at an origin-to-origin pitch, with the object
  // origin (posx, posy) at the lower-left (min-X, min-Y) corner of target
  // (0,0). One target is X by Y. A legacy object with no target_* fields is
  // a 1x1 target group, so its footprint and behaviour are unchanged.
  getTargetLayout(obj) {
    return {
      rows: Math.max(1, parseInt(obj.target_rows) || 1),
      cols: Math.max(1, parseInt(obj.target_cols) || 1),
      pitchX: obj.target_pitchx != null && obj.target_pitchx !== ''
        ? parseFloat(obj.target_pitchx) : (parseFloat(obj.X) || 0),
      pitchY: obj.target_pitchy != null && obj.target_pitchy !== ''
        ? parseFloat(obj.target_pitchy) : (parseFloat(obj.Y) || 0)
    };
  }

  // Blocks of spots repeated identically on every target. Offsets are in the
  // target's local frame, measured from its min-X/min-Y corner. Legacy
  // objects with no blocks[] are migrated on read into a single block built
  // from the flat Array Configuration fields (margin/array*/shape), so the
  // rendered spots are identical to before.
  getBlocks(obj) {
    // An explicit blocks array is authoritative, including an empty array
    // (a bare target such as the bed, which has no spots).
    if (Array.isArray(obj.blocks)) {
      return obj.blocks.map(b => this.normalizeBlock(b));
    }
    // Legacy object (no blocks field). Only migrate to a block if the flat
    // array fields describe a real spot pattern; otherwise it is a bare
    // target and gets zero blocks.
    const rows = Math.max(1, parseInt(obj.arrayrow) || 1);
    const cols = Math.max(1, parseInt(obj.arraycolumn) || 1);
    const sizeX = parseFloat(obj.shapex) || 0;
    const sizeY = parseFloat(obj.shapey) || 0;
    const hasPattern = rows > 1 || cols > 1 || (sizeX > 0 && sizeY > 0);
    if (!hasPattern) {
      return [];
    }
    return [this.normalizeBlock({
      name: 'block1',
      offsetx: obj.marginx,
      offsety: obj.marginy,
      rows: obj.arrayrow,
      cols: obj.arraycolumn,
      spacingx: obj.arraycolumnsp,
      spacingy: obj.arrayrowsp,
      spot_shape: obj.arrayshape,
      spot_sizex: obj.shapex,
      spot_sizey: obj.shapey
    })];
  }

  normalizeBlock(b) {
    b = b || {};
    return {
      name: b.name || 'block',
      offsetx: b.offsetx != null && b.offsetx !== '' ? parseFloat(b.offsetx) : 0,
      offsety: b.offsety != null && b.offsety !== '' ? parseFloat(b.offsety) : 0,
      rows: Math.max(1, parseInt(b.rows) || 1),
      cols: Math.max(1, parseInt(b.cols) || 1),
      spacingx: b.spacingx != null && b.spacingx !== '' ? parseFloat(b.spacingx) : 0,
      spacingy: b.spacingy != null && b.spacingy !== '' ? parseFloat(b.spacingy) : 0,
      spot_shape: b.spot_shape === 'square' ? 'square' : 'ellipse',
      spot_sizex: b.spot_sizex != null && b.spot_sizex !== '' ? parseFloat(b.spot_sizex) : 0,
      spot_sizey: b.spot_sizey != null && b.spot_sizey !== '' ? parseFloat(b.spot_sizey) : 0
    };
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
        <h3 class="section-title">📐 Printer Bed (<span id="area-display">${this.printerArea.width}x${this.printerArea.height}</span>mm)<span id="mouse-coords" style="margin-left: 15px; font-size: 14px; color: #667eea; font-weight: normal;"></span></h3>
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

    return this.objects.map((obj, index) => {
      const t = this.getTargetLayout(obj);
      const blocks = this.getBlocks(obj);
      const spotTotal = blocks.reduce((n, b) => n + b.rows * b.cols, 0);
      return `
      <div class="list-item ${index === this.selectedIndex ? 'selected' : ''}" data-index="${index}">
        <div class="list-item-title">
          ${obj.status === 'on' ? '✅' : '❌'} ${obj.name}
        </div>
        <div class="list-item-details">
          Pos: (${obj.posx}, ${obj.posy}) | Size: ${obj.X}×${obj.Y} | Targets: ${t.rows}×${t.cols} @ ${t.pitchX}×${t.pitchY} | Blocks: ${blocks.length} (${spotTotal} spots)
        </div>
      </div>
    `;
    }).join('');
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
        <label>Object Type:</label>
        <input type="text" id="obj-type" value="targetarray" readonly
               style="background: #f9f9f9; width: 140px;">
        <span style="font-size: 12px; color: #999; margin-left: 8px;">Target Array (targets × blocks of spots)</span>
      </div>

      <h4 style="margin: 20px 0 10px 0; color: #667eea;">Target Array Layout</h4>
      <div class="form-row cols-2">
        <div>
          <label>Target Rows:</label>
          <input type="number" id="obj-target-rows" value="${obj.target_rows != null ? obj.target_rows : 1}" min="1" step="1">
        </div>
        <div>
          <label>Target Columns:</label>
          <input type="number" id="obj-target-cols" value="${obj.target_cols != null ? obj.target_cols : 1}" min="1" step="1">
        </div>
      </div>
      <div class="form-row cols-2">
        <div>
          <label>Target Pitch X (mm):</label>
          <input type="number" id="obj-target-pitchx" value="${obj.target_pitchx != null ? obj.target_pitchx : (obj.X || 0)}" step="0.1">
        </div>
        <div>
          <label>Target Pitch Y (mm):</label>
          <input type="number" id="obj-target-pitchy" value="${obj.target_pitchy != null ? obj.target_pitchy : (obj.Y || 0)}" step="0.1">
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

      <h4 style="margin: 20px 0 10px 0; color: #667eea;">Blocks of Spots</h4>
      <div style="font-size: 12px; color: #999; margin-bottom: 10px;">
        Each block is a rows × columns grid of spots, repeated on every target.
        Offsets are from the target's lower-left corner.
      </div>
      <div id="blocks-container">
        ${(() => {
          const bl = this.getBlocks(obj);
          if (bl.length === 0) {
            return '<div style="padding: 10px; text-align: center; color: #999; font-style: italic;">No blocks — this is a bare target (e.g. the bed). Add a block to place spots.</div>';
          }
          return bl.map((b, i) => this.renderBlockEditor(b, i)).join('');
        })()}
      </div>
      <button id="add-block" class="btn btn-secondary" style="margin-bottom: 15px;">➕ Add Block</button>

      <div style="margin-bottom: 15px;">
        <label>Z Travel (mm):</label>
        <input type="number" id="obj-ztrav" value="${obj.ztrav}" step="0.1">
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

  renderBlockEditor(b, i) {
    return `
      <div class="block-editor" data-block-index="${i}" style="border: 1px solid #ddd; border-radius: 6px; padding: 10px; margin-bottom: 10px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
          <strong style="color: #667eea;">Block ${i + 1}</strong>
          <button class="btn btn-danger remove-block" data-block-index="${i}" style="padding: 2px 10px; font-size: 12px;">🗑️ Remove</button>
        </div>
        <div class="form-row cols-2">
          <div>
            <label>Block Offset X (mm):</label>
            <input type="number" class="block-offsetx" data-block-index="${i}" value="${b.offsetx}" step="0.1">
          </div>
          <div>
            <label>Block Offset Y (mm):</label>
            <input type="number" class="block-offsety" data-block-index="${i}" value="${b.offsety}" step="0.1">
          </div>
        </div>
        <div class="form-row cols-2">
          <div>
            <label>Spot Rows:</label>
            <input type="number" class="block-rows" data-block-index="${i}" value="${b.rows}" min="1" step="1">
          </div>
          <div>
            <label>Spot Columns:</label>
            <input type="number" class="block-cols" data-block-index="${i}" value="${b.cols}" min="1" step="1">
          </div>
        </div>
        <div class="form-row cols-2">
          <div>
            <label>Spot Spacing X (mm):</label>
            <input type="number" class="block-spacingx" data-block-index="${i}" value="${b.spacingx}" step="0.1">
          </div>
          <div>
            <label>Spot Spacing Y (mm):</label>
            <input type="number" class="block-spacingy" data-block-index="${i}" value="${b.spacingy}" step="0.1">
          </div>
        </div>
        <div style="margin-bottom: 10px;">
          <label>Spot Shape:</label>
          <label style="display: inline; margin-right: 15px;">
            <input type="radio" name="block-shape-${i}" class="block-shape" data-block-index="${i}" value="ellipse" ${b.spot_shape === 'ellipse' ? 'checked' : ''}> Ellipse (Round)
          </label>
          <label style="display: inline;">
            <input type="radio" name="block-shape-${i}" class="block-shape" data-block-index="${i}" value="square" ${b.spot_shape === 'square' ? 'checked' : ''}> Square
          </label>
        </div>
        <div class="form-row cols-2">
          <div>
            <label>Spot Size X (mm):</label>
            <input type="number" class="block-sizex" data-block-index="${i}" value="${b.spot_sizex}" step="0.01">
          </div>
          <div>
            <label>Spot Size Y (mm):</label>
            <input type="number" class="block-sizey" data-block-index="${i}" value="${b.spot_sizey}" step="0.01">
          </div>
        </div>
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
      'obj-posx', 'obj-posy', 'obj-ztrav',
      'obj-target-rows', 'obj-target-cols', 'obj-target-pitchx', 'obj-target-pitchy'
    ];
    
    fields.forEach(fieldId => {
      const element = container.querySelector(`#${fieldId}`);
      element?.addEventListener('change', () => this.autoSaveObject());
    });

    // Per-block field changes
    container.querySelectorAll(
      '.block-offsetx, .block-offsety, .block-rows, .block-cols, ' +
      '.block-spacingx, .block-spacingy, .block-sizex, .block-sizey, .block-shape'
    ).forEach(el => {
      el.addEventListener('change', () => this.autoSaveObject());
    });

    // Add / remove block buttons
    container.querySelector('#add-block')?.addEventListener('click', () => this.addBlock());
    container.querySelectorAll('.remove-block').forEach(btn => {
      btn.addEventListener('click', () => {
        this.removeBlock(parseInt(btn.dataset.blockIndex));
      });
    });
    
    // Radio buttons
    container.querySelectorAll('input[name="obj-status"]').forEach(radio => {
      radio.addEventListener('change', () => this.autoSaveObject());
    });
  }

  // Read the current form into a normalized blocks[] array
  readBlocksFromForm() {
    const container = document.getElementById('object-editor-content');
    const editors = container.querySelectorAll('.block-editor');
    const blocks = [];
    editors.forEach((ed, i) => {
      const q = (sel) => ed.querySelector(sel);
      blocks.push({
        name: `block${i + 1}`,
        offsetx: q('.block-offsetx')?.value ?? '0',
        offsety: q('.block-offsety')?.value ?? '0',
        rows: q('.block-rows')?.value ?? '1',
        cols: q('.block-cols')?.value ?? '1',
        spacingx: q('.block-spacingx')?.value ?? '0',
        spacingy: q('.block-spacingy')?.value ?? '0',
        spot_shape: ed.querySelector('.block-shape:checked')?.value ?? 'ellipse',
        spot_sizex: q('.block-sizex')?.value ?? '0',
        spot_sizey: q('.block-sizey')?.value ?? '0'
      });
    });
    return blocks;
  }

  // Keep the legacy flat Array Configuration fields in sync with block[0] so
  // existing consumers (drypad grid sync, getArrayCoordinates) keep working.
  syncLegacyFieldsFromBlock0(obj) {
    const b0 = (obj.blocks && obj.blocks[0]) || null;
    if (!b0) {
      // No blocks: collapse the legacy array fields to a bare 1x1 with no
      // spot size, so drypad sync / coordinate generation see no pattern and
      // getBlocks does not re-migrate a phantom block.
      obj.arrayrow = "1";
      obj.arraycolumn = "1";
      obj.shapex = "0";
      obj.shapey = "0";
      return;
    }
    obj.marginx = b0.offsetx;
    obj.marginy = b0.offsety;
    obj.arrayrow = b0.rows;
    obj.arraycolumn = b0.cols;
    obj.arraycolumnsp = b0.spacingx;
    obj.arrayrowsp = b0.spacingy;
    obj.arrayshape = b0.spot_shape;
    obj.shapex = b0.spot_sizex;
    obj.shapey = b0.spot_sizey;
  }

  addBlock() {
    if (this.selectedIndex === -1) return;
    const obj = this.objects[this.selectedIndex];
    // Start from whatever the form currently shows. When there are zero
    // block editors this yields an empty array, which is correct.
    obj.blocks = this.readBlocksFromForm();
    obj.blocks.push({
      name: `block${obj.blocks.length + 1}`,
      offsetx: "0", offsety: "0", rows: "1", cols: "1",
      spacingx: "9", spacingy: "9",
      spot_shape: "ellipse", spot_sizex: "7.05", spot_sizey: "7.05"
    });
    this.syncLegacyFieldsFromBlock0(obj);
    this.storage.setObjects(this.objects);
    this.render();
    this.attachEventListeners();
  }

  removeBlock(index) {
    if (this.selectedIndex === -1) return;
    const obj = this.objects[this.selectedIndex];
    obj.blocks = this.readBlocksFromForm();
    obj.blocks.splice(index, 1);
    this.syncLegacyFieldsFromBlock0(obj);
    this.storage.setObjects(this.objects);
    this.render();
    this.attachEventListeners();
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
    obj.ztrav = container.querySelector('#obj-ztrav')?.value || obj.ztrav;

    // Object type is always targetarray in this model
    obj.objtype = 'targetarray';

    // Target Array Layout
    const tRows = container.querySelector('#obj-target-rows');
    if (tRows && tRows.value !== '') obj.target_rows = tRows.value;
    const tCols = container.querySelector('#obj-target-cols');
    if (tCols && tCols.value !== '') obj.target_cols = tCols.value;
    const tPx = container.querySelector('#obj-target-pitchx');
    if (tPx && tPx.value !== '') obj.target_pitchx = tPx.value;
    const tPy = container.querySelector('#obj-target-pitchy');
    if (tPy && tPy.value !== '') obj.target_pitchy = tPy.value;

    // Blocks of spots
    if (container.querySelector('#blocks-container')) {
      obj.blocks = this.readBlocksFromForm();
      this.syncLegacyFieldsFromBlock0(obj);
    }

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
      ztrav: "0",
      objtype: "targetarray",
      target_rows: "1",
      target_cols: "1",
      target_pitchx: "75",
      target_pitchy: "20",
      blocks: [
        {
          name: "block1",
          offsetx: "2",
          offsety: "10",
          rows: "1",
          cols: "8",
          spacingx: "9",
          spacingy: "9",
          spot_shape: "ellipse",
          spot_sizex: "7.05",
          spot_sizey: "7.05"
        }
      ]
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
    // Deep-copy the blocks array so the clone does not share block objects
    if (Array.isArray(original.blocks)) {
      cloned.blocks = original.blocks.map(b => ({ ...b }));
    }

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
    obj.ztrav = container.querySelector('#obj-ztrav').value;
    obj.color = container.querySelector('#obj-color').value;

    // Object type is always targetarray in this model
    obj.objtype = 'targetarray';

    // Target Array Layout
    const tRows = container.querySelector('#obj-target-rows');
    if (tRows && tRows.value !== '') obj.target_rows = tRows.value;
    const tCols = container.querySelector('#obj-target-cols');
    if (tCols && tCols.value !== '') obj.target_cols = tCols.value;
    const tPx = container.querySelector('#obj-target-pitchx');
    if (tPx && tPx.value !== '') obj.target_pitchx = tPx.value;
    const tPy = container.querySelector('#obj-target-pitchy');
    if (tPy && tPy.value !== '') obj.target_pitchy = tPy.value;

    // Blocks of spots
    if (container.querySelector('#blocks-container')) {
      obj.blocks = this.readBlocksFromForm();
      this.syncLegacyFieldsFromBlock0(obj);
    }

    // ---- Validate target + block geometry before saving ----
    {
      const X = parseFloat(obj.X) || 0;
      const Y = parseFloat(obj.Y) || 0;
      const posx = parseFloat(obj.posx) || 0;
      const posy = parseFloat(obj.posy) || 0;
      const t = this.getTargetLayout(obj);

      // Target overlap (pitch == size is allowed = butted targets)
      if ((t.cols > 1 && t.pitchX < X) || (t.rows > 1 && t.pitchY < Y)) {
        alert('Target pitch is smaller than target size, targets would overlap.');
        return;
      }

      // Each block's spot grid must stay within one target's footprint
      const blocks = this.getBlocks(obj);
      for (let bi = 0; bi < blocks.length; bi++) {
        const b = blocks[bi];
        const bxMin = b.offsetx - b.spot_sizex / 2;
        const byMin = b.offsety - b.spot_sizey / 2;
        const bxMax = b.offsetx + (b.cols - 1) * b.spacingx + b.spot_sizex / 2;
        const byMax = b.offsety + (b.rows - 1) * b.spacingy + b.spot_sizey / 2;
        if (bxMin < 0 || byMin < 0 || bxMax > X || byMax > Y) {
          alert(`Block ${bi + 1} extends outside the target footprint.`);
          return;
        }
      }

      // Union bounding box must stay inside the printer area
      const xMin = posx;
      const xMax = posx + (t.cols - 1) * t.pitchX + X;
      const yMin = posy;
      const yMax = posy + (t.rows - 1) * t.pitchY + Y;
      if (xMin < 0 || yMin < 0 ||
          xMax > this.printerArea.width || yMax > this.printerArea.height) {
        alert('Target array extends outside the printer area.');
        return;
      }
    }

    await this.storage.setObjects(this.objects);
    
    // If this is the drypad object, sync grid configuration to Klipper
    if (obj.name === 'drypad') {
      await this.saveDrypadGridToKlipper(obj);
    }
    
    // Sync all collision objects to Klipper
    await this.syncCollisionObjectsToKlipper();
    
    this.render();
    this.attachEventListeners();
    alert('Object saved and synced to Klipper!');
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

  // Sync collision avoidance objects to Klipper
  async syncCollisionObjectsToKlipper() {
    console.log('Syncing collision objects to Klipper...');
    
    for (const obj of this.objects) {
      const name = obj.name.toLowerCase().replace(/\s+/g, '_');
      const posx = parseFloat(obj.posx) || 0;
      const posy = parseFloat(obj.posy) || 0;
      const width = parseFloat(obj.X) || 0;
      const height = parseFloat(obj.Y) || 0;
      const zHeight = parseFloat(obj.Z) || 0;
      const zTrav = parseFloat(obj.ztrav) || 0;
      const enabled = obj.status === 'on' ? 'true' : 'false';

      // Z clearance: use ztrav if set, otherwise default based on object type
      let zClearance = zTrav > 0 ? zTrav : 10;
      if (name.includes('dispenser') || name.includes('box') || name.includes('rack')) {
        zClearance = zTrav > 0 ? zTrav : 15;
      } else if (name.includes('bed')) {
        zClearance = zTrav > 0 ? zTrav : 5;
      }

      // Emit the full set of collision variables under a given key suffix.
      const emitBox = async (suffix, xMin, xMax, yMin, yMax) => {
        await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=obj_${name}${suffix}_enabled VALUE="'${enabled}'"`);
        await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=obj_${name}${suffix}_x_min VALUE=${xMin.toFixed(1)}`);
        await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=obj_${name}${suffix}_x_max VALUE=${xMax.toFixed(1)}`);
        await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=obj_${name}${suffix}_y_min VALUE=${yMin.toFixed(1)}`);
        await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=obj_${name}${suffix}_y_max VALUE=${yMax.toFixed(1)}`);
        await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=obj_${name}${suffix}_z_height VALUE=${zHeight.toFixed(1)}`);
        await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=obj_${name}${suffix}_z_clearance VALUE=${zClearance.toFixed(1)}`);
      };

      const t = this.getTargetLayout(obj);

      if (t.rows === 1 && t.cols === 1) {
        // Single target: keep the exact original variable names.
        await emitBox('', posx, posx + width, posy, posy + height);
        console.log(`Synced collision object: ${name} (${posx}-${posx + width}, ${posy}-${posy + height}, Z=${zHeight})`);
      } else {
        // Multi-target: one box per target (1-based row/col), plus the union
        // bounding box under the original names for backward compatibility.
        for (let tr = 0; tr < t.rows; tr++) {
          for (let tc = 0; tc < t.cols; tc++) {
            const tx0 = posx + tc * t.pitchX;
            const ty0 = posy + tr * t.pitchY;
            await emitBox(`_t${tr + 1}_${tc + 1}`, tx0, tx0 + width, ty0, ty0 + height);
          }
        }
        const uXMin = posx;
        const uXMax = posx + (t.cols - 1) * t.pitchX + width;
        const uYMin = posy;
        const uYMax = posy + (t.rows - 1) * t.pitchY + height;
        await emitBox('', uXMin, uXMax, uYMin, uYMax);
        console.log(`Synced collision target array: ${name} ${t.rows}x${t.cols}, union (${uXMin}-${uXMax}, ${uYMin}-${uYMax})`);
      }
    }
    
    // Trigger Klipper to reload collision objects into memory
    await this.api.sendGcode('SYNC_COLLISION_OBJECTS');
    console.log('Collision objects synced and reloaded in Klipper');
  }

  async updatePrinterArea() {
    const widthInput = document.getElementById('printer-width');
    const heightInput = document.getElementById('printer-height');
    
    if (!widthInput || !heightInput) {
      alert('Error: Could not find printer area input fields');
      return;
    }
    
    const width = parseFloat(widthInput.value);
    const height = parseFloat(heightInput.value);

    if (isNaN(width) || isNaN(height) || width < 100 || height < 100) {
      alert('Dimensions must be at least 100mm');
      return;
    }

    this.printerArea = { width, height };
    await this.storage.setPrinterArea(width, height);
    this.render();
    this.attachEventListeners();
    alert('Printer area updated to ' + width + 'x' + height + 'mm');
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
      
      // Calculate real printer coordinates from canvas position.
      // Bed origin (0,0) is bottom-left: X grows right (un-mirrored),
      // Y grows up (canvas Y is flipped).
      const printerX = mouseX / scale;
      const printerY = this.printerArea.height - (mouseY / scale);
      
      // Update coordinate display in header
      const coordsDisplay = document.getElementById('mouse-coords');
      if (coordsDisplay) {
        coordsDisplay.textContent = `X: ${printerX.toFixed(1)}mm, Y: ${printerY.toFixed(1)}mm`;
      }
      
      // Check if mouse is over any object (target array)
      let hoveredObject = null;
      let hoveredLabel = null;
      for (let i = this.objects.length - 1; i >= 0 && !hoveredObject; i--) {
        const obj = this.objects[i];
        if (obj.status === 'off') continue;

        const sizeX = parseFloat(obj.X);
        const sizeY = parseFloat(obj.Y);
        const posx = parseFloat(obj.posx);
        const posy = parseFloat(obj.posy);
        const t = this.getTargetLayout(obj);
        const blocks = this.getBlocks(obj);
        const width = sizeX * scale;
        const height = sizeY * scale;

        for (let tr = 0; tr < t.rows && !hoveredObject; tr++) {
          for (let tc = 0; tc < t.cols && !hoveredObject; tc++) {
            const tx0 = posx + tc * t.pitchX;
            const ty0 = posy + tr * t.pitchY;
            const x = tx0 * scale;
            const y = (this.printerArea.height - (ty0 + sizeY)) * scale;
            if (mouseX < x || mouseX > x + width || mouseY < y || mouseY > y + height) {
              continue;
            }

            // Inside this target. Default label is the target cell.
            hoveredObject = obj;
            hoveredLabel = `${obj.name} [${tr + 1},${tc + 1}]`;

            // Refine to a spot if the cursor is over one
            for (let bi = 0; bi < blocks.length && hoveredLabel === `${obj.name} [${tr + 1},${tc + 1}]`; bi++) {
              const block = blocks[bi];
              const halfX = (block.spot_sizex * scale) / 2;
              const halfY = (block.spot_sizey * scale) / 2;
              for (let sr = 0; sr < block.rows; sr++) {
                for (let sc = 0; sc < block.cols; sc++) {
                  const spotX = tx0 + block.offsetx + sc * block.spacingx;
                  const spotY = ty0 + block.offsety + sr * block.spacingy;
                  const cx = spotX * scale;
                  const cy = (this.printerArea.height - spotY) * scale;
                  if (mouseX >= cx - halfX && mouseX <= cx + halfX &&
                      mouseY >= cy - halfY && mouseY <= cy + halfY) {
                    hoveredLabel = `${obj.name} [${tr + 1},${tc + 1}] block${bi + 1} [${sr + 1},${sc + 1}]`;
                    sr = block.rows; break;
                  }
                }
              }
            }
          }
        }
      }
      
      if (hoveredObject) {
        // Show tooltip
        tooltip.textContent = hoveredLabel;
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
      // Clear coordinate display when mouse leaves canvas
      const coordsDisplay = document.getElementById('mouse-coords');
      if (coordsDisplay) {
        coordsDisplay.textContent = '';
      }
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

      const sizeX = parseFloat(obj.X);
      const sizeY = parseFloat(obj.Y);
      const [r, g, b] = obj.color.split(',').map(c => parseInt(c.trim()));
      const isSelected = index === this.selectedIndex;

      const posx = parseFloat(obj.posx);
      const posy = parseFloat(obj.posy);
      const t = this.getTargetLayout(obj);
      const blocks = this.getBlocks(obj);
      const width = sizeX * scale;
      const height = sizeY * scale;

      for (let tr = 0; tr < t.rows; tr++) {
        for (let tc = 0; tc < t.cols; tc++) {
          const tx0 = posx + tc * t.pitchX;   // target lower-left, bed X
          const ty0 = posy + tr * t.pitchY;   // target lower-left, bed Y
          // Bed origin (0,0) is bottom-left: X grows right (un-mirrored),
          // Y grows up (canvas Y is flipped). The rect's top canvas edge is
          // the target's upper bed edge (ty0 + sizeY).
          const displayX = tx0 * scale;
          const displayY = (this.printerArea.height - (ty0 + sizeY)) * scale;

          ctx.fillStyle = `rgba(${r}, ${g}, ${b}, 0.7)`;
          ctx.strokeStyle = isSelected ? '#ffff00' : '#000';
          ctx.lineWidth = isSelected ? 3 : 1;

          ctx.fillRect(displayX, displayY, width, height);
          ctx.strokeRect(displayX, displayY, width, height);

          // Draw every block's spots within this target
          blocks.forEach(block => {
            this.drawArrays(ctx, block, scale, tx0, ty0);
          });
        }
      }
    });
  }

  // Draw one block's grid of spots within a target whose lower-left (min-X,
  // min-Y) corner is at bed coords (targetX0, targetY0). block is normalized.
  drawArrays(ctx, block, scale, targetX0, targetY0) {
    const rows = block.rows;
    const cols = block.cols;
    const spotSizeX = block.spot_sizex * scale;
    const spotSizeY = block.spot_sizey * scale;

    ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
    ctx.strokeStyle = '#000';
    ctx.lineWidth = 0.5;

    for (let row = 0; row < rows; row++) {
      for (let col = 0; col < cols; col++) {
        // Spot centre in bed coords: target origin + block offset + grid step
        const spotX = targetX0 + block.offsetx + col * block.spacingx;
        const spotY = targetY0 + block.offsety + row * block.spacingy;

        // Bed origin bottom-left: X un-mirrored, Y flipped.
        const displayX = spotX * scale - spotSizeX / 2;
        const displayY = (this.printerArea.height - spotY) * scale - spotSizeY / 2;

        if (block.spot_shape === 'ellipse') {
          ctx.beginPath();
          ctx.ellipse(displayX + spotSizeX / 2, displayY + spotSizeY / 2,
                      spotSizeX / 2, spotSizeY / 2, 0, 0, 2 * Math.PI);
          ctx.fill();
          ctx.stroke();
        } else {
          ctx.fillRect(displayX, displayY, spotSizeX, spotSizeY);
          ctx.strokeRect(displayX, displayY, spotSizeX, spotSizeY);
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
