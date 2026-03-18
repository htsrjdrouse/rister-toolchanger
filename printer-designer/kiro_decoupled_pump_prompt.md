# Kiro Feature Prompt: Decoupled Pump Mode for ShapeDesigner

## Context

File: `client/src/components/ShapeDesigner.js`

This component generates G-code for a syringe pump dispensing system on a Klipper-based CoreXY toolchanger. Currently, the XY motion feedrate and extruder (pump) feedrate are coupled in a single `G1 Y{yEnd} E{currentE} F{feedrate}` command. A new hardware architecture decouples these: the syringe pump runs on a separate Arduino controller triggered by a Klipper output pin, allowing the XY and pump to run at independent feedrates. This is necessary because the minimum streaming flow rate for a 30G needle is F4000, but the XY needs to run at F8000–F18000 to achieve thin line widths. Without decoupling, the G-code cannot achieve the low volume-per-mm needed for sub-300µm lines.

---

## Feature: Decoupled Pump Mode

### 1. Add new fields to `DEFAULT_SETTINGS`

```js
decoupledPump: false,         // toggle decoupled Arduino pump mode
pumpFeedrate: 4000,           // mm/min — Arduino pump rate (independent of XY)
triggerDelayMs: 50,           // ms — delay between trigger firing and pump starting
triggerPin: 'dispense_trigger', // Klipper output pin name
```

### 2. Add UI section in the Motion panel (after existing Dispense Speed field)

Insert after the `Dispense Speed (mm/min)` label block (around line 883), before `Dispense Acceleration`:

```jsx
{/* Decoupled Pump Mode toggle */}
<label style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '4px' }}>
  <input
    type="checkbox"
    checked={settings.decoupledPump || false}
    onChange={(e) => updateSetting('decoupledPump', e.target.checked)}
  />
  <span>Decoupled pump mode (Arduino controller)</span>
</label>
<small style={{ color: '#888', fontSize: '10px', marginLeft: '24px', display: 'block', marginBottom: '8px' }}>
  XY and pump run at independent feedrates. Pump triggered via Klipper output pin.
</small>

{settings.decoupledPump && (
  <>
    <label>
      <span>XY Feedrate (mm/min)</span>
      {/* This reuses existing settings.feedrate field — label change only when decoupled */}
      <NumInput
        step="100"
        min="100"
        value={settings.feedrate}
        onChange={(v) => updateSetting('feedrate', v)}
        fallback={8000}
        integer
      />
      <small style={{ color: '#888', fontSize: '10px' }}>
        XY motion speed — independent of pump. Target: F8000–F18000 for thin lines.
      </small>
    </label>
    <label>
      <span>Pump Feedrate (mm/min)</span>
      <NumInput
        step="100"
        min="100"
        value={settings.pumpFeedrate || 4000}
        onChange={(v) => updateSetting('pumpFeedrate', v)}
        fallback={4000}
        integer
      />
      <small style={{ color: '#888', fontSize: '10px' }}>
        Arduino pump rate. Min streaming threshold 30G = F4000. Must not go lower.
      </small>
    </label>
    <label>
      <span>Trigger Delay (ms)</span>
      <NumInput
        step="10"
        min="0"
        value={settings.triggerDelayMs ?? 50}
        onChange={(v) => updateSetting('triggerDelayMs', v)}
        fallback={50}
        integer
      />
      <small style={{ color: '#888', fontSize: '10px' }}>
        Delay between trigger pin HIGH and pump starting (on Arduino). Start at 50ms, tune empirically.
      </small>
    </label>
    <label>
      <span>Klipper Trigger Pin Name</span>
      <input
        type="text"
        value={settings.triggerPin || 'dispense_trigger'}
        onChange={(e) => updateSetting('triggerPin', e.target.value)}
        style={{ width: '100%', padding: '4px', fontFamily: 'monospace', fontSize: '12px' }}
      />
      <small style={{ color: '#888', fontSize: '10px' }}>
        Must match [output_pin] name in printer.cfg
      </small>
    </label>

    {/* Estimated line width display */}
    {(() => {
      const xySpeed = (settings.feedrate || 8000) / 60;         // mm/s
      const pumpSpeed = (settings.pumpFeedrate || 4000) / 60;   // mm/s = µL/s (calibrated)
      const volPerMm = pumpSpeed / xySpeed;                      // µL/mm
      const z = settings.zHeight || 0.3;
      const needleId = NEEDLE_GAUGES[settings.needleGauge] || 0.260;
      const geomW = Math.max(Math.sqrt(volPerMm / (Math.PI * z)) * 1000, needleId * 1000);
      const ratio = ((settings.pumpFeedrate || 4000) / (settings.feedrate || 8000)).toFixed(2);
      return (
        <div style={{ 
          background: 'rgba(0,217,255,0.08)', 
          border: '1px solid rgba(0,217,255,0.2)',
          borderRadius: '4px', 
          padding: '8px', 
          marginTop: '8px',
          fontSize: '11px'
        }}>
          <div style={{ fontWeight: 'bold', color: '#00d9ff', marginBottom: '4px' }}>
            Estimated line geometry
          </div>
          <div>Pump/XY ratio: {ratio} ({(volPerMm * 1000).toFixed(2)} nL/mm)</div>
          <div>Vol/mm: {volPerMm.toFixed(4)} µL/mm</div>
          <div style={{ color: geomW <= 250 ? '#4CAF50' : geomW <= 400 ? '#ff9800' : '#f44336', fontWeight: 'bold' }}>
            Est. geometric width: ~{Math.round(geomW)} µm
            {geomW <= 250 ? ' ✓ target range' : geomW <= 400 ? ' ⚠ marginal' : ' ✗ above target'}
          </div>
          <div style={{ color: '#888', marginTop: '2px' }}>
            Actual width wider due to spreading. Substrate 60°C + Z {z}mm reduces spread.
          </div>
        </div>
      );
    })()}
  </>
)}
```

