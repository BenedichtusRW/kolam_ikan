const express = require('express');
const mqtt = require('mqtt');
const admin = require('firebase-admin');
const redis = require('redis');
const { InfluxDB, Point } = require('@influxdata/influxdb-client');
const cors = require('cors');
const helmet = require('helmet');
const winston = require('winston');
const cron = require('cron');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Logger setup
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
    new winston.transports.Console()
  ]
});

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert({
    projectId: process.env.FIREBASE_PROJECT_ID,
    privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
  }),
  databaseURL: `https://${process.env.FIREBASE_PROJECT_ID}.firebaseio.com`
});

const db = admin.firestore();

// Initialize Redis
const redisClient = redis.createClient({
  host: process.env.REDIS_HOST || 'redis',
  port: process.env.REDIS_PORT || 6379
});

// Initialize InfluxDB
const influxDB = new InfluxDB({
  url: process.env.INFLUXDB_URL || 'http://influxdb:8086',
  token: process.env.INFLUXDB_TOKEN || 'your-token'
});

const writeApi = influxDB.getWriteApi(
  process.env.INFLUXDB_ORG || 'kolam-org',
  process.env.INFLUXDB_BUCKET || 'sensor-data'
);

// Initialize MQTT Client
const mqttClient = mqtt.connect(`mqtt://${process.env.MQTT_BROKER || 'mosquitto'}:1883`, {
  clientId: 'kolam-backend-server',
  clean: true,
  reconnectPeriod: 1000,
});

// MQTT Topics
const TOPICS = {
  SENSOR_DATA: 'kolam/sensor/data',
  CONTROL_COMMAND: 'kolam/control/command',
  DEVICE_STATUS: 'kolam/device/status',
  ALERT: 'kolam/alert'
};

// MQTT Event Handlers
mqttClient.on('connect', () => {
  logger.info('Connected to MQTT broker');
  
  // Subscribe to topics
  Object.values(TOPICS).forEach(topic => {
    mqttClient.subscribe(topic, (err) => {
      if (err) {
        logger.error(`Failed to subscribe to ${topic}:`, err);
      } else {
        logger.info(`Subscribed to ${topic}`);
      }
    });
  });
});

mqttClient.on('message', async (topic, message) => {
  try {
    const data = JSON.parse(message.toString());
    logger.info(`Received message on ${topic}:`, data);

    switch (topic) {
      case TOPICS.SENSOR_DATA:
        await handleSensorData(data);
        break;
      case TOPICS.DEVICE_STATUS:
        await handleDeviceStatus(data);
        break;
      case TOPICS.ALERT:
        await handleAlert(data);
        break;
      default:
        logger.warn(`Unknown topic: ${topic}`);
    }
  } catch (error) {
    logger.error('Error processing MQTT message:', error);
  }
});

// Handle sensor data from IoT devices
async function handleSensorData(data) {
  try {
    // Store in InfluxDB for time-series data
    const point = new Point('sensor_reading')
      .tag('device_id', data.deviceId)
      .tag('pond_id', data.pondId)
      .tag('location', data.location)
      .floatField('temperature', data.temperature)
      .floatField('oxygen', data.oxygen)
      .floatField('ph_level', data.phLevel)
      .timestamp(new Date(data.timestamp));

    writeApi.writePoint(point);
    await writeApi.flush();

    // Store latest data in Redis for quick access
    await redisClient.setEx(
      `latest_sensor:${data.pondId}`,
      3600, // 1 hour TTL
      JSON.stringify(data)
    );

    // Store in Firebase Firestore
    await db.collection('sensor_data').add({
      ...data,
      timestamp: admin.firestore.Timestamp.fromDate(new Date(data.timestamp))
    });

    // Check for alerts
    await checkSensorAlerts(data);

    logger.info(`Sensor data processed for pond ${data.pondId}`);
  } catch (error) {
    logger.error('Error handling sensor data:', error);
  }
}

// Check sensor values and trigger alerts
async function checkSensorAlerts(data) {
  const alerts = [];

  // Temperature alerts
  if (data.temperature < 20 || data.temperature > 30) {
    alerts.push({
      type: 'temperature',
      severity: data.temperature < 15 || data.temperature > 35 ? 'critical' : 'warning',
      message: `Temperature ${data.temperature}°C is out of normal range (20-30°C)`,
      value: data.temperature,
      pondId: data.pondId
    });
  }

  // Oxygen alerts
  if (data.oxygen < 5) {
    alerts.push({
      type: 'oxygen',
      severity: data.oxygen < 3 ? 'critical' : 'warning',
      message: `Oxygen level ${data.oxygen} mg/L is below recommended minimum (5 mg/L)`,
      value: data.oxygen,
      pondId: data.pondId
    });
  }

  // pH alerts
  if (data.phLevel < 6.5 || data.phLevel > 8.5) {
    alerts.push({
      type: 'ph',
      severity: data.phLevel < 6 || data.phLevel > 9 ? 'critical' : 'warning',
      message: `pH level ${data.phLevel} is out of normal range (6.5-8.5)`,
      value: data.phLevel,
      pondId: data.pondId
    });
  }

  // Send alerts if any
  for (const alert of alerts) {
    await sendAlert(alert);
  }
}

