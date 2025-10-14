// Complaint Model
class Complaint {
  final String id;
  final String phoneNumber;
  final String message;
  final String originalText;
  final String translatedText;
  final String category;
  final String priority;
  final String sentiment;
  final double confidence;
  final DateTime timestamp;
  String status;
  final String location;

  Complaint({
    required this.id,
    required this.phoneNumber,
    required this.message,
    required this.originalText,
    required this.translatedText,
    required this.category,
    required this.priority,
    required this.sentiment,
    required this.confidence,
    required this.timestamp,
    required this.status,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'message': message,
      'originalText': originalText,
      'translatedText': translatedText,
      'category': category,
      'priority': priority,
      'sentiment': sentiment,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'location': location,
    };
  }

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      phoneNumber: json['phoneNumber'],
      message: json['message'],
      originalText: json['originalText'],
      translatedText: json['translatedText'],
      category: json['category'],
      priority: json['priority'],
      sentiment: json['sentiment'],
      confidence: json['confidence'],
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'],
      location: json['location'],
    );
  }
}

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

// Predictive Model
class PredictiveAlert {
  final String id;
  final String towerId;
  final String alertType;
  final String severity;
  final String title;
  final String description;
  final double confidence;
  final DateTime predictedTime;
  final DateTime createdAt;
  final Map<String, dynamic> features;
  final String recommendedAction;
  String status;

  PredictiveAlert({
    required this.id,
    required this.towerId,
    required this.alertType,
    required this.severity,
    required this.title,
    required this.description,
    required this.confidence,
    required this.predictedTime,
    required this.createdAt,
    required this.features,
    required this.recommendedAction,
    this.status = 'ACTIVE',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'towerId': towerId,
      'alertType': alertType,
      'severity': severity,
      'title': title,
      'description': description,
      'confidence': confidence,
      'predictedTime': predictedTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'features': features,
      'recommendedAction': recommendedAction,
      'status': status,
    };
  }

  factory PredictiveAlert.fromJson(Map<String, dynamic> json) {
    return PredictiveAlert(
      id: json['id'],
      towerId: json['towerId'],
      alertType: json['alertType'],
      severity: json['severity'],
      title: json['title'],
      description: json['description'],
      confidence: json['confidence'],
      predictedTime: DateTime.parse(json['predictedTime']),
      createdAt: DateTime.parse(json['createdAt']),
      features: json['features'],
      recommendedAction: json['recommendedAction'],
      status: json['status'] ?? 'ACTIVE',
    );
  }

  bool get isCritical => severity == 'CRITICAL';
  bool get isHigh => severity == 'HIGH';
  bool get isMedium => severity == 'MEDIUM';
  bool get isLow => severity == 'LOW';
}

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