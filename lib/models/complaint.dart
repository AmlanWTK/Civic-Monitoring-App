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
