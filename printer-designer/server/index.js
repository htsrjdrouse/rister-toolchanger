const express = require('express');
const cors = require('cors');
const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = process.env.PORT || 3100;
const IS_PRODUCTION = process.env.NODE_ENV === 'production';
const DATA_DIR = IS_PRODUCTION ? path.join(__dirname, 'data') : path.join(__dirname, '..', 'data');
const DESIGNS_FILE = path.join(DATA_DIR, 'designs.json');

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
// Catch-all for React routing
// =====================

if (process.env.NODE_ENV === 'production') {
  app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
  });
}

// Start server
initDataFile().then(() => {
  app.listen(PORT, () => {
    console.log(`Printer Designer server running on http://localhost:${PORT}`);
    if (PUBLISHER_PASSWORD) {
      console.log('Publisher mode: Password protected');
    } else {
      console.log('Publisher mode: Open (no password set)');
    }
  });
});
