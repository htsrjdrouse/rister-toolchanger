# Rister Toolchanger 3D Viewer

A React + Three.js web viewer for the Rister Toolchanger STL files.

## Project Structure

```
/home/rista/toolchanger_js_model/
├── dist/                          # Production build output
│   ├── index.html                 # Main HTML entry point
│   ├── assets/
│   │   └── index-*.js           # Bundled JavaScript
│   └── models/                    # STL files directory
│       ├── *.stl                 # 408 STL files
│       ├── list.json             # Array of all STL filenames (auto-generated)
│       └── category_mapping.json  # Category-to-STL mappings (auto-generated)
└── src/
    └── App.tsx                   # Main React application
```

## Adding/Removing STL Files

### 1. Add New STL Files

Copy your `.stl` files to:
```
/home/rista/toolchanger_js_model/dist/models/
```

### 2. Remove STL Files

Delete the `.stl` file from:
```
/home/rista/toolchanger_js_model/dist/models/
```

### 3. Rebuild the JSON Indexes

After adding/removing STL files, regenerate the index files:

```bash
cd /home/rista/toolchanger_js_model/dist/models

# Regenerate list.json (all STL files)
ls *.stl | python3 -c "import json, sys; d=[l.strip() for l in sys.stdin if l.strip()]; json.dump(d, open('list.json', 'w'))"

# Regenerate category_mapping.json (from OpenSCAD includes)
python3 /tmp/parse_scad.py
```

Or run both:
```bash
cd /home/rista/toolchanger_js_model/dist/models && \
ls *.stl | python3 -c "import json, sys; d=[l.strip() for l in sys.stdin if l.strip()]; json.dump(d, open('list.json', 'w'))" && \
python3 /tmp/parse_scad.py
```

## Updating Categories

The categories are defined in `/home/rista/toolchanger_js_model/src/App.tsx` in the `CATEGORIES` constant:

```typescript
const CATEGORIES: CategoryInfo[] = [
  { name: 'X_AXIS', label: 'X Axis', color: '#E91E63' },
  { name: 'Y_AXIS', label: 'Y Axis', color: '#9C27B0' },
  // Add more categories here...
];
```

To change how files map to categories, edit `/tmp/parse_scad.py` - it parses the OpenSCAD include files to build the mapping.

## Running the Viewer

### Development
```bash
cd /home/rista/toolchanger_js_model
npm run dev
```

### Production
```bash
cd /home/rista/toolchanger_js_model/dist
python3 -m http.server 3010
```

Then open: http://192.168.1.155:3010/

## Rebuilding After Code Changes

If you modify `App.tsx` or other source files:

```bash
cd /home/rista/toolchanger_js_model
npm run build
```

The build output goes to `dist/`.

## Troubleshooting

### "0 / 0 visible" or blank sidebar
The JSON index files may be corrupted. Regenerate them:
```bash
cd /home/rista/toolchanger_js_model/dist/models
ls *.stl | python3 -c "import json, sys; d=[l.strip() for l in sys.stdin if l.strip()]; json.dump(d, open('list.json', 'w'))"
python3 /tmp/parse_scad.py
```

### STL files not showing in 3D
Check that the files exist in `dist/models/` and are listed in `list.json`.

### Cache issues
- Hard refresh: Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)
- Try incognito/private window
- Clear localStorage in browser dev tools (F12 → Application → Local Storage)
