import 'package:bossgrad/core/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/boss_theme.dart';
import '../../screens/boss_intro_screen.dart';
import '../../screens/quest_result_screen.dart';

class QuestMapCard extends StatefulWidget {
  final BossGradTheme theme;
  final List<String> subjects;
  final String selectedSubject;
  final List<Map<String, dynamic>> topics;
  final int totalLevels;
  final VoidCallback onQuestClosed;
  final ValueChanged<String> onSubjectChanged;

  const QuestMapCard({
    super.key,
    required this.theme,
    required this.subjects,
    required this.selectedSubject,
    required this.topics,
    required this.totalLevels,
    required this.onQuestClosed,
    required this.onSubjectChanged,
  });

  @override
  State<QuestMapCard> createState() => _QuestMapCardState();
}

class _QuestMapCardState extends State<QuestMapCard> {
  final ScrollController _scrollController = ScrollController();
  static const double _rowHeight = 110.0;
  static const double _topPadding = 40.0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveNode();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveNode() {
    if (!_scrollController.hasClients) return;

    final activeIndex = widget.topics.indexWhere((t) => t['state'] == 'active');
    if (activeIndex == -1) return;

    final nodeCenterY =
        _topPadding + (activeIndex * _rowHeight) + (_rowHeight / 2);
    final viewportHeight = _scrollController.position.viewportDimension;
    double targetOffset = nodeCenterY - (viewportHeight / 2);

    targetOffset = targetOffset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    const List<double> nodeXAlignments = [-0.6, -0.1, 0.4, -0.1];

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFFFF8D9)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE5D9F4), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0xFFD8C9EB), offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Map Header (Fixed, cleanly minimal)
          Padding(
            padding: const EdgeInsets.only(
              left: 30,
              right: 30,
              top: 20,
              bottom: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL LEVELS · ${widget.totalLevels}',
                  style: const TextStyle(
                    color: Color(0xFF7554F6),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.selectedSubject} Quest',
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF241642),
                  ),
                ),
              ],
            ),
          ),

          // Winding Map Path Area with Floating UI Overlay
          Expanded(
            child: Stack(
              children: [
                // Layer 1: The Scrollable Map
                Positioned.fill(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: _topPadding,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double width = constraints.maxWidth;
                        final double totalHeight =
                            (widget.topics.length * _rowHeight) + 100;

                        final List<Offset> nodeCenters = [];
                        for (int i = 0; i < widget.topics.length; i++) {
                          final double xAlign =
                              nodeXAlignments[i % nodeXAlignments.length];
                          final double x = (width / 2) + (xAlign * width / 2);
                          final double y = (i * _rowHeight) + (_rowHeight / 2);
                          nodeCenters.add(Offset(x, y));
                        }

                        if (nodeCenters.isNotEmpty) {
                          nodeCenters.add(
                            Offset(
                              width / 2,
                              (widget.topics.length * _rowHeight) + 60,
                            ),
                          );
                        }

                        return SizedBox(
                          height: totalHeight,
                          width: width,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _MeanderPathPainter(
                                    points: nodeCenters,
                                  ),
                                ),
                              ),
                              ...widget.topics.asMap().entries.map((entry) {
                                final index = entry.key;
                                final topic = entry.value;
                                final center = nodeCenters[index];
                                final isLabelOnRight = center.dx < width / 2;

                                return Positioned(
                                  left: isLabelOnRight ? center.dx - 30 : null,
                                  right: !isLabelOnRight
                                      ? (width - center.dx) - 30
                                      : null,
                                  top: center.dy - 30,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!isLabelOnRight)
                                        _NodeLabel(
                                          topic: topic,
                                          theme: widget.theme,
                                          alignLeft: isLabelOnRight,
                                        ),
                                      if (!isLabelOnRight)
                                        const SizedBox(width: 12),

                                      GestureDetector(
                                        onTap: () async {
                                          AudioService().playSfx(
                                            'btn_click.wav',
                                          );
                                          if (topic['state'] != 'locked') {
                                            if (topic['state'] == 'done' &&
                                                topic['result_data'] != null) {
                                              await Navigator.of(
                                                context,
                                                rootNavigator: true,
                                              ).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      QuestResultScreen(
                                                        theme: widget.theme,
                                                        topic: topic,
                                                        subject: widget
                                                            .selectedSubject,
                                                      ),
                                                ),
                                              );
                                            } else {
                                              await Navigator.of(
                                                context,
                                                rootNavigator: true,
                                              ).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      BossIntroScreen(
                                                        theme: widget.theme,
                                                        topic: topic,
                                                        subject: widget
                                                            .selectedSubject,
                                                      ),
                                                ),
                                              );
                                            }
                                            widget.onQuestClosed();
                                          }
                                        },
                                        child: topic['state'] == 'active'
                                            ? _ActiveNodePulse(
                                                color: topic['color'] as Color,
                                              )
                                            : Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color:
                                                      topic['state'] == 'locked'
                                                      ? const Color(0xFFD5D9E1)
                                                      : topic['color'] as Color,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 6,
                                                  ),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Color(0x2E43277A),
                                                      offset: Offset(0, 5),
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  topic['state'] == 'done'
                                                      ? LucideIcons.check
                                                      : LucideIcons.lock,
                                                  color:
                                                      topic['state'] == 'locked'
                                                      ? const Color(0xFF929BAD)
                                                      : Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                      ),

                                      if (isLabelOnRight)
                                        const SizedBox(width: 12),
                                      if (isLabelOnRight)
                                        _NodeLabel(
                                          topic: topic,
                                          theme: widget.theme,
                                          alignLeft: isLabelOnRight,
                                        ),
                                    ],
                                  ),
                                );
                              }),
                              if (nodeCenters.isNotEmpty)
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  top: nodeCenters.last.dy - 20,
                                  child: Column(
                                    children: const [
                                      Icon(
                                        LucideIcons.trophy,
                                        color: Color(0xFFC9CDD7),
                                        size: 28,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'THE FINAL BOSS',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFA2A8B6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Layer 2: Google Maps style Floating Subject Pills
                Positioned(
                  top: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: widget.subjects.map((subject) {
                      final isSelected = widget.selectedSubject == subject;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => {
                            AudioService().playSfx('btn_click.wav'),
                            widget.onSubjectChanged(subject),
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? widget.theme.primaryAction
                                  : Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? widget.theme.primaryAction
                                    : const Color(0xFFE5D9F4),
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1F4E2C8B),
                                  offset: Offset(0, 4),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Text(
                              subject,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF756B91),
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ... _ActiveNodePulse and _MeanderPathPainter remain the same ...

class _ActiveNodePulse extends StatefulWidget {
  final Color color;
  const _ActiveNodePulse({required this.color});

  @override
  State<_ActiveNodePulse> createState() => _ActiveNodePulseState();
}

class _ActiveNodePulseState extends State<_ActiveNodePulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final pulsingBgColor = Color.lerp(
          widget.color,
          Colors.white,
          _animation.value * 0.35,
        );

        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: pulsingBgColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 6),
            boxShadow: [
              const BoxShadow(color: Color(0x2E43277A), offset: Offset(0, 5)),
              BoxShadow(
                color: widget.color.withOpacity(0.1 + (0.5 * _animation.value)),
                offset: const Offset(0, 0),
                blurRadius: 5 + (20 * _animation.value),
                spreadRadius: 2 + (8 * _animation.value),
              ),
            ],
          ),
          child: const Icon(LucideIcons.swords, color: Colors.white, size: 18),
        );
      },
    );
  }
}

