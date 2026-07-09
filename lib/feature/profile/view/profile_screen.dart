/**
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tag/core/constants/app_routes.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/feature/profile/view/terms_privacy_policy/terms_privacy_policy.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/demo_user.jpg',
                              height: 110,
                              width: 110,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 06,
                        child: SvgPicture.asset(
                          'assets/icons/edit_profile_image.svg',
                          width: 25,
                          height: 25,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'john.doe@logistics.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGreyColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Menu Items
            _buildMenuItem(
              iconPath: 'assets/icons/account_settings.svg',
              title: 'Account Settings',
              subtitle: 'Edit name, password, and security',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.accoutnSettings);
              },
            ),
            _buildMenuItem(
              iconPath: 'assets/icons/manage_drivers.svg',
              title: 'Manage Drivers',
              subtitle: 'Add, remove Drivers',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.drivers);
              },
            ),
            _buildMenuItem(
              iconPath: 'assets/icons/accountant.svg',
              title: 'Accountant',
              subtitle: 'Contact Accountant',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.sendToAccountantScreen);
              },
            ),
            _buildMenuItem(
              iconPath: 'assets/icons/subscription.svg',
              title: 'Subscription',
              subtitle: 'Current Plan: FREE',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.subscriptionScreen);

              },
            ),
            _buildMenuItem(
              iconPath: 'assets/icons/app_preferences.svg',
              title: 'App Preferences',
              subtitle: 'Language, Units, and others',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.appPreferencesScreen);

              },
            ),
            _buildMenuItem(
              iconPath: 'assets/icons/help_support.svg',
              title: 'Help & Support',
              subtitle: 'FAQs and Customer Center',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.helpSupportScreen);

              },
            ),
            _buildMenuItem(
              iconPath: 'assets/icons/terms_and_condition.svg',
              title: 'Terms & Condition',
              subtitle: 'App use terms and condition',
              onTap: () {
                // ✅ Navigate to Terms & Conditions
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsPrivacyScreen(
                      contentType: ContentType.terms,
                    ),
                  ),
                );
              },
            ),
            _buildMenuItem(
              iconPath: 'assets/icons/privacy_policy.svg',
              title: 'Privacy Policy',
              subtitle: 'Data privacy policy',
              onTap: () {
                // ✅ Navigate to Privacy Policy
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsPrivacyScreen(
                      contentType: ContentType.privacy,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);

                },
                icon: SvgPicture.asset(
                  'assets/icons/logout.svg',
                  width: 20,
                  height: 20,
                  color: AppColors.redColor,
                ),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.redColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.whiteColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.redColor.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16), // Extra bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String iconPath,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}*/








import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tag/core/constants/app_routes.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/feature/profile/view/terms_privacy_policy/terms_privacy_policy.dart';
import '../../auth/cubit/logout_cubit.dart'; // ✅ Import logout cubit

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LogoutCubit(),
      child: BlocConsumer<LogoutCubit, LogoutState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Logged out successfully'),
                backgroundColor: Colors.green,
                duration: Duration(milliseconds: 800),
              ),
            );

            // Navigate to login screen and clear all previous routes
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
                  (route) => false,
            );
          } else if (state is LogoutFailure) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is LogoutLoading;

          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Profile Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/demo_user.jpg',
                                    height: 110,
                                    width: 110,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              bottom: 06,
                              child: SvgPicture.asset(
                                'assets/icons/edit_profile_image.svg',
                                width: 25,
                                height: 25,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'John Doe',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blackColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'john.doe@logistics.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textGreyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Menu Items
                  _buildMenuItem(
                    iconPath: 'assets/icons/account_settings.svg',
                    title: 'Account Settings',
                    subtitle: 'Edit name, password, and security',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.accoutnSettings);
                    },
                  ),
                  _buildMenuItem(
                    iconPath: 'assets/icons/manage_drivers.svg',
                    title: 'Manage Drivers',
                    subtitle: 'Add, remove Drivers',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.drivers);
                    },
                  ),
                  _buildMenuItem(
                    iconPath: 'assets/icons/accountant.svg',
                    title: 'Accountant',
                    subtitle: 'Contact Accountant',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.sendToAccountantScreen);
                    },
                  ),
                  _buildMenuItem(
                    iconPath: 'assets/icons/subscription.svg',
                    title: 'Subscription',
                    subtitle: 'Current Plan: FREE',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.subscriptionScreen);
                    },
                  ),
                  _buildMenuItem(
                    iconPath: 'assets/icons/app_preferences.svg',
                    title: 'App Preferences',
                    subtitle: 'Language, Units, and others',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.appPreferencesScreen);
                    },
                  ),
                  _buildMenuItem(
                    iconPath: 'assets/icons/help_support.svg',
                    title: 'Help & Support',
                    subtitle: 'FAQs and Customer Center',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.helpSupportScreen);
                    },
                  ),
                  _buildMenuItem(
                    iconPath: 'assets/icons/terms_and_condition.svg',
                    title: 'Terms & Condition',
                    subtitle: 'App use terms and condition',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsPrivacyScreen(
                            contentType: ContentType.terms,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    iconPath: 'assets/icons/privacy_policy.svg',
                    title: 'Privacy Policy',
                    subtitle: 'Data privacy policy',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsPrivacyScreen(
                            contentType: ContentType.privacy,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // ✅ Updated: Logout Button with loading state
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : () => _handleLogout(context),
                      icon: isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.redColor,
                        ),
                      )
                          : SvgPicture.asset(
                        'assets/icons/logout.svg',
                        width: 20,
                        height: 20,
                        color: AppColors.redColor,
                      ),
                      label: Text(
                        isLoading ? 'Logging out...' : 'Logout',
                        style: TextStyle(
                          color: AppColors.redColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.whiteColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: AppColors.redColor.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required String iconPath,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Fixed: Handle logout with confirmation dialog
  void _handleLogout(BuildContext context) {
    // ✅ Capture the context before showing dialog
    final scaffoldContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.whiteColor,
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              // ✅ Use the captured context to access the cubit
              scaffoldContext.read<LogoutCubit>().logout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.redColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}