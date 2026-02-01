// API wrapper for Klipper/Mainsail communication
export class KlipperAPI {
  constructor() {
    this.endpoints = [
      'http://192.168.1.89:7125',
      'http://mainsailos.local:7125',
      'http://localhost:7125'
    ];
    this.activeEndpoint = null;
    this.commandLog = [];
    this.maxLogLines = 50; // Keep last 50 commands

    // Connection settings
    this.requestTimeout = 5000;      // 5 second timeout per request
    this.maxRetries = 3;             // Retry failed requests up to 3 times
    this.retryDelay = 1000;          // Initial retry delay (doubles each retry)
    this.healthCheckInterval = 30000; // Check connection every 30 seconds
    this.isConnected = false;
    this.healthCheckTimer = null;
    this.onConnectionChange = null;  // Callback for connection status changes
  }

  // Start health check polling
  startHealthCheck() {
    if (this.healthCheckTimer) return;

    this.healthCheckTimer = setInterval(async () => {
      const wasConnected = this.isConnected;
      await this.checkConnection();

      if (wasConnected !== this.isConnected && this.onConnectionChange) {
        this.onConnectionChange(this.isConnected);
      }
    }, this.healthCheckInterval);

    // Also check immediately
    this.checkConnection();
  }

  // Stop health check polling
  stopHealthCheck() {
    if (this.healthCheckTimer) {
      clearInterval(this.healthCheckTimer);
      this.healthCheckTimer = null;
    }
  }

  // Check if current connection is alive
  async checkConnection() {
    if (!this.activeEndpoint) {
      this.isConnected = false;
      return false;
    }

    try {
      const response = await this.fetchWithTimeout(
        `${this.activeEndpoint}/server/info`,
        { method: 'GET' },
        3000 // Quick 3s timeout for health check
      );
      this.isConnected = response.ok;
      return this.isConnected;
    } catch (error) {
      this.isConnected = false;
      return false;
    }
  }