When `decoupledPump` is false, the existing `Dispense Speed (mm/min)` label and behavior remain completely unchanged.

---

### 3. Modify `generateGcode` function

The generate function is `const generateGcode = useCallback(() => { ... }, [settings])` starting at line 422.

#### 3a. Update header comments

After the existing `; Needle:` comment line, add when decoupled:

```js
if (s.decoupledPump) {
  lines.push(`; Mode: DECOUPLED PUMP (Arduino controller)`);
  lines.push(`; XY Feedrate: F${s.feedrate} | Pump Feedrate: F${s.pumpFeedrate || 4000}`);
  lines.push(`; Pump/XY ratio: ${((s.pumpFeedrate || 4000) / s.feedrate).toFixed(3)} | Trigger delay: ${s.triggerDelayMs ?? 50}ms`);
  lines.push(`; Trigger pin: ${s.triggerPin || 'dispense_trigger'}`);
} else {
  lines.push(`; Mode: COUPLED (Klipper extruder)`);
}
```

#### 3b. Add setup commands before line set

After `G92 E0` and `beforePrintingGcode`, when decoupled add:

```js
if (s.decoupledPump) {
  const pin = s.triggerPin || 'dispense_trigger';
  const td = s.triggerDelayMs ?? 50;
  const pumpF = s.pumpFeedrate || 4000;
  lines.push('; === Decoupled Pump Setup ===');
  lines.push(`SET_PIN PIN=${pin} VALUE=0 ; ensure pump stopped`);
  lines.push(`; Arduino: send "T1 F${pumpF}" to set pump rate`);
  lines.push(`; Arduino: send "TD ${td}" to set trigger delay`);
  lines.push('');
}
```

#### 3c. Replace the per-line dispense G-code block

Current line (557):
```js
lines.push(`G1 Y${yEnd.toFixed(3)} E${currentE.toFixed(2)} F${s.feedrate}`);
```

Replace with:

