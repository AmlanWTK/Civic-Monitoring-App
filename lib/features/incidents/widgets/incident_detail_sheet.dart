import 'package:flutter/material.dart';
import '../models/incident_model.dart';
import 'incident_helpers.dart';

/// Bottom-sheet showing full details of a single incident.
class IncidentDetailSheet extends StatelessWidget {
  final Incident incident;
  const IncidentDetailSheet({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  IncidentHelpers.getIncidentIcon(incident.type),
                  size: 32,
                  color: IncidentHelpers.getSeverityColor(incident.severity),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Real-Time Incident Details',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text('LIVE',
                      style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                IconButton(
                    onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(label: 'Title', value: incident.title),
                    _DetailRow(label: 'Type', value: incident.type),
                    _DetailRow(label: 'Severity', value: incident.severity),
                    _DetailRow(label: 'Status', value: incident.status),
                    _DetailRow(label: 'Source', value: incident.source),
                    _DetailRow(
                        label: 'Location',
                        value:
                            '${incident.lat.toStringAsFixed(4)}, ${incident.lon.toStringAsFixed(4)}'),
                    _DetailRow(
                        label: 'Time', value: incident.time?.toString() ?? 'Unknown'),
                    if (incident.description != null) ...[
                      const SizedBox(height: 16),
                      const Text('Description:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(incident.description!),
                    ],
                    if (incident.metadata != null && incident.metadata!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('Additional Data:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...incident.metadata!.entries
                          .map((e) => _DetailRow(label: e.key, value: e.value.toString())),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        '📡 This is real-time data from ${incident.source} API. '
                        'Information is updated automatically from official disaster monitoring sources.',
                        style: const TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 100,
                child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
            Expanded(child: Text(value)),
          ],
        ),
      );
}
