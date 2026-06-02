class Incident {
  final String id;
  final String type;
  final String title;
  final double lat;
  final double lon;
  final DateTime? time;
  final String source;
  final String? url;
  final String severity;
  final String status;
  final String? description;
  final Map<String, dynamic>? metadata;

  Incident({
    required this.id,
    required this.type,
    required this.title,
    required this.lat,
    required this.lon,
    this.time,
    required this.source,
    this.url,
    this.severity = 'Medium',
    this.status = 'Active',
    this.description,
    this.metadata,
  });
}
