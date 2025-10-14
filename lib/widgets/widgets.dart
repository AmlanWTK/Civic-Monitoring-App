import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;

  const MetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white, // White background
      elevation: 3,        // Soft shadow
      shadowColor: Colors.grey[300], // Light shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15), // lighter background for icon
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  Spacer(),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400], // softer arrow
                    ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              SizedBox(height: 4),
              Text(
  title,
  style: GoogleFonts.playfairDisplay(
    fontWeight: FontWeight.bold,
    color: Colors.black,
    //color: Colors.grey[700],
    fontSize: 16, // optional, adjust as needed
  ),
),
              if (subtitle != null) ...[
                SizedBox(height: 4),
                Text(
  subtitle!,
  style: GoogleFonts.roboto(   // or any Google Font you want
    textStyle: Theme.of(context).textTheme.bodySmall,
    color: Colors.grey[700],
    fontSize: 11,
  ),
),

              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Alert Widget for notifications and alerts
class AlertWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const AlertWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.color,
    this.onTap,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(title + time),
      direction: onDismiss != null 
          ? DismissDirection.endToStart 
          : DismissDirection.none,
      onDismissed: (direction) {
        if (onDismiss != null) onDismiss!();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600, color: Colors.black,),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              message,
              style: GoogleFonts.roboto(fontSize: 13,color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: onTap != null 
            ? Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)
            : null,
      ),
    );
  }
}

// Chart Widget for data visualization
class ChartWidget extends StatelessWidget {
  final String title;
  final List<ChartData> data;
  final Color primaryColor;
  final ChartType chartType;
  final String? yAxisLabel;
  final String? xAxisLabel;

  const ChartWidget({
    Key? key,
    required this.title,
    required this.data,
    required this.primaryColor,
    this.chartType = ChartType.line,
    this.yAxisLabel,
    this.xAxisLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 15
                
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: _buildChart(),
            ),
            if (xAxisLabel != null) ...[
              SizedBox(height: 8),
              Center(
                child: Text(
                  xAxisLabel!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    switch (chartType) {
      case ChartType.bar:
        return _buildBarChart();
      case ChartType.pie:
        return _buildPieChart();
      case ChartType.line:
      default:
        return _buildLineChart();
    }
  }

  Widget _buildLineChart() {
    if (data.isEmpty) return Center(child: Text('No data available'));

    double maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    double minValue = data.map((d) => d.value).reduce((a, b) => a < b ? a : b);
    double range = maxValue - minValue;
    
    return CustomPaint(
      size: Size.infinite,
      painter: LineChartPainter(
        data: data,
        primaryColor: primaryColor,
        maxValue: maxValue,
        minValue: minValue,
      ),
    );
  }

  Widget _buildBarChart() {
    if (data.isEmpty) return Center(child: Text('No data available'));

    double maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.asMap().entries.map((entry) {
        int index = entry.key;
        ChartData item = entry.value;
        double height = (item.value / maxValue) * 180;
        
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.8),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(fontSize: 10,color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPieChart() {
    if (data.isEmpty) return Center(child: Text('No data available'));

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: PieChartPainter(
                data: data,
                primaryColor: primaryColor,
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.asMap().entries.map((entry) {
              int index = entry.key;
              ChartData item = entry.value;
              Color color = _getColorForIndex(index);
              
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(fontSize: 12,color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                        
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
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
}






// Line Chart Painter
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

// Progress Bar Widget
class ProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final String? label;

  const ProgressBar({
    Key? key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.height = 8,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          SizedBox(height: 4),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey[800],
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color ?? Colors.blue,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Data classes
class ChartData {
  final String label;
  final double value;
  final Color? color;

  ChartData({
    required this.label,
    required this.value,
    this.color,
  });
}

enum ChartType { line, bar, pie }