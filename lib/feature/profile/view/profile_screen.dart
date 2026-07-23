import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tag/core/constants/app_routes.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/utils/app_url.dart';
import 'package:tag/feature/profile/view/account_settings/model/account_settings_data.dart';
import 'package:tag/feature/profile/view/terms_privacy_policy/terms_privacy_policy.dart';
import '../../auth/cubit/logout_cubit.dart';
import '../cubit/user_profile_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => UserProfileCubit()..getUserProfile()),
        BlocProvider(create: (_) => LogoutCubit()),
      ],
      child: BlocConsumer<LogoutCubit, LogoutState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
                  (route) => false,
            );
          } else if (state is LogoutFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppColors.redColor,
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
              child: _ProfileContent(
                isLoading: isLoading,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ✅ Separate widget to handle lifecycle events
class _ProfileContent extends StatefulWidget {
  final bool isLoading;

  const _ProfileContent({required this.isLoading});

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _refreshProfile();
    }
  }

  void _refreshProfile() {
    final cubit = context.read<UserProfileCubit>();
    if (cubit.state is! UserProfileLoading) {
      cubit.getUserProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileCubit, UserProfileState>(
      builder: (context, profileState) {
        UserData? userData;
        bool isProfileLoading = false;
        String? profileError;

        if (profileState is UserProfileLoading) {
          isProfileLoading = true;
        } else if (profileState is UserProfileSuccess) {
          userData = profileState.userData;
        } else if (profileState is UserProfileFailure) {
          profileError = profileState.errorMessage;
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ✅ Profile Card - Shows error only in this card
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
              child: profileError != null
                  ? _buildErrorWidget(profileError)
                  : _buildProfileCard(userData, isProfileLoading),
            ),
            const SizedBox(height: 16),

            // Menu Items - Always visible
            _buildMenuItem(
              iconPath: 'assets/icons/account_settings.svg',
              title: 'Account Settings',
              subtitle: 'Edit name, password, and security',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.accoutnSettings).then((_) {
                  _refreshProfile();
                });
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

            // Logout Button with loading state
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.isLoading ? null : () => _handleLogout(context),
                icon: widget.isLoading
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
                  widget.isLoading ? 'Logging out...' : 'Logout',
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
        );
      },
    );
  }

  // ✅ Build Profile Card (Success/Loading)
  Widget _buildProfileCard(UserData? userData, bool isProfileLoading) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: isProfileLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                )
                    : userData?.profileImage != null &&
                    userData!.profileImage.isNotEmpty &&
                    userData!.profileImage != 'users/user.png'
                    ? Image.network(
                  '${AppUrl.imageBaseUrl}/${userData.profileImage}',
                  height: 110,
                  width: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        userData?.initials ?? '',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    );
                  },
                )
                    : Center(
                  child: Text(
                    userData?.initials ?? '',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          isProfileLoading ? 'Loading...' : (userData?.name ?? 'John Doe'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isProfileLoading
              ? 'Loading...'
              : (userData?.email ?? 'john.doe@logistics.com'),
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textGreyColor,
          ),
        ),
        const SizedBox(height: 8),
        if (!isProfileLoading && userData != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              userData.role.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
          ),
      ],
    );
  }

  // ✅ Build Error Widget (Only for Profile Card)
  Widget _buildErrorWidget(String errorMessage) {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 12),
        Text(
          'Failed to load profile',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          errorMessage,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            context.read<UserProfileCubit>().getUserProfile();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            'Retry',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
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

  void _handleLogout(BuildContext context) {
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
              Navigator.pop(dialogContext);
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