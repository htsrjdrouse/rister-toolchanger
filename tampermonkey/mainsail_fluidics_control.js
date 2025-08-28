// ==UserScript==
// @name         Mainsail Fluidics Control Enhanced
// @namespace    http://tampermonkey.net/
// @version      1.4
// @description  Add fluidics control panel with pump speed control
// @author       Rister
// @match        http://192.168.1.89:81/*
// @match        http://mainsailos.local/*
// @match        http://your-printer-ip/*
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    // Send G-code command to Klipper
    function sendGcode(command) {
        console.log('Sending command:', command);

        if (window.$nuxt && window.$nuxt.$socket) {
            window.$nuxt.$socket.emit('printer.gcode.script', { script: command });
            return;
        }

        const wsUrl = `ws://${window.location.hostname}:7125/websocket`;
        try {
            const ws = new WebSocket(wsUrl);
            ws.onopen = function() {
                const message = {
                    jsonrpc: "2.0",
                    method: "printer.gcode.script",
                    params: { script: command },
                    id: Date.now()
                };
                ws.send(JSON.stringify(message));
                setTimeout(() => ws.close(), 1000);
            };
        } catch (error) {
            console.log('WebSocket failed:', error);
        }
    }

    // Create the control panel
    function createFluidicsPanel() {
        const panel = document.createElement('div');
        panel.id = 'fluidics-control-panel';
        panel.innerHTML = `
            <div id="fluidics-main-panel" style="
                position: fixed; top: 100px; left: 10px; background: white;
                border: 1px solid #ccc; border-radius: 8px; padding: 15px;
                box-shadow: 0 4px 8px rgba(0,0,0,0.1); z-index: 1000; min-width: 360px;
                font-family: Arial, sans-serif; cursor: move;">

                <div id="fluidics-header" style="display: flex; justify-content: space-between;
                    align-items: center; margin-bottom: 15px; cursor: grab;">
                    <h3 style="margin: 0;">Fluidics Control</h3>
                    <button id="toggle-fluidics" style="background: #f0f0f0; border: none;
                        border-radius: 4px; padding: 5px 8px; cursor: pointer;">+</button>
                </div>

                <div id="fluidics-content" style="display: none;">

                    <!-- Syringe Pump Control -->
                    <div style="margin-bottom: 15px; padding: 10px; background: #f3e5f5;
                        border-radius: 4px; border-left: 4px solid #9c27b0;">
                        <label style="display: block; margin-bottom: 8px; font-weight: bold;">
                            Syringe Pump:</label>

                        <div style="display: flex; gap: 8px; align-items: center; margin-bottom: 8px;">
                            <div style="display: flex; flex-direction: column; flex: 1;">
                                <label style="font-size: 11px; margin-bottom: 2px;">Steps:</label>
                                <input type="number" id="syringe-steps" value="130" min="1" max="1000"
                                    style="padding: 4px; border: 1px solid #ccc; border-radius: 3px;"
                                    onchange="localStorage.setItem('syringe-steps', this.value)">
                            </div>
                            <div style="display: flex; flex-direction: column; flex: 1;">
                                <label style="font-size: 11px; margin-bottom: 2px;">Feedrate:</label>
                                <input type="number" id="syringe-feedrate" value="3000" min="100" max="10000"
                                    style="padding: 4px; border: 1px solid #ccc; border-radius: 3px;"
                                    onchange="localStorage.setItem('syringe-feedrate', this.value)">
                            </div>
                        </div>

                        <div style="display: flex; gap: 8px; margin-bottom: 8px;">
                            <button onclick="aspirateSyringe()" style="background: #2196F3; color: white;
                                border: none; padding: 6px 12px; border-radius: 3px; cursor: pointer;
                                font-size: 12px; flex: 1;">Aspirate</button>
                            <button onclick="dispenseSyringe()" style="background: #4CAF50; color: white;
                                border: none; padding: 6px 12px; border-radius: 3px; cursor: pointer;
                                font-size: 12px; flex: 1;">Dispense</button>
                            <button onclick="zeroSyringeCount()" style="background: #f44336; color: white;
                                border: none; padding: 6px 12px; border-radius: 3px; cursor: pointer;
                                font-size: 12px;">Zero</button>
                        </div>

                        <div id="syringe-count-display" style="padding: 4px; background: rgba(156, 39, 176, 0.1);
                            border-radius: 3px; font-size: 11px; color: #7b1fa2; text-align: center;">
                            Position: 0 steps
                        </div>
                    </div>

                    <!-- Pump Speed Control -->
                    <div style="margin-bottom: 15px; padding: 10px; background: #fff3e0;
                        border-radius: 4px; border-left: 4px solid #ff9800;">
                        <label style="display: block; margin-bottom: 8px; font-weight: bold;">
                            Pump Speed (0-255):</label>

                        <div style="display: flex; gap: 8px; align-items: center; margin-bottom: 8px;">
                            <input type="range" id="pump-speed-slider" min="0" max="255" value="255"
                                style="flex: 1;" oninput="updatePumpSpeed(this.value)">
                            <input type="number" id="pump-speed-input" value="255" min="0" max="255"
                                style="width: 60px; padding: 4px;" onchange="updatePumpSpeed(this.value)">
                            <div id="pump-speed-display" style="font-size: 11px; min-width: 70px;">255 (100%)</div>
                        </div>

                        <div style="display: flex; gap: 8px;">
                            <button onclick="setWashSpeed()" style="background: #2196F3; color: white;
                                border: none; padding: 6px 12px; border-radius: 3px; cursor: pointer;
                                font-size: 12px; flex: 1;">Set Wash</button>
                            <button onclick="setDrySpeed()" style="background: #FF9800; color: white;
                                border: none; padding: 6px 12px; border-radius: 3px; cursor: pointer;
                                font-size: 12px; flex: 1;">Set Waste</button>
                        </div>
                    </div>

                    <!-- Pipette Height Control -->
                    <div style="margin-bottom: 15px; padding: 10px; background: #e8f5e8;
                        border-radius: 4px; border-left: 4px solid #4CAF50;">
                        <label style="display: block; margin-bottom: 8px; font-weight: bold;">Pipette Height:</label>
                        <div style="display: flex; gap: 10px; align-items: center;">
                            <input type="number" id="servo-angle" value="0" min="0" max="180"
                                style="width: 80px; padding: 8px; border: 1px solid #ccc; border-radius: 4px;">
                            <span style="font-size: 12px;">degrees</span>
                            <button onclick="setPipetteHeight()" style="background: #4CAF50; color: white;
                                border: none; padding: 8px 15px; border-radius: 4px; cursor: pointer;">
                                Set Position</button>
                        </div>
                        <div style="display: flex; gap: 5px; margin-top: 8px;">
                            <button onclick="setPresetAngle(0)" style="background: #81C784; color: white;
                                border: none; padding: 4px 8px; border-radius: 3px; cursor: pointer;
                                font-size: 11px;">Up (0°)</button>
                            <button onclick="setPresetAngle(90)" style="background: #64B5F6; color: white;
                                border: none; padding: 4px 8px; border-radius: 3px; cursor: pointer;
                                font-size: 11px;">Mid (90°)</button>
                            <button onclick="setPresetAngle(180)" style="background: #FFB74D; color: white;
                                border: none; padding: 4px 8px; border-radius: 3px; cursor: pointer;
                                font-size: 11px;">Down (180°)</button>
                            <button onclick="disableServo()" style="background: #f44336; color: white;
                                border: none; padding: 4px 8px; border-radius: 3px; cursor: pointer;
                                font-size: 11px;">OFF</button>
                        </div>
                    </div>

                    <!-- Tip Selection -->
                    <div style="margin-bottom: 15px; padding: 10px; background: #fff3e0;
                        border-radius: 4px; border-left: 4px solid #ff9800;">
                        <label style="display: block; margin-bottom: 8px; font-weight: bold;">Pipette Tip:</label>
                        <div style="display: flex; gap: 10px; align-items: center;">
                            <select id="tip-selector" style="flex: 1; padding: 8px; border: 1px solid #ccc;
                                border-radius: 4px; background: white;">
                                <option value="P100">P100 Tip</option>
                                <option value="P300" selected>P300 Tip</option>
                            </select>
                            <button onclick="selectTip()" style="background: #ff9800; color: white;
                                border: none; padding: 8px 15px; border-radius: 4px; cursor: pointer;">
                                Select</button>
                        </div>
                    </div>

                    <!-- Control Buttons -->
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px;">
                        <button onclick="sendCommand('FEEDBACK_PCV')" style="background: #4CAF50; color: white;
                            border: none; padding: 8px; border-radius: 4px; cursor: pointer; font-size: 12px;">
                            Feedback PCV</button>
                        <button onclick="sendCommand('MANUAL_PCV')" style="background: #f44336; color: white;
                            border: none; padding: 8px; border-radius: 4px; cursor: pointer; font-size: 12px;">
                            Manual PCV</button>
                        <button onclick="sendCommand('WASH_ON')" style="background: #4CAF50; color: white;
                            border: none; padding: 8px; border-radius: 4px; cursor: pointer; font-size: 12px;">
                            Wash On</button>
                        <button onclick="sendCommand('WASH_OFF')" style="background: #f44336; color: white;
                            border: none; padding: 8px; border-radius: 4px; cursor: pointer; font-size: 12px;">
                            Wash Off</button>
                        <button onclick="sendCommand('WASTE_ON')" style="background: #4CAF50; color: white;
                            border: none; padding: 8px; border-radius: 4px; cursor: pointer; font-size: 12px;">
                            Waste On</button>
                        <button onclick="sendCommand('WASTE_OFF')" style="background: #f44336; color: white;
                            border: none; padding: 8px; border-radius: 4px; cursor: pointer; font-size: 12px;">
                            Waste Off</button>
                        <button onclick="sendCommand('VALVE_INPUT')" style="background: #2196F3; color: white;
                            border: none; padding: 8px; border-radius: 4px; cursor: pointer; font-size: 12px;">
                            Valve Input</button>
                        <button onclick="sendCommand('VALVE_OUTPUT')" style="background: #2196F3; color: white;
                            border: none; padding: 8px; border-radius: 4px; cursor: pointer; font-size: 12px;">
                            Valve Output</button>
                        <button onclick="sendCommand('VALVE_BYPASS')" style="background: #2196F3; color: white;
                            border: none; padding: 8px; border-radius: 4px; cursor: pointer; font-size: 12px;">
                            Valve Bypass</button>
                        <button onclick="sendCommand('WASH_POSITION')" style="background: #2196F3; color: white;
                            border: none; padding: 8px; border-radius: 4px; cursor: pointer; font-size: 12px;">
                            Wash Position</button>
                        <button onclick="sendCommand('WASTE_POSITION')" style="background: #2196F3; color: white;
                            border: none; padding: 8px; border-radius: 4px; cursor: pointer; font-size: 12px;">
                            Waste Position</button>
                        <button onclick="sendCommand('EJECT_PIPETTE')" style="background: #f44336; color: white;
                            border: none; padding: 8px; border-radius: 4px; cursor: pointer; font-size: 12px;">
                            Eject Pipette</button>
                        <button onclick="sendCommand('TOUCH_DRY')" style="background: #9C27B0; color: white;
                            border: none; padding: 8px; border-radius: 4px; cursor: pointer; font-size: 12px;">
                            Touch Dry</button>
                    </div>

                    <!-- Status -->
                    <div id="fluidics-status" style="margin-top: 10px; padding: 8px;
                        background: #e3f2fd; border-radius: 4px; font-size: 12px; display: none;">
                    </div>
                </div>
            </div>
        `;

        document.body.appendChild(panel);
        makeDraggable();
        setupEventHandlers();
        loadSavedSettings();
    }

    // Event handlers and functions
    function setupEventHandlers() {
        document.getElementById('toggle-fluidics').onclick = function() {
            const content = document.getElementById('fluidics-content');
            const button = this;
            if (content.style.display === 'none') {
                content.style.display = 'block';
                button.textContent = '-';
            } else {
                content.style.display = 'none';
                button.textContent = '+';
            }
        };
    }

    // Pump speed functions
    window.updatePumpSpeed = function(value) {
        document.getElementById('pump-speed-slider').value = value;
        document.getElementById('pump-speed-input').value = value;
        const percentage = Math.round((value / 255) * 100);
        document.getElementById('pump-speed-display').textContent = `${value} (${percentage}%)`;
    };

    window.setWashSpeed = function() {
        const speed = document.getElementById('pump-speed-input').value;
        sendGcode(`SET_WASH_SPEED SPEED=${speed}`);
        showStatus(`Wash pump speed set to ${speed}`);
        localStorage.setItem('pump-speed', speed);
    };

    window.setDrySpeed = function() {
        const speed = document.getElementById('pump-speed-input').value;
        sendGcode(`SET_DRY_SPEED SPEED=${speed}`);
        showStatus(`Waste pump speed set to ${speed}`);
        localStorage.setItem('pump-speed', speed);
    };

    // Syringe pump functions
    window.aspirateSyringe = function() {
        const steps = document.getElementById('syringe-steps').value;
        const feedrate = document.getElementById('syringe-feedrate').value;
        const command = `G91\nG1 E-${steps} F${feedrate}\nG90`;

        sendGcode(command);

        // Update step count (aspirate = negative)
        let currentCount = parseInt(localStorage.getItem('syringe-count') || '0');
        currentCount -= parseInt(steps);
        localStorage.setItem('syringe-count', currentCount);
        updateSyringeDisplay(currentCount);

        showStatus(`Aspirated ${steps} steps (F${feedrate})`);
    };

    window.dispenseSyringe = function() {
        const steps = document.getElementById('syringe-steps').value;
        const feedrate = document.getElementById('syringe-feedrate').value;
        const command = `G91\nG1 E${steps} F${feedrate}\nG90`;

        sendGcode(command);

        // Update step count (dispense = positive)
        let currentCount = parseInt(localStorage.getItem('syringe-count') || '0');
        currentCount += parseInt(steps);
        localStorage.setItem('syringe-count', currentCount);
        updateSyringeDisplay(currentCount);

        showStatus(`Dispensed ${steps} steps (F${feedrate})`);
    };

    window.zeroSyringeCount = function() {
        sendGcode('G92 E0');
        localStorage.setItem('syringe-count', '0');
        updateSyringeDisplay(0);
        showStatus('Syringe position reset to zero (G92 E0)');
    };

    function updateSyringeDisplay(count) {
        const display = document.getElementById('syringe-count-display');
        const direction = count > 0 ? 'dispensed' : count < 0 ? 'aspirated' : 'zero';
        const absCount = Math.abs(count);

        if (count === 0) {
            display.textContent = 'Position: 0 steps';
            display.style.background = 'rgba(156, 39, 176, 0.1)';
        } else if (count > 0) {
            display.textContent = `Position: +${count} steps (${direction})`;
            display.style.background = 'rgba(76, 175, 80, 0.1)';
        } else {
            display.textContent = `Position: ${count} steps (${direction})`;
            display.style.background = 'rgba(33, 150, 243, 0.1)';
        }
    }

    // Servo functions
    window.setPipetteHeight = function() {
        const angle = document.getElementById('servo-angle').value;
        sendGcode(`SET_SERVO_ANGLE_L0 ANGLE=${angle}`);
        showStatus(`Pipette height set to ${angle} degrees`);
        localStorage.setItem('servo-angle', angle);
    };

    window.setPresetAngle = function(angle) {
        document.getElementById('servo-angle').value = angle;
        setPipetteHeight();
    };

    window.disableServo = function() {
        sendGcode('DISABLE_LINEARACTUATOR_SERVO_L0');
        showStatus('Servo disabled');
    };

    // Tip selection
    window.selectTip = function() {
        const tip = document.getElementById('tip-selector').value;
        const command = tip === 'P100' ? 'SETP100' : 'SETP300';
        sendGcode(command);
        showStatus(`Selected ${tip} tip`);
        localStorage.setItem('selected-tip', tip);
    };

    // Send command function
    window.sendCommand = function(command) {
        sendGcode(command);
        showStatus(`Sent: ${command}`);
    };

    // Show status message
    function showStatus(message) {
        const status = document.getElementById('fluidics-status');
        status.textContent = message;
        status.style.display = 'block';
        setTimeout(() => status.style.display = 'none', 3000);
    }

    // Load saved settings
    function loadSavedSettings() {
        const pumpSpeed = localStorage.getItem('pump-speed') || '255';
        const servoAngle = localStorage.getItem('servo-angle') || '0';
        const selectedTip = localStorage.getItem('selected-tip') || 'P300';
        const syringeSteps = localStorage.getItem('syringe-steps') || '130';
        const syringeFeedrate = localStorage.getItem('syringe-feedrate') || '3000';
        const syringeCount = parseInt(localStorage.getItem('syringe-count') || '0');

        updatePumpSpeed(pumpSpeed);
        document.getElementById('servo-angle').value = servoAngle;
        document.getElementById('tip-selector').value = selectedTip;
        document.getElementById('syringe-steps').value = syringeSteps;
        document.getElementById('syringe-feedrate').value = syringeFeedrate;
        updateSyringeDisplay(syringeCount);
    }

    // Make panel draggable
    function makeDraggable() {
        const panel = document.getElementById('fluidics-main-panel');
        const header = document.getElementById('fluidics-header');
        let isDragging = false, currentX, currentY, initialX, initialY;

        // Get saved position or use defaults
        let xOffset = parseInt(localStorage.getItem('fluidics-panel-x')) || 10;
        let yOffset = parseInt(localStorage.getItem('fluidics-panel-y')) || 100;

        // Set initial position
        panel.style.left = xOffset + "px";
        panel.style.top = yOffset + "px";

        header.addEventListener('mousedown', dragStart);
        document.addEventListener('mousemove', drag);
        document.addEventListener('mouseup', dragEnd);

        function dragStart(e) {
            initialX = e.clientX - xOffset;
            initialY = e.clientY - yOffset;
            if (e.target === header || header.contains(e.target)) {
                isDragging = true;
            }
        }

        function drag(e) {
            if (isDragging) {
                e.preventDefault();
                currentX = e.clientX - initialX;
                currentY = e.clientY - initialY;
                xOffset = currentX;
                yOffset = currentY;
                panel.style.left = xOffset + "px";
                panel.style.top = yOffset + "px";
            }
        }

        function dragEnd() {
            initialX = currentX;
            initialY = currentY;
            isDragging = false;

            // Save position
            localStorage.setItem('fluidics-panel-x', xOffset);
            localStorage.setItem('fluidics-panel-y', yOffset);
        }
    }

    // Initialize
    setTimeout(() => {
        if (document.body) {
            createFluidicsPanel();
        }
    }, 2000);

})();
