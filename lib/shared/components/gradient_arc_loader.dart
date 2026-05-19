import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Optimized Gradient Arc Loader - 60fps
class GradientArcLoader extends StatefulWidget {
  final double size;
  final Duration duration;

  const GradientArcLoader({
    super.key,
    this.size = 200,
    this.duration = const Duration(milliseconds: 1400),
  });

  @override
  State<GradientArcLoader> createState() => _GradientArcLoaderState();
}

class _GradientArcLoaderState extends State<GradientArcLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late final _FastPainter _painter;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _painter = _FastPainter(
      size: widget.size,
    );
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
      builder: (context, child) {
        _painter.progress = _controller.value;
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _painter,
        );
      },
    );
  }
}

class _FastPainter extends CustomPainter {
  double progress = 0;
  final double size;

  // Pre-calculated values
  late final double _strokeWidth;
  late final double _radius;
  late final Offset _center;

  // Reusable paint objects
  final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.butt;

  final Paint _capPaint = Paint()..style = PaintingStyle.fill;

  // Pre-computed colors (20 segments)
  static final List<Color> _colors = List.generate(20, (i) {
    final t = i / 20;
    if (t < 0.35) {
      return Color.lerp(
        const Color(0x00C8D3E0),
        const Color(0xFFBDCAD8),
        (t / 0.35) * (t / 0.35),
      )!;
    } else if (t < 0.65) {
      return Color.lerp(
        const Color(0xFFBDCAD8),
        const Color(0xFF7A90A8),
        (t - 0.35) / 0.30,
      )!;
    } else {
      final localT = (t - 0.65) / 0.35;
      final easedT = 1 - (1 - localT) * (1 - localT);
      return Color.lerp(
        const Color(0xFF7A90A8),
        const Color(0xFF2B3F5E),
        easedT,
      )!;
    }
  });

  _FastPainter({required this.size}) {
    _strokeWidth = size * 0.155;
    _radius = (size - _strokeWidth) / 2;
    _center = Offset(size / 2, size / 2);
  }

  @override
  void paint(Canvas canvas, Size canvasSize) {
    const sweepAngle = 5.7;
    const segments = 20;
    final anglePerSegment = sweepAngle / segments;
    final startAngle = 2 * math.pi * progress;

    // Draw segments
    for (int i = 0; i < segments; i++) {
      _paint.color = _colors[i];
      _paint.strokeWidth = _strokeWidth;

      canvas.drawArc(
        Rect.fromCircle(center: _center, radius: _radius),
        startAngle + i * anglePerSegment,
        anglePerSegment + 0.002,
        false,
        _paint,
      );
    }

    // Draw cap
    final capAngle = startAngle + sweepAngle;
    final capCenter = Offset(
      _center.dx + _radius * math.cos(capAngle),
      _center.dy + _radius * math.sin(capAngle),
    );

    _capPaint.color = const Color(0xFF2B3F5E);
    canvas.drawCircle(capCenter, _strokeWidth / 2, _capPaint);
  }

  @override
  bool shouldRepaint(_FastPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}