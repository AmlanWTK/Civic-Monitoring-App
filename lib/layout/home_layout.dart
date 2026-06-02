import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:civic_app_4/theme.dart';
import 'package:civic_app_4/screens/complaints_screen.dart';
import 'package:civic_app_4/screens/dashboard_screen.dart';
import 'package:civic_app_4/screens/network_health_screen.dart';
import 'package:civic_app_4/screens/predictions_screen.dart';
import 'package:civic_app_4/screens/traffic.dart';
import 'package:civic_app_4/screens/satellite.dart';
import 'package:civic_app_4/screens/incidents.dart';
import 'package:civic_app_4/screens/air_quality.dart';

// ─── Nav Data ────────────────────────────────────────────────────────────────
class _NavItem {
  final IconData activeIcon;
  final IconData icon;
  final String label;
  const _NavItem(this.activeIcon, this.icon, this.label);
}

class _DrawerItem {
  final int index;
  final IconData icon;
  final String label;
  const _DrawerItem(this.index, this.icon, this.label);
}

// ─── Home Page ────────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardScreen(),
    NetworkHealthScreen(),
    ComplaintsScreen(),
    PredictionsScreen(),
    RealTimeTrafficScreen(),
    SatelliteScreen(),
    RealIncidentsScreen(),
    AirQualityScreen(),
  ];

  static const List<_NavItem> _navItems = [
    _NavItem(Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
    _NavItem(Icons.network_check_rounded, Icons.network_check_outlined, 'Network'),
    _NavItem(Icons.chat_bubble_rounded, Icons.chat_bubble_outline_rounded, 'Complaints'),
    _NavItem(Icons.auto_graph_rounded, Icons.auto_graph_outlined, 'Predictions'),
  ];

  static const List<_DrawerItem> _extras = [
    _DrawerItem(4, Icons.traffic_rounded, 'Traffic Monitor'),
    _DrawerItem(5, Icons.satellite_alt_rounded, 'Satellite View'),
    _DrawerItem(6, Icons.report_problem_rounded, 'Incidents'),
    _DrawerItem(7, Icons.air_rounded, 'Air Quality'),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _selectedIndex <= 3 ? _buildBottomNav() : null,
      drawer: _buildDrawer(),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.menu_rounded,
                color: AppColors.textSecondary, size: 18),
          ),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.monitor_heart_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('CivicPulse',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.4)),
              Text('Infrastructure Monitor',
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      letterSpacing: 0.2)),
            ],
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        // Live badge
        Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: AppDecorations.statusBadge(AppColors.success),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: AppColors.success, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text('LIVE',
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                      letterSpacing: 0.8)),
            ],
          ),
        ),
        IconButton(
          icon:
              const Icon(Icons.notifications_rounded, color: AppColors.textSecondary),
          onPressed: () => _showNotifications(context),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Bottom Nav ───────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: List.generate(_navItems.length, (i) {
              final item = _navItems[i];
              final isSelected = _selectedIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onItemTapped(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            key: ValueKey(isSelected),
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textMuted,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 3),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: isSelected ? 18 : 0,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ── Drawer ───────────────────────────────────────────────────────────────────
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A2550), AppColors.surface],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border:
                  Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.monitor_heart_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(height: 16),
                Text('CivicPulse',
                    style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5)),
                Text('Infrastructure Monitoring System',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: AppDecorations.statusBadge(AppColors.success),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('All Systems Operational',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              children: [
                _sectionLabel('Main Navigation'),
                _drawerItem(0, Icons.dashboard_rounded, 'Dashboard'),
                _drawerItem(1, Icons.network_check_rounded, 'Network Health'),
                _drawerItem(2, Icons.chat_bubble_rounded, 'SMS Complaints'),
                _drawerItem(3, Icons.auto_graph_rounded, 'Predictions'),
                const SizedBox(height: 8),
                _sectionLabel('Additional Monitoring'),
                ..._extras.map((e) => _drawerItem(e.index, e.icon, e.label)),
              ],
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
                border:
                    Border(top: BorderSide(color: AppColors.border, width: 1))),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientCyan,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Admin User',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      Text('System Administrator',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                const Icon(Icons.settings_rounded,
                    color: AppColors.textMuted, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 1.3,
          ),
        ),
      );

  Widget _drawerItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isSelected
            ? Border.all(color: AppColors.primary.withOpacity(0.3))
            : null,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            size: 20),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle))
            : null,
        onTap: () {
          Navigator.pop(context);
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  // ── Notifications Sheet ───────────────────────────────────────────────────────
  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Recent Alerts',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            _notifItem(Icons.warning_rounded, 'Network Latency High',
                'Tower BD-001 showing 200ms latency', AppColors.warning),
            _notifItem(Icons.error_rounded, 'Service Complaints',
                '15 new SMS complaints received', AppColors.error),
            _notifItem(Icons.build_rounded, 'Maintenance Scheduled',
                'Predictive model: Tower BD-003', AppColors.primary),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _notifItem(
      IconData icon, String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.glowCard(color, radius: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text('Now',
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}