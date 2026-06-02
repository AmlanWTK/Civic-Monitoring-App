import 'package:civic_app_4/screens/complaints_screen.dart';
import 'package:civic_app_4/screens/dashboard_screen.dart';
import 'package:civic_app_4/screens/network_health_screen.dart';
import 'package:civic_app_4/screens/predictions_screen.dart';
import 'package:civic_app_4/theme.dart';
import 'package:civic_app_4/layout/home_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/traffic.dart';
import 'screens/satellite.dart';
import 'screens/incidents.dart';
import 'screens/air_quality.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CivicPulse – Infrastructure Monitor',
      theme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}

