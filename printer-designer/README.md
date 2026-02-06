# Printer Designer

A web-based tool for designing and managing printer bed layouts for liquid handling systems.

## Features

- **Design Management**: Create, clone, import/export printer designs
- **Object Editor**: Visual canvas to place and configure objects on the printer bed
- **Tip Management**: Configure pipette tip positions for drypad, wash, waste, and eject stations
- **G-code Builder**: Generate and manage G-code sequences for liquid handling
- **Shape Designer**: Design nanoarray patterns using JSCAD, visualize in 3D, and slice to G-code
- **Persistent Storage**: All designs saved to JSON file on server

## Shape Designer

The Shape Designer is a new module for creating nanoarray patterns for perovskite deposition and similar applications.

### Features

- **JSCAD Code Editor**: Write JavaScript-based CAD code to define shapes
- **3D STL Viewer**: Real-time visualization using Three.js
- **PrusaSlicer Integration**: Slice STL files to G-code with customizable settings
- **G-code Preview & Download**: View sliced G-code with statistics

### Example: Creating Parallel Lines

```javascript
const jscad = require('@jscad/modeling');
const { cuboid } = jscad.primitives;
const { translate } = jscad.transforms;
const { union } = jscad.booleans;

// 50mm lines, 100μm wide, 50μm tall, 1mm spacing
const LINE_LENGTH = 50, LINE_WIDTH = 0.1, LINE_HEIGHT = 0.05;
const SPACING = 1.0, NUM_LINES = 10;

function main() {
  const lines = [];
  for (let i = 0; i < NUM_LINES; i++) {
    lines.push(translate([0, i * SPACING, 0], 
      cuboid({ size: [LINE_LENGTH, LINE_WIDTH, LINE_HEIGHT] })));
  }
  return union(lines);
}

module.exports = { main };
```

### Slicer Settings

Default settings optimized for nanoarray deposition:
- Layer Height: 0.05mm (50μm)
- Extrusion Width: 0.1mm (100μm)
- Speed: 5mm/s

## Quick Start

### Using Docker (Recommended)

```bash
cd printer-designer
docker-compose up -d
```

Access the app at: **http://localhost:3100**

### Development Mode

```bash
# Start the backend
cd server
npm install
npm run dev

# In another terminal, start the React frontend
cd client
npm install
npm start
```

- Backend runs on: http://localhost:3100
- Frontend dev server: http://localhost:3000 (proxies API to backend)

## Project Structure

```
printer-designer/
├── docker-compose.yml     # Docker configuration
├── Dockerfile             # Production build
├── server/
│   ├── package.json
│   └── index.js           # Express API server
├── client/
│   ├── package.json
│   ├── public/
│   │   └── index.html
│   └── src/
│       ├── App.js         # Main React app
│       ├── components/
│       │   ├── DesignList.js      # Design management
│       │   ├── ObjectEditor.js    # Visual object editor
│       │   └── TipManagement.js   # Pipette tip configuration
│       └── styles/
│           └── main.css
└── data/
    └── designs.json       # Persistent storage
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/designs` | List all designs |
| GET | `/api/designs/:id` | Get single design |
| POST | `/api/designs` | Create new design |
| PUT | `/api/designs/:id` | Update design |
| DELETE | `/api/designs/:id` | Delete design |
| POST | `/api/designs/:id/clone` | Clone a design |
| GET | `/api/designs/:id/export` | Export as JSON file |
| POST | `/api/designs/import` | Import from JSON |

## Docker Commands

```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# View logs
docker logs printer-designer

# Rebuild after changes
docker-compose build --no-cache
docker-compose up -d
```

## Data Persistence

Designs are stored in `./data/designs.json`. This directory is mounted as a Docker volume, so your data persists across container restarts.

To backup your designs:
```bash
cp data/designs.json designs_backup.json
```
