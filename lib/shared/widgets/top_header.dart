// /lib/shared/widgets/top_header.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/boss_theme.dart';
import '../../core/audio_service.dart';
import '../../core/child_stat_service.dart';
import 'navigation.dart';

class TopHeader extends StatelessWidget {
  final BossGradTheme theme;
  final String displayName;
  final UserRole role;
  final VoidCallback? onSettingsTapped;

  // Child-specific fields
  final List<String> subjects;
  final String selectedSubject;
  final ValueChanged<String>? onSubjectChanged;

  const TopHeader({
    super.key,
    required this.theme,
    this.displayName = '',
    this.role = UserRole.child,
    this.onSettingsTapped,
    this.subjects = const [],
    this.selectedSubject = '',
    this.onSubjectChanged,
  });

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      barrierColor: const Color(0xFF241642).withOpacity(0.6),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5D9F4), width: 3),
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [
                BoxShadow(color: Color(0xFFD8C9EB), offset: Offset(0, 8)),
                BoxShadow(
                  color: Color(0x174E2C8B),
                  offset: Offset(0, 18),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE3E3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    LucideIcons.logOut,
                    color: Color(0xFFFF6578),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'End Session?',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF241642),
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Are you sure you want to log out and return to the character select screen?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF756B91),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF756B91),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          final prefs = await SharedPreferences.getInstance();
                          await FirebaseAuth.instance.signOut();
                          await prefs.remove('active_role');
                          await prefs.remove('child_name');
                          await prefs.remove('child_id');
                          await prefs.remove('child_uid');
                          await prefs.remove('child_coins');
                          await prefs.remove('child_xp');
                          await prefs.remove('child_rank');
                          if (context.mounted) {
                            Navigator.of(context)
                                .pushNamedAndRemoveUntil('/', (route) => false);
                          }
                        },
                        style:
                            ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6578),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ).copyWith(
                              side: WidgetStateProperty.all(
                                const BorderSide(
                                  color: Color(0xFFD44B5E),
                                  width: 0,
                                ),
                              ),
                            ),
                        child: const Text(
                          'Log out',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // If it's a child, wrap the entire header in an AnimatedBuilder to react to stats changes instantly
    if (role == UserRole.child) {
      return AnimatedBuilder(
        animation: Listenable.merge([
          ChildStatsService().coins,
          ChildStatsService().xp,
          ChildStatsService().rank,
          ChildStatsService().childName,
        ]),
        builder: (context, _) => _buildHeaderContent(context),
      );
    }

    return _buildHeaderContent(context);
  }

  Widget _buildHeaderContent(BuildContext context) {
    final activeName = role == UserRole.child
        ? ChildStatsService().childName.value
        : displayName;

    final initial = activeName.isNotEmpty
        ? activeName[0].toUpperCase()
        : (role == UserRole.parent ? 'C' : 'P');

    final roleTitle = role == UserRole.parent ? 'COMMANDER' : 'PLAYER';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: role == UserRole.parent
          ? MainAxisAlignment.start
          : MainAxisAlignment.spaceBetween,
      children: [
        // 1. Profile Pill and Audio Controls (Left)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: PopupMenuButton<String>(
                offset: const Offset(0, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFE5D9F4), width: 2),
                ),
                color: Colors.white,
                elevation: 8,
                onSelected: (value) {
                  if (value == 'logout') {
                    _showLogoutConfirmation(context);
                  } else if (value == 'settings' && onSettingsTapped != null) {
                    onSettingsTapped!();
                  }
                },
                itemBuilder: (context) {
                  final items = <PopupMenuEntry<String>>[
                    const PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.user,
                            size: 18,
                            color: Color(0xFF756B91),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'My Profile',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF241642),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ];

                  if (role == UserRole.parent) {
                    items.add(
                      const PopupMenuItem(
                        value: 'settings',
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.settings,
                              size: 18,
                              color: Color(0xFF756B91),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Settings',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF241642),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  items.add(const PopupMenuDivider());
                  items.add(
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.logOut,
                            size: 18,
                            color: Color(0xFFFF6578),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Log out',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFF6578),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  return items;
                },
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 6,
                    right: 14,
                    top: 6,
                    bottom: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: const Color(0xFFE5D9F4),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0xFFD8C9EB), offset: Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: theme.primaryAction,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF4D2AB4),
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            roleTitle,
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF756B91),
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            activeName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF241642),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        LucideIcons.chevronDown,
                        size: 16,
                        color: Color(0xFF756B91),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Reactive Mute Toggle Button
            ValueListenableBuilder<bool>(
              valueListenable: AudioService().isMuted,
              builder: (context, isMuted, _) {
                return GestureDetector(
                  onTap: () {
                    AudioService().toggleMute();
                    if (!isMuted) AudioService().playSfx('btn_click.wav');
                  },
                  child: Container(
                    width: 48,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE5D9F4),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFFD8C9EB),
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      isMuted ? LucideIcons.volumeX : LucideIcons.volume2,
                      color: isMuted
                          ? const Color(0xFFFF6578)
                          : const Color(0xFF756B91),
                      size: 20,
                    ),
                  ),
                );
              },
            ),
          ],
        ),

        if (role == UserRole.child) ...[
          const Spacer(),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _HeroStatPill(
                icon: LucideIcons.zap,
                value: '${ChildStatsService().xp.value}',
                label: 'XP',
                iconBg: const Color(0xFFE8DDFF),
                iconColor: theme.primaryAction,
              ),
              const SizedBox(width: 10),
              _HeroStatPill(
                icon: LucideIcons.coins,
                value: '${ChildStatsService().coins.value}',
                label: 'COINS',
                iconBg: const Color(0xFFFFD447),
                iconColor: const Color(0xFF7E5A00),
              ),
              const SizedBox(width: 10),
              _HeroStatPill(
                icon: LucideIcons.star,
                value: '${ChildStatsService().rank.value}',
                label: 'RANK',
                iconBg: const Color(0xFFFFF1AE),
                iconColor: const Color(0xFFD89400),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _HeroStatPill extends StatelessWidget {
  final String value;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final IconData icon;

  const _HeroStatPill({
    required this.value,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5D9F4), width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0xFFD8C9EB), offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 14),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF241642),
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF756B91),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
