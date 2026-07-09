import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedOnboardingButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLastPage;
  final AnimationController animationController;
  final int totalPages;
  final int currentIndex;

  const AnimatedOnboardingButton({
    super.key,
    required this.onPressed,
    required this.isLastPage,
    required this.animationController,
    required this.totalPages,
    required this.currentIndex,
  });

  @override
  State<AnimatedOnboardingButton> createState() => _AnimatedOnboardingButtonState();
}

class _AnimatedOnboardingButtonState extends State<AnimatedOnboardingButton> {
  late Animation<double> _widthAnimation;
  late Animation<Color?> _backgroundColorAnimation;
  late Animation<double> _alignmentAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _widthAnimation = Tween<double>(
      begin: 120.0,
      end: double.infinity,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeInOutCubic,
    ));

    _backgroundColorAnimation = ColorTween(
      begin: Colors.grey.shade200,
      end: const Color(0xFF1E3A5F),
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeInOutCubic,
    ));

    _alignmentAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        return AnimatedBuilder(
          animation: widget.animationController,
          builder: (context, child) {
            final animationValue = widget.animationController.value;

            // Calculate button width
            double buttonWidth;
            if (widget.isLastPage && animationValue >= 0.99) {
              buttonWidth = availableWidth;
            } else if (!widget.isLastPage && animationValue <= 0.01) {
              buttonWidth = 120;
            } else {
              buttonWidth = lerpDouble(120.0, availableWidth, animationValue)?.clamp(0.0, availableWidth) ?? 120.0;
            }

            // Calculate alignment
            final alignment = lerpDouble(1.0, 0.0, animationValue)?.clamp(-1.0, 1.0) ?? 1.0;

            // Determine text to show
            final shouldShowGetStarted = widget.isLastPage && animationValue >= 0.7;

            return Align(
              alignment: Alignment(alignment, 0),
              child: Container(
                width: buttonWidth,
                height: 56,
                decoration: BoxDecoration(
                  color: _backgroundColorAnimation.value,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: shouldShowGetStarted
                      ? [
                    BoxShadow(
                      color: const Color(0xFF1E3A5F).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onPressed,
                    borderRadius: BorderRadius.circular(28),
                    child: Center(
                      child: _buildButtonContent(shouldShowGetStarted, animationValue),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildButtonContent(bool showGetStarted, double animationValue) {
    if (showGetStarted) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Get Started",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 8),
          Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 20,
          ),
        ],
      );
    } else {
      final textColor = Color.lerp(
        const Color(0xFF1E3A5F),
        Colors.white,
        animationValue,
      );

      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Next",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward,
            color: textColor,
            size: 20,
          ),
        ],
      );
    }
  }
}