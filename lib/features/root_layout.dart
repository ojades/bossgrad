// /lib/features/root_layout.dart

import 'package:bossgrad/features/parent/parent_layout.dart';
import 'package:bossgrad/features/parent/screens/parent_boss_screen.dart';
import 'package:bossgrad/features/parent/screens/parent_dashboard_screen.dart';
import 'package:bossgrad/features/parent/screens/parent_mission_control_screen.dart';
import 'package:bossgrad/features/parent/screens/parent_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bossgrad/core/http_client.dart';

import '../shared/widgets/navigation.dart';

class RootLayout extends StatefulWidget {
  const RootLayout({super.key});

  @override
  State<RootLayout> createState() => _RootLayoutState();
}

class _RootLayoutState extends State<RootLayout> {
  NavPage _currentPage = NavPage.mission;
  String _displayName = '';

  final List<NavPage> _stackOrder = [
    NavPage.quest,
    NavPage.boss,
    NavPage.mission,
    NavPage.tools,
    NavPage.library,
    NavPage.settings,
  ];

  @override
  void initState() {
    super.initState();
    _loadIdentity();
  }

  Future<void> _loadIdentity() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () => _displayName = prefs.getString('parent_name') ?? 'Commander',
    );

    try {
      final res = await HttpClient().dio.get('/api/user/profile');
      if (res.data['display_name'] != null) {
        setState(() => _displayName = res.data['display_name']);
        await prefs.setString('parent_name', _displayName);
      }
    } catch (e) {
      debugPrint('Profile sync failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ParentLayout(
      displayName: _displayName,

      currentPage: _currentPage,
      onTabSelected: (page) => setState(() => _currentPage = page),
      child: IndexedStack(
        index: _stackOrder.indexOf(_currentPage),
        children: const [
          Center(
            child: Text(
              'Quest Map Under Construction',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Center(
            child: Text(
              'Boss Library Under Construction',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          ParentDashboardScreen(),
          ParentBossScreen(),
          ParentMissionControl(),
          ParentSettingsScreen(),
        ],
      ),
    );
  }
}
