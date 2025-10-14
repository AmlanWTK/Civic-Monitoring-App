import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Enhanced Incident model with additional properties
class Incident {
  final String id;
  final String type;
  final String title;
  final double lat;
  final double lon;
  final DateTime? time;
  final String source;
  final String? url;
  final String severity;
  final String status;
  final String? description;

  Incident({
    required this.id,
    required this.type,
    required this.title,
    required this.lat,
    required this.lon,
    this.time,
    required this.source,
    this.url,
    this.severity = 'Medium',
    this.status = 'Active',
    this.description,
  });
}

class IncidentsScreen extends StatefulWidget {
  @override
  _IncidentsScreenState createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen>
    with SingleTickerProviderStateMixin {
  List<Incident> _incidents = [];
  List<Incident> _filteredIncidents = [];
  bool _loading = false;
  String? _error;
  String _searchQuery = '';
  
  late TabController _tabController;

  // Enhanced filters
  bool _bangladeshOnly = true;
  String _selectedSeverity = 'All';
  String _selectedSource = 'All';
  String _selectedTimeRange = 'All';
  
  final Map<String, bool> _typeFilters = {
    'Earthquake': true,
    'Tornado': true,
    'Cyclone': true,
    'Storm': true,
    'Flood': true,
    'Wildfire': true,
    'Volcano': true,
    'Landslide': true,
  };

  final List<String> _severityOptions = ['All', 'Low', 'Medium', 'High', 'Critical'];
  final List<String> _sourceOptions = ['All', 'USGS', 'EONET', 'GDACS'];
  final List<String> _timeRangeOptions = ['All', 'Last 24h', 'Last 7d', 'Last 30d'];

  // Bangladesh bounding box
  static const double _bdMinLat = 20.6;
  static const double _bdMaxLat = 26.7;
  static const double _bdMinLon = 88.0;
  static const double _bdMaxLon = 92.7;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchIncidents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _withinBangladesh(double lat, double lon) {
    return lat >= _bdMinLat && lat <= _bdMaxLat && lon >= _bdMinLon && lon <= _bdMaxLon;
  }

  Future<void> fetchIncidents() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Simulate API calls with fallback data
      await _loadFallbackData();
      _applyFilters();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadFallbackData() async {
    // Enhanced sample data with more realistic incident information
    final sampleIncidents = [
      Incident(
        id: 'EQ001',
        type: 'Earthquake',
        title: 'M 4.2 Earthquake - Chittagong Division',
        lat: 22.5,
        lon: 91.8,
        time: DateTime.now().subtract(Duration(hours: 2)),
        source: 'USGS',
        severity: 'Medium',
        status: 'Active',
        description: 'Moderate earthquake detected in Chittagong region. No significant damage reported.',
      ),
      Incident(
        id: 'CY001',
        type: 'Cyclone',
        title: 'Tropical Cyclone Formation - Bay of Bengal',
        lat: 21.0,
        lon: 92.0,
        time: DateTime.now().subtract(Duration(hours: 6)),
        source: 'EONET',
        severity: 'High',
        status: 'Active',
        description: 'Cyclonic storm forming in Bay of Bengal. Coastal areas advised to take precautions.',
      ),
      Incident(
        id: 'FL001',
        type: 'Flood',
        title: 'Flash Flood Warning - Sylhet Division',
        lat: 24.9,
        lon: 91.9,
        time: DateTime.now().subtract(Duration(hours: 12)),
        source: 'GDACS',
        severity: 'High',
        status: 'Active',
        description: 'Heavy monsoon rains causing flash floods in northeastern regions.',
      ),
      Incident(
        id: 'ST001',
        type: 'Storm',
        title: 'Severe Thunderstorm - Dhaka Metropolitan',
        lat: 23.8,
        lon: 90.4,
        time: DateTime.now().subtract(Duration(days: 1)),
        source: 'EONET',
        severity: 'Medium',
        status: 'Resolved',
        description: 'Severe thunderstorm with strong winds and heavy rain affected Dhaka area.',
      ),
      Incident(
        id: 'LS001',
        type: 'Landslide',
        title: 'Landslide Risk - Chittagong Hill Tracts',
        lat: 22.3,
        lon: 92.2,
        time: DateTime.now().subtract(Duration(days: 3)),
        source: 'GDACS',
        severity: 'Medium',
        status: 'Monitoring',
        description: 'Increased landslide risk due to continuous rainfall in hilly areas.',
      ),
      Incident(
        id: 'EQ002',
        type: 'Earthquake',
        title: 'M 3.8 Earthquake - Rangpur Division',
        lat: 25.7,
        lon: 89.2,
        time: DateTime.now().subtract(Duration(days: 5)),
        source: 'USGS',
        severity: 'Low',
        status: 'Resolved',
        description: 'Minor earthquake in northern Bangladesh. No damage reported.',
      ),
    ];

    setState(() {
      _incidents = sampleIncidents;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredIncidents = _incidents.where((incident) {
        // Location filter
        if (_bangladeshOnly && !_withinBangladesh(incident.lat, incident.lon)) {
          return false;
        }

        // Type filter
        if (!(_typeFilters[incident.type] ?? false)) {
          return false;
        }

        // Search filter
        if (_searchQuery.isNotEmpty) {
          String query = _searchQuery.toLowerCase();
          if (!incident.title.toLowerCase().contains(query) &&
              !incident.type.toLowerCase().contains(query) &&
              !incident.source.toLowerCase().contains(query)) {
            return false;
          }
        }

        // Severity filter
        if (_selectedSeverity != 'All' && incident.severity != _selectedSeverity) {
          return false;
        }

        // Source filter
        if (_selectedSource != 'All' && incident.source != _selectedSource) {
          return false;
        }

        // Time range filter
        if (_selectedTimeRange != 'All' && incident.time != null) {
          DateTime now = DateTime.now();
          Duration difference = now.difference(incident.time!);
          
          switch (_selectedTimeRange) {
            case 'Last 24h':
              if (difference.inHours > 24) return false;
              break;
            case 'Last 7d':
              if (difference.inDays > 7) return false;
              break;
            case 'Last 30d':
              if (difference.inDays > 30) return false;
              break;
          }
        }

        return true;
      }).toList();

      // Sort by time (most recent first)
      _filteredIncidents.sort((a, b) {
        if (a.time == null && b.time == null) return 0;
        if (a.time == null) return 1;
        if (b.time == null) return -1;
        return b.time!.compareTo(a.time!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disaster Incidents'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.map), text: 'Map View'),
            Tab(icon: Icon(Icons.list), text: 'Incident List'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchIncidents,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? _buildLoadingState()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMapView(),
                _buildListView(),
                _buildAnalyticsView(),
              ],
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(strokeWidth: 3),
          SizedBox(height: 20),
          Text(
            'Loading Incident Data...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Fetching latest disaster information',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Column(
      children: [
        _buildControlsHeader(),
        Expanded(
          child: _filteredIncidents.isEmpty
              ? _buildEmptyState()
              : Stack(
                  children: [
                    _buildMap(),
                    _buildMapOverlay(),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildControlsHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search incidents...',
              prefixIcon: Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _applyFilters();
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _applyFilters();
              });
            },
          ),
          SizedBox(height: 12),
          // Filter Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: Text('Bangladesh Only'),
                  selected: _bangladeshOnly,
                  onSelected: (value) {
                    setState(() {
                      _bangladeshOnly = value;
                      _applyFilters();
                    });
                  },
                ),
                SizedBox(width: 8),
                _buildFilterDropdown('Severity', _selectedSeverity, _severityOptions, (value) {
                  setState(() {
                    _selectedSeverity = value!;
                    _applyFilters();
                  });
                }),
                SizedBox(width: 8),
                _buildFilterDropdown('Source', _selectedSource, _sourceOptions, (value) {
                  setState(() {
                    _selectedSource = value!;
                    _applyFilters();
                  });
                }),
                SizedBox(width: 8),
                _buildFilterDropdown('Time', _selectedTimeRange, _timeRangeOptions, (value) {
                  setState(() {
                    _selectedTimeRange = value!;
                    _applyFilters();
                  });
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option, style: TextStyle(fontSize: 12)),
          );
        }).toList(),
        onChanged: onChanged,
        underline: SizedBox(),
        isDense: true,
      ),
    );
  }

  Widget _buildMap() {
    List<Marker> markers = _filteredIncidents.map((incident) {
      return Marker(
        width: 50.0,
        height: 50.0,
        point: LatLng(incident.lat, incident.lon),
        child: _buildIncidentMarker(incident),
      );
    }).toList();

    LatLng center = markers.isNotEmpty 
        ? markers.first.point 
        : LatLng(23.8103, 90.4125);

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: _bangladeshOnly ? 7.0 : 3.0,
        maxZoom: 18,
        minZoom: 2,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.civic_app_4',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  Widget _buildIncidentMarker(Incident incident) {
    Color markerColor = _getSeverityColor(incident.severity);
    IconData markerIcon = _getIncidentIcon(incident.type);
    
    return GestureDetector(
      onTap: () => _showIncidentDetails(incident),
      child: Container(
        decoration: BoxDecoration(
          color: markerColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: markerColor.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            markerIcon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildMapOverlay() {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          _buildLegendCard(),
          SizedBox(height: 12),
          _buildStatsCard(),
        ],
      ),
    );
  }

  Widget _buildLegendCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Severity Legend',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            SizedBox(height: 8),
            _buildLegendItem('Critical', Colors.red),
            _buildLegendItem('High', Colors.orange),
            _buildLegendItem('Medium', Colors.yellow),
            _buildLegendItem('Low', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    Map<String, int> severityStats = {};
    Map<String, int> typeStats = {};
    
    for (var incident in _filteredIncidents) {
      severityStats[incident.severity] = (severityStats[incident.severity] ?? 0) + 1;
      typeStats[incident.type] = (typeStats[incident.type] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Statistics',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            SizedBox(height: 8),
            Text('Total: ${_filteredIncidents.length}', style: TextStyle(fontSize: 10)),
            if (severityStats.isNotEmpty) ...[
              SizedBox(height: 4),
              ...severityStats.entries.map((entry) =>
                Text('${entry.key}: ${entry.value}', style: TextStyle(fontSize: 10))
              ).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return Column(
      children: [
        _buildControlsHeader(),
        Expanded(
          child: _filteredIncidents.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _filteredIncidents.length,
                  itemBuilder: (context, index) {
                    return _buildIncidentCard(_filteredIncidents[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildIncidentCard(Incident incident) {
    Color severityColor = _getSeverityColor(incident.severity);
    IconData typeIcon = _getIncidentIcon(incident.type);
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showIncidentDetails(incident),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      typeIcon,
                      color: severityColor,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          incident.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: severityColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                incident.severity.toUpperCase(),
                                style: TextStyle(
                                  color: severityColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(incident.status).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                incident.status.toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(incident.status),
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
                ],
              ),
              SizedBox(height: 12),
              if (incident.description != null) ...[
                Text(
                  incident.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
              ],
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    '${incident.lat.toStringAsFixed(3)}, ${incident.lon.toStringAsFixed(3)}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  Spacer(),
                  Text(
                    incident.source,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    _getTimeAgo(incident.time),
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 10,
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

  Widget _buildAnalyticsView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalyticsHeader(),
          SizedBox(height: 20),
          _buildSeverityAnalysis(),
          SizedBox(height: 20),
          _buildTypeAnalysis(),
          SizedBox(height: 20),
          _buildTimelineAnalysis(),
          SizedBox(height: 20),
          _buildRecommendations(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsHeader() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, size: 32, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Incident Analytics',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Disaster monitoring and analysis',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getOverallRiskColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Risk: ${_getOverallRiskLevel()}',
                    style: TextStyle(
                      color: _getOverallRiskColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityAnalysis() {
    Map<String, int> severityStats = {};
    for (var incident in _filteredIncidents) {
      severityStats[incident.severity] = (severityStats[incident.severity] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Severity Distribution',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: severityStats.entries.map((entry) {
            return _buildAnalyticsCard(
              entry.key,
              '${entry.value}',
              _getSeverityColor(entry.key),
              _getSeverityIcon(entry.key),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeAnalysis() {
    Map<String, int> typeStats = {};
    for (var incident in _filteredIncidents) {
      typeStats[incident.type] = (typeStats[incident.type] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Incident Types',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ...typeStats.entries.map((entry) {
          double percentage = (entry.value / _filteredIncidents.length) * 100;
          return _buildTypeItem(entry.key, entry.value, percentage);
        }).toList(),
      ],
    );
  }

  Widget _buildTypeItem(String type, int count, double percentage) {
    Color typeColor = _getTypeColor(type);
    
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(_getIncidentIcon(type), color: typeColor),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    color: typeColor,
                    backgroundColor: typeColor.withOpacity(0.2),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Text(
              '$count (${percentage.toInt()}%)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: typeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineAnalysis() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Timeline',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ..._filteredIncidents.take(5).map((incident) {
              return _buildTimelineItem(incident);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(Incident incident) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getSeverityColor(incident.severity).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getSeverityColor(incident.severity).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIncidentIcon(incident.type),
            color: _getSeverityColor(incident.severity),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  incident.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  _getTimeAgo(incident.time),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getSeverityColor(incident.severity).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              incident.severity,
              style: TextStyle(
                color: _getSeverityColor(incident.severity),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emergency Recommendations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ..._getEmergencyRecommendations().map((rec) {
              return _buildRecommendationItem(rec['icon'], rec['title'], rec['description'], rec['color']);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(IconData icon, String title, String description, Color color) {
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
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.report_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No Incidents Found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            'No incidents match your current filters',
            style: TextStyle(color: Colors.grey[400]),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: fetchIncidents,
            icon: Icon(Icons.refresh),
            label: Text('Refresh'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getIncidentIcon(String type) {
    switch (type) {
      case 'Earthquake':
        return Icons.public;
      case 'Tornado':
        return Icons.air;
      case 'Cyclone':
        return Icons.waves;
      case 'Storm':
        return Icons.thunderstorm;
      case 'Flood':
        return Icons.waves;
      case 'Wildfire':
        return Icons.local_fire_department;
      case 'Volcano':
        return Icons.landscape;
      case 'Landslide':
        return Icons.terrain;
      default:
        return Icons.warning;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Critical':
        return Colors.red;
      case 'High':
        return Colors.orange;
      case 'Medium':
        return Colors.yellow;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'Critical':
        return Icons.error;
      case 'High':
        return Icons.warning;
      case 'Medium':
        return Icons.info;
      case 'Low':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.red;
      case 'Monitoring':
        return Colors.orange;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Earthquake':
        return Colors.brown;
      case 'Cyclone':
        return Colors.blue;
      case 'Flood':
        return Colors.cyan;
      case 'Storm':
        return Colors.purple;
      case 'Wildfire':
        return Colors.orange;
      case 'Landslide':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getOverallRiskColor() {
    if (_filteredIncidents.isEmpty) return Colors.grey;
    
    int criticalCount = _filteredIncidents.where((i) => i.severity == 'Critical').length;
    int highCount = _filteredIncidents.where((i) => i.severity == 'High').length;
    
    if (criticalCount > 0) return Colors.red;
    if (highCount > 1) return Colors.orange;
    return Colors.green;
  }

  String _getOverallRiskLevel() {
    Color color = _getOverallRiskColor();
    if (color == Colors.red) return 'HIGH';
    if (color == Colors.orange) return 'MEDIUM';
    if (color == Colors.green) return 'LOW';
    return 'UNKNOWN';
  }

  String _getTimeAgo(DateTime? timestamp) {
    if (timestamp == null) return 'Unknown';
    
    Duration difference = DateTime.now().difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  List<Map<String, dynamic>> _getEmergencyRecommendations() {
    String riskLevel = _getOverallRiskLevel();
    
    switch (riskLevel) {
      case 'HIGH':
        return [
          {
            'icon': Icons.warning,
            'title': 'Emergency Alert',
            'description': 'Multiple critical incidents detected. Follow emergency protocols.',
            'color': Colors.red,
          },
          {
            'icon': Icons.phone,
            'title': 'Contact Authorities',
            'description': 'Immediately contact local emergency services and disaster management.',
            'color': Colors.red,
          },
        ];
      case 'MEDIUM':
        return [
          {
            'icon': Icons.visibility,
            'title': 'Stay Alert',
            'description': 'Monitor situation closely and be prepared for emergency actions.',
            'color': Colors.orange,
          },
          {
            'icon': Icons.inventory,
            'title': 'Emergency Kit',
            'description': 'Ensure emergency supplies are readily available.',
            'color': Colors.orange,
          },
        ];
      default:
        return [
          {
            'icon': Icons.check_circle,
            'title': 'Normal Conditions',
            'description': 'Current incident levels are within normal parameters.',
            'color': Colors.green,
          },
          {
            'icon': Icons.update,
            'title': 'Stay Informed',
            'description': 'Continue monitoring for any changes in conditions.',
            'color': Colors.blue,
          },
        ];
    }
  }

  void _showIncidentDetails(Incident incident) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_getIncidentIcon(incident.type), size: 32, color: _getSeverityColor(incident.severity)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Incident Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
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
                      _buildDetailRow('Title', incident.title),
                      _buildDetailRow('Type', incident.type),
                      _buildDetailRow('Severity', incident.severity),
                      _buildDetailRow('Status', incident.status),
                      _buildDetailRow('Source', incident.source),
                      _buildDetailRow('Location', '${incident.lat.toStringAsFixed(4)}, ${incident.lon.toStringAsFixed(4)}'),
                      _buildDetailRow('Time', incident.time?.toString() ?? 'Unknown'),
                      if (incident.description != null) ...[
                        SizedBox(height: 16),
                        Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(incident.description!),
                      ],
                      if (incident.url != null) ...[
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Open URL
                          },
                          icon: Icon(Icons.open_in_new),
                          label: Text('More Information'),
                        ),
                      ],
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
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}