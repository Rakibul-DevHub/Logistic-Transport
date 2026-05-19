import 'dart:math' as math;
import 'dart:ui' as ui;
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
  final Color? backgroundColor;

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
          painter: _OptimizedGradientArcPainter(
            progress: _controller.value,
            size: widget.size,
          ),
        );
      },
    );
  }
}

class _OptimizedGradientArcPainter extends CustomPainter {
  final double progress;
  final double size;

  // Pre-calculated constants
  static const double _sweepAngle = 5.7; // ~326 degrees in radians
  static const int _segments = 40; // Reduced from 120 to 40 segments (66% reduction)

  // Pre-cached colors for better performance
  static final List<Color> _gradientColors = _buildGradientColors();

  _OptimizedGradientArcPainter({
    required this.progress,
    required this.size,
  });

  static List<Color> _buildGradientColors() {
    return [
      const Color(0x00C8D3E0), // transparent
      const Color(0xFFBDCAD8), // light silvery blue
      const Color(0xFF7A90A8), // medium steel blue
      const Color(0xFF2B3F5E), // dark navy
    ];
  }

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(size / 2, size / 2);
    final strokeWidth = size * 0.155;
    final radius = (size - strokeWidth) / 2;

    // Rotation angle based on animation progress
    final rotation = 2 * math.pi * progress;

    // Draw the gradient arc using optimized segment approach
    _drawOptimizedGradientArc(
      canvas: canvas,
      center: center,
      radius: radius,
      strokeWidth: strokeWidth,
      startAngle: rotation,
    );

    // Draw rounded cap at the dark (tail) end
    _drawRoundedCap(
      canvas: canvas,
      center: center,
      radius: radius,
      angle: rotation + _sweepAngle,
      strokeWidth: strokeWidth,
    );
  }

  void _drawOptimizedGradientArc({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double strokeWidth,
    required double startAngle,
  }) {
    final anglePerSegment = _sweepAngle / _segments;

    for (int i = 0; i < _segments; i++) {
      final t = i / _segments;
      final color = _getColorAtPoint(t);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      final segmentStart = startAngle + i * anglePerSegment;
      final rect = Rect.fromCircle(center: center, radius: radius);

      // Draw slightly larger segments to avoid gaps
      canvas.drawArc(rect, segmentStart, anglePerSegment + 0.002, false, paint);
    }
  }

  Color _getColorAtPoint(double t) {
    // Optimized color interpolation without function calls
    if (t < 0.35) {
      final localT = t / 0.35;
      final easedT = localT * localT; // _easeIn inline
      return Color.lerp(
        _gradientColors[0],
        _gradientColors[1],
        easedT,
      )!;
    } else if (t < 0.65) {
      final localT = (t - 0.35) / 0.30;
      return Color.lerp(
        _gradientColors[1],
        _gradientColors[2],
        localT,
      )!;
    } else {
      final localT = (t - 0.65) / 0.35;
      final easedT = 1 - (1 - localT) * (1 - localT); // _easeOut inline
      return Color.lerp(
        _gradientColors[2],
        _gradientColors[3],
        easedT,
      )!;
    }
  }

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
      ..color = _gradientColors[3] // Dark navy
      ..style = PaintingStyle.fill;

    canvas.drawCircle(capCenter, strokeWidth / 2, capPaint);
  }

  @override
  bool shouldRepaint(_OptimizedGradientArcPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.size != size;
  }
}