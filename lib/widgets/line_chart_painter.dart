
// Line Chart Painter
import 'package:civic_app_4/widgets/widgets.dart';
import 'package:flutter/material.dart';

class LineChartPainter extends CustomPainter {
  final List<ChartData> data;
  final Color primaryColor;
  final double maxValue;
  final double minValue;

  LineChartPainter({
    required this.data,
    required this.primaryColor,
    required this.maxValue,
    required this.minValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    Paint linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    Paint pointPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    Paint gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 0.5;

    // Draw grid
    for (int i = 0; i <= 5; i++) {
      double y = size.height - (i * size.height / 5);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Calculate points
    List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      double x = (i / (data.length - 1)) * size.width;
      double normalizedValue = (data[i].value - minValue) / (maxValue - minValue);
      double y = size.height - (normalizedValue * size.height);
      points.add(Offset(x, y));
    }

    // Draw line
    Path path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }
    canvas.drawPath(path, linePaint);

    // Draw points
    for (Offset point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Pie Chart Painter
class PieChartPainter extends CustomPainter {
  final List<ChartData> data;
  final Color primaryColor;

  PieChartPainter({
    required this.data,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    double total = data.fold(0, (sum, item) => sum + item.value);
    double startAngle = -3.14159 / 2; // Start from top
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2;

    for (int i = 0; i < data.length; i++) {
      double sweepAngle = (data[i].value / total) * 2 * 3.14159;
      
      Paint paint = Paint()
        ..color = _getColorForIndex(i)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  Color _getColorForIndex(int index) {
    List<Color> colors = [
      primaryColor,
      primaryColor.withOpacity(0.8),
      primaryColor.withOpacity(0.6),
      primaryColor.withOpacity(0.4),
      primaryColor.withOpacity(0.2),
    ];
    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Status Indicator Widget
class StatusIndicator extends StatelessWidget {
  final String status;
  final double size;

  const StatusIndicator({
    Key? key,
    required this.status,
    this.size = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = _getStatusColor(status);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'online':
      case 'active':
        return Colors.green;
      case 'warning':
      case 'degraded':
        return Colors.orange;
      case 'critical':
      case 'offline':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
