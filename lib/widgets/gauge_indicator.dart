import 'package:flutter/material.dart';
import 'dart:math' as math;

class GaugeIndicator extends StatelessWidget {
  final String title;
  final double value;
  final double minValue;
  final double maxValue;
  final String unit;

  const GaugeIndicator({
    Key? key,
    required this.title,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.unit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),
            
            // Custom gauge placeholder
            Container(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 8,
                      ),
                    ),
                  ),
                  
                  // Progress arc
                  CustomPaint(
                    size: Size(120, 120),
                    painter: GaugePainter(
                      value: value,
                      minValue: minValue,
                      maxValue: maxValue,
                    ),
                  ),
                  
                  // Center value display
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        value.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getValueColor(),
                        ),
                      ),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Min/Max labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${minValue.toStringAsFixed(0)}$unit',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${maxValue.toStringAsFixed(0)}$unit',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getValueColor() {
    double percentage = (value - minValue) / (maxValue - minValue);
    
    if (percentage < 0.3) return Colors.red;
    if (percentage < 0.7) return Colors.orange;
    return Colors.green;
  }
}

class GaugePainter extends CustomPainter {
  final double value;
  final double minValue;
  final double maxValue;

  GaugePainter({
    required this.value,
    required this.minValue,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2; // Account for stroke width
    
    // Calculate the progress (0 to 1)
    double progress = (value - minValue) / (maxValue - minValue);
    progress = progress.clamp(0.0, 1.0);
    
    // Define the arc (3/4 circle starting from -135 degrees)
    final startAngle = -math.pi * 3 / 4; // -135 degrees
    final sweepAngle = math.pi * 3 / 2 * progress; // Up to 270 degrees
    
    // Create paint for the progress arc
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: _getGradientColors(progress),
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    // Draw the progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  List<Color> _getGradientColors(double progress) {
    if (progress < 0.3) {
      return [Colors.red[300]!, Colors.red[600]!];
    } else if (progress < 0.7) {
      return [Colors.orange[300]!, Colors.orange[600]!];
    } else {
      return [Colors.green[300]!, Colors.green[600]!];
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}