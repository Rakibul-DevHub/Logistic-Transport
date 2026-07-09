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

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _buttonAnimationController;
  late final OnboardingCubit _cubit;

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

  static final int _pageCount = _pages.length;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _cubit = OnboardingCubit(_pageCount);
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Listen to cubit state changes and sync PageController
    _cubit.stream.listen((state) {
      if (state.currentIndex != _pageController.page?.round()) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              state.currentIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final page in _pages) {
      precacheImage(AssetImage(page.assetPath), context);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _buttonAnimationController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _handlePageChanged(int index) {
    // Update cubit when user swipes
    _cubit.updatePage(index);
    _updateButtonAnimation(index);
  }

  void _updateButtonAnimation(int index) {
    if (index == _pageCount - 1) {
      _buttonAnimationController.forward();
    } else {
      _buttonAnimationController.reverse();
    }
  }

  void _handleNextPressed() {
    if (_cubit.isLastPage(_cubit.state)) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.welcome,
            (route) => false,
      );
    } else {
      // Update cubit, which will trigger PageController via listener
      _cubit.nextPage();
    }
  }

  void _handleSkipPressed() {
    // Update cubit, which will trigger PageController via listener
    _cubit.skipToEnd();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
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

// ---------------------------------------------------------------------------
// Content — separated so the BlocBuilder only rebuilds this subtree.
// ---------------------------------------------------------------------------

class _OnboardingContent extends StatelessWidget {
  final PageController pageController;
  final AnimationController buttonAnimationController;
  final int currentIndex;
  final bool isLastPage;
  final int pageCount;
  final ValueChanged<int> onPageChanged;
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
        _SkipButton(isVisible: !isLastPage, onSkip: onSkipPressed),
        Expanded(
          child: PageView.builder(
            controller: pageController,
            onPageChanged: onPageChanged,
            itemCount: pageCount,
            itemBuilder: (context, index) {
              return RepaintBoundary(
                child: OnboardingPageContent(
                  data: _OnboardingScreenState._pages[index],
                ),
              );
            },
          ),
        ),
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

// ---------------------------------------------------------------------------
// Skip button
// ---------------------------------------------------------------------------

class _SkipButton extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onSkip;

  const _SkipButton({required this.isVisible, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox(height: 48, width: double.infinity);

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

// ---------------------------------------------------------------------------
// Bottom section (indicators + button)
// ---------------------------------------------------------------------------

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
          RepaintBoundary(
            child: _PageIndicators(
              currentIndex: currentIndex,
              pageCount: pageCount,
            ),
          ),
          const SizedBox(height: 48),
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

// ---------------------------------------------------------------------------
// Page indicators
// ---------------------------------------------------------------------------

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
          key: ValueKey('dot_$index'),
          isActive: currentIndex == index,
        ),
      ),
    );
  }
}

class _IndicatorDot extends StatelessWidget {
  final bool isActive;

  const _IndicatorDot({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1E3A5F) : const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}