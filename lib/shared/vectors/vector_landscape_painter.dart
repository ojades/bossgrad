import 'package:flutter/material.dart';

/// Draws a vibrant, layered vector landscape inspired by classic adventure games.
class VectorLandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 1. SKY GRADIENT
    final skyRect = Rect.fromLTWH(0, 0, width, height);
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF6B4EE6), // Deep violet sky
          Color(0xFFB180F3), // Mid purple
          Color(0xFFFFB677), // Warm horizon
          Color(0xFFFFF1A8), // Bright sun glow
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      ).createShader(skyRect);
    canvas.drawRect(skyRect, skyPaint);

    // 2. GLOWING SUN
    final sunCenter = Offset(width * 0.8, height * 0.55);
    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          const Color(0xFFFFF5BB),
          const Color(0xFFFFF5BB).withOpacity(0.0),
        ],
        stops: const [0.2, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: 120));
    canvas.drawCircle(sunCenter, 120, sunPaint);

    // 3. DISTANT MOUNTAINS (Polygonal)
    final mountainPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF8B64DC), Color(0xFF5F44DC)],
      ).createShader(skyRect);

    final mountainPath = Path()
      ..moveTo(0, height * 0.60)
      ..lineTo(width * 0.15, height * 0.45)
      ..lineTo(width * 0.35, height * 0.65)
      ..lineTo(width * 0.55, height * 0.38)
      ..lineTo(width * 0.75, height * 0.58)
      ..lineTo(width * 0.90, height * 0.48)
      ..lineTo(width, height * 0.60)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    canvas.drawPath(mountainPath, mountainPaint);

    // 4. MIDGROUND HILLS (Smooth Beziers)
    final midHillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF492EAE), Color(0xFF321E82)],
      ).createShader(skyRect);

    final midHillPath = Path()
      ..moveTo(0, height * 0.70)
      ..quadraticBezierTo(
        width * 0.25,
        height * 0.55,
        width * 0.5,
        height * 0.75,
      )
      ..quadraticBezierTo(width * 0.8, height * 0.90, width, height * 0.65)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    canvas.drawPath(midHillPath, midHillPaint);

    // 5. FOREGROUND LANDSCAPE
    final foregroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF231454), Color(0xFF170C3A)],
      ).createShader(skyRect);

    final foregroundPath = Path()
      ..moveTo(0, height * 0.85)
      ..quadraticBezierTo(
        width * 0.3,
        height * 0.75,
        width * 0.6,
        height * 0.90,
      )
      ..quadraticBezierTo(width * 0.8, height * 0.98, width, height * 0.80)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    canvas.drawPath(foregroundPath, foregroundPaint);

    // 6. ATMOSPHERIC FOG OVERLAY
    final fogPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.0),
          const Color(0xFFF4EFFF).withOpacity(0.4),
          const Color(0xFFF4EFFF).withOpacity(0.8),
        ],
        stops: const [0.5, 0.8, 1.0],
      ).createShader(skyRect);
    canvas.drawRect(skyRect, fogPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
