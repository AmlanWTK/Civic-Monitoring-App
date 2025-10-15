import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class SatelliteScreen extends StatefulWidget {
  @override
  _SatelliteScreenState createState() => _SatelliteScreenState();
}

class _SatelliteScreenState extends State<SatelliteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  String _selectedLayer = 'BlueMarble_ShadedRelief';
  double _currentZoom = 7.0;
  LatLng _currentCenter = LatLng(23.8103, 90.4125); // Dhaka, Bangladesh
  
  final Map<String, Map<String, String>> _satelliteLayers = {
    'BlueMarble_ShadedRelief': {
      'name': 'Blue Marble',
      'description': 'Natural Earth satellite imagery',
      'url': 'https://gibs.earthdata.nasa.gov/wmts/epsg3857/best/BlueMarble_ShadedRelief/default/2023-01-01/GoogleMapsCompatible_Level8/{z}/{y}/{x}.jpg',
    },
    'MODIS_Aqua_CorrectedReflectance_TrueColor': {
      'name': 'MODIS True Color',
      'description': 'Recent satellite imagery from MODIS Aqua',
      'url': 'https://gibs.earthdata.nasa.gov/wmts/epsg3857/best/MODIS_Aqua_CorrectedReflectance_TrueColor/default/{time}/GoogleMapsCompatible_Level9/{z}/{y}/{x}.jpg',
    },
    'MODIS_Terra_CorrectedReflectance_TrueColor': {
      'name': 'MODIS Terra',
      'description': 'High-resolution Terra satellite imagery',
      'url': 'https://gibs.earthdata.nasa.gov/wmts/epsg3857/best/MODIS_Terra_CorrectedReflectance_TrueColor/default/{time}/GoogleMapsCompatible_Level9/{z}/{y}/{x}.jpg',
    },
    'VIIRS_SNPP_DayNightBand_ENCC': {
      'name': 'Night Lights',
      'description': 'Nighttime lights from VIIRS satellite',
      'url': 'https://gibs.earthdata.nasa.gov/wmts/epsg3857/best/VIIRS_SNPP_DayNightBand_ENCC/default/{time}/GoogleMapsCompatible_Level8/{z}/{y}/{x}.png',
    },
  };

  final List<Map<String, dynamic>> _pointsOfInterest = [
    {
      'name': 'Dhaka',
      'description': 'Capital city of Bangladesh',
      'lat': 23.8103,
      'lon': 90.4125,
      'type': 'city',
      'icon': Icons.location_city,
    },
    {
      'name': 'Chittagong Port',
      'description': 'Major seaport and commercial hub',
      'lat': 22.3569,
      'lon': 91.7832,
      'type': 'port',
      'icon': Icons.directions_boat,
    },
    {
      'name': 'Sundarbans',
      'description': 'Largest mangrove forest in the world',
      'lat': 21.9497,
      'lon': 89.1833,
      'type': 'forest',
      'icon': Icons.park,
    },
    {
      'name': 'Cox\'s Bazar',
      'description': 'Longest sea beach in the world',
      'lat': 21.4272,
      'lon': 92.0058,
      'type': 'beach',
      'icon': Icons.beach_access,
    },
    {
      'name': 'Sylhet Tea Gardens',
      'description': 'Famous tea plantation region',
      'lat': 24.8949,
      'lon': 91.8687,
      'type': 'agriculture',
      'icon': Icons.eco,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getCurrentDate() {
    DateTime now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _getLayerUrl(String layerKey) {
    String baseUrl = _satelliteLayers[layerKey]!['url']!;
    return baseUrl.replaceAll('{time}', _getCurrentDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Satellite Imagery',style: GoogleFonts.playfairDisplaySc(fontWeight: FontWeight.bold,fontSize: 25, color: Colors.blueGrey),),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.satellite), text: 'Live View'),
            Tab(icon: Icon(Icons.layers), text: 'Layers'),
            Tab(icon: Icon(Icons.place), text: 'Points of Interest'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: _centerOnBangladesh,
            tooltip: 'Center on Bangladesh',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSatelliteView(),
          _buildLayersView(),
          _buildPointsOfInterestView(),
        ],
      ),
    );
  }

  Widget _buildSatelliteView() {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: _currentCenter,
            initialZoom: _currentZoom,
            maxZoom: 18,
            minZoom: 2,
            onPositionChanged: (position, hasGesture) {
              if (hasGesture) {
                setState(() {
                  _currentCenter = position.center!;
                  _currentZoom = position.zoom!;
                });
              }
            },
          ),
          children: [
            TileLayer(
  urlTemplate: _getLayerUrl(_selectedLayer),
  userAgentPackageName: 'com.example.civic_app_4',
  tileProvider: NetworkTileProvider(),
  errorTileCallback: (tile, error, stackTrace) {
    print('Tile failed to load: $error');
  },
  errorImage: const AssetImage('assets/fallback_tile.png'),
),

            MarkerLayer(
              markers: _pointsOfInterest
                  .map((poi) => Marker(
                        width: 40.0,
                        height: 40.0,
                        point: LatLng(poi['lat'], poi['lon']),
                        child: GestureDetector(
                          onTap: () => _showPOIDetails(poi),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              poi['icon'],
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
        _buildMapControls(),
        _buildInformationPanel(),
      ],
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      top: 16,
      left: 16,
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Satellite Layer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _selectedLayer,
                    isDense: true,
                    underline: SizedBox(),
                    items: _satelliteLayers.entries
                        .map((entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text(
                                entry.value['name']!,
                                style: TextStyle(fontSize: 12),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedLayer = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentZoom = (_currentZoom + 1).clamp(2.0, 18.0);
                    });
                  },
                  icon: Icon(Icons.add),
                  tooltip: 'Zoom In',
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentZoom = (_currentZoom - 1).clamp(2.0, 18.0);
                    });
                  },
                  icon: Icon(Icons.remove),
                  tooltip: 'Zoom Out',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationPanel() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.satellite, color: Theme.of(context).primaryColor),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _satelliteLayers[_selectedLayer]!['name']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _satelliteLayers[_selectedLayer]!['description']!,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip('Zoom', '${_currentZoom.toStringAsFixed(1)}x'),
                  SizedBox(width: 8),
                  _buildInfoChip('Lat', '${_currentCenter.latitude.toStringAsFixed(4)}°'),
                  SizedBox(width: 8),
                  _buildInfoChip('Lon', '${_currentCenter.longitude.toStringAsFixed(4)}°'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLayersView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLayersHeader(),
          SizedBox(height: 20),
          _buildLayersList(),
          SizedBox(height: 20),
          _buildLayerInformation(),
        ],
      ),
    );
  }

  Widget _buildLayersHeader() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.layers, size: 32, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Satellite Layers',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Choose from different satellite data sources',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Live Data',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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

  Widget _buildLayersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Layers',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ..._satelliteLayers.entries.map((entry) {
          return _buildLayerCard(entry.key, entry.value);
        }).toList(),
      ],
    );
  }



  Widget _buildLayerCard(String layerKey, Map<String, String> layerInfo) {
    bool isSelected = _selectedLayer == layerKey;
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 2,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedLayer = layerKey;
            if (_tabController.index >= 0 && _tabController.index < _tabController.length) {
  _tabController.animateTo(0);
}
 // Switch to satellite view
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).primaryColor.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  _getLayerIcon(layerKey),
                  color: isSelected 
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      layerInfo['name']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isSelected 
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      layerInfo['description']!,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLayerInformation() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Layer Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildInfoItem(
              Icons.update,
              'Data Source',
              'NASA Worldview GIBS',
              'Global Imagery Browse Services providing real-time satellite data',
            ),
            _buildInfoItem(
              Icons.schedule,
              'Update Frequency',
              'Daily',
              'Satellite imagery is updated daily with the latest available data',
            ),
            _buildInfoItem(
              Icons.photo_camera,
              'Resolution',
              'Up to 250m/pixel',
              'High-resolution imagery suitable for detailed geographical analysis',
            ),
            _buildInfoItem(
              Icons.public,
              'Coverage',
              'Global',
              'Worldwide satellite coverage including all regions of Bangladesh',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Spacer(),
                    Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsOfInterestView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPOIHeader(),
          SizedBox(height: 20),
          _buildPOIList(),
        ],
      ),
    );
  }

  Widget _buildPOIHeader() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.place, size: 32, color: Colors.green),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Points of Interest',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Notable locations in Bangladesh',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_pointsOfInterest.length} Locations',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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

  Widget _buildPOIList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Locations',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ..._pointsOfInterest.map((poi) {
          return _buildPOICard(poi);
        }).toList(),
      ],
    );
  }

  Widget _buildPOICard(Map<String, dynamic> poi) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToPOI(poi),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getPOIColor(poi['type']).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  poi['icon'],
                  color: _getPOIColor(poi['type']),
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poi['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      poi['description'],
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          '${poi['lat'].toStringAsFixed(4)}°, ${poi['lon'].toStringAsFixed(4)}°',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 10,
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getPOIColor(poi['type']).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            poi['type'].toString().toUpperCase(),
                            style: TextStyle(
                              color: _getPOIColor(poi['type']),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  IconData _getLayerIcon(String layerKey) {
    switch (layerKey) {
      case 'BlueMarble_ShadedRelief':
        return Icons.public;
      case 'MODIS_Aqua_CorrectedReflectance_TrueColor':
      case 'MODIS_Terra_CorrectedReflectance_TrueColor':
        return Icons.satellite_alt;
      case 'VIIRS_SNPP_DayNightBand_ENCC':
        return Icons.nights_stay;
      default:
        return Icons.layers;
    }
  }

  Color _getPOIColor(String type) {
    switch (type) {
      case 'city':
        return Colors.blue;
      case 'port':
        return Colors.indigo;
      case 'forest':
        return Colors.green;
      case 'beach':
        return Colors.cyan;
      case 'agriculture':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  void _centerOnBangladesh() {
    setState(() {
      _currentCenter = LatLng(23.6850, 90.3563); // Center of Bangladesh
      _currentZoom = 7.0;
    });
  }

  void _navigateToPOI(Map<String, dynamic> poi) {
    setState(() {
      _currentCenter = LatLng(poi['lat'], poi['lon']);
      _currentZoom = 10.0;
     if (_tabController.index >= 0 && _tabController.index < _tabController.length) {
  _tabController.animateTo(0);
}
 // Switch to satellite view
    });
  }

  void _showPOIDetails(Map<String, dynamic> poi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(poi['icon'], size: 32, color: _getPOIColor(poi['type'])),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      poi['name'],
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
                      Text(
                        'Description',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(poi['description']),
                      SizedBox(height: 16),
                      Text(
                        'Location',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Latitude: ${poi['lat']}°'),
                      Text('Longitude: ${poi['lon']}°'),
                      SizedBox(height: 16),
                      Text(
                        'Type',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getPOIColor(poi['type']).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          poi['type'].toString().toUpperCase(),
                          style: TextStyle(
                            color: _getPOIColor(poi['type']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToPOI(poi);
                  },
                  icon: Icon(Icons.navigation),
                  label: Text('Navigate to Location'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}