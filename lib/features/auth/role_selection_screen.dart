import 'package:bossgrad/core/audio_service.dart';
import 'package:flutter/material.dart';

import '../../core/theme/boss_theme.dart';

class RoleSelectionScreen extends StatefulWidget {
  final VoidCallback onParentSelected;
  final VoidCallback onChildSelected;

  const RoleSelectionScreen({
    super.key,
    required this.onParentSelected,
    required this.onChildSelected,
  });
  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        AudioService().playBgm('auth.wav');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BossGradTheme>()!;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.32, 1.0],
            colors: [Color(0xFFFFF1A8), Color(0xFFFFF8DF), Color(0xFFE8DDFF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              // Reduced outer vertical padding
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                // Reduced inner vertical padding
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(color: const Color(0xFFEADCF8), width: 4),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFCDBBE8), offset: Offset(0, 8)),
                    BoxShadow(
                      color: Color(0x294C2A82),
                      offset: Offset(0, 20),
                      blurRadius: 35,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36, // Slightly smaller logo
                          height: 36,
                          decoration: BoxDecoration(
                            color: theme.primaryAction,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF4D2AB4),
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: BossColors.backgroundSlate,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Boss',
                                style: TextStyle(color: Color(0xFF172033)),
                              ),
                              TextSpan(
                                text: 'Grad',
                                style: TextStyle(color: theme.primaryAction),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16), // Tighter spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: theme.primaryAction,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'YOUR LEARNING ADVENTURE',
                          style: TextStyle(
                            color: theme.primaryAction,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 34, // Scaled down from 42 for landscape fit
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          color: Color(0xFF172033),
                        ),
                        children: [
                          const TextSpan(text: 'Who\'s entering\n'),
                          TextSpan(
                            text: 'the arena?',
                            style: TextStyle(color: theme.primaryAction),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose your player to continue the quest.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF697386),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20), // Tighter spacing before cards
                    _RoleCard(
                      title: 'I\'m a parent',
                      subtitle: 'Mission control & family progress',
                      icon: Icons.shield_outlined,
                      iconBg: const Color(0xFFEEE8FF),
                      iconColor: theme.primaryAction,
                      onTap: () {
                        AudioService().playSfx('btn_click.wav');
                        widget.onParentSelected();
                      },
                    ),
                    const SizedBox(height: 10),
                    _RoleCard(
                      title: 'I\'m a learner',
                      subtitle: 'Enter the quest and earn XP',
                      icon: Icons.sports_esports_outlined,
                      iconBg: const Color(0xFFFFF1AE),
                      iconColor: const Color(0xFF9C7200),
                      onTap: () {
                        AudioService().playSfx('btn_click.wav');
                        widget.onChildSelected();
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'New here? Pick a role to start your first quest.',
                      style: TextStyle(
                        color: Color(0xFF9B91AD),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ), // Reduced card padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8DEF5), width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFDFD1EF),
              offset: Offset(0, 4),
            ), // Smaller shadow for compact fit
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44, // Slightly smaller icon box
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF172033),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF697386),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context)
                  .extension<BossGradTheme>()!
                  .primaryAction,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
