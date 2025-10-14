import 'dart:convert';
import 'dart:math';
import 'package:civic_app_4/models/models.dart';
import 'package:http/http.dart' as http;


class PredictionService {
  final Random _random = Random();
  
  // Simple ML-based prediction service for telecom infrastructure
  // In production, this would integrate with actual ML models
  
  // Generate predictive maintenance alerts
  Future<List<PredictiveAlert>> generateMaintenanceAlerts() async {
    try {
      // Simulate API delay for ML model inference
      await Future.delayed(Duration(milliseconds: 800));
      
      List<PredictiveAlert> alerts = [];
      
      // Simulate different types of predictive alerts
      alerts.addAll(await _generateNetworkDegradationAlerts());
      alerts.addAll(await _generateEquipmentFailureAlerts());
      alerts.addAll(await _generateCapacityPlanningAlerts());
      alerts.addAll(await _generateMaintenanceScheduleAlerts());
      
      // Sort by severity and predicted time
      alerts.sort((a, b) {
        int severityCompare = _getSeverityOrder(b.severity).compareTo(_getSeverityOrder(a.severity));
        if (severityCompare != 0) return severityCompare;
        return a.predictedTime.compareTo(b.predictedTime);
      });
      
      return alerts;
    } catch (e) {
      print('Error generating maintenance alerts: $e');
      return _generateFallbackAlerts();
    }
  }

  Future<List<PredictiveAlert>> _generateNetworkDegradationAlerts() async {
    List<PredictiveAlert> alerts = [];
    
    // Simulate network performance degradation predictions
    List<String> towerIds = ['BD-001', 'BD-002', 'BD-003', 'BD-004', 'BD-005'];
    
    for (String towerId in towerIds) {
      // Random chance of generating an alert
      if (_random.nextDouble() < 0.3) { // 30% chance
        String severity = _generateRandomSeverity();
        DateTime predictedTime = DateTime.now().add(Duration(hours: _random.nextInt(72) + 1));
        
        alerts.add(PredictiveAlert(
          id: 'NET_${DateTime.now().millisecondsSinceEpoch}_$towerId',
          towerId: towerId,
          alertType: 'NETWORK_DEGRADATION',
          severity: severity,
          title: 'Network Performance Degradation Predicted',
          description: 'ML model predicts ${severity.toLowerCase()} performance issues for tower $towerId based on trending latency and packet loss patterns.',
          confidence: 0.7 + _random.nextDouble() * 0.25, // 70-95% confidence
          predictedTime: predictedTime,
          createdAt: DateTime.now(),
          features: {
            'avgLatency': 45.0 + _random.nextDouble() * 100,
            'packetLossRate': _random.nextDouble() * 5,
            'signalStrengthTrend': -5.0 - _random.nextDouble() * 15,
            'userComplaintRate': _random.nextDouble() * 20,
          },
          recommendedAction: _getRecommendedAction('NETWORK_DEGRADATION', severity),
        ));
      }
    }
    
    return alerts;
  }