// Send alert to mobile app via Firebase
async function sendAlert(alert) {
  try {
    // Store alert in Firestore
    await db.collection('alerts').add({
      ...alert,
      timestamp: admin.firestore.Timestamp.now(),
      status: 'active'
    });

    // Send push notification (if FCM tokens are available)
    const usersSnapshot = await db.collection('users')
      .where('assignedPonds', 'array-contains', alert.pondId)
      .get();

    const tokens = [];
    usersSnapshot.forEach(doc => {
      const userData = doc.data();
      if (userData.fcmToken) {
        tokens.push(userData.fcmToken);
      }
    });

    if (tokens.length > 0) {
      const message = {
        notification: {
          title: `Alert: ${alert.type.toUpperCase()}`,
          body: alert.message
        },
        data: {
          type: 'sensor_alert',
          severity: alert.severity,
          pondId: alert.pondId
        },
        tokens: tokens
      };

      await admin.messaging().sendMulticast(message);
      logger.info(`Alert sent to ${tokens.length} devices`);
    }

    logger.info(`Alert created: ${alert.type} - ${alert.severity}`);
  } catch (error) {
    logger.error('Error sending alert:', error);
  }
}

// Handle device status updates
async function handleDeviceStatus(data) {
  try {
    await db.collection('device_status').doc(data.deviceId).set({
      ...data,
      lastUpdate: admin.firestore.Timestamp.now()
    }, { merge: true });

    await redisClient.setEx(
      `device_status:${data.deviceId}`,
      1800, // 30 minutes TTL
      JSON.stringify(data)
    );

    logger.info(`Device status updated for ${data.deviceId}`);
  } catch (error) {
    logger.error('Error handling device status:', error);
  }
}

// Handle alerts from devices
async function handleAlert(data) {
  try {
    await sendAlert(data);
    logger.info(`Alert processed: ${data.type}`);
  } catch (error) {
    logger.error('Error handling alert:', error);
  }
}

// REST API Endpoints

// Get latest sensor data
app.get('/api/sensor/:pondId/latest', async (req, res) => {
  try {
    const { pondId } = req.params;
    
    // Try Redis first
    const cached = await redisClient.get(`latest_sensor:${pondId}`);
    if (cached) {
      return res.json(JSON.parse(cached));
    }

    // Fallback to Firestore
    const snapshot = await db.collection('sensor_data')
      .where('pondId', '==', pondId)
      .orderBy('timestamp', 'desc')
      .limit(1)
      .get();

    if (snapshot.empty) {
      return res.status(404).json({ error: 'No sensor data found' });
    }

    const data = snapshot.docs[0].data();
    res.json(data);
  } catch (error) {
    logger.error('Error getting latest sensor data:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Send control command to device
app.post('/api/control/:deviceId', async (req, res) => {
  try {
    const { deviceId } = req.params;
    const command = req.body;

    const message = {
      deviceId,
      ...command,
      timestamp: new Date().toISOString()
    };

    mqttClient.publish(TOPICS.CONTROL_COMMAND, JSON.stringify(message));
    
    logger.info(`Control command sent to ${deviceId}:`, command);
    res.json({ success: true, message: 'Command sent' });
  } catch (error) {
    logger.error('Error sending control command:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get device status
app.get('/api/device/:deviceId/status', async (req, res) => {
  try {
    const { deviceId } = req.params;
    
    const cached = await redisClient.get(`device_status:${deviceId}`);
    if (cached) {
      return res.json(JSON.parse(cached));
    }

    const doc = await db.collection('device_status').doc(deviceId).get();
    if (!doc.exists) {
      return res.status(404).json({ error: 'Device not found' });
    }

    res.json(doc.data());
  } catch (error) {
    logger.error('Error getting device status:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    services: {
      mqtt: mqttClient.connected,
      redis: redisClient.isReady,
      firebase: true
    }
  });
});

// Start server
app.listen(PORT, () => {
  logger.info(`Kolam Ikan Backend Server running on port ${PORT}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  writeApi.close();
  mqttClient.end();
  redisClient.disconnect();
  process.exit(0);
});