// ==UserScript==
// @name         Object Editor & Macro Editor
// @namespace    http://tampermonkey.net/
// @version      2.1
// @description  Object positioning editor and macro generator for lab automation with Klipper/Mainsail
// @author       Rister
// @match        http://192.168.1.89:81/*
// @match        http://192.168.1.89/*
// @match        http://localhost:*/*
// @require      https://cdnjs.cloudflare.com/ajax/libs/p5.js/1.7.0/p5.min.js
// @grant        GM_xmlhttpRequest
// @grant        GM_setValue
// @grant        GM_getValue
// ==/UserScript==

(function() {
    'use strict';

    // Global variables accessible to both editors
    window.LabAutomationData = {
        objects: [],
        printerArea: { width: 380, height: 480 },
        savedMacros: [], // New array to store saved macros
        getObjectByName: function(name) {
            return this.objects.find(obj => obj.name === name);
        },
        getAllObjects: function() {
            return this.objects;
        },
        getWellCoordinates: function(objectName) {
            const obj = this.getObjectByName(objectName);
            if (!obj) return [];

            const coords = [];
            const rows = parseInt(obj.wellrow);
            const cols = parseInt(obj.wellcolumn);
            const rowSpacing = parseFloat(obj.wellrowsp);
            const colSpacing = parseFloat(obj.wellcolumnsp);
            const marginX = parseFloat(obj.marginx);
            const marginY = parseFloat(obj.marginy);
            const baseX = parseFloat(obj.posx);
            const baseY = parseFloat(obj.posy);

            for (let row = 0; row < rows; row++) {
                for (let col = 0; col < cols; col++) {
                    // X coordinates: object position is right edge, wells go leftward
                    const wellX = baseX - marginX - col * colSpacing;
                    const wellY = baseY + marginY + row * rowSpacing;
                    const wellName = String.fromCharCode(65 + row) + (col + 1);
                    coords.push({
                        name: wellName,
                        x: wellX,
                        y: wellY,
                        row: row,
                        col: col
                    });
                }
            }
            return coords;
        }
    };

    let sketch;
    let objects = [];
    let selectedObjectIndex = -1;
    let printerArea = { width: 380, height: 480 };
    let scale = 1;
    let offsetX = 0, offsetY = 0;
    let currentObjectId = 0;

    // Lab Object class
    class LabObject {
        constructor(name = "new_object") {
            this.id = currentObjectId++;
            this.name = name;
            this.catalog = "";
            this.status = "on";
            this.posx = "100";
            this.posy = "100";
            this.X = "75";
            this.Y = "20";
            this.Z = "29";
            this.marginx = "2";
            this.marginy = "10";
            this.shimx = "0";
            this.shimy = "0";
            this.wellrow = "1";
            this.wellcolumn = "8";
            this.wellrowsp = "9";
            this.wellcolumnsp = "9";
            this.shape = "square";
            this.shapex = "7.05";      // Well size X
            this.shapey = "7.05";      // Well size Y
            this.wellshape = "ellipse";
            this.color = "99,87,101";
            this.ztrav = "0";
        }

        draw(p) {
            if (this.status === "off") return;

            p.push();
            // Flip X coordinate: convert stored coordinate to display coordinate
            const displayX = (printerArea.width - parseFloat(this.posx) - parseFloat(this.X)) * scale + offsetX;
            const y = parseFloat(this.posy) * scale + offsetY;
            const width = parseFloat(this.X) * scale;
            const height = parseFloat(this.Y) * scale;

            p.translate(displayX, y);

            const [r, g, b] = this.color.split(',').map(c => parseInt(c.trim()));

            if (selectedObjectIndex === objects.indexOf(this)) {
                p.stroke(255, 255, 0);
                p.strokeWeight(3);
            } else {
                p.stroke(0);
                p.strokeWeight(1);
            }

            p.fill(r || 99, g || 87, b || 101, 180);
            p.rect(0, 0, width, height);

            if (parseInt(this.wellrow) > 1 || parseInt(this.wellcolumn) > 1) {
                this.drawWells(p, width, height);
            }

            p.fill(255);
            p.stroke(0);
            p.strokeWeight(1);
            p.textAlign(p.CENTER, p.CENTER);
            p.textSize(8);
            p.text(this.name, width/2, height/2);

            p.pop();
        }

        drawWells(p, width, height) {
            const rows = parseInt(this.wellrow);
            const cols = parseInt(this.wellcolumn);
            const rowSpacing = parseFloat(this.wellrowsp);
            const colSpacing = parseFloat(this.wellcolumnsp);
            const wellSizeX = parseFloat(this.shapex) * scale;
            const wellSizeY = parseFloat(this.shapey) * scale;

            p.fill(255, 255, 255, 200);
            p.stroke(0);
            p.strokeWeight(0.5);

            for (let row = 0; row < rows; row++) {
                for (let col = 0; col < cols; col++) {
                    // Wells positioned from right edge going leftward
                    const wellX = width - parseFloat(this.marginx) * scale - (col + 1) * colSpacing * scale;
                    const wellY = parseFloat(this.marginy) * scale + row * rowSpacing * scale;

                    if (this.wellshape === "ellipse") {
                        p.ellipse(wellX + wellSizeX/2, wellY + wellSizeY/2, wellSizeX, wellSizeY);
                    } else {
                        p.rect(wellX, wellY, wellSizeX, wellSizeY);
                    }
                }
            }
        }

        clone() {
            const newObj = new LabObject(this.name + "_copy");
            Object.keys(this).forEach(key => {
                if (key !== 'id' && key !== 'name') {
                    newObj[key] = this[key];
                }
            });
            newObj.posx = (parseFloat(this.posx) + 20).toString();
            newObj.posy = (parseFloat(this.posy) + 20).toString();
            return newObj;
        }
    }

    function createLabEditor() {
        createObjectEditor();
        createMacroEditor();
    }

    function createObjectEditor() {
        const panel = document.createElement('div');
        panel.id = 'lab-editor-panel';
        panel.innerHTML = `
            <div id="lab-main-panel" style="
                position: fixed;
                top: 20px;
                right: 10px;
                background: white;
                border: 2px solid #333;
                border-radius: 8px;
                padding: 15px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.2);
                z-index: 10000;
                width: 400px;
                max-height: 90vh;
                overflow-y: auto;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                font-size: 14px;
            ">
                <div id="lab-header" style="
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin-bottom: 15px;
                    cursor: move;
                    user-select: none;
                    background: #f0f0f0;
                    padding: 8px;
                    margin: -15px -15px 15px -15px;
                    border-radius: 6px 6px 0 0;
                ">
                    <h3 style="margin: 0; color: #333;">⬜ Object Editor</h3>
                    <button id="toggle-editor" style="
                        background: #666;
                        color: white;
                        border: none;
                        border-radius: 4px;
                        padding: 5px 8px;
                        cursor: pointer;
                    ">+</button>
                </div>

                <div id="editor-content" style="display: none;">
                    <div style="margin-bottom: 15px; padding: 10px; background: #fff3e0; border-radius: 4px; border: 1px solid #ff9800;">
                        <h4 style="margin: 0 0 10px 0; color: #e65100;">Printer Area Settings</h4>
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Width (mm):</label>
                                <input type="number" id="printer-area-width" step="1" min="100" value="${printerArea.width}">
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Height (mm):</label>
                                <input type="number" id="printer-area-height" step="1" min="100" value="${printerArea.height}">
                            </div>
                        </div>
                        <button id="btn-update-printer-area" style="
                            background: #ff9800; color: white; border: none; padding: 6px 12px;
                            border-radius: 4px; cursor: pointer; width: 100%; margin-top: 10px;
                        ">Update Printer Area</button>
                    </div>

                    <div style="margin-bottom: 15px;">
                        <h4 style="margin: 0 0 10px 0;">Printer Area (<span id="printer-area-display">${printerArea.width}x${printerArea.height}</span>mm)</h4>
                        <div id="p5-canvas-container" style="border: 2px solid #333; border-radius: 4px;"></div>
                        <div style="font-size: 10px; color: #666; margin-top: 5px;">Visual representation only - use position fields below to move objects</div>
                    </div>

                    <div style="display: flex; gap: 5px; margin-bottom: 15px;">
                        <button id="btn-new-object" style="
                            background: #4CAF50; color: white; border: none; padding: 8px 12px;
                            border-radius: 4px; cursor: pointer; flex: 1;
                        ">New Object</button>
                        <button id="btn-clone-object" style="
                            background: #2196F3; color: white; border: none; padding: 8px 12px;
                            border-radius: 4px; cursor: pointer; flex: 1;
                        ">Clone</button>
                        <button id="btn-delete-object" style="
                            background: #f44336; color: white; border: none; padding: 8px 12px;
                            border-radius: 4px; cursor: pointer; flex: 1;
                        ">Delete</button>
                    </div>

                    <div style="margin-bottom: 15px;">
                        <h4 style="margin: 0 0 10px 0;">Objects</h4>
                        <div id="object-list" style="max-height: 120px; overflow-y: auto; border: 1px solid #ccc; border-radius: 4px; padding: 5px;">
                            <em>No objects created yet</em>
                        </div>
                    </div>

                    <div id="object-editor" style="margin-bottom: 15px; padding: 10px; background: #f8f9fa; border-radius: 4px; border: 1px solid #ddd;">
                        <h4 style="margin: 0 0 15px 0;">Edit Object Properties</h4>
                        <div id="editing-indicator" style="background: #e3f2fd; padding: 5px 10px; margin: -10px -10px 15px -10px; border-radius: 4px 4px 0 0; font-size: 11px; color: #1976d2; font-weight: bold;">
                            Ready to create new object - click "New Object" button above
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 15px;">
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Name:</label>
                                <input type="text" id="obj-name">
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Catalog:</label>
                                <input type="text" id="obj-catalog">
                            </div>
                        </div>

                        <div style="margin-bottom: 15px;">
                            <label style="display: block; margin-bottom: 3px; font-weight: bold;">Status:</label>
                            <label><input type="radio" name="obj-status" value="on" checked> Active</label>
                            <label style="margin-left: 15px;"><input type="radio" name="obj-status" value="off"> Inactive</label>
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; margin-bottom: 15px;">
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Object Size X (mm):</label>
                                <input type="number" id="obj-X" step="0.1">
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Object Size Y (mm):</label>
                                <input type="number" id="obj-Y" step="0.1">
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Z (mm):</label>
                                <input type="number" id="obj-Z" step="0.1">
                            </div>
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 15px;">
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Position X:</label>
                                <input type="number" id="obj-posx" step="0.1">
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Position Y:</label>
                                <input type="number" id="obj-posy" step="0.1">
                            </div>
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 15px;">
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Well Rows:</label>
                                <input type="number" id="obj-wellrow" min="1">
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Well Columns:</label>
                                <input type="number" id="obj-wellcolumn" min="1">
                            </div>
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 15px;">
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Row Spacing:</label>
                                <input type="number" id="obj-wellrowsp" step="0.1">
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Col Spacing:</label>
                                <input type="number" id="obj-wellcolumnsp" step="0.1">
                            </div>
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr 1fr 1fr; gap: 10px; margin-bottom: 15px;">
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Margin X:</label>
                                <input type="number" id="obj-marginx" step="0.1">
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Margin Y:</label>
                                <input type="number" id="obj-marginy" step="0.1">
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Shim X:</label>
                                <input type="number" id="obj-shimx" step="0.1">
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Shim Y:</label>
                                <input type="number" id="obj-shimy" step="0.1">
                            </div>
                        </div>

                        <div style="margin-bottom: 15px;">
                            <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Well Shape:</label>
                            <label><input type="radio" name="well-shape" value="ellipse" checked> Ellipse (Round)</label>
                            <label style="margin-left: 15px;"><input type="radio" name="well-shape" value="square"> Square</label>
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; margin-bottom: 15px;">
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Well Size X:</label>
                                <input type="number" id="obj-shapex" step="0.01">
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Well Size Y:</label>
                                <input type="number" id="obj-shapey" step="0.01">
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Z Travel:</label>
                                <input type="number" id="obj-ztrav" step="0.1">
                            </div>
                        </div>

                        <div style="margin-bottom: 15px;">
                            <label style="display: block; margin-bottom: 3px; font-weight: bold;">Color:</label>
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <input type="color" id="obj-color-picker" style="
                                    width: 50px; height: 35px; border: 1px solid #ccc; border-radius: 4px;
                                    cursor: pointer; padding: 0; background: none;
                                ">
                                <input type="text" id="obj-color" placeholder="99,87,101" readonly style="
                                    flex: 1; background: #f9f9f9; color: #666;
                                ">
                            </div>
                        </div>

                        <div style="display: flex; gap: 10px;">
                            <button id="btn-save-changes" style="
                                background: #4CAF50; color: white; border: none; padding: 8px 15px;
                                border-radius: 4px; cursor: pointer; flex: 1;
                            ">Save Changes</button>
                            <button id="btn-cancel-edit" style="
                                background: #666; color: white; border: none; padding: 8px 15px;
                                border-radius: 4px; cursor: pointer; flex: 1;
                            ">Cancel</button>
                        </div>
                    </div>

                    <div style="margin-bottom: 15px;">
                        <h4 style="margin: 0 0 10px 0;">Object Coordinates</h4>
                        <textarea id="gcode-output" readonly style="
                            width: 100%; height: 120px; padding: 8px; border: 1px solid #ccc;
                            border-radius: 4px; font-family: monospace; font-size: 11px; background: #f9f9f9;
                        "></textarea>
                    </div>

                    <div style="display: flex; gap: 5px;">
                        <button id="btn-export-config" style="
                            background: #9C27B0; color: white; border: none; padding: 6px 12px;
                            border-radius: 4px; cursor: pointer; flex: 1;
                        ">Export Config</button>
                        <button id="btn-load-config" style="
                            background: #607D8B; color: white; border: none; padding: 6px 12px;
                            border-radius: 4px; cursor: pointer; flex: 1;
                        ">Load Config</button>
                    </div>
                </div>
            </div>
        `;

        document.body.appendChild(panel);
        initializeObjectEditor();
        makeDraggable('lab-main-panel', 'lab-header');
    }

    function createMacroEditor() {
        const panel = document.createElement('div');
        panel.id = 'macro-editor-panel';
        panel.innerHTML = `
            <div id="macro-main-panel" style="
                position: fixed; top: 20px; left: 10px; background: white; border: 2px solid #333;
                border-radius: 8px; padding: 15px; box-shadow: 0 4px 12px rgba(0,0,0,0.2);
                z-index: 10000; width: 350px; max-height: 90vh; overflow-y: auto;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; font-size: 14px;
            ">
                <div id="macro-header" style="
                    display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;
                    cursor: move; user-select: none; background: #f0f0f0; padding: 8px;
                    margin: -15px -15px 15px -15px; border-radius: 6px 6px 0 0;
                ">
                    <h3 style="margin: 0; color: #333;">🔧 G-code Builder</h3>
                    <button id="toggle-macro-editor" style="
                        background: #666; color: white; border: none; border-radius: 4px;
                        padding: 5px 8px; cursor: pointer;
                    ">+</button>
                </div>

                <div id="macro-editor-content" style="display: none;">
                    <div style="margin-bottom: 15px; padding: 10px; background: #e8f5e8; border-radius: 4px; border: 1px solid #4CAF50;">
                        <h4 style="margin: 0 0 10px 0; color: #2e7d32;">Position to Object</h4>

                        <div style="margin-bottom: 10px;">
                            <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Select Object:</label>
                            <select id="macro-object-select" style="
                                width: 100%; padding: 6px; border: 1px solid #ccc; border-radius: 4px; font-size: 12px;
                            ">
                                <option value="">Choose an object...</option>
                            </select>
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 10px;">
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Array Row:</label>
                                <input type="number" id="array-row" min="1" value="1" style="
                                    width: 100%; padding: 6px; border: 1px solid #ccc; border-radius: 4px; font-size: 12px;
                                ">
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Array Column:</label>
                                <input type="number" id="array-column" min="1" value="1" style="
                                    width: 100%; padding: 6px; border: 1px solid #ccc; border-radius: 4px; font-size: 12px;
                                ">
                            </div>
                        </div>

                        <div style="display: flex; gap: 5px; margin-bottom: 10px;">
                            <button id="btn-position-to-object" style="
                                background: #4CAF50; color: white; border: none; padding: 6px 12px;
                                border-radius: 4px; cursor: pointer; flex: 1;
                            ">Position to Object</button>
                            <button id="btn-position-to-array" style="
                                background: #FF9800; color: white; border: none; padding: 6px 12px;
                                border-radius: 4px; cursor: pointer; flex: 1;
                            ">Position to Array</button>
                        </div>

                        <button id="btn-refresh-objects" style="
                            background: #2196F3; color: white; border: none; padding: 6px 12px;
                            border-radius: 4px; cursor: pointer; width: 100%;
                        ">Refresh Object List</button>
                    </div>

                    <div style="margin-bottom: 15px;">
                        <h4 style="margin: 0 0 10px 0;">G-code Sequence Builder</h4>

                        <div style="margin-bottom: 10px;">
                            <label style="display: block; margin-bottom: 3px; font-weight: bold; font-size: 12px;">Sequence Name:</label>
                            <input type="text" id="macro-name" placeholder="Sample_Collection_Sequence" style="
                                width: 100%; padding: 6px; border: 1px solid #ccc; border-radius: 4px;
                                font-size: 12px;
                            ">
                        </div>

                        <textarea id="macro-output" style="
                            width: 100%; height: 200px; padding: 8px; border: 1px solid #ccc;
                            border-radius: 4px; font-family: monospace; font-size: 11px; background: #f9f9f9;
                        "></textarea>

                        <div style="font-size: 11px; color: #666; margin-top: 5px; margin-bottom: 10px;">
                            Ready-to-run G-code sequence. Copy and paste directly into Mainsail console or save as .gcode file.
                        </div>

                        <div style="display: flex; gap: 5px; margin-bottom: 15px;">
                            <button id="btn-save-macro" style="
                                background: #4CAF50; color: white; border: none; padding: 6px 12px;
                                border-radius: 4px; cursor: pointer; flex: 1;
                            ">Save Sequence</button>
                            <button id="btn-copy-gcode" style="
                                background: #2196F3; color: white; border: none; padding: 6px 12px;
                                border-radius: 4px; cursor: pointer; flex: 1;
                            ">Copy G-code</button>
                            <button id="btn-download-gcode" style="
                                background: #FF9800; color: white; border: none; padding: 6px 12px;
                                border-radius: 4px; cursor: pointer; flex: 1;
                            ">Download .gcode</button>
                        </div>
                    </div>

                    <div style="margin-bottom: 15px;">
                        <h4 style="margin: 0 0 10px 0;">Saved G-code Sequences</h4>

                        <div style="margin-bottom: 10px;">
                            <select id="saved-macros-select" multiple size="6" style="
                                width: 100%; padding: 6px; border: 1px solid #ccc; border-radius: 4px;
                                font-size: 12px; font-family: monospace;
                            ">
                                <option disabled style="color: #666;">No saved sequences yet</option>
                            </select>
                        </div>

                        <div style="display: flex; gap: 5px; margin-bottom: 10px;">
                            <button id="btn-move-up" style="
                                background: #9C27B0; color: white; border: none; padding: 6px 12px;
                                border-radius: 4px; cursor: pointer; flex: 1;
                            ">Move Up</button>
                            <button id="btn-move-down" style="
                                background: #9C27B0; color: white; border: none; padding: 6px 12px;
                                border-radius: 4px; cursor: pointer; flex: 1;
                            ">Move Down</button>
                        </div>

                        <div style="display: flex; gap: 5px;">
                            <button id="btn-combine-macros" style="
                                background: #607D8B; color: white; border: none; padding: 6px 12px;
                                border-radius: 4px; cursor: pointer; flex: 1;
                            ">Combine Selected</button>
                            <button id="btn-delete-macro" style="
                                background: #f44336; color: white; border: none; padding: 6px 12px;
                                border-radius: 4px; cursor: pointer; flex: 1;
                            ">Delete Selected</button>
                        </div>
                    </div>
                </div>
            </div>
        `;

        document.body.appendChild(panel);
        initializeMacroEditor();
        makeDraggable('macro-main-panel', 'macro-header');
    }

    function makeDraggable(panelId, headerId) {
        const panel = document.getElementById(panelId);
        const header = document.getElementById(headerId);
        let isDragging = false;
        let currentX, currentY, initialX, initialY;
        let xOffset = 0, yOffset = 0;

        // Set initial positions to prevent jumping
        if (panelId === 'lab-main-panel') {
            // Object Editor starts at top right
            panel.style.right = '10px';
            panel.style.top = '20px';
            panel.style.left = 'auto'; // Remove left positioning
        } else if (panelId === 'macro-main-panel') {
            // G-code Builder starts at top left
            panel.style.left = '10px';
            panel.style.top = '20px';
            panel.style.right = 'auto'; // Remove right positioning
        }

        header.addEventListener('mousedown', dragStart);
        document.addEventListener('mousemove', drag);
        document.addEventListener('mouseup', dragEnd);

        function dragStart(e) {
            if (e.target.id && e.target.id.includes('toggle')) return;

            // Get current position relative to viewport
            const rect = panel.getBoundingClientRect();
            initialX = e.clientX - rect.left;
            initialY = e.clientY - rect.top;

            isDragging = true;
            header.style.cursor = 'grabbing';

            // Switch to absolute positioning when dragging starts
            panel.style.position = 'fixed';
            panel.style.left = rect.left + 'px';
            panel.style.top = rect.top + 'px';
            panel.style.right = 'auto';
        }

        function drag(e) {
            if (isDragging) {
                e.preventDefault();
                currentX = e.clientX - initialX;
                currentY = e.clientY - initialY;

                const maxX = window.innerWidth - panel.offsetWidth;
                const maxY = window.innerHeight - panel.offsetHeight;

                currentX = Math.max(0, Math.min(currentX, maxX));
                currentY = Math.max(0, Math.min(currentY, maxY));

                panel.style.left = currentX + "px";
                panel.style.top = currentY + "px";
            }
        }

        function dragEnd() {
            isDragging = false;
            header.style.cursor = 'move';
        }
    }

    function initializeObjectEditor() {
        document.getElementById('toggle-editor').onclick = function() {
            const content = document.getElementById('editor-content');
            const button = this;
            if (content.style.display === 'none') {
                content.style.display = 'block';
                button.textContent = '−';
            } else {
                content.style.display = 'none';
                button.textContent = '+';
            }
        };

        document.getElementById('btn-new-object').addEventListener('click', createNewObject);
        document.getElementById('btn-clone-object').addEventListener('click', cloneObject);
        document.getElementById('btn-delete-object').addEventListener('click', deleteObject);
        document.getElementById('btn-save-changes').addEventListener('click', saveObjectChanges);
        document.getElementById('btn-cancel-edit').addEventListener('click', cancelObjectEdit);
        document.getElementById('btn-export-config').addEventListener('click', exportConfiguration);
        document.getElementById('btn-load-config').addEventListener('click', loadConfiguration);
        document.getElementById('btn-update-printer-area').addEventListener('click', updatePrinterArea);

        // Add color picker event listener
        document.getElementById('obj-color-picker').addEventListener('change', function(e) {
            const hexColor = e.target.value;
            const rgb = hexToRgb(hexColor);
            if (rgb) {
                document.getElementById('obj-color').value = `${rgb.r},${rgb.g},${rgb.b}`;
            }
        });

        sketch = new p5(function(p) {
            p.setup = function() {
                const canvas = p.createCanvas(380, 300);
                canvas.parent('p5-canvas-container');
                scale = 300 / printerArea.height;
                offsetX = 0;
                offsetY = 0;
                // Removed canvas.mousePressed(canvasClick); to disable click functionality
            };

            p.draw = function() {
                p.background(245);
                p.stroke(0);
                p.fill(255);
                p.rect(offsetX, offsetY, printerArea.width * scale, printerArea.height * scale);

                p.stroke(220);
                p.strokeWeight(0.5);
                for(let i = 0; i <= printerArea.width; i += 20) {
                    p.line(i * scale + offsetX, offsetY, i * scale + offsetX, printerArea.height * scale + offsetY);
                }
                for(let i = 0; i <= printerArea.height; i += 20) {
                    p.line(offsetX, i * scale + offsetY, printerArea.width * scale + offsetX, i * scale + offsetY);
                }

                objects.forEach(obj => obj.draw(p));

                p.fill(0);
                p.stroke(255);
                p.strokeWeight(1);
                p.textAlign(p.LEFT, p.TOP);
                // Flip X coordinate display for user - show flipped coordinate
                const flippedX = printerArea.width - Math.round(p.mouseX / scale);
                p.text(`Mouse: X${flippedX} Y${Math.round(p.mouseY / scale)}`, 5, 5);
            };
        });

        updateObjectList();
        generateGCode();
        setTimeout(autoLoadConfiguration, 500);
    }

    function updatePrinterArea() {
        const newWidth = parseFloat(document.getElementById('printer-area-width').value);
        const newHeight = parseFloat(document.getElementById('printer-area-height').value);

        if (isNaN(newWidth) || isNaN(newHeight) || newWidth < 100 || newHeight < 100) {
            alert('Please enter valid dimensions (minimum 100mm for both width and height)');
            return;
        }

        printerArea.width = newWidth;
        printerArea.height = newHeight;

        // Update the global data
        window.LabAutomationData.printerArea = printerArea;

        // Update the display title
        const displayElement = document.getElementById('printer-area-display');
        if (displayElement) {
            displayElement.textContent = `${printerArea.width}x${printerArea.height}`;
        }

        // Recreate the canvas with new dimensions
        if (sketch) {
            sketch.remove();
        }

        sketch = new p5(function(p) {
            p.setup = function() {
                const canvas = p.createCanvas(380, 300);
                canvas.parent('p5-canvas-container');
                scale = 300 / printerArea.height;
                offsetX = 0;
                offsetY = 0;
            };

            p.draw = function() {
                p.background(245);
                p.stroke(0);
                p.fill(255);
                p.rect(offsetX, offsetY, printerArea.width * scale, printerArea.height * scale);

                p.stroke(220);
                p.strokeWeight(0.5);
                for(let i = 0; i <= printerArea.width; i += 20) {
                    p.line(i * scale + offsetX, offsetY, i * scale + offsetX, printerArea.height * scale + offsetY);
                }
                for(let i = 0; i <= printerArea.height; i += 20) {
                    p.line(offsetX, i * scale + offsetY, printerArea.width * scale + offsetX, i * scale + offsetY);
                }

                objects.forEach(obj => obj.draw(p));

                p.fill(0);
                p.stroke(255);
                p.strokeWeight(1);
                p.textAlign(p.LEFT, p.TOP);
                const flippedX = printerArea.width - Math.round(p.mouseX / scale);
                p.text(`Mouse: X${flippedX} Y${Math.round(p.mouseY / scale)}`, 5, 5);
            };
        });

        generateGCode();
        autoSaveConfiguration();
        alert(`Printer area updated to ${newWidth}x${newHeight}mm`);
    }

    function initializeMacroEditor() {
        document.getElementById('toggle-macro-editor').onclick = function() {
            const content = document.getElementById('macro-editor-content');
            const button = this;
            if (content.style.display === 'none') {
                content.style.display = 'block';
                button.textContent = '−';
                refreshMacroObjectList();
                loadSavedMacros();
            } else {
                content.style.display = 'none';
                button.textContent = '+';
            }
        };

        document.getElementById('btn-refresh-objects').addEventListener('click', refreshMacroObjectList);
        document.getElementById('btn-position-to-object').addEventListener('click', addPositionToObject);
        document.getElementById('btn-position-to-array').addEventListener('click', addPositionToArray);
        document.getElementById('btn-save-macro').addEventListener('click', saveMacro);
        document.getElementById('btn-copy-gcode').addEventListener('click', copyGCode);
        document.getElementById('btn-download-gcode').addEventListener('click', downloadGCode);
        document.getElementById('btn-move-up').addEventListener('click', moveMacroUp);
        document.getElementById('btn-move-down').addEventListener('click', moveMacroDown);
        document.getElementById('btn-combine-macros').addEventListener('click', combineMacros);
        document.getElementById('btn-delete-macro').addEventListener('click', deleteMacro);

        // Auto-format sequence name as user types
        document.getElementById('macro-name').addEventListener('input', function(e) {
            e.target.value = e.target.value.replace(/[^a-zA-Z0-9_\-]/g, '');
        });

        // Load saved sequences when sequence select changes
        document.getElementById('saved-macros-select').addEventListener('change', function() {
            if (this.selectedOptions.length === 1) {
                loadMacroToEditor(this.selectedOptions[0].value);
            }
        });
    }

    function refreshMacroObjectList() {
        const selectElement = document.getElementById('macro-object-select');
        const objList = window.LabAutomationData.getAllObjects();

        // Clear existing options except the first one
        selectElement.innerHTML = '<option value="">Choose an object...</option>';

        if (objList.length === 0) {
            const option = document.createElement('option');
            option.value = '';
            option.textContent = 'No objects found - create some in Object Editor';
            option.disabled = true;
            selectElement.appendChild(option);
            return;
        }

        objList.forEach((obj, index) => {
            const option = document.createElement('option');
            option.value = obj.name;
            const statusIcon = obj.status === 'on' ? '✅' : '❌';
            const wellCount = parseInt(obj.wellrow) * parseInt(obj.wellcolumn);
            option.textContent = `${obj.name} ${statusIcon} (${wellCount} arrays)`;
            if (obj.status === 'off') {
                option.style.color = '#999';
            }
            selectElement.appendChild(option);
        });

        console.log('Refreshed macro object dropdown with', objList.length, 'objects');
    }

    function addPositionToObject() {
        const selectedObjectName = document.getElementById('macro-object-select').value;
        if (!selectedObjectName) {
            alert('Please select an object from the dropdown first');
            return;
        }

        const obj = window.LabAutomationData.getObjectByName(selectedObjectName);
        if (!obj) {
            alert('Object not found');
            return;
        }

        const sequenceName = document.getElementById('macro-name').value || 'Sample_Collection_Sequence';
        const currentGCode = document.getElementById('macro-output').value;

        let newCommand = '';
        if (!currentGCode.trim()) {
            newCommand = `; G-code Sequence: ${sequenceName}\n`;
            newCommand += `; Generated: ${new Date().toISOString()}\n`;
            newCommand += `; Ready to execute in Mainsail console\n\n`;
        }

        newCommand += `; Move to ${obj.name}\n`;
        newCommand += `G90  ; Absolute positioning\n`;
        newCommand += `G1 X${obj.posx} Y${obj.posy} F3000  ; Move to object position\n`;

        if (obj.ztrav !== "0") {
            newCommand += `G1 Z${obj.ztrav} F1500  ; Move to Z height\n`;
        }

        newCommand += `G4 P500  ; Pause 500ms for stabilization\n`;
        newCommand += `\n`;

        document.getElementById('macro-output').value = currentGCode + newCommand;
    }

// Fixed addPositionToArray function
function addPositionToArray() {
    const selectedObjectName = document.getElementById('macro-object-select').value;
    const arrayRow = parseInt(document.getElementById('array-row').value) - 1; // Convert to 0-based
    const arrayCol = parseInt(document.getElementById('array-column').value) - 1; // Convert to 0-based

    if (!selectedObjectName) {
        alert('Please select an object from the dropdown first');
        return;
    }

    if (isNaN(arrayRow) || isNaN(arrayCol) || arrayRow < 0 || arrayCol < 0) {
        alert('Please enter valid row and column numbers (starting from 1)');
        return;
    }

    const obj = window.LabAutomationData.getObjectByName(selectedObjectName);
    if (!obj) {
        alert('Object not found');
        return;
    }

    // Check if specified array position exists
    const maxRows = parseInt(obj.wellrow);
    const maxCols = parseInt(obj.wellcolumn);

    if (arrayRow >= maxRows || arrayCol >= maxCols) {
        alert(`Array position out of bounds. Object has ${maxRows} rows and ${maxCols} columns.`);
        return;
    }

    const sequenceName = document.getElementById('macro-name').value || 'Sample_Collection_Sequence';
    const currentGCode = document.getElementById('macro-output').value;

    // Calculate specific array position - FIXED CALCULATION
    const rowSpacing = parseFloat(obj.wellrowsp);
    const colSpacing = parseFloat(obj.wellcolumnsp);
    const marginX = parseFloat(obj.marginx);
    const marginY = parseFloat(obj.marginy);
    const baseX = parseFloat(obj.posx);
    const baseY = parseFloat(obj.posy);

    // CORRECTED: X coordinates should ADD margin and column offset
    // The object position (posx) is the reference point, wells go outward from there
    const wellX = baseX + marginX + arrayCol * colSpacing;
    const wellY = baseY + marginY + arrayRow * rowSpacing;
    const wellName = String.fromCharCode(65 + arrayRow) + (arrayCol + 1);

    let newCommand = '';
    if (!currentGCode.trim()) {
        newCommand = `; G-code Sequence: ${sequenceName}\n`;
        newCommand += `; Generated: ${new Date().toISOString()}\n`;
        newCommand += `; Ready to execute in Mainsail console\n\n`;
    }

    newCommand += `; Move to ${obj.name} well ${wellName}\n`;
    newCommand += `G90  ; Absolute positioning\n`;
    newCommand += `G1 X${wellX.toFixed(2)} Y${wellY.toFixed(2)} F3000  ; Move to well position\n`;

    if (obj.ztrav !== "0") {
        newCommand += `G1 Z${obj.ztrav} F1500  ; Move to Z height\n`;
    }

    newCommand += `G4 P500  ; Pause 500ms for stabilization\n`;
    newCommand += `\n`;

    document.getElementById('macro-output').value = currentGCode + newCommand;
}

// Also need to fix the getWellCoordinates function in the global data
window.LabAutomationData.getWellCoordinates = function(objectName) {
    const obj = this.getObjectByName(objectName);
    if (!obj) return [];

    const coords = [];
    const rows = parseInt(obj.wellrow);
    const cols = parseInt(obj.wellcolumn);
    const rowSpacing = parseFloat(obj.wellrowsp);
    const colSpacing = parseFloat(obj.wellcolumnsp);
    const marginX = parseFloat(obj.marginx);
    const marginY = parseFloat(obj.marginy);
    const baseX = parseFloat(obj.posx);
    const baseY = parseFloat(obj.posy);

    for (let row = 0; row < rows; row++) {
        for (let col = 0; col < cols; col++) {
            // CORRECTED: X coordinates should ADD margin and column offset
            const wellX = baseX + marginX + col * colSpacing;
            const wellY = baseY + marginY + row * rowSpacing;
            const wellName = String.fromCharCode(65 + row) + (col + 1);
            coords.push({
                name: wellName,
                x: wellX,
                y: wellY,
                row: row,
                col: col
            });
        }
    }
    return coords;
};




    function copyGCode() {
        const gcode = document.getElementById('macro-output').value;
        if (!gcode.trim()) {
            alert('No G-code to copy! Generate a sequence first.');
            return;
        }

        navigator.clipboard.writeText(gcode).then(() => {
            alert('G-code sequence copied to clipboard!\nYou can now paste it directly into Mainsail console.');
        }).catch(() => {
            const textArea = document.createElement('textarea');
            textArea.value = gcode;
            document.body.appendChild(textArea);
            textArea.select();
            document.execCommand('copy');
            document.body.removeChild(textArea);
            alert('G-code sequence copied to clipboard!\nYou can now paste it directly into Mainsail console.');
        });
    }

    function downloadGCode() {
        const gcode = document.getElementById('macro-output').value;
        const sequenceName = document.getElementById('macro-name').value || 'sequence';

        if (!gcode.trim()) {
            alert('No G-code to download! Generate a sequence first.');
            return;
        }

        const fileName = `${sequenceName}_${new Date().toISOString().slice(0, 10)}.gcode`;
        const blob = new Blob([gcode], { type: 'text/plain' });
        const url = URL.createObjectURL(blob);

        const link = document.createElement('a');
        link.href = url;
        link.download = fileName;
        link.style.display = 'none';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);

        alert(`G-code sequence downloaded as ${fileName}!\nYou can upload this file to Mainsail and run it directly.`);
    }

    function saveMacro() {
        const sequenceName = document.getElementById('macro-name').value.trim();
        const gcodeContent = document.getElementById('macro-output').value.trim();

        if (!sequenceName) {
            alert('Please enter a sequence name');
            return;
        }

        if (!gcodeContent) {
            alert('Please create some G-code content first');
            return;
        }

        // Check if sequence name already exists
        const existingIndex = window.LabAutomationData.savedMacros.findIndex(m => m.name === sequenceName);

        if (existingIndex !== -1) {
            if (!confirm(`G-code sequence "${sequenceName}" already exists. Do you want to overwrite it?`)) {
                return;
            }
            window.LabAutomationData.savedMacros[existingIndex] = {
                name: sequenceName,
                content: gcodeContent
            };
        } else {
            window.LabAutomationData.savedMacros.push({
                name: sequenceName,
                content: gcodeContent
            });
        }

        saveMacrosToStorage();
        updateSavedMacrosList();
        alert(`G-code sequence "${sequenceName}" saved successfully!`);
    }

    function loadSavedMacros() {
        const savedMacros = GM_getValue('lab_automation_macros', '[]');
        try {
            window.LabAutomationData.savedMacros = JSON.parse(savedMacros);
            updateSavedMacrosList();
        } catch (error) {
            console.log('Error loading saved macros:', error);
            window.LabAutomationData.savedMacros = [];
        }
    }

    function saveMacrosToStorage() {
        const macrosJson = JSON.stringify(window.LabAutomationData.savedMacros);
        GM_setValue('lab_automation_macros', macrosJson);
    }

    function updateSavedMacrosList() {
        const selectElement = document.getElementById('saved-macros-select');
        selectElement.innerHTML = '';

        if (window.LabAutomationData.savedMacros.length === 0) {
            const option = document.createElement('option');
            option.disabled = true;
            option.style.color = '#666';
            option.textContent = 'No saved sequences yet';
            selectElement.appendChild(option);
            return;
        }

        window.LabAutomationData.savedMacros.forEach((sequence, index) => {
            const option = document.createElement('option');
            option.value = index;
            option.textContent = sequence.name;
            selectElement.appendChild(option);
        });
    }

    function loadMacroToEditor(sequenceIndex) {
        const sequence = window.LabAutomationData.savedMacros[parseInt(sequenceIndex)];
        if (sequence) {
            document.getElementById('macro-name').value = sequence.name;
            document.getElementById('macro-output').value = sequence.content;
        }
    }

    function moveMacroUp() {
        const selectElement = document.getElementById('saved-macros-select');
        const selectedOptions = Array.from(selectElement.selectedOptions);

        if (selectedOptions.length !== 1) {
            alert('Please select exactly one macro to move');
            return;
        }

        const index = parseInt(selectedOptions[0].value);
        if (index > 0) {
            const macros = window.LabAutomationData.savedMacros;
            [macros[index - 1], macros[index]] = [macros[index], macros[index - 1]];
            saveMacrosToStorage();
            updateSavedMacrosList();
            // Re-select the moved item
            selectElement.options[index - 1].selected = true;
        }
    }

    function moveMacroDown() {
        const selectElement = document.getElementById('saved-macros-select');
        const selectedOptions = Array.from(selectElement.selectedOptions);

        if (selectedOptions.length !== 1) {
            alert('Please select exactly one macro to move');
            return;
        }

        const index = parseInt(selectedOptions[0].value);
        const macros = window.LabAutomationData.savedMacros;

        if (index < macros.length - 1) {
            [macros[index], macros[index + 1]] = [macros[index + 1], macros[index]];
            saveMacrosToStorage();
            updateSavedMacrosList();
            // Re-select the moved item
            selectElement.options[index + 1].selected = true;
        }
    }

    function combineMacros() {
        const selectElement = document.getElementById('saved-macros-select');
        const selectedOptions = Array.from(selectElement.selectedOptions);

        if (selectedOptions.length < 2) {
            alert('Please select at least 2 G-code sequences to combine');
            return;
        }

        const selectedSequences = selectedOptions.map(option =>
            window.LabAutomationData.savedMacros[parseInt(option.value)]
        );

        // Create combined G-code content
        let combinedContent = `; Combined G-code Sequence\n`;
        combinedContent += `; Generated: ${new Date().toISOString()}\n`;
        combinedContent += `; Combined from: ${selectedSequences.map(s => s.name).join(', ')}\n`;
        combinedContent += `; Ready to execute in Mainsail console\n\n`;

        selectedSequences.forEach((sequence, index) => {
            combinedContent += `; --- Sequence ${index + 1}: ${sequence.name} ---\n`;

            // Clean the content by removing headers and comments if it's already a sequence
            const lines = sequence.content.split('\n');
            let addingContent = false;

            lines.forEach(line => {
                const trimmedLine = line.trim();
                // Skip header comments but keep G-code commands and operation comments
                if (trimmedLine.startsWith('; Generated:') ||
                    trimmedLine.startsWith('; G-code Sequence:') ||
                    trimmedLine.startsWith('; Ready to execute') ||
                    trimmedLine.startsWith('; Combined')) {
                    return;
                }

                if (trimmedLine.length > 0) {
                    combinedContent += line + '\n';
                }
            });
            combinedContent += '\n';
        });

        // Load combined content into editor
        document.getElementById('macro-name').value = 'Combined_Sequence';
        document.getElementById('macro-output').value = combinedContent;

        alert(`Combined ${selectedSequences.length} G-code sequences. You can now edit and save the combined sequence.`);
    }

    function deleteMacro() {
        const selectElement = document.getElementById('saved-macros-select');
        const selectedOptions = Array.from(selectElement.selectedOptions);

        if (selectedOptions.length === 0) {
            alert('Please select macro(s) to delete');
            return;
        }

        const macroNames = selectedOptions.map(option =>
            window.LabAutomationData.savedMacros[parseInt(option.value)].name
        );

        if (!confirm(`Are you sure you want to delete the following macro(s)?\n${macroNames.join('\n')}`)) {
            return;
        }

        // Sort indices in descending order to avoid index shifting issues
        const indices = selectedOptions.map(option => parseInt(option.value)).sort((a, b) => b - a);

        indices.forEach(index => {
            window.LabAutomationData.savedMacros.splice(index, 1);
        });

        saveMacrosToStorage();
        updateSavedMacrosList();
        alert(`Deleted ${indices.length} macro(s)`);
    }

    // Removed canvasClick function entirely since we don't want click-to-move functionality

    function createNewObject() {
        const newObj = new LabObject(`object_${objects.length + 1}`);
        objects.push(newObj);
        selectObject(objects.length - 1);
        updateObjectList();
        generateGCode();
        autoSaveConfiguration();
    }

    function cloneObject() {
        if (selectedObjectIndex === -1) {
            alert('Please select an object to clone');
            return;
        }
        const clonedObj = objects[selectedObjectIndex].clone();
        objects.push(clonedObj);
        selectObject(objects.length - 1);
        updateObjectList();
        generateGCode();
        autoSaveConfiguration();
    }

    function deleteObject() {
        if (selectedObjectIndex === -1) {
            alert('Please select an object to delete');
            return;
        }

        const objName = objects[selectedObjectIndex].name;
        if (confirm(`Are you sure you want to delete "${objName}"?`)) {
            objects.splice(selectedObjectIndex, 1);
            selectedObjectIndex = -1;
            document.getElementById('editing-indicator').textContent = 'Ready to create new object - click "New Object" button above';
            document.getElementById('editing-indicator').style.background = '#e3f2fd';
            document.getElementById('editing-indicator').style.color = '#1976d2';
            updateObjectList();
            generateGCode();
            autoSaveConfiguration();
        }
    }

    function selectObject(index) {
        selectedObjectIndex = index;
        updateObjectList();
        showObjectEditor(objects[index]);
    }

    function showObjectEditor(obj) {
        const indicator = document.getElementById('editing-indicator');
        if (indicator) {
            indicator.textContent = `Editing: ${obj.name} (Object ${selectedObjectIndex + 1})`;
            indicator.style.background = '#c8e6c9';
            indicator.style.color = '#2e7d32';
        }
        populateObjectEditor(obj);
    }

    function populateObjectEditor(obj) {
        const elements = {
            name: document.getElementById('obj-name'),
            catalog: document.getElementById('obj-catalog'),
            X: document.getElementById('obj-X'),
            Y: document.getElementById('obj-Y'),
            Z: document.getElementById('obj-Z'),
            posx: document.getElementById('obj-posx'),
            posy: document.getElementById('obj-posy'),
            shapex: document.getElementById('obj-shapex'),
            shapey: document.getElementById('obj-shapey'),
            ztrav: document.getElementById('obj-ztrav')
        };

        if (elements.name) elements.name.value = obj.name;
        if (elements.catalog) elements.catalog.value = obj.catalog;

        const statusRadio = document.querySelector(`input[name="obj-status"][value="${obj.status}"]`);
        if (statusRadio) statusRadio.checked = true;

        if (elements.X) elements.X.value = obj.X;
        if (elements.Y) elements.Y.value = obj.Y;
        if (elements.Z) elements.Z.value = obj.Z;
        if (elements.posx) elements.posx.value = obj.posx;
        if (elements.posy) elements.posy.value = obj.posy;
        if (elements.shapex) elements.shapex.value = obj.shapex;
        if (elements.shapey) elements.shapey.value = obj.shapey;
        if (elements.ztrav) elements.ztrav.value = obj.ztrav;

        const fields = ['wellrow', 'wellcolumn', 'wellrowsp', 'wellcolumnsp', 'marginx', 'marginy', 'shimx', 'shimy'];
        fields.forEach(field => {
            const el = document.getElementById(`obj-${field}`);
            if (el) el.value = obj[field];
        });

        const wellShapeRadio = document.querySelector(`input[name="well-shape"][value="${obj.wellshape || 'ellipse'}"]`);
        if (wellShapeRadio) wellShapeRadio.checked = true;

        const color = document.getElementById('obj-color');
        if (color) color.value = obj.color;

        // Update color picker to match the RGB value
        const colorPicker = document.getElementById('obj-color-picker');
        if (colorPicker && obj.color) {
            const rgbValues = obj.color.split(',').map(c => parseInt(c.trim()));
            if (rgbValues.length === 3) {
                const hexColor = rgbToHex(rgbValues[0], rgbValues[1], rgbValues[2]);
                colorPicker.value = hexColor;
            }
        }
    }

    function saveObjectChanges() {
        if (selectedObjectIndex === -1) {
            alert('No object selected to save!');
            return;
        }

        const obj = objects[selectedObjectIndex];

        try {
            const nameInput = document.getElementById('obj-name');
            const catalogInput = document.getElementById('obj-catalog');
            const statusRadio = document.querySelector('input[name="obj-status"]:checked');

            if (nameInput) obj.name = nameInput.value;
            if (catalogInput) obj.catalog = catalogInput.value;
            if (statusRadio) obj.status = statusRadio.value;

            ['X', 'Y', 'Z', 'posx', 'posy', 'wellrow', 'wellcolumn', 'wellrowsp', 'wellcolumnsp',
             'marginx', 'marginy', 'shimx', 'shimy', 'shapex', 'shapey', 'ztrav'].forEach(field => {
                const input = document.getElementById(`obj-${field}`);
                if (input) obj[field] = input.value;
            });

            obj.shape = "square";

            const wellShapeRadio = document.querySelector('input[name="well-shape"]:checked');
            if (wellShapeRadio) obj.wellshape = wellShapeRadio.value;

            const colorInput = document.getElementById('obj-color');
            if (colorInput) obj.color = colorInput.value;

            updateObjectList();
            generateGCode();
            autoSaveConfiguration();
            alert('Object saved successfully!');

        } catch (error) {
            alert('Error saving object: ' + error.message);
        }
    }

    function cancelObjectEdit() {
        if (selectedObjectIndex !== -1) {
            populateObjectEditor(objects[selectedObjectIndex]);
            alert('Changes cancelled - form reset to original values');
        }
    }

    function updateObjectList() {
        const listDiv = document.getElementById('object-list');

        if (objects.length === 0) {
            listDiv.innerHTML = '<em>No objects created yet</em>';
            return;
        }

        let html = '';
        objects.forEach((obj, index) => {
            const isSelected = index === selectedObjectIndex;
            const statusIcon = obj.status === 'on' ? '✅' : '❌';
            html += `
                <div data-object-index="${index}" style="
                    display: flex; justify-content: space-between; align-items: center; padding: 8px;
                    border-bottom: 1px solid #eee; cursor: pointer;
                    background: ${isSelected ? '#e3f2fd' : 'transparent'};
                    border-left: ${isSelected ? '4px solid #2196F3' : '4px solid transparent'};
                ">
                    <div>
                        <strong>${obj.name}</strong> ${statusIcon}<br>
                        <small>Pos: (${obj.posx}, ${obj.posy}) | Size: ${obj.X}×${obj.Y}</small>
                    </div>
                    <div style="font-size: 10px; color: #666;">
                        Wells: ${obj.wellrow}×${obj.wellcolumn}
                    </div>
                </div>
            `;
        });

        listDiv.innerHTML = html;

        listDiv.querySelectorAll('[data-object-index]').forEach(item => {
            item.addEventListener('click', function() {
                const index = parseInt(this.getAttribute('data-object-index'));
                selectObject(index);
            });
        });
    }

    function generateGCode() {
        let output = `; Object Coordinates for Lab Automation\n`;
        output += `; Total active objects: ${objects.filter(obj => obj.status === 'on').length}\n`;
        output += `; Generated: ${new Date().toISOString()}\n\n`;

        objects.forEach((obj, index) => {
            if (obj.status === 'on') {
                output += `; Object ${index + 1}: ${obj.name}\n`;
                output += `; Position: X${obj.posx} Y${obj.posy} Z${obj.Z}\n`;
                output += `; Size: ${obj.X} x ${obj.Y} x ${obj.Z}mm\n`;

                if (parseInt(obj.wellrow) > 1 || parseInt(obj.wellcolumn) > 1) {
                    output += `; Wells: ${obj.wellrow} rows x ${obj.wellcolumn} columns\n`;
                    output += `; Well spacing: ${obj.wellrowsp} x ${obj.wellcolumnsp}mm\n`;

                    const rows = parseInt(obj.wellrow);
                    const cols = parseInt(obj.wellcolumn);
                    const rowSpacing = parseFloat(obj.wellrowsp);
                    const colSpacing = parseFloat(obj.wellcolumnsp);
                    const marginX = parseFloat(obj.marginx);
                    const marginY = parseFloat(obj.marginy);
                    const baseX = parseFloat(obj.posx);
                    const baseY = parseFloat(obj.posy);

                    for (let row = 0; row < rows; row++) {
                        for (let col = 0; col < cols; col++) {
                            const wellX = baseX + marginX + col * colSpacing;
                            const wellY = baseY + marginY + row * rowSpacing;
                            const wellName = String.fromCharCode(65 + row) + (col + 1);
                            output += `;   Well ${wellName}: X${wellX.toFixed(2)} Y${wellY.toFixed(2)}\n`;
                        }
                    }
                } else {
                    output += `;   Center point: X${obj.posx} Y${obj.posy}\n`;
                }

                output += `; Color: RGB(${obj.color})\n`;
                output += `; Shape: ${obj.shape} (${obj.X} x ${obj.Y})\n`;
                if (obj.ztrav !== "0") {
                    output += `; Z-travel: ${obj.ztrav}mm\n`;
                }
                output += '\n';
            }
        });

        const outputArea = document.getElementById('gcode-output');
        if (outputArea) {
            outputArea.value = output;
        }
    }

    function autoSaveConfiguration() {
        const config = {
            objects: objects,
            printerArea: printerArea,
            timestamp: new Date().toISOString(),
            version: '2.1'
        };

        const dataStr = JSON.stringify(config, null, 2);
        GM_setValue('lab_automation_config', dataStr);
        window.LabAutomationData.objects = objects;
        window.LabAutomationData.printerArea = printerArea;
    }

    function autoLoadConfiguration() {
        const savedConfig = GM_getValue('lab_automation_config', null);
        if (savedConfig) {
            try {
                const config = JSON.parse(savedConfig);
                loadConfigurationData(config);
                return true;
            } catch (error) {
                console.log('Error auto-loading configuration:', error);
            }
        }
        return false;
    }

    function loadConfigurationData(config) {
        if (config.objects) {
            objects = [];
            config.objects.forEach(objData => {
                const obj = new LabObject(objData.name);
                Object.assign(obj, objData);
                objects.push(obj);
            });
        }

        if (config.printerArea) {
            printerArea = config.printerArea;
            window.LabAutomationData.printerArea = printerArea;

            // Update the input fields with loaded printer area
            const widthInput = document.getElementById('printer-area-width');
            const heightInput = document.getElementById('printer-area-height');
            if (widthInput) widthInput.value = printerArea.width;
            if (heightInput) heightInput.value = printerArea.height;

            // Update the display
            const displayElement = document.getElementById('printer-area-display');
            if (displayElement) {
                displayElement.textContent = `${printerArea.width}x${printerArea.height}`;
            }
        }

        window.LabAutomationData.objects = objects;

        selectedObjectIndex = -1;
        updateObjectList();
        generateGCode();

        // Recreate canvas with loaded printer area dimensions
        if (sketch) {
            sketch.remove();
            sketch = new p5(function(p) {
                p.setup = function() {
                    const canvas = p.createCanvas(380, 300);
                    canvas.parent('p5-canvas-container');
                    scale = 300 / printerArea.height;
                    offsetX = 0;
                    offsetY = 0;
                };

                p.draw = function() {
                    p.background(245);
                    p.stroke(0);
                    p.fill(255);
                    p.rect(offsetX, offsetY, printerArea.width * scale, printerArea.height * scale);

                    p.stroke(220);
                    p.strokeWeight(0.5);
                    for(let i = 0; i <= printerArea.width; i += 20) {
                        p.line(i * scale + offsetX, offsetY, i * scale + offsetX, printerArea.height * scale + offsetY);
                    }
                    for(let i = 0; i <= printerArea.height; i += 20) {
                        p.line(offsetX, i * scale + offsetY, printerArea.width * scale + offsetX, i * scale + offsetY);
                    }

                    objects.forEach(obj => obj.draw(p));

                    p.fill(0);
                    p.stroke(255);
                    p.strokeWeight(1);
                    p.textAlign(p.LEFT, p.TOP);
                    const flippedX = printerArea.width - Math.round(p.mouseX / scale);
                    p.text(`Mouse: X${flippedX} Y${Math.round(p.mouseY / scale)}`, 5, 5);
                };
            });
        }
    }

    function exportConfiguration() {
        const config = {
            objects: objects,
            printerArea: printerArea,
            timestamp: new Date().toISOString(),
            version: '2.1'
        };

        const dataStr = JSON.stringify(config, null, 2);
        const fileName = `object_editor_config_${new Date().toISOString().slice(0, 10)}.json`;

        const blob = new Blob([dataStr], { type: 'application/json' });
        const url = URL.createObjectURL(blob);

        const link = document.createElement('a');
        link.href = url;
        link.download = fileName;
        link.style.display = 'none';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);

        autoSaveConfiguration();
        alert(`Configuration exported as ${fileName}!`);
    }

    function loadConfiguration() {
        const input = document.createElement('input');
        input.type = 'file';
        input.accept = '.json';

        input.onchange = function(event) {
            const file = event.target.files[0];
            if (!file) return;

            const reader = new FileReader();
            reader.onload = function(e) {
                try {
                    const config = JSON.parse(e.target.result);
                    loadConfigurationData(config);
                    autoSaveConfiguration();
                    alert(`Configuration loaded from ${file.name} successfully!`);
                } catch (error) {
                    alert('Error loading configuration file: Invalid JSON format');
                }
            };
            reader.readAsText(file);
        };
        input.click();
    }

    // Helper functions for color conversion
    function hexToRgb(hex) {
        const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        return result ? {
            r: parseInt(result[1], 16),
            g: parseInt(result[2], 16),
            b: parseInt(result[3], 16)
        } : null;
    }

    function rgbToHex(r, g, b) {
        return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
    }

    function waitForPageLoad() {
        if (document.readyState === 'complete' || document.readyState === 'interactive') {
            setTimeout(() => {
                createLabEditor();
            }, 2000);
        } else {
            setTimeout(waitForPageLoad, 100);
        }
    }

    waitForPageLoad();

    const style = document.createElement('style');
    style.textContent = `
        #lab-main-panel *, #macro-main-panel * { box-sizing: border-box; }

        #lab-main-panel input, #lab-main-panel textarea,
        #macro-main-panel input, #macro-main-panel textarea,
        #macro-main-panel select {
            width: 100% !important; padding: 4px !important; border: 1px solid #ccc !important;
            border-radius: 3px !important; font-size: 12px !important;
        }

        #lab-main-panel input:focus, #lab-main-panel textarea:focus,
        #macro-main-panel input:focus, #macro-main-panel textarea:focus,
        #macro-main-panel select:focus {
            outline: 2px solid #2196F3; outline-offset: -2px;
        }

        #lab-main-panel button:hover, #macro-main-panel button:hover {
            opacity: 0.9; transform: translateY(-1px);
        }

        #lab-main-panel button:active, #macro-main-panel button:active {
            transform: translateY(0);
        }

        #lab-main-panel ::-webkit-scrollbar, #macro-main-panel ::-webkit-scrollbar {
            width: 8px;
        }

        #lab-main-panel ::-webkit-scrollbar-track, #macro-main-panel ::-webkit-scrollbar-track {
            background: #f1f1f1; border-radius: 4px;
        }

        #lab-main-panel ::-webkit-scrollbar-thumb, #macro-main-panel ::-webkit-scrollbar-thumb {
            background: #888; border-radius: 4px;
        }

        #lab-main-panel ::-webkit-scrollbar-thumb:hover, #macro-main-panel ::-webkit-scrollbar-thumb:hover {
            background: #555;
        }

        #saved-macros-select option:checked {
            background: #2196F3 !important;
            color: white !important;
        }
    `;
    document.head.appendChild(style);

    document.addEventListener('keydown', function(e) {
        if (!document.getElementById('lab-editor-panel')) return;
        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') return;

        switch(e.key) {
            case 'n':
                if (e.ctrlKey) {
                    e.preventDefault();
                    createNewObject();
                }
                break;
            case 'd':
                if (e.ctrlKey && selectedObjectIndex !== -1) {
                    e.preventDefault();
                    cloneObject();
                }
                break;
            case 'Delete':
                if (selectedObjectIndex !== -1) {
                    e.preventDefault();
                    deleteObject();
                }
                break;
            case 'g':
                if (e.ctrlKey) {
                    e.preventDefault();
                    generateGCode();
                }
                break;
            case 'Escape':
                cancelObjectEdit();
                break;
        }
    });

})();

