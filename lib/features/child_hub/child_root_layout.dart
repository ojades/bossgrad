// /lib/features/child_hub/child_root_layout.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/widgets/navigation.dart';
import 'child_layout.dart';
import 'screens/child_quest_screen.dart';

class ChildRootLayout extends StatefulWidget {
  const ChildRootLayout({super.key});

  @override
  State<ChildRootLayout> createState() => _ChildRootLayoutState();
}

class _ChildRootLayoutState extends State<ChildRootLayout> {
  NavPage _currentPage = NavPage.quest;
  String _childName = 'Player';

  final List<NavPage> _stackOrder = [
    NavPage.quest,
    NavPage.boss,
    NavPage.profile,
  ];

  @override
  void initState() {
    super.initState();
    _loadIdentity();
  }

  Future<void> _loadIdentity() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _childName = prefs.getString('child_name') ?? 'Player';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChildLayout(
      displayName: _childName,
      currentPage: _currentPage,
      onTabSelected: (page) => setState(() => _currentPage = page),
      child: IndexedStack(
        index: _stackOrder.indexOf(_currentPage),
        children: const [
          ChildQuestScreen(),
          Center(
            child: Text(
              'Claim Your Rewards Under Construction',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Center(
            child: Text(
              'Player Profile Under Construction',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
