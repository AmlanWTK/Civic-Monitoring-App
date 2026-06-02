// QoS Metrics Model
class QoSMetrics {
  final String towerId;
  final DateTime timestamp;
  final double bandwidth;
  final double latency;
  final double jitter;
  final double packetLoss;
  final double throughput;
  final double errorRate;
  final int activeConnections;
  final Map<String, double> serviceClassMetrics;

  QoSMetrics({
    required this.towerId,
    required this.timestamp,
    required this.bandwidth,
    required this.latency,
    required this.jitter,
    required this.packetLoss,
    required this.throughput,
    required this.errorRate,
    required this.activeConnections,
    required this.serviceClassMetrics,
  });

  Map<String, dynamic> toJson() {
    return {
      'towerId': towerId,
      'timestamp': timestamp.toIso8601String(),
      'bandwidth': bandwidth,
      'latency': latency,
      'jitter': jitter,
      'packetLoss': packetLoss,
      'throughput': throughput,
      'errorRate': errorRate,
      'activeConnections': activeConnections,
      'serviceClassMetrics': serviceClassMetrics,
    };
  }

  factory QoSMetrics.fromJson(Map<String, dynamic> json) {
    return QoSMetrics(
      towerId: json['towerId'],
      timestamp: DateTime.parse(json['timestamp']),
      bandwidth: json['bandwidth'],
      latency: json['latency'],
      jitter: json['jitter'],
      packetLoss: json['packetLoss'],
      throughput: json['throughput'],
      errorRate: json['errorRate'],
      activeConnections: json['activeConnections'],
      serviceClassMetrics: Map<String, double>.from(json['serviceClassMetrics']),
    );
  }

  double get qualityScore {
    // Calculate overall quality score (0-100)
    double latencyScore = (200 - latency).clamp(0, 100);
    double lossScore = (100 - (packetLoss * 100)).clamp(0, 100);
    double jitterScore = (100 - jitter).clamp(0, 100);
    double errorScore = (100 - (errorRate * 100)).clamp(0, 100);
    
    return (latencyScore + lossScore + jitterScore + errorScore) / 4;
  }

  String get qualityGrade {
    double score = qualityScore;
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }
}
