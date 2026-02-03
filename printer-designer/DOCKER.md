# Docker Guide for Printer Designer

## Quick Reference

```bash
# Navigate to project directory first
cd /Users/richard/Documents/voron/Trident/lineux_toolchanger/rister-toolchanger-4dispenser/rister-toolchanger/printer-designer
```

---

## 🔐 Publisher/Viewer Mode

The app supports two access modes:
- **Publisher**: Full access (create, edit, delete designs)
- **Viewer**: Read-only (view designs, copy/download G-code)

### Enable Password Protection

**Option 1: Environment variable (recommended)**
```bash
PUBLISHER_PASSWORD=your-secret-password docker-compose up -d --build
```

**Option 2: Create a .env file**
```bash
echo "PUBLISHER_PASSWORD=your-secret-password" > .env
docker-compose up -d --build
```

**Option 3: Edit docker-compose.yml directly**
```yaml
environment:
  - PUBLISHER_PASSWORD=your-secret-password
```

### Share with Others
- **Operators/Viewers**: Give them the URL `http://your-ip:3100`
- **Publishers**: They click "Login" and enter the password

### Disable Password (Open Access)
Remove or leave `PUBLISHER_PASSWORD` empty - everyone gets full access.

---

### 🟢 Start the App
```bash
docker-compose up -d
```
- `-d` = "detached" mode (runs in background)
- App runs at: http://localhost:3100

### 🔴 Stop the App
```bash
docker-compose down
```

### 🔄 Restart After Code Changes
```bash
docker-compose up -d --build
```
- `--build` = rebuild the image with your code changes
- **Always use this after editing any code files**

### 📋 View Logs (see errors)
```bash
# Show recent logs
docker-compose logs --tail=50

# Follow logs in real-time (Ctrl+C to exit)
docker-compose logs -f
```

### 🔍 Check Status
```bash
docker-compose ps
```

### 🧹 Full Reset (if things go wrong)
```bash
# Stop and remove everything (keeps your data!)
docker-compose down

# Rebuild from scratch (no cache)
docker-compose build --no-cache

# Start fresh
docker-compose up -d
```

### 🗑️ Nuclear Option (removes everything including data)
```bash
docker-compose down -v
```
- `-v` = also removes volumes (YOUR DESIGNS WILL BE DELETED!)

---

## Troubleshooting

### Page won't load / blank screen
1. Check if container is running: `docker-compose ps`
2. Check logs for errors: `docker-compose logs --tail=100`
3. Hard refresh browser: `Cmd+Shift+R` (Mac) or `Ctrl+Shift+R`
4. Try full reset (see above)

### Changes not showing after code edit
You must rebuild:
```bash
docker-compose up -d --build
```

### Port 3100 already in use
```bash
# Find what's using it
lsof -i :3100

# Kill it (replace PID with actual number)
kill -9 <PID>

# Or change the port in docker-compose.yml:
# ports:
#   - "3101:3100"  # Use 3101 instead
```

### Container keeps crashing
```bash
# Check what went wrong
docker-compose logs printer-designer

# Common fixes:
# 1. Rebuild: docker-compose up -d --build
# 2. Full reset (see above)
```

---

## How It Works

```
┌─────────────────────────────────────────┐
│           Docker Container              │
│  ┌─────────────────────────────────┐    │
│  │     Node.js Express Server      │    │
│  │     (serves React app + API)    │    │
│  │         Port 3100               │    │
│  └─────────────────────────────────┘    │
│                  │                      │
│                  ▼                      │
│  ┌─────────────────────────────────┐    │
│  │      /app/data (volume)         │◄───┼──── ./data (your local folder)
│  │      designs.json               │    │     (data persists here!)
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

**Key point:** Your designs are saved in `./data/designs.json` which is mounted as a volume. This means your data survives container restarts/rebuilds.

---

## File Structure

```
printer-designer/
├── client/           # React frontend code
│   └── src/
│       ├── App.js
│       └── components/
├── server/           # Express backend code
│   └── index.js
├── data/             # YOUR DATA (persisted)
│   └── designs.json
├── docker-compose.yml
├── Dockerfile
└── DOCKER.md         # This file
```

---

## Common Workflows

### "I edited some React code"
```bash
docker-compose up -d --build
# Then hard-refresh browser
```

### "I want to see what's happening"
```bash
docker-compose logs -f
```

### "Something broke, start fresh"
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### "I want to backup my designs"
```bash
cp ./data/designs.json ~/Desktop/designs-backup.json
```
