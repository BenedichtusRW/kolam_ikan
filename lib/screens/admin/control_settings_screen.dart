import 'package:flutter/material.dart';

enum ControlMode { manual, automatic }

class ControlSettingsScreen extends StatefulWidget {
  const ControlSettingsScreen({super.key});

  @override
  State<ControlSettingsScreen> createState() => _ControlSettingsScreenState();
}

class _ControlSettingsScreenState extends State<ControlSettingsScreen> {
  // Temperature control variables
  ControlMode _tempControlMode = ControlMode.automatic;
  bool _tempManualStatus = false;
  double _tempMinThreshold = 25.0;
  double _tempMaxThreshold = 30.0;
  bool _tempAutoEnabled = true;

  // pH control variables
  ControlMode _phControlMode = ControlMode.automatic;
  bool _phManualStatus = false;
  double _phMinThreshold = 6.5;
  double _phMaxThreshold = 8.5;
  bool _phAutoEnabled = true;

  // Oxygen control variables
  ControlMode _oxygenControlMode = ControlMode.automatic;
  bool _oxygenManualStatus = false;
  double _oxygenMinThreshold = 5.0;
  double _oxygenMaxThreshold = 10.0;
  bool _oxygenAutoEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Pusat Kontrol',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[800]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Pusat Kontrol Sistem',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Kelola semua parameter kolam ikan secara terpusat',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Control Cards Section
            Text(
              'Parameter Kontrol',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),

            // Temperature Control Card
            _buildControlCard(
              title: 'Kontrol Suhu',
              icon: Icons.thermostat,
              color: Colors.orange,
              unit: 'C',
              currentMode: _tempControlMode,
              manualStatus: _tempManualStatus,
              minValue: _tempMinThreshold,
              maxValue: _tempMaxThreshold,
              autoEnabled: _tempAutoEnabled,
              onModeChanged: (mode) => setState(() => _tempControlMode = mode),
              onManualToggle: (value) => setState(() => _tempManualStatus = value),
              onMinChanged: (value) => setState(() => _tempMinThreshold = value),
              onMaxChanged: (value) => setState(() => _tempMaxThreshold = value),
              onAutoToggle: (value) => setState(() => _tempAutoEnabled = value),
            ),

            const SizedBox(height: 16),

            // pH Control Card
            _buildControlCard(
              title: 'Kontrol pH',
              icon: Icons.water_drop,
              color: Colors.green,
              unit: 'pH',
              currentMode: _phControlMode,
              manualStatus: _phManualStatus,
              minValue: _phMinThreshold,
              maxValue: _phMaxThreshold,
              autoEnabled: _phAutoEnabled,
              onModeChanged: (mode) => setState(() => _phControlMode = mode),
              onManualToggle: (value) => setState(() => _phManualStatus = value),
              onMinChanged: (value) => setState(() => _phMinThreshold = value),
              onMaxChanged: (value) => setState(() => _phMaxThreshold = value),
              onAutoToggle: (value) => setState(() => _phAutoEnabled = value),
            ),

            const SizedBox(height: 16),

            // Oxygen Control Card
            _buildControlCard(
              title: 'Kontrol Oksigen',
              icon: Icons.air,
              color: Colors.lightBlue,
              unit: 'mg/L',
              currentMode: _oxygenControlMode,
              manualStatus: _oxygenManualStatus,
              minValue: _oxygenMinThreshold,
              maxValue: _oxygenMaxThreshold,
              autoEnabled: _oxygenAutoEnabled,
              onModeChanged: (mode) => setState(() => _oxygenControlMode = mode),
              onManualToggle: (value) => setState(() => _oxygenManualStatus = value),
              onMinChanged: (value) => setState(() => _oxygenMinThreshold = value),
              onMaxChanged: (value) => setState(() => _oxygenMaxThreshold = value),
              onAutoToggle: (value) => setState(() => _oxygenAutoEnabled = value),
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Simpan Pengaturan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlCard({
    required String title,
    required IconData icon,
    required MaterialColor color,
    required String unit,
    required ControlMode currentMode,
    required bool manualStatus,
    required double minValue,
    required double maxValue,
    required bool autoEnabled,
    required Function(ControlMode) onModeChanged,
    required Function(bool) onManualToggle,
    required Function(double) onMinChanged,
    required Function(double) onMaxChanged,
    required Function(bool) onAutoToggle,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'Unit: $unit',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mode Selection
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onModeChanged(ControlMode.manual),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: currentMode == ControlMode.manual
                              ? color[600]
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Manual',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: currentMode == ControlMode.manual
                                ? Colors.white
                                : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onModeChanged(ControlMode.automatic),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: currentMode == ControlMode.automatic
                              ? color[600]
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Otomatis',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: currentMode == ControlMode.automatic
                                ? Colors.white
                                : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Manual Control Section
            if (currentMode == ControlMode.manual) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kontrol Manual',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: color[700],
                          ),
                        ),
                        Switch(
                          value: manualStatus,
                          onChanged: onManualToggle,
                          activeColor: color[600],
                        ),
                      ],
                    ),
                    if (manualStatus) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color[600],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Sistem sedang dalam mode manual',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Automatic Control Section
            if (currentMode == ControlMode.automatic) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kontrol Otomatis',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: color[700],
                          ),
                        ),
                        Switch(
                          value: autoEnabled,
                          onChanged: onAutoToggle,
                          activeColor: color[600],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Threshold Settings
                    Text(
                      'Pengaturan Ambang Batas',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: color[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Min Threshold
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Minimum:',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            initialValue: minValue.toString(),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              suffix: Text(unit),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              isDense: true,
                            ),
                            onChanged: (value) {
                              final double? newValue = double.tryParse(value);
                              if (newValue != null) {
                                onMinChanged(newValue);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Max Threshold
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Maksimum:',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            initialValue: maxValue.toString(),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              suffix: Text(unit),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              isDense: true,
                            ),
                            onChanged: (value) {
                              final double? newValue = double.tryParse(value);
                              if (newValue != null) {
                                onMaxChanged(newValue);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _saveSettings() {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Pengaturan berhasil disimpan!'),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
      ),
    );

    // Here you would typically save the settings to a database or shared preferences
    print('Temperature Settings:');
    print('  Mode: $_tempControlMode');
    print('  Manual Status: $_tempManualStatus');
    print('  Min Threshold: $_tempMinThreshold');
    print('  Max Threshold: $_tempMaxThreshold');
    print('  Auto Enabled: $_tempAutoEnabled');
    
    print('pH Settings:');
    print('  Mode: $_phControlMode');
    print('  Manual Status: $_phManualStatus');
    print('  Min Threshold: $_phMinThreshold');
    print('  Max Threshold: $_phMaxThreshold');
    print('  Auto Enabled: $_phAutoEnabled');
    
    print('Oxygen Settings:');
    print('  Mode: $_oxygenControlMode');
    print('  Manual Status: $_oxygenManualStatus');
    print('  Min Threshold: $_oxygenMinThreshold');
    print('  Max Threshold: $_oxygenMaxThreshold');
    print('  Auto Enabled: $_oxygenAutoEnabled');
  }
}