  Future<List<PredictiveAlert>> _generateEquipmentFailureAlerts() async {
    List<PredictiveAlert> alerts = [];
    
    List<Map<String, dynamic>> equipmentTypes = [
      {'type': 'POWER_SUPPLY', 'probability': 0.15},
      {'type': 'ANTENNA', 'probability': 0.10},
      {'type': 'TRANSMITTER', 'probability': 0.08},
      {'type': 'COOLING_SYSTEM', 'probability': 0.12},
      {'type': 'BACKUP_GENERATOR', 'probability': 0.05},
    ];
    
    List<String> towerIds = ['BD-001', 'BD-002', 'BD-003', 'BD-004'];
    
    for (String towerId in towerIds) {
      for (Map<String, dynamic> equipment in equipmentTypes) {
        if (_random.nextDouble() < equipment['probability']) {
          String severity = equipment['type'] == 'POWER_SUPPLY' ? 'CRITICAL' : _generateRandomSeverity();
          DateTime predictedTime = DateTime.now().add(Duration(hours: _random.nextInt(168) + 12)); // 12 hours to 1 week
          
          alerts.add(PredictiveAlert(
            id: 'EQP_${DateTime.now().millisecondsSinceEpoch}_$towerId',
            towerId: towerId,
            alertType: 'EQUIPMENT_FAILURE',
            severity: severity,
            title: '${equipment['type'].toString().replaceAll('_', ' ')} Failure Predicted',
            description: 'Predictive model indicates potential ${equipment['type'].toString().toLowerCase().replaceAll('_', ' ')} failure at tower $towerId based on performance metrics and historical data.',
            confidence: 0.6 + _random.nextDouble() * 0.3, // 60-90% confidence
            predictedTime: predictedTime,
            createdAt: DateTime.now(),
            features: {
              'temperatureAnomaly': _random.nextDouble() * 25,
              'vibrationLevel': _random.nextDouble() * 100,
              'powerConsumption': 2000 + _random.nextDouble() * 1000,
              'operatingHours': 8000 + _random.nextDouble() * 4000,
              'lastMaintenanceAgo': _random.nextInt(365), // days
            },
            recommendedAction: _getRecommendedAction('EQUIPMENT_FAILURE', severity),
          ));
        }
      }
    }
    
    return alerts;
  }

  Future<List<PredictiveAlert>> _generateCapacityPlanningAlerts() async {
    List<PredictiveAlert> alerts = [];
    
    List<Map<String, dynamic>> capacityScenarios = [
      {'location': 'Dhaka Central', 'type': 'USER_GROWTH', 'towerId': 'BD-001'},
      {'location': 'Chittagong Port', 'type': 'BANDWIDTH_SATURATION', 'towerId': 'BD-002'},
      {'location': 'Sylhet Hills', 'type': 'COVERAGE_GAP', 'towerId': 'BD-003'},
    ];
    
    for (Map<String, dynamic> scenario in capacityScenarios) {
      if (_random.nextDouble() < 0.25) { // 25% chance
        DateTime predictedTime = DateTime.now().add(Duration(days: 30 + _random.nextInt(90))); // 1-4 months
        
        alerts.add(PredictiveAlert(
          id: 'CAP_${DateTime.now().millisecondsSinceEpoch}_${scenario['towerId']}',
          towerId: scenario['towerId'],
          alertType: 'CAPACITY_PLANNING',
          severity: 'MEDIUM',
          title: 'Capacity Planning Required',
          description: 'Predictive analysis suggests ${scenario['type'].toString().toLowerCase().replaceAll('_', ' ')} at ${scenario['location']} will require infrastructure expansion.',
          confidence: 0.8 + _random.nextDouble() * 0.15, // 80-95% confidence
          predictedTime: predictedTime,
          createdAt: DateTime.now(),
          features: {
            'userGrowthRate': 5.0 + _random.nextDouble() * 15, // 5-20% growth
            'peakUsageIncrease': _random.nextDouble() * 40,
            'currentUtilization': 60.0 + _random.nextDouble() * 30,
            'projectedDemand': 100.0 + _random.nextDouble() * 100,
          },
          recommendedAction: _getRecommendedAction('CAPACITY_PLANNING', 'MEDIUM'),
        ));
      }
    }
    
    return alerts;
  }

  Future<List<PredictiveAlert>> _generateMaintenanceScheduleAlerts() async {
    List<PredictiveAlert> alerts = [];
    
    List<String> towerIds = ['BD-001', 'BD-002', 'BD-003', 'BD-004'];
    
    for (String towerId in towerIds) {
      if (_random.nextDouble() < 0.4) { // 40% chance
        DateTime predictedTime = DateTime.now().add(Duration(days: _random.nextInt(30) + 7)); // 1-5 weeks
        
        alerts.add(PredictiveAlert(
          id: 'MNT_${DateTime.now().millisecondsSinceEpoch}_$towerId',
          towerId: towerId,
          alertType: 'SCHEDULED_MAINTENANCE',
          severity: 'LOW',
          title: 'Preventive Maintenance Recommended',
          description: 'Based on operational hours and performance trends, tower $towerId is due for preventive maintenance to ensure optimal performance.',
          confidence: 0.9 + _random.nextDouble() * 0.08, // 90-98% confidence
          predictedTime: predictedTime,
          createdAt: DateTime.now(),
          features: {
            'operationalHours': 6000 + _random.nextDouble() * 3000,
            'lastMaintenanceDays': _random.nextInt(180) + 90, // 90-270 days ago
            'performanceScore': 70.0 + _random.nextDouble() * 20,
            'componentWearLevel': _random.nextDouble() * 100,
          },
          recommendedAction: _getRecommendedAction('SCHEDULED_MAINTENANCE', 'LOW'),
        ));
      }
    }
    
    return alerts;
  }

