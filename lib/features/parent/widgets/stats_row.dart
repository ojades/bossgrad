import 'package:flutter/material.dart';

class ParentStatsRow extends StatelessWidget {
  final int questTimeSeconds;
  final int questsCleared;
  final int totalQuests;

  const ParentStatsRow({
    super.key,
    required this.questTimeSeconds,
    required this.questsCleared,
    required this.totalQuests,
  });

  @override
  Widget build(BuildContext context) {
    final int hours = questTimeSeconds ~/ 3600;
    final int minutes = (questTimeSeconds % 3600) ~/ 60;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'QUEST TIME',
            bigNum: '$hours',
            smallNum: 'h ${minutes}m',
            trend: 'Across all players',
            bg: const Color(0xFFDFF9ED),
            border: const Color(0xFFA9E8CF),
            trendColor: const Color(0xFF15A178),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StatCard(
            title: 'QUESTS CLEARED',
            bigNum: '$questsCleared',
            smallNum: ' / $totalQuests',
            trend: 'Total squad progress',
            bg: const Color(0xFFE9E2FF),
            border: const Color(0xFFCFC0FA),
            trendColor: const Color(0xFF7447F5),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: _StatCard(
            title: 'PENDING REWARDS',
            bigNum: '08',
            smallNum: '',
            trend: 'Needs your approval',
            bg: Color(0xFFFFF1B8),
            border: Color(0xFFF3D96C),
            trendColor: Color(0xFFE29324),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String bigNum;
  final String smallNum;
  final String trend;
  final Color bg;
  final Color border;
  final Color trendColor;

  const _StatCard({
    required this.title,
    required this.bigNum,
    required this.smallNum,
    required this.trend,
    required this.bg,
    required this.border,
    required this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 3),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(color: Color(0x1F5A3989), offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF756B91),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Color(0xFF241642),
                letterSpacing: -2.0,
              ),
              children: [
                TextSpan(text: bigNum),
                TextSpan(
                  text: smallNum,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Color(0xFFA4ADBB),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            trend,
            style: TextStyle(
              color: trendColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
