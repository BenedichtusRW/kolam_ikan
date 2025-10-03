const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Basic logging
const log = (message) => {
  console.log(`[${new Date().toISOString()}] ${message}`);
};

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage()
  });
});

// API endpoints
app.get('/api/sensor-data/:pondId', (req, res) => {
  const { pondId } = req.params;
  log(`Getting sensor data for pond: ${pondId}`);
  
  // Mock sensor data
  res.json({
    success: true,
    data: {
      pondId,
      temperature: 25.5 + Math.random() * 5,
      oxygen: 6.2 + Math.random() * 2,
      phLevel: 7.1 + Math.random() * 0.5,
      timestamp: new Date().toISOString()
    }
  });
});

app.post('/api/sensor-data', (req, res) => {
  log('Received sensor data:', JSON.stringify(req.body));
  res.json({ success: true, message: 'Sensor data received' });
});

app.post('/api/control/:deviceId', (req, res) => {
  const { deviceId } = req.params;
  log(`Control command for device ${deviceId}:`, JSON.stringify(req.body));
  res.json({ success: true, message: 'Control command sent' });
});

app.get('/api/device-status/:deviceId', (req, res) => {
  const { deviceId } = req.params;
  res.json({
    success: true,
    data: {
      deviceId,
      online: true,
      lastSeen: new Date().toISOString(),
      devices: {
        heater: Math.random() > 0.5,
        aerator: Math.random() > 0.5,
        phPump: Math.random() > 0.5
      }
    }
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// Error handler
app.use((error, req, res, next) => {
  log(`Error: ${error.message}`);
  res.status(500).json({ error: 'Internal server error' });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  log(`🚀 Kolam Ikan API Server running on port ${PORT}`);
  log(`📊 Health check: http://localhost:${PORT}/health`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  log('SIGINT received, shutting down gracefully');
  process.exit(0);
});