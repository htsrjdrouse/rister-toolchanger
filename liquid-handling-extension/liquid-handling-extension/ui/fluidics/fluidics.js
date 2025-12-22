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
      wash_x: 134.0,
      wash_y: 374.5,
      wash_z: 70.0,
      wash_servo: 120,
      waste_x: 170.0,
      waste_y: 373.0,
      waste_z: 92.0,
      waste_servo: 170,
      eject_x: 65.0,
      eject_y: 340.0,
      eject_z: 40.0,
      eject_servo: 150
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
        <button id="touch-dry" class="btn btn-purple" style="width: 100%; margin-bottom: 10px;">Touch Drypad (Auto)</button>
        <div style="display: flex; gap: 8px;">
          <input type="number" id="drypad-position" value="1" min="1" max="210" style="flex: 1;">
          <button id="touch-dry-at" class="btn btn-purple">Touch At #</button>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="section">
        <h3 class="section-title">⚡ Quick Actions</h3>
        <div class="btn-group">
          <button id="go-wash" class="btn btn-secondary">🧼 Wash</button>
          <button id="go-waste" class="btn btn-warning">🗑️ Waste</button>
        </div>
        <div class="btn-group">
          <button id="eject-tip" class="btn btn-danger">📤 Eject</button>
          <button id="home-printer" class="btn btn-gray">🏠 Home</button>
        </div>
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

  renderTipEditor() {
    const tip = this.tips[this.selectedTipIndex];
    
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

        <h4 style="color: #2196F3; margin: 15px 0 10px 0;">🧼 WASH</h4>
        <div class="form-row cols-4">
          <div><label>X:</label><input type="number" id="tip-wash-x" value="${tip.wash_x}" step="0.1"></div>
          <div><label>Y:</label><input type="number" id="tip-wash-y" value="${tip.wash_y}" step="0.1"></div>
          <div><label>Z:</label><input type="number" id="tip-wash-z" value="${tip.wash_z}" step="0.1"></div>
          <div><label>Servo:</label><input type="number" id="tip-wash-servo" value="${tip.wash_servo}"></div>
        </div>

        <h4 style="color: #ff9800; margin: 15px 0 10px 0;">🗑️ WASTE</h4>
        <div class="form-row cols-4">
          <div><label>X:</label><input type="number" id="tip-waste-x" value="${tip.waste_x}" step="0.1"></div>
          <div><label>Y:</label><input type="number" id="tip-waste-y" value="${tip.waste_y}" step="0.1"></div>
          <div><label>Z:</label><input type="number" id="tip-waste-z" value="${tip.waste_z}" step="0.1"></div>
          <div><label>Servo:</label><input type="number" id="tip-waste-servo" value="${tip.waste_servo}"></div>
        </div>

        <h4 style="color: #f44336; margin: 15px 0 10px 0;">📤 EJECT</h4>
        <div class="form-row cols-4">
          <div><label>X:</label><input type="number" id="tip-eject-x" value="${tip.eject_x}" step="0.1"></div>
          <div><label>Y:</label><input type="number" id="tip-eject-y" value="${tip.eject_y}" step="0.1"></div>
          <div><label>Z:</label><input type="number" id="tip-eject-z" value="${tip.eject_z}" step="0.1"></div>
          <div><label>Servo:</label><input type="number" id="tip-eject-servo" value="${tip.eject_servo}"></div>
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

    // Pipette controls
    container.querySelector('#set-height')?.addEventListener('click', () => {
      const angle = document.getElementById('servo-angle').value;
      this.api.sendGcode(`SET_SERVO SERVO=linearactuator_servo_l0 ANGLE=${angle}`);
      this.showNotification(`Pipette height set to ${angle}°`);
    });
    
    container.querySelector('#preset-0')?.addEventListener('click', () => this.setPresetAngle(0));
    container.querySelector('#preset-90')?.addEventListener('click', () => this.setPresetAngle(90));
    container.querySelector('#preset-180')?.addEventListener('click', () => this.setPresetAngle(180));
    container.querySelector('#servo-off')?.addEventListener('click', () => {
      this.api.sendGcode('SET_SERVO SERVO=linearactuator_servo_l0 WIDTH=0');
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
      this.api.sendGcode('GO_WASH');
      this.showNotification('Moving to wash station...');
    });
    
    container.querySelector('#go-waste')?.addEventListener('click', () => {
      this.api.sendGcode('GO_WASTE');
      this.showNotification('Moving to waste...');
    });
    
    container.querySelector('#eject-tip')?.addEventListener('click', () => {
      this.api.sendGcode('BAYONET_EJECT');
      this.showNotification('Ejecting tip...');
    });
    
    container.querySelector('#home-printer')?.addEventListener('click', () => {
      this.api.sendGcode('G28');
      this.showNotification('Homing printer...');
    });
  }

  createNewTip() {
    const newTip = {
      name: `Tip${this.tips.length}`,
      drypad_z: 70.0,
      drypad_servo: 115,
      drypad_time: 3000,
      wash_x: 134.0,
      wash_y: 374.5,
      wash_z: 70.0,
      wash_servo: 120,
      waste_x: 170.0,
      waste_y: 373.0,
      waste_z: 92.0,
      waste_servo: 170,
      eject_x: 65.0,
      eject_y: 340.0,
      eject_z: 40.0,
      eject_servo: 150
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

  async saveTip() {
    if (this.selectedTipIndex === -1) return;

    const tip = this.tips[this.selectedTipIndex];
    const c = document.getElementById('fluidics-content');

    tip.name = c.querySelector('#tip-name').value;
    tip.drypad_z = parseFloat(c.querySelector('#tip-drypad-z').value);
    tip.drypad_servo = parseInt(c.querySelector('#tip-drypad-servo').value);
    tip.drypad_time = parseInt(c.querySelector('#tip-drypad-time').value);
    tip.wash_x = parseFloat(c.querySelector('#tip-wash-x').value);
    tip.wash_y = parseFloat(c.querySelector('#tip-wash-y').value);
    tip.wash_z = parseFloat(c.querySelector('#tip-wash-z').value);
    tip.wash_servo = parseInt(c.querySelector('#tip-wash-servo').value);
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
    this.api.sendGcode(`SET_SERVO SERVO=linearactuator_servo_l0 ANGLE=${angle}`);
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

  showNotification(message) {
    // Simple notification - could be enhanced with a toast system
    console.log('Fluidics:', message);
  }
}
