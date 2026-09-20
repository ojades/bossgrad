import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/boss_theme.dart';
import '../../../core/widgets/arcade_components.dart';
import 'manage_squad_modal.dart';

class SquadCard extends StatefulWidget {
  final List<Map<String, dynamic>> childrenList;
  final bool isLoading;
  final VoidCallback onRefresh;

  const SquadCard({
    super.key,
    required this.childrenList,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  State<SquadCard> createState() => _SquadCardState();
}

class _SquadCardState extends State<SquadCard> {
  int _selectedChildIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BossGradTheme>()!;

    if (_selectedChildIndex >= widget.childrenList.length) {
      _selectedChildIndex = 0;
    }

    final child = widget.childrenList.isNotEmpty
        ? widget.childrenList[_selectedChildIndex]
        : null;

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
                    'YOUR SQUAD',
                    style: TextStyle(
                      color: Color(0xFF7447F5),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Learning progress',
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
              TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ManageSquadModal(
                      childrenList: widget.childrenList,
                      onRefresh: widget.onRefresh,
                    ),
                  );
                },
                child: const Row(
                  children: [
                    Text(
                      'Manage Squad',
                      style: TextStyle(
                        color: Color(0xFF7447F5),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      LucideIcons.settings2,
                      size: 14,
                      color: Color(0xFF7447F5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // LOADING STATE
          if (widget.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF7447F5)),
              ),
            )
          // EMPTY STATE
          else if (widget.childrenList.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No players in your squad yet.\nTap "Manage Squad" to add your first explorer!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF756B91),
                  ),
                ),
              ),
            )
          // POPULATED STATE
          else ...[
            // Tabs
            Row(
              children: List.generate(widget.childrenList.length, (index) {
                final isSelected = _selectedChildIndex == index;
                final c = widget.childrenList[index];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedChildIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFF5B8)
                            : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFE8CA57)
                              : const Color(0xFFEADFF7),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? const Color(0xFFD1B63D)
                                : const Color(0xFFDED2EF),
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          BossAvatar(
                            initials: c['initials'],
                            colorType: c['color'],
                            size: 36,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c['name'],
                                  style: const TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF241642),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  c['grade'],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF756B91),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(color: Color(0xFFEADFF7), thickness: 2),
            ),

            // Selected Child Detail
            Row(
              children: [
                BossAvatar(
                  initials: child!['initials'],
                  colorType: child['color'],
                  size: 56,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child['name'],
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF241642),
                      ),
                    ),
                    Text(
                      '${child['grade']} ',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF756B91),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5D5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.star,
                        size: 18,
                        color: Color(0xFF916E00),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ' ${child['rank']}',
                        style: const TextStyle(
                          color: Color(0xFF916E00),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Progress Bar
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFEAEDF2),
                borderRadius: BorderRadius.circular(99),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (child['progress'] as num).toDouble(),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.primaryAction,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF756B91),
                    ),
                    children: [
                      TextSpan(
                        text:
                            '${((child['progress'] as num).toDouble() * 100).toInt()}%',
                        style: TextStyle(
                          color: theme.primaryAction,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const TextSpan(text: ' term progress'),
                    ],
                  ),
                ),
                Text(
                  '${child['total_cleared']} / ${child['total_levels']} quests',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF756B91),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Dynamic Subjects Grid
            _buildDynamicSubjectsGrid(
              child['subjects'] as List<dynamic>? ?? [],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDynamicSubjectsGrid(List<dynamic> subjects) {
    if (subjects.isEmpty) {
      return const SizedBox(
        height: 60,
        child: Center(
          child: Text(
            'No quests assigned yet.',
            style: TextStyle(
              color: Color(0xFF756B91),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final uiConfigs = [
      {
        'bg': const Color(0xFFD9F8ED),
        'iconColor': const Color(0xFF28C995),
        'icon': LucideIcons.bookOpen,
      },
      {
        'bg': const Color(0xFFFFF1C5),
        'iconColor': const Color(0xFFD79806),
        'icon': LucideIcons.zap,
      },
      {
        'bg': const Color(0xFFFFE1E1),
        'iconColor': const Color(0xFFFF6578),
        'icon': LucideIcons.wandSparkles,
      },
    ];

    // Take max 3 subjects to fit the grid neatly
    final displaySubjects = subjects.take(3).toList();

    return Row(
      children: displaySubjects.asMap().entries.map((entry) {
        final i = entry.key;
        final sub = entry.value as Map<String, dynamic>;
        final conf = uiConfigs[i % uiConfigs.length];

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: i < displaySubjects.length - 1 ? 12.0 : 0,
            ),
            child: _buildSubjectBlock(
              sub['name'] as String,
              '${sub['cleared']} / ${sub['total']} cleared',
              (sub['progress'] as num).toDouble(),
              conf['bg'] as Color,
              conf['iconColor'] as Color,
              conf['icon'] as IconData,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubjectBlock(
    String title,
    String subtitle,
    double progress,
    Color iconBg,
    Color iconColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Color(0xFF241642),
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF756B91),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFEAEDF2),
              borderRadius: BorderRadius.circular(99),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
