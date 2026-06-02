import 'package:flutter/material.dart';
import '../models/incident_model.dart';
import 'incident_helpers.dart';

/// Map marker widget for a single incident point.
class IncidentMapMarker extends StatelessWidget {
  final Incident incident;
  final VoidCallback onTap;

  const IncidentMapMarker({super.key, required this.incident, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final markerColor = IncidentHelpers.getSeverityColor(incident.severity);
    final markerIcon = IncidentHelpers.getIncidentIcon(incident.type);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: markerColor,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: markerColor.withOpacity(0.5), blurRadius: 8, spreadRadius: 2)],
        ),
        child: Center(child: Icon(markerIcon, color: Colors.white, size: 24)),
      ),
    );
  }
}

/// Map overlay: severity colour legend.
class SeverityLegendCard extends StatelessWidget {
  const SeverityLegendCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Severity Legend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            _LegendItem(label: 'Critical', color: Colors.red),
            _LegendItem(label: 'High', color: Colors.orange),
            _LegendItem(label: 'Medium', color: Colors.yellow),
            _LegendItem(label: 'Low', color: Colors.green),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      );
}

/// Map overlay: live statistics by severity.
class LiveStatsCard extends StatelessWidget {
  final List<Incident> incidents;
  const LiveStatsCard({super.key, required this.incidents});

  @override
  Widget build(BuildContext context) {
    final Map<String, int> severityStats = {};
    for (final i in incidents) {
      severityStats[i.severity] = (severityStats[i.severity] ?? 0) + 1;
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Live Statistics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            Text('Total: ${incidents.length}', style: const TextStyle(fontSize: 10)),
            ...severityStats.entries
                .map((e) => Text('${e.key}: ${e.value}', style: const TextStyle(fontSize: 10))),
          ],
        ),
      ),
    );
  }
}

/// Map overlay: breakdown of incidents per API source.
class LiveSourcesCard extends StatelessWidget {
  final List<Incident> incidents;
  const LiveSourcesCard({super.key, required this.incidents});

  @override
  Widget build(BuildContext context) {
    final Map<String, int> sourceStats = {};
    for (final i in incidents) {
      sourceStats[i.source] = (sourceStats[i.source] ?? 0) + 1;
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.circle, color: Colors.green, size: 8),
                SizedBox(width: 4),
                Text('LIVE SOURCES',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 4),
            ...sourceStats.entries
                .take(4)
                .map((e) => Text('${e.key}: ${e.value}', style: const TextStyle(fontSize: 9))),
            Text(
              'Updated: ${DateTime.now().toString().substring(11, 16)}',
              style: const TextStyle(fontSize: 8, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
