import 'package:civic_app_4/services/prediction_service.dart';
import 'package:civic_app_4/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/network_monitoring_service.dart';
import '../services/sms_service.dart';

import 'dart:async';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final NetworkMonitoringService _networkService = NetworkMonitoringService();
  final SMSService _smsService = SMSService();
  final PredictionService _predictionService = PredictionService();
  
  Timer? _refreshTimer;
  bool _loading = true;
  
  // Dashboard metrics
  Map<String, dynamic> _metrics = {
    'networkHealth': 85,
    'activeTowers': 12,
    'avgLatency': 45,
    'packetLoss': 0.2,
    'newComplaints': 8,
    'resolvedComplaints': 23,
    'criticalAlerts': 3,
    'maintenanceAlerts': 2,
  };

  List<Map<String, dynamic>> _recentAlerts = [];
  List<Map<String, dynamic>> _towerStatus = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      // Simulate API calls to get real-time data
      await Future.wait([
        _loadNetworkMetrics(),
        _loadComplaintMetrics(),
        _loadPredictiveAlerts(),
      ]);
      
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print('Error loading dashboard data: $e');
    }
  }

  Future<void> _loadNetworkMetrics() async {
    // Simulate network monitoring data
    await Future.delayed(Duration(milliseconds: 500));
    
    // In real implementation, these would come from network monitoring APIs
    _metrics['networkHealth'] = 80 + (DateTime.now().millisecond % 20);
    _metrics['avgLatency'] = 30 + (DateTime.now().millisecond % 50);
    _metrics['packetLoss'] = (DateTime.now().millisecond % 5) / 10.0;
    
    _towerStatus = [
      {'id': 'BD-001', 'location': 'Dhaka Central', 'status': 'healthy', 'signal': 95},
      {'id': 'BD-002', 'location': 'Chittagong Port', 'status': 'warning', 'signal': 78},
      {'id': 'BD-003', 'location': 'Sylhet Hill', 'status': 'healthy', 'signal': 88},
      {'id': 'BD-004', 'location': 'Khulna Bridge', 'status': 'critical', 'signal': 45},
    ];
  }

  Future<void> _loadComplaintMetrics() async {
    // Simulate SMS complaint processing
    await Future.delayed(Duration(milliseconds: 300));
    
    _metrics['newComplaints'] = 5 + (DateTime.now().hour % 10);
    _metrics['resolvedComplaints'] = 20 + (DateTime.now().hour % 15);
  }

  Future<void> _loadPredictiveAlerts() async {
    // Simulate predictive maintenance alerts
    await Future.delayed(Duration(milliseconds: 400));
    
    _recentAlerts = [
      {
        'type': 'critical',
        'icon': Icons.error,
        'title': 'Tower Signal Degradation',
        'message': 'BD-004 showing 60% signal drop - maintenance required',
        'time': '5 min ago',
        'color': Colors.red,
      },
      {
        'type': 'warning',
        'icon': Icons.warning,
        'title': 'High Network Latency',
        'message': 'BD-002 experiencing 150ms+ latency',
        'time': '12 min ago',
        'color': Colors.orange,
      },
      {
        'type': 'info',
        'icon': Icons.info,
        'title': 'Scheduled Maintenance',
        'message': 'BD-001 maintenance window: 2 AM - 4 AM',
        'time': '1 hour ago',
        'color': Colors.blue,
      },
      {
        'type': 'success',
        'icon': Icons.check_circle,
        'title': 'Complaint Resolved',
        'message': '8 SMS complaints auto-resolved via AI',
        'time': '2 hours ago',
        'color': Colors.green,
      },
    ];
    
    _metrics['criticalAlerts'] = _recentAlerts.where((a) => a['type'] == 'critical').length;
    _metrics['maintenanceAlerts'] = _recentAlerts.where((a) => a['type'] == 'warning').length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(),
                    SizedBox(height: 20),
                    _buildMetricsGrid(),
                    SizedBox(height: 20),
                    _buildAlertsSection(),
                    SizedBox(height: 20),
                    _buildTowerStatusSection(),
                    SizedBox(height: 20),
                    _buildQuickActionsSection(),
                  ],
                ),
              ),
            ),
    );
  }
