const express = require('express');
const cors = require('cors');
const fs = require('fs').promises;
const fsSync = require('fs');
const path = require('path');
const crypto = require('crypto');
const { v4: uuidv4 } = require('uuid');
const { exec, spawn } = require('child_process');
const { promisify } = require('util');
const execAsync = promisify(exec);

const app = express();
const PORT = process.env.PORT || 3100;
const DATA_DIR = path.join(__dirname, '..', 'data');
const DESIGNS_FILE = path.join(DATA_DIR, 'designs.json');
const TEMP_DIR = path.join(__dirname, '..', 'temp');
const SLICER_PROFILES_DIR = path.join(__dirname, '..', 'slicer-profiles');
const SHAPES_DIR = path.join(DATA_DIR, 'shapes');

// Publisher password from environment variable
const PUBLISHER_PASSWORD = process.env.PUBLISHER_PASSWORD || null;

// Simple in-memory session store (tokens expire after 24 hours)
const sessions = new Map();
const SESSION_DURATION = 24 * 60 * 60 * 1000; // 24 hours

// Clean expired sessions periodically
setInterval(() => {
  const now = Date.now();
  for (const [token, session] of sessions) {
    if (now > session.expiresAt) {
      sessions.delete(token);
    }
  }
}, 60 * 60 * 1000); // Check every hour

// Middleware
app.use(cors());
app.use(express.json());

// Serve static React build in production
if (process.env.NODE_ENV === 'production') {
  app.use(express.static(path.join(__dirname, 'public')));
}

// =====================
// Auth Middleware
// =====================

// Check if request has valid publisher token
function isPublisher(req) {
  // If no password is set, everyone is a publisher
  if (!PUBLISHER_PASSWORD) {
    return true;
  }
  
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return false;
  }
  
  const token = authHeader.substring(7);
  const session = sessions.get(token);
  
  if (!session || Date.now() > session.expiresAt) {
    sessions.delete(token);
    return false;
  }
  
  return true;
}

// Middleware to require publisher access
function requirePublisher(req, res, next) {
  if (!isPublisher(req)) {
    return res.status(403).json({ 
      error: 'Publisher access required',
      code: 'PUBLISHER_REQUIRED'
    });
  }
  next();
}

// =====================
// Data Functions
// =====================

async function initDataFile() {
  try {
    await fs.mkdir(DATA_DIR, { recursive: true });
    try {
      await fs.access(DESIGNS_FILE);
    } catch {
      await fs.writeFile(DESIGNS_FILE, JSON.stringify({ designs: [] }, null, 2));
    }
  } catch (err) {
    console.error('Error initializing data file:', err);
  }
}

async function readDesigns() {
  try {
    const data = await fs.readFile(DESIGNS_FILE, 'utf-8');
    return JSON.parse(data);
  } catch (err) {
    return { designs: [] };
  }
}

async function writeDesigns(data) {
  await fs.writeFile(DESIGNS_FILE, JSON.stringify(data, null, 2));
}

// =====================
// Auth Routes
// =====================

// Get auth status (is password required? is user authenticated?)
app.get('/api/auth/status', (req, res) => {
  const passwordRequired = !!PUBLISHER_PASSWORD;
  const isAuthenticated = isPublisher({ headers: req.headers });
  
  res.json({
    passwordRequired,
    isPublisher: isAuthenticated,
    mode: isAuthenticated ? 'publisher' : 'viewer'
  });
});

// Login to get publisher access
app.post('/api/auth/login', (req, res) => {
  const { password } = req.body;
  
  // If no password configured, auto-grant access
  if (!PUBLISHER_PASSWORD) {
    return res.json({ 
      success: true, 
      message: 'No password required',
      token: null 
    });
  }
  
  // Verify password
  if (password !== PUBLISHER_PASSWORD) {
    return res.status(401).json({ 
      success: false, 
      error: 'Invalid password' 
    });
  }
  
  // Generate session token
  const token = crypto.randomBytes(32).toString('hex');
  sessions.set(token, {
    createdAt: Date.now(),
    expiresAt: Date.now() + SESSION_DURATION
  });
  
  res.json({ 
    success: true, 
    token,
    expiresIn: SESSION_DURATION
  });
});

