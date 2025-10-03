# Kolam Ikan IoT Docker Setup Script for Windows
# This script sets up the complete Docker environment for the fish pond monitoring system

Write-Host "🐳 Setting up Kolam Ikan IoT Docker Environment..." -ForegroundColor Cyan

# Check if Docker is installed
try {
    docker --version | Out-Null
    Write-Host "✅ Docker found" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not installed. Please install Docker Desktop first." -ForegroundColor Red
    exit 1
}

try {
    docker-compose --version | Out-Null
    Write-Host "✅ Docker Compose found" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Compose is not installed. Please install Docker Compose first." -ForegroundColor Red
    exit 1
}

# Create necessary directories
Write-Host "📁 Creating directory structure..." -ForegroundColor Yellow
$directories = @(
    "docker\mqtt\config",
    "docker\mqtt\data", 
    "docker\mqtt\log",
    "docker\backend\logs",
    "docker\grafana\provisioning\dashboards",
    "docker\grafana\provisioning\datasources",
    "data\influxdb",
    "data\grafana",
    "data\redis"
)

foreach ($dir in $directories) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "Created: $dir" -ForegroundColor Gray
    }
}

# Copy environment file if it doesn't exist
if (!(Test-Path "docker\backend\.env")) {
    Write-Host "📄 Creating environment file..." -ForegroundColor Yellow
    Copy-Item "docker\backend\.env.example" "docker\backend\.env"
    Write-Host "⚠️  Please edit docker\backend\.env with your Firebase credentials" -ForegroundColor Red
}

# Create MQTT password file (optional)
Write-Host "🔐 Setting up MQTT authentication..." -ForegroundColor Yellow
if (!(Test-Path "docker\mqtt\config\passwd")) {
    New-Item -ItemType File -Path "docker\mqtt\config\passwd" -Force | Out-Null
}

# Create Grafana datasource configuration
Write-Host "📊 Setting up Grafana datasources..." -ForegroundColor Yellow
@"
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
"@ | Out-File -FilePath "docker\grafana\provisioning\datasources\influxdb.yml" -Encoding UTF8

# Create Grafana dashboard configuration
@"
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
"@ | Out-File -FilePath "docker\grafana\provisioning\dashboards\dashboard.yml" -Encoding UTF8

# Start Docker containers
Write-Host "🚀 Starting Docker containers..." -ForegroundColor Cyan
Set-Location docker
docker-compose up -d

# Wait for services to start
Write-Host "⏳ Waiting for services to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Check container status
Write-Host "📊 Container Status:" -ForegroundColor Cyan
docker-compose ps

# Show service URLs
Write-Host ""
Write-Host "🎉 Setup Complete! Services are available at:" -ForegroundColor Green
Write-Host "📊 Grafana Dashboard: http://localhost:3001 (admin/admin123)" -ForegroundColor White
Write-Host "🗄️  InfluxDB: http://localhost:8086" -ForegroundColor White
Write-Host "🚀 API Server: http://localhost:3000" -ForegroundColor White  
Write-Host "🦟 MQTT Broker: localhost:1883" -ForegroundColor White
Write-Host "🗄️  Redis: localhost:6379" -ForegroundColor White
Write-Host ""
Write-Host "📝 Next steps:" -ForegroundColor Cyan
Write-Host "1. Edit docker\backend\.env with your Firebase credentials"
Write-Host "2. Configure your ESP32 to connect to MQTT broker"
Write-Host "3. Test the Flutter app connection"
Write-Host ""
Write-Host "📊 To view logs: docker-compose logs -f [service_name]" -ForegroundColor Gray
Write-Host "🛑 To stop: docker-compose down" -ForegroundColor Gray
Write-Host "🔄 To restart: docker-compose restart" -ForegroundColor Gray

Set-Location ..