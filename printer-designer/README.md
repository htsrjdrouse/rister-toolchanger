# Printer Designer

A web-based tool for designing and managing printer bed layouts for liquid handling systems.

## Features

- **Design Management**: Create, clone, import/export printer designs
- **Object Editor**: Visual canvas to place and configure objects on the printer bed
- **Tip Management**: Configure pipette tip positions for drypad, wash, waste, and eject stations
- **Persistent Storage**: All designs saved to JSON file on server

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