// Logout (invalidate token)
app.post('/api/auth/logout', (req, res) => {
  const authHeader = req.headers.authorization;
  if (authHeader && authHeader.startsWith('Bearer ')) {
    const token = authHeader.substring(7);
    sessions.delete(token);
  }
  res.json({ success: true });
});

// =====================
// Design Routes (Read - Open to all)
// =====================

// Get all designs (list)
app.get('/api/designs', async (req, res) => {
  try {
    const data = await readDesigns();
    const summary = data.designs.map(d => ({
      id: d.id,
      name: d.name,
      description: d.description,
      printerArea: d.printerArea,
      objectCount: d.objects?.length || 0,
      tipCount: d.tips?.length || 0,
      macroCount: d.savedMacros?.length || 0,
      createdAt: d.createdAt,
      updatedAt: d.updatedAt
    }));
    res.json(summary);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get single design by ID
app.get('/api/designs/:id', async (req, res) => {
  try {
    const data = await readDesigns();
    const design = data.designs.find(d => d.id === req.params.id);
    if (!design) {
      return res.status(404).json({ error: 'Design not found' });
    }
    res.json(design);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Export design as JSON (open to viewers - they can download)
app.get('/api/designs/:id/export', async (req, res) => {
  try {
    const data = await readDesigns();
    const design = data.designs.find(d => d.id === req.params.id);
    if (!design) {
      return res.status(404).json({ error: 'Design not found' });
    }
    
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Content-Disposition', `attachment; filename="${design.name.replace(/[^a-z0-9]/gi, '_')}.json"`);
    res.json(design);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// =====================
// Design Routes (Write - Publisher only)
// =====================

// Create new design
app.post('/api/designs', requirePublisher, async (req, res) => {
  try {
    const data = await readDesigns();
    const newDesign = {
      id: uuidv4(),
      name: req.body.name || 'Untitled Design',
      description: req.body.description || '',
      printerArea: req.body.printerArea || { width: 380, height: 480 },
      objects: req.body.objects || [],
      tips: req.body.tips || [],
      savedMacros: req.body.savedMacros || [],
      activeTipIndex: req.body.activeTipIndex || 0,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    data.designs.push(newDesign);
    await writeDesigns(data);
    res.status(201).json(newDesign);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update design
app.put('/api/designs/:id', requirePublisher, async (req, res) => {
  try {
    const data = await readDesigns();
    const index = data.designs.findIndex(d => d.id === req.params.id);
    if (index === -1) {
      return res.status(404).json({ error: 'Design not found' });
    }
    
    data.designs[index] = {
      ...data.designs[index],
      ...req.body,
      id: req.params.id,
      updatedAt: new Date().toISOString()
    };
    
    await writeDesigns(data);
    res.json(data.designs[index]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete design
app.delete('/api/designs/:id', requirePublisher, async (req, res) => {
  try {
    const data = await readDesigns();
    const index = data.designs.findIndex(d => d.id === req.params.id);
    if (index === -1) {
      return res.status(404).json({ error: 'Design not found' });
    }
    
    data.designs.splice(index, 1);
    await writeDesigns(data);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Clone design
app.post('/api/designs/:id/clone', requirePublisher, async (req, res) => {
  try {
    const data = await readDesigns();
    const original = data.designs.find(d => d.id === req.params.id);
    if (!original) {
      return res.status(404).json({ error: 'Design not found' });
    }
    
    const cloned = {
      ...JSON.parse(JSON.stringify(original)),
      id: uuidv4(),
      name: (req.body.name || original.name) + ' (Copy)',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    
    data.designs.push(cloned);
    await writeDesigns(data);
    res.status(201).json(cloned);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Import design from JSON
app.post('/api/designs/import', requirePublisher, async (req, res) => {
  try {
    const data = await readDesigns();
    
    let baseName = req.body.name;
    if (!baseName) {
      const macroCount = req.body.savedMacros?.length || 0;
      const objectCount = req.body.objects?.length || 0;
      baseName = `Imported Design (${objectCount} objects, ${macroCount} macros)`;
    }
    
    const imported = {
      ...req.body,
      id: uuidv4(),
      name: baseName + ' (Imported)',
      description: req.body.description || '',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    
    data.designs.push(imported);
    await writeDesigns(data);
    res.status(201).json(imported);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// =====================
// Publish Routes
// =====================

// Get the currently published design (open to viewers)
app.get('/api/published', async (req, res) => {
  try {
    const data = await readDesigns();
    
    if (!data.publishedDesignId) {
      return res.json({ published: false, design: null });
    }
    
    const design = data.designs.find(d => d.id === data.publishedDesignId);
    
    if (!design) {
      return res.json({ published: false, design: null });
    }
    
    res.json({ published: true, design });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get publish status for all designs (which one is published)
app.get('/api/published/status', async (req, res) => {
  try {
    const data = await readDesigns();
    res.json({ publishedDesignId: data.publishedDesignId || null });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Publish a design (publisher only)
app.post('/api/designs/:id/publish', requirePublisher, async (req, res) => {
  try {
    const data = await readDesigns();
    const design = data.designs.find(d => d.id === req.params.id);
    
    if (!design) {
      return res.status(404).json({ error: 'Design not found' });
    }
    
    data.publishedDesignId = req.params.id;
    await writeDesigns(data);
    
    res.json({ 
      success: true, 
      message: `Design "${design.name}" is now published`,
      publishedDesignId: req.params.id
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Unpublish (publisher only)
app.post('/api/published/unpublish', requirePublisher, async (req, res) => {
  try {
    const data = await readDesigns();
    data.publishedDesignId = null;
    await writeDesigns(data);
    
    res.json({ success: true, message: 'Design unpublished' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// =====================
// Shape Designer Routes
// =====================

// Initialize temp and shapes directories
async function initShapeDirectories() {
  await fs.mkdir(TEMP_DIR, { recursive: true });
  await fs.mkdir(SHAPES_DIR, { recursive: true });
}

// Compile JSCAD code to STL
app.post('/api/shape/compile', async (req, res) => {
  const { code, filename } = req.body;
  
  if (!code) {
    return res.status(400).json({ error: 'No code provided' });
  }
  
  const jobId = uuidv4();
  const jscadFile = path.join(TEMP_DIR, `${jobId}.js`);
  const stlFile = path.join(TEMP_DIR, `${jobId}.stl`);
  
  try {
    // Write JSCAD code to temp file
    await fs.writeFile(jscadFile, code);
    
    // Run JSCAD CLI to compile to STL
    // Use local jscad from node_modules and set NODE_PATH for @jscad/modeling resolution
    const jscadBin = path.join(__dirname, 'node_modules', '.bin', 'jscad');
    const nodeModulesPath = path.join(__dirname, 'node_modules');
    
    const { stdout, stderr } = await execAsync(`"${jscadBin}" "${jscadFile}" -o "${stlFile}"`, {
      timeout: 30000, // 30 second timeout
      env: {
        ...process.env,
        NODE_PATH: nodeModulesPath
      }
    });
    
    // Read the generated STL
    const stlData = await fs.readFile(stlFile);
    const stlBase64 = stlData.toString('base64');
    
    // Clean up temp files
    await fs.unlink(jscadFile).catch(() => {});
    await fs.unlink(stlFile).catch(() => {});
    
    res.json({
      success: true,
      jobId,
      stl: stlBase64,
      format: 'base64',
      logs: stdout || stderr || 'Compilation successful'
    });
    
  } catch (err) {
    // Clean up on error
    await fs.unlink(jscadFile).catch(() => {});
    await fs.unlink(stlFile).catch(() => {});
    
    res.status(500).json({
      success: false,
      error: err.message,
      logs: err.stderr || err.stdout || ''
    });
  }
});

// Slice STL to G-code
app.post('/api/shape/slice', async (req, res) => {
  const { stl, profile, settings } = req.body;
  
  if (!stl) {
    return res.status(400).json({ error: 'No STL data provided' });
  }
  
  const jobId = uuidv4();
  const stlFile = path.join(TEMP_DIR, `${jobId}.stl`);
  const gcodeFile = path.join(TEMP_DIR, `${jobId}.gcode`);
  const profileFile = profile ? path.join(SLICER_PROFILES_DIR, profile) : null;
  
  try {
    // Write STL from base64
    const stlBuffer = Buffer.from(stl, 'base64');
    await fs.writeFile(stlFile, stlBuffer);
    
    // Build PrusaSlicer command
    // For Docker: use prusa-slicer-cli wrapper (with xvfb)
    // For local: use prusa-slicer or PrusaSlicer directly
    const slicerCmd = process.env.NODE_ENV === 'production' 
      ? 'prusa-slicer-cli' 
      : 'prusa-slicer';
    
    let cmd = `${slicerCmd} --export-gcode "${stlFile}" -o "${gcodeFile}"`;
    
    // Add profile if specified
    if (profileFile && fsSync.existsSync(profileFile)) {
      cmd += ` --load "${profileFile}"`;
    }
    
    // Add individual settings overrides
    if (settings) {
      if (settings.layerHeight) cmd += ` --layer-height ${settings.layerHeight}`;
      if (settings.firstLayerHeight) cmd += ` --first-layer-height ${settings.firstLayerHeight}`;
      if (settings.perimeterSpeed) cmd += ` --perimeter-speed ${settings.perimeterSpeed}`;
      if (settings.extrusionWidth) cmd += ` --extrusion-width ${settings.extrusionWidth}`;
      if (settings.nozzleDiameter) cmd += ` --nozzle-diameter ${settings.nozzleDiameter}`;
    }
    
    const { stdout, stderr } = await execAsync(cmd, {
      timeout: 60000 // 60 second timeout for slicing
    });
    
    // Read the generated G-code
    const gcodeData = await fs.readFile(gcodeFile, 'utf-8');
    
    // Parse some stats from G-code
    const stats = parseGcodeStats(gcodeData);
    
    // Clean up temp files
    await fs.unlink(stlFile).catch(() => {});
    await fs.unlink(gcodeFile).catch(() => {});
    
    res.json({
      success: true,
      jobId,
      gcode: gcodeData,
      stats,
      logs: stdout || stderr || 'Slicing successful'
    });
    
  } catch (err) {
    // Clean up on error
    await fs.unlink(stlFile).catch(() => {});
    await fs.unlink(gcodeFile).catch(() => {});
    
    res.status(500).json({
      success: false,
      error: err.message,
      logs: err.stderr || err.stdout || ''
    });
  }
});

// Parse basic stats from G-code
function parseGcodeStats(gcode) {
  const lines = gcode.split('\n');
  let totalLines = lines.length;
  let moveCount = 0;
  let layerCount = 0;
  let minX = Infinity, maxX = -Infinity;
  let minY = Infinity, maxY = -Infinity;
  let minZ = Infinity, maxZ = -Infinity;
  
  for (const line of lines) {
    if (line.startsWith('G1 ') || line.startsWith('G0 ')) {
      moveCount++;
      
      const xMatch = line.match(/X([\d.-]+)/);
      const yMatch = line.match(/Y([\d.-]+)/);
      const zMatch = line.match(/Z([\d.-]+)/);
      
      if (xMatch) {
        const x = parseFloat(xMatch[1]);
        minX = Math.min(minX, x);
        maxX = Math.max(maxX, x);
      }
      if (yMatch) {
        const y = parseFloat(yMatch[1]);
        minY = Math.min(minY, y);
        maxY = Math.max(maxY, y);
      }
      if (zMatch) {
        const z = parseFloat(zMatch[1]);
        if (z > minZ) layerCount++;
        minZ = Math.min(minZ, z);
        maxZ = Math.max(maxZ, z);
      }
    }
  }
  
  return {
    totalLines,
    moveCount,
    layerCount,
    bounds: {
      x: { min: minX === Infinity ? 0 : minX, max: maxX === -Infinity ? 0 : maxX },
      y: { min: minY === Infinity ? 0 : minY, max: maxY === -Infinity ? 0 : maxY },
      z: { min: minZ === Infinity ? 0 : minZ, max: maxZ === -Infinity ? 0 : maxZ }
    }
  };
}

// Get available slicer profiles
app.get('/api/shape/profiles', async (req, res) => {
  try {
    const files = await fs.readdir(SLICER_PROFILES_DIR);
    const profiles = files.filter(f => f.endsWith('.ini')).map(f => ({
      name: f,
      path: f
    }));
    res.json(profiles);
  } catch (err) {
    res.json([]); // Return empty array if no profiles directory
  }
});

// Save a shape design
app.post('/api/shape/save', requirePublisher, async (req, res) => {
  const { name, code, stl, gcode, designId } = req.body;
  
  if (!name || !code) {
    return res.status(400).json({ error: 'Name and code are required' });
  }
  
  try {
    const shapeId = uuidv4();
    const shape = {
      id: shapeId,
      name,
      code,
      designId: designId || null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    
    // Save shape metadata
    const shapeFile = path.join(SHAPES_DIR, `${shapeId}.json`);
    await fs.writeFile(shapeFile, JSON.stringify(shape, null, 2));
    
    // Optionally save STL and G-code files
    if (stl) {
      const stlBuffer = Buffer.from(stl, 'base64');
      await fs.writeFile(path.join(SHAPES_DIR, `${shapeId}.stl`), stlBuffer);
    }
    if (gcode) {
      await fs.writeFile(path.join(SHAPES_DIR, `${shapeId}.gcode`), gcode);
    }
    
    res.json({ success: true, shape });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// List saved shapes
app.get('/api/shape/list', async (req, res) => {
  try {
    const files = await fs.readdir(SHAPES_DIR);
    const shapes = [];
    
    for (const file of files) {
      if (file.endsWith('.json')) {
        const data = await fs.readFile(path.join(SHAPES_DIR, file), 'utf-8');
        shapes.push(JSON.parse(data));
      }
    }
    
    res.json(shapes);
  } catch (err) {
    res.json([]);
  }
});

// Get a specific shape
app.get('/api/shape/:id', async (req, res) => {
  try {
    const shapeFile = path.join(SHAPES_DIR, `${req.params.id}.json`);
    const data = await fs.readFile(shapeFile, 'utf-8');
    const shape = JSON.parse(data);
    
    // Check if STL/G-code files exist
    shape.hasStl = fsSync.existsSync(path.join(SHAPES_DIR, `${req.params.id}.stl`));
    shape.hasGcode = fsSync.existsSync(path.join(SHAPES_DIR, `${req.params.id}.gcode`));
    
    res.json(shape);
  } catch (err) {
    res.status(404).json({ error: 'Shape not found' });
  }
});

// Download shape STL
app.get('/api/shape/:id/stl', async (req, res) => {
  try {
    const stlFile = path.join(SHAPES_DIR, `${req.params.id}.stl`);
    const shapeFile = path.join(SHAPES_DIR, `${req.params.id}.json`);
    const shapeData = JSON.parse(await fs.readFile(shapeFile, 'utf-8'));
    
    res.setHeader('Content-Type', 'application/octet-stream');
    res.setHeader('Content-Disposition', `attachment; filename="${shapeData.name.replace(/[^a-z0-9]/gi, '_')}.stl"`);
    res.sendFile(stlFile);
  } catch (err) {
    res.status(404).json({ error: 'STL not found' });
  }
});

// Download shape G-code
app.get('/api/shape/:id/gcode', async (req, res) => {
  try {
    const gcodeFile = path.join(SHAPES_DIR, `${req.params.id}.gcode`);
    const shapeFile = path.join(SHAPES_DIR, `${req.params.id}.json`);
    const shapeData = JSON.parse(await fs.readFile(shapeFile, 'utf-8'));
    
    res.setHeader('Content-Type', 'text/plain');
    res.setHeader('Content-Disposition', `attachment; filename="${shapeData.name.replace(/[^a-z0-9]/gi, '_')}.gcode"`);
    res.sendFile(gcodeFile);
  } catch (err) {
    res.status(404).json({ error: 'G-code not found' });
  }
});

// =====================
// Catch-all for React routing
// =====================

if (process.env.NODE_ENV === 'production') {
  app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
  });
}

// Start server
Promise.all([initDataFile(), initShapeDirectories()]).then(() => {
  app.listen(PORT, () => {
    console.log(`Printer Designer server running on http://localhost:${PORT}`);
    if (PUBLISHER_PASSWORD) {
      console.log('Publisher mode: Password protected');
    } else {
      console.log('Publisher mode: Open (no password set)');
    }
    console.log('Shape Designer: Ready');
  });
});
