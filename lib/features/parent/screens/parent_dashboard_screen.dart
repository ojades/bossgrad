import 'package:bossgrad/core/http_client.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/boss_theme.dart';
import '../widgets/squad_card.dart';
import '../widgets/live_feed_card.dart';
import '../widgets/stats_row.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  String _displayName = '';

  // Dynamic Data State
  List<Map<String, dynamic>> _children = [];
  bool _isLoadingChildren = true;

  // Stats State
  int _questTimeSeconds = 0;
  int _questsCleared = 0;
  int _totalQuests = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedName = prefs.getString('parent_name');
    final firebaseName = FirebaseAuth.instance.currentUser?.displayName;

    setState(() {
      _displayName = cachedName ?? firebaseName ?? '';
    });

    await _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoadingChildren = true);
    try {
      final responses = await Future.wait([
        HttpClient().dio.get('/api/user/profile'),
        HttpClient().dio.get('/api/user/squad/progress'),
      ]);

      final profileRes = responses[0];
      final squadRes = responses[1];

      final fetchedName = profileRes.data['display_name'] ?? '';
      if (fetchedName.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('parent_name', fetchedName);
      }

      final colors = ['violet', 'mint', 'coral', 'yellow'];

      // Parse payload
      final squadList = squadRes.data['squad'] as List? ?? [];
      final statsMap = squadRes.data['stats'] ?? {};

      setState(() {
        if (fetchedName.isNotEmpty) _displayName = fetchedName;

        _questTimeSeconds = statsMap['quest_time_seconds'] ?? 0;
        _questsCleared = statsMap['quests_cleared'] ?? 0;
        _totalQuests = statsMap['total_quests'] ?? 0;

        _children = squadList.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return {
            'id': item['id'],
            'name': item['name'],
            'grade': item['grade'],
            'initials': item['initials'],
            'rank': item['rank'] ?? 0,
            'progress': item['progress'] ?? 0.0,
            'total_cleared': item['total_cleared'] ?? 0,
            'total_levels': item['total_levels'] ?? 0,
            'subjects': item['subjects'] ?? [],
            'color': colors[idx % colors.length],
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('Failed to fetch dashboard data: $e');
    } finally {
      if (mounted) setState(() => _isLoadingChildren = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BossGradTheme>()!;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 120,
        bottom: 120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.shieldCheck,
                        color: theme.primaryAction,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'PARENT VIEW · MISSION CONTROL',
                        style: TextStyle(
                          color: theme.primaryAction,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                        color: Color(0xFF241642),
                        letterSpacing: -2.0,
                      ),
                      children: [
                        const TextSpan(text: 'Good morning, '),
                        TextSpan(
                          text: _displayName.isEmpty
                              ? 'Commander.'
                              : '$_displayName.',
                          style: TextStyle(color: theme.primaryAction),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your squad is making great progress this week.',
                    style: TextStyle(
                      color: Color(0xFF756B91),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text(
                  'Create mission',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                ),
                style:
                    ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryAction,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ).copyWith(
                      side: WidgetStateProperty.all(
                        const BorderSide(color: Color(0xFF4D2AB4), width: 0),
                      ),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Wire up the new Stats Row
          ParentStatsRow(
            questTimeSeconds: _questTimeSeconds,
            questsCleared: _questsCleared,
            totalQuests: _totalQuests,
          ),
          const SizedBox(height: 22),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: SquadCard(
                  childrenList: _children,
                  isLoading: _isLoadingChildren,
                  onRefresh: _fetchDashboardData,
                ),
              ),
              const SizedBox(width: 22),
              const Expanded(flex: 4, child: LiveFeedCard()),
            ],
          ),
        ],
      ),
    );
  }
}
