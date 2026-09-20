// /lib/features/child_hub/screens/quest_result_screen.dart
import 'package:flutter/material.dart';

import '../../../core/theme/boss_theme.dart';
import '../widgets/quest/quest_result_view.dart';
import 'boss_intro_screen.dart';

class QuestResultScreen extends StatelessWidget {
  final BossGradTheme theme;
  final Map<String, dynamic> topic;
  final String subject;

  const QuestResultScreen({
    super.key,
    required this.theme,
    required this.topic,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final resultData = topic['result_data'] ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF4EFFF),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [Color(0xFFE8DCFF), Color(0xFFF4EFFF)],
          ),
        ),
        child: SafeArea(
          child: QuestResultView(
            stars: resultData['stars'] ?? 0,
            score: resultData['total_score'] ?? 0,
            coins: resultData['total_coins'] ?? 0,
            correctQs: resultData['correct_answers'] ?? 0,
            totalQs: resultData['total_questions'] ?? 0,
            timeTakenSeconds: resultData['time_taken_seconds'] ?? 0,
            canRematch: resultData['can_rematch'] ?? false,
            onReturn: () => Navigator.pop(context),
            onRematch: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => BossIntroScreen(
                    theme: theme,
                    topic: topic,
                    subject: subject,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
