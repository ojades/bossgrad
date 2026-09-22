import 'dart:async';
import 'dart:math' as math;

import 'package:bossgrad/core/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/http_client.dart';
import '../../../core/theme/boss_theme.dart';
import '../../../shared/vectors/battle_arena_painter.dart';
import '../../parent/widgets/boss_scanner/diagram_renderer.dart';
import '../widgets/quest/quest_result_view.dart';

class QuestPlayScreen extends StatefulWidget {
  final BossGradTheme theme;
  final Map<String, dynamic> battleData;

  const QuestPlayScreen({
    super.key,
    required this.theme,
    required this.battleData,
  });

  @override
  State<QuestPlayScreen> createState() => _QuestPlayScreenState();
}

class _QuestPlayScreenState extends State<QuestPlayScreen>
    with SingleTickerProviderStateMixin {
  late final String _attemptId;
  late final List<dynamic> _questions;
  late final String _subject;

  // Background animation
  late final AnimationController _bgController;
  late final Animation<double> _floatAnim;

  // State
  int _currentIndex = 0;
  final Map<String, int> _selectedAnswers = {};
  bool _isSubmitting = false;
  Map<String, dynamic>? _resultData; // Holds payload after completion

  // Retries & Timer
  late int _livesRemaining;
  late int _totalLives;
  late int _totalTimeSeconds;
  late int _timeLeftSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    AudioService().playBgm('quest_play.wav');
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _attemptId = widget.battleData['attempt_id'];
    _questions = widget.battleData['questions'];
    _subject = widget.battleData['subject'] ?? 'Quest';

    _livesRemaining = widget.battleData['lives_remaining'] ?? 3;
    _totalLives = widget.battleData['total_lives'] ?? 3;

    final answeredState =
        widget.battleData['answered_state'] as Map<String, dynamic>?;
    if (answeredState != null) {
      answeredState.forEach((key, value) {
        _selectedAnswers[key] = value as int;
      });
    }

    // Use exact time limit from DB (or fallback), and subtract time already spent
    _totalTimeSeconds = widget.battleData['time_limit'] ?? 600;
    final int timeSpent = widget.battleData['time_spent'] ?? 0;
    _timeLeftSeconds = math.max(0, _totalTimeSeconds - timeSpent);

    _startTimer();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Creates a smooth, sine-wave easing curve for floating objects
    _floatAnim = CurvedAnimation(
      parent: _bgController,
      curve: Curves.easeInOutSine,
    );
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeftSeconds > 0) {
        setState(() => _timeLeftSeconds--);
      } else {
        timer.cancel();
        // Time ran out -> Auto complete instead of defeat
        _completeQuest();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _bgController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _submitAnswer(String questionId, int selectedIndex) async {
    if (_isSubmitting || _timeLeftSeconds <= 0) return;

    setState(() {
      _selectedAnswers[questionId] = selectedIndex;
    });

    try {
      await HttpClient().dio.post(
        '/api/quest/attempt/$_attemptId/answer',
        data: {
          'question_id': questionId,
          'selected_index': selectedIndex,
          'time_spent_seconds': 10,
        },
      );
    } catch (e) {
      debugPrint('Failed to submit answer: $e');
    }
  }

  Future<void> _completeQuest() async {
    setState(() => _isSubmitting = true);
    _countdownTimer?.cancel();

    try {
      final response = await HttpClient().dio.post(
        '/api/quest/attempt/$_attemptId/complete',
      );
      if (mounted) {
        setState(() {
          _resultData = response.data;
          _isSubmitting = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to complete quest: $e');
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _confirmRetreat() async {
    final bool? exit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Retreat?',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Your progress is saved, but the boss will regenerate its health while you are away.',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF756B91),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Stay & Fight',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          TextButton(
            onPressed: () => {
              AudioService().playBgm('quest_map.wav'),
              Navigator.pop(ctx, true),
            },
            child: const Text(
              'Retreat',
              style: TextStyle(
                color: Color(0xFFFF6578),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );

    if (exit == true && mounted) {
      Navigator.pop(context);
    }
  }

  String _formatTime(int seconds) {
    final m = (seconds / 60).floor().toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: Text("No questions found.")));
    }

    return Scaffold(
      body: AnimatedBuilder(
        animation: _floatAnim,
        builder: (context, child) {
          return CustomPaint(
            // Use our new animated vector background
            painter: BattleArenaPainter(_floatAnim.value),
            child: child,
          );
        },
        child: SafeArea(
          child: _resultData != null
              ? QuestResultView(
                  stars: _resultData!['stars'] ?? 0,
                  score: _resultData!['total_score'] ?? 0,
                  coins: _resultData!['total_coins'] ?? 0,
                  correctQs: _resultData!['correct_answers'] ?? 0,
                  totalQs: _resultData!['total_questions'] ?? 0,
                  timeTakenSeconds: _resultData!['time_taken_seconds'] ?? 0,
                  canRematch: false,
                  onReturn: () => Navigator.pop(context),
                )
              : _buildBattleView(),
        ),
      ),
    );
  }

  Widget _buildBattleView() {
    final question = _questions[_currentIndex];
    final questionId = question['id'];
    final options = question['options'] as List<dynamic>;
    final hasAnsweredAll = _selectedAnswers.length == _questions.length;
    final progressVal = _selectedAnswers.length / _questions.length;
    final timeRatio = (_timeLeftSeconds / _totalTimeSeconds).clamp(0.0, 1.0);

    return Column(
      children: [
        // 1. TOP BAR
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: _confirmRetreat,
                icon: const Icon(
                  LucideIcons.chevronLeft,
                  size: 16,
                  color: Color(0xFF756B91),
                ),
                label: const Text(
                  'Exit',
                  style: TextStyle(
                    color: Color(0xFF756B91),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),

              // Lives Left
              Row(
                children: List.generate(
                  _totalLives,
                  (index) => Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      LucideIcons.heart,
                      size: 16,
                      color: index < _livesRemaining
                          ? const Color(0xFFFF6578)
                          : const Color(0xFFFF6578).withOpacity(0.25),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Compact Question Counter
              Text(
                'Q ${_currentIndex + 1}/${_questions.length}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF756B91),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 16),

              // The Heartometer (Thermometer Timer)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        width: 65,
                        height: 14,
                        margin: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFCCD2),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFFD8A2AC),
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: timeRatio,
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF5670),
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        left: -2,
                        child: Icon(
                          LucideIcons.heart,
                          color: Color(0xFFFF536A),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: Text(
                      _formatTime(_timeLeftSeconds),
                      style: const TextStyle(
                        color: Color(0xFFFF536A),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. OVERALL PROGRESS BAR
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E8EE).withOpacity(0.5),
            borderRadius: BorderRadius.circular(99),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progressVal,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.theme.primaryAction,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // 3. MAIN SCROLLABLE BATTLE CONTENT
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 32, bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // QUESTION CARD
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(26),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2B1852), Color(0xFF4C2C89)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFF3A2366),
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF1D1136),
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_currentIndex + 1 < 10 ? '0' : ''}${_currentIndex + 1}',
                                style: const TextStyle(
                                  color: Color(0xFFA99CFF),
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -2,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_subject.toUpperCase()} · ${question['topic']?.toString().toUpperCase() ?? 'KNOWLEDGE'}',
                                      style: const TextStyle(
                                        color: Color(0xFFA99CFF),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      question['question_text'] ??
                                          question['question'] ??
                                          '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Choose the best answer to deal damage to the boss.',
                                      style: TextStyle(
                                        color: Color(0xFFACB4C4),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (question['diagram_svg'] != null) ...[
                                      const SizedBox(height: 16),
                                      Center(
                                        child: SizedBox(
                                          height: 160,
                                          child: SvgPicture.string(
                                            question['diagram_svg'],
                                          ),
                                        ),
                                      ),
                                    ] else if (question['diagram'] != null) ...[
                                      const SizedBox(height: 16),
                                      DiagramRenderer(
                                        diagram: Map<String, dynamic>.from(
                                          question['diagram'],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // OPTIONS GRID
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 72,
                              ),
                          itemCount: options.length,
                          itemBuilder: (context, i) {
                            final opt = options[i];
                            final isSelected =
                                _selectedAnswers[questionId] == i;

                            String type = 'text';
                            String value = '';
                            if (opt is Map) {
                              type = opt['type'] ?? 'text';
                              value = opt['value'].toString();
                            } else {
                              value = opt.toString();
                            }

                            return GestureDetector(
                              onTap: () => {
                                AudioService().playSfx('option_select.wav'),
                                _submitAnswer(questionId, i),
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFFFF4A9)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFD5B63C)
                                        : const Color(0xFFE1D4F2),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? const Color(0xFFD5B63C)
                                          : const Color(0xFFD7C8EB),
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFFF1F2F6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        String.fromCharCode(65 + i),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isSelected
                                              ? const Color(0xFF684E00)
                                              : const Color(0xFF756B91),
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: type == 'svg'
                                          ? Container(
                                              height: 24,
                                              alignment: Alignment.centerLeft,
                                              child: SvgPicture.string(value),
                                            )
                                          : Text(
                                              value,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                color: isSelected
                                                    ? const Color(0xFF684E00)
                                                    : const Color(0xFF241642),
                                              ),
                                            ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        LucideIcons.check,
                                        color: Color(0xFFD89400),
                                        size: 16,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // FIXED BOTTOM NAVIGATION BUTTONS
                Padding(
                  padding: const EdgeInsets.only(bottom: 24, top: 12),
                  child: Row(
                    children: [
                      if (_currentIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => {
                              AudioService().playSfx('q_next.wav'),
                              setState(() => _currentIndex--),
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(
                                color: Color(0xFFEADFF7),
                                width: 3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'PREVIOUS',
                              style: TextStyle(
                                color: Color(0xFF756B91),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      if (_currentIndex > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            AudioService().playSfx('q_next.wav');
                            if (_currentIndex < _questions.length - 1) {
                              setState(() => _currentIndex++);
                            } else if (hasAnsweredAll && !_isSubmitting) {
                              _completeQuest();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _currentIndex == _questions.length - 1 &&
                                    hasAnsweredAll
                                ? const Color(0xFF28C995)
                                : const Color(0xFF241642),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _currentIndex == _questions.length - 1
                                      ? (hasAnsweredAll
                                            ? 'FINISH BATTLE'
                                            : 'ANSWER ALL TO FINISH')
                                      : 'NEXT QUESTION',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
