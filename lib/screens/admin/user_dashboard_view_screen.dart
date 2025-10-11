import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:excel/excel.dart' as excel_pkg;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../providers/dashboard_provider.dart';
import '../../utils/mock_data_generator.dart';
import '../../widgets/modern_gauge_widget.dart';
import 'user_list_screen.dart';

// Clean admin dashboard implementation matching requested UI (blue theme, gauge cards)
class UserDashboardViewScreen extends StatefulWidget {
  final String? userId;
  final String? userName;
  final String? pondId;
  final String? pondName;

  const UserDashboardViewScreen({Key? key, this.userId, this.userName, this.pondId, this.pondName}) : super(key: key);

  @override
  State<UserDashboardViewScreen> createState() => _UserDashboardViewScreenState();
}

class _UserDashboardViewScreenState extends State<UserDashboardViewScreen> {
  String _selectedChartType = 'temperature';
  final Color _primaryBlue = const Color(0xFF1976D2);

  @override
  Widget build(BuildContext context) {
    // Mock sample users for admin overview (replace with Firestore fetch in production)
    final sampleUsers = [
      {
        'uid': 'user_budi',
        'name': 'Budi Santoso',
        'email': 'budi@example.com',
        'pond': 'Kolam A',
        'pondId': 'pond_a',
        'sensors': 4,
        'alerts': 2,
        'status': 'Active',
        'temperature': 28.5,
        'ph': 7.2,
        'oxygen': 8.4,
      },
      {
        'uid': 'user_siti',
        'name': 'Siti Nurhaliza',
        'email': 'siti@example.com',
        'pond': 'Kolam B',
        'pondId': 'pond_b',
        'sensors': 4,
        'alerts': 0,
        'status': 'Active',
        'temperature': 27.1,
        'ph': 7.6,
        'oxygen': 9.1,
      },
      {
        'uid': 'user_ahmad',
        'name': 'Ahmad Rahman',
        'email': 'ahmad@example.com',
        'pond': 'Kolam C',
        'pondId': 'pond_c',
        'sensors': 3,
        'alerts': 1,
        'status': 'Inactive',
        'temperature': 26.3,
        'ph': 6.9,
        'oxygen': 7.0,
      },
    ];

    final totalUsers = sampleUsers.length;
    final activeUsers = sampleUsers.where((u) => u['status'] == 'Active').length;
    final totalDevices = sampleUsers.fold<int>(0, (p, u) => p + (u['sensors'] as int));

    // If userId provided, show per-user view
    if (widget.userId != null) return _buildPerUserView();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dashboard Admin', style: TextStyle(color: Colors.white)),
        backgroundColor: _primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list, color: Colors.black54),
                const SizedBox(width: 8),
                const Text('Filter:', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: 'All Users',
                  items: ['All Users', 'Active', 'Inactive']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (_) {},
                ),
                const Spacer(),
                    ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => UserListScreen()));
                  },
                  icon: const Icon(Icons.manage_accounts, color: Colors.white),
                  label: const Text('Manage Users', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: _primaryBlue, foregroundColor: Colors.white),
                )
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildSummaryCard(Icons.group, 'Total Users', totalUsers.toString(), _primaryBlue)),
                const SizedBox(width: 12),
                Expanded(child: _buildSummaryCard(Icons.person, 'Active Users', activeUsers.toString(), _primaryBlue.withOpacity(0.9))),
                const SizedBox(width: 12),
                Expanded(child: _buildSummaryCard(Icons.devices_other, 'Total Devices', totalDevices.toString(), _primaryBlue.withOpacity(0.7))),
              ],
            ),

            const SizedBox(height: 16),
            const Text('Users', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Column(children: sampleUsers.map((u) => _buildAdminUserCard(u)).toList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _generatePDFReport();
          await _generateExcelReport();
        },
        label: const Text('Export Semua', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.download_rounded, color: Colors.white),
        backgroundColor: _primaryBlue,
      ),
    );
  }

  // Per-user view
  Widget _buildPerUserView() {
    return ChangeNotifierProvider<DashboardProvider>(
      create: (_) {
        final dp = DashboardProvider();
        if (widget.pondId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await dp.switchPond(widget.pondId!, '');
            Future.delayed(const Duration(milliseconds: 250), () {
              if (dp.recentData.isEmpty) dp.enableTestingMode();
            });
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            dp.enableTestingMode();
          });
        }
        return dp;
      },
      child: Consumer<DashboardProvider>(builder: (context, dashboardProvider, child) {
        final temp = dashboardProvider.currentSensorData?.temperature ?? 25.0;
        final oxy = dashboardProvider.currentSensorData?.oxygen ?? 7.0;
        final ph = dashboardProvider.currentSensorData?.phLevel ?? 7.0;

        final tempStatus = GaugeHelper.getTemperatureStatus(temp);
        final oxyStatus = GaugeHelper.getOxygenStatus(oxy);
        final phStatus = GaugeHelper.getPhStatus(ph);

        return Scaffold(
          appBar: AppBar(title: Text(widget.userName ?? 'User Dashboard'), backgroundColor: _primaryBlue),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(widget.userName ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('Kolam: ${widget.pondName ?? widget.pondId ?? ''}'),
                      const SizedBox(height: 8),
                      Row(children: [
                        ElevatedButton.icon(onPressed: _generatePDFReport, icon: const Icon(Icons.picture_as_pdf), label: const Text('Download PDF'), style: ElevatedButton.styleFrom(backgroundColor: _primaryBlue, foregroundColor: Colors.white)),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(onPressed: _generateExcelReport, icon: const Icon(Icons.table_chart), label: const Text('Download Excel'), style: ElevatedButton.styleFrom(backgroundColor: _primaryBlue, foregroundColor: Colors.white)),
                      ])
                    ]),
                  ),
                ),

                const SizedBox(height: 16),

                // Gauges as cards to match screenshot
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Kondisi Terkini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      LayoutBuilder(builder: (ctx, constraints) {
                        final wide = constraints.maxWidth > 600;
                        if (wide) {
                          return Column(children: [
                            Row(children: [
                              Expanded(child: _buildGaugeCard(title: 'Suhu Air', icon: Icons.thermostat, value: temp, unit: '°C', minValue: 20, maxValue: 35, status: tempStatus, ranges: GaugeHelper.getTemperatureRanges())),
                              const SizedBox(width: 12),
                              Expanded(child: _buildGaugeCard(title: 'Oksigen', icon: Icons.air, value: oxy, unit: 'ppm', minValue: 0, maxValue: 15, status: oxyStatus, ranges: GaugeHelper.getOxygenRanges())),
                            ]),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(child: _buildGaugeCard(title: 'pH', icon: Icons.science, value: ph, unit: '', minValue: 6, maxValue: 8.5, status: phStatus, ranges: GaugeHelper.getPhRanges())),
                              const SizedBox(width: 12),
                              const Expanded(child: SizedBox()),
                            ])
                          ]);
                        } else {
                          return Column(children: [
                            _buildGaugeCard(title: 'Suhu Air', icon: Icons.thermostat, value: temp, unit: '°C', minValue: 20, maxValue: 35, status: tempStatus, ranges: GaugeHelper.getTemperatureRanges()),
                            const SizedBox(height: 12),
                            _buildGaugeCard(title: 'Oksigen', icon: Icons.air, value: oxy, unit: 'ppm', minValue: 0, maxValue: 15, status: oxyStatus, ranges: GaugeHelper.getOxygenRanges()),
                            const SizedBox(height: 12),
                            _buildGaugeCard(title: 'pH', icon: Icons.science, value: ph, unit: '', minValue: 6, maxValue: 8.5, status: phStatus, ranges: GaugeHelper.getPhRanges()),
                          ]);
                        }
                      })
                    ]),
                  ),
                ),

                const SizedBox(height: 16),

                // Trend chart (full)
                Card(
                  elevation: 3,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    height: 360,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Grafik Tren (Hari ini)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      // Chart selector
                      Container(
                        height: 44,
                        child: Row(children: [Expanded(child: _perUserChartTab('Suhu', _selectedChartType == 'temperature')), const SizedBox(width: 8), Expanded(child: _perUserChartTab('pH', _selectedChartType == 'ph')), const SizedBox(width: 8), Expanded(child: _perUserChartTab('Oksigen', _selectedChartType == 'oxygen'))]),
                      ),
                      const SizedBox(height: 12),

                      // Chart area
                      Expanded(
                        child: Provider.of<DashboardProvider>(context, listen: false).recentData.isNotEmpty
                            ? _buildPerUserLineChart(Provider.of<DashboardProvider>(context, listen: false))
                            : Container(
                                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                                child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.show_chart, size: 48, color: Colors.grey[400]), const SizedBox(height: 8), Text('Tidak ada data sensor', style: TextStyle(color: Colors.grey[600]))]))),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _perUserChartTab(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChartType = label == 'Suhu'
              ? 'temperature'
              : label == 'pH'
                  ? 'ph'
                  : 'oxygen';
        });
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(color: isSelected ? _primaryBlue : Colors.transparent, borderRadius: BorderRadius.circular(6)),
        child: Center(child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
      ),
    );
  }

  Widget _buildSummaryCard(IconData icon, String title, String value, Color color) {
    return Card(
      color: const Color(0xFFF3E8FF),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(children: [Icon(icon, color: color, size: 26), const SizedBox(height: 6), Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 13))]),
      ),
    );
  }

  Widget _buildAdminUserCard(Map u) {
    return Card(
      color: const Color(0xFFFAF7FF),
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          // Middle: user info
          Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(u['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text('Jumlah Alat: ${u['sensors']}', style: TextStyle(color: Colors.grey[700]))
          ])),

          // Right: show three compact gauge cards (Suhu, pH, Oksigen) for quick admin view
          Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.center, children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
        _buildMiniGauge(
      title: 'Suhu',
      icon: Icons.thermostat,
      value: (u['temperature'] as double),
      unit: '°C',
      minV: 20,
      maxV: 35,
      ranges: GaugeHelper.getTemperatureRanges(),
      status: GaugeHelper.getTemperatureStatus((u['temperature'] as double)),
      color: Colors.blueAccent,
      useThermometer: false,
      speedometer: true),
        const SizedBox(width: 8),
        _buildMiniGauge(
      title: 'pH',
      icon: Icons.science,
      value: (u['ph'] as double),
      unit: '',
      minV: 6,
      maxV: 8.5,
      ranges: GaugeHelper.getPhRanges(),
      status: GaugeHelper.getPhStatus((u['ph'] as double)),
      color: Colors.green,
      speedometer: true),
        const SizedBox(width: 8),
        _buildMiniGauge(
      title: 'Oksigen',
      icon: Icons.air,
      value: (u['oxygen'] as double),
      unit: 'ppm',
      minV: 0,
      maxV: 15,
      ranges: GaugeHelper.getOxygenRanges(),
      status: GaugeHelper.getOxygenStatus((u['oxygen'] as double)),
      color: Colors.orangeAccent,
      speedometer: true),
              ]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => UserDashboardViewScreen(userId: u['uid'], userName: u['name'], pondId: u['pondId'], pondName: u['pond'])));
            }, child: const Text('Lihat Dashboard'), style: ElevatedButton.styleFrom(backgroundColor: _primaryBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8))),
            const SizedBox(height: 6),
            TextButton(onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fungsi Jadikan Admin dipanggil untuk ${u['name']}')));
            }, child: const Text('Jadikan Admin'))
          ])
        ]),
        ),
    );
  }


  Widget _buildMiniGauge({required String title, required IconData icon, required double value, String unit = '', required double minV, required double maxV, required List<GaugeRange> ranges, required Map<String, dynamic> status, Color? color, bool useThermometer = false, bool speedometer = false}) {
    // Circular mini-gauge tile
    return SizedBox(
      width: 96,
      height: 96,
      child: LayoutBuilder(builder: (ctx, constraints) {
        // Force the internal column to flex and fit inside 96x96. Use slightly smaller gauges to avoid overflow.
        final gaugeSize = min(constraints.maxWidth, constraints.maxHeight) * 0.55; // ~52-54px on 96px tile
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Flexible(
            fit: FlexFit.loose,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (useThermometer)
                  SizedBox(width: gaugeSize, height: gaugeSize, child: VeryMiniThermometer(value: value, minValue: minV, maxValue: maxV, size: gaugeSize, color: color ?? Colors.red))
                else
            ClipOval(
              child: Container(
                width: gaugeSize + 8,
                height: gaugeSize + 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: (color ?? _primaryBlue).withOpacity(0.08), width: 2),
                  boxShadow: [BoxShadow(color: (color ?? _primaryBlue).withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
                  gradient: LinearGradient(colors: [Colors.white, Colors.grey[50]!], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                child: Stack(children: [
                  Center(child: SizedBox(width: gaugeSize, height: gaugeSize, child: VeryMiniGauge(value: value, minValue: minV, maxValue: maxV, ranges: ranges, size: gaugeSize, unit: unit, needleColor: color, speedometer: speedometer))),
                  // small top cap indicator for style
                  Positioned(top: 6, left: 0, right: 0, child: Center(child: Container(width: gaugeSize * 0.12, height: 4, decoration: BoxDecoration(color: (color ?? _primaryBlue).withOpacity(0.9), borderRadius: BorderRadius.circular(2))))),
                ]),
              ),
            ),
              ]),
            ),
          ),
          const SizedBox(height: 4),
          Text(value.toStringAsFixed(value % 1 == 0 ? 0 : 1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 2),
          Text(status['status'] ?? '', style: TextStyle(color: color ?? status['color'] ?? _primaryBlue, fontSize: 11)),
        ]);
      }),
    );
  }
  

  Widget _buildGaugeCard({required String title, required IconData icon, required double value, String unit = '', required double minValue, required double maxValue, required Map<String, dynamic> status, required List<GaugeRange> ranges}) {
    return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Icon(icon, color: _primaryBlue), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w600))]),
              const SizedBox(height: 12),
              ModernGaugeWidget(title: '', value: value, unit: unit, minValue: minValue, maxValue: maxValue, status: status['status'], statusColor: status['color'], icon: icon, ranges: ranges, compact: true, height: 120, speedometer: true),
              const SizedBox(height: 8),
              Text(value.toStringAsFixed(value % 1 == 0 ? 0 : 1), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(status['status'] ?? '', style: TextStyle(color: status['color'] ?? _primaryBlue))
            ])));
  }

  Widget _buildPerUserLineChart(DashboardProvider provider) {
    // Build a LineChart using provider.recentData; fallback to mock data when empty
  final data = provider.recentData.isNotEmpty ? provider.recentData : MockDataGenerator.generateDailyMockData(date: DateTime.now(), pondId: widget.pondId ?? 'mock');
    // pick field
    final values = <double>[];
    for (final d in data) {
      if (_selectedChartType == 'temperature')
        values.add(d.temperature);
      else if (_selectedChartType == 'ph')
        values.add(d.phLevel);
      else
        values.add(d.oxygen);
    }

    final spots = List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i]));

    final minY = (values.isEmpty ? 0.0 : values.reduce(min)) - 1.0;
    final maxY = (values.isEmpty ? 10.0 : values.reduce(max)) + 1.0;

    return LineChart(LineChartData(
      gridData: FlGridData(show: true, horizontalInterval: (maxY - minY) / 4),
      titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true))),
      borderData: FlBorderData(show: false),
      minY: minY,
      maxY: maxY,
      lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: _primaryBlue, barWidth: 2, dotData: FlDotData(show: false))],
    ));
  }

  Future<void> _generatePDFReport() async {
    try {
      _showProgressSnackBar('Membuat laporan PDF...');
      final String content = 'Laporan Monitoring Kolam Ikan - ${widget.userName ?? ''}\nKolam: ${widget.pondName ?? ''}\nTanggal: ${DateTime.now()}\n\n(Ini adalah file PDF placeholder yang berisi teks. Untuk hasil terbaik gunakan package pdf.)';
      final Uint8List bytes = Uint8List.fromList(utf8.encode(content));
      String fileName = 'Laporan_${(widget.userName ?? 'user').replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final savedPath = await _saveFileBytes(bytes, fileName, preferDownloads: true);
      if (savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [Icon(Icons.check_circle, color: Colors.white), const SizedBox(width: 8), Expanded(child: Text('Laporan PDF berhasil disimpan di: $savedPath'))]), backgroundColor: Colors.green, duration: const Duration(seconds: 6), action: SnackBarAction(label: 'Salin path', textColor: Colors.white, onPressed: () { Clipboard.setData(ClipboardData(text: savedPath)); })));
      } else {
        _showErrorSnackBar('Gagal menyimpan laporan PDF. Coba berikan izin penyimpanan atau cek pengaturan aplikasi.');
      }
    } catch (e) {
      _showErrorSnackBar('Gagal membuat laporan PDF: ${e.toString()}');
    }
  }

  Future<void> _generateExcelReport() async {
    try {
      _showProgressSnackBar('Membuat laporan Excel...');
      var xls = excel_pkg.Excel.createExcel();
      excel_pkg.Sheet sheetObject = xls['Sheet1'];
      sheetObject.cell(excel_pkg.CellIndex.indexByString('A1')).value = excel_pkg.TextCellValue('Laporan Monitoring Kolam Ikan - ${widget.userName ?? ''}');
      sheetObject.cell(excel_pkg.CellIndex.indexByString('A2')).value = excel_pkg.TextCellValue('Kolam: ${widget.pondName ?? ''}');
      sheetObject.cell(excel_pkg.CellIndex.indexByString('A3')).value = excel_pkg.TextCellValue('Tanggal: ${DateTime.now().toString().split(' ')[0]}');
      sheetObject.cell(excel_pkg.CellIndex.indexByString('A5')).value = excel_pkg.TextCellValue('Waktu');
      sheetObject.cell(excel_pkg.CellIndex.indexByString('B5')).value = excel_pkg.TextCellValue('Suhu (°C)');
      sheetObject.cell(excel_pkg.CellIndex.indexByString('C5')).value = excel_pkg.TextCellValue('pH');
      sheetObject.cell(excel_pkg.CellIndex.indexByString('D5')).value = excel_pkg.TextCellValue('Oksigen (ppm)');
      Random random = Random();
      for (int i = 0; i < 24; i++) {
        int row = i + 6;
        sheetObject.cell(excel_pkg.CellIndex.indexByString('A$row')).value = excel_pkg.TextCellValue('${DateTime.now().subtract(Duration(hours: 23 - i)).hour.toString().padLeft(2, '0')}:00');
        sheetObject.cell(excel_pkg.CellIndex.indexByString('B$row')).value = excel_pkg.TextCellValue((28 + random.nextDouble() * 4).toStringAsFixed(1));
        sheetObject.cell(excel_pkg.CellIndex.indexByString('C$row')).value = excel_pkg.TextCellValue((7.0 + random.nextDouble() * 1.5).toStringAsFixed(1));
        sheetObject.cell(excel_pkg.CellIndex.indexByString('D$row')).value = excel_pkg.TextCellValue((6 + random.nextDouble() * 2).toStringAsFixed(1));
      }
      final List<int>? encoded = xls.encode();
      if (encoded == null) {
        _showErrorSnackBar('Gagal membuat file Excel (encoding error)');
        return;
      }
      String fileName = 'Laporan_${(widget.userName ?? 'user').replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final savedPath = await _saveFileBytes(Uint8List.fromList(encoded), fileName, preferDownloads: true);
      if (savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [Icon(Icons.check_circle, color: Colors.white), const SizedBox(width: 8), Expanded(child: Text('Laporan Excel berhasil disimpan di: $savedPath'))]), backgroundColor: Colors.green, duration: const Duration(seconds: 6), action: SnackBarAction(label: 'Salin path', textColor: Colors.white, onPressed: () { Clipboard.setData(ClipboardData(text: savedPath)); })));
      } else {
        _showErrorSnackBar('Gagal menyimpan laporan Excel. Coba berikan izin penyimpanan atau cek pengaturan aplikasi.');
      }
    } catch (e) {
      _showErrorSnackBar('Gagal membuat laporan Excel: ${e.toString()}');
    }
  }

  Future<String?> _saveFileBytes(Uint8List bytes, String fileName, {bool preferDownloads = true}) async {
    try {
      Directory? targetDir;
      if (Platform.isAndroid && preferDownloads) {
        bool canWriteDownloads = false;
        try {
          if (await Permission.manageExternalStorage.isGranted) {
            canWriteDownloads = true;
          } else if (await Permission.storage.isGranted) {
            canWriteDownloads = true;
          } else {
            var status = await Permission.storage.request();
            if (status.isGranted) {
              canWriteDownloads = true;
            } else {
              var mgr = await Permission.manageExternalStorage.request();
              if (mgr.isGranted) canWriteDownloads = true;
            }
          }
        } catch (e) {
          canWriteDownloads = false;
        }

        if (canWriteDownloads) {
          try {
            final downloads = Directory('/storage/emulated/0/Download');
            if (await downloads.exists()) {
              targetDir = downloads;
            } else {
              targetDir = await getExternalStorageDirectory();
            }
            if (targetDir != null) {
              final file = File('${targetDir.path}/$fileName');
              await file.writeAsBytes(bytes);
              return file.path;
            }
          } catch (e) {
            // ignore and fallback
          }
        }
      }

      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        final file = File('${appDocDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        return file.path;
      } catch (e) {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void _showProgressSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))), const SizedBox(width: 12), Text(message)]), backgroundColor: Colors.orange, duration: const Duration(seconds: 2)));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [Icon(Icons.error, color: Colors.white), const SizedBox(width: 8), Expanded(child: Text(message))]), backgroundColor: Colors.red, duration: const Duration(seconds: 4)));
  }
}

