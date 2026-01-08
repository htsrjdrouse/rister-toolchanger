// API wrapper for Klipper/Mainsail communication
export class KlipperAPI {
  constructor() {
    this.endpoints = [
      'http://192.168.1.89:7125',
      'http://mainsailos.local:7125',
      'http://localhost:7125'
    ];
    this.activeEndpoint = null;
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
