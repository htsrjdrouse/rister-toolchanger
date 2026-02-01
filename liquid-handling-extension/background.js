// Background service worker for the extension
console.log('Liquid Handling Extension background script loaded');

// Store window ID to check if already open
let controlWindowId = null;

// Handle extension installation
chrome.runtime.onInstalled.addListener((details) => {
  if (details.reason === 'install') {
    console.log('Extension installed successfully');
  } else if (details.reason === 'update') {
    console.log('Extension updated to version', chrome.runtime.getManifest().version);
  }
});

// Handle extension icon click - open detachable window
chrome.action.onClicked.addListener(async () => {
  // Check if window is already open
  if (controlWindowId !== null) {
    try {
      const window = await chrome.windows.get(controlWindowId);
      // Window exists, focus it
      await chrome.windows.update(controlWindowId, { focused: true });
      console.log('Focused existing control window');
      return;
    } catch (error) {
      // Window was closed, create a new one
      controlWindowId = null;
    }
  }

  // Create new popup window
  const window = await chrome.windows.create({
    url: chrome.runtime.getURL('ui/popup.html'),
    type: 'popup',
    width: 1000,
    height: 800,
    left: 100,
    top: 100
  });

  controlWindowId = window.id;
  console.log('Created new control window:', controlWindowId);
});

// Clean up when window is closed
chrome.windows.onRemoved.addListener((windowId) => {
  if (windowId === controlWindowId) {
    controlWindowId = null;
    console.log('Control window closed');
  }
});

// Listen for messages from content scripts or popup
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.type === 'sendGcode') {
    // Forward G-code commands to the printer
    fetch(`${request.endpoint}/printer/gcode/script`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ script: request.gcode })
    })
    .then(response => response.json())
    .then(data => sendResponse({ success: true, data }))
    .catch(error => sendResponse({ success: false, error: error.message }));
    
    return true; // Keep message channel open for async response
  }
});
