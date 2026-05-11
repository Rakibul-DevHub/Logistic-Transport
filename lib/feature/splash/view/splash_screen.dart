import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widget/gradient_arc_loader.dart';
import 'splash_cubit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit()..startSplash(),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    // Listen for navigation trigger
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigate) {
          _navigateToNext(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: Column(
            children: [
              // Center: Your Image (No Text)
              const Expanded(
                child: Center(
                  child: _CenterImage(),
                ),
              ),

              // Bottom: Custom Loader
              const _LoaderSection(),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToNext(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.onboard);
  }
}

// ============ UI Widgets (Keep them private & focused) ============

class _CenterImage extends StatelessWidget {
  const _CenterImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280, maxHeight: 280),
      padding: const EdgeInsets.all(0),
      child: SvgPicture.asset(
        'assets/images/splash_image.svg',
        width: MediaQuery.of(context).size.width,
        height: 250,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _LoaderSection extends StatelessWidget {
  const _LoaderSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Your custom GradientArcLoader
          GradientArcLoader(
            size: 72,
            duration: const Duration(milliseconds: 1400),
          ),
        ],
      ),
    );
  }
}

