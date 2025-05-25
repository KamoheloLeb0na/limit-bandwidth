const pool = require('./db');
const axios = require('axios');
require('dotenv').config();

async function fetchUnprocessedSMS() {
  const [rows] = await pool.query(
    `SELECT * FROM inbox WHERE Processed = 'false' ORDER BY ID ASC LIMIT 5`
  );
  return rows;
}

function parseMessage(message) {
  const regex = /Confirmed\. (.*) sent .* Ksh([\d.]+)/i;
  const match = message.TextDecoded.match(regex);

  if (match) {
    return {
      transactionId: match[1].trim(),
      amount: parseFloat(match[2]),
      sender: message.SenderNumber,
      text: message.TextDecoded,
    };
  }
  return null;
}

async function markAsProcessed(id) {
  await pool.query(`UPDATE inbox SET Processed = 'true' WHERE ID = ?`, [id]);
}

async function sendWebhook(data) {
  try {
    const response = await axios.post(process.env.WEBHOOK_URL, data);
    console.log(`[→] Webhook sent: ${response.status}`);
  } catch (err) {
    console.error(`[!] Webhook failed:`, err.message);
  }
}

async function handleSMS(sms) {
  const parsed = parseMessage(sms);
  if (!parsed) {
    console.log(`[!] Could not parse SMS ID ${sms.ID}`);
    await markAsProcessed(sms.ID);
    return;
  }

  console.log(`[✓] Payment received: ${parsed.amount} (TX: ${parsed.transactionId})`);

  // ✅ Send data to webhook
  await sendWebhook({
    phone: parsed.sender,
    amount: parsed.amount,
    transactionId: parsed.transactionId,
    rawText: parsed.text,
    timestamp: sms.ReceivingDateTime,
  });

  await markAsProcessed(sms.ID);
}

module.exports = async function processQueue() {
  const messages = await fetchUnprocessedSMS();
  for (const msg of messages) {
    await handleSMS(msg);
  }
};
