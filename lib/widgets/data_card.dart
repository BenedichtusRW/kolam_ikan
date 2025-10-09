import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DataCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const DataCard({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse value untuk gauge calculation
    double numericValue = double.tryParse(value) ?? 0.0;
    
    // Tentukan range berdasarkan jenis sensor
    double minValue = 0.0;
    double maxValue = 100.0;
    List<GaugeRange> ranges = [];
    
    if (title.contains('Suhu')) {
      minValue = 20.0;
      maxValue = 35.0;
      ranges = [
        GaugeRange(startValue: 20, endValue: 25, color: Colors.blue.shade300),
        GaugeRange(startValue: 25, endValue: 32, color: Colors.green),
        GaugeRange(startValue: 32, endValue: 35, color: Colors.red.shade400),
      ];
    } else if (title.contains('pH')) {
      minValue = 6.0;
      maxValue = 9.0;
      ranges = [
        GaugeRange(startValue: 6.0, endValue: 6.5, color: Colors.red.shade400),
        GaugeRange(startValue: 6.5, endValue: 8.5, color: Colors.green),
        GaugeRange(startValue: 8.5, endValue: 9.0, color: Colors.red.shade400),
      ];
    } else if (title.contains('Oksigen')) {
      minValue = 0.0;
      maxValue = 12.0;
      ranges = [
        GaugeRange(startValue: 0, endValue: 5, color: Colors.red.shade400),
        GaugeRange(startValue: 5, endValue: 7, color: Colors.orange),
        GaugeRange(startValue: 7, endValue: 12, color: Colors.blue),
      ];
    }
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Gauge Speedometer untuk User Dashboard
            Container(
              height: 120,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: minValue,
                    maximum: maxValue,
                    showLabels: true,
                    showTicks: true,
                    axisLabelStyle: GaugeTextStyle(fontSize: 10),
                    majorTickStyle: MajorTickStyle(length: 6),
                    minorTickStyle: MinorTickStyle(length: 3),
                    ranges: ranges,
                    pointers: <GaugePointer>[
                      // Jarum penunjuk
                      NeedlePointer(
                        value: numericValue,
                        needleLength: 0.7,
                        needleStartWidth: 1,
                        needleEndWidth: 3,
                        needleColor: Colors.grey[800],
                        knobStyle: KnobStyle(
                          knobRadius: 0.05,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      // Nilai di tengah gauge
                      GaugeAnnotation(
                        widget: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$value',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            Text(
                              unit,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        angle: 90,
                        positionFactor: 0.75,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}