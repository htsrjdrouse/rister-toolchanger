// ==UserScript==
// @name         Mainsail Fluidics Control
// @namespace    http://tampermonkey.net/
// @version      1.0
// @description  Add fluidics control panel to Mainsail
// @author       Rister
// @match        http://192.168.1.89:81/*
// @match        http://mainsailos.local/*
// @match        http://your-printer-ip/*
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    // Wait for page to load
    function waitForElement(selector) {
        return new Promise(resolve => {
            if (document.querySelector(selector)) {
                return resolve(document.querySelector(selector));
            }

            const observer = new MutationObserver(mutations => {
                if (document.querySelector(selector)) {
                    observer.disconnect();
                    resolve(document.querySelector(selector));
                }
            });

            observer.observe(document.body, {
                childList: true,
                subtree: true
            });
        });
    }

    // Send G-code command to Klipper
    function sendGcode(command) {
        console.log('Attempting to send command:', command);

        // Method 1: Try to access Mainsail's Vue instance and socket
        if (window.$nuxt && window.$nuxt.$socket) {
            console.log('Using $nuxt.$socket');
            window.$nuxt.$socket.emit('printer.gcode.script', { script: command });
            return;
        }

        // Method 2: Try to access Vue through the app
        if (window.__NUXT__ && window.$nuxt) {
            console.log('Using $nuxt direct access');
            window.$nuxt.$socket.emit('printer.gcode.script', { script: command });
            return;
        }

        // Method 3: Try moonraker WebSocket directly
        const wsUrl = `ws://${window.location.hostname}:7125/websocket`;
        try {
            const ws = new WebSocket(wsUrl);
            ws.onopen = function() {
                console.log('WebSocket connection opened');
                const message = {
                    jsonrpc: "2.0",
                    method: "printer.gcode.script",
                    params: { script: command },
                    id: Date.now()
                };
                ws.send(JSON.stringify(message));
                setTimeout(() => ws.close(), 1000);
            };
            ws.onerror = function(error) {
                console.log('WebSocket error:', error);
                fallbackSendCommand(command);
            };
            return;
        } catch (error) {
            console.log('WebSocket creation failed:', error);
        }

        // Method 4: Try to simulate console input
        fallbackSendCommand(command);
    }

    // Fallback method - simulate typing in console
    function fallbackSendCommand(command) {
        console.log('Using fallback method for command:', command);

        // Try to find the console input field
        const consoleSelectors = [
            'input[placeholder*="ommand" i]',
            'input[placeholder*="console" i]',
            '.console-input input',
            '.v-text-field input[type="text"]',
            'input[type="text"]'
        ];

        let consoleInput = null;
        for (const selector of consoleSelectors) {
            consoleInput = document.querySelector(selector);
            if (consoleInput) {
                console.log('Found console input with selector:', selector);
                break;
            }
        }

        if (consoleInput) {
            // Focus the input
            consoleInput.focus();

            // Clear any existing content
            consoleInput.value = '';

            // Set the command
            consoleInput.value = command;

            // Trigger input events
            consoleInput.dispatchEvent(new Event('input', { bubbles: true }));
            consoleInput.dispatchEvent(new Event('change', { bubbles: true }));

            // Try multiple ways to submit
            setTimeout(() => {
                // Method 1: Enter key
                consoleInput.dispatchEvent(new KeyboardEvent('keydown', {
                    key: 'Enter',
                    code: 'Enter',
                    keyCode: 13,
                    bubbles: true
                }));

                // Method 2: Look for submit button
                const submitButton = document.querySelector('button[type="submit"], .console-send-btn, button:contains("Send")');
                if (submitButton) {
                    submitButton.click();
                }
            }, 100);

            showStatus(`Command sent via console: ${command}`);
        } else {
            // Last resort - show manual instruction
            showStatus(`Please run manually: ${command}`, 'error');

            // Copy to clipboard if possible
            if (navigator.clipboard) {
                navigator.clipboard.writeText(command).then(() => {
                    showStatus(`Command copied to clipboard: ${command}`, 'info');
                });
            } else {
                // Alert as final fallback
                alert(`Please run this command manually in the console:\n\n${command}`);
            }
        }
    }

    // Create the control panel
    function createFluidicsPanel() {
        const panel = document.createElement('div');
        panel.id = 'fluidics-control-panel';
        panel.innerHTML = `
            <div id="fluidics-main-panel" style="
                position: fixed;
                top: 100px;
                left: 10px;
                background: white;
                border: 1px solid #ccc;
                border-radius: 8px;
                padding: 15px;
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
                z-index: 1000;
                min-width: 300px;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                cursor: move;
            ">
                <div id="fluidics-header" style="
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin-bottom: 15px;
                    cursor: grab;
                    user-select: none;
                ">
                    <h3 style="margin: 0; color: #333;">🧪 Fluidics Control</h3>
                    <button id="toggle-fluidics" style="
                        background: #f0f0f0;
                        border: none;
                        border-radius: 4px;
                        padding: 5px 8px;
                        cursor: pointer;
                    ">+</button>
                </div>

                <div id="fluidics-content" style="display: none;">
                    <!-- Timed Wash Section -->
                    <div style="margin-bottom: 15px; padding: 10px; background: #f8f9fa; border-radius: 4px;">
                        <label style="display: block; margin-bottom: 5px; font-weight: bold;">Wash Duration:</label>
                        <div style="display: flex; gap: 10px; align-items: center;">
                            <input type="number" id="wash-duration" value="30" min="1" max="300"
                                   style="width: 80px; padding: 5px; border: 1px solid #ccc; border-radius: 4px;">
                            <span>seconds</span>
                            <button onclick="runTimedWash()" style="
                                background: #4CAF50;
                                color: white;
                                border: none;
                                padding: 8px 15px;
                                border-radius: 4px;
                                cursor: pointer;
                            ">Start Timed Wash</button>
                        </div>
                    </div>

                    <!-- Control Buttons Grid -->
                    <div id="fluidics-buttons" style="
                        display: grid;
                        grid-template-columns: 1fr 1fr;
                        gap: 8px;
                    ">
                        <button onclick="sendFluidicsCommand('FEEDBACK_PCV')" class="fluidics-btn primary">Feedback PCV On</button>
                        <button onclick="sendFluidicsCommand('MANUAL_PCV')" class="fluidics-btn danger">Manual PCV</button>
                        <button onclick="sendFluidicsCommand('WASH_ON')" class="fluidics-btn primary">Wash On</button>
                        <button onclick="sendFluidicsCommand('WASH_OFF')" class="fluidics-btn danger">Wash Off</button>
                        <button onclick="sendFluidicsCommand('WASTE_ON')" class="fluidics-btn primary">Dry On</button>
                        <button onclick="sendFluidicsCommand('WASTE_OFF')" class="fluidics-btn danger">Dry Off</button>
                        <button onclick="sendFluidicsCommand('VALVE_INPUT')" class="fluidics-btn secondary">Valve Input</button>
                        <button onclick="sendFluidicsCommand('VALVE_OUTPUT')" class="fluidics-btn secondary">Valve Output</button>
                        <button onclick="sendFluidicsCommand('VALVE_BYPASS')" class="fluidics-btn secondary">Valve Bypass</button>
                        <button onclick="sendFluidicsCommand('WASTE_POSITION')" class="fluidics-btn secondary">Waste Position</button>
                        <button onclick="sendFluidicsCommand('EJECT_PIPETTE')" class="fluidics-btn danger">Eject Pipette</button>
                    </div>

                    <!-- Status Display -->
                    <div id="fluidics-status" style="
                        margin-top: 10px;
                        padding: 8px;
                        background: #e3f2fd;
                        border-radius: 4px;
                        font-size: 12px;
                        display: none;
                    "></div>
                </div>

                <style>
                    .fluidics-btn {
                        padding: 8px 12px;
                        border: none;
                        border-radius: 4px;
                        cursor: pointer;
                        font-size: 12px;
                        transition: opacity 0.2s;
                    }
                    .fluidics-btn:hover {
                        opacity: 0.8;
                    }
                    .fluidics-btn.primary {
                        background: #4CAF50;
                        color: white;
                    }
                    .fluidics-btn.danger {
                        background: #f44336;
                        color: white;
                    }
                    .fluidics-btn.secondary {
                        background: #2196F3;
                        color: white;
                    }
                </style>
            </div>
        `;

        document.body.appendChild(panel);

        // Make panel draggable
        makeDraggable();

        // Add toggle functionality
        document.getElementById('toggle-fluidics').onclick = function() {
            const content = document.getElementById('fluidics-content');
            const button = this;
            if (content.style.display === 'none') {
                content.style.display = 'block';
                button.textContent = '−';
            } else {
                content.style.display = 'none';
                button.textContent = '+';
            }
        };
    }

    // Make the panel draggable
    function makeDraggable() {
        const panel = document.getElementById('fluidics-main-panel');
        const header = document.getElementById('fluidics-header');
        let isDragging = false;
        let currentX;
        let currentY;
        let initialX;
        let initialY;
        let xOffset = 0;
        let yOffset = 0;

        // Get initial position
        const rect = panel.getBoundingClientRect();
        xOffset = rect.left;
        yOffset = rect.top;

        header.addEventListener('mousedown', dragStart);
        document.addEventListener('mousemove', drag);
        document.addEventListener('mouseup', dragEnd);

        // Touch events for mobile
        header.addEventListener('touchstart', dragStart);
        document.addEventListener('touchmove', drag);
        document.addEventListener('touchend', dragEnd);

        function dragStart(e) {
            if (e.type === "touchstart") {
                initialX = e.touches[0].clientX - xOffset;
                initialY = e.touches[0].clientY - yOffset;
            } else {
                initialX = e.clientX - xOffset;
                initialY = e.clientY - yOffset;
            }

            if (e.target === header || header.contains(e.target)) {
                isDragging = true;
                header.style.cursor = 'grabbing';
            }
        }

        function drag(e) {
            if (isDragging) {
                e.preventDefault();

                if (e.type === "touchmove") {
                    currentX = e.touches[0].clientX - initialX;
                    currentY = e.touches[0].clientY - initialY;
                } else {
                    currentX = e.clientX - initialX;
                    currentY = e.clientY - initialY;
                }

                xOffset = currentX;
                yOffset = currentY;

                // Keep panel within viewport
                const maxX = window.innerWidth - panel.offsetWidth;
                const maxY = window.innerHeight - panel.offsetHeight;

                xOffset = Math.max(0, Math.min(xOffset, maxX));
                yOffset = Math.max(0, Math.min(yOffset, maxY));

                panel.style.left = xOffset + "px";
                panel.style.top = yOffset + "px";
            }
        }

        function dragEnd() {
            initialX = currentX;
            initialY = currentY;
            isDragging = false;
            header.style.cursor = 'grab';

            // Save position to localStorage so it remembers between page loads
            localStorage.setItem('fluidics-panel-x', xOffset);
            localStorage.setItem('fluidics-panel-y', yOffset);
        }

        // Restore saved position
        const savedX = localStorage.getItem('fluidics-panel-x');
        const savedY = localStorage.getItem('fluidics-panel-y');
        if (savedX && savedY) {
            xOffset = parseInt(savedX);
            yOffset = parseInt(savedY);
            panel.style.left = xOffset + "px";
            panel.style.top = yOffset + "px";
        }
    }

    // Global functions for button clicks
    window.sendFluidicsCommand = function(command) {
        showStatus(`Sending: ${command}`);
        sendGcode(command);
    };

    window.runTimedWash = function() {
        const duration = parseInt(document.getElementById('wash-duration').value);
        if (duration < 1 || duration > 300) {
            showStatus('Duration must be between 1-300 seconds', 'error');
            return;
        }

        showStatus(`Starting ${duration}s wash cycle...`);
        sendGcode('WASH_ON');

        setTimeout(() => {
            sendGcode('WASH_OFF');
            showStatus(`Wash cycle completed (${duration}s)`);
        }, duration * 1000);
    };

    function showStatus(message, type = 'info') {
        const status = document.getElementById('fluidics-status');
        status.textContent = message;
        status.style.display = 'block';
        status.style.background = type === 'error' ? '#ffebee' : '#e3f2fd';

        setTimeout(() => {
            status.style.display = 'none';
        }, 3000);
    }

    // Initialize when page is ready
    waitForElement('body').then(() => {
        setTimeout(createFluidicsPanel, 2000); // Wait a bit for Mainsail to fully load
    });

})();
