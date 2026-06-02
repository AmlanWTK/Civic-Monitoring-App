import 'package:civic_app_4/models/models.dart';
import 'package:civic_app_4/theme.dart';
import 'package:civic_app_4/widgets/chart_widget.dart';
import 'package:civic_app_4/widgets/metric_card.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Network Health',
            style: GoogleFonts.inter(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded), text: 'Overview'),
            Tab(icon: Icon(Icons.network_check_rounded), text: 'QoS Metrics'),
            Tab(icon: Icon(Icons.analytics_rounded), text: 'Analytics'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadNetworkData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
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
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_rounded, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Error loading network data',
              style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 16)),
          const SizedBox(height: 8),
          Text(_error ?? 'Unknown error',
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNetworkData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.card,
      onRefresh: _loadNetworkData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNetworkSummary(),
            const SizedBox(height: 20),
            _buildTowerGrid(),
            const SizedBox(height: 20),
            _buildRealtimeMetrics(),
            const SizedBox(height: 16),
          ],
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

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2550), Color(0xFF0E1A38)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.network_check_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Network Overview',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.textPrimary)),
                    Text('Real-time telecom infrastructure monitoring',
                        style: GoogleFonts.inter(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: AppDecorations.statusBadge(_getOverallHealthColor()),
                child: Text('Health: ${avgSignalStrength.toInt()}%',
                    style: GoogleFonts.inter(
                        color: _getOverallHealthColor(),
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildSummaryCard('Total', '$totalTowers', Icons.cell_tower_rounded, AppColors.primary)),
              const SizedBox(width: 10),
              Expanded(child: _buildSummaryCard('Healthy', '$healthyTowers', Icons.check_circle_rounded, AppColors.success)),
              const SizedBox(width: 10),
              Expanded(child: _buildSummaryCard('Warning', '$warningTowers', Icons.warning_rounded, AppColors.warning)),
              const SizedBox(width: 10),
              Expanded(child: _buildSummaryCard('Critical', '$criticalTowers', Icons.error_rounded, AppColors.error)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: color.withOpacity(0.8)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildTowerGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tower Status',
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: _networkMetrics.length,
          itemBuilder: (context, index) =>
              _buildTowerCard(_networkMetrics[index]),
        ),
      ],
    );
  }

  Widget _buildTowerCard(NetworkMetrics tower) {
    Color statusColor = _getStatusColor(tower.status);
    return Container(
      decoration: AppDecorations.glowCard(statusColor),
      child: InkWell(
        onTap: () => _showTowerDetails(tower),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Icon(Icons.cell_tower_rounded,
                        color: statusColor, size: 20),
                  ),
                  const Spacer(),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: statusColor, shape: BoxShape.circle),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(tower.towerId,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary)),
              Text(tower.location,
                  style: GoogleFonts.inter(
                      color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.signal_cellular_alt_rounded,
                      size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text('${tower.signalStrength}%',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const Spacer(),
                  Text('${tower.latency.toInt()}ms',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealtimeMetrics() {
    if (_qosMetrics.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Real-time Metrics',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontSize: 16)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: [
            MetricCard(
              title: 'Avg Latency',
              value: '${_calculateAverageLatency().toInt()}ms',
              icon: Icons.speed_rounded,
              color: _getLatencyColor(_calculateAverageLatency()),
              subtitle: 'Network Response',
            ),
            MetricCard(
              title: 'Packet Loss',
              value: '${_calculateAveragePacketLoss().toStringAsFixed(1)}%',
              icon: Icons.warning_rounded,
              color: _getPacketLossColor(_calculateAveragePacketLoss()),
              subtitle: 'Data Integrity',
            ),
            MetricCard(
              title: 'Total Users',
              value: '${_calculateTotalUsers()}',
              icon: Icons.people_rounded,
              color: AppColors.primary,
              subtitle: 'Connected Devices',
            ),
            MetricCard(
              title: 'Avg Uptime',
              value: '${_calculateAverageUptime().toStringAsFixed(1)}%',
              icon: Icons.timer_rounded,
              color: AppColors.success,
              subtitle: 'Service Availability',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQoSTab() {
    if (_qosMetrics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.network_check_rounded, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text('No QoS data available',
                style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQoSOverview(),
          const SizedBox(height: 20),
          _buildQoSMetricsList(),
        ],
      ),
    );
  }

  Widget _buildQoSOverview() {
    double avgQualityScore = _qosMetrics.isNotEmpty
        ? _qosMetrics.map((q) => q.qualityScore).reduce((a, b) => a + b) / _qosMetrics.length
        : 0;

    return Card(
      color: AppColors.card,
      shadowColor: AppColors.border,
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quality of Service Overview',
              style: GoogleFonts.inter(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
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
                    backgroundColor: AppColors.border,
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
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
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
      color: AppColors.card,
      shadowColor: AppColors.border,
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
        title: Text('Tower ${qos.towerId}', style: GoogleFonts.inter(color: AppColors.textPrimary)),
        subtitle: Text('Quality: ${qos.qualityGrade} (${qos.qualityScore.toInt()}/100)', style: TextStyle(color: AppColors.textSecondary)),
        children: [
          Container(
            color: AppColors.surface,
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
          Icon(icon, size: 16, color: AppColors.textSecondary),
          SizedBox(width: 8),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPerformanceTrends(),
          const SizedBox(height: 20),
          _buildNetworkUtilization(),
          const SizedBox(height: 20),
          _buildPredictiveAnalytics(),
          const SizedBox(height: 16),
        ],
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
      color: AppColors.card,
      shadowColor: AppColors.border,
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Predictive Analytics',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
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
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Text(
                  description,
                  style: GoogleFonts.roboto(fontSize: 12, color: AppColors.textSecondary),
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
      backgroundColor: AppColors.surface,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          color: AppColors.surface,
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: AppColors.textPrimary),
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
                      Text('Additional Metrics:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}