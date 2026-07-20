/**
// lib/feature/profile/view/terms_privacy_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';
import '../../../../shared/components/custom_background.dart';

// ============================================
// TERMS & CONDITIONS / PRIVACY POLICY SCREEN
// ============================================

enum ContentType {
  terms,
  privacy,
}

class TermsPrivacyScreen extends StatelessWidget {
  final ContentType contentType;

  const TermsPrivacyScreen({
    super.key,
    required this.contentType,
  });

  @override
  Widget build(BuildContext context) {
    final isTerms = contentType == ContentType.terms;
    final title = isTerms ? 'Terms & Conditions' : 'Privacy Policy';
    final iconPath = isTerms
        ? 'assets/icons/terms_and_condition.svg'
        : 'assets/icons/privacy_policy.svg';

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back_button_with_circle.svg',
            height: 40,
            width: 40,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: AppTextStyle.SFProDisplay_Regular.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AppColors.primaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  iconPath,
                  width: 60,
                  height: 60,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: AppTextStyle.SFProDisplay_Regular.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 8),

              // Last Updated
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Last Updated: ${DateTime.now().toString().split(' ')[0]}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Content Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: isTerms
                      ? _buildTermsContent()
                      : _buildPrivacyContent(),
                ),
              ),

              const SizedBox(height: 24),

              // Accept Button (Optional - if you need acceptance)
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       Navigator.pop(context);
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: AppColors.primaryColor,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //       padding: const EdgeInsets.symmetric(vertical: 16),
              //     ),
              //     child: Text(
              //       'I Understand',
              //       style: TextStyle(
              //         fontSize: 16,
              //         fontWeight: FontWeight.w600,
              //         color: Colors.white,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTermsContent() {
    return [
      _buildSection(
        title: '1. Acceptance of Terms',
        content: 'By using the T.A.G (Trucking Accounting on the Go) mobile application, you agree to comply with and be bound by the following terms and conditions. If you do not agree to these terms, please do not use the application.',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '2. User Accounts',
        content: 'To access certain features of the application, you may be required to create an account. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '3. User Obligations',
        content: '• Provide accurate and complete information\n• Maintain the security of your account\n• Notify us immediately of any unauthorized use\n• Comply with all applicable laws and regulations',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '4. Prohibited Activities',
        content: 'You agree not to:\n• Use the application for any unlawful purpose\n• Attempt to gain unauthorized access to the system\n• Interfere with or disrupt the application\'s functionality\n• Upload malicious code or content',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '5. Intellectual Property',
        content: 'All content, features, and functionality of the application, including but not limited to text, graphics, logos, and software, are the exclusive property of T.A.G and are protected by copyright and other intellectual property laws.',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '6. Limitation of Liability',
        content: 'T.A.G is not liable for any damages arising from the use of the application, including but not limited to direct, indirect, incidental, or consequential damages. The application is provided "as is" without warranties of any kind.',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '7. Termination',
        content: 'T.A.G reserves the right to terminate or suspend your account at any time without prior notice for any violation of these terms or for any other reason deemed appropriate.',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '8. Changes to Terms',
        content: 'T.A.G reserves the right to modify these terms at any time. Continued use of the application after any changes constitutes acceptance of the new terms. Please review these terms periodically.',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '9. Contact Information',
        content: 'For any questions or concerns regarding these terms, please contact us at:\n📧 support@tagapp.com\n📞 +1 (555) 123-4567',
      ),
    ];
  }

  List<Widget> _buildPrivacyContent() {
    return [
      _buildSection(
        title: '1. Information We Collect',
        content: 'We collect the following types of information to provide and improve our services:\n\n• Personal Information: Name, email address, phone number\n• Account Information: Login credentials, profile data\n• Location Data: GPS data for tracking deliveries\n• Device Information: Device type, operating system, app version\n• Usage Data: How you interact with the application',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '2. How We Use Your Information',
        content: 'Your information is used to:\n• Provide and maintain the application\n• Process transactions and shipments\n• Improve user experience\n• Send important notifications\n• Comply with legal obligations\n• Prevent fraud and enhance security',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '3. Data Storage and Security',
        content: 'Your data is stored securely using industry-standard encryption. We implement appropriate technical and organizational measures to protect your personal information from unauthorized access, disclosure, or alteration.',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '4. Third-Party Sharing',
        content: 'We do not sell or share your personal information with third parties except:\n• With your explicit consent\n• To comply with legal requirements\n• With service providers who assist our operations\n• In connection with business transfers',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '5. Your Rights',
        content: 'You have the right to:\n• Access your personal data\n• Request data correction or deletion\n• Withdraw consent\n• Data portability\n• Lodge a complaint with regulatory authorities',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '6. Cookies and Tracking',
        content: 'We use cookies and similar tracking technologies to enhance your experience, analyze usage patterns, and improve our services. You can manage cookie preferences through your browser settings.',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '7. Data Retention',
        content: 'We retain your personal data only for as long as necessary to fulfill the purposes outlined in this policy, unless a longer retention period is required by law.',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '8. Children\'s Privacy',
        content: 'Our services are not directed to children under 13. We do not knowingly collect personal information from children. If you believe we have collected such information, please contact us immediately.',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '9. Changes to Privacy Policy',
        content: 'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last Updated" date.',
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: '10. Contact Us',
        content: 'For privacy-related questions or concerns:\n📧 privacy@tagapp.com\n📞 +1 (555) 123-4567\n📍 123 Logistics Way, New York, NY 10001',
      ),
    ];
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.SFProDisplay_Regular.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.6,
          ),
        ),
      ],
    );
  }
}*/





///
///
///
///
/// todO:: implementing api
///
///
///





import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';
import '../../../../shared/components/custom_background.dart';
import 'cubit/terms_conditions_cubit.dart';

enum ContentType {
  terms,
  privacy,
}

/// One common page for Terms & Privacy.
/// Pass ContentType → cubit calls the matching API → show HTML on this screen.
class TermsPrivacyScreen extends StatelessWidget {
  final ContentType contentType;

  const TermsPrivacyScreen({
    super.key,
    required this.contentType,
  });

  @override
  Widget build(BuildContext context) {
    final isTerms = contentType == ContentType.terms;
    final apiType =
    isTerms ? SettingsContentType.terms : SettingsContentType.privacy;
    final title = isTerms ? 'Terms & Conditions' : 'Privacy Policy';
    final iconPath = isTerms
        ? 'assets/icons/terms_and_condition.svg'
        : 'assets/icons/privacy_policy.svg';

    return BlocProvider(
      create: (_) => SettingsContentCubit()..fetch(apiType),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/back_button_with_circle.svg',
              height: 40,
              width: 40,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            title,
            style: AppTextStyle.SFProDisplay_Regular.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: AppColors.primaryColor,
            ),
          ),
          centerTitle: true,
        ),
        body: CustomBackground(
          child: BlocBuilder<SettingsContentCubit, SettingsContentState>(
            builder: (context, state) {
              if (state is SettingsContentLoading ||
                  state is SettingsContentInitial) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }

              if (state is SettingsContentFailure) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load $title',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.errorMessage,
                          style:
                          TextStyle(fontSize: 13, color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<SettingsContentCubit>()
                                .fetch(apiType);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is SettingsContentSuccess) {
                // ✅ Same screen body — no WebView / secondary window
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
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
                        // ✅ Exact HTML from API `data.value`
                        child: Html(data: state.htmlContent),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}