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
  // optional compact mode to fit in tighter layouts
  final bool compact;
  // optional explicit height
  final double? height;
  // render as speedometer-style semicircular gauge (thicker axis, ticks, animated needle)
  final bool speedometer;

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
    this.compact = false,
    this.height,
    this.speedometer = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // If the widget is given extremely small space (e.g. 56x56 in admin mini-cards),
      // render a very compact view that avoids the full Column/gauge layout to prevent overflow.
      final isTiny = constraints.maxHeight < 80 || constraints.maxWidth < 80;
      final pad = isTiny ? 6.0 : (compact ? 8.0 : 20.0);
      final gaugeHeight = isTiny ? constraints.maxHeight - (pad * 2) - 8 : (height ?? (compact ? 78.0 : 160.0));

      if (isTiny) {
        // Extremely compact representation: show only value and small status dot.
        return Container(
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 1))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(value.toStringAsFixed(value % 1 == 0 ? 0 : 1), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800])),
              if (unit.isNotEmpty) Text(unit, style: TextStyle(fontSize: 9, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
            ],
          ),
        );
      }

      // Regular/compact rendering when there's enough space.
      final annotationTextColor = speedometer ? Colors.white : Colors.grey[800];
      final annotationUnitColor = speedometer ? Colors.white70 : Colors.grey[600];
      final effectiveKnobRadius = speedometer ? 0.0 : 8.0;

      return Container(
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title (hide title when compact to save space)
            if (!compact)
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(compact ? 6 : 8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: statusColor,
                      size: compact ? 16 : 20,
                    ),
                  ),
                  SizedBox(width: compact ? 8 : 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: compact ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),

            SizedBox(height: compact ? 8 : 20),

            // Gauge (animated using TweenAnimationBuilder so the needle moves smoothly)
            SizedBox(
              height: gaugeHeight.clamp(40.0, 400.0),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: minValue, end: value),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, animValue, child) {
                  return SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        minimum: minValue,
                        maximum: maxValue,
                        startAngle: 180,
                        endAngle: 0,
                        showLabels: true,
                        showTicks: true,
                        radiusFactor: compact ? 0.6 : 0.8,
                        majorTickStyle: MajorTickStyle(
                          length: speedometer ? (compact ? 8 : 12) : 8,
                          thickness: 2,
                          color: Colors.grey[400],
                        ),
                        minorTickStyle: MinorTickStyle(
                          length: speedometer ? 6 : 4,
                          thickness: 1,
                          color: Colors.grey[300],
                        ),
                        axisLabelStyle: GaugeTextStyle(
                          color: Colors.grey[600],
                          fontSize: compact ? 8 : 10,
                          fontWeight: FontWeight.w500,
                        ),
                        axisLineStyle: AxisLineStyle(
                          thickness: speedometer ? 16 : 12,
                          color: Colors.grey[200],
                        ),
                        ranges: ranges,
                        pointers: <GaugePointer>[
                          NeedlePointer(
                            value: animValue,
                            needleColor: Colors.grey[850]!,
                            needleStartWidth: 2,
                            needleEndWidth: speedometer ? 5 : 4,
                            needleLength: speedometer ? 0.78 : 0.7,
                            knobStyle: KnobStyle(
                              knobRadius: effectiveKnobRadius,
                              color: speedometer ? Colors.transparent : Colors.grey[850]!,
                              borderColor: speedometer ? Colors.transparent : Colors.white,
                              borderWidth: speedometer ? 0 : 2,
                            ),
                          ),
                        ],
                        // For speedometer mode we avoid center annotations to prevent overlap with the gauge face.
                        annotations: speedometer
                            ? <GaugeAnnotation>[]
                            : <GaugeAnnotation>[
                                GaugeAnnotation(
                                  widget: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        value.toStringAsFixed(value % 1 == 0 ? 0 : 1),
                                        style: TextStyle(
                                          fontSize: compact ? 18 : 28,
                                          fontWeight: FontWeight.bold,
                                          color: annotationTextColor,
                                        ),
                                      ),
                                      if (unit.isNotEmpty)
                                        Text(
                                          unit,
                                          style: TextStyle(
                                            fontSize: compact ? 8 : 12,
                                            color: annotationUnitColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                  angle: 90,
                                  positionFactor: compact ? 0.6 : 0.8,
                                ),
                              ],
                      ),
                    ],
                  );
                },
              ),
            ),

            SizedBox(height: compact ? 6 : 12),

            // Status
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 4 : 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: compact ? 12 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
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

