import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tag/core/theme/app_text_style.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                    // Profile Picture with Edit Button
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

                    // Name and Email
                    const Text(
                      'John Doe',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'john.doe@logistics.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Edit Profile Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to edit profile
                        },
                        icon: SvgPicture.asset(
                          'assets/icons/edit_pen_box.svg', // Your SVG icon
                          width: 20,
                          height: 20,
                        ),
                        label:  Text(
                          'Edit Profile',
                          style: AppTextStyle.SFProDisplay_Regular
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Menu Items
              _buildMenuItem(
                iconPath: 'assets/icons/account_settings.svg', // Your SVG
                title: 'Account Settings',
                subtitle: 'Edit name, password, and security',
                onTap: () {},
              ),
              _buildMenuItem(
                iconPath: 'assets/icons/manage_drivers.svg', // Your SVG
                title: 'Manage Drivers',
                subtitle: 'Add, remove Drivers',
                onTap: () {},
              ),
              _buildMenuItem(
                iconPath: 'assets/icons/accountant.svg', // Your SVG
                title: 'Accountant',
                subtitle: 'Contact Accountant',
                onTap: () {},
              ),
              _buildMenuItem(
                iconPath: 'assets/icons/subscription.svg', // Your SVG
                title: 'Subscription',
                subtitle: 'Current Plan: FREE',
                onTap: () {},
              ),
              _buildMenuItem(
                iconPath: 'assets/icons/app_preferences.svg', // Your SVG
                title: 'App Preferences',
                subtitle: 'Language, Units, and others',
                onTap: () {},
              ),
              _buildMenuItem(
                iconPath: 'assets/icons/help_support.svg', // Your SVG
                title: 'Help & Support',
                subtitle: 'FAQs and Customer Center',
                onTap: () {},
              ),
              const SizedBox(height: 16),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Handle logout
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/logout.svg', // Your SVG icon
                    width: 20,
                    height: 20,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
        color: Colors.white,
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
            // SVG Icon Container
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(
                iconPath,
                width: 25,
                height: 25,
              ),
            ),
            const SizedBox(width: 16),
            // Text Content
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
            // Arrow Icon
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
}