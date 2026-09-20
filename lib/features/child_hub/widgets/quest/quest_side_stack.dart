import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/boss_theme.dart';

class QuestSideStack extends StatelessWidget {
  final BossGradTheme theme;

  const QuestSideStack({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // // Streak Card
          // Container(
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     gradient: const LinearGradient(
          //       begin: Alignment.topLeft,
          //       end: Alignment.bottomRight,
          //       colors: [Color(0xFFFFF2AB), Color(0xFFFFFDF1)],
          //     ),
          //     borderRadius: BorderRadius.circular(24),
          //     border: Border.all(color: const Color(0xFFE5D9F4), width: 3),
          //     boxShadow: const [
          //       BoxShadow(color: Color(0xFFD8C9EB), offset: Offset(0, 6)),
          //     ],
          //   ),
          //   child: Row(
          //     children: [
          //       Stack(
          //         clipBehavior: Clip.none,
          //         children: [
          //           Container(
          //             width: 54,
          //             height: 54,
          //             decoration: BoxDecoration(
          //               color: const Color(0xFFFF8A48),
          //               borderRadius: BorderRadius.circular(16),
          //               boxShadow: const [
          //                 BoxShadow(
          //                   color: Color(0xFFD45B31),
          //                   offset: Offset(0, 5),
          //                 ),
          //               ],
          //             ),
          //             child: const Icon(
          //               LucideIcons.flame,
          //               color: Colors.white,
          //               size: 28,
          //             ),
          //           ),
          //           Positioned(
          //             right: -5,
          //             top: -7,
          //             child: Container(
          //               padding: const EdgeInsets.symmetric(
          //                 horizontal: 6,
          //                 vertical: 2,
          //               ),
          //               decoration: BoxDecoration(
          //                 color: const Color(0xFFFFD447),
          //                 borderRadius: BorderRadius.circular(99),
          //               ),
          //               child: const Text(
          //                 '+',
          //                 style: TextStyle(
          //                   color: Color(0xFF7B4B00),
          //                   fontWeight: FontWeight.w900,
          //                   fontSize: 10,
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //       const SizedBox(width: 12),
          //       Expanded(
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: const [
          //             Text(
          //               'ON FIRE',
          //               style: TextStyle(
          //                 color: Color(0xFF7554F6),
          //                 fontSize: 9,
          //                 fontWeight: FontWeight.w900,
          //                 letterSpacing: 1.2,
          //               ),
          //             ),
          //             Text(
          //               '5 day streak',
          //               style: TextStyle(
          //                 fontFamily: 'Fredoka',
          //                 fontSize: 14,
          //                 fontWeight: FontWeight.w900,
          //                 color: Color(0xFF241642),
          //               ),
          //             ),
          //             Text(
          //               '2 more days to earn the Flame Badge',
          //               style: TextStyle(
          //                 color: Color(0xFF756B91),
          //                 fontSize: 9,
          //                 fontWeight: FontWeight.w600,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 12),

          // Daily Mission Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5D9F4), width: 3),
              boxShadow: const [
                BoxShadow(color: Color(0xFFD8C9EB), offset: Offset(0, 6)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daily mission',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF241642),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EDFF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '0',
                        style: TextStyle(
                          color: theme.primaryAction,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // _MissionRow(
                //   icon: LucideIcons.bookOpen,
                //   iconBg: const Color(0xFFDCF8EE),
                //   iconColor: const Color(0xFF21C69A),
                //   title: 'Study for 15 minutes',
                //   subtitle: '9 min complete',
                //   reward: 25,
                //   progress: 0.6,
                // ),
                // const SizedBox(height: 14),
                // _MissionRow(
                //   icon: LucideIcons.award,
                //   iconBg: const Color(0xFFEEEAFF),
                //   iconColor: theme.primaryAction,
                //   title: 'Clear a boss battle',
                //   subtitle: 'Not started',
                //   reward: 50,
                //   progress: 0.0,
                // ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // // Avatar Card
          // Container(
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(24),
          //     border: Border.all(color: const Color(0xFFE5D9F4), width: 3),
          //     boxShadow: const [
          //       BoxShadow(color: Color(0xFFD8C9EB), offset: Offset(0, 6)),
          //     ],
          //   ),
          //   child: Column(
          //     children: [
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           const Text(
          //             'My avatar',
          //             style: TextStyle(
          //               fontFamily: 'Fredoka',
          //               fontSize: 16,
          //               fontWeight: FontWeight.w900,
          //               color: Color(0xFF241642),
          //             ),
          //           ),
          //           Row(
          //             children: [
          //               Text(
          //                 'Customize',
          //                 style: TextStyle(
          //                   color: theme.primaryAction,
          //                   fontSize: 9,
          //                   fontWeight: FontWeight.w900,
          //                 ),
          //               ),
          //               const SizedBox(width: 4),
          //               Icon(
          //                 LucideIcons.chevronRight,
          //                 color: theme.primaryAction,
          //                 size: 12,
          //               ),
          //             ],
          //           ),
          //         ],
          //       ),
          //       const SizedBox(height: 16),
          //       Row(
          //         children: [
          //           Container(
          //             width: 50,
          //             height: 50,
          //             alignment: Alignment.center,
          //             decoration: BoxDecoration(
          //               gradient: const LinearGradient(
          //                 begin: Alignment.topLeft,
          //                 end: Alignment.bottomRight,
          //                 colors: [Color(0xFF8F77FF), Color(0xFF5A3BD5)],
          //               ),
          //               borderRadius: BorderRadius.circular(16),
          //             ),
          //             child: const Text(
          //               'AJ',
          //               style: TextStyle(
          //                 color: Colors.white,
          //                 fontSize: 15,
          //                 fontWeight: FontWeight.w900,
          //               ),
          //             ),
          //           ),
          //           const SizedBox(width: 10),
          //           Expanded(
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 const Text(
          //                   'Astro Alex',
          //                   style: TextStyle(
          //                     fontSize: 13,
          //                     fontWeight: FontWeight.w900,
          //                     color: Color(0xFF241642),
          //                   ),
          //                 ),
          //                 const Text(
          //                   'Level 8 explorer',
          //                   style: TextStyle(
          //                     fontSize: 8,
          //                     fontWeight: FontWeight.w800,
          //                     color: Color(0xFF756B91),
          //                   ),
          //                 ),
          //                 const SizedBox(height: 6),
          //                 Container(
          //                   height: 4,
          //                   width: double.infinity,
          //                   decoration: BoxDecoration(
          //                     color: const Color(0xFFEDF0F5),
          //                     borderRadius: BorderRadius.circular(10),
          //                   ),
          //                   child: FractionallySizedBox(
          //                     alignment: Alignment.centerLeft,
          //                     widthFactor: 0.72,
          //                     child: Container(
          //                       decoration: BoxDecoration(
          //                         color: theme.primaryAction,
          //                         borderRadius: BorderRadius.circular(10),
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //                 const SizedBox(height: 4),
          //                 const Text(
          //                   '720 / 1000 XP',
          //                   style: TextStyle(
          //                     fontSize: 8,
          //                     fontWeight: FontWeight.w800,
          //                     color: Color(0xFF756B91),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _MissionRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final int reward;
  final double progress;

  const _MissionRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.reward,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF241642),
                ),
              ),
              if (progress > 0) ...[
                const SizedBox(height: 4),
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF0F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF21C69A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF756B91),
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          children: [
            Icon(
              LucideIcons.coins,
              color: progress == 0
                  ? const Color(0xFFAAB0BC)
                  : const Color(0xFFBC8700),
              size: 10,
            ),
            const SizedBox(width: 2),
            Text(
              '+$reward',
              style: TextStyle(
                color: progress == 0
                    ? const Color(0xFFAAB0BC)
                    : const Color(0xFFBC8700),
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