// Very small/compact radial gauge optimized for mini tiles (arc + needle + center value)
class VeryMiniGauge extends StatelessWidget {
  final double value;
  final double minValue;
  final double maxValue;
  final List<GaugeRange> ranges;
  final double size;
  final String unit;
  final Color? needleColor;
  final bool speedometer;

  const VeryMiniGauge({Key? key, required this.value, required this.minValue, required this.maxValue, required this.ranges, this.size = 64, this.unit = '', this.needleColor, this.speedometer = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool small = size <= 64;
    // Decorative container to create a neat mini-tile with subtle border and glow
    final baseColor = needleColor ?? Colors.grey[800]!;
    final brightness = ThemeData.estimateBrightnessForColor(baseColor);
    final textColor = brightness == Brightness.dark ? Colors.white : Colors.grey[900];

    return SizedBox(
      width: size,
      height: size,
      child: Container(
        padding: EdgeInsets.all(size * 0.06),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: baseColor.withOpacity(0.10), width: 2),
          boxShadow: [BoxShadow(color: baseColor.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white, Colors.white.withOpacity(0.98)]),
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: minValue, end: value),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, animValue, child) {
            final annotationColor = speedometer ? Colors.white : textColor;
            final knobRadius = speedometer ? 0.0 : (small ? 4.0 : 6.0);

            return SfRadialGauge(
              axes: [
                RadialAxis(
                  minimum: minValue,
                  maximum: maxValue,
                  showTicks: speedometer,
                  showLabels: speedometer,
                  startAngle: 180,
                  endAngle: 0,
                  radiusFactor: 0.95,
                  axisLineStyle: AxisLineStyle(thickness: small ? (speedometer ? 10 : 6) : (speedometer ? 12 : 8), color: Colors.grey[200]),
                  ranges: ranges,
                  pointers: [
                    NeedlePointer(
                      value: animValue,
                      needleColor: baseColor,
                      needleStartWidth: 1,
                      needleEndWidth: small ? 3 : 4,
                      needleLength: speedometer ? 0.68 : 0.62,
                      knobStyle: KnobStyle(knobRadius: knobRadius, color: speedometer ? Colors.transparent : baseColor),
                    ),
                  ],
                  annotations: [
                    GaugeAnnotation(
                      positionFactor: 0.55,
                      angle: 90,
                      widget: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(value.toStringAsFixed(value % 1 == 0 ? 0 : 1), style: TextStyle(fontSize: small ? 12 : 16, fontWeight: FontWeight.bold, color: annotationColor)),
                        if (unit.isNotEmpty) Text(unit, style: TextStyle(fontSize: small ? 8 : 10, color: speedometer ? Colors.white70 : Colors.grey[600])),
                      ]),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Very small thermometer-style widget for temperature (vertical fill)
class VeryMiniThermometer extends StatelessWidget {
  final double value;
  final double minValue;
  final double maxValue;
  final double size;
  final Color color;

  const VeryMiniThermometer({Key? key, required this.value, required this.minValue, required this.maxValue, this.size = 64, this.color = Colors.red}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final clamped = ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
    final bulbSize = size * 0.28;
    final tubeWidth = size * 0.22;
    final tubeHeight = size - bulbSize - 8;

    return SizedBox(
      width: size,
      height: size,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // tube with fill (top is 0)
        Container(
          width: tubeWidth,
          height: tubeHeight,
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(tubeWidth / 2)),
          child: Stack(children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              top: tubeHeight * (1 - clamped),
              child: Container(decoration: BoxDecoration(color: color.withOpacity(0.95), borderRadius: BorderRadius.vertical(bottom: Radius.circular(tubeWidth / 2)))),
            ),
          ]),
        ),
        const SizedBox(height: 4),
        // bulb
        Container(width: bulbSize, height: bulbSize, decoration: BoxDecoration(color: color.withOpacity(0.95), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
      ]),
    );
  }
}