Widget _buildHeaderSection() {
  return Card(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dashboard, size: 32, color: Colors.blueAccent),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Infrastructure Dashboard',
                      style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Real-time monitoring of telecom infrastructure',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getHealthColor(_metrics['networkHealth']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: _getHealthColor(_metrics['networkHealth']),
                      size: 10,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '${_metrics['networkHealth']}%',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w600,
                        color: _getHealthColor(_metrics['networkHealth']),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Last updated: ${DateTime.now().toString().substring(0, 19)}',
            style: GoogleFonts.roboto(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: [
        MetricCard(
          title: 'Active Towers',
          value: '${_metrics['activeTowers']}',
          icon: Icons.cell_tower,
          color: Colors.blue,
          subtitle: 'Online & Operational',
        ),
        MetricCard(
          title: 'Avg Latency',
          value: '${_metrics['avgLatency']}ms',
          icon: Icons.speed,
          color: _getLatencyColor(_metrics['avgLatency']),
          subtitle: 'Network Response',
        ),
        MetricCard(
          title: 'New Complaints',
          value: '${_metrics['newComplaints']}',
          icon: Icons.message,
          color: Colors.orange,
          subtitle: 'SMS Reports Today',
        ),
        MetricCard(
          title: 'Critical Alerts',
          value: '${_metrics['criticalAlerts']}',
          icon: Icons.warning,
          color: Colors.red,
          subtitle: 'Require Attention',
        ),
      ],
    );
  }

  Widget _buildAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Alerts',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
                fontSize: 25
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full alerts screen
              },
              child: Text('View All', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
        SizedBox(height: 12),
        Card(
          color: Colors.white,
          elevation: 2,
          child: Column(
            children: _recentAlerts.take(3).map((alert) {
              return AlertWidget(
                icon: alert['icon'],
                title: alert['title'],
                message: alert['message'],
                time: alert['time'],
                color: alert['color'],
                onTap: () {
                  _showAlertDetails(alert);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTowerStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tower Status',
          style: GoogleFonts.playfairDisplay(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        SizedBox(height: 12),
        Card(
          color: Colors.white,
          elevation: 2,
          child: Column(
            children: _towerStatus.map((tower) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getTowerStatusColor(tower['status']).withOpacity(0.2),
                  child: Icon(
                    Icons.cell_tower,
                    color: _getTowerStatusColor(tower['status']),
                  ),
                ),
                title: Text('${tower['id']} - ${tower['location']}', style: GoogleFonts.roboto(color: Colors.black)),
                subtitle: Text('Signal: ${tower['signal']}%', style: TextStyle(color: Colors.grey[600])),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTowerStatusColor(tower['status']).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tower['status'].toString().toUpperCase(),
                    style: TextStyle(
                      color: _getTowerStatusColor(tower['status']),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  _showTowerDetails(tower);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
            fontSize: 25
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to complaints screen
                },
                icon: Icon(Icons.message, color: Colors.white),
                label: Text('View Complaints', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to network health
                },
                icon: Icon(Icons.network_check, color: Colors.white),
                label: Text('Network Health', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getHealthColor(int health) {
    if (health >= 90) return Colors.green;
    if (health >= 70) return Colors.orange;
    return Colors.red;
  }

  Color _getLatencyColor(int latency) {
    if (latency <= 50) return Colors.green;
    if (latency <= 100) return Colors.orange;
    return Colors.red;
  }

  Color _getTowerStatusColor(String status) {
    switch (status) {
      case 'healthy': return Colors.green;
      case 'warning': return Colors.orange;
      case 'critical': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _showAlertDetails(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(alert['icon'], color: alert['color']),
            SizedBox(width: 8),
            Expanded(child: Text(alert['title'], style: TextStyle(color: Colors.black))),
          ],
        ),
        content: Text(alert['message'], style: TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.blue)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle alert action
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('Take Action', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTowerDetails(Map<String, dynamic> tower) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Tower ${tower['id']}', style: TextStyle(color: Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location: ${tower['location']}', style: TextStyle(color: Colors.black)),
            Text('Signal Strength: ${tower['signal']}%', style: TextStyle(color: Colors.black)),
            Text('Status: ${tower['status']}', style: TextStyle(color: Colors.black)),
            SizedBox(height: 16),
            Text('Recent Metrics:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            Text('• Uptime: 99.5%', style: TextStyle(color: Colors.black87)),
            Text('• Data Throughput: 1.2 Gbps', style: TextStyle(color: Colors.black87)),
            Text('• Connected Users: 1,247', style: TextStyle(color: Colors.black87)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.blue)),
          ),
          if (tower['status'] != 'healthy')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Schedule maintenance
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text('Schedule Maintenance', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}