import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animated neon parametric heart.
///
/// This is a reusable visual component. It is not yet wired to maze collision
/// or an extra-life mechanic; see README.md for integration notes.
class HeartPowerUp extends StatefulWidget {
  const HeartPowerUp({super.key, this.size = 120});

  final double size;

  @override
  State<HeartPowerUp> createState() => _HeartPowerUpState();
}

class _HeartPowerUpState extends State<HeartPowerUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => CustomPaint(
        size: Size.square(widget.size),
        painter: HeartPainter(progress: _controller.value),
      ),
    );
  }
}

class HeartPainter extends CustomPainter {
  const HeartPainter({required this.progress});

  final double progress;
  static const Color neonGreen = Color(0xFF39FF14);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final pulse = 1.0 + 0.07 * math.sin(progress * 2 * math.pi);
    final scale = math.min(size.width, size.height) * 0.105 * pulse;
    final path = Path();
    const steps = 240;
    final endT = progress * 2 * math.pi;

    for (int i = 0; i <= steps; i++) {
      final t = endT * i / steps;
      final x = 3.5 * math.sin(t) - math.sin(3 * t);
      // The source notation cos^1(2t) was ambiguous; this uses cos²(2t).
      final cos2t = math.cos(2 * t);
      final y = 4 * math.cos(t) - 1.5 * cos2t * cos2t;
      final point = Offset(center.dx + x * scale, center.dy - y * scale);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    if (progress >= 0.999) {
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFB6FF00), Color(0xFF39FF14), Color(0xFF00FFA3)],
          ).createShader(Offset.zero & size)
          ..style = PaintingStyle.fill,
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = neonGreen.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = neonGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(
      center,
      2.5 + 1.5 * progress,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant HeartPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
