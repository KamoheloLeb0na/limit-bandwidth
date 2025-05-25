const express = require('express');
const app = express();
app.use(express.json());

app.post('/api/payment-hook', (req, res) => {
  console.log('[Webhook Received]', req.body);

  // Here you can:
  // - Grant access by modifying DB
  // - Notify admin
  // - Start FreeRADIUS session
  // - etc.

  res.status(200).json({ status: 'ok' });
});

app.listen(5000, () => {
  console.log('✅ Webhook server listening on http://localhost:5000');
});
