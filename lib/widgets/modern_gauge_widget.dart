import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ModernGaugeWidget extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final double minValue;
  final double maxValue;
  final String status;
  final Color statusColor;
  final IconData icon;
  final List<GaugeRange> ranges;

  const ModernGaugeWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    required this.minValue,
    required this.maxValue,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.ranges,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: statusColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 20),
          
          // Gauge
          Container(
            height: 160,
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: minValue,
                  maximum: maxValue,
                  startAngle: 180,
                  endAngle: 0,
                  showLabels: true,
                  showTicks: true,
                  radiusFactor: 0.8,
                  majorTickStyle: MajorTickStyle(
                    length: 8,
                    thickness: 2,
                    color: Colors.grey[400],
                  ),
                  minorTickStyle: MinorTickStyle(
                    length: 4,
                    thickness: 1,
                    color: Colors.grey[300],
                  ),
                  axisLabelStyle: GaugeTextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  axisLineStyle: AxisLineStyle(
                    thickness: 12,
                    color: Colors.grey[200],
                  ),
                  ranges: ranges,
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      value: value,
                      needleColor: Colors.grey[800]!,
                      needleStartWidth: 1,
                      needleEndWidth: 4,
                      needleLength: 0.7,
                      knobStyle: KnobStyle(
                        knobRadius: 8,
                        color: Colors.grey[800]!,
                        borderColor: Colors.white,
                        borderWidth: 2,
                      ),
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            value.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            unit,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      angle: 90,
                      positionFactor: 0.8,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: 12),
          
          // Status
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function untuk membuat gauge range dengan warna yang sesuai
class GaugeHelper {
  static List<GaugeRange> getTemperatureRanges() {
    return [
      GaugeRange(
        startValue: 15,
        endValue: 25, 
        color: Colors.blue,
        sizeUnit: GaugeSizeUnit.logicalPixel,
        startWidth: 12,
        endWidth: 12,
      ),
      GaugeRange(
        startValue: 25,
        endValue: 30,
        color: Colors.green,
        sizeUnit: GaugeSizeUnit.logicalPixel,
        startWidth: 12,
        endWidth: 12,
      ),
      GaugeRange(
        startValue: 30,
        endValue: 35,
        color: Colors.red,
        sizeUnit: GaugeSizeUnit.logicalPixel,
        startWidth: 12,
        endWidth: 12,
      ),
    ];
  }
  
  static List<GaugeRange> getOxygenRanges() {
    return [
      GaugeRange(
        startValue: 0,
        endValue: 5,
        color: Colors.red,
        sizeUnit: GaugeSizeUnit.logicalPixel,
        startWidth: 12,
        endWidth: 12,
      ),
      GaugeRange(
        startValue: 5,
        endValue: 8,
        color: Colors.orange,
        sizeUnit: GaugeSizeUnit.logicalPixel,
        startWidth: 12,
        endWidth: 12,
      ),
      GaugeRange(
        startValue: 8,
        endValue: 12,
        color: Colors.blue,
        sizeUnit: GaugeSizeUnit.logicalPixel,
        startWidth: 12,
        endWidth: 12,
      ),
    ];
  }
  
  static List<GaugeRange> getPhRanges() {
    return [
      GaugeRange(
        startValue: 5,
        endValue: 6.5,
        color: Colors.red,
        sizeUnit: GaugeSizeUnit.logicalPixel,
        startWidth: 12,
        endWidth: 12,
      ),
      GaugeRange(
        startValue: 6.5,
        endValue: 8,
        color: Colors.green,
        sizeUnit: GaugeSizeUnit.logicalPixel,
        startWidth: 12,
        endWidth: 12,
      ),
      GaugeRange(
        startValue: 8,
        endValue: 9,
        color: Colors.red,
        sizeUnit: GaugeSizeUnit.logicalPixel,
        startWidth: 12,
        endWidth: 12,
      ),
    ];
  }
  
  // Helper untuk mendapatkan status dan warna berdasarkan nilai
  static Map<String, dynamic> getTemperatureStatus(double temp) {
    if (temp < 20 || temp > 32) {
      return {'status': 'Bahaya', 'color': Colors.red};
    } else if (temp < 24 || temp > 30) {
      return {'status': 'Sedang', 'color': Colors.orange};
    } else {
      return {'status': 'Normal', 'color': Colors.green};
    }
  }
  
  static Map<String, dynamic> getOxygenStatus(double oxygen) {
    if (oxygen < 4 || oxygen > 10) {
      return {'status': 'Bahaya', 'color': Colors.red};
    } else if (oxygen < 6 || oxygen > 9) {
      return {'status': 'Sedang', 'color': Colors.orange};
    } else {
      return {'status': 'Normal', 'color': Colors.green};
    }
  }
  
  static Map<String, dynamic> getPhStatus(double ph) {
    if (ph < 6 || ph > 8.5) {
      return {'status': 'Bahaya', 'color': Colors.red};
    } else if (ph < 6.5 || ph > 8) {
      return {'status': 'Sedang', 'color': Colors.orange};
    } else {
      return {'status': 'Normal', 'color': Colors.green};
    }
  }
}