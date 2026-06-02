// Infrastructure Component Model
class InfrastructureComponent {
  final String id;
  final String type; // 'TOWER', 'BRIDGE', 'POWER_GRID', 'SERVER'
  final String name;
  final String location;
  final double latitude;
  final double longitude;
  final String status;
  final Map<String, dynamic> healthMetrics;
  final DateTime lastMaintenance;
  final DateTime nextScheduledMaintenance;
  final List<String> dependencies;
  final Map<String, dynamic> configuration;

  InfrastructureComponent({
    required this.id,
    required this.type,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.healthMetrics,
    required this.lastMaintenance,
    required this.nextScheduledMaintenance,
    required this.dependencies,
    required this.configuration,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'healthMetrics': healthMetrics,
      'lastMaintenance': lastMaintenance.toIso8601String(),
      'nextScheduledMaintenance': nextScheduledMaintenance.toIso8601String(),
      'dependencies': dependencies,
      'configuration': configuration,
    };
  }

  factory InfrastructureComponent.fromJson(Map<String, dynamic> json) {
    return InfrastructureComponent(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      location: json['location'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      status: json['status'],
      healthMetrics: json['healthMetrics'],
      lastMaintenance: DateTime.parse(json['lastMaintenance']),
      nextScheduledMaintenance: DateTime.parse(json['nextScheduledMaintenance']),
      dependencies: List<String>.from(json['dependencies']),
      configuration: json['configuration'],
    );
  }

  bool get needsMaintenance {
    return DateTime.now().isAfter(nextScheduledMaintenance) ||
           status == 'DEGRADED' ||
           status == 'CRITICAL';
  }
}
