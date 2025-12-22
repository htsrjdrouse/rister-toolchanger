// Content script - injects into Mainsail/Fluidd pages if needed
console.log('Liquid Handling Extension content script loaded on:', window.location.href);

// Listen for messages from the popup
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.type === 'getPageInfo') {
    sendResponse({
      url: window.location.href,
      title: document.title
    });
  }
});

// Detect if this is a Mainsail or Fluidd interface
const isMainsail = window.location.href.includes('mainsail') || 
                   document.title.toLowerCase().includes('mainsail');
const isFluidd = window.location.href.includes('fluidd') || 
                 document.title.toLowerCase().includes('fluidd');

if (isMainsail || isFluidd) {
  console.log(`Detected ${isMainsail ? 'Mainsail' : 'Fluidd'} interface`);
}