  // Analyze network trends for predictive insights
  Future<Map<String, dynamic>> analyzeNetworkTrends(List<NetworkMetrics> historicalData) async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      
      if (historicalData.isEmpty) {
        return {'error': 'No historical data available'};
      }
      
      Map<String, List<double>> towerTrends = {};
      Map<String, dynamic> analysis = {};
      
      // Group data by tower
      for (NetworkMetrics metric in historicalData) {
        towerTrends.putIfAbsent(metric.towerId, () => []);
        towerTrends[metric.towerId]!.add(metric.signalStrength.toDouble());
      }
      
      // Analyze trends for each tower
      for (String towerId in towerTrends.keys) {
        List<double> values = towerTrends[towerId]!;
        if (values.length >= 3) {
          double trend = _calculateTrend(values);
          String trendDirection = trend > 2 ? 'improving' : trend < -2 ? 'degrading' : 'stable';
          
          analysis[towerId] = {
            'trend': trend,
            'direction': trendDirection,
            'avgSignalStrength': values.reduce((a, b) => a + b) / values.length,
            'volatility': _calculateVolatility(values),
            'prediction': _predictFuturePerformance(values),
          };
        }
      }
      
      // Overall network health prediction
      analysis['overallHealth'] = {
        'currentScore': _calculateOverallHealth(historicalData),
        'predictedScore': _predictOverallHealth(historicalData),
        'riskLevel': _assessRiskLevel(analysis),
        'recommendations': _generateRecommendations(analysis),
      };
      
