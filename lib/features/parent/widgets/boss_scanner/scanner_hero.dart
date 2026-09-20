// lib/features/parent/screens/widgets/boss_scanner/scanner_hero.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/theme/boss_theme.dart';

class ScannerHero extends StatelessWidget {
  final BossGradTheme theme;
  final int currentStep;

  const ScannerHero({
    super.key,
    required this.theme,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.wandSparkles,
                  color: theme.primaryAction,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'PARENT TOOLKIT · VISION AI',
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
                  const TextSpan(text: 'Turn pages into '),
                  TextSpan(
                    text: 'bosses.',
                    style: TextStyle(color: theme.primaryAction),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Scan a textbook page and we\'ll build a battle-ready quiz in seconds.',
              style: TextStyle(
                color: Color(0xFF756B91),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        _buildStepIndicators(),
      ],
    );
  }

  Widget _buildStepIndicators() {
    return Row(
      children: [
        _buildStepCircle('01', currentStep >= 1),
        Container(width: 44, height: 2, color: const Color(0xFFE2E5ED)),
        _buildStepCircle('02', currentStep >= 2),
        Container(width: 44, height: 2, color: const Color(0xFFE2E5ED)),
        _buildStepCircle('03', currentStep == 3),
      ],
    );
  }

  Widget _buildStepCircle(String text, bool isActive) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isActive ? theme.primaryAction : const Color(0xFFE7E9EF),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFFB4BBC6),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
