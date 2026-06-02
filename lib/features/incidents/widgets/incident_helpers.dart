import 'package:flutter/material.dart';

class IncidentHelpers {
  static IconData getIncidentIcon(String type) {
    switch (type) {
      case 'Earthquake': return Icons.public;
      case 'Tornado': return Icons.air;
      case 'Cyclone': return Icons.waves;
      case 'Storm': return Icons.thunderstorm;
      case 'Flood': return Icons.waves;
      case 'Wildfire': return Icons.local_fire_department;
      case 'Volcano': return Icons.landscape;
      case 'Landslide': return Icons.terrain;
      case 'Drought': return Icons.water_drop_outlined;
      default: return Icons.warning;
    }
  }

  static Color getSeverityColor(String severity) {
    switch (severity) {
      case 'Critical': return Colors.red;
      case 'High': return Colors.orange;
      case 'Medium': return Colors.yellow;
      case 'Low': return Colors.green;
      default: return Colors.grey;
    }
  }

  static IconData getSeverityIcon(String severity) {
    switch (severity) {
      case 'Critical': return Icons.error;
      case 'High': return Icons.warning;
      case 'Medium': return Icons.info;
      case 'Low': return Icons.check_circle;
      default: return Icons.help;
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'Active': return Colors.red;
      case 'Monitoring': return Colors.orange;
      case 'Resolved': return Colors.green;
      default: return Colors.grey;
    }
  }

  static Color getSourceColor(String source) {
    switch (source) {
      case 'USGS': return Colors.brown;
      case 'EONET': return Colors.blue;
      case 'GDACS': return Colors.orange;
      case 'ReliefWeb': return Colors.green;
      default: return Colors.grey;
    }
  }

  static Color getTypeColor(String type) {
    switch (type) {
      case 'Earthquake': return Colors.brown;
      case 'Cyclone': return Colors.blue;
      case 'Flood': return Colors.cyan;
      case 'Storm': return Colors.purple;
      case 'Wildfire': return Colors.orange;
      case 'Landslide': return Colors.green;
      case 'Drought': return Colors.amber;
      default: return Colors.grey;
    }
  }

  static String getTimeAgo(DateTime? timestamp) {
    if (timestamp == null) return 'Unknown';
    final difference = DateTime.now().difference(timestamp);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}