      return analysis;
    } catch (e) {
      print('Error analyzing network trends: $e');
      return {'error': 'Analysis failed: $e'};
    }
  }

  // Predict infrastructure failures using simple ML approach
  Future<List<String>> predictInfrastructureFailures(Map<String, dynamic> metrics) async {
    List<String> predictions = [];
    
    try {
      await Future.delayed(Duration(milliseconds: 300));
      
      // Simple rule-based prediction (in production, use actual ML models)
      if (metrics['avgLatency'] != null && metrics['avgLatency'] > 150) {
        predictions.add('High latency detected - potential network congestion or equipment issues');
      }
      
      if (metrics['packetLoss'] != null && metrics['packetLoss'] > 3.0) {
        predictions.add('Excessive packet loss - possible transmission equipment failure');
      }
      
      if (metrics['signalStrengthTrend'] != null && metrics['signalStrengthTrend'] < -10) {
        predictions.add('Signal strength declining - antenna or transmitter maintenance needed');
      }
      
      if (metrics['uptimeTrend'] != null && metrics['uptimeTrend'] < 95.0) {
        predictions.add('Service reliability declining - infrastructure health check required');
      }
      
      // Generate additional predictions based on combined factors
      double riskScore = _calculateRiskScore(metrics);
      if (riskScore > 0.7) {
        predictions.add('High risk of service disruption within 48 hours - immediate attention required');
      } else if (riskScore > 0.5) {
        predictions.add('Moderate risk of performance degradation - schedule maintenance within 1 week');
      }
      
    } catch (e) {
      print('Error predicting infrastructure failures: $e');
    }
    
    return predictions;
  }

  // Generate maintenance recommendations
  Future<List<Map<String, dynamic>>> generateMaintenanceRecommendations() async {
    try {
      await Future.delayed(Duration(milliseconds: 400));
      
      List<Map<String, dynamic>> recommendations = [];
      
      // Simulated maintenance recommendations
      recommendations.addAll([
        {
          'type': 'PREVENTIVE',
          'priority': 'HIGH',
          'towerId': 'BD-004',
          'task': 'Replace backup power system',
          'estimatedCost': 15000,
          'estimatedHours': 8,
          'skills': ['Electrical', 'Power Systems'],
          'urgency': 'Within 3 days',
          'reasoning': 'Battery backup showing degraded capacity - risk of power outage',
        },
        {
          'type': 'CORRECTIVE',
          'priority': 'MEDIUM',
          'towerId': 'BD-002',
          'task': 'Antenna realignment and calibration',
          'estimatedCost': 3000,
          'estimatedHours': 4,
          'skills': ['RF Engineering', 'Field Technician'],
          'urgency': 'Within 1 week',
          'reasoning': 'Signal strength suboptimal - likely antenna misalignment',
        },
        {
          'type': 'UPGRADE',
          'priority': 'LOW',
          'towerId': 'BD-001',
          'task': 'Capacity expansion - additional transmitter',
          'estimatedCost': 50000,
          'estimatedHours': 24,
          'skills': ['RF Engineering', 'Installation Team'],
          'urgency': 'Within 1 month',
          'reasoning': 'User demand exceeding current capacity during peak hours',
        },
      ]);
      
      return recommendations;
    } catch (e) {
      print('Error generating maintenance recommendations: $e');
      return [];
    }
  }

  // Helper methods
  String _generateRandomSeverity() {
    List<String> severities = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'];
    List<double> weights = [0.4, 0.3, 0.2, 0.1]; // Weighted towards lower severity
    
    double random = _random.nextDouble();
    double cumulative = 0.0;
    
    for (int i = 0; i < severities.length; i++) {
      cumulative += weights[i];
      if (random <= cumulative) {
        return severities[i];
      }
    }
    
    return 'MEDIUM';
  }

  int _getSeverityOrder(String severity) {
    switch (severity) {
      case 'CRITICAL': return 4;
      case 'HIGH': return 3;
      case 'MEDIUM': return 2;
      case 'LOW': return 1;
      default: return 0;
    }
  }

  String _getRecommendedAction(String alertType, String severity) {
    switch (alertType) {
      case 'NETWORK_DEGRADATION':
        switch (severity) {
          case 'CRITICAL':
            return 'Immediate on-site investigation required. Dispatch emergency technical team.';
          case 'HIGH':
            return 'Schedule urgent maintenance within 24 hours. Monitor closely.';
          case 'MEDIUM':
            return 'Plan maintenance within 3-5 days. Increase monitoring frequency.';
          default:
            return 'Include in next scheduled maintenance cycle.';
        }
      case 'EQUIPMENT_FAILURE':
        switch (severity) {
          case 'CRITICAL':
            return 'Replace component immediately. Activate backup systems if available.';
          case 'HIGH':
            return 'Schedule component replacement within 48 hours.';
          default:
            return 'Order replacement parts and schedule maintenance.';
        }
      case 'CAPACITY_PLANNING':
        return 'Analyze current usage patterns and plan infrastructure expansion.';
      case 'SCHEDULED_MAINTENANCE':
        return 'Schedule routine maintenance during low-usage hours.';
      default:
        return 'Review alert details and take appropriate action.';
    }
  }

  double _calculateTrend(List<double> values) {
    if (values.length < 2) return 0.0;
    
    // Simple linear trend calculation
    double sum = 0;
    for (int i = 1; i < values.length; i++) {
      sum += values[i] - values[i-1];
    }
    
    return sum / (values.length - 1);
  }

  double _calculateVolatility(List<double> values) {
    if (values.length < 2) return 0.0;
    
    double mean = values.reduce((a, b) => a + b) / values.length;
    double sumSquaredDiffs = 0;
    
    for (double value in values) {
      sumSquaredDiffs += (value - mean) * (value - mean);
    }
    
    return sqrt(sumSquaredDiffs / values.length);
  }

  double sqrt(double x) {
    // Simple square root approximation
    if (x < 0) return 0;
    if (x == 0) return 0;
    
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  Map<String, double> _predictFuturePerformance(List<double> values) {
    double trend = _calculateTrend(values);
    double current = values.last;
    
    return {
      'next24h': current + trend * 24,
      'next7d': current + trend * 168,
      'next30d': current + trend * 720,
    };
  }

  double _calculateOverallHealth(List<NetworkMetrics> data) {
    if (data.isEmpty) return 0.0;
    
    double totalHealth = 0;
    for (NetworkMetrics metric in data) {
      totalHealth += metric.signalStrength;
    }
    
    return totalHealth / data.length;
  }

  double _predictOverallHealth(List<NetworkMetrics> data) {
    double currentHealth = _calculateOverallHealth(data);
    double trend = _calculateTrend(data.map((m) => m.signalStrength.toDouble()).toList());
    
    return (currentHealth + trend * 168).clamp(0.0, 100.0); // Predict 1 week ahead
  }

  String _assessRiskLevel(Map<String, dynamic> analysis) {
    int degradingTowers = 0;
    int totalTowers = 0;
    
    for (String key in analysis.keys) {
      if (key != 'overallHealth' && analysis[key] is Map) {
        totalTowers++;
        if (analysis[key]['direction'] == 'degrading') {
          degradingTowers++;
        }
      }
    }
    
    if (totalTowers == 0) return 'unknown';
    
    double degradationRatio = degradingTowers / totalTowers;
    
    if (degradationRatio > 0.5) return 'high';
    if (degradationRatio > 0.25) return 'medium';
    return 'low';
  }

  List<String> _generateRecommendations(Map<String, dynamic> analysis) {
    List<String> recommendations = [];
    String riskLevel = analysis['overallHealth']['riskLevel'];
    
    switch (riskLevel) {
      case 'high':
        recommendations.addAll([
          'Immediate network health assessment required',
          'Deploy emergency maintenance teams',
          'Activate backup systems where available',
          'Increase monitoring frequency to real-time',
        ]);
        break;
      case 'medium':
        recommendations.addAll([
          'Schedule comprehensive network audit',
          'Plan proactive maintenance for degrading towers',
          'Review capacity planning for high-usage areas',
          'Update emergency response procedures',
        ]);
        break;
      default:
        recommendations.addAll([
          'Continue regular monitoring schedule',
          'Perform routine preventive maintenance',
          'Monitor trending patterns for early detection',
          'Review performance optimization opportunities',
        ]);
    }
    
    return recommendations;
  }

  double _calculateRiskScore(Map<String, dynamic> metrics) {
    double riskScore = 0.0;
    int factors = 0;
    
    if (metrics['avgLatency'] != null) {
      riskScore += (metrics['avgLatency'] > 100 ? 0.3 : 0.0);
      factors++;
    }
    
    if (metrics['packetLoss'] != null) {
      riskScore += (metrics['packetLoss'] > 2.0 ? 0.4 : 0.0);
      factors++;
    }
    
    if (metrics['signalStrengthTrend'] != null) {
      riskScore += (metrics['signalStrengthTrend'] < -5 ? 0.3 : 0.0);
      factors++;
    }
    
    return factors > 0 ? riskScore / factors : 0.0;
  }

  List<PredictiveAlert> _generateFallbackAlerts() {
    return [
      PredictiveAlert(
        id: 'FALLBACK_001',
        towerId: 'BD-001',
        alertType: 'SYSTEM_INFO',
        severity: 'LOW',
        title: 'Prediction Service Unavailable',
        description: 'Unable to generate ML predictions. Using fallback data.',
        confidence: 0.5,
        predictedTime: DateTime.now().add(Duration(hours: 24)),
        createdAt: DateTime.now(),
        features: {},
        recommendedAction: 'Check prediction service connectivity and try again later.',
      ),
    ];
  }
}