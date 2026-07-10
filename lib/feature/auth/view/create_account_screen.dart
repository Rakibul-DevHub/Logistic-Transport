/**
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tag/core/constants/app_routes.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';
import '../cubit/auth_registration_cubit.dart';
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
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isTermsAccepted = false;

  // Track validation errors
  String? _fullNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleNext() {
    // Validate all fields manually
    setState(() {
      _fullNameError = _validateFullName(_fullNameController.text);
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
      _confirmPasswordError = _validateConfirmPassword(_confirmPasswordController.text);
    });

    // Check if any error exists
    if (_fullNameError != null ||
        _emailError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      return;
    }

    if (!_isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Use and Privacy Policy'),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 800),
        ),
      );
      return;
    }

    // Call API to register user
    final authCubit = context.read<AuthRegistrationCubit>();
    authCubit.registerUser(
      email: _emailController.text.trim(),
      fullName: _fullNameController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
  }

  String? _validateFullName(String value) {
    if (value.isEmpty) return 'Please enter your full name';
    return null;
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Please create a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String value) {
    if (value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: BlocConsumer<AuthRegistrationCubit, AuthRegistrationState>(
            listener: (context, state) {
              // Handle API response
              if (state.isSuccess && state.verificationToken != null) {
                // Registration successful - navigate to OTP verification
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please verify your email.'),
                    backgroundColor: AppColors.lightBlueColor,
                    duration: const Duration(milliseconds: 600),
                  ),
                );

                // Navigate immediately
                Navigator.pushNamed(context, AppRoutes.otpVerify);
              } else if (state.errorMessage != null) {
                // Show error message briefly
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            builder: (context, state) {
              // ✅ Check if loading
              final bool isLoading = state.isLoading;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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

                    // Full Name Field
                    _buildLabel('Full Name'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      cubit: _fullNameController,
                      hintText: 'Enter your full name',
                      onChanged: (value) {
                        setState(() {
                          _fullNameError = _validateFullName(value);
                        });
                      },
                      hasError: _fullNameError != null,
                      enabled: !isLoading, // ✅ Disable when loading
                    ),
                    if (_fullNameError != null) ...[
                      const SizedBox(height: 4),
                      _buildErrorText(_fullNameError!),
                    ],
                    const SizedBox(height: 16),

                    // Email Field
                    _buildLabel('Email'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      cubit: _emailController,
                      hintText: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setState(() {
                          _emailError = _validateEmail(value);
                        });
                      },
                      hasError: _emailError != null,
                      enabled: !isLoading, // ✅ Disable when loading
                    ),
                    if (_emailError != null) ...[
                      const SizedBox(height: 4),
                      _buildErrorText(_emailError!),
                    ],
                    const SizedBox(height: 16),

                    const SizedBox(height: 8),

                    // Create Password Section
                    _buildLabel('Create Password'),
                    const SizedBox(height: 16),

                    // Password Field
                    _buildPasswordField(
                      cubit: _passwordController,
                      obscureText: _obscurePassword,
                      hintText: 'Create a password',
                      onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                      onChanged: (value) {
                        setState(() {
                          _passwordError = _validatePassword(value);
                          if (_confirmPasswordController.text.isNotEmpty) {
                            _confirmPasswordError = _validateConfirmPassword(
                                _confirmPasswordController.text);
                          }
                        });
                      },
                      hasError: _passwordError != null,
                      enabled: !isLoading, // ✅ Disable when loading
                    ),
                    if (_passwordError != null) ...[
                      const SizedBox(height: 4),
                      _buildErrorText(_passwordError!),
                    ],
                    const SizedBox(height: 16),

                    // Confirm Password Field
                    _buildLabel('Confirm Password'),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      cubit: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      hintText: 'Confirm your password',
                      onToggle: () =>
                          setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      onChanged: (value) {
                        setState(() {
                          _confirmPasswordError = _validateConfirmPassword(value);
                        });
                      },
                      hasError: _confirmPasswordError != null,
                      enabled: !isLoading, // ✅ Disable when loading
                    ),
                    if (_confirmPasswordError != null) ...[
                      const SizedBox(height: 4),
                      _buildErrorText(_confirmPasswordError!),
                    ],
                    const SizedBox(height: 16),

                    const SizedBox(height: 24),

                    // Terms and Conditions
                    _buildTermsCheckbox(),

                    const SizedBox(height: 32),

                    /// Next Button
                    CustomElevatedButton(
                      onPressed: isLoading ? null : _handleNext,
                      buttonText: isLoading ? 'Processing...' : 'Next',
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
              );
            },
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

  Widget _buildErrorText(String error) {
    return Text(
      error,
      style: AppTextStyle.SFProDisplay_Regular.copyWith(
        color: AppColors.redColor,
        fontSize: 12,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController cubit,
    required String hintText,
    TextInputType? keyboardType,
    required Function(String) onChanged,
    required bool hasError,
    bool enabled = true, // ✅ Added enabled parameter
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError ? Colors.red : Colors.transparent,
          width: hasError ? 1.5 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        cubit: cubit,
        keyboardType: keyboardType,
        onChanged: onChanged,
        enabled: enabled, // ✅ Use enabled parameter
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[100], // ✅ Different color when disabled
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorStyle: const TextStyle(height: 0, fontSize: 0),
        ),
        validator: null,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController cubit,
    required bool obscureText,
    required String hintText,
    required VoidCallback onToggle,
    required Function(String) onChanged,
    required bool hasError,
    bool enabled = true, // ✅ Added enabled parameter
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError ? Colors.red : Colors.transparent,
          width: hasError ? 1.5 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        cubit: cubit,
        obscureText: obscureText,
        onChanged: onChanged,
        enabled: enabled, // ✅ Use enabled parameter
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[100], // ✅ Different color when disabled
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.grey[600],
            ),
            onPressed: enabled ? onToggle : null, // ✅ Disable toggle when loading
          ),
          errorStyle: const TextStyle(height: 0, fontSize: 0),
        ),
        validator: null,
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
}*/





