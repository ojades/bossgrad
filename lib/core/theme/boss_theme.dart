// /lib/core/theme/boss_theme.dart
import 'package:flutter/material.dart';

// 1. Design Tokens
abstract class BossColors {
  static const electricViolet = Color(0xFF7C3AED);
  static const arcadeYellow = Color(0xFFFACC15);
  static const victoryGreen = Color(0xFF10B981);
  static const bossRed = Color(0xFFEF4444);
  static const backgroundSlate = Color(0xFFF8FAFC);
}

// 2. Theme Extension
class BossGradTheme extends ThemeExtension<BossGradTheme> {
  final Color primaryAction;
  final Color coinAccent;
  final Color background;
  final BorderRadius chunkyRadius;

  const BossGradTheme({
    required this.primaryAction,
    required this.coinAccent,
    required this.background,
    required this.chunkyRadius,
  });

  @override
  ThemeExtension<BossGradTheme> copyWith() => this;

  @override
  ThemeExtension<BossGradTheme> lerp(
    ThemeExtension<BossGradTheme>? other,
    double t,
  ) => this;
}
