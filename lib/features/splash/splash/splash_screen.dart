import 'package:bossgrad/core/audio_service.dart';
import 'package:flutter/material.dart';

class AnimatedSplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const AnimatedSplashScreen({super.key, required this.onComplete});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconScale;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  bool _soundPlayed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 0.0s - 0.6s: Icon bounces in
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
      ),
    );

    // 0.6s - 1.0s: Text fades in and slides up
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.75, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.45, 0.75, curve: Curves.easeOutCubic),
          ),
        );

    _controller.addListener(() {
      // Trigger the sound effect right as the text begins to appear
      if (_controller.value >= 0.45 && !_soundPlayed) {
        _soundPlayed = true;
        AudioService().playSfx('splash_1.wav');
      }
    });

    // Start animation, wait an extra 600ms on screen, then route away
    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) widget.onComplete();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF241642,
      ), // Deep purple matching native splash
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _iconScale,
              child: Image.asset(
                'assets/images/bossgrad_logo_icon.png',
                width: 140,
                height: 140,
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _textOpacity,
              child: SlideTransition(
                position: _textSlide,
                child: Image.asset(
                  'assets/images/bossgrad-logo_name.png',
                  width: 220,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