class _NodeLabel extends StatelessWidget {
  final Map<String, dynamic> topic;
  final BossGradTheme theme;
  final bool alignLeft;

  const _NodeLabel({
    required this.topic,
    required this.theme,
    required this.alignLeft,
  });

  @override
  Widget build(BuildContext context) {
    final state = topic['state'] as String;
    final qCount = topic['question_count'] as int? ?? 0;

    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: state == 'active'
              ? const Color(0xFFB7AAFF)
              : const Color(0xFFEADFF7),
          width: state == 'active' ? 2 : 3,
        ),
        boxShadow: state == 'active'
            ? const [
                BoxShadow(
                  color: Color(0xFFDDD8FF),
                  offset: Offset(0, 4),
                  blurRadius: 12,
                ),
              ]
            : const [BoxShadow(color: Color(0xFFDED2EF), offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: alignLeft
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(
            '${topic['level']}  ·  Q$qCount ',
            style: const TextStyle(
              color: Color(0xFF756B91),
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            topic['title'] as String,
            textAlign: alignLeft ? TextAlign.left : TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF241642),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          if (state == 'active')
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.zap, color: theme.primaryAction, size: 9),
                const SizedBox(width: 3),
                Text(
                  'BOSS READY',
                  style: TextStyle(
                    color: theme.primaryAction,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          if (state == 'done')
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(LucideIcons.check, color: Color(0xFF159A72), size: 10),
                SizedBox(width: 3),
                Text(
                  'cleared',
                  style: TextStyle(
                    color: Color(0xFF159A72),
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          if (state == 'locked')
            const Text(
              'Clear previous boss',
              style: TextStyle(
                color: Color(0xFF756B91),
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}

class _MeanderPathPainter extends CustomPainter {
  final List<Offset> points;

  _MeanderPathPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFFB8A2FF)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final double verticalOffset = (p1.dy - p0.dy) / 2;

      path.cubicTo(
        p0.dx,
        p0.dy + verticalOffset,
        p1.dx,
        p1.dy - verticalOffset,
        p1.dx,
        p1.dy,
      );
    }

    const dashLength = 14.0;
    const dashSpace = 11.0;

    final dashedPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + dashSpace;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _MeanderPathPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
