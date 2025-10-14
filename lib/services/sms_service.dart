import 'dart:convert';
import 'package:civic_app_4/models/models.dart';
import 'package:http/http.dart' as http;


class SMSService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _apiKey = 'YOUR_OPENAI_API_KEY'; // Replace with actual key
  
  // Free alternative APIs for SMS processing
  static const String _huggingFaceUrl = 'https://api-inference.huggingface.co/models';
  static const String _translationApi = 'https://api.mymemory.translated.net/get';

  // Process incoming SMS complaints
  Future<Complaint> processSMSComplaint({
    required String phoneNumber,
    required String message,
    required String location,
  }) async {
    try {
      // Step 1: Detect language and translate if needed
      final translationResult = await _translateText(message);
      
      // Step 2: Classify complaint category using free API
      final category = await _classifyComplaint(translationResult['translatedText']!);
      
      // Step 3: Analyze sentiment
      final sentiment = await _analyzeSentiment(translationResult['translatedText']!);
      
      // Step 4: Determine priority based on keywords and sentiment
      final priority = _determinePriority(translationResult['translatedText']!, sentiment['label']);

      return Complaint(
        id: 'SMS${DateTime.now().millisecondsSinceEpoch}',
        phoneNumber: phoneNumber,
        message: message,
        originalText: message,
        translatedText: translationResult['translatedText'] ?? 'N/A',
        category: category['label'],
        priority: priority,
        sentiment: sentiment['label'],
        confidence: (category['confidence'] + sentiment['confidence']) / 2,
        timestamp: DateTime.now(),
        status: 'PENDING',
        location: location,
      );
    } catch (e) {
      print('Error processing SMS complaint: $e');
      // Return a basic complaint if processing fails
      return Complaint(
        id: 'SMS${DateTime.now().millisecondsSinceEpoch}',
        phoneNumber: phoneNumber,
        message: message,
        originalText: message,
        translatedText: message,
        category: 'OTHER',
        priority: 'MEDIUM',
        sentiment: 'NEUTRAL',
        confidence: 0.5,
        timestamp: DateTime.now(),
        status: 'PENDING',
        location: location,
      );
    }
  }

  // Free translation using MyMemory API
  Future<Map<String, String>> _translateText(String text) async {
    try {
      // Detect if text is in Bengali/other languages and translate to English
      final response = await http.get(
        Uri.parse('$_translationApi?q=${Uri.encodeComponent(text)}&langpair=bn|en'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translatedText = data['responseData']['translatedText'];
        
        return {
          'originalText': text,
          'translatedText': translatedText,
        };
      }
    } catch (e) {
      print('Translation error: $e');
    }

    // Return original text if translation fails
    return {
      'originalText': text,
      'translatedText': text,
    };
  }

  // Classify complaint using simple keyword matching (free alternative to ML APIs)
  Future<Map<String, dynamic>> _classifyComplaint(String text) async {
    try {
      // For demo purposes, using keyword-based classification
      // In production, you could use Hugging Face Transformers API (free tier available)
      
      final textLower = text.toLowerCase();
      
      // Network outage keywords
      if (textLower.contains('network') && (textLower.contains('down') || 
          textLower.contains('outage') || textLower.contains('no signal'))) {
        return {'label': 'NETWORK_OUTAGE', 'confidence': 0.85};
      }
      
      // Slow internet keywords  
      if (textLower.contains('slow') || textLower.contains('speed') || 
          textLower.contains('internet')) {
        return {'label': 'SLOW_INTERNET', 'confidence': 0.80};
      }
      
      // Billing keywords
      if (textLower.contains('bill') || textLower.contains('payment') || 
          textLower.contains('charge') || textLower.contains('money')) {
        return {'label': 'BILLING_ISSUE', 'confidence': 0.75};
      }
      
      // Technical support keywords
      if (textLower.contains('technical') || textLower.contains('support') || 
          textLower.contains('help') || textLower.contains('problem')) {
        return {'label': 'TECHNICAL_SUPPORT', 'confidence': 0.70};
      }
      
      // Service interruption keywords
      if (textLower.contains('service') || textLower.contains('interruption') || 
          textLower.contains('disruption')) {
        return {'label': 'SERVICE_INTERRUPTION', 'confidence': 0.75};
      }

      return {'label': 'OTHER', 'confidence': 0.60};
      
    } catch (e) {
      print('Classification error: $e');
      return {'label': 'OTHER', 'confidence': 0.50};
    }
  }

  // Alternative: Use Hugging Face API for more accurate classification (free tier)
  Future<Map<String, dynamic>> _classifyWithHuggingFace(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_huggingFaceUrl/facebook/bart-large-mnli'),
        headers: {
          'Authorization': 'Bearer YOUR_HF_TOKEN', // Replace with HF token
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'inputs': text,
          'parameters': {
            'candidate_labels': [
              'network outage',
              'slow internet',
              'billing issue',
              'technical support',
              'service interruption',
              'other'
            ]
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'label': data['labels'][0].toString().toUpperCase().replaceAll(' ', '_'),
          'confidence': data['scores'][0],
        };
      }
    } catch (e) {
      print('Hugging Face API error: $e');
    }

    return {'label': 'OTHER', 'confidence': 0.50};
  }

  // Analyze sentiment using keyword-based approach (free alternative)
  Future<Map<String, dynamic>> _analyzeSentiment(String text) async {
    try {
      final textLower = text.toLowerCase();
      
      // Negative sentiment keywords
      List<String> negativeWords = [
        'bad', 'terrible', 'awful', 'worst', 'hate', 'angry', 'frustrated',
        'slow', 'down', 'broken', 'not working', 'problem', 'issue', 'error'
      ];
      
      // Positive sentiment keywords
      List<String> positiveWords = [
        'good', 'great', 'excellent', 'love', 'happy', 'satisfied',
        'working', 'fast', 'thank', 'appreciate'
      ];
      
      int negativeCount = 0;
      int positiveCount = 0;
      
      for (String word in negativeWords) {
        if (textLower.contains(word)) negativeCount++;
      }
      
      for (String word in positiveWords) {
        if (textLower.contains(word)) positiveCount++;
      }
      
      if (negativeCount > positiveCount) {
        return {'label': 'NEGATIVE', 'confidence': 0.75};
      } else if (positiveCount > negativeCount) {
        return {'label': 'POSITIVE', 'confidence': 0.75};
      } else {
        return {'label': 'NEUTRAL', 'confidence': 0.65};
      }
      
    } catch (e) {
      print('Sentiment analysis error: $e');
      return {'label': 'NEUTRAL', 'confidence': 0.50};
    }
  }

  // Determine priority based on content and sentiment
  String _determinePriority(String text, String sentiment) {
    final textLower = text.toLowerCase();
    
    // High priority keywords
    List<String> highPriorityWords = [
      'outage', 'down', 'emergency', 'urgent', 'critical', 'no signal',
      'not working', 'completely', 'totally', 'dead'
    ];
    
    // Check for high priority indicators
    for (String word in highPriorityWords) {
      if (textLower.contains(word)) {
        return 'HIGH';
      }
    }
    
    // If sentiment is very negative, increase priority
    if (sentiment == 'NEGATIVE') {
      return 'MEDIUM';
    }
    
    return 'LOW';
  }

  // Send SMS response (would integrate with SMS gateway)
  Future<bool> sendSMSResponse({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // This would integrate with actual SMS gateway like:
      // - Twilio SMS API
      // - SMS.net.bd (for Bangladesh)
      // - TextMagic
      // - Plivo
      
      print('Sending SMS to $phoneNumber: $message');
      
      // Simulate SMS sending
      await Future.delayed(Duration(seconds: 1));
      
      return true;
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }

  // Auto-respond to common complaints
  Future<void> autoRespond(Complaint complaint) async {
    String responseMessage = _generateAutoResponse(complaint);
    
    bool sent = await sendSMSResponse(
      phoneNumber: complaint.phoneNumber,
      message: responseMessage,
    );
    
    if (sent) {
      print('Auto-response sent for complaint ${complaint.id}');
    }
  }

  String _generateAutoResponse(Complaint complaint) {
    switch (complaint.category) {
      case 'NETWORK_OUTAGE':
        return 'We received your report about network issues. Our technical team is investigating. You will be updated within 2 hours. Ref: ${complaint.id}';
      
      case 'SLOW_INTERNET':
        return 'Thank you for reporting slow internet. Please restart your device and check again. If issue persists, reply TECH for technical support. Ref: ${complaint.id}';
      
      case 'BILLING_ISSUE':
        return 'Your billing query has been received. Our billing team will review and respond within 24 hours. Ref: ${complaint.id}';
      
      case 'TECHNICAL_SUPPORT':
        return 'Technical support request received. Please ensure your device is powered on and try restarting. For urgent issues, call 123. Ref: ${complaint.id}';
      
      default:
        return 'Thank you for contacting us. Your message has been received and will be reviewed by our team. Ref: ${complaint.id}';
    }
  }

  // Batch process multiple SMS complaints
  Future<List<Complaint>> processBatchSMS(List<Map<String, String>> smsData) async {
    List<Complaint> complaints = [];
    
    for (Map<String, String> sms in smsData) {
      try {
        Complaint complaint = await processSMSComplaint(
          phoneNumber: sms['phoneNumber']!,
          message: sms['message']!,
          location: sms['location'] ?? 'Unknown',
        );
        
        complaints.add(complaint);
        
        // Auto-respond for certain categories
        if (['NETWORK_OUTAGE', 'TECHNICAL_SUPPORT'].contains(complaint.category)) {
          await autoRespond(complaint);
        }
        
      } catch (e) {
        print('Error processing SMS ${sms['phoneNumber']}: $e');
      }
    }
    
    return complaints;
  }

  // Get complaint statistics
  Map<String, int> getComplaintStats(List<Complaint> complaints) {
    Map<String, int> stats = {
      'total': complaints.length,
      'pending': 0,
      'inProgress': 0,
      'resolved': 0,
      'high': 0,
      'medium': 0,
      'low': 0,
    };

    for (Complaint complaint in complaints) {
      // Status counts
      switch (complaint.status) {
        case 'PENDING':
          stats['pending'] = (stats['pending'] ?? 0) + 1;
          break;
        case 'IN_PROGRESS':  
          stats['inProgress'] = (stats['inProgress'] ?? 0) + 1;
          break;
        case 'RESOLVED':
          stats['resolved'] = (stats['resolved'] ?? 0) + 1;
          break;
      }

      // Priority counts
      switch (complaint.priority) {
        case 'HIGH':
          stats['high'] = (stats['high'] ?? 0) + 1;
          break;
        case 'MEDIUM':
          stats['medium'] = (stats['medium'] ?? 0) + 1;
          break;
        case 'LOW':
          stats['low'] = (stats['low'] ?? 0) + 1;
          break;
      }
    }

    return stats;
  }

  // Export complaints to CSV
  String exportComplaintsToCSV(List<Complaint> complaints) {
    StringBuffer csv = StringBuffer();
    
    // Headers
    csv.writeln('ID,Phone Number,Original Text,Translated Text,Category,Priority,Sentiment,Confidence,Status,Location,Timestamp');
    
    // Data rows
    for (Complaint complaint in complaints) {
      csv.writeln([
        complaint.id,
        complaint.phoneNumber,
        '"${complaint.originalText.replaceAll('"', '""')}"',
        '"${complaint.translatedText.replaceAll('"', '""')}"',
        complaint.category,
        complaint.priority,
        complaint.sentiment,
        complaint.confidence.toStringAsFixed(2),
        complaint.status,
        complaint.location,
        complaint.timestamp.toIso8601String(),
      ].join(','));
    }
    
    return csv.toString();
  }
}