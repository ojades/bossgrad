import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../shared/vectors/vector_landscape_painter.dart';
import '../../shared/widgets/navigation.dart';

class ChildLayout extends StatefulWidget {
  final Widget child;
  final String displayName;
  final NavPage currentPage;
  final ValueChanged<NavPage> onTabSelected;

  const ChildLayout({
    super.key,
    required this.child,
    required this.displayName,
    required this.currentPage,
    required this.onTabSelected,
  });

  @override
  State<ChildLayout> createState() => _ChildLayoutState();
}

class _ChildLayoutState extends State<ChildLayout> {
  bool _showUI = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EFFF),
      body: Stack(
        children: [
          // 1. DYNAMIC VECTOR LANDSCAPE BACKGROUND
          Positioned.fill(
            child: CustomPaint(painter: VectorLandscapePainter()),
          ),

          // 2. SCROLL-AWARE PAGE CONTENT
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

          // 3. BOTTOM NAV BAR (Child Role)
          BossBottomNav(
            currentPage: widget.currentPage,
            isVisible: _showUI,
            onTabSelected: widget.onTabSelected,
            role: UserRole.child,
          ),
        ],
      ),
    );
  }
}
