#!/bin/bash

# Kolam Ikan IoT Docker Setup Script
# This script sets up the complete Docker environment for the fish pond monitoring system

echo "🐳 Setting up Kolam Ikan IoT Docker Environment..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create necessary directories
echo "📁 Creating directory structure..."
mkdir -p docker/mqtt/config
mkdir -p docker/mqtt/data
mkdir -p docker/mqtt/log
mkdir -p docker/backend/logs
mkdir -p docker/grafana/provisioning/dashboards
mkdir -p docker/grafana/provisioning/datasources
mkdir -p data/influxdb
mkdir -p data/grafana
mkdir -p data/redis

# Set permissions for MQTT directories
echo "🔧 Setting up MQTT permissions..."
chmod -R 777 docker/mqtt/

# Copy environment file if it doesn't exist
if [ ! -f docker/backend/.env ]; then
    echo "📄 Creating environment file..."
    cp docker/backend/.env.example docker/backend/.env
    echo "⚠️  Please edit docker/backend/.env with your Firebase credentials"
fi

# Create MQTT password file (optional)
echo "🔐 Setting up MQTT authentication..."
touch docker/mqtt/config/passwd

# Create Grafana datasource configuration
cat > docker/grafana/provisioning/datasources/influxdb.yml << 'EOF'
apiVersion: 1

datasources:
  - name: InfluxDB
    type: influxdb
    access: proxy
    url: http://influxdb:8086
    database: kolam_sensors
    user: kolam_user
    password: kolam123
    isDefault: true
EOF

# Create Grafana dashboard configuration
cat > docker/grafana/provisioning/dashboards/dashboard.yml << 'EOF'
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    options:
      path: /etc/grafana/provisioning/dashboards
EOF

# Start Docker containers
echo "🚀 Starting Docker containers..."
cd docker
docker-compose up -d

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 10

# Check container status
echo "📊 Container Status:"
docker-compose ps

# Show service URLs
echo ""
echo "🎉 Setup Complete! Services are available at:"
echo "📊 Grafana Dashboard: http://localhost:3001 (admin/admin123)"
echo "🗄️  InfluxDB: http://localhost:8086"
echo "🚀 API Server: http://localhost:3000"
echo "🦟 MQTT Broker: localhost:1883"
echo "🗄️  Redis: localhost:6379"
echo ""
echo "📝 Next steps:"
echo "1. Edit docker/backend/.env with your Firebase credentials"
echo "2. Configure your ESP32 to connect to MQTT broker"
echo "3. Test the Flutter app connection"
echo ""
echo "📊 To view logs: docker-compose logs -f [service_name]"
echo "🛑 To stop: docker-compose down"
echo "🔄 To restart: docker-compose restart"