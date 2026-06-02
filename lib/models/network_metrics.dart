// Network Metrics Model
class NetworkMetrics {
  final String towerId;
  final String location;
  final double latitude;
  final double longitude;
  final int signalStrength;
  final double latency;
  final double packetLoss;
  final double throughput;
  final int connectedUsers;
  final double uptime;
  final String status;
  final DateTime timestamp;
  final Map<String, dynamic> additionalMetrics;

  NetworkMetrics({
    required this.towerId,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.signalStrength,
    required this.latency,
    required this.packetLoss,
    required this.throughput,
    required this.connectedUsers,
    required this.uptime,
    required this.status,
    required this.timestamp,
    this.additionalMetrics = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'towerId': towerId,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'signalStrength': signalStrength,
      'latency': latency,
      'packetLoss': packetLoss,
      'throughput': throughput,
      'connectedUsers': connectedUsers,
      'uptime': uptime,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'additionalMetrics': additionalMetrics,
    };
  }

  factory NetworkMetrics.fromJson(Map<String, dynamic> json) {
    return NetworkMetrics(
      towerId: json['towerId'],
      location: json['location'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      signalStrength: json['signalStrength'],
      latency: json['latency'],
      packetLoss: json['packetLoss'],
      throughput: json['throughput'],
      connectedUsers: json['connectedUsers'],
      uptime: json['uptime'],
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
      additionalMetrics: json['additionalMetrics'] ?? {},
    );
  }

  bool get isHealthy => status == 'healthy';
  bool get hasWarning => status == 'warning';
  bool get isCritical => status == 'critical';
}
