import 'package:flutter/material.dart';

class ArcadeCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ArcadeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(28),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
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
      child: child,
    );
  }
}

class BossAvatar extends StatelessWidget {
  final String initials;
  final String colorType;
  final double size;

  const BossAvatar({
    super.key,
    required this.initials,
    required this.colorType,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [const Color(0xFF9B83FF), const Color(0xFF5F44DC)];
    if (colorType == 'mint')
      colors = [const Color(0xFF56E3B8), const Color(0xFF0DA37C)];
    if (colorType == 'coral')
      colors = [const Color(0xFFFF9F9F), const Color(0xFFE65050)];

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(size * 0.35),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Fredoka',
          fontWeight: FontWeight.w900,
          fontSize: size * 0.45,
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String bigNum;
  final String smallNum;
  final String trend;
  final Color bg;
  final Color border;
  final Color trendColor;

  const StatCard({
    super.key,
    required this.title,
    required this.bigNum,
    required this.smallNum,
    required this.trend,
    required this.bg,
    required this.border,
    required this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 3),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(color: Color(0x1F5A3989), offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF756B91),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Color(0xFF241642),
                letterSpacing: -2.0,
              ),
              children: [
                TextSpan(text: bigNum),
                TextSpan(
                  text: smallNum,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Color(0xFFA4ADBB),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            trend,
            style: TextStyle(
              color: trendColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityRow extends StatelessWidget {
  final String title;
  final String detail;
  final String time;
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final bool isLast;

  const ActivityRow({
    super.key,
    required this.title,
    required this.detail,
    required this.time,
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFEADFF7), width: 2),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF241642),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF756B91),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF756B91),
            ),
          ),
        ],
      ),
    );
  }
}
