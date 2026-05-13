import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A reusable rotating arc loader that fades from dark navy → steel blue → transparent
///
/// Usage:
/// ```dart
/// GradientArcLoader(
///   size: 200,
///   duration: Duration(milliseconds: 1400),
/// )
/// ```
class GradientArcLoader extends StatefulWidget {
  final double size;
  final Duration duration;
  final Color? backgroundColor; // Optional background color override

  const GradientArcLoader({
    super.key,
    this.size = 200,
    this.duration = const Duration(milliseconds: 1400),
    this.backgroundColor,
  });

  @override
  State<GradientArcLoader> createState() => _GradientArcLoaderState();
}

class _GradientArcLoaderState extends State<GradientArcLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
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
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _GradientArcPainter(
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _GradientArcPainter extends CustomPainter {
  final double progress;

  _GradientArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.155;
    final radius = (size.width - strokeWidth) / 2;

    // Rotation angle based on animation progress
    final rotation = 2 * math.pi * progress;

    // Arc sweep: ~300 degrees (the arc doesn't fully close)
    const sweepAngle = 5.7; // ~326 degrees in radians

    // The arc starts at the "transparent" end and ends at the "dark" end.
    _drawGradientArc(
      canvas: canvas,
      center: center,
      radius: radius,
      strokeWidth: strokeWidth,
      startAngle: rotation,
      sweepAngle: sweepAngle,
    );

    // Draw rounded cap at the dark (tail) end
    _drawRoundedCap(
      canvas: canvas,
      center: center,
      radius: radius,
      angle: rotation + sweepAngle,
      strokeWidth: strokeWidth,
    );
  }

  void _drawGradientArc({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double strokeWidth,
    required double startAngle,
    required double sweepAngle,
  }) {
    // Approximate the gradient arc by drawing many small segments
    const segments = 120;
    final anglePerSegment = sweepAngle / segments;

    for (final i in List.generate(segments, (i) => i)) {
      final t = i / segments; // 0 = transparent end, 1 = dark end
      final color = _lerpColor(t);

      final segmentStart = startAngle + i * anglePerSegment;
      final segmentSweep = anglePerSegment + 0.002; // tiny overlap to avoid gaps

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, segmentStart, segmentSweep, false, paint);
    }
  }

  Color _lerpColor(double t) {
    if (t < 0.35) {
      // transparent → light silvery blue
      final localT = t / 0.35;
      return Color.lerp(
        const Color(0x00C8D3E0), // fully transparent
        const Color(0xFFBDCAD8), // light silvery blue
        _easeIn(localT),
      )!;
    } else if (t < 0.65) {
      // light silver → medium steel blue
      final localT = (t - 0.35) / 0.30;
      return Color.lerp(
        const Color(0xFFBDCAD8), // light silver
        const Color(0xFF7A90A8), // medium steel blue
        localT,
      )!;
    } else {
      // medium steel → dark navy
      final localT = (t - 0.65) / 0.35;
      return Color.lerp(
        const Color(0xFF7A90A8), // medium steel blue
        const Color(0xFF2B3F5E), // dark navy
        _easeOut(localT),
      )!;
    }
  }

  double _easeIn(double t) => t * t;
  double _easeOut(double t) => 1 - (1 - t) * (1 - t);

  void _drawRoundedCap({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double angle,
    required double strokeWidth,
  }) {
    final capCenter = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    final capPaint = Paint()
      ..color = const Color(0xFF2B3F5E)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(capCenter, strokeWidth / 2, capPaint);
  }

  @override
  bool shouldRepaint(_GradientArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}