///
///
/// todo:: addming the terms condition privacy policy ,,navigation
///
///
///




import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tag/core/constants/app_routes.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';
import '../../profile/view/terms_privacy_policy/terms_privacy_policy.dart';
import '../cubit/auth_registration_cubit.dart';
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
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isTermsAccepted = false;

  // Track validation errors
  String? _fullNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleNext() {
    // Validate all fields manually
    setState(() {
      _fullNameError = _validateFullName(_fullNameController.text);
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
      _confirmPasswordError = _validateConfirmPassword(_confirmPasswordController.text);
    });

    // Check if any error exists
    if (_fullNameError != null ||
        _emailError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      return;
    }

    if (!_isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Use and Privacy Policy'),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 800),
        ),
      );
      return;
    }

    // Call API to register user
    final authCubit = context.read<AuthRegistrationCubit>();
    authCubit.registerUser(
      email: _emailController.text.trim(),
      fullName: _fullNameController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
  }

  String? _validateFullName(String value) {
    if (value.isEmpty) return 'Please enter your full name';
    return null;
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Please create a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String value) {
    if (value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: BlocConsumer<AuthRegistrationCubit, AuthRegistrationState>(
            listener: (context, state) {
              // Handle API response
              if (state.isSuccess && state.verificationToken != null) {
                // Registration successful - navigate to OTP verification
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please verify your email.'),
                    backgroundColor: AppColors.lightBlueColor,
                    duration: const Duration(milliseconds: 600),
                  ),
                );

                // Navigate immediately
                Navigator.pushNamed(context, AppRoutes.otpVerify);
              } else if (state.errorMessage != null) {
                // Show error message briefly
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            builder: (context, state) {
              // ✅ Check if loading
              final bool isLoading = state.isLoading;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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

                    // Full Name Field
                    _buildLabel('Full Name'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _fullNameController,
                      hintText: 'Enter your full name',
                      onChanged: (value) {
                        setState(() {
                          _fullNameError = _validateFullName(value);
                        });
                      },
                      hasError: _fullNameError != null,
                      enabled: !isLoading,
                    ),
                    if (_fullNameError != null) ...[
                      const SizedBox(height: 4),
                      _buildErrorText(_fullNameError!),
                    ],
                    const SizedBox(height: 16),

                    // Email Field
                    _buildLabel('Email'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setState(() {
                          _emailError = _validateEmail(value);
                        });
                      },
                      hasError: _emailError != null,
                      enabled: !isLoading,
                    ),
                    if (_emailError != null) ...[
                      const SizedBox(height: 4),
                      _buildErrorText(_emailError!),
                    ],
                    const SizedBox(height: 16),

                    const SizedBox(height: 8),

                    // Create Password Section
                    _buildLabel('Create Password'),
                    const SizedBox(height: 16),

                    // Password Field
                    _buildPasswordField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      hintText: 'Create a password',
                      onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                      onChanged: (value) {
                        setState(() {
                          _passwordError = _validatePassword(value);
                          if (_confirmPasswordController.text.isNotEmpty) {
                            _confirmPasswordError = _validateConfirmPassword(
                                _confirmPasswordController.text);
                          }
                        });
                      },
                      hasError: _passwordError != null,
                      enabled: !isLoading,
                    ),
                    if (_passwordError != null) ...[
                      const SizedBox(height: 4),
                      _buildErrorText(_passwordError!),
                    ],
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
                      onChanged: (value) {
                        setState(() {
                          _confirmPasswordError = _validateConfirmPassword(value);
                        });
                      },
                      hasError: _confirmPasswordError != null,
                      enabled: !isLoading,
                    ),
                    if (_confirmPasswordError != null) ...[
                      const SizedBox(height: 4),
                      _buildErrorText(_confirmPasswordError!),
                    ],
                    const SizedBox(height: 16),

                    const SizedBox(height: 24),

                    // ✅ Updated: Terms and Conditions with clickable links
                    _buildTermsCheckbox(),

                    const SizedBox(height: 32),

                    /// Next Button
                    CustomElevatedButton(
                      onPressed: isLoading ? null : _handleNext,
                      buttonText: isLoading ? 'Processing...' : 'Next',
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
              );
            },
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

  Widget _buildErrorText(String error) {
    return Text(
      error,
      style: AppTextStyle.SFProDisplay_Regular.copyWith(
        color: AppColors.redColor,
        fontSize: 12,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    required Function(String) onChanged,
    required bool hasError,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError ? Colors.red : Colors.transparent,
          width: hasError ? 1.5 : 0,
        ),
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
        onChanged: onChanged,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorStyle: const TextStyle(height: 0, fontSize: 0),
        ),
        validator: null,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscureText,
    required String hintText,
    required VoidCallback onToggle,
    required Function(String) onChanged,
    required bool hasError,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError ? Colors.red : Colors.transparent,
          width: hasError ? 1.5 : 0,
        ),
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
        onChanged: onChanged,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.grey[600],
            ),
            onPressed: enabled ? onToggle : null,
          ),
          errorStyle: const TextStyle(height: 0, fontSize: 0),
        ),
        validator: null,
      ),
    );
  }

  // ✅ Updated: Terms and Conditions with clickable links
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
                WidgetSpan(
                  child: GestureDetector(
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
                    child: Text(
                      'Terms of Use',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: ' and '),
                WidgetSpan(
                  child: GestureDetector(
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
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
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