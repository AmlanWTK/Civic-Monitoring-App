import 'package:civic_app_4/models/models.dart';
import 'package:civic_app_4/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/prediction_service.dart';

import 'dart:async';

class PredictionsScreen extends StatefulWidget {
  @override
  _PredictionsScreenState createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends State<PredictionsScreen>
    with SingleTickerProviderStateMixin {
  final PredictionService _predictionService = PredictionService();
  
  List<PredictiveAlert> _alerts = [];
  List<Map<String, dynamic>> _maintenanceRecommendations = [];
  Map<String, dynamic> _trendAnalysis = {};
  bool _loading = true;
  String? _error;
  
  late TabController _tabController;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Changed from 3 to 2
    _loadPredictiveData();
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      _loadPredictiveData();
    });
  }

  Future<void> _loadPredictiveData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Load all predictive data in parallel
      final results = await Future.wait([
        _predictionService.generateMaintenanceAlerts(),
        _predictionService.generateMaintenanceRecommendations(),
        _loadTrendAnalysis(),
      ]);

      setState(() {
        _alerts = results[0] as List<PredictiveAlert>;
        _maintenanceRecommendations = results[1] as List<Map<String, dynamic>>;
        _trendAnalysis = results[2] as Map<String, dynamic>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _loadTrendAnalysis() async {
    // Generate sample historical data for trend analysis
    List<NetworkMetrics> sampleData = _generateSampleHistoricalData();
    return await _predictionService.analyzeNetworkTrends(sampleData);
  }

  List<NetworkMetrics> _generateSampleHistoricalData() {
    List<NetworkMetrics> data = [];
    List<String> towerIds = ['BD-001', 'BD-002', 'BD-003', 'BD-004'];
    
    for (int i = 0; i < 30; i++) { // 30 days of data
      for (String towerId in towerIds) {
        data.add(NetworkMetrics(
          towerId: towerId,
          location: _getTowerLocation(towerId),
          latitude: 23.8103,
          longitude: 90.4125,
          signalStrength: 70 + (i % 20) + (towerId == 'BD-004' ? -i ~/ 3 : 0), // BD-004 shows degradation
          latency: 40.0 + (i % 30),
          packetLoss: 0.5 + (i % 5) * 0.1,
          throughput: 300.0 + (i % 100),
          connectedUsers: 500 + (i % 300),
          uptime: 99.0 + (i % 10) * 0.1,
          status: 'healthy',
          timestamp: DateTime.now().subtract(Duration(days: 30 - i)),
        ));
      }
    }
    
    return data;
  }

  String _getTowerLocation(String towerId) {
    Map<String, String> locations = {
      'BD-001': 'Dhaka Central',
      'BD-002': 'Chittagong Port',
      'BD-003': 'Sylhet Hills',
      'BD-004': 'Khulna Division',
    };
    return locations[towerId] ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: Colors.grey[50],
        cardColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
          shadowColor: Colors.grey[300],
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: Colors.blue[600],
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.blue[600],
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          shadowColor: Colors.grey[300],
          elevation: 2,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
        ),
      ),
      child: Container(
        color: Colors.grey[50],
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 1,
            shadowColor: Colors.grey[300],
            title: Text('Predictive Maintenance', style: GoogleFonts.playfairDisplay(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.blue[600],
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.blue[600],
              tabs: [
                Tab(icon: Icon(Icons.warning), text: 'Alerts'),
                Tab(icon: Icon(Icons.build), text: 'Maintenance'),
                // Removed the Trends tab
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.black87),
                onPressed: _loadPredictiveData,
              ),
            ],
          ),
          body: _loading
              ? Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildErrorWidget()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAlertsTab(),
                        _buildMaintenanceTab(),
                        // Removed _buildTrendsTab()
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Error loading predictive data', style: TextStyle(color: Colors.black87)),
            Text(_error ?? 'Unknown error', style: TextStyle(color: Colors.black87)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPredictiveData,
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsTab() {
    return Container(
      color: Colors.grey[50],
      child: RefreshIndicator(
        onRefresh: _loadPredictiveData,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAlertsSummary(),
              SizedBox(height: 20),
              _buildAlertsFilter(),
              SizedBox(height: 20),
              _buildAlertsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsSummary() {
    int totalAlerts = _alerts.length;
    int criticalAlerts = _alerts.where((a) => a.severity == 'CRITICAL').length;
    int highAlerts = _alerts.where((a) => a.severity == 'HIGH').length;
    int activeAlerts = _alerts.where((a) => a.status == 'ACTIVE').length;

    return Card(
      color: Colors.white,
      shadowColor: Colors.grey[300],
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, size: 32, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Predictive Alerts',
                        style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                          fontSize: 20
                        ),
                      ),
                      Text(
                        'ML-powered infrastructure failure predictions',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getAlertHealthColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$activeAlerts Active',
                    style: TextStyle(
                      color: _getAlertHealthColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildAlertSummaryCard('Total', '$totalAlerts', Icons.list, Colors.blue),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildAlertSummaryCard('Critical', '$criticalAlerts', Icons.error, Colors.red),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildAlertSummaryCard('High', '$highAlerts', Icons.warning, Colors.orange),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildAlertSummaryCard('Active', '$activeAlerts', Icons.notifications_active, Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsFilter() {
    return Row(
      children: [
        Text(
          'Alerts by Severity',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 15
          ),
        ),
        Spacer(),
        
      ],
    );
  }

  Widget _buildAlertsList() {
    if (_alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'No Predictive Alerts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
            ),
            Text(
              'All systems are operating within normal parameters',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        return _buildAlertCard(_alerts[index]);
      },
    );
  }

  Widget _buildAlertCard(PredictiveAlert alert) {
    Color severityColor = _getSeverityColor(alert.severity);
    IconData alertIcon = _getAlertIcon(alert.alertType);

    return Card(
      color: Colors.white,
      shadowColor: Colors.grey[300],
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showAlertDetails(alert),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(alertIcon, color: severityColor, size: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: GoogleFonts.playfairDisplay(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey,
                          ),
                        ),
                        Text(
                          'Tower ${alert.towerId}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildSeverityChip(alert.severity),
                ],
              ),
              SizedBox(height: 12),
              Text(
                alert.description,
                style: GoogleFonts.roboto(color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    'Predicted: ${_formatPredictedTime(alert.predictedTime)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(alert.confidence * 100).toInt()}% confidence',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceTab() {
    return Container(
      color: Colors.grey[50],
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMaintenanceSummary(),
            SizedBox(height: 20),
            _buildMaintenanceRecommendations(),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceSummary() {
    int totalRecommendations = _maintenanceRecommendations.length;
    int highPriority = _maintenanceRecommendations.where((r) => r['priority'] == 'HIGH').length;
    int estimatedCost = _maintenanceRecommendations.fold(0, (sum, r) => sum + (r['estimatedCost'] as int));
    int estimatedHours = _maintenanceRecommendations.fold(0, (sum, r) => sum + (r['estimatedHours'] as int));

    return Card(
      color: Colors.white,
      shadowColor: Colors.grey[300],
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maintenance Overview',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
                fontSize: 20
              ),
            ),
            SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
              children: [
                MetricCard(
                  title: 'Total Tasks',
                  value: '$totalRecommendations',
                  icon: Icons.task,
                  color: Colors.blue,
                ),
                MetricCard(
                  title: 'High Priority',
                  value: '$highPriority',
                  icon: Icons.priority_high,
                  color: Colors.red,
                ),
                MetricCard(
                  title: 'Est. Cost',
                  value: '\$${(estimatedCost / 1000).toInt()}K',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
                MetricCard(
                  title: 'Est. Hours',
                  value: '${estimatedHours}h',
                  icon: Icons.access_time,
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Maintenance Recommendations',
          style:GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
            fontSize: 23
          ),
        ),
        SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _maintenanceRecommendations.length,
          itemBuilder: (context, index) {
            return _buildMaintenanceCard(_maintenanceRecommendations[index]);
          },
        ),
      ],
    );
  }

  Widget _buildMaintenanceCard(Map<String, dynamic> recommendation) {
    Color priorityColor = _getPriorityColor(recommendation['priority']);
    
    return Card(
      color: Colors.white,
      shadowColor: Colors.grey[300],
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: priorityColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getMaintenanceIcon(recommendation['type']),
            color: priorityColor,
          ),
        ),
        title: Text(recommendation['task'], style: TextStyle(color: Colors.black87)),
        subtitle: Text('Tower ${recommendation['towerId']} - ${recommendation['urgency']}', 
                     style: TextStyle(color: Colors.grey[600])),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: priorityColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            recommendation['priority'],
            style: TextStyle(
              color: priorityColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reasoning:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text(recommendation['reasoning'], style: TextStyle(color: Colors.black87)),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Estimated Cost:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                            Text('\$${recommendation['estimatedCost']}', style: TextStyle(color: Colors.black87)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Estimated Hours:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                            Text('${recommendation['estimatedHours']}h', style: TextStyle(color: Colors.black87)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text('Required Skills:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  Wrap(
                    spacing: 8,
                    children: (recommendation['skills'] as List<String>).map((skill) {
                      return Chip(
                        label: Text(skill, style: TextStyle(fontSize: 12, color: Colors.black87)),
                        backgroundColor: Colors.white,
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 12),
                 ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white, // Button background color
    side: BorderSide(color: Colors.black, width: 2), // Button border
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8), // Rounded corners
    ),
  ),
  onPressed: () => _scheduleMaintenance(recommendation),
  child: Text('Schedule Maintenance',style: TextStyle(color: Colors.black),),
)

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Widget _buildSeverityChip(String severity) {
    Color color = _getSeverityColor(severity);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        severity,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'CRITICAL': return Colors.red;
      case 'HIGH': return Colors.orange;
      case 'MEDIUM': return Colors.yellow;
      case 'LOW': return Colors.green;
      default: return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'HIGH': return Colors.red;
      case 'MEDIUM': return Colors.orange;
      case 'LOW': return Colors.green;
      default: return Colors.grey;
    }
  }

  Color _getAlertHealthColor() {
    int criticalCount = _alerts.where((a) => a.severity == 'CRITICAL').length;
    int highCount = _alerts.where((a) => a.severity == 'HIGH').length;
    
    if (criticalCount > 0) return Colors.red;
    if (highCount > 2) return Colors.orange;
    return Colors.green;
  }

  IconData _getAlertIcon(String alertType) {
    switch (alertType) {
      case 'NETWORK_DEGRADATION': return Icons.signal_wifi_bad;
      case 'EQUIPMENT_FAILURE': return Icons.build_circle;
      case 'CAPACITY_PLANNING': return Icons.analytics;
      case 'SCHEDULED_MAINTENANCE': return Icons.schedule;
      default: return Icons.warning;
    }
  }

  IconData _getMaintenanceIcon(String type) {
    switch (type) {
      case 'PREVENTIVE': return Icons.shield;
      case 'CORRECTIVE': return Icons.build;
      case 'UPGRADE': return Icons.upgrade;
      default: return Icons.settings;
    }
  }

  String _formatPredictedTime(DateTime predictedTime) {
    Duration difference = predictedTime.difference(DateTime.now());
    
    if (difference.inDays > 0) {
      return 'in ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} minutes';
    } else {
      return 'now';
    }
  }

  void _showAlertDetails(PredictiveAlert alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          color: Colors.white,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_getAlertIcon(alert.alertType), color: _getSeverityColor(alert.severity)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alert.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.black87),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Alert ID', alert.id),
                      _buildDetailRow('Tower ID', alert.towerId),
                      _buildDetailRow('Alert Type', alert.alertType.replaceAll('_', ' ')),
                      _buildDetailRow('Severity', alert.severity),
                      _buildDetailRow('Confidence', '${(alert.confidence * 100).toInt()}%'),
                      _buildDetailRow('Predicted Time', alert.predictedTime.toString()),
                      _buildDetailRow('Created', alert.createdAt.toString()),
                      SizedBox(height: 16),
                      Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      SizedBox(height: 8),
                      Text(alert.description, style: TextStyle(color: Colors.black87)),
                      SizedBox(height: 16),
                      Text('Recommended Action:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      SizedBox(height: 8),
                      Text(alert.recommendedAction, style: TextStyle(color: Colors.black87)),
                      SizedBox(height: 16),
                      if (alert.features.isNotEmpty) ...[
                        Text('ML Features:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        SizedBox(height: 8),
                        ...alert.features.entries.map((entry) =>
                          _buildDetailRow(entry.key, entry.value.toString())
                        ).toList(),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _acknowledgeAlert(alert),
                      child: Text('Acknowledge'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _scheduleAction(alert),
                      child: Text('Schedule Action'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }

  void _scheduleMaintenance(Map<String, dynamic> recommendation) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Maintenance scheduled for Tower ${recommendation['towerId']}'),
      ),
    );
  }

  void _acknowledgeAlert(PredictiveAlert alert) {
    setState(() {
      alert.status = 'ACKNOWLEDGED';
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alert ${alert.id} acknowledged')),
    );
  }

  void _scheduleAction(PredictiveAlert alert) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Action scheduled for ${alert.title}')),
    );
  }
}