```js
if (s.decoupledPump) {
  const pin = s.triggerPin || 'dispense_trigger';
  // Trigger fires; Arduino waits triggerDelayMs internally before stepping
  lines.push(`SET_PIN PIN=${pin} VALUE=1 ; start pump (Arduino delays ${s.triggerDelayMs ?? 50}ms)`);
  lines.push(`G1 Y${yEnd.toFixed(3)} F${s.feedrate} ; XY only — no E (pump on Arduino)`);
  lines.push(`SET_PIN PIN=${pin} VALUE=0 ; stop pump`);
} else {
  lines.push(`G1 Y${yEnd.toFixed(3)} E${currentE.toFixed(2)} F${s.feedrate}`);
}
```

#### 3d. Skip E accumulation in decoupled mode

The `currentE += lineEDisplacement` at line 531 should still run for stats display, but the E value must not appear in the motion G-code in decoupled mode. The replacement above already handles this. No change needed to the accumulation itself.

#### 3e. Update gcodeStats flow rate calculation

Current (line 453):
```js
const flowRate = (actualVolumePerLine / s.lineLength) * (s.feedrate / 60);
```

Replace with:
```js
const effectiveFeedrate = s.decoupledPump ? (s.pumpFeedrate || 4000) : s.feedrate;
const flowRate = (actualVolumePerLine / s.lineLength) * (effectiveFeedrate / 60);
```

---

### 4. Update stats display (gcodeStats panel, lines 1151–1161)

Add a stat row when decoupled:

```jsx
{settings.decoupledPump && gcodeStats && (
  <>
    <div className="stat"><span>Pump F:</span> F{settings.pumpFeedrate || 4000}</div>
    <div className="stat"><span>XY F:</span> F{settings.feedrate}</div>
    <div className="stat">
      <span>Ratio:</span> {((settings.pumpFeedrate || 4000) / settings.feedrate).toFixed(2)}×
    </div>
  </>
)}
```

---

### 5. Backward compatibility

- `decoupledPump` defaults to `false` — all existing behavior unchanged when off
- `DEFAULT_SETTINGS` merge in `loadSettings()` handles missing keys for existing localStorage data
- No changes to CalibrationArrayGenerator.js needed — it inherits settings from ShapeDesigner

---

## Expected G-code output (decoupled mode, 5 lines)

```gcode
; Nanoarray Dispenser G-code
; Mode: DECOUPLED PUMP (Arduino controller)
; XY Feedrate: F10000 | Pump Feedrate: F4000
; Pump/XY ratio: 0.400 | Trigger delay: 50ms
; Trigger pin: dispense_trigger

G21
G90
G92 E0

; === Decoupled Pump Setup ===
SET_PIN PIN=dispense_trigger VALUE=0
; Arduino: send "T1 F4000" to set pump rate
; Arduino: send "TD 50" to set trigger delay

G1 X65.000 Y65.000 F3000
G1 Z5 F1000
G1 Z0.3 F500

M204 S500

; Line 1 (E mult: 1.50)
M204 S300
[prime gcode]
SET_PIN PIN=dispense_trigger VALUE=1 ; start pump (Arduino delays 50ms)
G1 Y135.000 F10000
SET_PIN PIN=dispense_trigger VALUE=0 ; stop pump
[post dispense gcode]

; Line 2 (E mult: 1.20)
G1 Z5 F500
G1 X66.000 Y65.000 F3000
G1 Z0.3 F500
[prime gcode]
SET_PIN PIN=dispense_trigger VALUE=1
G1 Y135.000 F10000
SET_PIN PIN=dispense_trigger VALUE=0
[post dispense gcode]

G1 Z5 F500
M204 S3000
; Total dispensed: 25.00 µL (E: 0 -> 6.25, Δ6.25 µL)
```

---

## Klipper printer.cfg required (add if not present)

```ini
[output_pin dispense_trigger]
pin: PB0           ; adjust to spare Octopus pin
value: 0
shutdown_value: 0
```

---

## Arduino pre-run sequence (manual, via serial before print)

```
T1 F4000    ; set pump rate
TD 50       ; set trigger delay
A1 E50 F2000  ; fill syringe
D1 E2 F1000   ; prime tip
```
