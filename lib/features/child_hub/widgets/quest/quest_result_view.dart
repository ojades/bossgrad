import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/audio_service.dart';

class QuestResultView extends StatefulWidget {
  final int stars;
  final int score;
  final int coins;
  final int correctQs;
  final int totalQs;
  final int timeTakenSeconds;
  final bool canRematch;
  final VoidCallback onReturn;
  final VoidCallback? onRematch;

  const QuestResultView({
    super.key,
    required this.stars,
    required this.score,
    required this.coins,
    required this.correctQs,
    required this.totalQs,
    required this.timeTakenSeconds,
    required this.canRematch,
    required this.onReturn,
    this.onRematch,
  });

  @override
  State<QuestResultView> createState() => _QuestResultViewState();
}

class _QuestResultViewState extends State<QuestResultView> {
  @override
  void initState() {
    super.initState();
    AudioService().playBgm('q_result_4.wav');
  }

  String _formatTime(int seconds) {
    final m = (seconds / 60).floor().toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: const Color(0xFFE5D9F4), width: 4),
          boxShadow: const [
            BoxShadow(color: Color(0xFFD8C9EB), offset: Offset(0, 12)),
            BoxShadow(
              color: Color(0x1A4C2A82),
              offset: Offset(0, 30),
              blurRadius: 40,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final isEarned = index < widget.stars;
                return Padding(
                  padding: EdgeInsets.only(
                    left: 4,
                    right: 4,
                    top: (index == 2)
                        ? 0
                        : ((index == 1 || index == 3) ? 12 : 24), // Arc pattern
                  ),
                  child: Icon(
                    LucideIcons.star,
                    size: 48,
                    color: isEarned
                        ? const Color(0xFFFFD447)
                        : const Color(0xFFE5D9F4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              widget.stars > 0 ? 'LEVEL CLEARED!' : 'BOSS ESCAPED!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: widget.stars > 0
                    ? const Color(0xFF28C995)
                    : const Color(0xFFFF6578),
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.stars > 0
                  ? 'You dealt massive damage and gathered the loot.'
                  : 'You didn\'t get enough right to clear the level. Try again!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF756B91),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),

            // Loot/Stats Row
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                ResultStatBadge(
                  icon: LucideIcons.target,
                  label: '${widget.correctQs} / ${widget.totalQs}',
                  color: const Color(0xFF159A72),
                ),
                ResultStatBadge(
                  icon: LucideIcons.timer,
                  label: _formatTime(widget.timeTakenSeconds),
                  color: const Color(0xFFFF6578),
                ),
                ResultStatBadge(
                  icon: LucideIcons.zap,
                  label: '+${widget.score} XP',
                  color: const Color(0xFF7447F5),
                ),
                ResultStatBadge(
                  icon: LucideIcons.coins,
                  label: '+${widget.coins}',
                  color: const Color(0xFFD89400),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      AudioService().playSfx('btn_click.wav');
                      widget.onReturn();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      side: const BorderSide(
                        color: Color(0xFFEADFF7),
                        width: 3,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'RETURN TO MAP',
                      style: TextStyle(
                        color: Color(0xFF756B91),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                if (widget.canRematch && widget.onRematch != null) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        AudioService().playSfx('btn_click.wav');
                        widget.onRematch!();
                      },
                      style:
                          ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7447F5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ).copyWith(
                            side: WidgetStateProperty.all(
                              const BorderSide(
                                color: Color(0xFF4D2AB4),
                                width: 0,
                              ),
                            ),
                          ),
                      child: const Text(
                        'REMATCH',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ... ResultStatBadge remains unchanged ...
class ResultStatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const ResultStatBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
