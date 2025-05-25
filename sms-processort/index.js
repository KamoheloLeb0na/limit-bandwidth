require('dotenv').config();
const processQueue = require('./processor');

const INTERVAL = parseInt(process.env.POLL_INTERVAL) || 3000;

console.log('[✓] SMS Processor started...');

setInterval(async () => {
  try {
    await processQueue();
  } catch (err) {
    console.error('[!] Error processing queue:', err.message);
  }
}, INTERVAL);
