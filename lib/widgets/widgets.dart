import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



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