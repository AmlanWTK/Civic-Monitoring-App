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
