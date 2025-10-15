import 'package:civic_app_4/screens/complaints_screen.dart';
import 'package:civic_app_4/screens/dashboard_screen.dart';
import 'package:civic_app_4/screens/network_health_screen.dart';
import 'package:civic_app_4/screens/predictions_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/traffic.dart';
import 'screens/satellite.dart';
import 'screens/incidents.dart';
import 'screens/air_quality.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Telecom Civic Infrastructure Monitoring',
      
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[50],
        cardTheme: const CardThemeData(
          elevation: 4,
          color: Colors.white,
          shadowColor: Color(0xFFE0E0E0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: 1,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          shadowColor: Colors.grey[300],
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 8,
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  
  final List<Widget> _pages = [
    DashboardScreen(), // Main dashboard - new
    NetworkHealthScreen(), // Network monitoring - new
    ComplaintsScreen(), // SMS complaints - new  
    PredictionsScreen(), // Predictive maintenance - new
   RealTimeTrafficScreen(), // Existing traffic monitoring
    SatelliteScreen(), // Existing satellite imagery
  RealIncidentsScreen(), // Existing incidents
    AirQualityScreen(), // Existing air quality
  ];

  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: "Dashboard",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.network_check),
      label: "Network",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.message),
      label: "Complaints",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.trending_up),
      label: "Predictions",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.traffic),
      label: "Traffic",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.satellite),
      label: "Satellite",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.report),
      label: "Incidents",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.cloud),
      label: "Air Quality",
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: Colors.grey[50],
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
            title: Text(
              "Telecom Civic Infrastructure",
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.black87),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.black87),
                onPressed: () {
                  // Show notifications/alerts
                  _showNotifications(context);
                },
              ),
            ],
          ),
          body: Container(
            color: Colors.grey[50],
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
          bottomNavigationBar: _selectedIndex <= 3 ? BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 8,
            selectedItemColor: Colors.blue[600],
            unselectedItemColor: Colors.grey[600],
            currentIndex: _selectedIndex.clamp(0, 3), // Ensure valid index
            onTap: _onItemTapped,
            items: _navItems.take(4).toList(), // Show only main 4 items
          ) : null, // Hide bottom nav for drawer screens
          drawer: _buildDrawer(context),  // Additional screens in drawer
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        drawerTheme: DrawerThemeData(
          backgroundColor: Colors.white,
        ),
      ),
      child: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[400]!],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.monitor_heart, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Infrastructure Monitor',
                    style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 23,fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Telecom & Civic Services',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(0, Icons.dashboard, 'Dashboard'),
            _buildDrawerItem(1, Icons.network_check, 'Network Health'),
            _buildDrawerItem(2, Icons.message, 'SMS Complaints'),
            _buildDrawerItem(3, Icons.trending_up, 'Predictions'),
            Divider(color: Colors.grey[300]),
            _buildDrawerItem(4, Icons.traffic, 'Traffic Monitor'),
            _buildDrawerItem(5, Icons.satellite, 'Satellite View'),
            _buildDrawerItem(6, Icons.report, 'Incidents'),
            _buildDrawerItem(7, Icons.cloud, 'Air Quality'),
            Divider(color: Colors.grey[300]),
           
           
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String title) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.blue[600] : Colors.grey[700],
      ),
      title: Text(
        title,
        style: GoogleFonts.playfairDisplay(
          color: isSelected ? Colors.blue[700] : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.blue[50],
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Alerts',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            _buildAlertItem(
              Icons.warning,
              'Network Latency High',
              'Tower BD-001 showing 200ms latency',
              Colors.orange,
            ),
            _buildAlertItem(
              Icons.error,
              'Service Complaints',
              '15 new SMS complaints received',
              Colors.red,
            ),
            _buildAlertItem(
              Icons.info,
              'Maintenance Scheduled',
              'Predictive model suggests maintenance for Tower BD-003',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(IconData icon, String title, String subtitle, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: TextStyle(color: Colors.black87)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: Text(
        'Just now',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
    );
  }
}