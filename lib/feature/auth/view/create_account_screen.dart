
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tag/core/constants/app_routes.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';
import '../cubit/auth_resigstration_cubit.dart';
import '../../../shared/components/Custom_Elevated_Button.dart';
import '../../../shared/components/custom_background.dart';

// ============================================
// CREATE ACCOUNT SCREEN
// ============================================
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isTermsAccepted = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;
    if (!_isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Use and Privacy Policy'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ Save data to Cubit
    final authCubit = context.read<AuthRegistrationCubit>();
    authCubit.updateRegistrationData(
      email: _emailController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      password: _passwordController.text,
    );

    // ✅ Navigate without passing email
    Navigator.pushNamed(context, AppRoutes.otpVerify);
  }

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Top Image
                  Center(
                    child: SizedBox(
                      height: 150,
                      child: SvgPicture.asset(
                        'assets/images/splash_image.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title Section
                  Center(
                    child: Text(
                      'Create An Account',
                      style: AppTextStyle.SFProDisplay_Regular.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Basic Information Title
                  Text(
                    'Basic Information',
                    style: AppTextStyle.SFProDisplay_Regular.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // First Name Field
                  _buildLabel('First Name'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _firstNameController,
                    hintText: 'Enter your first name',
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your first name' : null,
                  ),

                  const SizedBox(height: 16),

                  // Last Name Field
                  _buildLabel('Last Name'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _lastNameController,
                    hintText: 'Enter your last name',
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your last name' : null,
                  ),

                  const SizedBox(height: 16),

                  // Email Field
                  _buildLabel('Email'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'Enter your email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Create Password Section
                  _buildLabel('Create Password'),
                  const SizedBox(height: 16),

                  // Password Field
                  _buildPasswordField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    hintText: 'Create a password',
                    onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please create a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Confirm Password Field
                  _buildLabel('Confirm Password'),
                  const SizedBox(height: 8),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    hintText: 'Confirm your password',
                    onToggle: () =>
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Terms and Conditions
                  _buildTermsCheckbox(),

                  const SizedBox(height: 32),

                  /// Next Button
                  CustomElevatedButton(
                    onPressed: _handleNext,
                    buttonText: 'Next',
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    height: 56,
                    isFullWidth: true,
                    isRounded: true,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),

                  const SizedBox(height: 24),

                  // Sign In Link
                  _buildSignInLink(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ========== WIDGET HELPERS ==========
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyle.SFProDisplay_Regular.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscureText,
    required String hintText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.grey[600],
            ),
            onPressed: onToggle,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _isTermsAccepted,
            onChanged: (value) => setState(() => _isTermsAccepted = value ?? false),
            activeColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              children: [
                const TextSpan(text: 'I agree with this '),
                TextSpan(
                  text: 'Terms of Use',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
          child: Text(
            'Sign In',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}