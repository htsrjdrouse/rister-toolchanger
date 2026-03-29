// Unified storage manager for all extension data
export class StorageManager {
  constructor() {
    this.config = {
      printerArea: { width: 380, height: 480 },
      objects: [],
      tips: [],
      activeTipIndex: 0,
      savedMacros: [],
      fluidicsSettings: {
        pumpFeedrate: 4000,
        pumpVolume: 5,
        triggerDelay: 50,
        accelSteps: 500,
        aspirateFeedrate: 2000,
        aspirateVolume: 50,
        valveSettleMs: 3200,
        valveMask: '1111',
        stabilizeMs: 50,
        storeVolume: 100,
        storeRate: 2000,
        seq_primeVol: 20,
        seq_primeFeedrate: 10000,
        seq_primeDelayMs: 1000,
        seq_dispVol: 50,
        seq_dispFeedrate: 14000,
        seq_dispDelayMs: 500,
        seq_retractVol: 60,
        seq_retractFeedrate: 6000,
        seq_retractDelayMs: 100,
        seq_accelSteps: 50,
        seq_lastPreset: 'Custom'
      },
      version: '1.5.1'
    };
  }

  // Initialize storage with default values if needed
  async initialize() {
    const stored = await chrome.storage.local.get('liquidHandlingConfig');
    if (stored.liquidHandlingConfig) {
      this.config = { ...this.config, ...stored.liquidHandlingConfig };

      // Initialize fluidicsSettings if not present (migration from older versions)
      if (!this.config.fluidicsSettings) {
        this.config.fluidicsSettings = {
          pumpFeedrate: 4000,
          pumpVolume: 5,
          triggerDelay: 50,
          accelSteps: 500,
          aspirateFeedrate: 2000,
          aspirateVolume: 50,
          valveSettleMs: 3200,
          valveMask: '1111',
          stabilizeMs: 50,
          storeVolume: 100,
          storeRate: 2000,
          seq_primeVol: 20,
          seq_primeFeedrate: 10000,
          seq_primeDelayMs: 1000,
          seq_dispVol: 50,
          seq_dispFeedrate: 14000,
          seq_dispDelayMs: 500,
          seq_retractVol: 60,
          seq_retractFeedrate: 6000,
          seq_retractDelayMs: 100,
          seq_accelSteps: 50,
          seq_lastPreset: 'Custom'
        };
        await this.save();
        console.log('Initialized fluidicsSettings with defaults');
      }

      // Migrate: add sequence fields if missing
      const seqDefaults = {
        seq_primeVol: 20, seq_primeFeedrate: 10000, seq_primeDelayMs: 1000,
        seq_dispVol: 50, seq_dispFeedrate: 14000, seq_dispDelayMs: 500,
        seq_retractVol: 60, seq_retractFeedrate: 6000, seq_retractDelayMs: 100,
        seq_accelSteps: 50, seq_lastPreset: 'Custom'
      };
      let seqMigrated = false;
      for (const [k, v] of Object.entries(seqDefaults)) {
        if (this.config.fluidicsSettings[k] === undefined) {
          this.config.fluidicsSettings[k] = v;
          seqMigrated = true;
        }
      }
      if (seqMigrated) {
        await this.save();
        console.log('Migrated fluidicsSettings with dispense sequence defaults');
      }

      // Migrate existing tips to add new fields if they don't exist
      if (this.config.tips && this.config.tips.length > 0) {
        let needsSave = false;
        this.config.tips = this.config.tips.map((tip, index) => {
          const updated = { ...tip };
          
          // Update tip name to use L0 prefix if it doesn't have one
          if (!updated.name.startsWith('L0') && !updated.name.startsWith('L1')) {
            updated.name = `L0${updated.name}`;
            needsSave = true;
          }
          
          // Add drypad X/Y if missing
          if (updated.drypad_x === undefined) {
            updated.drypad_x = 92.0;
            needsSave = true;
          }
          if (updated.drypad_y === undefined) {
            updated.drypad_y = 335.0;
            needsSave = true;
          }
          
          // Migrate old drypad_servo to new split fields
          if (updated.drypad_servo !== undefined && updated.drypad_servo_touch === undefined) {
            updated.drypad_servo_move = 0;
            updated.drypad_servo_touch = updated.drypad_servo;
            delete updated.drypad_servo;
            delete updated.drypad_linear_pos; // Remove old field
            needsSave = true;
          }
          
          // Add new drypad fields if missing
          if (updated.drypad_servo_move === undefined) {
            updated.drypad_servo_move = 0;
            needsSave = true;
          }
          if (updated.drypad_servo_touch === undefined) {
            updated.drypad_servo_touch = 115;
            needsSave = true;
          }
          if (updated.drypad_delay === undefined) {
            updated.drypad_delay = 2000;
            needsSave = true;
          }
          
          // Migrate old wash_servo to new split fields
          if (updated.wash_servo !== undefined && updated.wash_servo_wash === undefined) {
            updated.wash_servo_move = 0;
            updated.wash_servo_wash = updated.wash_servo;
            delete updated.wash_servo;
            needsSave = true;
          }
          if (updated.wash_servo_move === undefined) {
            updated.wash_servo_move = 0;
            needsSave = true;
          }
          if (updated.wash_servo_wash === undefined) {
            updated.wash_servo_wash = 120;
            needsSave = true;
          }
          
          // Migrate old waste_servo to new split fields
          if (updated.waste_servo !== undefined && updated.waste_servo_waste === undefined) {
            updated.waste_servo_move = 0;
            updated.waste_servo_waste = updated.waste_servo;
            delete updated.waste_servo;
            needsSave = true;
          }
          if (updated.waste_servo_move === undefined) {
            updated.waste_servo_move = 0;
            needsSave = true;
          }
          if (updated.waste_servo_waste === undefined) {
            updated.waste_servo_waste = 170;
            needsSave = true;
          }
          
          // Migrate old eject_servo to new split fields
          if (updated.eject_servo !== undefined && updated.eject_servo_eject === undefined) {
            updated.eject_servo_move = 0;
            updated.eject_servo_eject = updated.eject_servo;
            delete updated.eject_servo;
            needsSave = true;
          }
          if (updated.eject_servo_move === undefined) {
            updated.eject_servo_move = 0;
            needsSave = true;
          }
          if (updated.eject_servo_eject === undefined) {
            updated.eject_servo_eject = 150;
            needsSave = true;
          }
          
          // Add new macro fields if missing
          if (updated.wash_macro === undefined) {
            updated.wash_macro = "";
            needsSave = true;
          }
          if (updated.waste_macro === undefined) {
            updated.waste_macro = "";
            needsSave = true;
          }
          if (updated.eject_macro === undefined) {
            updated.eject_macro = "";
            needsSave = true;
          }
          
          return updated;
        });
        
        // Save if we migrated any tips
        if (needsSave) {
          await this.save();
          console.log('Migrated tips to v1.3.0 schema');
        }
      }
    } else {
      // No stored config - load default config from file
      console.log('No stored configuration found. Loading default configuration...');
      try {
        const response = await fetch(chrome.runtime.getURL('default_config.json'));
        const defaultConfig = await response.json();
        this.config = { ...this.config, ...defaultConfig };
        await this.save();
        console.log('Default configuration loaded and saved:', defaultConfig.version);
      } catch (error) {
        console.error('Failed to load default config, using basic defaults:', error);
        // Fallback to basic defaults if file load fails
        if (this.config.tips.length === 0) {
          this.config.tips.push(this.createDefaultTip());
        }
        await this.save();
      }
    }
    return this.config;
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

  // Save entire configuration
  async save() {
    await chrome.storage.local.set({ 
      liquidHandlingConfig: this.config 
    });
  }

  // Get all configuration
  getAll() {
    return this.config;
  }

  // Printer Area methods
  getPrinterArea() {
    return this.config.printerArea;
  }

  async setPrinterArea(width, height) {
    this.config.printerArea = { width, height };
    await this.save();
  }

  // Object methods
  getObjects() {
    return this.config.objects;
  }

  getObject(name) {
    return this.config.objects.find(obj => obj.name === name);
  }

  async addObject(object) {
    this.config.objects.push(object);
    await this.save();
  }

  async updateObject(index, object) {
    this.config.objects[index] = object;
    await this.save();
  }

  async deleteObject(index) {
    this.config.objects.splice(index, 1);
    await this.save();
  }

  async setObjects(objects) {
    this.config.objects = objects;
    await this.save();
  }

  // Tip methods
  getTips() {
    return this.config.tips;
  }

  getTip(index) {
    return this.config.tips[index];
  }

  getActiveTipIndex() {
    return this.config.activeTipIndex;
  }

  async addTip(tip) {
    this.config.tips.push(tip);
    await this.save();
  }

  async updateTip(index, tip) {
    this.config.tips[index] = tip;
    await this.save();
  }

  async deleteTip(index) {
    this.config.tips.splice(index, 1);
    await this.save();
  }

  async setTips(tips) {
    this.config.tips = tips;
    await this.save();
  }

  async setActiveTipIndex(index) {
    this.config.activeTipIndex = index;
    await this.save();
  }

  // Macro methods
  getMacros() {
    return this.config.savedMacros;
  }

  async addMacro(macro) {
    this.config.savedMacros.push(macro);
    await this.save();
  }

  async updateMacro(index, macro) {
    this.config.savedMacros[index] = macro;
    await this.save();
  }

  async deleteMacro(index) {
    this.config.savedMacros.splice(index, 1);
    await this.save();
  }

  async setMacros(macros) {
    this.config.savedMacros = macros;
    await this.save();
  }

  // Export/Import
  exportConfig() {
    return JSON.stringify(this.config, null, 2);
  }

  async importConfig(jsonString) {
    try {
      const imported = JSON.parse(jsonString);
      this.config = { ...this.config, ...imported };
      await this.save();
      return true;
    } catch (error) {
      console.error('Import failed:', error);
      return false;
    }
  }

  // Fluidics settings methods
  getFluidicsSettings() {
    return this.config.fluidicsSettings;
  }

  async setFluidicsSetting(key, value) {
    if (this.config.fluidicsSettings) {
      this.config.fluidicsSettings[key] = value;
      await this.save();
    }
  }

  async resetFluidicsSettings() {
    this.config.fluidicsSettings = {
      pumpFeedrate: 4000,
      pumpVolume: 5,
      triggerDelay: 50,
      accelSteps: 500,
      aspirateFeedrate: 2000,
      aspirateVolume: 50,
      valveSettleMs: 3200,
      valveMask: '1111',
      stabilizeMs: 50,
      storeVolume: 100,
      storeRate: 2000,
      seq_primeVol: 20,
      seq_primeFeedrate: 10000,
      seq_primeDelayMs: 1000,
      seq_dispVol: 50,
      seq_dispFeedrate: 14000,
      seq_dispDelayMs: 500,
      seq_retractVol: 60,
      seq_retractFeedrate: 6000,
      seq_retractDelayMs: 100,
      seq_accelSteps: 50,
      seq_lastPreset: 'Custom'
    };
    await this.save();
  }

  // Array coordinate calculation
  getArrayCoordinates(objectName) {
    const obj = this.getObject(objectName);
    if (!obj) return [];

    const coords = [];
    const rows = parseInt(obj.arrayrow);
    const cols = parseInt(obj.arraycolumn);
    const rowSpacing = parseFloat(obj.arrayrowsp);
    const colSpacing = parseFloat(obj.arraycolumnsp);
    const marginX = parseFloat(obj.marginx);
    const marginY = parseFloat(obj.marginy);
    const baseX = parseFloat(obj.posx);
    const baseY = parseFloat(obj.posy);

    for (let row = 0; row < rows; row++) {
      for (let col = 0; col < cols; col++) {
        const arrayX = baseX + marginX + col * colSpacing;
        const arrayY = baseY + marginY + row * rowSpacing;
        const arrayName = String.fromCharCode(65 + row) + (col + 1);
        coords.push({
          name: arrayName,
          x: arrayX,
          y: arrayY,
          row: row,
          col: col
        });
      }
    }
    return coords;
  }
}

// Create singleton instance
export const storage = new StorageManager();
