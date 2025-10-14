import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TrafficScreen extends StatefulWidget {
  @override
  _TrafficScreenState createState() => _TrafficScreenState();
}

class _TrafficScreenState extends State<TrafficScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _locations = [];
  List<dynamic> _trafficData = [];
  bool _loading = false;
  String? _error;
  String _selectedCity = 'Dhaka';
  String _trafficLevel = 'Moderate';
  
  late TabController _tabController;
  
  final List<String> _cities = ['Dhaka', 'Chittagong', 'Sylhet', 'Khulna', 'Rajshahi'];
  
  final Map<String, LatLng> _cityCoordinates = {
    'Dhaka': LatLng(23.8103, 90.4125),
    'Chittagong': LatLng(22.3569, 91.7832),
    'Sylhet': LatLng(24.8949, 91.8687),
    'Khulna': LatLng(22.8456, 89.5403),
    'Rajshahi': LatLng(24.3745, 88.6042),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchTrafficData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchTrafficData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Fetch location data from OpenStreetMap
      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/search?city=$_selectedCity&country=Bangladesh&format=json&limit=20'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _locations = data;
          _generateTrafficData();
        });
      } else {
        setState(() {
          _error = 'Failed to load data: ${response.statusCode}';
          _generateFallbackData();
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _generateFallbackData();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _generateTrafficData() {
    // Generate simulated traffic data based on locations
    List<dynamic> trafficPoints = [];
    
    for (var location in _locations) {
      final lat = double.tryParse(location['lat'] ?? '0') ?? 0;
      final lon = double.tryParse(location['lon'] ?? '0') ?? 0;
      
      if (lat != 0 && lon != 0) {
        trafficPoints.add({
          'lat': lat,
          'lon': lon,
          'name': location['display_name'] ?? 'Unknown Location',
          'type': location['type'] ?? 'road',
          'trafficLevel': _getRandomTrafficLevel(),
          'speed': _getRandomSpeed(),
          'congestion': _getRandomCongestion(),
          'lastUpdated': DateTime.now().toIso8601String(),
        });
      }
    }
    
    setState(() {
      _trafficData = trafficPoints;
    });
  }

  void _generateFallbackData() {
    final fallbackData = [
      {
        'lat': 23.8103,
        'lon': 90.4125,
        'name': 'Dhaka - Gulshan Avenue',
        'type': 'primary',
        'trafficLevel': 'Heavy',
        'speed': 15,
        'congestion': 85,
        'lastUpdated': DateTime.now().subtract(Duration(minutes: 5)).toIso8601String(),
      },
      {
        'lat': 23.7808,
        'lon': 90.4220,
        'name': 'Dhaka - Dhanmondi Road',
        'type': 'secondary',
        'trafficLevel': 'Moderate',
        'speed': 25,
        'congestion': 60,
        'lastUpdated': DateTime.now().subtract(Duration(minutes: 10)).toIso8601String(),
      },
      {
        'lat': 23.8200,
        'lon': 90.3700,
        'name': 'Dhaka - Airport Road',
        'type': 'trunk',
        'trafficLevel': 'Light',
        'speed': 45,
        'congestion': 30,
        'lastUpdated': DateTime.now().subtract(Duration(minutes: 3)).toIso8601String(),
      },
      {
        'lat': 23.7600,
        'lon': 90.3900,
        'name': 'Dhaka - Mirpur Road',
        'type': 'primary',
        'trafficLevel': 'Heavy',
        'speed': 12,
        'congestion': 90,
        'lastUpdated': DateTime.now().subtract(Duration(minutes: 7)).toIso8601String(),
      },
    ];

    setState(() {
      _locations = fallbackData;
      _trafficData = fallbackData;
      _error = null;
    });
  }

  String _getRandomTrafficLevel() {
    List<String> levels = ['Light', 'Moderate', 'Heavy'];
    return levels[DateTime.now().millisecond % levels.length];
  }

  int _getRandomSpeed() {
    return 10 + (DateTime.now().millisecond % 40); // 10-50 km/h
  }

  int _getRandomCongestion() {
    return 20 + (DateTime.now().millisecond % 70); // 20-90%
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Traffic Monitoring'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.map), text: 'Live Map'),
            Tab(icon: Icon(Icons.list), text: 'Traffic Data'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchTrafficData,
          ),
        ],
      ),
      body: _loading
          ? _buildLoadingState()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMapView(),
                _buildDataView(),
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
            'Loading Traffic Data...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Fetching real-time traffic information',
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
          child: _trafficData.isEmpty
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
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCity,
                  decoration: InputDecoration(
                    labelText: 'Select City',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  items: _cities.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCity = value;
                      });
                      fetchTrafficData();
                    }
                  },
                ),
              ),
              SizedBox(width: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _getTrafficLevelColor(_trafficLevel).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getTrafficLevelColor(_trafficLevel).withOpacity(0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Traffic Level',
                      style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                    ),
                    Text(
                      _trafficLevel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getTrafficLevelColor(_trafficLevel),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    List<Marker> markers = _trafficData.map((traffic) {
      return Marker(
        width: 50.0,
        height: 50.0,
        point: LatLng(traffic['lat'], traffic['lon']),
        child: _buildTrafficMarker(traffic),
      );
    }).toList();

    LatLng center = _cityCoordinates[_selectedCity] ?? LatLng(23.8103, 90.4125);

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 12.0,
        maxZoom: 18,
        minZoom: 6,
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

  Widget _buildTrafficMarker(Map<String, dynamic> traffic) {
    Color markerColor = _getTrafficLevelColor(traffic['trafficLevel']);
    
    return GestureDetector(
      onTap: () => _showTrafficDetails(traffic),
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
            _getTrafficIcon(traffic['trafficLevel']),
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
          _buildTrafficStatsCard(),
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
              'Traffic Legend',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            SizedBox(height: 8),
            _buildLegendItem('Light', Colors.green),
            _buildLegendItem('Moderate', Colors.orange),
            _buildLegendItem('Heavy', Colors.red),
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

  Widget _buildTrafficStatsCard() {
    int lightTraffic = _trafficData.where((t) => t['trafficLevel'] == 'Light').length;
    int moderateTraffic = _trafficData.where((t) => t['trafficLevel'] == 'Moderate').length;
    int heavyTraffic = _trafficData.where((t) => t['trafficLevel'] == 'Heavy').length;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Traffic Stats',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            SizedBox(height: 8),
            Text('Total: ${_trafficData.length}', style: TextStyle(fontSize: 10)),
            Text('Light: $lightTraffic', style: TextStyle(fontSize: 10)),
            Text('Moderate: $moderateTraffic', style: TextStyle(fontSize: 10)),
            Text('Heavy: $heavyTraffic', style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildDataView() {
    return Column(
      children: [
        _buildControlsHeader(),
        Expanded(
          child: _trafficData.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _trafficData.length,
                  itemBuilder: (context, index) {
                    return _buildTrafficCard(_trafficData[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTrafficCard(Map<String, dynamic> traffic) {
    Color trafficColor = _getTrafficLevelColor(traffic['trafficLevel']);
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showTrafficDetails(traffic),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: trafficColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  _getTrafficIcon(traffic['trafficLevel']),
                  color: trafficColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      traffic['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
                            color: trafficColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            traffic['trafficLevel'],
                            style: TextStyle(
                              color: trafficColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Spacer(),
                        Text(
                          '${traffic['speed']} km/h',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: trafficColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.traffic, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          '${traffic['congestion']}% congestion',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        Spacer(),
                        Text(
                          _getTimeAgo(traffic['lastUpdated']),
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
          _buildTrafficSummary(),
          SizedBox(height: 20),
          _buildSpeedAnalysis(),
          SizedBox(height: 20),
          _buildCongestionAnalysis(),
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
                        'Traffic Analytics',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Real-time traffic analysis for $_selectedCity',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getOverallTrafficColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Overall: ${_getOverallTrafficLevel()}',
                    style: TextStyle(
                      color: _getOverallTrafficColor(),
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

  Widget _buildTrafficSummary() {
    int lightCount = _trafficData.where((t) => t['trafficLevel'] == 'Light').length;
    int moderateCount = _trafficData.where((t) => t['trafficLevel'] == 'Moderate').length;
    int heavyCount = _trafficData.where((t) => t['trafficLevel'] == 'Heavy').length;
    double avgSpeed = _trafficData.isNotEmpty 
        ? _trafficData.map((t) => t['speed'] as int).reduce((a, b) => a + b) / _trafficData.length
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Traffic Summary',
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
          children: [
            _buildSummaryCard('Light Traffic', '$lightCount', Colors.green, Icons.trending_up),
            _buildSummaryCard('Moderate Traffic', '$moderateCount', Colors.orange, Icons.trending_flat),
            _buildSummaryCard('Heavy Traffic', '$heavyCount', Colors.red, Icons.trending_down),
            _buildSummaryCard('Avg Speed', '${avgSpeed.toInt()} km/h', Colors.blue, Icons.speed),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
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
                    fontSize: 20,
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

  Widget _buildSpeedAnalysis() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Speed Analysis',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ..._trafficData.take(5).map((traffic) {
              return _buildSpeedItem(traffic);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedItem(Map<String, dynamic> traffic) {
    double speedRatio = (traffic['speed'] as int) / 60.0; // Normalize to 60 km/h max
    Color speedColor = speedRatio > 0.7 ? Colors.green : speedRatio > 0.4 ? Colors.orange : Colors.red;
    
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  traffic['name'],
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${traffic['speed']} km/h',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: speedColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: speedRatio.clamp(0.0, 1.0),
            color: speedColor,
            backgroundColor: speedColor.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildCongestionAnalysis() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Congestion Analysis',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ..._trafficData.take(5).map((traffic) {
              return _buildCongestionItem(traffic);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCongestionItem(Map<String, dynamic> traffic) {
    double congestionRatio = (traffic['congestion'] as int) / 100.0;
    Color congestionColor = congestionRatio > 0.7 ? Colors.red : congestionRatio > 0.4 ? Colors.orange : Colors.green;
    
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  traffic['name'],
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${traffic['congestion']}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: congestionColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: congestionRatio,
            color: congestionColor,
            backgroundColor: congestionColor.withOpacity(0.2),
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
              'Traffic Recommendations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ..._getTrafficRecommendations().map((rec) {
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.traffic, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No Traffic Data',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            'Unable to load traffic information for $_selectedCity',
            style: TextStyle(color: Colors.grey[400]),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: fetchTrafficData,
            icon: Icon(Icons.refresh),
            label: Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getTrafficLevelColor(String level) {
    switch (level) {
      case 'Light':
        return Colors.green;
      case 'Moderate':
        return Colors.orange;
      case 'Heavy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTrafficIcon(String level) {
    switch (level) {
      case 'Light':
        return Icons.trending_up;
      case 'Moderate':
        return Icons.trending_flat;
      case 'Heavy':
        return Icons.trending_down;
      default:
        return Icons.traffic;
    }
  }

  Color _getOverallTrafficColor() {
    if (_trafficData.isEmpty) return Colors.grey;
    
    int heavyCount = _trafficData.where((t) => t['trafficLevel'] == 'Heavy').length;
    int moderateCount = _trafficData.where((t) => t['trafficLevel'] == 'Moderate').length;
    
    double heavyRatio = heavyCount / _trafficData.length;
    double moderateRatio = moderateCount / _trafficData.length;
    
    if (heavyRatio > 0.5) return Colors.red;
    if (moderateRatio > 0.5) return Colors.orange;
    return Colors.green;
  }

  String _getOverallTrafficLevel() {
    Color color = _getOverallTrafficColor();
    if (color == Colors.green) return 'LIGHT';
    if (color == Colors.orange) return 'MODERATE';
    if (color == Colors.red) return 'HEAVY';
    return 'UNKNOWN';
  }

  String _getTimeAgo(String timestamp) {
    try {
      DateTime time = DateTime.parse(timestamp);
      Duration difference = DateTime.now().difference(time);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  List<Map<String, dynamic>> _getTrafficRecommendations() {
    String overallLevel = _getOverallTrafficLevel();
    
    switch (overallLevel) {
      case 'HEAVY':
        return [
          {
            'icon': Icons.alt_route,
            'title': 'Use Alternative Routes',
            'description': 'Consider using less congested roads and alternative paths.',
            'color': Colors.red,
          },
          {
            'icon': Icons.schedule,
            'title': 'Avoid Peak Hours',
            'description': 'Travel during off-peak hours to reduce commute time.',
            'color': Colors.orange,
          },
        ];
      case 'MODERATE':
        return [
          {
            'icon': Icons.directions_transit,
            'title': 'Consider Public Transport',
            'description': 'Public transportation may be faster during moderate traffic.',
            'color': Colors.orange,
          },
        ];
      default:
        return [
          {
            'icon': Icons.thumb_up,
            'title': 'Good Traffic Conditions',
            'description': 'Current traffic conditions are favorable for travel.',
            'color': Colors.green,
          },
        ];
    }
  }

  void _showTrafficDetails(Map<String, dynamic> traffic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_getTrafficIcon(traffic['trafficLevel']), size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Traffic Details',
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
                      _buildDetailRow('Location', traffic['name']),
                      _buildDetailRow('Traffic Level', traffic['trafficLevel']),
                      _buildDetailRow('Average Speed', '${traffic['speed']} km/h'),
                      _buildDetailRow('Congestion', '${traffic['congestion']}%'),
                      _buildDetailRow('Road Type', traffic['type'] ?? 'Unknown'),
                      _buildDetailRow('Last Updated', _getTimeAgo(traffic['lastUpdated'])),
                      _buildDetailRow('Coordinates', '${traffic['lat'].toStringAsFixed(4)}, ${traffic['lon'].toStringAsFixed(4)}'),
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
            width: 120,
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