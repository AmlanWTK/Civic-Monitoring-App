import 'package:civic_app_4/models/models.dart';
import 'package:civic_app_4/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/network_monitoring_service.dart';

class NetworkHealthScreen extends StatefulWidget {
  @override
  _NetworkHealthScreenState createState() => _NetworkHealthScreenState();
}

class _NetworkHealthScreenState extends State<NetworkHealthScreen>
    with SingleTickerProviderStateMixin {
  final NetworkMonitoringService _networkService = NetworkMonitoringService();
  
  List<NetworkMetrics> _networkMetrics = [];
  List<QoSMetrics> _qosMetrics = [];
  bool _loading = true;
  String? _error;
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNetworkData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNetworkData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final networkHealth = await _networkService.getNetworkHealth();
      final towerIds = networkHealth.map((n) => n.towerId).toList();
      final qosMetrics = await _networkService.getQoSMetrics(towerIds);

      setState(() {
        _networkMetrics = networkHealth;
        _qosMetrics = qosMetrics;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
    scaffoldBackgroundColor: Colors.grey.shade50,
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 1,
      shadowColor: Colors.grey.shade300,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: Colors.blue.shade600,
      unselectedLabelColor: Colors.grey.shade600,
      indicatorColor: Colors.blue.shade600,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      shadowColor: Colors.grey.shade300,
      elevation: 2,
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
            title: Text('Network Health', style: GoogleFonts.playfairDisplay(color: Colors.blueGrey, fontWeight: FontWeight.bold,fontSize: 25)),
            bottom:
             TabBar(
              controller: _tabController,
              labelColor: Colors.blue[600],
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.blue[600],
              tabs: [
                Tab(icon: Icon(Icons.dashboard), text: 'Overview',),
                Tab(icon: Icon(Icons.network_check), text: 'QoS Metrics'),
                Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.black87),
                onPressed: _loadNetworkData,
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
                        _buildOverviewTab(),
                        _buildQoSTab(),
                        _buildAnalyticsTab(),
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
            Text('Error loading network data', style: TextStyle(color: Colors.black87)),
            Text(_error ?? 'Unknown error', style: TextStyle(color: Colors.black87)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNetworkData,
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Container(
      color: Colors.grey[50],
      child: RefreshIndicator(
        onRefresh: _loadNetworkData,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNetworkSummary(),
              SizedBox(height: 20),
              _buildTowerGrid(),
              SizedBox(height: 20),
              _buildRealtimeMetrics(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkSummary() {
    int totalTowers = _networkMetrics.length;
    int healthyTowers = _networkMetrics.where((n) => n.status == 'healthy').length;
    int warningTowers = _networkMetrics.where((n) => n.status == 'warning').length;
    int criticalTowers = _networkMetrics.where((n) => n.status == 'critical').length;
    
    double avgSignalStrength = totalTowers > 0 
        ? _networkMetrics.map((n) => n.signalStrength).reduce((a, b) => a + b) / totalTowers
        : 0;

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
                Icon(Icons.network_check, size: 32, color: Colors.blueAccent),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Network Overview',
                        style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Real-time telecom infrastructure monitoring',
                        style: GoogleFonts.roboto(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getOverallHealthColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Health: ${avgSignalStrength.toInt()}%',
                    style: GoogleFonts.playfairDisplay(
                      color: _getOverallHealthColor(),
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
                  child: _buildSummaryCard('Total Towers', '$totalTowers', Icons.cell_tower, Colors.blue),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard('Healthy', '$healthyTowers', Icons.check_circle, Colors.green),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard('Warning', '$warningTowers', Icons.warning, Colors.orange),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard('Critical', '$criticalTowers', Icons.error, Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTowerGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tower Status',
          style: GoogleFonts.playfairDisplay(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: _networkMetrics.length,
          itemBuilder: (context, index) {
            return _buildTowerCard(_networkMetrics[index]);
          },
        ),
      ],
    );
  }

  Widget _buildTowerCard(NetworkMetrics tower) {
    Color statusColor = _getStatusColor(tower.status);
    
    return Card(
      color: Colors.white,
      shadowColor: Colors.grey[300],
      elevation: 2,
      child: InkWell(
        onTap: () => _showTowerDetails(tower),
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
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.cell_tower,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                tower.towerId,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Text(
                tower.location,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.signal_cellular_alt, size: 14, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    '${tower.signalStrength}%',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  Spacer(),
                  Text(
                    '${tower.latency.toInt()}ms',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealtimeMetrics() {
    if (_qosMetrics.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Real-time Metrics',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 25
          ),
        ),
        SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: [
            MetricCard(
              title: 'Avg Latency',
              value: '${_calculateAverageLatency().toInt()}ms',
              icon: Icons.speed,
              color: _getLatencyColor(_calculateAverageLatency()),
              subtitle: 'Network Response',
            ),
            MetricCard(
              title: 'Packet Loss',
              value: '${_calculateAveragePacketLoss().toStringAsFixed(1)}%',
              icon: Icons.warning,
              color: _getPacketLossColor(_calculateAveragePacketLoss()),
              subtitle: 'Data Integrity',
            ),
            MetricCard(
              title: 'Total Users',
              value: '${_calculateTotalUsers()}',
              icon: Icons.people,
              color: Colors.blue,
              subtitle: 'Connected Devices',
            ),
            MetricCard(
              title: 'Avg Uptime',
              value: '${_calculateAverageUptime().toStringAsFixed(1)}%',
              icon: Icons.timer,
              color: Colors.green,
              subtitle: 'Service Availability',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQoSTab() {
    if (_qosMetrics.isEmpty) {
      return Container(
        color: Colors.grey[50],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.network_check, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No QoS data available', style: TextStyle(color: Colors.black87)),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey[50],
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQoSOverview(),
            SizedBox(height: 20),
            _buildQoSMetricsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildQoSOverview() {
    double avgQualityScore = _qosMetrics.isNotEmpty
        ? _qosMetrics.map((q) => q.qualityScore).reduce((a, b) => a + b) / _qosMetrics.length
        : 0;

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
              'Quality of Service Overview',
              style: GoogleFonts.playfairDisplay(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Quality Score',
                        style: GoogleFonts.roboto(color: Colors.grey[800]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${avgQualityScore.toInt()}/100',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _getQualityScoreColor(avgQualityScore),
                        ),
                      ),
                      Text(
                        'Grade: ${_getQualityGrade(avgQualityScore)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getQualityScoreColor(avgQualityScore),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: avgQualityScore / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(_getQualityScoreColor(avgQualityScore)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQoSMetricsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tower QoS Metrics',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _qosMetrics.length,
          itemBuilder: (context, index) {
            return _buildQoSCard(_qosMetrics[index]);
          },
        ),
      ],
    );
  }

  Widget _buildQoSCard(QoSMetrics qos) {
    return Card(
      color: Colors.white,
      shadowColor: Colors.grey[300],
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getQualityScoreColor(qos.qualityScore).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.network_check,
            color: _getQualityScoreColor(qos.qualityScore),
          ),
        ),
        title: Text('Tower ${qos.towerId}', style: GoogleFonts.playfairDisplay(color: Colors.black)),
        subtitle: Text('Quality: ${qos.qualityGrade} (${qos.qualityScore.toInt()}/100)', style: TextStyle(color: Colors.grey[600])),
        children: [
          Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildQoSMetricRow('Bandwidth', '${qos.bandwidth.toInt()} Mbps', Icons.speed),
                  _buildQoSMetricRow('Latency', '${qos.latency.toInt()} ms', Icons.access_time),
                  _buildQoSMetricRow('Jitter', '${qos.jitter.toStringAsFixed(1)} ms', Icons.graphic_eq),
                  _buildQoSMetricRow('Packet Loss', '${qos.packetLoss.toStringAsFixed(2)}%', Icons.warning),
                  _buildQoSMetricRow('Throughput', '${qos.throughput.toInt()} Mbps', Icons.trending_up),
                  _buildQoSMetricRow('Error Rate', '${qos.errorRate.toStringAsFixed(2)}%', Icons.error),
                  _buildQoSMetricRow('Active Connections', '${qos.activeConnections}', Icons.people),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQoSMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 14, color: Colors.black87)),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return Container(
      color: Colors.grey[50],
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPerformanceTrends(),
            SizedBox(height: 20),
            _buildNetworkUtilization(),
            SizedBox(height: 20),
            _buildPredictiveAnalytics(),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceTrends() {
    List<ChartData> latencyTrend = _networkMetrics.map((n) => 
      ChartData(label: n.towerId, value: n.latency)
    ).toList();

    return ChartWidget(
      title: 'Latency Trends by Tower',
      data: latencyTrend,
      primaryColor: Colors.orange,
      chartType: ChartType.bar,
      yAxisLabel: 'Latency (ms)',
    );
  }

  Widget _buildNetworkUtilization() {
    List<ChartData> utilizationData = _networkMetrics.map((n) => 
      ChartData(
        label: n.towerId,
        value: n.signalStrength.toDouble(),
      )
    ).toList();

    return ChartWidget(
      title: 'Signal Strength Distribution',
      data: utilizationData,
      primaryColor: Colors.green,
      chartType: ChartType.pie,
    );
  }

  Widget _buildPredictiveAnalytics() {
    return Card(
      color: Colors.white,
      shadowColor: Colors.grey[300],
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Predictive Analytics',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
                fontSize: 20
              ),
            ),
            SizedBox(height: 16),
            _buildPredictionCard(
              'Network Congestion',
              'Expected during 6-8 PM peak hours',
              'Medium Risk',
              Colors.orange,
              Icons.trending_up,
            ),
            _buildPredictionCard(
              'Maintenance Required',
              'BD-004 showing degraded performance',
              'High Priority',
              Colors.red,
              Icons.build,
            ),
            _buildPredictionCard(
              'Capacity Planning',
              'Additional tower needed in Dhaka Central',
              'Future Planning',
              Colors.blue,
              Icons.add_location,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard(String title, String description, String level, Color color, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Text(
                  description,
                  style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              level,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getOverallHealthColor() {
    if (_networkMetrics.isEmpty) return Colors.grey;
    
    int healthyCount = _networkMetrics.where((n) => n.status == 'healthy').length;
    double healthyPercentage = healthyCount / _networkMetrics.length;
    
    if (healthyPercentage >= 0.8) return Colors.green;
    if (healthyPercentage >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'healthy': return Colors.green;
      case 'warning': return Colors.orange;
      case 'critical': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _getLatencyColor(double latency) {
    if (latency <= 50) return Colors.green;
    if (latency <= 100) return Colors.orange;
    return Colors.red;
  }

  Color _getPacketLossColor(double packetLoss) {
    if (packetLoss <= 1) return Colors.green;
    if (packetLoss <= 3) return Colors.orange;
    return Colors.red;
  }

  Color _getQualityScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  String _getQualityGrade(double score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  double _calculateAverageLatency() {
    if (_qosMetrics.isEmpty) return 0;
    return _qosMetrics.map((q) => q.latency).reduce((a, b) => a + b) / _qosMetrics.length;
  }

  double _calculateAveragePacketLoss() {
    if (_qosMetrics.isEmpty) return 0;
    return _qosMetrics.map((q) => q.packetLoss).reduce((a, b) => a + b) / _qosMetrics.length;
  }

  int _calculateTotalUsers() {
    return _networkMetrics.fold(0, (sum, n) => sum + n.connectedUsers);
  }

  double _calculateAverageUptime() {
    if (_networkMetrics.isEmpty) return 0;
    return _networkMetrics.map((n) => n.uptime).reduce((a, b) => a + b) / _networkMetrics.length;
  }

  void _showTowerDetails(NetworkMetrics tower) {
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
                  Icon(Icons.cell_tower, color: _getStatusColor(tower.status)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tower ${tower.towerId}',
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
                      _buildDetailRow('Location', tower.location),
                      _buildDetailRow('Status', tower.status.toUpperCase()),
                      _buildDetailRow('Signal Strength', '${tower.signalStrength}%'),
                      _buildDetailRow('Latency', '${tower.latency.toInt()} ms'),
                      _buildDetailRow('Packet Loss', '${tower.packetLoss.toStringAsFixed(2)}%'),
                      _buildDetailRow('Throughput', '${tower.throughput.toInt()} Mbps'),
                      _buildDetailRow('Connected Users', '${tower.connectedUsers}'),
                      _buildDetailRow('Uptime', '${tower.uptime.toStringAsFixed(2)}%'),
                      _buildDetailRow('Coordinates', '${tower.latitude}, ${tower.longitude}'),
                      SizedBox(height: 16),
                      Text('Additional Metrics:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      ...tower.additionalMetrics.entries.map((entry) =>
                        _buildDetailRow(entry.key, entry.value.toString())
                      ).toList(),
                    ],
                  ),
                ),
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
}