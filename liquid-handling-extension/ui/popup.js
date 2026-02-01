import { storage } from '../shared/storage.js';
import { api } from '../shared/api.js';
import { ObjectEditor } from './object-editor/object-editor.js';
import { FluidicsControl } from './fluidics/fluidics.js';
import { GcodeBuilder } from './gcode-builder/gcode-builder.js';

class LiquidHandlingApp {
  constructor() {
    this.storage = storage;
    this.api = api;
    this.objectEditor = null;
    this.fluidicsControl = null;
    this.gcodeBuilder = null;
    this.currentTab = 'object-editor';
  }

  async initialize() {
    console.log('Initializing Liquid Handling Control System...');

    // Initialize storage
    await this.storage.initialize();

    // Check printer connection
    await this.checkConnection();

    // Setup tab navigation
    this.setupTabs();

    // Initialize all modules
    this.objectEditor = new ObjectEditor(this.storage, this.api);
    this.fluidicsControl = new FluidicsControl(this.storage, this.api);
    this.gcodeBuilder = new GcodeBuilder(this.storage, this.api);

    await this.objectEditor.initialize();
    await this.fluidicsControl.initialize();
    await this.gcodeBuilder.initialize();

    // Setup global actions
    this.setupGlobalActions();

    console.log('✓ Liquid Handling Control System initialized');
  }

  setupTabs() {
    const tabButtons = document.querySelectorAll('.tab-button');
    
    tabButtons.forEach(button => {
      button.addEventListener('click', () => {
        const tabName = button.dataset.tab;
        this.switchTab(tabName);
      });
    });
  }

  switchTab(tabName) {
    // Update buttons
    document.querySelectorAll('.tab-button').forEach(btn => {
      btn.classList.remove('active');
    });
    document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');

    // Update panels
    document.querySelectorAll('.tab-panel').forEach(panel => {
      panel.classList.remove('active');
    });
    document.getElementById(tabName).classList.add('active');

    this.currentTab = tabName;

    // Trigger any tab-specific refresh logic
    if (tabName === 'gcode-builder') {
      this.gcodeBuilder.refreshObjectList();
    }
  }

  async checkConnection() {
    const statusIndicator = document.getElementById('status-indicator');
    const statusText = document.getElementById('status-text');

    try {
      const endpoint = await this.api.detectEndpoint();
      if (endpoint) {
        statusIndicator.classList.add('connected');
        statusText.textContent = 'Connected';
      } else {
        statusIndicator.classList.add('disconnected');
        statusText.textContent = 'Disconnected';
      }
    } catch (error) {
      statusIndicator.classList.add('disconnected');
      statusText.textContent = 'Connection Error';
    }
  }

  setupGlobalActions() {
    // Export configuration
    document.getElementById('export-all').addEventListener('click', () => {
      this.exportConfiguration();
    });

    // Import configuration
    document.getElementById('import-all').addEventListener('click', () => {
      this.importConfiguration();
    });

    // Clear command log
    document.getElementById('clear-log').addEventListener('click', () => {
      this.api.clearLog();
    });

    // Copy command log to clipboard
    document.getElementById('copy-log').addEventListener('click', () => {
      const logText = this.api.getLogText();
      if (logText) {
        navigator.clipboard.writeText(logText).then(() => {
          this.showNotification('Command log copied to clipboard!', 'success');
        }).catch(err => {
          // Fallback for older browsers
          const logElement = document.getElementById('command-log');
          logElement.select();
          document.execCommand('copy');
          this.showNotification('Command log copied to clipboard!', 'success');
        });
      } else {
        this.showNotification('No commands to copy', 'info');
      }
    });
  }

  exportConfiguration() {
    const config = this.storage.exportConfig();
    const fileName = `liquid_handling_config_${new Date().toISOString().slice(0, 10)}.json`;
    
    const blob = new Blob([config], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    
    const link = document.createElement('a');
    link.href = url;
    link.download = fileName;
    link.click();
    
    URL.revokeObjectURL(url);
    
    this.showNotification('Configuration exported successfully!', 'success');
  }

  importConfiguration() {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.json';
    
    input.onchange = async (event) => {
      const file = event.target.files[0];
      if (!file) return;
      
      const reader = new FileReader();
      reader.onload = async (e) => {
        try {
          const success = await this.storage.importConfig(e.target.result);
          if (success) {
            this.showNotification('Configuration imported successfully! Reloading...', 'success');
            // Reload all modules
            setTimeout(() => {
              window.location.reload();
            }, 1000);
          } else {
            this.showNotification('Failed to import configuration', 'danger');
          }
        } catch (error) {
          this.showNotification('Error importing configuration: ' + error.message, 'danger');
        }
      };
      reader.readAsText(file);
    };
    
    input.click();
  }

  showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `alert alert-${type}`;
    notification.textContent = message;
    notification.style.position = 'fixed';
    notification.style.top = '70px';
    notification.style.right = '20px';
    notification.style.zIndex = '10000';
    notification.style.minWidth = '300px';
    notification.style.animation = 'slideInRight 0.3s ease';
    
    document.body.appendChild(notification);
    
    // Remove after 3 seconds
    setTimeout(() => {
      notification.style.animation = 'slideOutRight 0.3s ease';
      setTimeout(() => {
        document.body.removeChild(notification);
      }, 300);
    }, 3000);
  }
}

// Initialize app when DOM is ready
document.addEventListener('DOMContentLoaded', async () => {
  const app = new LiquidHandlingApp();
  await app.initialize();
});

// Add animation keyframes
const style = document.createElement('style');
style.textContent = `
  @keyframes slideInRight {
    from {
      transform: translateX(400px);
      opacity: 0;
    }
    to {
      transform: translateX(0);
      opacity: 1;
    }
  }
  
  @keyframes slideOutRight {
    from {
      transform: translateX(0);
      opacity: 1;
    }
    to {
      transform: translateX(400px);
      opacity: 0;
    }
  }
`;
document.head.appendChild(style);
