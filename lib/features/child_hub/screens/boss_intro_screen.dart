import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/http_client.dart';
import '../../../core/theme/boss_theme.dart';
import 'quest_play_screen.dart';

class BossIntroScreen extends StatefulWidget {
  final BossGradTheme theme;
  final Map<String, dynamic> topic;
  final String subject;

  const BossIntroScreen({
    super.key,
    required this.theme,
    required this.topic,
    required this.subject,
  });

  @override
  State<BossIntroScreen> createState() => _BossIntroScreenState();
}

class _BossIntroScreenState extends State<BossIntroScreen> {
  bool _isStarting = false;

  Future<void> _engageBoss() async {
    setState(() => _isStarting = true);

    try {
      final response = await HttpClient().dio.post(
        '/api/quest/${widget.topic['id']}/start',
      );

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                QuestPlayScreen(theme: widget.theme, battleData: response.data),
          ),
        );

        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint('Failed to start boss battle: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load battle data. Please try again.'),
          ),
        );
        setState(() => _isStarting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.topic['color'] as Color;
    final qCount = widget.topic['question_count'] ?? 0;

    // ---> NEW: Time Limit Formatting
    final int? timeLimitSecs = widget.topic['time_limit'];
    String timeLimitText = 'No Timer';
    if (timeLimitSecs != null && timeLimitSecs > 0) {
      final m = timeLimitSecs ~/ 60;
      final s = timeLimitSecs % 60;
      timeLimitText = s == 0 ? '${m}m limit' : '${m}m ${s}s';
    }

    // ---> NEW: Lives Left Extraction
    final int livesLeft = widget.topic['lives_remaining'] ?? 1;

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
          bottom: false,
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  padding: const EdgeInsets.all(24),
                  icon: const Icon(
                    LucideIcons.x,
                    size: 32,
                    color: Color(0xFF756B91),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 24),
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(36),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.5),
                                      offset: const Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color: color.withOpacity(0.4),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    LucideIcons.swords,
                                    color: Colors.white,
                                    size: 54,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              Text(
                                '${widget.subject.toUpperCase()} · ${widget.topic['level']}',
                                style: const TextStyle(
                                  color: Color(0xFF7447F5),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Text(
                                  widget.topic['title'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF241642),
                                    letterSpacing: -1.5,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // ---> NEW: 3-Stat Row (Qs, Timer, Lives)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _StatBadge(
                                    icon: LucideIcons.target,
                                    label: '$qCount Qs',
                                  ),
                                  const SizedBox(width: 12),
                                  _StatBadge(
                                    icon: LucideIcons.timer,
                                    label: timeLimitText,
                                  ),
                                  const SizedBox(width: 12),
                                  _StatBadge(
                                    icon: LucideIcons.heart,
                                    label: '$livesLeft Tries',
                                  ),
                                ],
                              ),

                              const Spacer(),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 24,
                                  right: 24,
                                  top: 40,
                                  bottom:
                                      40 +
                                      MediaQuery.of(context).padding.bottom,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 68,
                                  child: ElevatedButton(
                                    onPressed: (_isStarting || livesLeft <= 0)
                                        ? null
                                        : _engageBoss,
                                    style:
                                        ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF241642,
                                          ),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          elevation: 0,
                                        ).copyWith(
                                          side: WidgetStateProperty.all(
                                            const BorderSide(
                                              color: Color(0xFF090D15),
                                              width: 0,
                                            ),
                                          ),
                                        ),
                                    child: _isStarting
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : Text(
                                            livesLeft <= 0
                                                ? 'NO TRIES LEFT'
                                                : 'ENGAGE BOSS',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Reduced horizontal padding slightly to fit 3 badges on smaller screens
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEADFF7), width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0xFFD8C9EB), offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF756B91)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF241642),
            ),
          ),
        ],
      ),
    );
  }
}
