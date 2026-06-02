import 'package:flutter/material.dart';
import '../models/incident_model.dart';
import 'incident_helpers.dart';

/// A card widget displaying a single incident in the list view.
class IncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback onTap;

  const IncidentCard({super.key, required this.incident, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final severityColor = IncidentHelpers.getSeverityColor(incident.severity);
    final typeIcon = IncidentHelpers.getIncidentIcon(incident.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(typeIcon, color: severityColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                incident.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('LIVE',
                                  style: TextStyle(fontSize: 8, color: Colors.green, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _SeverityBadge(severity: incident.severity, color: severityColor),
                            const SizedBox(width: 8),
                            _StatusBadge(status: incident.status),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (incident.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  incident.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${incident.lat.toStringAsFixed(3)}, ${incident.lon.toStringAsFixed(3)}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const Spacer(),
                  _SourceBadge(source: incident.source),
                  const SizedBox(width: 8),
                  Text(
                    IncidentHelpers.getTimeAgo(incident.time),
                    style: TextStyle(color: Colors.grey[400], fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final String severity;
  final Color color;
  const _SeverityBadge({required this.severity, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: Text(severity.toUpperCase(),
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = IncidentHelpers.getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
      child: Text(status.toUpperCase(),
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final String source;
  const _SourceBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    final color = IncidentHelpers.getSourceColor(source);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(source, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
