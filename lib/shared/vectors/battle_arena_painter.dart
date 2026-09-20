import 'package:flutter/material.dart';

/// A custom painter that draws a dynamic, animated "Crystal Arena" background.
class BattleArenaPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0 (smoothly easing back and forth)

  BattleArenaPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. BASE GRADIENT
    final bgRect = Offset.zero & size;
    canvas.drawRect(
      bgRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8DCFF), Color(0xFFFFF8D9)],
        ).createShader(bgRect),
    );

    // 2. PULSING AURA / SUN IN BACKGROUND
    final auraCenter = Offset(w * 0.5, h * 0.35);
    final pulseRadius = 180 + (progress * 40); // Breathes slightly
    canvas.drawCircle(
      auraCenter,
      pulseRadius,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.white.withOpacity(0.8),
                Colors.white.withOpacity(0.0),
              ],
            ).createShader(
              Rect.fromCircle(center: auraCenter, radius: pulseRadius),
            ),
    );

    // Helper to draw a 3D-ish floating crystal shard
    void drawCrystal(
      Offset pos,
      double scale,
      Color leftColor,
      Color rightColor,
      double yOffset,
    ) {
      final p = pos.translate(0, yOffset);
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.scale(scale);

      // Left facet
      final leftPath = Path()
        ..moveTo(0, -50)
        ..lineTo(-20, 0)
        ..lineTo(0, 80)
        ..close();
      canvas.drawPath(leftPath, Paint()..color = leftColor);

      // Right facet
      final rightPath = Path()
        ..moveTo(0, -50)
        ..lineTo(20, -10)
        ..lineTo(0, 80)
        ..close();
      canvas.drawPath(rightPath, Paint()..color = rightColor);

      canvas.restore();
    }

    // Determine the float offset (since progress naturally goes 0 -> 1 -> 0)
    // multiplying it directly by a value gives a smooth bobbing motion.
    final floatOffset = progress * 25;

    // 3. BACKGROUND CRYSTALS (Smaller, move inversely to create parallax depth)
    drawCrystal(
      Offset(w * 0.15, h * 0.65),
      0.8,
      const Color(0xFFD4C5F9),
      const Color(0xFFBCA5F0),
      -floatOffset * 0.6,
    );
    drawCrystal(
      Offset(w * 0.85, h * 0.55),
      0.6,
      const Color(0xFFD4C5F9),
      const Color(0xFFBCA5F0),
      floatOffset * 0.8,
    );

    // 4. FOREGROUND CRYSTALS (Larger, more vibrant, move directly with the float)
    drawCrystal(
      Offset(w * 0.25, h * 0.85),
      1.5,
      const Color(0xFFBCA5F0),
      const Color(0xFF9B7DE5),
      floatOffset,
    );
    drawCrystal(
      Offset(w * 0.75, h * 0.80),
      1.3,
      const Color(0xFFBCA5F0),
      const Color(0xFF9B7DE5),
      -floatOffset * 1.2,
    );

    // Add one tiny floating shard up high for atmosphere
    drawCrystal(
      Offset(w * 0.4, h * 0.25),
      0.3,
      const Color(0xFFFFFFFF),
      const Color(0xFFE8DCFF),
      floatOffset * 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant BattleArenaPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
