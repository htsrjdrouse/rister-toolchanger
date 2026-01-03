export class FluidicsControl {
  constructor(storage, api) {
    this.storage = storage;
    this.api = api;
    this.tips = [];
    this.selectedTipIndex = -1;
    this.activeTipIndex = 0;
  }

  async initialize() {
    const config = this.storage.getAll();
    this.tips = config.tips || [];
    this.activeTipIndex = config.activeTipIndex || 0;
    
    // Ensure at least one default tip exists
    if (this.tips.length === 0) {
      this.tips.push(this.createDefaultTip());
      await this.storage.setTips(this.tips);
    }
    
    this.render();
  }

  createDefaultTip() {
    return {
      name: "Tip0",
      drypad_z: 70.0,
      drypad_servo: 115,
      drypad_time: 3000,
      drypad_linear_pos: 115,
      drypad_delay: 2000,
      wash_x: 134.0,
      wash_y: 374.5,
      wash_z: 70.0,
      wash_servo: 120,
      wash_macro: "",
      waste_x: 170.0,
      waste_y: 373.0,
      waste_z: 92.0,
      waste_servo: 170,
      waste_macro: "",
      eject_x: 65.0,
      eject_y: 340.0,
      eject_z: 40.0,
      eject_servo: 150,
      eject_macro: ""
    };
  }

  render() {
    const container = document.getElementById('fluidics-content');
    container.innerHTML = `
      <!-- Tip Management -->
      <div class="section">
        <h3 class="section-title">💧 Tip Management</h3>
        
        <div class="btn-group">
          <button id="new-tip" class="btn">➕ New Tip</button>
          <button id="clone-tip" class="btn btn-secondary">📋 Clone</button>
          <button id="delete-tip" class="btn btn-danger">🗑️ Delete</button>
        </div>

        <div class="list-container" id="tip-list" style="margin-bottom: 15px;">
          ${this.renderTipList()}
        </div>

        <!-- Active Tip Selector -->
        <div style="background: #e8f5e9; padding: 12px; border-radius: 6px; border: 1px solid #4CAF50;">
          <label style="font-weight: 600; margin-bottom: 8px; display: block;">Active Tip:</label>
          <div style="display: flex; gap: 8px;">
            <select id="active-tip-select" style="flex: 1;">
              ${this.tips.map((tip, i) => 
                `<option value="${i}" ${i === this.activeTipIndex ? 'selected' : ''}>
                  ${tip.name} ${i === this.activeTipIndex ? '★' : ''}
                </option>`
              ).join('')}
            </select>
            <button id="set-active-tip" class="btn">Set Active</button>
          </div>
        </div>
      </div>

      <!-- Tip Editor -->
      ${this.selectedTipIndex >= 0 ? this.renderTipEditor() : `
        <div class="alert alert-info">
          Select a tip from the list above or create a new one to edit
        </div>
      `}

      <!-- Pipette Height Control -->
      <div class="section">
        <h3 class="section-title">📏 Pipette Height</h3>
        <div style="display: flex; gap: 8px; margin-bottom: 10px; align-items: center;">
          <input type="number" id="servo-angle" value="0" min="0" max="180" style="width: 80px;">
          <span style="line-height: 34px;">degrees</span>
          <button id="set-height" class="btn">Set Height</button>
        </div>
        <div class="btn-group">
          <button id="preset-0" class="btn">Up (0°)</button>
          <button id="preset-90" class="btn btn-secondary">Mid (90°)</button>
          <button id="preset-180" class="btn btn-warning">Down (180°)</button>
          <button id="servo-off" class="btn btn-danger">OFF</button>
        </div>
      </div>

      <!-- Syringe Pump -->
      <div class="section">
        <h3 class="section-title">💉 Syringe Pump</h3>
        <div class="form-row cols-2" style="margin-bottom: 10px;">
          <div>
            <label>Steps:</label>
            <input type="number" id="syringe-steps" value="130">
          </div>
          <div>
            <label>Feedrate:</label>
            <input type="number" id="syringe-feedrate" value="3000">
          </div>
        </div>
        <div class="btn-group">
          <button id="aspirate" class="btn btn-secondary">⬆️ Aspirate</button>
          <button id="dispense" class="btn">⬇️ Dispense</button>
          <button id="zero-syringe" class="btn btn-danger">Zero</button>
        </div>
      </div>

      <!-- Valves -->
      <div class="section">
        <h3 class="section-title">🔄 Valves</h3>
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 10px;">
          <label style="cursor: pointer;"><input type="checkbox" id="valve-a"> Valve A</label>
          <label style="cursor: pointer;"><input type="checkbox" id="valve-b"> Valve B</label>
          <label style="cursor: pointer;"><input type="checkbox" id="valve-c"> Valve C</label>
          <label style="cursor: pointer;"><input type="checkbox" id="valve-d"> Valve D</label>
        </div>
        <div class="btn-group" style="margin-bottom: 10px;">
          <button id="valve-all" class="btn btn-gray">All</button>
          <button id="valve-none" class="btn btn-gray">None</button>
        </div>
        <div class="btn-group">
          <button id="valve-input" class="btn btn-secondary">INPUT</button>
          <button id="valve-output" class="btn">OUTPUT</button>
          <button id="valve-bypass" class="btn btn-warning">BYPASS</button>
        </div>
      </div>

      <!-- Drypad Control -->
      <div class="section">
        <h3 class="section-title">🔸 Drypad Control</h3>
        <div class="form-row cols-2" style="margin-bottom: 10px;">
          <div>
            <label>Linear Actuator Position:</label>
            <input type="number" id="drypad-linear-position" value="${this.tips[this.activeTipIndex]?.drypad_linear_pos || 115}" min="0" max="180">
          </div>
          <div>
            <label>Delay Time (ms):</label>
            <input type="number" id="drypad-delay-time" value="${this.tips[this.activeTipIndex]?.drypad_delay || 2000}" min="0" step="100">
          </div>
        </div>
        <button id="touch-dry" class="btn btn-purple" style="width: 100%; margin-bottom: 10px;">Touch Drypad</button>
        <div style="display: flex; gap: 8px;">
          <input type="number" id="drypad-position" value="1" min="1" max="210" style="flex: 1;">
          <button id="touch-dry-at" class="btn btn-purple">Touch At #</button>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="section">
        <h3 class="section-title">⚡ Quick Actions</h3>
        ${this.renderQuickActionButtons()}
      </div>
    `;

    this.attachEventListeners();
  }

  renderTipList() {
    if (this.tips.length === 0) {
      return '<div style="padding: 20px; text-align: center; color: #999;">No tips created yet</div>';
    }

    return this.tips.map((tip, index) => `
      <div class="list-item ${index === this.selectedTipIndex ? 'selected' : ''}" data-index="${index}">
        <div class="list-item-title">
          ${index === this.activeTipIndex ? '★ ' : ''}${tip.name}
          ${index === this.activeTipIndex ? '<span style="color: #4CAF50; font-size: 10px; margin-left: 8px;">ACTIVE</span>' : ''}
        </div>
        <div class="list-item-details">
          Drypad Z: ${tip.drypad_z} | Wash: (${tip.wash_x}, ${tip.wash_y})
        </div>
      </div>
    `).join('');
  }
  
  renderQuickActionButtons() {
    const activeTip = this.tips[this.activeTipIndex];
    if (!activeTip) {
      return `
        <div class="alert alert-warning">No active tip selected</div>
      `;
    }
    
    // Auto-detect standard macro names
    const savedMacros = this.storage.getMacros();
    const washGcode = savedMacros.find(m => m.name === 'wash.gcode');
    const wasteGcode = savedMacros.find(m => m.name === 'waste.gcode');
    const ejectGcode = savedMacros.find(m => m.name === 'eject.gcode');
    
    // Use auto-detected macros or fall back to tip assignments
    const washMacro = washGcode ? 'wash.gcode' : (activeTip.wash_macro || '');
    const wasteMacro = wasteGcode ? 'waste.gcode' : (activeTip.waste_macro || '');
    const ejectMacro = ejectGcode ? 'eject.gcode' : (activeTip.eject_macro || '');
    
    const washLabel = washMacro ? `🧼 Wash (${washMacro})` : '🧼 Wash';
    const wasteLabel = wasteMacro ? `🗑️ Waste (${wasteMacro})` : '🗑️ Waste';
    const ejectLabel = ejectMacro ? `📤 Eject (${ejectMacro})` : '📤 Eject';
    
    const washTitle = washMacro ? `Run macro: ${washMacro}` : 'Run GO_WASH command';
    const wasteTitle = wasteMacro ? `Run macro: ${wasteMacro}` : 'Run GO_WASTE command';
    const ejectTitle = ejectMacro ? `Run macro: ${ejectMacro}` : 'Run BAYONET_EJECT command';
    
    return `
      <div class="btn-group">
        <button id="go-wash" class="btn btn-secondary" style="flex: 1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="${washTitle}">${washLabel}</button>
        <button id="go-waste" class="btn btn-warning" style="flex: 1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="${wasteTitle}">${wasteLabel}</button>
      </div>
      <div class="btn-group">
        <button id="eject-tip" class="btn btn-danger" style="flex: 1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="${ejectTitle}">${ejectLabel}</button>
      </div>
    `;
  }

  renderTipEditor() {
    const tip = this.tips[this.selectedTipIndex];
    const savedMacros = this.storage.getMacros();
    
    const renderMacroSelect = (currentMacro) => {
      return `
        <select style="width: 100%;">
          <option value="">-- None --</option>
          ${savedMacros.map(macro => 
            `<option value="${macro.name}" ${currentMacro === macro.name ? 'selected' : ''}>${macro.name}</option>`
          ).join('')}
        </select>
      `;
    };
    
    return `
      <div class="section">
        <h3 class="section-title">✏️ Edit Tip Properties</h3>
        
        <div class="alert alert-success" style="margin-bottom: 15px;">
          Editing: ${tip.name} (Tip ${this.selectedTipIndex + 1})
        </div>

        <div style="margin-bottom: 15px;">
          <label>Tip Name:</label>
          <input type="text" id="tip-name" value="${tip.name}">
        </div>

        <h4 style="color: #9c27b0; margin: 15px 0 10px 0;">🔸 DRYPAD</h4>
        <div class="form-row cols-3">
          <div><label>Z:</label><input type="number" id="tip-drypad-z" value="${tip.drypad_z}" step="0.1"></div>
          <div><label>Servo:</label><input type="number" id="tip-drypad-servo" value="${tip.drypad_servo}"></div>
          <div><label>Time (ms):</label><input type="number" id="tip-drypad-time" value="${tip.drypad_time}"></div>
        </div>
        <div class="form-row cols-2">
          <div><label>Linear Actuator Pos:</label><input type="number" id="tip-drypad-linear-pos" value="${tip.drypad_linear_pos || 115}" min="0" max="180"></div>
          <div><label>Delay (ms):</label><input type="number" id="tip-drypad-delay" value="${tip.drypad_delay || 2000}" step="100"></div>
        </div>

        <h4 style="color: #2196F3; margin: 15px 0 10px 0;">🧼 WASH</h4>
        <div class="form-row cols-4">
          <div><label>X:</label><input type="number" id="tip-wash-x" value="${tip.wash_x}" step="0.1"></div>
          <div><label>Y:</label><input type="number" id="tip-wash-y" value="${tip.wash_y}" step="0.1"></div>
          <div><label>Z:</label><input type="number" id="tip-wash-z" value="${tip.wash_z}" step="0.1"></div>
          <div><label>Servo:</label><input type="number" id="tip-wash-servo" value="${tip.wash_servo}"></div>
        </div>
        <div style="margin-bottom: 10px;">
          <label>G-code Macro (optional):</label>
          ${renderMacroSelect(tip.wash_macro || "")}
          <div id="wash-macro-select-holder" style="display:none;">${tip.wash_macro || ""}</div>
        </div>

        <h4 style="color: #ff9800; margin: 15px 0 10px 0;">🗑️ WASTE</h4>
        <div class="form-row cols-4">
          <div><label>X:</label><input type="number" id="tip-waste-x" value="${tip.waste_x}" step="0.1"></div>
          <div><label>Y:</label><input type="number" id="tip-waste-y" value="${tip.waste_y}" step="0.1"></div>
          <div><label>Z:</label><input type="number" id="tip-waste-z" value="${tip.waste_z}" step="0.1"></div>
          <div><label>Servo:</label><input type="number" id="tip-waste-servo" value="${tip.waste_servo}"></div>
        </div>
        <div style="margin-bottom: 10px;">
          <label>G-code Macro (optional):</label>
          ${renderMacroSelect(tip.waste_macro || "")}
          <div id="waste-macro-select-holder" style="display:none;">${tip.waste_macro || ""}</div>
        </div>

        <h4 style="color: #f44336; margin: 15px 0 10px 0;">📤 EJECT</h4>
        <div class="form-row cols-4">
          <div><label>X:</label><input type="number" id="tip-eject-x" value="${tip.eject_x}" step="0.1"></div>
          <div><label>Y:</label><input type="number" id="tip-eject-y" value="${tip.eject_y}" step="0.1"></div>
          <div><label>Z:</label><input type="number" id="tip-eject-z" value="${tip.eject_z}" step="0.1"></div>
          <div><label>Servo:</label><input type="number" id="tip-eject-servo" value="${tip.eject_servo}"></div>
        </div>
        <div style="margin-bottom: 10px;">
          <label>G-code Macro (optional):</label>
          ${renderMacroSelect(tip.eject_macro || "")}
          <div id="eject-macro-select-holder" style="display:none;">${tip.eject_macro || ""}</div>
        </div>

        <div class="btn-group">
          <button id="save-tip" class="btn">💾 Save Changes</button>
          <button id="cancel-tip-edit" class="btn btn-gray">❌ Cancel</button>
        </div>
      </div>
    `;
  }

  attachEventListeners() {
    const container = document.getElementById('fluidics-content');

    // Tip management
    container.querySelector('#new-tip')?.addEventListener('click', () => this.createNewTip());
    container.querySelector('#clone-tip')?.addEventListener('click', () => this.cloneTip());
    container.querySelector('#delete-tip')?.addEventListener('click', () => this.deleteTip());
    container.querySelector('#set-active-tip')?.addEventListener('click', () => this.setActiveTip());

    // Tip list clicks
    container.querySelectorAll('#tip-list .list-item').forEach(item => {
      item.addEventListener('click', () => {
        this.selectedTipIndex = parseInt(item.dataset.index);
        this.render();
      });
    });

    // Tip editor
    container.querySelector('#save-tip')?.addEventListener('click', () => this.saveTip());
    container.querySelector('#cancel-tip-edit')?.addEventListener('click', () => {
      this.selectedTipIndex = -1;
      this.render();
    });
    
    // Auto-save tip editor fields
    this.setupTipAutoSave();

    // Pipette controls
    container.querySelector('#set-height')?.addEventListener('click', () => {
      const angle = document.getElementById('servo-angle').value;
      this.api.sendGcode(`LINEARACTSERVOMOVE ANGLE=${angle} HOLD=1000`);
      this.showNotification(`Pipette height set to ${angle}°`);
    });
    
    container.querySelector('#preset-0')?.addEventListener('click', () => this.setPresetAngle(0));
    container.querySelector('#preset-90')?.addEventListener('click', () => this.setPresetAngle(90));
    container.querySelector('#preset-180')?.addEventListener('click', () => this.setPresetAngle(180));
    container.querySelector('#servo-off')?.addEventListener('click', () => {
      this.api.sendGcode('LINEARACTSERVOOFF');
      this.showNotification('Servo turned OFF');
    });

    // Syringe pump
    container.querySelector('#aspirate')?.addEventListener('click', () => this.aspirate());
    container.querySelector('#dispense')?.addEventListener('click', () => this.dispense());
    container.querySelector('#zero-syringe')?.addEventListener('click', () => {
      this.api.sendGcode('G92 E0');
      this.showNotification('Syringe position zeroed');
    });

    // Valve controls
    container.querySelector('#valve-all')?.addEventListener('click', () => this.selectAllValves(true));
    container.querySelector('#valve-none')?.addEventListener('click', () => this.selectAllValves(false));
    container.querySelector('#valve-input')?.addEventListener('click', () => this.setValves('INPUT'));
    container.querySelector('#valve-output')?.addEventListener('click', () => this.setValves('OUTPUT'));
    container.querySelector('#valve-bypass')?.addEventListener('click', () => this.setValves('BYPASS'));

    // Drypad
    document.getElementById('drypad-linear-position')?.addEventListener('change', () => this.saveDrypadSettings());
    document.getElementById('drypad-delay-time')?.addEventListener('change', () => this.saveDrypadSettings());
    
    container.querySelector('#touch-dry')?.addEventListener('click', () => {
      this.api.sendGcode('TOUCH_DRY');
      this.showNotification('Touching drypad...');
    });
    
    container.querySelector('#touch-dry-at')?.addEventListener('click', () => {
      const pos = document.getElementById('drypad-position').value;
      this.api.sendGcode(`TOUCH_DRY_AT KEY=${pos}`);
      this.showNotification(`Touching drypad at position ${pos}`);
    });

    // Quick actions
    container.querySelector('#go-wash')?.addEventListener('click', () => {
      const savedMacros = this.storage.getMacros();
      const washGcode = savedMacros.find(m => m.name === 'wash.gcode');
      const activeTip = this.tips[this.activeTipIndex];
      
      // Priority: 1. wash.gcode, 2. tip-assigned macro, 3. default command
      if (washGcode) {
        this.runMacro('wash.gcode');
        this.showNotification('Running wash.gcode');
      } else if (activeTip && activeTip.wash_macro) {
        this.runMacro(activeTip.wash_macro);
        this.showNotification(`Running ${activeTip.wash_macro}`);
      } else {
        this.api.sendGcode('GO_WASH');
        this.showNotification('Moving to wash station...');
      }
    });
    
    container.querySelector('#go-waste')?.addEventListener('click', () => {
      const savedMacros = this.storage.getMacros();
      const wasteGcode = savedMacros.find(m => m.name === 'waste.gcode');
      const activeTip = this.tips[this.activeTipIndex];
      
      // Priority: 1. waste.gcode, 2. tip-assigned macro, 3. default command
      if (wasteGcode) {
        this.runMacro('waste.gcode');
        this.showNotification('Running waste.gcode');
      } else if (activeTip && activeTip.waste_macro) {
        this.runMacro(activeTip.waste_macro);
        this.showNotification(`Running ${activeTip.waste_macro}`);
      } else {
        this.api.sendGcode('GO_WASTE');
        this.showNotification('Moving to waste...');
      }
    });
    
    container.querySelector('#eject-tip')?.addEventListener('click', () => {
      const savedMacros = this.storage.getMacros();
      const ejectGcode = savedMacros.find(m => m.name === 'eject.gcode');
      const activeTip = this.tips[this.activeTipIndex];
      
      // Priority: 1. eject.gcode, 2. tip-assigned macro, 3. default command
      if (ejectGcode) {
        this.runMacro('eject.gcode');
        this.showNotification('Running eject.gcode');
      } else if (activeTip && activeTip.eject_macro) {
        this.runMacro(activeTip.eject_macro);
        this.showNotification(`Running ${activeTip.eject_macro}`);
      } else {
        this.api.sendGcode('BAYONET_EJECT');
        this.showNotification('Ejecting tip...');
      }
    });
  }

  createNewTip() {
    const newTip = {
      name: `Tip${this.tips.length}`,
      drypad_z: 70.0,
      drypad_servo: 115,
      drypad_time: 3000,
      drypad_linear_pos: 115,
      drypad_delay: 2000,
      wash_x: 134.0,
      wash_y: 374.5,
      wash_z: 70.0,
      wash_servo: 120,
      wash_macro: "",
      waste_x: 170.0,
      waste_y: 373.0,
      waste_z: 92.0,
      waste_servo: 170,
      waste_macro: "",
      eject_x: 65.0,
      eject_y: 340.0,
      eject_z: 40.0,
      eject_servo: 150,
      eject_macro: ""
    };

    this.tips.push(newTip);
    this.selectedTipIndex = this.tips.length - 1;
    this.storage.setTips(this.tips);
    this.render();
  }

  cloneTip() {
    if (this.selectedTipIndex === -1) {
      alert('Please select a tip to clone');
      return;
    }

    const cloned = { ...this.tips[this.selectedTipIndex] };
    cloned.name = cloned.name + '_copy';
    this.tips.push(cloned);
    this.selectedTipIndex = this.tips.length - 1;
    this.storage.setTips(this.tips);
    this.render();
  }

  deleteTip() {
    if (this.selectedTipIndex === -1) {
      alert('Please select a tip to delete');
      return;
    }

    if (this.selectedTipIndex === 0) {
      alert('Cannot delete the first tip!');
      return;
    }

    if (confirm(`Delete "${this.tips[this.selectedTipIndex].name}"?`)) {
      this.tips.splice(this.selectedTipIndex, 1);
      this.selectedTipIndex = -1;
      this.storage.setTips(this.tips);
      this.render();
    }
  }
  
  setupTipAutoSave() {
    if (this.selectedTipIndex === -1) return;
    
    const container = document.getElementById('fluidics-content');
    const fields = [
      'tip-name', 'tip-drypad-z', 'tip-drypad-servo', 'tip-drypad-time',
      'tip-drypad-linear-pos', 'tip-drypad-delay',
      'tip-wash-x', 'tip-wash-y', 'tip-wash-z', 'tip-wash-servo',
      'tip-waste-x', 'tip-waste-y', 'tip-waste-z', 'tip-waste-servo',
      'tip-eject-x', 'tip-eject-y', 'tip-eject-z', 'tip-eject-servo'
    ];
    
    fields.forEach(fieldId => {
      const element = container.querySelector(`#${fieldId}`);
      element?.addEventListener('change', () => this.autoSaveTip());
    });
    
    // Macro dropdowns
    const selects = container.querySelectorAll('select');
    selects.forEach(select => {
      select.addEventListener('change', () => this.autoSaveTip());
    });
  }
  
  async autoSaveTip() {
    if (this.selectedTipIndex === -1) return;

    const tip = this.tips[this.selectedTipIndex];
    const c = document.getElementById('fluidics-content');

    tip.name = c.querySelector('#tip-name')?.value || tip.name;
    tip.drypad_z = parseFloat(c.querySelector('#tip-drypad-z')?.value || tip.drypad_z);
    tip.drypad_servo = parseInt(c.querySelector('#tip-drypad-servo')?.value || tip.drypad_servo);
    tip.drypad_time = parseInt(c.querySelector('#tip-drypad-time')?.value || tip.drypad_time);
    tip.drypad_linear_pos = parseInt(c.querySelector('#tip-drypad-linear-pos')?.value || 115);
    tip.drypad_delay = parseInt(c.querySelector('#tip-drypad-delay')?.value || 2000);
    
    tip.wash_x = parseFloat(c.querySelector('#tip-wash-x')?.value || tip.wash_x);
    tip.wash_y = parseFloat(c.querySelector('#tip-wash-y')?.value || tip.wash_y);
    tip.wash_z = parseFloat(c.querySelector('#tip-wash-z')?.value || tip.wash_z);
    tip.wash_servo = parseInt(c.querySelector('#tip-wash-servo')?.value || tip.wash_servo);
    
    tip.waste_x = parseFloat(c.querySelector('#tip-waste-x')?.value || tip.waste_x);
    tip.waste_y = parseFloat(c.querySelector('#tip-waste-y')?.value || tip.waste_y);
    tip.waste_z = parseFloat(c.querySelector('#tip-waste-z')?.value || tip.waste_z);
    tip.waste_servo = parseInt(c.querySelector('#tip-waste-servo')?.value || tip.waste_servo);
    
    tip.eject_x = parseFloat(c.querySelector('#tip-eject-x')?.value || tip.eject_x);
    tip.eject_y = parseFloat(c.querySelector('#tip-eject-y')?.value || tip.eject_y);
    tip.eject_z = parseFloat(c.querySelector('#tip-eject-z')?.value || tip.eject_z);
    tip.eject_servo = parseInt(c.querySelector('#tip-eject-servo')?.value || tip.eject_servo);
    
    // Get macro selects
    const washMacroSelects = c.querySelectorAll('select');
    if (washMacroSelects.length >= 3) {
      tip.wash_macro = washMacroSelects[0]?.value || "";
      tip.waste_macro = washMacroSelects[1]?.value || "";
      tip.eject_macro = washMacroSelects[2]?.value || "";
    }

    await this.storage.setTips(this.tips);
    await this.saveAllTipsToKlipper();
    console.log('Auto-saved tip:', tip.name);
  }

  async saveTip() {
    if (this.selectedTipIndex === -1) return;

    const tip = this.tips[this.selectedTipIndex];
    const c = document.getElementById('fluidics-content');

    tip.name = c.querySelector('#tip-name').value;
    tip.drypad_z = parseFloat(c.querySelector('#tip-drypad-z').value);
    tip.drypad_servo = parseInt(c.querySelector('#tip-drypad-servo').value);
    tip.drypad_time = parseInt(c.querySelector('#tip-drypad-time').value);
    tip.drypad_linear_pos = parseInt(c.querySelector('#tip-drypad-linear-pos')?.value || 115);
    tip.drypad_delay = parseInt(c.querySelector('#tip-drypad-delay')?.value || 2000);
    
    tip.wash_x = parseFloat(c.querySelector('#tip-wash-x').value);
    tip.wash_y = parseFloat(c.querySelector('#tip-wash-y').value);
    tip.wash_z = parseFloat(c.querySelector('#tip-wash-z').value);
    tip.wash_servo = parseInt(c.querySelector('#tip-wash-servo').value);
    
    // Get macro selects - they appear after the "G-code Macro (optional):" labels
    const washMacroSelects = c.querySelectorAll('select');
    tip.wash_macro = washMacroSelects[0]?.value || "";
    tip.waste_macro = washMacroSelects[1]?.value || "";
    tip.eject_macro = washMacroSelects[2]?.value || "";
    
    tip.waste_x = parseFloat(c.querySelector('#tip-waste-x').value);
    tip.waste_y = parseFloat(c.querySelector('#tip-waste-y').value);
    tip.waste_z = parseFloat(c.querySelector('#tip-waste-z').value);
    tip.waste_servo = parseInt(c.querySelector('#tip-waste-servo').value);
    
    tip.eject_x = parseFloat(c.querySelector('#tip-eject-x').value);
    tip.eject_y = parseFloat(c.querySelector('#tip-eject-y').value);
    tip.eject_z = parseFloat(c.querySelector('#tip-eject-z').value);
    tip.eject_servo = parseInt(c.querySelector('#tip-eject-servo').value);

    await this.storage.setTips(this.tips);
    await this.saveAllTipsToKlipper();
    this.showNotification('Tip saved successfully!');
    this.render();
  }

  async setActiveTip() {
    const select = document.getElementById('active-tip-select');
    this.activeTipIndex = parseInt(select.value);
    await this.storage.setActiveTipIndex(this.activeTipIndex);
    await this.api.sendGcode(`SELECT_TIP TIP=${this.activeTipIndex}`);
    this.showNotification(`Active tip set to: ${this.tips[this.activeTipIndex].name}`);
    this.render();
  }

  async saveAllTipsToKlipper() {
    const tipsObj = {};
    this.tips.forEach((tip, i) => {
      tipsObj[`tip${i}`] = tip;
    });
    const jsonStr = JSON.stringify(tipsObj).replace(/"/g, '\\"');
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=tips_config VALUE="${jsonStr}"`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=active_tip VALUE=${this.activeTipIndex}`);
  }

  setPresetAngle(angle) {
    document.getElementById('servo-angle').value = angle;
    this.api.sendGcode(`LINEARACTSERVOMOVE ANGLE=${angle} HOLD=1000`);
    this.showNotification(`Pipette set to ${angle}°`);
  }

  aspirate() {
    const steps = document.getElementById('syringe-steps').value;
    const feedrate = document.getElementById('syringe-feedrate').value;
    this.api.sendGcode(`G91\nG1 E-${steps} F${feedrate}\nG90`);
    this.showNotification(`Aspirating ${steps} steps`);
  }

  dispense() {
    const steps = document.getElementById('syringe-steps').value;
    const feedrate = document.getElementById('syringe-feedrate').value;
    this.api.sendGcode(`G91\nG1 E${steps} F${feedrate}\nG90`);
    this.showNotification(`Dispensing ${steps} steps`);
  }

  getValveMask() {
    const a = document.getElementById('valve-a')?.checked ? '1' : '0';
    const b = document.getElementById('valve-b')?.checked ? '1' : '0';
    const c = document.getElementById('valve-c')?.checked ? '1' : '0';
    const d = document.getElementById('valve-d')?.checked ? '1' : '0';
    return a + b + c + d;
  }

  selectAllValves(state) {
    ['valve-a', 'valve-b', 'valve-c', 'valve-d'].forEach(id => {
      const el = document.getElementById(id);
      if (el) el.checked = state;
    });
  }

  setValves(mode) {
    const mask = this.getValveMask();
    if (mask === '0000') {
      alert('Please select at least one valve');
      return;
    }
    this.api.sendGcode(`VALVE_${mode} MASK=${mask}`);
    this.showNotification(`Valves set to ${mode} (${mask})`);
  }

  async saveDrypadSettings() {
    const linearPos = parseInt(document.getElementById('drypad-linear-position')?.value || 115);
    const delayTime = parseInt(document.getElementById('drypad-delay-time')?.value || 2000);
    
    // Save to active tip
    if (this.tips[this.activeTipIndex]) {
      this.tips[this.activeTipIndex].drypad_linear_pos = linearPos;
      this.tips[this.activeTipIndex].drypad_delay = delayTime;
      
      await this.storage.setTips(this.tips);
      await this.saveAllTipsToKlipper();
      console.log('Auto-saved drypad settings:', linearPos, delayTime);
    }
  }

  runMacro(macroName) {
    const savedMacros = this.storage.getMacros();
    const macro = savedMacros.find(m => m.name === macroName);
    if (macro && macro.content) {
      this.api.sendGcode(macro.content);
    } else {
      console.warn(`Macro "${macroName}" not found`);
    }
  }

  showNotification(message) {
    // Simple notification - could be enhanced with a toast system
    console.log('Fluidics:', message);
  }
}
