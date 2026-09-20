// /lib/features/parent/parent_layout.dart

import 'package:bossgrad/core/theme/app_colors.dart';
import 'package:bossgrad/core/theme/boss_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../shared/widgets/navigation.dart';
import '../../shared/widgets/top_header.dart';

class ParentLayout extends StatefulWidget {
  final Widget child;
  final String displayName;
  final NavPage currentPage;
  final ValueChanged<NavPage> onTabSelected;

  const ParentLayout({
    super.key,
    required this.child,
    required this.displayName,
    required this.currentPage,
    required this.onTabSelected,
  });

  @override
  State<ParentLayout> createState() => _ParentLayoutState();
}

class _ParentLayoutState extends State<ParentLayout> {
  bool _showUI = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BossGradTheme>()!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4EFFF),
      body: Stack(
        children: [
          // 1. BASE LINEAR GRADIENT
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.backgroundBase,
                    AppColors.backgroundMid,
                    AppColors.backgroundBottom,
                  ],
                  stops: [0.0, 0.72, 1.0],
                ),
              ),
            ),
          ),

          // 2. TOP-LEFT YELLOW GLOW (Smooth, screen-relative)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.8, -1.0),
                  radius: 1.2,
                  colors: [
                    AppColors.glowYellow.withOpacity(0.85),
                    AppColors.glowYellow.withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
          ),

          // 3. TOP-RIGHT PURPLE GLOW (Smooth, screen-relative)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.9, -1.0),
                  radius: 1.2,
                  colors: [
                    AppColors.glowPurple.withOpacity(0.8),
                    AppColors.glowPurple.withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
          ),

          // 4. SCROLL-AWARE PAGE CONTENT
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: NotificationListener<UserScrollNotification>(
                onNotification: (notification) {
                  if (notification.direction == ScrollDirection.reverse &&
                      _showUI) {
                    setState(() => _showUI = false);
                  } else if (notification.direction ==
                          ScrollDirection.forward &&
                      !_showUI) {
                    setState(() => _showUI = true);
                  }
                  return true;
                },
                child: widget.child,
              ),
            ),
          ),

          // TOP NAV BAR (Global replacement)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutExpo,
            top: _showUI ? 20 + MediaQuery.of(context).padding.top : -(100.0),
            left: 24,
            right: 24,
            child: TopHeader(
              theme: theme,
              displayName: widget.displayName,
              role: UserRole.parent,
              onSettingsTapped: () => widget.onTabSelected(NavPage.settings),
            ),
          ),

          // BOTTOM NAV BAR
          BossBottomNav(
            currentPage: widget.currentPage,
            isVisible: _showUI,
            onTabSelected: widget.onTabSelected,
            role: UserRole.parent,
          ),
        ],
      ),
    );
  }
}
