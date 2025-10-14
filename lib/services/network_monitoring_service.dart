import 'dart:convert';
import 'dart:math';
import 'package:civic_app_4/models/models.dart';
import 'package:http/http.dart' as http;


class NetworkMonitoringService {
  static const String _prometheusUrl = 'http://localhost:9090'; // Local Prometheus instance
  static const String _prtgUrl = 'https://your-prtg-server.com'; // PRTG Network Monitor
  
  // Free network monitoring APIs and tools integration
  final Random _random = Random();
  
  // Monitor network quality of service metrics
  Future<List<QoSMetrics>> getQoSMetrics(List<String> towerIds) async {
    List<QoSMetrics> metrics = [];
    
    for (String towerId in towerIds) {
      try {
        // In production, this would query actual monitoring systems
        QoSMetrics qos = await _getQoSForTower(towerId);
        metrics.add(qos);
      } catch (e) {
        print('Error getting QoS metrics for $towerId: $e');
        // Add fallback metrics
        metrics.add(_generateFallbackQoS(towerId));
      }
    }
    
    return metrics;
  }

  Future<QoSMetrics> _getQoSForTower(String towerId) async {
    // Simulate realistic network metrics
    await Future.delayed(Duration(milliseconds: 200));
    
    return QoSMetrics(
      towerId: towerId,
      timestamp: DateTime.now(),
      bandwidth: 100.0 + _random.nextDouble() * 900, // 100-1000 Mbps
      latency: 20.0 + _random.nextDouble() * 180, // 20-200 ms
      jitter: _random.nextDouble() * 50, // 0-50 ms
      packetLoss: _random.nextDouble() * 5, // 0-5%
      throughput: 50.0 + _random.nextDouble() * 450, // 50-500 Mbps
      errorRate: _random.nextDouble() * 2, // 0-2%
      activeConnections: 100 + _random.nextInt(1900), // 100-2000
      serviceClassMetrics: {
        'voice': 90.0 + _random.nextDouble() * 10, // 90-100%
        'video': 80.0 + _random.nextDouble() * 20, // 80-100%
        'data': 70.0 + _random.nextDouble() * 30, // 70-100%
        'background': 60.0 + _random.nextDouble() * 40, // 60-100%
      },
    );
  }

  QoSMetrics _generateFallbackQoS(String towerId) {
    return QoSMetrics(
      towerId: towerId,
      timestamp: DateTime.now(),
      bandwidth: 500.0,
      latency: 50.0,
      jitter: 10.0,
      packetLoss: 1.0,
      throughput: 300.0,
      errorRate: 0.5,
      activeConnections: 500,
      serviceClassMetrics: {
        'voice': 95.0,
        'video': 90.0,
        'data': 85.0,
        'background': 80.0,
      },
    );
  }

  // Get comprehensive network health for all towers
  Future<List<NetworkMetrics>> getNetworkHealth() async {
    try {
      List<String> towerIds = ['BD-001', 'BD-002', 'BD-003', 'BD-004', 'BD-005'];
      List<NetworkMetrics> healthMetrics = [];
      
      for (String towerId in towerIds) {
        NetworkMetrics metrics = await _getNetworkMetricsForTower(towerId);
        healthMetrics.add(metrics);
      }
      
      return healthMetrics;
    } catch (e) {
      print('Error getting network health: $e');
      return _generateFallbackNetworkHealth();
    }
  }

  Future<NetworkMetrics> _getNetworkMetricsForTower(String towerId) async {
    // Simulate API calls to network monitoring systems
    await Future.delayed(Duration(milliseconds: 300));
    
    Map<String, dynamic> towerData = _getTowerData(towerId);
    
    // Simulate realistic metrics with some variability
    int signalStrength = 70 + _random.nextInt(30); // 70-100%
    double latency = 20.0 + _random.nextDouble() * 100; // 20-120ms
    double packetLoss = _random.nextDouble() * 3; // 0-3%
    double throughput = 100.0 + _random.nextDouble() * 400; // 100-500 Mbps
    int connectedUsers = 200 + _random.nextInt(1800); // 200-2000
    double uptime = 95.0 + _random.nextDouble() * 5; // 95-100%
    
    // Determine status based on metrics
    String status = _determineStatus(signalStrength, latency, packetLoss, uptime);
    
    return NetworkMetrics(
      towerId: towerId,
      location: towerData['location'],
      latitude: towerData['latitude'],
      longitude: towerData['longitude'],
      signalStrength: signalStrength,
      latency: latency,
      packetLoss: packetLoss,
      throughput: throughput,
      connectedUsers: connectedUsers,
      uptime: uptime,
      status: status,
      timestamp: DateTime.now(),
      additionalMetrics: {
        'cpuUsage': 20.0 + _random.nextDouble() * 60, // 20-80%
        'memoryUsage': 30.0 + _random.nextDouble() * 50, // 30-80%
        'diskUsage': 40.0 + _random.nextDouble() * 40, // 40-80%
        'temperature': 35.0 + _random.nextDouble() * 25, // 35-60°C
        'powerConsumption': 2000.0 + _random.nextDouble() * 1000, // 2-3kW
      },
    );
  }

