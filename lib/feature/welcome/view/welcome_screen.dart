import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tag/core/constants/app_routes.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';

import '../../../shared/components/Custom_Elevated_Button.dart';
import '../../../shared/components/custom_background.dart';
import '../../auth/view/login_screen.dart';

// ============================================
// WELCOME SCREEN
// ============================================
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Welcome Title - aligned with image padding
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Welcome',
                  style: AppTextStyle.BricolageGrotesque_24pt_Regular.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 60,
                    color: AppColors.primaryColor
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // SVG Image
              SizedBox(
                height: 300,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SvgPicture.asset(
                      'assets/images/splash_image.svg',
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              /// login Buttons Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    CustomElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      buttonText: 'Log in',
                      backgroundColor: const Color(0xFF1E3A5F),
                      foregroundColor: Colors.white,
                      height: 56,
                      isFullWidth: true,
                      isRounded: true,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      margin: const EdgeInsets.only(bottom: 16),
                    ),

              /// Create Account Button
                    CustomElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.createAccount);
                      },
                      buttonText: 'Create Account',
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E3A5F),
                      height: 56,
                      isFullWidth: true,
                      isRounded: true,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      hasShadow: true,
                      shadowColor: Colors.black12,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}