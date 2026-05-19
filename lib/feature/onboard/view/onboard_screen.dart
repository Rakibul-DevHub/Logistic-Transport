/**
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/constants/app_routes.dart';
import '../controller/onboard_cubit.dart';
import '../model/onboarding_model_data.dart';
import '../widget/animated_onboarding_button.dart';
import '../widget/onboarding_page_content.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _buttonAnimationController;
  late OnboardingCubit _cubit;

  final List<OnboardingData> pages = const [
    OnboardingData(
      title: "Track Every Mile. Count Every Dollar.",
      subtitle: "All your trucking business, simplified in one app.",
      assetPath: "assets/images/onboard_1.png",
    ),
    OnboardingData(
      title: "Automate Your Expenses",
      subtitle: "Fuel, maintenance, tolls — all tracked automatically.",
      assetPath: "assets/images/onboard_2.png",
    ),
    OnboardingData(
      title: "Know Your Real Profit Instantly",
      subtitle: "See income, expenses & profit in real-time.",
      assetPath: "assets/images/onboard_3.png",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _cubit = OnboardingCubit(pages.length);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _buttonAnimationController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _handlePageChanged(int index) {
    _cubit.updatePage(index);

    // Control animation based on page
    if (index == pages.length - 1) {
      _buttonAnimationController.forward();
    } else {
      _buttonAnimationController.reverse();
    }
  }

  void _handleNextPressed() {
    final state = _cubit.state;

    if (_cubit.isLastPage(state)) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (route) => false);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleSkipPressed() {
    _pageController.jumpToPage(pages.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocProvider.value(
          value: _cubit,
          child: BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) {
              final currentIndex = state.currentIndex;
              final isLastPage = _cubit.isLastPage(state);

              return Column(
                children: [
                  // Top Skip Button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: isLastPage
                          ? const SizedBox(height: 48, width: 80)
                          : TextButton(
                        onPressed: _handleSkipPressed,
                        child: const Text(
                          "Skip",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Page View
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _handlePageChanged,
                      itemCount: pages.length,
                      itemBuilder: (context, index) {
                        return OnboardingPageContent(data: pages[index]);
                      },
                    ),
                  ),

                  // Bottom Section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40, top: 20),
                    child: Column(
                      children: [
                        // Indicators
                        _buildIndicators(currentIndex),
                        const SizedBox(height: 48),

                        // Animated Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: AnimatedOnboardingButton(
                            onPressed: _handleNextPressed,
                            isLastPage: isLastPage,
                            animationController: _buttonAnimationController,
                            totalPages: pages.length,
                            currentIndex: currentIndex,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIndicators(int currentIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pages.length,
            (index) {
          final isActive = currentIndex == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF1E3A5F)
                  : const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
      ),
    );
  }
}*/








import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/constants/app_routes.dart';
import '../controller/onboard_cubit.dart';
import '../model/onboarding_model_data.dart';
import '../widget/animated_onboarding_button.dart';
import '../widget/onboarding_page_content.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _buttonAnimationController;
  late OnboardingCubit _cubit;

  // Cache page count
  late final int _pageCount;

  // Cache pages data (already const, but explicit)
  static const List<OnboardingData> _pages = [
    OnboardingData(
      title: "Track Every Mile. Count Every Dollar.",
      subtitle: "All your trucking business, simplified in one app.",
      assetPath: "assets/images/onboard_1.png",
    ),
    OnboardingData(
      title: "Automate Your Expenses",
      subtitle: "Fuel, maintenance, tolls — all tracked automatically.",
      assetPath: "assets/images/onboard_2.png",
    ),
    OnboardingData(
      title: "Know Your Real Profit Instantly",
      subtitle: "See income, expenses & profit in real-time.",
      assetPath: "assets/images/onboard_3.png",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageCount = _pages.length;
    _pageController = PageController();
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _cubit = OnboardingCubit(_pageCount);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _buttonAnimationController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _handlePageChanged(int index) {
    _cubit.updatePage(index);

    // Control animation based on page
    if (index == _pageCount - 1) {
      _buttonAnimationController.forward();
    } else {
      _buttonAnimationController.reverse();
    }
  }

  void _handleNextPressed() {
    final state = _cubit.state;

    if (_cubit.isLastPage(state)) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (route) => false);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleSkipPressed() {
    _pageController.jumpToPage(_pageCount - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocProvider.value(
          value: _cubit,
          child: BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) {
              return _OnboardingContent(
                pageController: _pageController,
                buttonAnimationController: _buttonAnimationController,
                currentIndex: state.currentIndex,
                isLastPage: _cubit.isLastPage(state),
                pageCount: _pageCount,
                onPageChanged: _handlePageChanged,
                onNextPressed: _handleNextPressed,
                onSkipPressed: _handleSkipPressed,
              );
            },
          ),
        ),
      ),
    );
  }
}

