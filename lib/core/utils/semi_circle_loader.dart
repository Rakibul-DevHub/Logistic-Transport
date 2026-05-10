// import 'dart:math';
// import 'package:flutter/material.dart';
// import '../theme/app_colors.dart';
//
// class SemiCircleLoader extends StatefulWidget {
//   const SemiCircleLoader({super.key});
//
//   @override
//   State<SemiCircleLoader> createState() => _SemiCircleLoaderState();
// }
//
// class _SemiCircleLoaderState extends State<SemiCircleLoader>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller =
//         AnimationController(vsync: this, duration: const Duration(seconds: 2))
//           ..repeat();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//         animation: _controller,
//         builder: (_, __) {
//           return Transform.rotate(
//             angle: _controller.value * 2 * pi,
//             child: CustomPaint(
//               painter: SemiCirclePainter(
//                 primaryColor:
//                     AppColors.primaryColor.withValues(alpha: 0.6),
//                 secondaryColor: AppColors.primaryColor,
//               ),
//               size: const Size(70, 70),
//             ),
//           );
//         });
//   }
// }
//
// class SemiCirclePainter extends CustomPainter {
//   final Color primaryColor;
//   final Color secondaryColor;
//
//   SemiCirclePainter({
//     required this.primaryColor,
//     required this.secondaryColor,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final strokeWidth = 14.0;
//     final rect = Offset.zero & size;
//
//     final paint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = strokeWidth
//       ..strokeCap = StrokeCap.round
//       ..shader = SweepGradient(
//         startAngle: 0.0,
//         endAngle: 3 * pi,
//         colors: [
//           // Color(0xff0B2F24DB),
//           primaryColor,
//           secondaryColor
//         ],
//       ).createShader(rect);
//
//     // Draw arc - adjust angles for "open gap"
//     canvas.drawArc(
//       Rect.fromLTWH(
//         strokeWidth / 2,
//         strokeWidth / 2,
//         size.width - strokeWidth,
//         size.height - strokeWidth,
//       ),
//       pi * 0.05, // start angle
//       pi * 1.8, // sweep angle
//       false,
//       paint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }





import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SemiCircleLoader extends StatefulWidget {
  const SemiCircleLoader({super.key});

  @override
  State<SemiCircleLoader> createState() => _SemiCircleLoaderState();
}

class _SemiCircleLoaderState extends State<SemiCircleLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
      builder: (_, __) {
        return Transform.rotate(
          angle: _controller.value * 2 * pi,
          child: CustomPaint(
            painter: SemiCirclePainter(
              primaryColor: AppColors.primaryColor.withValues(alpha: 0.8),
              secondaryColor: AppColors.primaryColor,
              backgroundColor: Colors.white,
            ),
            size: const Size(70, 70),
          ),
        );
      },
    );
  }
}

class SemiCirclePainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;

  SemiCirclePainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 14.0;

    final rect = Offset.zero & size;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: 2 * pi,
        stops: const [
          0.0,
          0.6,
          0.85,
          1.0,
        ],
        colors: [
          primaryColor,
          secondaryColor,
          secondaryColor.withOpacity(0.2),
          backgroundColor, // fade into white (vanishing tail)
        ],
      ).createShader(rect);

    final gap = 0.08; // small opening so it doesn't fully close

    canvas.drawArc(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      -pi / 2,
      2 * pi - gap,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}