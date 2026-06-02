import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:civic_app_4/theme.dart';
import '../models/incident_model.dart';
import 'incident_helpers.dart';

/// Full analytics tab content for the incidents screen.
class IncidentAnalyticsView extends StatelessWidget {
  final List<Incident> incidents;
  final String riskLevel;
  final Color riskColor;

  const IncidentAnalyticsView({
    super.key,
    required this.incidents,
    required this.riskLevel,
    required this.riskColor,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AnalyticsHeader(riskLevel: riskLevel, riskColor: riskColor),
          const SizedBox(height: 20),
          _LiveDataSourcesCard(incidents: incidents),
          const SizedBox(height: 20),
          _SeverityAnalysis(incidents: incidents),
          const SizedBox(height: 20),
          _TypeAnalysis(incidents: incidents),
          const SizedBox(height: 20),
          _TimelineAnalysis(incidents: incidents),
          const SizedBox(height: 20),
          _RecommendationsCard(riskLevel: riskLevel),
        ],
      ),
    );
  }
}

// ── Analytics Header ─────────────────────────────────────────────────────────

class _AnalyticsHeader extends StatelessWidget {
  final String riskLevel;
  final Color riskColor;
  const _AnalyticsHeader({required this.riskLevel, required this.riskColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.analytics, size: 32, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Real-Time Incident Analytics',
                      style: GoogleFonts.inter(
                          color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20)),
                  const Text('Live disaster monitoring from USGS, NASA, GDACS & ReliefWeb',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration:
                  BoxDecoration(color: riskColor.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
              child: Text('Risk: $riskLevel',
                  style: TextStyle(color: riskColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Live Data Sources ─────────────────────────────────────────────────────────

class _LiveDataSourcesCard extends StatelessWidget {
  final List<Incident> incidents;
  const _LiveDataSourcesCard({required this.incidents});

  @override
  Widget build(BuildContext context) {
    final Map<String, int> sourceStats = {};
    for (final i in incidents) sourceStats[i.source] = (sourceStats[i.source] ?? 0) + 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.data_usage, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Live Data Sources',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.circle, color: Colors.green, size: 8),
                      SizedBox(width: 4),
                      Text('LIVE',
                          style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2,
              children: [
                _SourceCard(source: 'USGS', count: sourceStats['USGS'] ?? 0, description: 'Earthquakes', color: Colors.brown),
                _SourceCard(source: 'EONET', count: sourceStats['EONET'] ?? 0, description: 'NASA Events', color: Colors.blue),
                _SourceCard(source: 'GDACS', count: sourceStats['GDACS'] ?? 0, description: 'Global Alerts', color: Colors.orange),
                _SourceCard(source: 'ReliefWeb', count: sourceStats['ReliefWeb'] ?? 0, description: 'Humanitarian', color: Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  final String source, description;
  final int count;
  final Color color;
  const _SourceCard({required this.source, required this.count, required this.description, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$count', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(source, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            Text(description, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8))),
          ],
        ),
      );
}

// ── Severity Analysis ─────────────────────────────────────────────────────────

class _SeverityAnalysis extends StatelessWidget {
  final List<Incident> incidents;
  const _SeverityAnalysis({required this.incidents});

  @override
  Widget build(BuildContext context) {
    final Map<String, int> stats = {};
    for (final i in incidents) stats[i.severity] = (stats[i.severity] ?? 0) + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Live Severity Distribution',
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: stats.entries
              .map((e) => _AnalyticsCard(
                    title: e.key,
                    value: '${e.value}',
                    color: IncidentHelpers.getSeverityColor(e.key),
                    icon: IncidentHelpers.getSeverityIcon(e.key),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title, value;
  final Color color;
  final IconData icon;
  const _AnalyticsCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const Spacer(),
                  Text(value,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
}

// ── Type Analysis ─────────────────────────────────────────────────────────────

class _TypeAnalysis extends StatelessWidget {
  final List<Incident> incidents;
  const _TypeAnalysis({required this.incidents});

  @override
  Widget build(BuildContext context) {
    final Map<String, int> stats = {};
    for (final i in incidents) stats[i.type] = (stats[i.type] ?? 0) + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Real Incident Types',
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 12),
        ...stats.entries.map((e) {
          final pct = incidents.isNotEmpty ? (e.value / incidents.length) * 100 : 0.0;
          final color = IncidentHelpers.getTypeColor(e.key);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(IncidentHelpers.getIncidentIcon(e.key), color: color),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                            value: pct / 100, color: color, backgroundColor: color.withOpacity(0.2)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('${e.value} (${pct.toInt()}%)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── Timeline Analysis ─────────────────────────────────────────────────────────

class _TimelineAnalysis extends StatelessWidget {
  final List<Incident> incidents;
  const _TimelineAnalysis({required this.incidents});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Live Timeline',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...incidents.take(5).map((i) => _TimelineItem(incident: i)),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final Incident incident;
  const _TimelineItem({required this.incident});

  @override
  Widget build(BuildContext context) {
    final color = IncidentHelpers.getSeverityColor(incident.severity);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(IncidentHelpers.getIncidentIcon(incident.type), color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(incident.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(IncidentHelpers.getTimeAgo(incident.time),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                          color: IncidentHelpers.getSourceColor(incident.source).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(incident.source,
                          style: TextStyle(
                              fontSize: 8,
                              color: IncidentHelpers.getSourceColor(incident.source),
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration:
                BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Text(incident.severity,
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ── Recommendations ───────────────────────────────────────────────────────────

class _RecommendationsCard extends StatelessWidget {
  final String riskLevel;
  const _RecommendationsCard({required this.riskLevel});

  List<Map<String, dynamic>> _getRecommendations() {
    switch (riskLevel) {
      case 'HIGH':
        return [
          {'icon': Icons.warning, 'title': 'Live Emergency Alert', 'description': 'Multiple critical incidents detected. Follow emergency protocols.', 'color': Colors.red},
          {'icon': Icons.phone, 'title': 'Contact Authorities', 'description': 'Real-time data shows high risk. Contact local emergency services immediately.', 'color': Colors.red},
        ];
      case 'MEDIUM':
        return [
          {'icon': Icons.visibility, 'title': 'Monitor Live Data', 'description': 'Real-time monitoring shows elevated risk. Stay alert and prepared.', 'color': Colors.orange},
          {'icon': Icons.inventory, 'title': 'Emergency Preparedness', 'description': 'Live data indicates potential risks. Ensure emergency supplies are ready.', 'color': Colors.orange},
        ];
      default:
        return [
          {'icon': Icons.check_circle, 'title': 'Normal Conditions', 'description': 'Real-time monitoring shows normal incident levels from all sources.', 'color': Colors.green},
          {'icon': Icons.update, 'title': 'Continue Monitoring', 'description': 'Live feeds from USGS, NASA, GDACS and ReliefWeb show stable conditions.', 'color': Colors.blue},
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Real-Time Emergency Recommendations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._getRecommendations().map((rec) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (rec['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: (rec['color'] as Color).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(rec['icon'] as IconData, color: rec['color'] as Color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rec['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(rec['description'] as String,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