  Map<String, dynamic> _getTowerData(String towerId) {
    Map<String, Map<String, dynamic>> towers = {
      'BD-001': {
        'location': 'Dhaka Central',
        'latitude': 23.8103,
        'longitude': 90.4125,
      },
      'BD-002': {
        'location': 'Chittagong Port',
        'latitude': 22.3569,
        'longitude': 91.7832,
      },
      'BD-003': {
        'location': 'Sylhet Hills',
        'latitude': 24.8949,
        'longitude': 91.8687,
      },
      'BD-004': {
        'location': 'Khulna Division',
        'latitude': 22.8456,
        'longitude': 89.5403,
      },
      'BD-005': {
        'location': 'Rajshahi Region',
        'latitude': 24.3745,
        'longitude': 88.6042,
      },
    };
    
    return towers[towerId] ?? {
      'location': 'Unknown Location',
      'latitude': 23.8103,
      'longitude': 90.4125,
    };
  }

  String _determineStatus(int signalStrength, double latency, double packetLoss, double uptime) {
    // Critical conditions
    if (signalStrength < 50 || latency > 200 || packetLoss > 5 || uptime < 90) {
      return 'critical';
    }
    
    // Warning conditions
    if (signalStrength < 70 || latency > 100 || packetLoss > 2 || uptime < 95) {
      return 'warning';
    }
    
    return 'healthy';
  }

  List<NetworkMetrics> _generateFallbackNetworkHealth() {
    List<String> towerIds = ['BD-001', 'BD-002', 'BD-003', 'BD-004'];
    return towerIds.map((id) => NetworkMetrics(
      towerId: id,
      location: _getTowerData(id)['location'],
      latitude: _getTowerData(id)['latitude'],
      longitude: _getTowerData(id)['longitude'],
      signalStrength: 85,
      latency: 45.0,
      packetLoss: 0.5,
      throughput: 300.0,
      connectedUsers: 800,
      uptime: 99.2,
      status: 'healthy',
      timestamp: DateTime.now(),
    )).toList();
  }

  // Monitor specific QoS parameters using SNMP simulation
  Future<Map<String, dynamic>> getSNMPMetrics(String towerId) async {
    try {
      // Simulate SNMP polling
      await Future.delayed(Duration(milliseconds: 500));
      
      return {
        'interfaceStats': {
          'bytesIn': 1000000 + _random.nextInt(9000000),
          'bytesOut': 800000 + _random.nextInt(7000000),
          'packetsIn': 5000 + _random.nextInt(45000),
          'packetsOut': 4000 + _random.nextInt(36000),
          'errorsIn': _random.nextInt(10),
          'errorsOut': _random.nextInt(5),
          'utilization': 30.0 + _random.nextDouble() * 40,
        },
        'systemStats': {
          'cpuLoad': 20.0 + _random.nextDouble() * 60,
          'memoryUsage': 40.0 + _random.nextDouble() * 40,
          'diskUsage': 50.0 + _random.nextDouble() * 30,
          'uptime': DateTime.now().millisecondsSinceEpoch - (24 * 60 * 60 * 1000),
        },
        'environmentalStats': {
          'temperature': 25.0 + _random.nextDouble() * 20,
          'humidity': 40.0 + _random.nextDouble() * 40,
          'powerStatus': 'normal',
          'fanSpeed': 1500 + _random.nextInt(1000),
        },
      };
    } catch (e) {
      print('Error getting SNMP metrics: $e');
      return {};
    }
  }

