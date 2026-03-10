# 🖨️ Printer Designer

A web-based tool for designing printer bed layouts and generating G-code for liquid dispensing systems. Built for the **Rister Toolchanger** — a Voron Trident-based platform for nanoarray fabrication and perovskite solar cell deposition.

![Printer Designer](https://img.shields.io/badge/Status-Active-green) ![Docker](https://img.shields.io/badge/Docker-Ready-blue) ![License](https://img.shields.io/badge/License-MIT-yellow)

## ✨ Features

### 📦 Object Editor
- Visual canvas showing the printer bed layout
- Create, clone, and position objects (slides, plates, stations)
- Configure array patterns (rows, columns, spacing)
- Real-time coordinate display with mouse hover

### 💧 Tip Management
- Configure multiple dispenser tips (needle positions)
- Set up wash, waste, and drypad stations per tip
- Tip-specific coordinate offsets

### ⚙️ G-code Builder
- **Z Height Settings**: Configure dispense height and travel height
- Generate positioning G-code for objects and array positions
- Safe travel moves (lift → move → lower) to avoid dragging
- Save, load, and combine G-code sequences
- Copy to clipboard or download as `.gcode` files

### 🔬 Shape Designer (Line Generator)
- Generate parallel line patterns for nanoarray dispensing
- Configure line count, length, spacing, width, and height
- Hardware settings: needle gauge, syringe size
- Real-time 3D preview with Three.js
- Automatic extrusion calculation based on geometry
- **Custom G-code sections**: Before/After Printing, Before/After Line Set, Prime/Post-Dispense per line
- **Zigzag printing**: Alternate line direction for faster multi-line dispensing
- Export ready-to-run G-code

### 🔐 Publisher/Viewer Mode
- Optional password protection for editing
- Viewers can see designs and export G-code
- Publishers can create, edit, and delete designs

## 🚀 Quick Start

### Docker (Recommended)

```bash
cd printer-designer
docker compose up -d
```

Access at: **http://localhost:3100**

To enable password protection:
```bash
PUBLISHER_PASSWORD=mysecret docker compose up -d
```

### Local Development

```bash
# Terminal 1: Backend
cd server
npm install
npm run dev

# Terminal 2: Frontend
cd client
npm install
npm start
```

- Backend: http://localhost:3100
- Frontend dev server: http://localhost:3000 (proxies to backend)

## 📁 Project Structure

```
printer-designer/
├── docker-compose.yml      # Docker orchestration
├── Dockerfile              # Production container build
├── server/
│   ├── index.js            # Express API server
│   ├── package.json
│   └── public/             # Built React app (production)
├── client/
│   ├── src/
│   │   ├── App.js                    # Main app with auth
│   │   ├── components/
│   │   │   ├── DesignList.js         # Design management
│   │   │   ├── ObjectEditor.js       # Visual bed editor
│   │   │   ├── TipManagement.js      # Dispenser tip config
│   │   │   ├── GcodeBuilder.js       # G-code sequence builder
│   │   │   ├── ShapeDesigner.js      # Line pattern generator
│   │   │   └── LoginModal.js         # Auth UI
│   │   ├── context/
│   │   │   └── AuthContext.js        # Publisher authentication
│   │   └── styles/
│   │       └── main.css
│   └── package.json
└── data/
    └── designs.json        # Persistent design storage
```

## 🎮 Usage

### Creating a Design

1. Click **📁 Designs** → **➕ New Design**
2. Switch to **📦 Object Editor** to add substrates/plates
3. Configure **💧 Tip Management** for your dispenser positions
4. Use **⚙️ G-code Builder** to create movement sequences
5. Use **🔬 Shape Designer** to generate dispensing patterns

### Z Height Settings

The G-code Builder includes critical Z parameters:

| Setting | Default | Description |
|---------|---------|-------------|
| **Z Dispense** | 0.5 mm | Nozzle height while dispensing (close to substrate) |
| **Z Travel** | 10 mm | Height for safe travel moves between positions |

Generated G-code follows this pattern:
```gcode
G1 Z10 F1500      ; Lift to travel height
G1 X100 Y100 F3000 ; Move to position
G1 Z0.5 F500      ; Lower to dispense height
```

### Shape Designer Parameters

| Parameter | Description |
|-----------|-------------|
| **Number of Lines** | How many parallel lines to dispense |
| **Line Length** | Length of each line (mm) |
| **Line Spacing** | Distance between line centers (mm) |
| **Line Width** | Target width on substrate (mm) |
| **Line Height** | Target film thickness (mm) |
| **Start X/Y** | G-code coordinates for first line |
| **Needle Gauge** | 18G–34G (affects inner diameter) |
| **Syringe Size** | 1ml–20ml (affects plunger area) |
| **Z Dispense** | Height while dispensing |
| **Z Travel** | Height for moves between lines |
| **E Multiplier** | Tune extrusion volume |
| **Zigzag Lines** | Alternate direction for faster printing (multi-line) |

### Shape Designer G-code Sections

The Shape Designer supports custom G-code insertion at multiple points:

| Section | When | Visibility |
|---------|------|------------|
| **Before Printing** | Once at start of job | Always |
| **After Printing** | Once at end of job | Always |
| **Before Line Set** | Once before all lines | Multi-line only (numLines > 1) |
| **After Line Set** | Once after all lines (after Z lift) | Multi-line only (numLines > 1) |
| **Prime G-code** | Before each individual line | Always |
| **Post-Dispense G-code** | After each individual line | Always |

**G-code Structure:**
```gcode
; Setup (G21, G90, G92 E0)

; === Before Printing ===
[Your custom start G-code]

; Move to start position (XY first, then Z)

; === Before Line Set ===  (multi-line only)
[Runs once before all lines]

; Line 1
[Prime G-code - runs before each line]
G1 Y... E... F...  ; Dispense
[Post-Dispense G-code - runs after each line]

; Line 2 (zigzag: reverses direction if enabled)
[Prime G-code]
G1 Y... E... F...  ; Dispense (opposite direction)
[Post-Dispense G-code]

; ... more lines ...

G1 Z... ; Lift to travel height

; === After Line Set ===  (multi-line only)
[Runs once after all lines]

; === After Printing ===
[Your custom end G-code]
```

## 🔌 API Reference

### Designs

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/designs` | - | List all designs |
| GET | `/api/designs/:id` | - | Get single design |
| POST | `/api/designs` | Publisher | Create new design |
| PUT | `/api/designs/:id` | Publisher | Update design |
| DELETE | `/api/designs/:id` | Publisher | Delete design |
| POST | `/api/designs/:id/clone` | Publisher | Clone design |
| GET | `/api/designs/:id/export` | - | Export as JSON |
| POST | `/api/designs/import` | Publisher | Import from JSON |

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/auth/status` | Check auth mode/status |
| POST | `/api/auth/login` | Login (get token) |
| POST | `/api/auth/logout` | Invalidate token |

## 🐳 Docker Commands

```bash
# Start (detached)
docker compose up -d

# Stop
docker compose down

# View logs
docker compose logs -f

# Rebuild after code changes
cd client && npm run build
cp -r build/* ../server/public/
docker compose restart

# Full rebuild (after Dockerfile changes)
docker compose build --no-cache
docker compose up -d
```

## 💾 Data Persistence

Designs are stored in `./data/designs.json`, mounted as a Docker volume.

**Backup:**
```bash
cp data/designs.json backups/designs_$(date +%Y%m%d).json
```

**Restore:**
```bash
cp backups/designs_20240206.json data/designs.json
docker compose restart
```

## 🔧 Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | 3100 | Server port |
| `PUBLISHER_PASSWORD` | *(none)* | Enable password protection |
| `NODE_ENV` | development | Set to `production` in Docker |

### docker-compose.yml

```yaml
services:
  printer-designer:
    build: .
    ports:
      - "3100:3100"
    environment:
      - PUBLISHER_PASSWORD=optional_password
    volumes:
      - ./data:/app/data
```

## 🎯 Use Cases

### Perovskite Solar Cell Fabrication
- Deposit parallel lines of perovskite precursor ink
- Configure for specific needle gauges (30G–34G typical)
- Calculate extrusion based on wet film requirements

### Nanoarray Printing
- Create patterns on glass slides or ITO-PET substrates
- Multiple substrate positions with array patterns
- Sequence generation for multi-layer deposition

### General Liquid Handling
- Any XYZ motion system with syringe pump
- Tip washing and waste disposal sequences
- Batch processing across multiple substrates

## 📝 License

MIT License — see [LICENSE](LICENSE) for details.

## 🤝 Contributing

Part of the [Rister Toolchanger](https://github.com/htsrjdrouse/rister-toolchanger) project.

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

*Built for low-cost, scalable perovskite solar fabrication* ☀️
