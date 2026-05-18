import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/components/Custom_Elevated_Button.dart';

import 'package:flutter/material.dart';


class AccountSettingScreen extends StatefulWidget {
  const AccountSettingScreen({super.key});

  @override
  State<AccountSettingScreen> createState() => _AccountSettingScreenState();
}

class _AccountSettingScreenState extends State<AccountSettingScreen> {
  // Controllers for text fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Password visibility states
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Set initial values
    _fullNameController.text = 'Alex Thompson';
    _phoneNumberController.text = '+1 (555) 000-0000';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // Validate passwords if they are being changed
    if (_newPasswordController.text.isNotEmpty ||
        _confirmPasswordController.text.isNotEmpty) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_newPasswordController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password must be at least 6 characters'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Save logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back or handle save
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12), // Top empty space
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildEditProfileSection(),
                  const SizedBox(height: 24),
                  _buildSecuritySection(),
                  const SizedBox(height: 32),
                  CustomElevatedButton(
                    onPressed: _saveChanges,
                    buttonText: 'Save changes',
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.whiteColor,
                    height: 48,
                    borderRadius: BorderRadius.circular(30),
                    isFullWidth: true,
                    hasShadow: false,
                    icon: const Icon(Icons.save, size: 20),
                    gap: 8,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      surfaceTintColor: AppColors.backgroundColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: InkWell(
          onTap: () => Navigator.pop(context),
          child: SvgPicture.asset('assets/icons/back_button_with_circle.svg'),
        ),
      ),
      title: const Text(
        'Account Setting',
        style: TextStyle(
          color: Color(0xFF1A1A2E),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'John Doe',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'john.doe@logistics.com',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.edit,
                  size: 18,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Full Name Field
          _buildTextField(
            label: 'FULL NAME',
            controller: _fullNameController,
            hint: 'Enter your full name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          // Phone Number Field
          _buildTextField(
            label: 'PHONE NUMBER',
            controller: _phoneNumberController,
            hint: 'Enter your phone number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Security',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Old Password Field
          _buildPasswordField(
            label: 'OLD PASSWORD',
            controller: _oldPasswordController,
            obscureText: _obscureOldPassword,
            onToggle: () {
              setState(() {
                _obscureOldPassword = !_obscureOldPassword;
              });
            },
          ),
          const SizedBox(height: 16),
          // New Password Field
          _buildPasswordField(
            label: 'NEW PASSWORD',
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            onToggle: () {
              setState(() {
                _obscureNewPassword = !_obscureNewPassword;
              });
            },
          ),
          const SizedBox(height: 16),
          // Confirm New Password Field
          _buildPasswordField(
            label: 'CONFIRM NEW PASSWORD',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            onToggle: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: const Color(0xFF888888),
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE1E8ED), width: 1),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A1A2E),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFFB0B0B0),
              ),
              prefixIcon: Icon(icon, size: 20, color: const Color(0xFF888888)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: const Color(0xFF888888),
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE1E8ED), width: 1),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A1A2E),
            ),
            decoration: InputDecoration(
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFFB0B0B0),
              ),
              prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Color(0xFF888888)),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: const Color(0xFF888888),
                ),
                onPressed: onToggle,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}