  // Fetch with timeout using AbortController
  async fetchWithTimeout(url, options = {}, timeout = this.requestTimeout) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);

    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      return response;
    } finally {
      clearTimeout(timeoutId);
    }
  }

  // Retry wrapper with exponential backoff
  async fetchWithRetry(url, options = {}, retries = this.maxRetries) {
    let lastError;
    let delay = this.retryDelay;

    for (let attempt = 0; attempt <= retries; attempt++) {
      try {
        const response = await this.fetchWithTimeout(url, options);
        if (response.ok) {
          this.isConnected = true;
          return response;
        }
        // Non-OK response, treat as error for retry
        lastError = new Error(`HTTP ${response.status}: ${response.statusText}`);
      } catch (error) {
        lastError = error;

        // If aborted due to timeout, mark as disconnected
        if (error.name === 'AbortError') {
          this.isConnected = false;
          console.warn(`Request timeout (attempt ${attempt + 1}/${retries + 1})`);
        }
      }

      // Don't delay after last attempt
      if (attempt < retries) {
        console.log(`Retrying in ${delay}ms... (attempt ${attempt + 2}/${retries + 1})`);
        await this.sleep(delay);
        delay *= 2; // Exponential backoff
      }
    }

    // All retries failed - try to reconnect
    this.isConnected = false;
    this.activeEndpoint = null;
    throw lastError;
  }

  // Sleep helper
  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  // Log command to the command log textarea
  logCommand(command) {
    const timestamp = new Date().toLocaleTimeString('en-US', { hour12: false });
    const lines = command.split('\n').filter(line => line.trim());

    lines.forEach(line => {
      this.commandLog.push(`[${timestamp}] ${line}`);
    });

    // Keep only the last maxLogLines
    if (this.commandLog.length > this.maxLogLines) {
      this.commandLog = this.commandLog.slice(-this.maxLogLines);
    }

    // Update the textarea if it exists
    const logElement = document.getElementById('command-log');
    if (logElement) {
      logElement.value = this.commandLog.join('\n');
      // Auto-scroll to bottom
      logElement.scrollTop = logElement.scrollHeight;
    }
  }

  // Clear command log
  clearLog() {
    this.commandLog = [];
    const logElement = document.getElementById('command-log');
    if (logElement) {
      logElement.value = '';
    }
  }

  // Get command log as string
  getLogText() {
    return this.commandLog.join('\n');
  }

  // Auto-detect which endpoint is available
  async detectEndpoint() {
    for (const endpoint of this.endpoints) {
      try {
        const response = await fetch(`${endpoint}/server/info`, {
          method: 'GET',
          timeout: 2000
        });
        if (response.ok) {
          this.activeEndpoint = endpoint;
          console.log('Connected to Klipper at:', endpoint);
          return endpoint;
        }
      } catch (error) {
        continue;
      }
    }
    console.warn('No Klipper endpoint detected');
    return null;
  }

  // Send G-code command
  async sendGcode(command) {
    // Log command immediately (before sending)
    this.logCommand(command);

    if (!this.activeEndpoint) {
      await this.detectEndpoint();
    }

    if (!this.activeEndpoint) {
      throw new Error('No Klipper connection available');
    }

    try {
      const response = await fetch(`${this.activeEndpoint}/printer/gcode/script`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          script: command
        })
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error('Klipper API error:', response.statusText, errorText);
        throw new Error(`Klipper API error: ${response.statusText}`);
      }

      const data = await response.json();
      console.log('✓ G-code sent successfully:', command);
      if (data.result) {
        console.log('  Response:', data.result);
      }
      return data;
    } catch (error) {
      console.error('✗ Failed to send G-code:', command);
      console.error('  Error:', error);
      throw error;
    }
  }

  // Send multiple G-code commands
  async sendGcodeMulti(commands) {
    const script = Array.isArray(commands) ? commands.join('\n') : commands;
    return await this.sendGcode(script);
  }

  // Get printer status
  async getPrinterStatus() {
    if (!this.activeEndpoint) {
      await this.detectEndpoint();
    }

    if (!this.activeEndpoint) {
      return null;
    }

    try {
      const response = await fetch(`${this.activeEndpoint}/printer/objects/query?toolhead`);
      if (response.ok) {
        return await response.json();
      }
    } catch (error) {
      console.error('Failed to get printer status:', error);
    }
    return null;
  }

  // Get saved variables from Klipper (variables.cfg)
  async getSavedVariables() {
    if (!this.activeEndpoint) {
      await this.detectEndpoint();
    }

    if (!this.activeEndpoint) {
      return null;
    }

    try {
      const response = await fetch(`${this.activeEndpoint}/printer/objects/query?save_variables`);
      if (response.ok) {
        const data = await response.json();
        return data.result?.status?.save_variables?.variables || null;
      }
    } catch (error) {
      console.error('Failed to get saved variables:', error);
    }
    return null;
  }

  // Get specific saved variable
  async getSavedVariable(name) {
    const variables = await this.getSavedVariables();
    return variables ? variables[name] : null;
  }

  // Upload and run G-code file
  async uploadAndRunGcode(filename, gcodeContent) {
    if (!this.activeEndpoint) {
      await this.detectEndpoint();
    }

    if (!this.activeEndpoint) {
      throw new Error('No Klipper connection available');
    }

    try {
      // Upload file
      const formData = new FormData();
      const blob = new Blob([gcodeContent], { type: 'text/plain' });
      formData.append('file', blob, filename);

      const uploadResponse = await fetch(`${this.activeEndpoint}/server/files/upload`, {
        method: 'POST',
        body: formData
      });

      if (!uploadResponse.ok) {
        throw new Error('Failed to upload G-code file');
      }

      // Start print
      const printResponse = await fetch(`${this.activeEndpoint}/printer/print/start`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          filename: filename
        })
      });

      if (!printResponse.ok) {
        throw new Error('Failed to start print');
      }

      console.log('G-code file uploaded and started:', filename);
      return await printResponse.json();
    } catch (error) {
      console.error('Failed to upload/run G-code:', error);
      throw error;
    }
  }

  // Save variables to Klipper
  async saveVariable(variable, value) {
    const command = `SAVE_VARIABLE VARIABLE=${variable} VALUE="${value}"`;
    return await this.sendGcode(command);
  }

  // WebSocket connection for real-time updates (optional)
  connectWebSocket(onMessage) {
    if (!this.activeEndpoint) {
      console.warn('No endpoint available for WebSocket');
      return null;
    }

    const wsUrl = this.activeEndpoint.replace('http', 'ws') + '/websocket';
    const ws = new WebSocket(wsUrl);

    ws.onopen = () => {
      console.log('WebSocket connected to Klipper');
    };

    ws.onmessage = (event) => {
      if (onMessage) {
        onMessage(JSON.parse(event.data));
      }
    };

    ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };

    ws.onclose = () => {
      console.log('WebSocket disconnected');
    };

    return ws;
  }
}

// Create singleton instance
export const api = new KlipperAPI();
