// /lib/features/child_hub/screens/child_quest_screen.dart

import 'package:bossgrad/core/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/child_stat_service.dart';
import '../../../core/http_client.dart';
import '../../../core/theme/boss_theme.dart';
import '../../../shared/widgets/navigation.dart';
import '../../../shared/widgets/top_header.dart';
import '../widgets/quest/quest_map_card.dart';
import '../widgets/quest/quest_side_stack.dart';

class ChildQuestScreen extends StatefulWidget {
  final VoidCallback? onSettingsTapped;

  const ChildQuestScreen({super.key, this.onSettingsTapped});

  @override
  State<ChildQuestScreen> createState() => _ChildQuestScreenState();
}

class _ChildQuestScreenState extends State<ChildQuestScreen> {
  bool _isLoading = true;
  List<String> _subjects = [];
  String _selectedSubject = '';
  List<Map<String, dynamic>> _currentTopics = [];

  int _totalLevels = 0;
  // String _childName = 'Player';

  @override
  void initState() {
    super.initState();
    AudioService().playBgm('quest_map.wav');
    // _loadProfile();
    _fetchQuestMap();
  }

  // Future<void> _loadProfile() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     _childName = prefs.getString('child_name') ?? 'Player';
  //   });
  // }

  Future<void> _fetchQuestMap([String? subject]) async {
    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> queryParams = subject != null
          ? {'subject': subject}
          : {};
      final response = await HttpClient().dio.get(
        '/api/quest/map',
        queryParameters: queryParams,
      );

      if (mounted) {
        setState(() {
          _subjects = List<String>.from(response.data['subjects'] ?? []);
          _selectedSubject = response.data['selected_subject'] ?? '';
          _totalLevels = response.data['total_levels'] ?? 0;

          final stats = response.data['stats'] ?? {};
          ChildStatsService().updateStats(
            newCoins: stats['coins'],
            newXp: stats['xp'],
            newRank: stats['rank'],
          );

          final rawTopics = response.data['topics'] as List<dynamic>? ?? [];
          _currentTopics = rawTopics.map((t) {
            final hexString = t['color_hex'] as String;
            final color = Color(int.parse(hexString.replaceFirst('#', '0xFF')));

            return {
              'id': t['id'],
              'level': t['level'],
              'title': t['title'],
              'state': t['state'],
              'color': color,
              'question_count': t['question_count'] ?? 0,
              'time_limit': t['time_limit'],
              'lives_remaining': t['lives_remaining'] ?? 1,
              'result_data': t['result_data'],
            };
          }).toList();

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load quest map: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BossGradTheme>()!;

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TopHeader(
            theme: theme,
            role: UserRole.child,
            subjects: _subjects,
            selectedSubject: _selectedSubject,
            onSettingsTapped: widget.onSettingsTapped,
            onSubjectChanged: (subject) {
              if (subject != _selectedSubject) {
                _fetchQuestMap(subject);
              }
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 16,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _subjects.isEmpty
                      ? _buildMapEmptyState()
                      : QuestMapCard(
                          theme: theme,
                          subjects: _subjects,
                          selectedSubject: _selectedSubject,
                          topics: _currentTopics,
                          totalLevels: _totalLevels,
                          onQuestClosed: () => _fetchQuestMap(_selectedSubject),
                          onSubjectChanged: (subject) {
                            if (subject != _selectedSubject) {
                              _fetchQuestMap(subject);
                            }
                          },
                        ),
                ),
                const SizedBox(width: 22),
                Expanded(flex: 7, child: QuestSideStack(theme: theme)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE5D9F4), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0xFFD8C9EB), offset: Offset(0, 8)),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.map,
              size: 64,
              color: const Color(0xFFD8C9EB).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No quests available for your grade yet.\nAsk your commander to deploy some bosses!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF756B91),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
