
// Chart Widget for data visualization
import 'dart:ui';

import 'package:civic_app_4/widgets/line_chart_painter.dart';
import 'package:civic_app_4/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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




