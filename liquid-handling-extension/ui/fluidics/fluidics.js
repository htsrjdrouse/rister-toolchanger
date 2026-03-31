export class FluidicsControl {
  constructor(storage, api) {
    this.storage = storage;
    this.api = api;
    this.tips = [];
    this.selectedTipIndex = -1;
    this.activeTipIndex = 0;
    this.syncInterval = null;
    this.triggerArmed = false;
    this.valveState = 'UNKNOWN';
    this.power5v = false;
    this.pumpAccelSteps = 500;
    this.settingsSaveIndicator = null;
    this.lastSentSeqAccel = null;
  }

  async initialize() {
    const config = this.storage.getAll();
    this.tips = config.tips || [];
    this.activeTipIndex = config.activeTipIndex || 0;

    // Load fluidics settings from storage
    this.loadSettings();

    // Ensure at least one default tip exists
    if (this.tips.length === 0) {
      this.tips.push(this.createDefaultTip());
      await this.storage.setTips(this.tips);
    }

    // Sync active tip FROM Klipper (in case it was changed externally)
    await this.syncActiveTipFromKlipper();

    // Sync all station variables to Klipper for active tip
    await this.saveAllStationVariables();

    this.render();

    // Update all positions from variables.cfg after rendering
    await this.updateAllPositions();

    // Start periodic sync to track external tip changes
    this.startActiveTipSync();
  }

  loadSettings() {
    const settings = this.storage.getFluidicsSettings();
    this.pumpAccelSteps = settings.accelSteps || 500;
  }

  async saveSetting(key, value) {
    await this.storage.setFluidicsSetting(key, value);
    this.showSettingsSaved();
  }

  showSettingsSaved() {
    // Show a brief "Saved" indicator
    const indicator = document.getElementById('settings-saved-indicator');
    if (indicator) {
      indicator.style.opacity = '1';
      setTimeout(() => {
        indicator.style.opacity = '0';
      }, 1000);
    }
  }

  // Sync active tip index from Klipper's variables.cfg
  async syncActiveTipFromKlipper() {
    try {
      const klipperActiveTip = await this.api.getSavedVariable('active_tip');
      if (klipperActiveTip !== null && klipperActiveTip !== undefined) {
        let tipIndex = -1;

        // Try parsing as number first (legacy support)
        const numValue = parseInt(klipperActiveTip);
        if (!isNaN(numValue) && numValue >= 0 && numValue < this.tips.length) {
          tipIndex = numValue;
        } else {
          // Try matching by tip name (e.g., "L0Tip1")
          const tipName = String(klipperActiveTip).toUpperCase();
          tipIndex = this.tips.findIndex(tip =>
            tip.name && tip.name.toUpperCase() === tipName
          );
        }

        if (tipIndex >= 0 && tipIndex < this.tips.length) {
          if (this.activeTipIndex !== tipIndex) {
            console.log(`Syncing active tip from Klipper: ${this.activeTipIndex} -> ${tipIndex} (${klipperActiveTip})`);
            this.activeTipIndex = tipIndex;
            await this.storage.setActiveTipIndex(tipIndex);
            this.render();
          }
        }
      }
    } catch (error) {
      console.warn('Could not sync active tip from Klipper:', error);
    }
  }

  // Start periodic polling to sync active tip from Klipper
  startActiveTipSync(intervalMs = 5000) {
    // Clear any existing interval
    if (this.syncInterval) {
      clearInterval(this.syncInterval);
    }

    this.syncInterval = setInterval(async () => {
      await this.syncActiveTipFromKlipper();
    }, intervalMs);

    console.log(`Active tip sync started (polling every ${intervalMs}ms)`);
  }

  // Stop periodic sync
  stopActiveTipSync() {
    if (this.syncInterval) {
      clearInterval(this.syncInterval);
      this.syncInterval = null;
      console.log('Active tip sync stopped');
    }
  }

  createDefaultTip() {
    return {
      name: "L0Tip0",
      drypad_x: 92.0,
      drypad_y: 335.0,
      drypad_z: 70.0,
      drypad_servo_move: 0,
      drypad_servo_touch: 115,
      drypad_time: 3000,
      drypad_delay: 2000,
      wash_x: 134.0,
      wash_y: 374.5,
      wash_z: 70.0,
      wash_servo_move: 0,
      wash_servo_wash: 120,
      wash_macro: "",
      waste_x: 170.0,
      waste_y: 373.0,
      waste_z: 92.0,
      waste_servo_move: 0,
      waste_servo_waste: 170,
      waste_macro: "",
      eject_x: 65.0,
      eject_y: 340.0,
      eject_z: 40.0,
      eject_servo_move: 0,
      eject_servo_eject: 150,
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

        <!-- Servo Position Display -->
        <div style="background: #e3f2fd; padding: 12px; border-radius: 6px; margin-bottom: 12px; border: 1px solid #2196F3;">
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <label style="font-weight: 600; color: #1565c0;">Current Position:</label>
            <span id="servo-position-display" style="font-size: 18px; font-weight: bold; color: #0d47a1; font-family: monospace;">0°</span>
          </div>
          <button id="refresh-servo" class="btn btn-secondary" style="width: 100%; margin-top: 8px; font-size: 12px;">🔄 Refresh Servo Position</button>
        </div>

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

        <!-- Settings Saved Indicator -->
        <div id="settings-saved-indicator" style="position: absolute; top: 10px; right: 10px; background: #4CAF50; color: white; padding: 4px 12px; border-radius: 12px; font-size: 11px; opacity: 0; transition: opacity 0.3s; pointer-events: none;">
          ✓ Saved
        </div>

        <!-- Pump Status Display -->
        <div id="pump-status-display" style="background: #e3f2fd; padding: 10px; border-radius: 6px; margin-bottom: 12px; border: 1px solid #2196F3; font-family: monospace; font-size: 11px; min-height: 40px;">
          <div style="font-weight: 600; margin-bottom: 4px;">Arduino Status:</div>
          <div id="pump-status-text" style="color: #666;">Click "Status (P114)" to query</div>
        </div>

        <!-- Emergency Stop -->
        <div style="display: flex; gap: 8px; margin-bottom: 12px;">
          <button id="estop" class="btn btn-danger" style="flex: 1; font-size: 14px; font-weight: bold;">🛑 E-STOP (P0)</button>
          <button id="clear-estop" class="btn" style="flex: 1; font-size: 14px;">✅ Clear Stop (P999)</button>
        </div>
        <div style="display: flex; gap: 8px; margin-bottom: 12px;">
          <button id="motor-on" class="btn" style="flex: 1; font-size: 14px; background: #4CAF50; color: white;">⚡ Motor ON</button>
          <button id="motor-off" class="btn btn-danger" style="flex: 1; font-size: 14px;">🔌 Motor OFF</button>
        </div>

        <!-- Acceleration Ramp Control -->
        <div style="background: #f3e5f5; padding: 12px; border-radius: 6px; margin-bottom: 12px; border: 1px solid #9C27B0;">
          <label style="font-weight: 600; display: block; margin-bottom: 6px;" title="Acceleration ramp prevents skipped steps at high feedrates. 0=disabled, 200=short (E5-E20), 500=default (F10000+), 1000=long (F15000+)">
            ⚡ Accel Ramp Steps <span style="font-size: 11px; color: #666;">(SA command)</span>
          </label>
          <div style="display: flex; gap: 8px; align-items: center;">
            <input type="number" id="accel-steps" value="${this.pumpAccelSteps}" min="0" max="2000" style="flex: 1;">
            <span id="accel-current" style="font-family: monospace; font-size: 11px; color: #666; min-width: 80px;">Current: ${this.pumpAccelSteps}</span>
            <button id="apply-accel" class="btn" style="white-space: nowrap;">Apply SA</button>
          </div>
          <div style="font-size: 10px; color: #666; margin-top: 4px;">
            0=off | 200=short (E5-E20) | 500=default (F10k+) | 1000=long (F15k+)
          </div>
        </div>

        <!-- Trigger Control -->
        <div style="background: #fff3e0; padding: 12px; border-radius: 6px; margin-bottom: 12px; border: 1px solid #FF9800;">
          <label style="font-weight: 600; display: block; margin-bottom: 8px;">🎯 Trigger</label>
          <div style="display: flex; gap: 8px; margin-bottom: 8px;">
            <button id="trigger-on" class="btn" style="flex: 1; background: #4CAF50; color: white;">TRIGGER ON</button>
            <button id="trigger-off" class="btn btn-danger" style="flex: 1;">TRIGGER OFF</button>
          </div>
          <div id="trigger-status" style="text-align: center; font-weight: 600; color: #e65100; margin-bottom: 8px;">Trigger: OFF</div>
          <div id="trigger-fire-container" style="display: none;">
            <button id="trigger-fire" class="btn btn-warning" style="width: 100%; font-size: 14px;">⚡ Fire Trigger</button>
          </div>
        </div>

        <!-- Aspirate / Dispense -->
        <div class="form-row cols-2" style="margin-bottom: 10px;">
          <div>
            <label>Volume (E µL):</label>
            <input type="number" id="syringe-steps" value="${this.storage.getFluidicsSettings().pumpVolume}">
          </div>
          <div>
            <label>Feedrate (F):</label>
            <input type="number" id="syringe-feedrate" value="${this.storage.getFluidicsSettings().pumpFeedrate}">
          </div>
        </div>
        <div class="btn-group">
          <button id="aspirate" class="btn btn-secondary">⬆️ Aspirate (A1)</button>
          <button id="dispense" class="btn">⬇️ Dispense (D1)</button>
        </div>

        <!-- Status & Reset -->
        <div style="display: flex; gap: 8px; margin-top: 8px;">
          <button id="pump-status" class="btn btn-gray" style="flex: 1; font-size: 12px;">📊 Status (P114)</button>
          <button id="reset-settings" class="btn btn-gray" style="font-size: 11px; padding: 6px 10px;" title="Reset all pump and valve settings to factory defaults">🔄 Reset</button>
        </div>
      </div>

      <!-- Dispense Sequence -->
      <div class="section">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
          <h3 class="section-title" style="margin: 0;">🧪 Dispense Sequence</h3>
          <div style="display: flex; gap: 8px; align-items: center;">
            <label style="font-size: 11px; margin: 0;">Preset:</label>
            <select id="seq-preset" style="width: 180px; font-size: 12px;">
              <option value="Custom">Custom</option>
              <option value="~190 µL (47.5/nozzle)">~190 µL (47.5/nozzle)</option>
              <option value="~160 µL (40/nozzle)">~160 µL (40/nozzle)</option>
              <option value="~85 µL (21/nozzle)">~85 µL (21/nozzle)</option>
              <option value="~50 µL (12.5/nozzle)">~50 µL (12.5/nozzle)</option>
              <option value="~40 µL (10/nozzle)">~40 µL (10/nozzle)</option>
            </select>
            <label style="font-size: 11px; margin: 0;">SA:</label>
            <input type="number" id="seq-accel" value="${this.storage.getFluidicsSettings().seq_accelSteps}" min="0" max="2000" style="width: 60px; font-size: 12px;">
          </div>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; margin-bottom: 12px;">
          <!-- Prime -->
          <div style="background: #e8f5e9; padding: 10px; border-radius: 6px; border: 1px solid #4CAF50;">
            <label style="font-weight: 700; display: block; margin-bottom: 6px; color: #2e7d32;">PRIME</label>
            <div style="margin-bottom: 4px;"><label style="font-size: 11px;">Vol (µL):</label><input type="number" id="seq-prime-vol" value="${this.storage.getFluidicsSettings().seq_primeVol}" min="0" style="width: 100%;"></div>
            <div style="margin-bottom: 4px;"><label style="font-size: 11px;">Feedrate:</label><input type="number" id="seq-prime-f" value="${this.storage.getFluidicsSettings().seq_primeFeedrate}" min="0" style="width: 100%;"></div>
            <div><label style="font-size: 11px;">Delay (ms):</label><input type="number" id="seq-prime-delay" value="${this.storage.getFluidicsSettings().seq_primeDelayMs}" min="0" style="width: 100%;"></div>
            <div style="font-size: 10px; color: #666; margin-top: 4px;">0 = skip prime</div>
          </div>
          <!-- Main Dispense -->
          <div style="background: #e3f2fd; padding: 10px; border-radius: 6px; border: 1px solid #2196F3;">
            <label style="font-weight: 700; display: block; margin-bottom: 6px; color: #1565c0;">MAIN DISPENSE</label>
            <div style="margin-bottom: 4px;"><label style="font-size: 11px;">Vol (µL):</label><input type="number" id="seq-disp-vol" value="${this.storage.getFluidicsSettings().seq_dispVol}" min="0" style="width: 100%;"></div>
            <div style="margin-bottom: 4px;"><label style="font-size: 11px;">Feedrate:</label><input type="number" id="seq-disp-f" value="${this.storage.getFluidicsSettings().seq_dispFeedrate}" min="0" style="width: 100%;"></div>
            <div><label style="font-size: 11px;">Delay (ms):</label><input type="number" id="seq-disp-delay" value="${this.storage.getFluidicsSettings().seq_dispDelayMs}" min="0" style="width: 100%;"></div>
          </div>
          <!-- Retract -->
          <div style="background: #fff3e0; padding: 10px; border-radius: 6px; border: 1px solid #FF9800;">
            <label style="font-weight: 700; display: block; margin-bottom: 6px; color: #e65100;">RETRACT</label>
            <div style="margin-bottom: 4px;"><label style="font-size: 11px;">Vol (µL):</label><input type="number" id="seq-retract-vol" value="${this.storage.getFluidicsSettings().seq_retractVol}" min="0" style="width: 100%;"></div>
            <div style="margin-bottom: 4px;"><label style="font-size: 11px;">Feedrate:</label><input type="number" id="seq-retract-f" value="${this.storage.getFluidicsSettings().seq_retractFeedrate}" min="0" style="width: 100%;"></div>
            <div><label style="font-size: 11px;">Delay (ms):</label><input type="number" id="seq-retract-delay" value="${this.storage.getFluidicsSettings().seq_retractDelayMs}" min="0" style="width: 100%;"></div>
            <div style="font-size: 10px; color: #666; margin-top: 4px;">0 = skip retract</div>
          </div>
        </div>

        <!-- Live Preview -->
        <div style="background: #1e1e1e; color: #00ff00; padding: 8px 10px; border-radius: 4px; font-family: monospace; font-size: 11px; margin-bottom: 12px; word-break: break-all;">
          <span style="color: #888;">Preview:</span> <span id="seq-preview"></span>
        </div>

        <!-- Action Buttons -->
        <div style="display: flex; gap: 8px;">
          <button id="seq-dispense-now" class="btn" style="flex: 1; font-size: 13px;">⬇️ Dispense Now</button>
          <button id="seq-store-trigger" class="btn btn-secondary" style="flex: 1; font-size: 13px;">🎯 Store for Trigger</button>
          <button id="seq-clear" class="btn btn-danger" style="flex: 1; font-size: 13px;">🗑️ Clear Sequence</button>
        </div>
        <div id="seq-status" style="text-align: center; font-size: 11px; margin-top: 6px; min-height: 16px; transition: opacity 0.3s;"></div>
      </div>

      <!-- Valves -->
      <div class="section">
        <h3 class="section-title">🔄 Valve Control</h3>

        <!-- State Indicator -->
        <div id="valve-state-bar" style="background: #e0e0e0; padding: 10px; border-radius: 6px; margin-bottom: 12px; text-align: center; font-weight: 700; font-size: 14px; color: #555;">
          State: ${this.valveState || 'UNKNOWN'} &nbsp;|&nbsp; 5V: ${this.power5v ? '<span style="color:#4CAF50;">ON</span>' : '<span style="color:#999;">OFF</span>'}
        </div>

        <!-- Mask Selector -->
        <div style="margin-bottom: 12px;">
          <label style="font-weight: 600; margin-bottom: 6px; display: block;">Valve Mask</label>
          <div style="display: flex; gap: 8px; align-items: center;">
            <div style="display: flex; gap: 4px;">
              ${[1,2,3,4].map(n => `
                <button id="valve-toggle-${n}" class="btn btn-gray" style="width: 44px; font-size: 12px; padding: 6px 0; opacity: 1;" title="Valve ${n}">V${n}</button>
              `).join('')}
            </div>
            <input type="text" id="valve-mask" value="1111" maxlength="4" style="width: 60px; text-align: center; font-family: monospace; font-size: 14px; font-weight: 700;">
            <button id="valve-all" class="btn btn-gray" style="font-size: 11px; padding: 6px 10px;">All</button>
            <button id="valve-none" class="btn btn-gray" style="font-size: 11px; padding: 6px 10px;">None</button>
          </div>
        </div>

        <!-- Position Buttons -->
        <div class="btn-group" style="margin-bottom: 10px;">
          <button id="valve-input" class="btn" style="background: #2196F3; color: white;">INPUT (0°)</button>
          <button id="valve-output" class="btn" style="background: #4CAF50; color: white;">OUTPUT (90°)</button>
          <button id="valve-bypass" class="btn" style="background: #9e9e9e; color: white;">BYPASS (35°)</button>
          <button id="valve-flush" class="btn" style="background: #FF9800; color: white;">FLUSH (180°)</button>
        </div>

        <!-- 5V Controls -->
        <div style="display: flex; gap: 8px; margin-bottom: 10px;">
          <button id="valve-5v-on" class="btn" style="flex: 1; background: #4CAF50; color: white;">⚡ 5V ON</button>
          <button id="valve-5v-off" class="btn btn-danger" style="flex: 1;">🔌 5V OFF</button>
        </div>

        <!-- Timing -->
        <div style="display: flex; gap: 8px; margin-bottom: 10px;">
          <div style="flex: 1;">
            <label title="Wait after turnon5v before servo command (5V stabilize)">5V Stabilize (ms):</label>
            <input type="number" id="valve-delay-a" value="${this.storage.getFluidicsSettings().stabilizeMs}" min="0" style="width: 100%;">
          </div>
          <div style="flex: 1;">
            <label title="Wait after valve servo command before turnoff5v. Increase if valves don't reach target position. Range: 150ms (fast) to 3200ms (heavy load)">Valve Settle (ms):</label>
            <input type="number" id="valve-delay-b" value="${this.storage.getFluidicsSettings().valveSettleMs}" min="0" style="width: 100%;">
          </div>
        </div>

        <div style="padding: 8px; background: #fff3e0; border-radius: 4px; font-size: 11px;">
          <strong>Angles:</strong> INPUT=0° (aspirate) | OUTPUT=90° (dispense) | BYPASS=35° (closed) | FLUSH=180° (PCV direct)
          <br><strong>Timing:</strong> 5V stabilize (${this.storage.getFluidicsSettings().stabilizeMs}ms) + Valve settle (${this.storage.getFluidicsSettings().valveSettleMs}ms) = ~${this.storage.getFluidicsSettings().stabilizeMs + this.storage.getFluidicsSettings().valveSettleMs}ms total
        </div>
      </div>

      <!-- Pump Control -->
      <div class="section">
        <h3 class="section-title">🚰 Pump Control</h3>
        
        <!-- Wash Pump -->
        <div style="background: #e3f2fd; padding: 10px; border-radius: 4px; margin-bottom: 10px;">
          <label style="font-weight: 600; display: block; margin-bottom: 8px;">Wash Pump</label>
          <div class="btn-group" style="margin-bottom: 8px;">
            <button id="wash-on" class="btn" style="background: #4CAF50; color: white;">ON</button>
            <button id="wash-off" class="btn btn-danger">OFF</button>
          </div>
          <div style="display: flex; gap: 8px; align-items: center;">
            <label style="font-size: 12px; white-space: nowrap;">Speed:</label>
            <input type="number" id="wash-speed" value="255" min="0" max="255" style="width: 70px;">
            <button id="wash-set-speed" class="btn btn-secondary" style="font-size: 11px; padding: 6px 10px;">Set</button>
          </div>
        </div>

        <!-- Waste/Dry Pump -->
        <div style="background: #fff3e0; padding: 10px; border-radius: 4px; margin-bottom: 10px;">
          <label style="font-weight: 600; display: block; margin-bottom: 8px;">Waste/Dry Pump</label>
          <div class="btn-group" style="margin-bottom: 8px;">
            <button id="waste-on" class="btn" style="background: #FF9800; color: white;">ON</button>
            <button id="waste-off" class="btn btn-danger">OFF</button>
          </div>
          <div style="display: flex; gap: 8px; align-items: center;">
            <label style="font-size: 12px; white-space: nowrap;">Speed:</label>
            <input type="number" id="waste-speed" value="255" min="0" max="255" style="width: 70px;">
            <button id="waste-set-speed" class="btn btn-secondary" style="font-size: 11px; padding: 6px 10px;">Set</button>
          </div>
        </div>

        <!-- PCV Control -->
        <div style="background: #f3e5f5; padding: 10px; border-radius: 4px;">
          <label style="font-weight: 600; display: block; margin-bottom: 8px;">Pressure Compensation Vessel</label>
          <div class="btn-group" style="margin-bottom: 8px;">
            <button id="feedback-pcv" class="btn" style="background: #9C27B0; color: white;">Feedback</button>
            <button id="manual-pcv" class="btn btn-warning">Manual</button>
          </div>
          <div style="display: flex; gap: 8px; align-items: center;">
            <label style="font-size: 12px; white-space: nowrap;">Speed:</label>
            <input type="number" id="pcv-speed" value="255" min="0" max="255" style="width: 70px;">
            <button id="pcv-set-speed" class="btn btn-secondary" style="font-size: 11px; padding: 6px 10px;">Set</button>
          </div>
        </div>
      </div>

      <!-- Touch Drypad -->
      <div class="section">
        <h3 class="section-title">🔸 Touch Drypad</h3>
        <button id="touch-dry" class="btn btn-purple" style="width: 100%; margin-bottom: 10px;">Touch Drypad</button>
        <div style="display: flex; gap: 8px;">
          <input type="number" id="drypad-position" value="1" min="1" max="210" style="flex: 1;" placeholder="Grid position">
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
    
    // Show macro name if selected, otherwise just show icon + label
    const washLabel = washMacro ? `🧼 Wash (${washMacro})` : '🧼 Wash';
    const wasteLabel = wasteMacro ? `🗑️ Waste (${wasteMacro})` : '🗑️ Waste';
    
    const washTitle = washMacro ? `Run macro: ${washMacro}` : 'Run GO_WASH command';
    const wasteTitle = wasteMacro ? `Run macro: ${wasteMacro}` : 'Run GO_WASTE command';
    
    return `
      <div class="btn-group">
        <button id="go-wash" class="btn btn-secondary" style="flex: 1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="${washTitle}">${washLabel}</button>
        <button id="go-waste" class="btn btn-warning" style="flex: 1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="${wasteTitle}">${wasteLabel}</button>
      </div>
    `;
  }

  renderTipEditor() {
    const tip = this.tips[this.selectedTipIndex];
    const savedMacros = this.storage.getMacros();
    
    const renderMacroSelect = (currentMacro) => {
      return `
        <select style="width: 100%;" class="tip-macro-select">
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
        <div style="display: flex; gap: 10px; align-items: center; margin-bottom: 10px;">
          <div style="flex: 1; display: flex; gap: 5px;">
            <div style="flex: 1;"><label>X:</label><input type="number" id="tip-drypad-x" value="${tip.drypad_x || 92.0}" step="0.1" style="width: 100%;"></div>
            <div style="flex: 1;"><label>Y:</label><input type="number" id="tip-drypad-y" value="${tip.drypad_y || 335.0}" step="0.1" style="width: 100%;"></div>
            <div style="flex: 1;"><label>Z:</label><input type="number" id="tip-drypad-z" value="${tip.drypad_z}" step="0.1" style="width: 100%;"></div>
          </div>
          <div style="border-left: 2px solid #ddd; padding-left: 10px; flex: 1; display: flex; gap: 5px;">
            <div style="flex: 1;"><label>Move°:</label><input type="number" id="tip-drypad-servo-move" value="${tip.drypad_servo_move || 0}" min="0" max="180" style="width: 100%;"></div>
            <div style="flex: 1;"><label>Touch°:</label><input type="number" id="tip-drypad-servo-touch" value="${tip.drypad_servo_touch || 115}" min="0" max="180" style="width: 100%;"></div>
          </div>
          <div style="border-left: 2px solid #ddd; padding-left: 10px; flex: 1; display: flex; gap: 5px;">
            <div style="flex: 1;"><label>Time (ms):</label><input type="number" id="tip-drypad-time" value="${tip.drypad_time}" style="width: 100%;"></div>
            <div style="flex: 1;"><label>Delay (ms):</label><input type="number" id="tip-drypad-delay" value="${tip.drypad_delay || 2000}" step="100" style="width: 100%;"></div>
          </div>
        </div>

        <h4 style="color: #2196F3; margin: 15px 0 10px 0;">🧼 WASH</h4>
        <div style="display: flex; gap: 10px; align-items: center; margin-bottom: 5px;">
          <div style="flex: 1; display: flex; gap: 5px;">
            <div style="flex: 1;"><label>X:</label><input type="number" id="tip-wash-x" value="${tip.wash_x}" step="0.1" style="width: 100%;"></div>
            <div style="flex: 1;"><label>Y:</label><input type="number" id="tip-wash-y" value="${tip.wash_y}" step="0.1" style="width: 100%;"></div>
            <div style="flex: 1;"><label>Z:</label><input type="number" id="tip-wash-z" value="${tip.wash_z}" step="0.1" style="width: 100%;"></div>
          </div>
          <div style="border-left: 2px solid #ddd; padding-left: 10px; flex: 1; display: flex; gap: 5px;">
            <div style="flex: 1;"><label>Move°:</label><input type="number" id="tip-wash-servo-move" value="${tip.wash_servo_move || 0}" min="0" max="180" style="width: 100%;"></div>
            <div style="flex: 1;"><label>Wash°:</label><input type="number" id="tip-wash-servo-wash" value="${tip.wash_servo_wash || tip.wash_servo || 120}" min="0" max="180" style="width: 100%;"></div>
          </div>
        </div>
        <div style="margin-bottom: 10px;">
          <label>Macro:</label>
          <div id="wash-macro-select">${renderMacroSelect(tip.wash_macro || "")}</div>
          <div id="wash-macro-select-holder" style="display:none;">${tip.wash_macro || ""}</div>
        </div>

        <h4 style="color: #ff9800; margin: 15px 0 10px 0;">🗑️ WASTE</h4>
        <div style="display: flex; gap: 10px; align-items: center; margin-bottom: 5px;">
          <div style="flex: 1; display: flex; gap: 5px;">
            <div style="flex: 1;"><label>X:</label><input type="number" id="tip-waste-x" value="${tip.waste_x}" step="0.1" style="width: 100%;"></div>
            <div style="flex: 1;"><label>Y:</label><input type="number" id="tip-waste-y" value="${tip.waste_y}" step="0.1" style="width: 100%;"></div>
            <div style="flex: 1;"><label>Z:</label><input type="number" id="tip-waste-z" value="${tip.waste_z}" step="0.1" style="width: 100%;"></div>
          </div>
          <div style="border-left: 2px solid #ddd; padding-left: 10px; flex: 1; display: flex; gap: 5px;">
            <div style="flex: 1;"><label>Move°:</label><input type="number" id="tip-waste-servo-move" value="${tip.waste_servo_move || 0}" min="0" max="180" style="width: 100%;"></div>
            <div style="flex: 1;"><label>Waste°:</label><input type="number" id="tip-waste-servo-waste" value="${tip.waste_servo_waste || tip.waste_servo || 170}" min="0" max="180" style="width: 100%;"></div>
          </div>
        </div>
        <div style="margin-bottom: 10px;">
          <label>Macro:</label>
          <div id="waste-macro-select">${renderMacroSelect(tip.waste_macro || "")}</div>
          <div id="waste-macro-select-holder" style="display:none;">${tip.waste_macro || ""}</div>
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
    container.querySelector('#set-height')?.addEventListener('click', async () => {
      const angle = document.getElementById('servo-angle').value;
      await this.api.sendGcode(`LINEARACTSERVOMOVE ANGLE=${angle} HOLD=1000`);
      // Wait for macro to complete and save position, then refresh display
      setTimeout(() => this.updateServoPosition(), 2000);
    });
    
    container.querySelector('#preset-0')?.addEventListener('click', async () => {
      await this.setPresetAngle(0);
      setTimeout(() => this.updateServoPosition(), 1500);
    });
    container.querySelector('#preset-90')?.addEventListener('click', async () => {
      await this.setPresetAngle(90);
      setTimeout(() => this.updateServoPosition(), 1500);
    });
    container.querySelector('#preset-180')?.addEventListener('click', async () => {
      await this.setPresetAngle(180);
      setTimeout(() => this.updateServoPosition(), 1500);
    });
    container.querySelector('#servo-off')?.addEventListener('click', () => {
      this.api.sendGcode('LINEARACTSERVOOFF');
    });
    container.querySelector('#refresh-servo')?.addEventListener('click', () => {
      this.updateServoPosition();
    });

    // Syringe pump - Arduino controller
    container.querySelector('#aspirate')?.addEventListener('click', () => this.aspirate());
    container.querySelector('#dispense')?.addEventListener('click', () => this.dispense());
    container.querySelector('#estop')?.addEventListener('click', () => this.api.sendGcode('SEND_PUMP_ARDUINO COMMAND="P0"'));
    container.querySelector('#clear-estop')?.addEventListener('click', () => this.api.sendGcode('SEND_PUMP_ARDUINO COMMAND="P999"'));
    container.querySelector('#motor-on')?.addEventListener('click', () => this.api.sendGcode('SEND_PUMP_ARDUINO COMMAND="MOTORON"'));
    container.querySelector('#motor-off')?.addEventListener('click', () => this.api.sendGcode('SEND_PUMP_ARDUINO COMMAND="MOTOROFF"'));
    container.querySelector('#trigger-on')?.addEventListener('click', () => {
      this.api.sendGcode('SEND_PUMP_ARDUINO COMMAND="TRIGGERON"');
      this.triggerArmed = true;
      this.updateTriggerUI();
    });
    container.querySelector('#trigger-off')?.addEventListener('click', () => {
      this.api.sendGcode('SEND_PUMP_ARDUINO COMMAND="TRIGGEROFF"');
      this.triggerArmed = false;
      this.updateTriggerUI();
    });
    container.querySelector('#trigger-fire')?.addEventListener('click', () => {
      this.api.sendGcode('TRIGGER_FIRE');
    });
    container.querySelector('#pump-status')?.addEventListener('click', async () => {
      await this.queryPumpStatus();
    });

    // Acceleration ramp controls
    container.querySelector('#apply-accel')?.addEventListener('click', () => {
      const steps = document.getElementById('accel-steps').value;
      this.api.sendGcode(`SEND_PUMP_ARDUINO COMMAND="SA ${steps}"`);
      this.pumpAccelSteps = parseInt(steps);
      this.saveSetting('accelSteps', parseInt(steps));
      // Update current display
      const currentDisplay = document.getElementById('accel-current');
      if (currentDisplay) {
        currentDisplay.textContent = `Current: ${steps}`;
      }
    });

    // Reset settings button
    container.querySelector('#reset-settings')?.addEventListener('click', async () => {
      if (confirm('Reset all pump and valve settings to factory defaults?')) {
        await this.storage.resetFluidicsSettings();
        this.loadSettings();
        this.render();
        alert('Settings reset to defaults. Page will reload.');
      }
    });

    // Dispense Sequence controls
    this.initSequencePanel(container);

    // Auto-save all input fields when they change
    this.setupAutoSaveListeners(container);

    // Valve controls
    container.querySelector('#valve-all')?.addEventListener('click', () => this.setValveMask('1111'));
    container.querySelector('#valve-none')?.addEventListener('click', () => this.setValveMask('0000'));
    container.querySelector('#valve-input')?.addEventListener('click', () => this.setValves('INPUT'));
    container.querySelector('#valve-output')?.addEventListener('click', () => this.setValves('OUTPUT'));
    container.querySelector('#valve-bypass')?.addEventListener('click', () => this.setValves('BYPASS'));
    container.querySelector('#valve-flush')?.addEventListener('click', () => this.setValves('FLUSH'));
    container.querySelector('#valve-5v-on')?.addEventListener('click', () => {
      this.api.sendGcode('SEND_ARDUINO COMMAND="turnon5v"');
      this.power5v = true;
      this.updateValveStateUI();
    });
    container.querySelector('#valve-5v-off')?.addEventListener('click', () => {
      this.api.sendGcode('SEND_ARDUINO COMMAND="turnoff5v"');
      this.power5v = false;
      this.updateValveStateUI();
    });
    // Valve toggle buttons
    [1,2,3,4].forEach(n => {
      container.querySelector(`#valve-toggle-${n}`)?.addEventListener('click', () => this.toggleValveBit(n));
    });
    // Mask text input sync
    container.querySelector('#valve-mask')?.addEventListener('input', () => this.syncTogglesFromMask());

    // Initialize valve toggle button visuals
    this.syncTogglesFromMask();

    // Pump controls
    container.querySelector('#wash-on')?.addEventListener('click', () => {
      this.api.sendGcode('WASH_ON');
    });
    container.querySelector('#wash-off')?.addEventListener('click', () => {
      this.api.sendGcode('WASH_OFF');
    });
    container.querySelector('#wash-set-speed')?.addEventListener('click', () => {
      const speed = document.getElementById('wash-speed').value;
      this.api.sendGcode(`SET_WASH_SPEED SPEED=${speed}`);
    });
    
    container.querySelector('#waste-on')?.addEventListener('click', () => {
      this.api.sendGcode('WASTE_ON');
    });
    container.querySelector('#waste-off')?.addEventListener('click', () => {
      this.api.sendGcode('WASTE_OFF');
    });
    container.querySelector('#waste-set-speed')?.addEventListener('click', () => {
      const speed = document.getElementById('waste-speed').value;
      this.api.sendGcode(`SET_DRY_SPEED SPEED=${speed}`);
    });
    
    container.querySelector('#feedback-pcv')?.addEventListener('click', () => {
      this.api.sendGcode('FEEDBACK_PCV');
    });
    container.querySelector('#manual-pcv')?.addEventListener('click', () => {
      this.api.sendGcode('MANUAL_PCV');
    });
    container.querySelector('#pcv-set-speed')?.addEventListener('click', () => {
      const speed = document.getElementById('pcv-speed').value;
      this.api.sendGcode(`SET_PCV_SPEED SPEED=${speed}`);
    });

    // Touch Drypad buttons
    container.querySelector('#touch-dry')?.addEventListener('click', () => {
      console.log('TOUCH_DRY button clicked, sending command: TOUCH_DRY');
      this.api.sendGcode('TOUCH_DRY');
    });
    
    container.querySelector('#touch-dry-at')?.addEventListener('click', () => {
      const pos = document.getElementById('drypad-position').value;
      console.log(`TOUCH_DRY_AT button clicked, sending command: TOUCH_DRY_AT KEY=${pos}`);
      this.api.sendGcode(`TOUCH_DRY_AT KEY=${pos}`);
    });

    // Quick actions
    this.attachQuickActionListeners();
  }

  setupAutoSaveListeners(container) {
    // Map of input IDs to storage keys
    const fieldMappings = {
      'syringe-steps': 'pumpVolume',
      'syringe-feedrate': 'pumpFeedrate',
      'accel-steps': 'accelSteps',
      'valve-mask': 'valveMask',
      'valve-delay-a': 'stabilizeMs',
      'valve-delay-b': 'valveSettleMs',
      'seq-accel': 'seq_accelSteps'
    };

    // Add change listeners to all mapped fields
    Object.keys(fieldMappings).forEach(fieldId => {
      const element = container.querySelector(`#${fieldId}`);
      if (element) {
        element.addEventListener('change', () => {
          const value = element.type === 'number' ? parseFloat(element.value) : element.value;
          this.saveSetting(fieldMappings[fieldId], value);
        });
      }
    });
  }

  async queryPumpStatus() {
    // Query the Arduino for status
    await this.api.sendGcode('SEND_PUMP_ARDUINO COMMAND="P114"');

    // Wait a bit for response, then try to fetch and parse it
    // Note: In a real implementation, you'd need to poll the Klipper console output
    // or have a mechanism to capture the Arduino's response
    setTimeout(() => {
      // For now, just update the display to show we queried
      const statusDisplay = document.getElementById('pump-status-text');
      if (statusDisplay) {
        statusDisplay.innerHTML = 'Status queried - check Klipper console for response<br>Format: vol=X rate=X delay=X armed=X motor=X dir=X estop=X accel=X steps_ul=X';
      }
    }, 500);

    // TODO: Implement actual response parsing when Arduino serial response is captured
    // For now, this is a placeholder. The full implementation would need:
    // 1. Capture serial output from Klipper's RESPOND command
    // 2. Parse the P114 response line
    // 3. Extract accel= value and update the display
  }

  parsePumpStatus(response) {
    // Parse P114 response format: "vol=50.00 rate=4000 delay=50 armed=1 motor=1 dir=disp estop=0 accel=500 steps_ul=130.4 ok"
    const params = {};
    const tokens = response.split(/\s+/);

    tokens.forEach(token => {
      const [key, value] = token.split('=');
      if (key && value) {
        params[key] = value;
      }
    });

    // Update acceleration display if present
    if (params.accel !== undefined) {
      this.pumpAccelSteps = parseInt(params.accel);
      const currentDisplay = document.getElementById('accel-current');
      if (currentDisplay) {
        currentDisplay.textContent = `Current: ${params.accel}`;
      }
    }

    // Update status display
    const statusDisplay = document.getElementById('pump-status-text');
    if (statusDisplay) {
      statusDisplay.innerHTML = `
        <strong>Vol:</strong> ${params.vol || '?'} µL |
        <strong>Rate:</strong> ${params.rate || '?'} |
        <strong>Delay:</strong> ${params.delay || '?'}ms |
        <strong>Accel:</strong> ${params.accel || '?'}<br>
        <strong>Armed:</strong> ${params.armed === '1' ? 'YES' : 'NO'} |
        <strong>Motor:</strong> ${params.motor === '1' ? 'ON' : 'OFF'} |
        <strong>Dir:</strong> ${params.dir || '?'} |
        <strong>E-Stop:</strong> ${params.estop === '1' ? 'YES' : 'NO'}
      `;
    }

    return params;
  }

  attachQuickActionListeners() {
    const container = document.getElementById('fluidics-content');
    
    container.querySelector('#go-wash')?.addEventListener('click', async () => {
      const savedMacros = this.storage.getMacros();
      const washGcode = savedMacros.find(m => m.name === 'wash.gcode');
      const activeTip = this.tips[this.activeTipIndex];
      
      // ALWAYS move to wash position first
      await this.api.sendGcode('GO_WASH_STATION');
      
      // Then run macro if one is assigned
      if (washGcode) {
        await this.runMacro('wash.gcode');
      } else if (activeTip && activeTip.wash_macro) {
        await this.runMacro(activeTip.wash_macro);
      }
      // If no macro, just the movement is enough
    });
    
    container.querySelector('#go-waste')?.addEventListener('click', async () => {
      const savedMacros = this.storage.getMacros();
      const wasteGcode = savedMacros.find(m => m.name === 'waste.gcode');
      const activeTip = this.tips[this.activeTipIndex];
      
      // ALWAYS move to waste position first
      await this.api.sendGcode('GO_WASTE_STATION');
      
      // Then run macro if one is assigned
      if (wasteGcode) {
        await this.runMacro('waste.gcode');
      } else if (activeTip && activeTip.waste_macro) {
        await this.runMacro(activeTip.waste_macro);
      }
      // If no macro, just the movement is enough
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
      return;  // No tip selected to clone
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
      return;  // No tip selected to delete
    }

    if (this.selectedTipIndex === 0) {
      return;  // Cannot delete the first tip
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
      'tip-name', 
      'tip-drypad-x', 'tip-drypad-y', 'tip-drypad-z', 'tip-drypad-servo-move', 'tip-drypad-servo-touch', 'tip-drypad-time', 'tip-drypad-delay',
      'tip-wash-x', 'tip-wash-y', 'tip-wash-z', 'tip-wash-servo-move', 'tip-wash-servo-wash',
      'tip-waste-x', 'tip-waste-y', 'tip-waste-z', 'tip-waste-servo-move', 'tip-waste-servo-waste'
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
    tip.drypad_x = parseFloat(c.querySelector('#tip-drypad-x')?.value || tip.drypad_x || 92.0);
    tip.drypad_y = parseFloat(c.querySelector('#tip-drypad-y')?.value || tip.drypad_y || 335.0);
    tip.drypad_z = parseFloat(c.querySelector('#tip-drypad-z')?.value || tip.drypad_z);
    tip.drypad_servo_move = parseInt(c.querySelector('#tip-drypad-servo-move')?.value || 0);
    tip.drypad_servo_touch = parseInt(c.querySelector('#tip-drypad-servo-touch')?.value || 115);
    tip.drypad_time = parseInt(c.querySelector('#tip-drypad-time')?.value || tip.drypad_time);
    tip.drypad_delay = parseInt(c.querySelector('#tip-drypad-delay')?.value || 2000);
    
    tip.wash_x = parseFloat(c.querySelector('#tip-wash-x')?.value || tip.wash_x);
    tip.wash_y = parseFloat(c.querySelector('#tip-wash-y')?.value || tip.wash_y);
    tip.wash_z = parseFloat(c.querySelector('#tip-wash-z')?.value || tip.wash_z);
    tip.wash_servo_move = parseInt(c.querySelector('#tip-wash-servo-move')?.value || 0);
    tip.wash_servo_wash = parseInt(c.querySelector('#tip-wash-servo-wash')?.value || 120);
    
    tip.waste_x = parseFloat(c.querySelector('#tip-waste-x')?.value || tip.waste_x);
    tip.waste_y = parseFloat(c.querySelector('#tip-waste-y')?.value || tip.waste_y);
    tip.waste_z = parseFloat(c.querySelector('#tip-waste-z')?.value || tip.waste_z);
    tip.waste_servo_move = parseInt(c.querySelector('#tip-waste-servo-move')?.value || 0);
    tip.waste_servo_waste = parseInt(c.querySelector('#tip-waste-servo-waste')?.value || 170);
    
    // Get macro selects by ID to ensure correct order
    const washMacroSelect = c.querySelector('#wash-macro-select select');
    const wasteMacroSelect = c.querySelector('#waste-macro-select select');
    tip.wash_macro = washMacroSelect?.value || "";
    tip.waste_macro = wasteMacroSelect?.value || "";

    await this.storage.setTips(this.tips);
    await this.saveAllTipsToKlipper();
    
    // If this is the active tip, also sync all station variables
    if (this.selectedTipIndex === this.activeTipIndex) {
      await this.saveAllStationVariables();
      
      // Re-render Quick Actions section to show updated macro names
      const quickActionsSection = document.querySelector('.section:has(#go-wash)');
      if (quickActionsSection) {
        const sectionTitle = quickActionsSection.querySelector('.section-title');
        const newContent = this.renderQuickActionButtons();
        
        // Clear old content but keep title
        while (quickActionsSection.firstChild) {
          quickActionsSection.removeChild(quickActionsSection.firstChild);
        }
        
        // Add title back
        if (sectionTitle) {
          quickActionsSection.appendChild(sectionTitle.cloneNode(true));
        }
        
        // Add new buttons
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = newContent;
        while (tempDiv.firstChild) {
          quickActionsSection.appendChild(tempDiv.firstChild);
        }
        
        // Re-attach event listeners
        this.attachQuickActionListeners();
      }
    }
    
    console.log('Auto-saved tip:', tip.name, 'wash_macro:', tip.wash_macro, 'waste_macro:', tip.waste_macro);
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
    
    // Get macro selects by ID to ensure correct order
    const washMacroSelect = c.querySelector('#wash-macro-select select');
    const wasteMacroSelect = c.querySelector('#waste-macro-select select');
    tip.wash_macro = washMacroSelect?.value || "";
    tip.waste_macro = wasteMacroSelect?.value || "";
    
    tip.waste_x = parseFloat(c.querySelector('#tip-waste-x').value);
    tip.waste_y = parseFloat(c.querySelector('#tip-waste-y').value);
    tip.waste_z = parseFloat(c.querySelector('#tip-waste-z').value);
    tip.waste_servo = parseInt(c.querySelector('#tip-waste-servo').value);

    await this.storage.setTips(this.tips);
    await this.saveAllTipsToKlipper();
    
    this.render();
  }

  async setActiveTip() {
    const select = document.getElementById('active-tip-select');
    this.activeTipIndex = parseInt(select.value);
    await this.storage.setActiveTipIndex(this.activeTipIndex);
    await this.api.sendGcode(`SELECT_TIP TIP=${this.activeTipIndex}`);
    
    // Sync all station variables for the new active tip
    await this.saveAllStationVariables();
    
    
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
  }

  aspirate() {
    const vol = document.getElementById('syringe-steps').value;
    const feedrate = document.getElementById('syringe-feedrate').value;
    this.api.sendGcode(`SEND_PUMP_ARDUINO COMMAND="A1 E${vol} F${feedrate}"`);
    this.saveSetting('pumpVolume', parseFloat(vol));
    this.saveSetting('pumpFeedrate', parseInt(feedrate));
  }

  dispense() {
    const vol = document.getElementById('syringe-steps').value;
    const feedrate = document.getElementById('syringe-feedrate').value;
    this.api.sendGcode(`SEND_PUMP_ARDUINO COMMAND="D1 E${vol} F${feedrate}"`);
    this.saveSetting('pumpVolume', parseFloat(vol));
    this.saveSetting('pumpFeedrate', parseInt(feedrate));
  }

  updateTriggerUI() {
    const status = document.getElementById('trigger-status');
    const fireContainer = document.getElementById('trigger-fire-container');
    if (status) {
      status.textContent = this.triggerArmed ? 'Trigger: ARMED' : 'Trigger: OFF';
      status.style.color = this.triggerArmed ? '#2e7d32' : '#e65100';
    }
    if (fireContainer) {
      fireContainer.style.display = this.triggerArmed ? 'block' : 'none';
    }
  }

  async updateSyringePosition() {
    // Syringe pump is now controlled by Arduino - no Klipper position to read
  }

  async updateServoPosition() {
    try {
      // Read from save_variables (variables.cfg) for tracked servo position
      const endpoint = this.api.activeEndpoint || 'http://192.168.1.89:7125';
      const response = await fetch(`${endpoint}/printer/objects/query?save_variables`);
      const data = await response.json();

      let servoPosition = 0;
      if (data && data.result && data.result.status && data.result.status.save_variables) {
        const variables = data.result.status.save_variables.variables;
        if (variables && variables.linearactuator_servo_position !== undefined) {
          servoPosition = variables.linearactuator_servo_position;
        }
      }

      // Update the display and input field
      const servoAngleInput = document.getElementById('servo-angle');
      const servoPositionDisplay = document.getElementById('servo-position-display');

      if (servoAngleInput) {
        servoAngleInput.value = servoPosition;
      }
      if (servoPositionDisplay) {
        servoPositionDisplay.textContent = `${servoPosition}°`;
      }
    } catch (error) {
      console.error('Error fetching servo position:', error);
    }
  }

  async updateAllPositions() {
    await this.updateSyringePosition();
    await this.updateServoPosition();
  }

  getValveMask() {
    return document.getElementById('valve-mask')?.value || '1111';
  }

  setValveMask(mask) {
    const el = document.getElementById('valve-mask');
    if (el) el.value = mask;
    this.syncTogglesFromMask();
  }

  toggleValveBit(n) {
    const mask = this.getValveMask().split('');
    mask[n - 1] = mask[n - 1] === '1' ? '0' : '1';
    this.setValveMask(mask.join(''));
  }

  syncTogglesFromMask() {
    const mask = this.getValveMask();
    [1,2,3,4].forEach(n => {
      const btn = document.getElementById(`valve-toggle-${n}`);
      if (btn) {
        const on = mask[n - 1] === '1';
        btn.style.background = on ? '#667eea' : '#bdbdbd';
        btn.style.color = 'white';
      }
    });
  }

  selectAllValves(state) {
    this.setValveMask(state ? '1111' : '0000');
  }

  setValves(mode) {
    const mask = this.getValveMask();
    if (mask === '0000') return;
    const delayA = document.getElementById('valve-delay-a')?.value || '50';
    const delayB = document.getElementById('valve-delay-b')?.value || '3200';
    const sequence = [
      'SEND_ARDUINO COMMAND="turnon5v"',
      `G4 P${delayA}`,
      `VALVE_${mode} MASK=${mask}`,
      `G4 P${delayB}`,
      'SEND_ARDUINO COMMAND="turnoff5v"'
    ].join('\n');
    this.api.sendGcode(sequence);
    this.valveState = mode;
    this.updateValveStateUI();

    // Save valve timing settings
    this.saveSetting('stabilizeMs', parseInt(delayA));
    this.saveSetting('valveSettleMs', parseInt(delayB));
    this.saveSetting('valveMask', mask);
  }

  updateValveStateUI() {
    const bar = document.getElementById('valve-state-bar');
    if (!bar) return;
    const colors = { INPUT: '#2196F3', OUTPUT: '#4CAF50', BYPASS: '#9e9e9e', FLUSH: '#FF9800', UNKNOWN: '#555' };
    const color = colors[this.valveState] || '#555';
    bar.innerHTML = `State: <span style="color:${color};">${this.valveState}</span> &nbsp;|&nbsp; 5V: ${this.power5v ? '<span style="color:#4CAF50;">ON</span>' : '<span style="color:#999;">OFF</span>'}`;
  }

  async saveDrypadSettings() {
    const drypadX = parseFloat(document.getElementById('drypad-x')?.value || 92.0);
    const drypadY = parseFloat(document.getElementById('drypad-y')?.value || 335.0);
    const drypadZ = parseFloat(document.getElementById('drypad-z')?.value || 70.0);
    const servoMove = parseInt(document.getElementById('drypad-servo-move')?.value || 0);
    const servoTouch = parseInt(document.getElementById('drypad-servo-touch')?.value || 115);
    const time = parseInt(document.getElementById('drypad-time')?.value || 3000);
    const delayTime = parseInt(document.getElementById('drypad-delay-time')?.value || 2000);
    
    // Save to active tip
    if (this.tips[this.activeTipIndex]) {
      this.tips[this.activeTipIndex].drypad_x = drypadX;
      this.tips[this.activeTipIndex].drypad_y = drypadY;
      this.tips[this.activeTipIndex].drypad_z = drypadZ;
      this.tips[this.activeTipIndex].drypad_servo_move = servoMove;
      this.tips[this.activeTipIndex].drypad_servo_touch = servoTouch;
      this.tips[this.activeTipIndex].drypad_time = time;
      this.tips[this.activeTipIndex].drypad_delay = delayTime;
      
      await this.storage.setTips(this.tips);
      await this.saveAllTipsToKlipper();
      
      // Also save to standalone variables for active tip
      await this.saveAllStationVariables();
      
      console.log('Auto-saved drypad settings:', { drypadX, drypadY, drypadZ, servoMove, servoTouch, time, delayTime });
    }
  }

  async saveAllStationVariables() {
    const activeTip = this.tips[this.activeTipIndex];
    if (!activeTip) {
      console.warn('No active tip found');
      return;
    }

    // Save all drypad variables
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=drypad_x VALUE=${activeTip.drypad_x || 92.0}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=drypad_y VALUE=${activeTip.drypad_y || 335.0}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=drypad_z VALUE=${activeTip.drypad_z}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=drypad_servo_move VALUE=${activeTip.drypad_servo_move || 0}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=drypad_servo_touch VALUE=${activeTip.drypad_servo_touch || 115}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=drypad_time VALUE=${activeTip.drypad_time || 3000}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=drypad_delay VALUE=${activeTip.drypad_delay || 2000}`);

    // Save all wash variables
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=wash_x VALUE=${activeTip.wash_x}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=wash_y VALUE=${activeTip.wash_y}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=wash_z VALUE=${activeTip.wash_z}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=wash_servo_move VALUE=${activeTip.wash_servo_move || 0}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=wash_servo_wash VALUE=${activeTip.wash_servo_wash || 120}`);

    // Save all waste variables
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=waste_x VALUE=${activeTip.waste_x}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=waste_y VALUE=${activeTip.waste_y}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=waste_z VALUE=${activeTip.waste_z}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=waste_servo_move VALUE=${activeTip.waste_servo_move || 0}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=waste_servo_waste VALUE=${activeTip.waste_servo_waste || 170}`);

    // Save all eject variables
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=eject_x VALUE=${activeTip.eject_x}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=eject_y VALUE=${activeTip.eject_y}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=eject_z VALUE=${activeTip.eject_z}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=eject_servo_move VALUE=${activeTip.eject_servo_move || 0}`);
    await this.api.sendGcode(`SAVE_VARIABLE VARIABLE=eject_servo_eject VALUE=${activeTip.eject_servo_eject || 150}`);

    console.log('All station variables saved to Klipper for tip:', activeTip.name);
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

  // ── Dispense Sequence ──────────────────────────────────────────

  static SEQ_PRESETS = [
    { label: 'Custom' },
    { label: '~190 µL (47.5/nozzle)', primeVol:50, dispVol:120, retractVol:120 },
    { label: '~160 µL (40/nozzle)',   primeVol:40, dispVol:90,  retractVol:90  },
    { label: '~85 µL (21/nozzle)',    primeVol:20, dispVol:80,  retractVol:80  },
    { label: '~50 µL (12.5/nozzle)',  primeVol:20, dispVol:70,  retractVol:80  },
    { label: '~40 µL (10/nozzle)',    primeVol:20, dispVol:50,  retractVol:60  },
  ];

  initSequencePanel(container) {
    const ids = ['seq-prime-vol','seq-prime-f','seq-prime-delay',
                 'seq-disp-vol','seq-disp-f','seq-disp-delay',
                 'seq-retract-vol','seq-retract-f','seq-retract-delay','seq-accel'];
    const storageKeys = ['seq_primeVol','seq_primeFeedrate','seq_primeDelayMs',
                         'seq_dispVol','seq_dispFeedrate','seq_dispDelayMs',
                         'seq_retractVol','seq_retractFeedrate','seq_retractDelayMs','seq_accelSteps'];

    // Live update preview + save + switch to Custom on any field edit
    ids.forEach((id, i) => {
      const el = container.querySelector(`#${id}`);
      if (!el) return;
      const handler = () => {
        const v = parseFloat(el.value) || 0;
        this.saveSetting(storageKeys[i], v);
        this.updateSeqPreview();
        // Switch preset to Custom when user edits a field
        const presetEl = container.querySelector('#seq-preset');
        if (presetEl && presetEl.value !== 'Custom') {
          presetEl.value = 'Custom';
          this.saveSetting('seq_lastPreset', 'Custom');
        }
      };
      el.addEventListener('input', handler);
    });

    // Preset dropdown
    const presetEl = container.querySelector('#seq-preset');
    if (presetEl) {
      // Restore last preset selection
      presetEl.value = this.storage.getFluidicsSettings().seq_lastPreset || 'Custom';
      presetEl.addEventListener('change', () => {
        const preset = FluidicsControl.SEQ_PRESETS.find(p => p.label === presetEl.value);
        if (preset && preset.primeVol !== undefined) {
          const fieldMap = {
            'seq-prime-vol': preset.primeVol,
            'seq-disp-vol': preset.dispVol,
            'seq-retract-vol': preset.retractVol,
            'seq-prime-f': 10000, 'seq-prime-delay': 1000,
            'seq-disp-f': 14000, 'seq-disp-delay': 500,
            'seq-retract-f': 6000, 'seq-retract-delay': 100,
          };
          Object.entries(fieldMap).forEach(([fid, val]) => {
            const el = container.querySelector(`#${fid}`);
            if (el) el.value = val;
          });
          // Save all preset values
          const keyMap = {
            'seq-prime-vol':'seq_primeVol','seq-prime-f':'seq_primeFeedrate','seq-prime-delay':'seq_primeDelayMs',
            'seq-disp-vol':'seq_dispVol','seq-disp-f':'seq_dispFeedrate','seq-disp-delay':'seq_dispDelayMs',
            'seq-retract-vol':'seq_retractVol','seq-retract-f':'seq_retractFeedrate','seq-retract-delay':'seq_retractDelayMs',
          };
          Object.entries(keyMap).forEach(([fid, sk]) => {
            this.saveSetting(sk, fieldMap[fid]);
          });
        }
        this.saveSetting('seq_lastPreset', presetEl.value);
        this.updateSeqPreview();
      });
    }

    // Action buttons
    container.querySelector('#seq-dispense-now')?.addEventListener('click', () => this.seqDispenseNow());
    container.querySelector('#seq-store-trigger')?.addEventListener('click', () => this.seqStoreTrigger());
    container.querySelector('#seq-clear')?.addEventListener('click', () => this.seqClear());

    // Initial preview
    this.updateSeqPreview();
  }

  getSeqValues() {
    return {
      primeVol:      parseFloat(document.getElementById('seq-prime-vol')?.value) || 0,
      primeFeedrate: parseFloat(document.getElementById('seq-prime-f')?.value) || 10000,
      primeDelayMs:  parseFloat(document.getElementById('seq-prime-delay')?.value) || 1000,
      dispVol:       parseFloat(document.getElementById('seq-disp-vol')?.value) || 0,
      dispFeedrate:  parseFloat(document.getElementById('seq-disp-f')?.value) || 14000,
      dispDelayMs:   parseFloat(document.getElementById('seq-disp-delay')?.value) || 500,
      retractVol:    parseFloat(document.getElementById('seq-retract-vol')?.value) || 0,
      retractFeedrate: parseFloat(document.getElementById('seq-retract-f')?.value) || 6000,
      retractDelayMs:  parseFloat(document.getElementById('seq-retract-delay')?.value) || 100,
      accelSteps:    parseFloat(document.getElementById('seq-accel')?.value) || 0,
    };
  }

  buildDispenseCmd(prefix = 'DISPENSE') {
    const v = this.getSeqValues();
    const parts = [];
    if (v.primeVol > 0) parts.push(`P${v.primeVol}`, `PF${v.primeFeedrate}`, `PD${v.primeDelayMs}`);
    parts.push(`E${v.dispVol}`, `F${v.dispFeedrate}`, `DD${v.dispDelayMs}`);
    if (v.retractVol > 0) parts.push(`R${v.retractVol}`, `RF${v.retractFeedrate}`, `RD${v.retractDelayMs}`);
    return `${prefix} ${parts.join(' ')}`;
  }

  updateSeqPreview() {
    const el = document.getElementById('seq-preview');
    if (el) el.textContent = this.buildDispenseCmd('DISPENSE');
  }

  showSeqStatus(msg, ok = true) {
    const el = document.getElementById('seq-status');
    if (!el) return;
    el.textContent = msg;
    el.style.color = ok ? '#4CAF50' : '#f44336';
    el.style.opacity = '1';
    setTimeout(() => { el.style.opacity = '0'; }, 2000);
  }

  seqValidate() {
    const v = this.getSeqValues();
    const fields = [v.primeVol, v.primeFeedrate, v.primeDelayMs,
                    v.dispVol, v.dispFeedrate, v.dispDelayMs,
                    v.retractVol, v.retractFeedrate, v.retractDelayMs, v.accelSteps];
    if (fields.some(f => isNaN(f) || f < 0)) {
      this.showSeqStatus('Invalid: all fields must be ≥ 0', false);
      return false;
    }
    return true;
  }

  async seqSendAccelIfNeeded() {
    const sa = this.getSeqValues().accelSteps;
    if (this.lastSentSeqAccel !== sa) {
      await this.api.sendGcode(`SEND_PUMP_ARDUINO COMMAND="SA ${sa}"`);
      this.lastSentSeqAccel = sa;
    }
  }

  async seqDispenseNow() {
    if (!this.seqValidate()) return;
    try {
      await this.seqSendAccelIfNeeded();
      await this.api.sendGcode(`SEND_PUMP_ARDUINO COMMAND="${this.buildDispenseCmd('DISPENSE')}"`);
      this.showSeqStatus('✓ Dispense sent');
    } catch (e) {
      this.showSeqStatus('✗ ' + e.message, false);
    }
  }

  async seqStoreTrigger() {
    if (!this.seqValidate()) return;
    try {
      const sa = this.getSeqValues().accelSteps;
      await this.api.sendGcode(`SEND_PUMP_ARDUINO COMMAND="SA ${sa}"`);
      this.lastSentSeqAccel = sa;
      await this.api.sendGcode(`SEND_PUMP_ARDUINO COMMAND="${this.buildDispenseCmd('SDISPENSE')}"`);
      await this.api.sendGcode('SEND_PUMP_ARDUINO COMMAND="TRIGGERON"');
      this.triggerArmed = true;
      this.updateTriggerUI();
      this.showSeqStatus('✓ Stored & trigger armed');
    } catch (e) {
      this.showSeqStatus('✗ ' + e.message, false);
    }
  }

  async seqClear() {
    try {
      await this.api.sendGcode('SEND_PUMP_ARDUINO COMMAND="SDISPENSE P0 E0 R0"');
      await this.api.sendGcode('SEND_PUMP_ARDUINO COMMAND="TRIGGEROFF"');
      this.triggerArmed = false;
      this.updateTriggerUI();
      this.showSeqStatus('✓ Sequence cleared');
    } catch (e) {
      this.showSeqStatus('✗ ' + e.message, false);
    }
  }

  showNotification(message) {
    console.log('Fluidics:', message);
    // Show a temporary alert (could be replaced with a toast notification later)
    alert(message);
  }
}
