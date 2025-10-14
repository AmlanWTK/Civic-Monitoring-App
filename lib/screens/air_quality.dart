import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AirQualityScreen extends StatefulWidget {
  @override
  _AirQualityScreenState createState() => _AirQualityScreenState();
}

class _AirQualityScreenState extends State<AirQualityScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _measurements = [];
  List<dynamic> _filtered = [];
  bool _loading = false;
  String? _error;
  String _search = '';
  String _selectedParameter = 'All';
  
  late TabController _tabController;
  
  // OpenAQ API v3 via CORS proxy
  final String apiUrl = 'https://corsproxy.io/?https://api.openaq.org/v3/measurements?limit=100&sort=desc&order_by=datetime';
  
  final List<String> _parameters = ['All', 'pm25', 'pm10', 'o3', 'no2', 'so2', 'co'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchAirQuality();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchAirQuality() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _measurements = data['results'] ?? [];
          _filterData();
        });
      } else {
        setState(() {
          _error = 'Failed to load data: ${response.statusCode}';
          _useFallbackData();
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _useFallbackData();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _useFallbackData() {
    final sample = [
      {
        'parameter': 'pm25',
        'value': 75.5,
        'unit': 'µg/m³',
        'city': 'Dhaka',
        'country': 'BD',
        'coordinates': {'latitude': 23.8103, 'longitude': 90.4125},
        'lastUpdated': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
      },
      {
        'parameter': 'pm10',
        'value': 145.2,
        'unit': 'µg/m³',
        'city': 'Chittagong',
        'country': 'BD',
        'coordinates': {'latitude': 22.3569, 'longitude': 91.7832},
        'lastUpdated': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
      },
      {
        'parameter': 'o3',
        'value': 0.045,
        'unit': 'ppm',
        'city': 'Sylhet',
        'country': 'BD',
        'coordinates': {'latitude': 24.8949, 'longitude': 91.8687},
        'lastUpdated': DateTime.now().subtract(Duration(minutes: 30)).toIso8601String(),
      },
      {
        'parameter': 'pm25',
        'value': 55.8,
        'unit': 'µg/m³',
        'city': 'Khulna',
        'country': 'BD',
        'coordinates': {'latitude': 22.8456, 'longitude': 89.5403},
        'lastUpdated': DateTime.now().subtract(Duration(hours: 3)).toIso8601String(),
      },
      {
        'parameter': 'no2',
        'value': 0.035,
        'unit': 'ppm',
        'city': 'Rajshahi',
        'country': 'BD',
        'coordinates': {'latitude': 24.3745, 'longitude': 88.6042},
        'lastUpdated': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
      },
      {
        'parameter': 'so2',
        'value': 0.008,
        'unit': 'ppm',
        'city': 'Barisal',
        'country': 'BD',
        'coordinates': {'latitude': 22.7010, 'longitude': 90.3535},
        'lastUpdated': DateTime.now().subtract(Duration(minutes: 45)).toIso8601String(),
      },
      {
        'parameter': 'co',
        'value': 1.2,
        'unit': 'ppm',
        'city': 'Comilla',
        'country': 'BD',
        'coordinates': {'latitude': 23.4607, 'longitude': 91.1809},
        'lastUpdated': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
      },
    ];

    setState(() {
      _measurements = sample;
      _filterData();
      _error = null;
    });
  }

  void _filterData() {
    setState(() {
      _filtered = _measurements.where((m) {
        final city = (m['city'] ?? '').toString().toLowerCase();
        final country = (m['country'] ?? '').toString().toLowerCase();
        final parameter = (m['parameter'] ?? '').toString().toLowerCase();
        
        bool matchesSearch = _search.isEmpty || 
            city.contains(_search.toLowerCase()) || 
            country.contains(_search.toLowerCase());
            
        bool matchesParameter = _selectedParameter == 'All' || 
            parameter == _selectedParameter.toLowerCase();
            
        return matchesSearch && matchesParameter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Air Quality Monitoring'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.map), text: 'Map View'),
            Tab(icon: Icon(Icons.list), text: 'Data List'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchAirQuality,
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
            'Loading Air Quality Data...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Fetching latest measurements',
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
          child: _measurements.isEmpty
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
              hintText: 'Search by city or country...',
              prefixIcon: Icon(Icons.search),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _search = '';
                          _filterData();
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
                _search = value;
                _filterData();
              });
            },
          ),
          SizedBox(height: 12),
          // Parameter Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _parameters.map((param) {
                bool isSelected = _selectedParameter == param;
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(param.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedParameter = param;
                        _filterData();
                      });
                    },
                    backgroundColor: Theme.of(context).cardColor,
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    List<Marker> markers = _filtered.map((m) {
      final loc = m['coordinates'];
      if (loc == null) return null;
      
      final lat = loc['latitude']?.toDouble();
      final lon = loc['longitude']?.toDouble();
      
      if (lat == null || lon == null) return null;
      
      return Marker(
        width: 50.0,
        height: 50.0,
        point: LatLng(lat, lon),
        child: _buildMapMarker(m),
      );
    }).where((marker) => marker != null).cast<Marker>().toList();

    return FlutterMap(
      options: MapOptions(
        initialCenter: markers.isNotEmpty 
            ? markers[0].point 
            : LatLng(23.8103, 90.4125),
        initialZoom: markers.isNotEmpty ? 7.0 : 2.0,
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

  Widget _buildMapMarker(Map<String, dynamic> measurement) {
    Color markerColor = _getAQIColor(measurement);
    String parameter = measurement['parameter'] ?? '';
    
    return GestureDetector(
      onTap: () => _showMeasurementDetails(measurement),
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
            _getParameterIcon(parameter),
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
              'AQI Legend',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            SizedBox(height: 8),
            _buildLegendItem('Good', Colors.green),
            _buildLegendItem('Moderate', Colors.yellow),
            _buildLegendItem('Unhealthy', Colors.orange),
            _buildLegendItem('Hazardous', Colors.red),
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
    int totalMeasurements = _filtered.length;
    Map<String, int> parameterCounts = {};
    
    for (var m in _filtered) {
      String param = m['parameter'] ?? 'unknown';
      parameterCounts[param] = (parameterCounts[param] ?? 0) + 1;
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
            Text('Total: $totalMeasurements', style: TextStyle(fontSize: 10)),
            ...parameterCounts.entries.map((entry) =>
              Text('${entry.key.toUpperCase()}: ${entry.value}', 
                   style: TextStyle(fontSize: 10))
            ).toList(),
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
          child: _filtered.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    return _buildMeasurementCard(_filtered[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMeasurementCard(Map<String, dynamic> measurement) {
    Color aqiColor = _getAQIColor(measurement);
    String parameter = measurement['parameter'] ?? '';
    double value = (measurement['value'] ?? 0).toDouble();
    String unit = measurement['unit'] ?? '';
    String city = measurement['city'] ?? 'Unknown';
    String country = measurement['country'] ?? '';
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showMeasurementDetails(measurement),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: aqiColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  _getParameterIcon(parameter),
                  color: aqiColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          parameter.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: aqiColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getAQILabel(measurement),
                            style: TextStyle(
                              color: aqiColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$value $unit',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: aqiColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          '$city, $country',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        Spacer(),
                        Text(
                          _getTimeAgo(measurement['lastUpdated']),
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
          _buildParameterSummary(),
          SizedBox(height: 20),
          _buildLocationAnalysis(),
          SizedBox(height: 20),
          _buildHealthRecommendations(),
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
                        'Air Quality Analytics',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Environmental monitoring insights',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getOverallAQIColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Overall: ${_getOverallAQILabel()}',
                    style: TextStyle(
                      color: _getOverallAQIColor(),
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

  Widget _buildParameterSummary() {
    Map<String, List<double>> parameterValues = {};
    
    for (var m in _filtered) {
      String param = m['parameter'] ?? '';
      double value = (m['value'] ?? 0).toDouble();
      parameterValues.putIfAbsent(param, () => []).add(value);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parameter Summary',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
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
            childAspectRatio: 1.5,
          ),
          itemCount: parameterValues.length,
          itemBuilder: (context, index) {
            String param = parameterValues.keys.elementAt(index);
            List<double> values = parameterValues[param]!;
            double avgValue = values.reduce((a, b) => a + b) / values.length;
            
            return _buildParameterCard(param, avgValue, values.length);
          },
        ),
      ],
    );
  }

  Widget _buildParameterCard(String parameter, double avgValue, int count) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getParameterIcon(parameter),
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  parameter.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              avgValue.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              '$count measurements',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationAnalysis() {
    Map<String, List<Map<String, dynamic>>> locationData = {};
    
    for (var m in _filtered) {
      String city = m['city'] ?? 'Unknown';
      locationData.putIfAbsent(city, () => []).add(m);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location Analysis',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ...locationData.entries.map((entry) {
          return _buildLocationCard(entry.key, entry.value);
        }).toList(),
      ],
    );
  }

  Widget _buildLocationCard(String city, List<Map<String, dynamic>> measurements) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(Icons.location_city),
        title: Text(city),
        subtitle: Text('${measurements.length} measurements'),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: measurements.map((m) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text('${m['parameter']?.toString().toUpperCase() ?? ''}:'),
                      Spacer(),
                      Text(
                        '${m['value']} ${m['unit']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRecommendations() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Recommendations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ..._getHealthRecommendations().map((rec) {
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
          Icon(Icons.cloud_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No Air Quality Data',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            'No measurements found matching your criteria',
            style: TextStyle(color: Colors.grey[400]),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: fetchAirQuality,
            icon: Icon(Icons.refresh),
            label: Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getAQIColor(Map<String, dynamic> measurement) {
    String parameter = measurement['parameter'] ?? '';
    double value = (measurement['value'] ?? 0).toDouble();
    
    switch (parameter.toLowerCase()) {
      case 'pm25':
        if (value <= 12) return Colors.green;
        if (value <= 35.4) return Colors.yellow;
        if (value <= 55.4) return Colors.orange;
        return Colors.red;
      case 'pm10':
        if (value <= 54) return Colors.green;
        if (value <= 154) return Colors.yellow;
        if (value <= 254) return Colors.orange;
        return Colors.red;
      case 'o3':
        if (value <= 0.054) return Colors.green;
        if (value <= 0.070) return Colors.yellow;
        if (value <= 0.085) return Colors.orange;
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getAQILabel(Map<String, dynamic> measurement) {
    Color color = _getAQIColor(measurement);
    if (color == Colors.green) return 'GOOD';
    if (color == Colors.yellow) return 'MODERATE';
    if (color == Colors.orange) return 'UNHEALTHY';
    if (color == Colors.red) return 'HAZARDOUS';
    return 'UNKNOWN';
  }

  IconData _getParameterIcon(String parameter) {
    switch (parameter.toLowerCase()) {
      case 'pm25':
      case 'pm10':
        return Icons.grain;
      case 'o3':
        return Icons.blur_on;
      case 'no2':
        return Icons.local_gas_station;
      case 'so2':
        return Icons.factory;
      case 'co':
        return Icons.smoke_free;
      default:
        return Icons.cloud;
    }
  }

  Color _getOverallAQIColor() {
    if (_filtered.isEmpty) return Colors.grey;
    
    int hazardous = 0, unhealthy = 0, moderate = 0, good = 0;
    
    for (var m in _filtered) {
      String label = _getAQILabel(m);
      switch (label) {
        case 'HAZARDOUS': hazardous++; break;
        case 'UNHEALTHY': unhealthy++; break;
        case 'MODERATE': moderate++; break;
        case 'GOOD': good++; break;
      }
    }
    
    if (hazardous > 0) return Colors.red;
    if (unhealthy > 0) return Colors.orange;
    if (moderate > 0) return Colors.yellow;
    return Colors.green;
  }

  String _getOverallAQILabel() {
    Color color = _getOverallAQIColor();
    if (color == Colors.green) return 'GOOD';
    if (color == Colors.yellow) return 'MODERATE';
    if (color == Colors.orange) return 'UNHEALTHY';
    if (color == Colors.red) return 'HAZARDOUS';
    return 'UNKNOWN';
  }

  String _getTimeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    
    try {
      DateTime time = DateTime.parse(timestamp.toString());
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

  List<Map<String, dynamic>> _getHealthRecommendations() {
    String overallLevel = _getOverallAQILabel();
    
    switch (overallLevel) {
      case 'HAZARDOUS':
        return [
          {
            'icon': Icons.warning,
            'title': 'Stay Indoors',
            'description': 'Avoid outdoor activities. Keep windows and doors closed.',
            'color': Colors.red,
          },
          {
            'icon': Icons.masks,
            'title': 'Wear N95 Masks',
            'description': 'Use high-quality air filtration masks when going outside.',
            'color': Colors.red,
          },
        ];
      case 'UNHEALTHY':
        return [
          {
            'icon': Icons.directions_run,
            'title': 'Limit Outdoor Exercise',
            'description': 'Reduce prolonged or heavy outdoor activities.',
            'color': Colors.orange,
          },
          {
            'icon': Icons.masks,
            'title': 'Consider Masks',
            'description': 'Sensitive individuals should wear masks outdoors.',
            'color': Colors.orange,
          },
        ];
      case 'MODERATE':
        return [
          {
            'icon': Icons.accessibility,
            'title': 'Sensitive Groups Be Careful',
            'description': 'Children, elderly, and those with respiratory conditions should limit outdoor time.',
            'color': Colors.yellow,
          },
        ];
      default:
        return [
          {
            'icon': Icons.thumb_up,
            'title': 'Good Air Quality',
            'description': 'Air quality is satisfactory for most people.',
            'color': Colors.green,
          },
        ];
    }
  }

  void _showMeasurementDetails(Map<String, dynamic> measurement) {
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
                  Icon(_getParameterIcon(measurement['parameter']), size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${measurement['parameter']?.toString().toUpperCase() ?? ''} Measurement',
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
                      _buildDetailRow('Value', '${measurement['value']} ${measurement['unit']}'),
                      _buildDetailRow('Parameter', measurement['parameter']?.toString().toUpperCase() ?? ''),
                      _buildDetailRow('Location', '${measurement['city']}, ${measurement['country']}'),
                      _buildDetailRow('Quality Level', _getAQILabel(measurement)),
                      _buildDetailRow('Last Updated', _getTimeAgo(measurement['lastUpdated'])),
                      if (measurement['coordinates'] != null) ...[
                        _buildDetailRow('Coordinates', '${measurement['coordinates']['latitude']}, ${measurement['coordinates']['longitude']}'),
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