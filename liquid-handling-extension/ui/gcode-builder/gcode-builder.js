export class GcodeBuilder {
  constructor(storage, api) {
    this.storage = storage;
    this.api = api;
    this.savedMacros = [];
  }

  async initialize() {
    const config = this.storage.getAll();
    this.savedMacros = config.savedMacros || [];
    this.render();
  }

  refreshObjectList() {
    // Called when switching to this tab
    const select = document.getElementById('macro-object-select');
    if (select) {
      this.updateObjectDropdown();
    }
  }

  render() {
    const container = document.getElementById('gcode-builder-content');
    
    // Get active tip info
    const config = this.storage.getAll();
    const tips = config.tips || [];
    const activeTipIndex = config.activeTipIndex || 0;
    const activeTip = tips[activeTipIndex] || { name: 'L0Tip0' };
    
    container.innerHTML = `
      <!-- Position to Tip Stations -->
      <div class="section">
        <h3 class="section-title">🔸 Position to Tip Stations</h3>
        <div class="btn-group">
          <button id="position-to-drypad" class="btn btn-purple">🔸 Drypad</button>
          <button id="position-to-wash" class="btn btn-secondary">🧼 Wash</button>
        </div>
        <div class="btn-group">
          <button id="position-to-waste" class="btn btn-warning">🗑️ Waste</button>
        </div>
      </div>

      <!-- Position to Object -->
      <div class="section">
        <h3 class="section-title">📍 Position to Object</h3>

        <div style="margin-bottom: 10px;">
          <label>Select Object:</label>
          <select id="macro-object-select" style="width: 100%;">
            <option value="">Choose an object...</option>
          </select>
        </div>

        <div class="form-row cols-2" style="margin-bottom: 10px;">
          <div>
            <label>Array Row:</label>
            <input type="number" id="array-row" min="1" value="1">
          </div>
          <div>
            <label>Array Column:</label>
            <input type="number" id="array-column" min="1" value="1">
          </div>
        </div>

        <div class="btn-group" style="margin-bottom: 10px;">
          <button id="position-to-object" class="btn">📦 Position to Object</button>
          <button id="position-to-array" class="btn btn-warning">🎯 Position to Array</button>
        </div>

        <button id="refresh-objects" class="btn btn-secondary" style="width: 100%;">🔄 Refresh Object List</button>
      </div>

      <!-- G-code Sequence Builder -->
      <div class="section">
        <h3 class="section-title">⚙️ G-code Sequence Builder</h3>

        <div style="margin-bottom: 10px;">
          <label>Sequence Name:</label>
          <input type="text" id="macro-name" placeholder="my_automation_sequence">
        </div>

        <textarea id="macro-output" style="height: 200px; font-family: monospace; font-size: 11px;" 
                  placeholder="G-code will appear here... Click 'Position to Object' or 'Position to Array' to start building your sequence."></textarea>

        <div class="alert alert-info" style="margin-top: 10px; font-size: 11px;">
          Ready-to-run G-code sequence. Copy to Mainsail console, download as .gcode, or run directly.
        </div>

        <div class="btn-group" style="margin-top: 10px;">
          <button id="save-macro" class="btn">💾 Save Sequence</button>
          <button id="copy-gcode" class="btn btn-secondary">📋 Copy</button>
        </div>

        <div class="btn-group">
          <button id="download-gcode" class="btn btn-warning">⬇️ Download .gcode</button>
          <button id="run-gcode" class="btn btn-danger" style="font-weight: bold;">▶️ Run on Printer</button>
        </div>

        <div class="btn-group">
          <button id="clear-gcode" class="btn btn-gray">🗑️ Clear</button>
        </div>
      </div>

      <!-- Saved Sequences -->
      <div class="section">
        <h3 class="section-title">📚 Saved G-code Sequences</h3>

        <select id="saved-macros-select" multiple size="8" style="width: 100%; margin-bottom: 10px; font-family: monospace; font-size: 12px;">
          ${this.renderSavedMacros()}
        </select>

        <div class="btn-group" style="margin-bottom: 10px;">
          <button id="load-macro" class="btn btn-secondary">📂 Load Selected</button>
          <button id="delete-macro" class="btn btn-danger">🗑️ Delete</button>
        </div>

        <div class="btn-group" style="margin-bottom: 10px;">
          <button id="move-up" class="btn btn-purple">⬆️ Move Up</button>
          <button id="move-down" class="btn btn-purple">⬇️ Move Down</button>
        </div>

        <button id="combine-macros" class="btn btn-gray" style="width: 100%;">🔗 Combine Selected</button>
      </div>
    `;

    this.updateObjectDropdown();
    this.attachEventListeners();
  }

  renderSavedMacros() {
    if (this.savedMacros.length === 0) {
      return '<option disabled style="color: #666;">No saved sequences yet</option>';
    }

    return this.savedMacros.map((macro, i) => 
      `<option value="${i}">${macro.name}</option>`
    ).join('');
  }

  updateObjectDropdown() {
    const select = document.getElementById('macro-object-select');
    if (!select) return;

    const objects = this.storage.getObjects();
    select.innerHTML = '<option value="">Choose an object...</option>';

    if (objects.length === 0) {
      select.innerHTML += '<option disabled>No objects found - create some in Object Editor</option>';
      return;
    }

    objects.forEach(obj => {
      const statusIcon = obj.status === 'on' ? '✅' : '❌';
      const arrayCount = parseInt(obj.arrayrow) * parseInt(obj.arraycolumn);
      select.innerHTML += `<option value="${obj.name}">${obj.name} ${statusIcon} (${arrayCount} arrays)</option>`;
    });
  }

  attachEventListeners() {
    const container = document.getElementById('gcode-builder-content');

    // Tip position controls
    container.querySelector('#position-to-drypad')?.addEventListener('click', () => {
      this.addPositionToTipStation('DRYPAD');
    });

    container.querySelector('#position-to-wash')?.addEventListener('click', () => {
      this.addPositionToTipStation('WASH');
    });

    container.querySelector('#position-to-waste')?.addEventListener('click', () => {
      this.addPositionToTipStation('WASTE');
    });

    // Position controls
    container.querySelector('#refresh-objects')?.addEventListener('click', () => {
      this.updateObjectDropdown();
      this.showNotification('Object list refreshed');
    });

    container.querySelector('#position-to-object')?.addEventListener('click', () => {
      this.addPositionToObject();
    });

    container.querySelector('#position-to-array')?.addEventListener('click', () => {
      this.addPositionToArray();
    });

    // Sequence controls
    container.querySelector('#save-macro')?.addEventListener('click', () => this.saveMacro());
    container.querySelector('#copy-gcode')?.addEventListener('click', () => this.copyGcode());
    container.querySelector('#download-gcode')?.addEventListener('click', () => this.downloadGcode());
    container.querySelector('#run-gcode')?.addEventListener('click', () => this.runGcode());
    container.querySelector('#clear-gcode')?.addEventListener('click', () => {
      if (confirm('Clear the current G-code sequence?')) {
        document.getElementById('macro-output').value = '';
      }
    });

    // Saved macros
    container.querySelector('#load-macro')?.addEventListener('click', () => this.loadMacro());
    container.querySelector('#delete-macro')?.addEventListener('click', () => this.deleteMacro());
    container.querySelector('#move-up')?.addEventListener('click', () => this.moveMacro(-1));
    container.querySelector('#move-down')?.addEventListener('click', () => this.moveMacro(1));
    container.querySelector('#combine-macros')?.addEventListener('click', () => this.combineMacros());
  }

  addPositionToTipStation(station) {
    const config = this.storage.getAll();
    const tips = config.tips || [];
    const activeTipIndex = config.activeTipIndex || 0;
    const activeTip = tips[activeTipIndex] || {};
    
    const sequenceName = document.getElementById('macro-name').value || 'automation_sequence';
    const currentGcode = document.getElementById('macro-output').value;

    let newCommand = '';
    if (!currentGcode.trim()) {
      newCommand = `; G-code Sequence: ${sequenceName}\n`;
      newCommand += `; Generated: ${new Date().toISOString()}\n`;
      newCommand += `; Active Tip: ${activeTip.name || 'L0Tip0'}\n`;
      newCommand += `; Ready to execute in Mainsail console\n\n`;
    }

    if (station === 'DRYPAD') {
      const x = activeTip.drypad_x || 92.0;
      const y = activeTip.drypad_y || 335.0;
      const z = activeTip.drypad_z || 70.0;
      
      newCommand += `; Move to DRYPAD (${activeTip.name || 'L0Tip0'})\n`;
      newCommand += `G90  ; Absolute positioning\n`;
      newCommand += `G1 X${x} Y${y} F3000  ; Move to drypad XY position\n`;
      newCommand += `G1 Z${z} F1500  ; Move to drypad Z height\n`;
      newCommand += `G4 P500  ; Pause 500ms for stabilization\n\n`;
    } else if (station === 'WASH') {
      const x = activeTip.wash_x || 134.0;
      const y = activeTip.wash_y || 374.5;
      const z = activeTip.wash_z || 70.0;
      
      newCommand += `; Move to WASH (${activeTip.name || 'L0Tip0'})\n`;
      newCommand += `G90  ; Absolute positioning\n`;
      newCommand += `G1 X${x} Y${y} F3000  ; Move to wash XY position\n`;
      newCommand += `G1 Z${z} F1500  ; Move to wash Z height\n`;
      newCommand += `G4 P500  ; Pause 500ms for stabilization\n\n`;
    } else if (station === 'WASTE') {
      const x = activeTip.waste_x || 170.0;
      const y = activeTip.waste_y || 373.0;
      const z = activeTip.waste_z || 92.0;
      
      newCommand += `; Move to WASTE (${activeTip.name || 'L0Tip0'})\n`;
      newCommand += `G90  ; Absolute positioning\n`;
      newCommand += `G1 X${x} Y${y} F3000  ; Move to waste XY position\n`;
      newCommand += `G1 Z${z} F1500  ; Move to waste Z height\n`;
      newCommand += `G4 P500  ; Pause 500ms for stabilization\n\n`;
    }

    document.getElementById('macro-output').value = currentGcode + newCommand;
  }

  addPositionToObject() {
    const selectedName = document.getElementById('macro-object-select').value;
    if (!selectedName) {
      alert('Please select an object from the dropdown');
      return;
    }

    const sequenceName = document.getElementById('macro-name').value || 'automation_sequence';
    const currentGcode = document.getElementById('macro-output').value;

    let newCommand = '';
    if (!currentGcode.trim()) {
      newCommand = `; G-code Sequence: ${sequenceName}\n`;
      newCommand += `; Generated: ${new Date().toISOString()}\n`;
      newCommand += `; Ready to execute in Mainsail console\n\n`;
    }

    // Check if this is a special tip station object
    const lowerName = selectedName.toLowerCase();
    if (lowerName === 'wash' || lowerName === 'waste' || lowerName === 'drypad') {
      // Use tip position instead of object position
      const config = this.storage.getAll();
      const tips = config.tips || [];
      const activeTipIndex = config.activeTipIndex || 0;
      const activeTip = tips[activeTipIndex] || {};

      if (lowerName === 'wash') {
        const x = activeTip.wash_x || 134.0;
        const y = activeTip.wash_y || 374.5;
        const z = activeTip.wash_z || 70.0;
        
        newCommand += `; Move to wash (${activeTip.name || 'L0Tip0'})\n`;
        newCommand += `G90  ; Absolute positioning\n`;
        newCommand += `G1 X${x} Y${y} F3000  ; Move to wash XY position\n`;
        newCommand += `G1 Z${z} F1500  ; Move to wash Z height\n`;
        newCommand += `G4 P500  ; Pause 500ms for stabilization\n\n`;
      } else if (lowerName === 'waste') {
        const x = activeTip.waste_x || 170.0;
        const y = activeTip.waste_y || 373.0;
        const z = activeTip.waste_z || 92.0;
        
        newCommand += `; Move to waste (${activeTip.name || 'L0Tip0'})\n`;
        newCommand += `G90  ; Absolute positioning\n`;
        newCommand += `G1 X${x} Y${y} F3000  ; Move to waste XY position\n`;
        newCommand += `G1 Z${z} F1500  ; Move to waste Z height\n`;
        newCommand += `G4 P500  ; Pause 500ms for stabilization\n\n`;
      } else if (lowerName === 'drypad') {
        const x = activeTip.drypad_x || 92.0;
        const y = activeTip.drypad_y || 335.0;
        const z = activeTip.drypad_z || 70.0;
        
        newCommand += `; Move to drypad (${activeTip.name || 'L0Tip0'})\n`;
        newCommand += `G90  ; Absolute positioning\n`;
        newCommand += `G1 X${x} Y${y} F3000  ; Move to drypad XY position\n`;
        newCommand += `G1 Z${z} F1500  ; Move to drypad Z height\n`;
        newCommand += `G4 P500  ; Pause 500ms for stabilization\n\n`;
      }
    } else {
      // Regular object - use object editor positions
      const obj = this.storage.getObject(selectedName);
      if (!obj) {
        alert('Object not found');
        return;
      }

      newCommand += `; Move to ${obj.name}\n`;
      newCommand += `G90  ; Absolute positioning\n`;
      newCommand += `G1 X${obj.posx} Y${obj.posy} F3000  ; Move to object position\n`;

      if (obj.ztrav !== "0") {
        newCommand += `G1 Z${obj.ztrav} F1500  ; Move to Z height\n`;
      }

      newCommand += `G4 P500  ; Pause 500ms for stabilization\n\n`;
    }

    document.getElementById('macro-output').value = currentGcode + newCommand;
  }

  addPositionToArray() {
    const selectedName = document.getElementById('macro-object-select').value;
    const arrayRow = parseInt(document.getElementById('array-row').value) - 1;
    const arrayCol = parseInt(document.getElementById('array-column').value) - 1;

    if (!selectedName) {
      alert('Please select an object');
      return;
    }

    if (isNaN(arrayRow) || isNaN(arrayCol) || arrayRow < 0 || arrayCol < 0) {
      alert('Please enter valid row and column numbers (starting from 1)');
      return;
    }

    const obj = this.storage.getObject(selectedName);
    if (!obj) {
      alert('Object not found');
      return;
    }

    const maxRows = parseInt(obj.arrayrow);
    const maxCols = parseInt(obj.arraycolumn);

    if (arrayRow >= maxRows || arrayCol >= maxCols) {
      alert(`Array position out of bounds. Object has ${maxRows} rows and ${maxCols} columns.`);
      return;
    }

    const sequenceName = document.getElementById('macro-name').value || 'automation_sequence';
    const currentGcode = document.getElementById('macro-output').value;

    // Calculate array position
    const rowSpacing = parseFloat(obj.arrayrowsp);
    const colSpacing = parseFloat(obj.arraycolumnsp);
    const marginX = parseFloat(obj.marginx);
    const marginY = parseFloat(obj.marginy);
    const baseX = parseFloat(obj.posx);
    const baseY = parseFloat(obj.posy);

    const arrayX = baseX + marginX + arrayCol * colSpacing;
    const arrayY = baseY + marginY + arrayRow * rowSpacing;
    const arrayName = String.fromCharCode(65 + arrayRow) + (arrayCol + 1);

    let newCommand = '';
    if (!currentGcode.trim()) {
      newCommand = `; G-code Sequence: ${sequenceName}\n`;
      newCommand += `; Generated: ${new Date().toISOString()}\n`;
      newCommand += `; Ready to execute in Mainsail console\n\n`;
    }

    newCommand += `; Move to ${obj.name} array ${arrayName}\n`;
    newCommand += `G90  ; Absolute positioning\n`;
    newCommand += `G1 X${arrayX.toFixed(2)} Y${arrayY.toFixed(2)} F3000  ; Move to array position\n`;

    if (obj.ztrav !== "0") {
      newCommand += `G1 Z${obj.ztrav} F1500  ; Move to Z height\n`;
    }

    newCommand += `G4 P500  ; Pause 500ms for stabilization\n\n`;

    document.getElementById('macro-output').value = currentGcode + newCommand;
  }

  async saveMacro() {
    const name = document.getElementById('macro-name').value.trim();
    const content = document.getElementById('macro-output').value.trim();

    if (!name) {
      alert('Please enter a sequence name');
      return;
    }

    if (!content) {
      alert('Please create some G-code content first');
      return;
    }

    const existingIndex = this.savedMacros.findIndex(m => m.name === name);

    if (existingIndex !== -1) {
      if (!confirm(`Sequence "${name}" already exists. Overwrite?`)) {
        return;
      }
      this.savedMacros[existingIndex] = { name, content };
    } else {
      this.savedMacros.push({ name, content });
    }

    await this.storage.setMacros(this.savedMacros);
    this.render();
    this.showNotification(`Sequence "${name}" saved!`);
  }

  copyGcode() {
    const gcode = document.getElementById('macro-output').value;
    if (!gcode.trim()) {
      alert('No G-code to copy!');
      return;
    }

    // Try modern clipboard API first (requires HTTPS)
    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(gcode).then(() => {
        this.showNotification('G-code copied to clipboard!');
        alert('G-code copied to clipboard!');
      }).catch((err) => {
        console.error('Clipboard API failed:', err);
        this.fallbackCopy(gcode);
      });
    } else {
      // Use fallback for HTTP connections
      this.fallbackCopy(gcode);
    }
  }

  fallbackCopy(text) {
    // Create a temporary textarea element
    const textArea = document.createElement('textarea');
    textArea.value = text;
    
    // Make it invisible but still part of the document
    textArea.style.position = 'fixed';
    textArea.style.top = '0';
    textArea.style.left = '0';
    textArea.style.width = '2em';
    textArea.style.height = '2em';
    textArea.style.padding = '0';
    textArea.style.border = 'none';
    textArea.style.outline = 'none';
    textArea.style.boxShadow = 'none';
    textArea.style.background = 'transparent';
    
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();
    
    try {
      const successful = document.execCommand('copy');
      if (successful) {
        this.showNotification('G-code copied to clipboard!');
        alert('G-code copied to clipboard!');
      } else {
        // execCommand failed - show the text for manual copy
        alert('Auto-copy failed. The G-code is selected in the text area - press Ctrl+C / Cmd+C to copy manually.');
        document.getElementById('macro-output').focus();
        document.getElementById('macro-output').select();
      }
    } catch (err) {
      console.error('Fallback copy failed:', err);
      alert('Auto-copy failed. The G-code is selected in the text area - press Ctrl+C / Cmd+C to copy manually.');
      document.getElementById('macro-output').focus();
      document.getElementById('macro-output').select();
    }
    
    document.body.removeChild(textArea);
  }

  downloadGcode() {
    const gcode = document.getElementById('macro-output').value;
    const sequenceName = document.getElementById('macro-name').value || 'sequence';

    if (!gcode.trim()) {
      alert('No G-code to download!');
      return;
    }

    const fileName = `${sequenceName}_${new Date().toISOString().slice(0, 10)}.gcode`;
    const blob = new Blob([gcode], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);

    const link = document.createElement('a');
    link.href = url;
    link.download = fileName;
    link.click();

    URL.revokeObjectURL(url);
    this.showNotification(`Downloaded: ${fileName}`);
  }

  async runGcode() {
    const gcode = document.getElementById('macro-output').value;

    if (!gcode.trim()) {
      alert('No G-code to run!');
      return;
    }

    if (!confirm('Run this G-code sequence on the printer now?')) {
      return;
    }

    try {
      await this.api.sendGcodeMulti(gcode);
      this.showNotification('G-code sent to printer!');
    } catch (error) {
      alert('Failed to send G-code: ' + error.message);
    }
  }

  loadMacro() {
    const select = document.getElementById('saved-macros-select');
    const selectedOptions = Array.from(select.selectedOptions);

    if (selectedOptions.length === 0) {
      alert('Please select a sequence to load');
      return;
    }

    if (selectedOptions.length > 1) {
      alert('Please select only one sequence to load');
      return;
    }

    const index = parseInt(selectedOptions[0].value);
    const macro = this.savedMacros[index];

    document.getElementById('macro-name').value = macro.name;
    document.getElementById('macro-output').value = macro.content;
    this.showNotification(`Loaded: ${macro.name}`);
  }

  async deleteMacro() {
    const select = document.getElementById('saved-macros-select');
    const selectedOptions = Array.from(select.selectedOptions);

    if (selectedOptions.length === 0) {
      alert('Please select sequence(s) to delete');
      return;
    }

    const names = selectedOptions.map(opt => this.savedMacros[parseInt(opt.value)].name);
    if (!confirm(`Delete these sequences?\n${names.join('\n')}`)) {
      return;
    }

    const indices = selectedOptions.map(opt => parseInt(opt.value)).sort((a, b) => b - a);
    indices.forEach(i => this.savedMacros.splice(i, 1));

    await this.storage.setMacros(this.savedMacros);
    this.render();
    this.showNotification(`Deleted ${indices.length} sequence(s)`);
  }

  async moveMacro(direction) {
    const select = document.getElementById('saved-macros-select');
    const selectedOptions = Array.from(select.selectedOptions);

    if (selectedOptions.length !== 1) {
      alert('Please select exactly one sequence to move');
      return;
    }

    const index = parseInt(selectedOptions[0].value);
    const newIndex = index + direction;

    if (newIndex < 0 || newIndex >= this.savedMacros.length) {
      return;
    }

    [this.savedMacros[index], this.savedMacros[newIndex]] = 
    [this.savedMacros[newIndex], this.savedMacros[index]];

    await this.storage.setMacros(this.savedMacros);
    this.render();

    // Re-select the moved item
    setTimeout(() => {
      document.getElementById('saved-macros-select').options[newIndex].selected = true;
    }, 50);
  }

  async combineMacros() {
    const select = document.getElementById('saved-macros-select');
    const selectedOptions = Array.from(select.selectedOptions);

    if (selectedOptions.length < 2) {
      alert('Please select at least 2 sequences to combine');
      return;
    }

    const selectedMacros = selectedOptions.map(opt => 
      this.savedMacros[parseInt(opt.value)]
    );

    let combined = `; Combined G-code Sequence\n`;
    combined += `; Generated: ${new Date().toISOString()}\n`;
    combined += `; Combined from: ${selectedMacros.map(m => m.name).join(', ')}\n\n`;

    selectedMacros.forEach((macro, i) => {
      combined += `; --- Sequence ${i + 1}: ${macro.name} ---\n`;
      
      const lines = macro.content.split('\n');
      lines.forEach(line => {
        const trimmed = line.trim();
        if (trimmed.startsWith('; Generated:') ||
            trimmed.startsWith('; G-code Sequence:') ||
            trimmed.startsWith('; Ready to execute') ||
            trimmed.startsWith('; Combined')) {
          return;
        }
        if (trimmed.length > 0) {
          combined += line + '\n';
        }
      });
      combined += '\n';
    });

    document.getElementById('macro-name').value = 'Combined_Sequence';
    document.getElementById('macro-output').value = combined;
    this.showNotification(`Combined ${selectedMacros.length} sequences`);
  }

  showNotification(message) {
    console.log('G-code Builder:', message);
  }
}
