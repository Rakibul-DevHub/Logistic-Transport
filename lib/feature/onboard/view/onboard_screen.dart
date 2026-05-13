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
}