  // Integrate with Prometheus for metrics collection
  Future<Map<String, double>> getPrometheusMetrics(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_prometheusUrl/api/v1/query?query=$query'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Map<String, double> metrics = {};
        
        for (var result in data['data']['result']) {
          String metric = result['metric']['__name__'] ?? 'unknown';
          double value = double.tryParse(result['value'][1]) ?? 0.0;
          metrics[metric] = value;
        }
        
        return metrics;
      }
    } catch (e) {
      print('Error querying Prometheus: $e');
    }
    
    return {};
  }

  // Monitor bandwidth utilization per service class
  Future<Map<String, double>> getBandwidthUtilization(String towerId) async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      
      return {
        'voice': 15.0 + _random.nextDouble() * 10, // 15-25%
        'video': 30.0 + _random.nextDouble() * 20, // 30-50%
        'data': 40.0 + _random.nextDouble() * 30, // 40-70%
        'background': 5.0 + _random.nextDouble() * 15, // 5-20%
        'management': 2.0 + _random.nextDouble() * 3, // 2-5%
      };
    } catch (e) {
      print('Error getting bandwidth utilization: $e');
      return {};
    }
  }

  // Check SLA compliance
  Future<Map<String, dynamic>> checkSLACompliance(String towerId) async {
    try {
      QoSMetrics qos = await _getQoSForTower(towerId);
      
      // Define SLA thresholds
      Map<String, double> slaThresholds = {
        'latency': 100.0, // max 100ms
        'packetLoss': 1.0, // max 1%
        'jitter': 20.0, // max 20ms
        'availability': 99.5, // min 99.5%
        'throughput': 100.0, // min 100 Mbps
      };
      
      Map<String, dynamic> compliance = {};
      
      compliance['latency'] = {
        'value': qos.latency,
        'threshold': slaThresholds['latency'],
        'compliant': qos.latency <= slaThresholds['latency']!,
      };
      
      compliance['packetLoss'] = {
        'value': qos.packetLoss,
        'threshold': slaThresholds['packetLoss'],
        'compliant': qos.packetLoss <= slaThresholds['packetLoss']!,
      };
      
      compliance['jitter'] = {
        'value': qos.jitter,
        'threshold': slaThresholds['jitter'],
        'compliant': qos.jitter <= slaThresholds['jitter']!,
      };
      
      compliance['throughput'] = {
        'value': qos.throughput,
        'threshold': slaThresholds['throughput'],
        'compliant': qos.throughput >= slaThresholds['throughput']!,
      };
      
      // Calculate overall compliance score
      int compliantCount = 0;
      for (var metric in compliance.values) {
        if (metric['compliant']) compliantCount++;
      }
      
      compliance['overallScore'] = (compliantCount / compliance.length) * 100;
      compliance['overallCompliant'] = compliance['overallScore'] >= 80;
      
      return compliance;
    } catch (e) {
      print('Error checking SLA compliance: $e');
      return {};
    }
  }

  // Generate network health report
  Future<Map<String, dynamic>> generateHealthReport() async {
    try {
      List<NetworkMetrics> networkHealth = await getNetworkHealth();
      
      Map<String, dynamic> report = {
        'timestamp': DateTime.now().toIso8601String(),
        'totalTowers': networkHealth.length,
        'healthyTowers': networkHealth.where((n) => n.status == 'healthy').length,
        'warningTowers': networkHealth.where((n) => n.status == 'warning').length,
        'criticalTowers': networkHealth.where((n) => n.status == 'critical').length,
        'averageSignalStrength': _calculateAverage(networkHealth.map((n) => n.signalStrength.toDouble()).toList()),
        'averageLatency': _calculateAverage(networkHealth.map((n) => n.latency).toList()),
        'averageUptime': _calculateAverage(networkHealth.map((n) => n.uptime).toList()),
        'totalConnectedUsers': networkHealth.fold(0, (sum, n) => sum + n.connectedUsers),
        'towers': networkHealth.map((n) => n.toJson()).toList(),
      };
      
      return report;
    } catch (e) {
      print('Error generating health report: $e');
      return {};
    }
  }

  double _calculateAverage(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  // Real-time monitoring with WebSocket simulation
  Stream<NetworkMetrics> monitorTowerRealTime(String towerId) async* {
    while (true) {
      try {
        NetworkMetrics metrics = await _getNetworkMetricsForTower(towerId);
        yield metrics;
        await Future.delayed(Duration(seconds: 5)); // Update every 5 seconds
      } catch (e) {
        print('Error in real-time monitoring: $e');
        await Future.delayed(Duration(seconds: 10)); // Retry after 10 seconds
      }
    }
  }

  // Export metrics to CSV
  String exportMetricsToCSV(List<NetworkMetrics> metrics) {
    StringBuffer csv = StringBuffer();
    
    // Headers
    csv.writeln('Tower ID,Location,Signal Strength,Latency,Packet Loss,Throughput,Connected Users,Uptime,Status,Timestamp');
    
    // Data rows
    for (NetworkMetrics metric in metrics) {
      csv.writeln([
        metric.towerId,
        metric.location,
        metric.signalStrength,
        metric.latency.toStringAsFixed(2),
        metric.packetLoss.toStringAsFixed(2),
        metric.throughput.toStringAsFixed(2),
        metric.connectedUsers,
        metric.uptime.toStringAsFixed(2),
        metric.status,
        metric.timestamp.toIso8601String(),
      ].join(','));
    }
    
    return csv.toString();
  }

  // Predict network issues based on trends
  Future<List<String>> predictNetworkIssues(List<NetworkMetrics> historicalMetrics) async {
    List<String> predictions = [];
    
    try {
      // Simple trend analysis (in production, use proper ML models)
      Map<String, List<double>> trends = {};
      
      for (NetworkMetrics metric in historicalMetrics) {
        trends.putIfAbsent(metric.towerId, () => []);
        
        // Use signal strength as primary indicator
        trends[metric.towerId]!.add(metric.signalStrength.toDouble());
      }
      
      for (String towerId in trends.keys) {
        List<double> values = trends[towerId]!;
        if (values.length >= 3) {
          // Calculate trend
          double avgRecent = values.sublist(values.length - 3).reduce((a, b) => a + b) / 3;
          double avgPrevious = values.sublist(0, values.length - 3).reduce((a, b) => a + b) / (values.length - 3);
          
          if (avgRecent < avgPrevious - 10) {
            predictions.add('Tower $towerId: Signal strength declining - potential maintenance needed');
          }
        }
      }
    } catch (e) {
      print('Error predicting network issues: $e');
    }
    
    return predictions;
  }
}