// Separated content widget to reduce rebuilds
class _OnboardingContent extends StatelessWidget {
  final PageController pageController;
  final AnimationController buttonAnimationController;
  final int currentIndex;
  final bool isLastPage;
  final int pageCount;
  final Function(int) onPageChanged;
  final VoidCallback onNextPressed;
  final VoidCallback onSkipPressed;

  const _OnboardingContent({
    required this.pageController,
    required this.buttonAnimationController,
    required this.currentIndex,
    required this.isLastPage,
    required this.pageCount,
    required this.onPageChanged,
    required this.onNextPressed,
    required this.onSkipPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Skip Button - Optimized
        _SkipButton(
          isVisible: !isLastPage,
          onSkip: onSkipPressed,
        ),

        // Page View - Optimized with caching
        Expanded(
          child: PageView.builder(
            controller: pageController,
            onPageChanged: onPageChanged,
            itemCount: pageCount,
            itemBuilder: (context, index) {
              // Use RepaintBoundary to isolate each page's rendering
              return RepaintBoundary(
                child: OnboardingPageContent(data: _OnboardingScreenState._pages[index]),
              );
            },
          ),
        ),

        // Bottom Section - Optimized
        _BottomSection(
          currentIndex: currentIndex,
          isLastPage: isLastPage,
          pageCount: pageCount,
          buttonAnimationController: buttonAnimationController,
          onNextPressed: onNextPressed,
        ),
      ],
    );
  }
}

// Optimized Skip Button - Only rebuilds when needed
class _SkipButton extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onSkip;

  const _SkipButton({
    required this.isVisible,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      // Return fixed size spacer when hidden (prevents layout shift)
      return const SizedBox(height: 48, width: 80);
    }

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: TextButton(
          onPressed: onSkip,
          child: const Text(
            "Skip",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// Optimized Bottom Section
class _BottomSection extends StatelessWidget {
  final int currentIndex;
  final bool isLastPage;
  final int pageCount;
  final AnimationController buttonAnimationController;
  final VoidCallback onNextPressed;

  const _BottomSection({
    required this.currentIndex,
    required this.isLastPage,
    required this.pageCount,
    required this.buttonAnimationController,
    required this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40, top: 20),
      child: Column(
        children: [
          // Indicators - Optimized with RepaintBoundary
          RepaintBoundary(
            child: _PageIndicators(
              currentIndex: currentIndex,
              pageCount: pageCount,
            ),
          ),
          const SizedBox(height: 48),

          // Animated Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AnimatedOnboardingButton(
              onPressed: onNextPressed,
              isLastPage: isLastPage,
              animationController: buttonAnimationController,
              totalPages: pageCount,
              currentIndex: currentIndex,
            ),
          ),
        ],
      ),
    );
  }
}

// Optimized Page Indicators - Using CustomPainter for better performance
class _PageIndicators extends StatelessWidget {
  final int currentIndex;
  final int pageCount;

  const _PageIndicators({
    required this.currentIndex,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
            (index) => _IndicatorDot(
          isActive: currentIndex == index,
          key: ValueKey('indicator_$index'), // Unique key for each dot
        ),
      ),
    );
  }
}

// Optimized Indicator Dot - Separated for better performance
class _IndicatorDot extends StatelessWidget {
  final bool isActive;

  const _IndicatorDot({
    super.key,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200), // Reduced from 300ms
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF1E3A5F)
            : const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// Optional: Alternative even more performant indicator using CustomPainter
class _CustomPaintIndicators extends StatelessWidget {
  final int currentIndex;
  final int pageCount;

  const _CustomPaintIndicators({
    required this.currentIndex,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _IndicatorPainter(
        currentIndex: currentIndex,
        pageCount: pageCount,
      ),
      size: Size(pageCount * 20.0, 8.0), // 20px per dot (4px margin + 8px width)
    );
  }
}

class _IndicatorPainter extends CustomPainter {
  final int currentIndex;
  final int pageCount;

  _IndicatorPainter({
    required this.currentIndex,
    required this.pageCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dotWidth = 8.0;
    final activeWidth = 28.0;
    final spacing = 12.0;

    double startX = 0;

    for (int i = 0; i < pageCount; i++) {
      final isActive = i == currentIndex;
      final width = isActive ? activeWidth : dotWidth;

      final paint = Paint()
        ..color = isActive ? const Color(0xFF1E3A5F) : const Color(0xFFD1D5DB)
        ..style = PaintingStyle.fill;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(startX, 0, width, 8),
        const Radius.circular(4),
      );

      canvas.drawRRect(rect, paint);
      startX += width + spacing;
    }
  }

  @override
  bool shouldRepaint(_IndicatorPainter oldDelegate) {
    return oldDelegate.currentIndex != currentIndex;
  }
}