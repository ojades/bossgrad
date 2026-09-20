import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/widgets/arcade_components.dart';

class LiveFeedCard extends StatelessWidget {
  const LiveFeedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ArcadeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LIVE FEED',
                    style: TextStyle(
                      color: Color(0xFF7447F5),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Recent activity',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF241642),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F9F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Live',
                  style: TextStyle(
                    color: Color(0xFF16A47B),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const ActivityRow(
            title: 'Alex cleared a boss battle',
            detail: 'States of matter · 92%',
            time: '2 min ago',
            iconBg: Color(0xFFE1F9F1),
            iconColor: Color(0xFF28C995),
            icon: LucideIcons.medal,
          ),
          const ActivityRow(
            title: 'Maya earned a new badge',
            detail: 'First Quest complete',
            time: '48 min ago',
            iconBg: Color(0xFFFFF3C9),
            iconColor: Color(0xFFD89400),
            icon: LucideIcons.award,
          ),
          const ActivityRow(
            title: 'Sam requested a reward',
            detail: '250 coins · Roblox card',
            time: '2 hr ago',
            iconBg: Color(0xFFFFE3E3),
            iconColor: Color(0xFFFF6578),
            icon: LucideIcons.coins,
            isLast: true,
          ),
        ],
      ),
    );
  }
}
