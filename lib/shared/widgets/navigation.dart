import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/boss_theme.dart';
import '../../../core/widgets/arcade_components.dart';

enum UserRole { parent, child }

enum NavPage { quest, boss, mission, tools, profile, library, settings }

class NavItemConfig {
  final NavPage id;
  final String label;
  final IconData icon;

  const NavItemConfig({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class BossTopBar extends StatelessWidget {
  final String displayName;
  final bool isVisible;
  final UserRole role;
  final ValueChanged<NavPage>? onTabSelected;

  const BossTopBar({
    super.key,
    required this.displayName,
    required this.isVisible,
    this.role = UserRole.parent,
    this.onTabSelected,
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
                          await prefs.remove('active_role');
                          await prefs.remove('child_name');
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
    return const SizedBox.shrink(); // Topbar logic removed as requested previously
  }
}

class BossBottomNav extends StatelessWidget {
  final NavPage currentPage;
  final ValueChanged<NavPage> onTabSelected;
  final bool isVisible;
  final UserRole role;

  const BossBottomNav({
    super.key,
    required this.currentPage,
    required this.onTabSelected,
    required this.isVisible,
    this.role = UserRole.parent,
  });

  static const List<NavItemConfig> _parentTabs = [
    NavItemConfig(
      id: NavPage.mission,
      label: 'MISSION',
      icon: LucideIcons.chartNoAxesCombined,
    ),
    NavItemConfig(
      id: NavPage.library,
      label: 'LIBRARY',
      icon: LucideIcons.library,
    ),
    NavItemConfig(
      id: NavPage.tools,
      label: 'TOOLS',
      icon: LucideIcons.scanLine,
    ),
  ];

  static const List<NavItemConfig> _childTabs = [
    NavItemConfig(id: NavPage.quest, label: 'QUEST', icon: LucideIcons.target),
    NavItemConfig(id: NavPage.boss, label: 'REWARDS', icon: LucideIcons.gift),
    NavItemConfig(
      id: NavPage.profile,
      label: 'PROFILE',
      icon: LucideIcons.user,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final rightPadding = MediaQuery.of(context).padding.right;
    final isChild = role == UserRole.child;
    final activeTabs = isChild ? _childTabs : _parentTabs;

    // Smart Margins: Use system safe area padding, but enforce a minimum 16px margin.
    // This prevents doubling up on padding on tablets.
    final safeBottomMargin = math.max(bottomPadding, 16.0);
    final safeRightMargin = math.max(rightPadding, 16.0);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutExpo,
      bottom: isVisible ? safeBottomMargin : -(100 + bottomPadding),

      // If child role, release the left constraint and pin perfectly to the right edge
      left: isChild ? null : 0,
      right: isChild ? safeRightMargin : 0,

      child: Row(
        mainAxisAlignment: isChild
            ? MainAxisAlignment.end
            : MainAxisAlignment.center,
        children: [
          Container(
            // Give a fixed width for the child so the right-anchored items distribute evenly
            width: isChild ? 320 : null,
            constraints: isChild ? null : const BoxConstraints(maxWidth: 420),
            child: Row(
              children: List.generate(
                activeTabs.length,
                (index) => _buildNavItem(activeTabs[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(NavItemConfig config) {
    final isActive = currentPage == config.id;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(config.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: 72,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF28C995)
                : Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isActive
                  ? const Color(0xFF15966F)
                  : const Color(0xFFE5D9F4),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? const Color(0xFF15966F)
                    : const Color(0xFFD8C9EB),
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                config.icon,
                color: isActive ? Colors.white : const Color(0xFF9689AE),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                config.label,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF9689AE),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
