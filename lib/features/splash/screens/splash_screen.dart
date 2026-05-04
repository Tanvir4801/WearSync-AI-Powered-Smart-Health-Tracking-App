import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _strapController;
  late final AnimationController _logoController;
  late final AnimationController _glowController;
  late final AnimationController _ringController;

  late final Animation<double> _strapSlide;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _glowRadius;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _strapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _strapSlide = Tween<double>(begin: 0, end: 120).animate(
      CurvedAnimation(parent: _strapController, curve: Curves.easeOutBack),
    );

    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.42, 1, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.42, 1, curve: Curves.easeOutBack),
      ),
    );

    _glowRadius = Tween<double>(begin: 60, end: 120).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _strapController.forward();
    _logoController.forward();

    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) {
        return;
      }
      _glowController.repeat(reverse: true);
      _ringController.repeat();
    });

    Future<void>.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) {
        return;
      }

      final bool loggedIn = FirebaseAuth.instance.currentUser != null;
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      context.go(loggedIn ? '/shell' : '/login');
    });
  }

  @override
  void dispose() {
    _strapController.dispose();
    _logoController.dispose();
    _glowController.dispose();
    _ringController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[
            _strapController,
            _logoController,
            _glowController,
            _ringController,
          ]),
          builder: (BuildContext context, Widget? child) {
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Center(
                  child: Container(
                    width: _glowRadius.value * 2,
                    height: _glowRadius.value * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF4FC3F7).withValues(alpha: 0.08),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color:
                              const Color(0xFF4FC3F7).withValues(alpha: 0.22),
                          blurRadius: _glowRadius.value,
                          spreadRadius: _glowRadius.value * 0.15,
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: CustomPaint(
                    size: const Size.square(320),
                    painter: _DashedPulseRingsPainter(
                      progress: _ringController.value,
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 340,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Transform.translate(
                          offset: Offset(-_strapSlide.value, 0),
                          child: const _StrapImage(
                            assetPath: 'assets/left.png',
                            width: 152,
                            alignment: Alignment.centerRight,
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(_strapSlide.value, 0),
                          child: const _StrapImage(
                            assetPath: 'assets/right.png',
                            width: 152,
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.asset(
                          'assets/logo.png',
                          width: 112,
                          height: 112,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            BuildContext context,
                            Object error,
                            StackTrace? stackTrace,
                          ) {
                            return Container(
                              width: 112,
                              height: 112,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A2239),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: const Icon(
                                Icons.watch,
                                color: Colors.white,
                                size: 48,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StrapImage extends StatelessWidget {
  const _StrapImage({
    required this.assetPath,
    required this.width,
    required this.alignment,
  });

  final String assetPath;
  final double width;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Image.asset(
        assetPath,
        width: width,
        fit: BoxFit.contain,
        errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
        ) {
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DashedPulseRingsPainter extends CustomPainter {
  const _DashedPulseRingsPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    _paintRing(canvas, size, progress);
    _paintRing(canvas, size, (progress + 0.5) % 1);
  }

  void _paintRing(Canvas canvas, Size size, double t) {
    final Offset center = size.center(Offset.zero);
    final double radius = 64 + (84 * Curves.easeOut.transform(t));
    final double opacity = ((1 - t) * 0.15).clamp(0.08, 0.15);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = Colors.white.withValues(alpha: opacity)
      ..strokeCap = StrokeCap.round;

    const double dashLength = 0.18;
    const double gapLength = 0.10;
    double angle = -math.pi / 2;

    while (angle < (math.pi * 2) - (math.pi / 2)) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle,
        dashLength,
        false,
        paint,
      );
      angle += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPulseRingsPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
