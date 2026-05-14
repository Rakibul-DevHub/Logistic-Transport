import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/components/Custom_Elevated_Button.dart';
import '../../../shared/components/custom_background.dart';

// ============================================
// LOGIN SCREEN
// ============================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'a@gmail.com');
  final _passwordController = TextEditingController(text: '123456');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

                  // Logo and Title Section
                  Center(
                    child: Column(
                      children: [
                        // SVG Image
                        SizedBox(
                          height: 150,
                          child: SvgPicture.asset(
                            'assets/images/splash_image.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Welcome Text
                        Text(
                          'Welcome to T.A.G',
                          style: AppTextStyle.BricolageGrotesque_24pt_Regular.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color:  Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          'Log in to access your account',
                          style: AppTextStyle.SFProDisplay_Regular.copyWith(
                            fontSize: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Email Field
                  Text(
                    'Email',
                    style: AppTextStyle.BricolageGrotesque_24pt_Regular.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E3A5F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
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
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        // ✅ FIXED: Using standard Regex instead of GetUtils
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Password Field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Password',
                        style: AppTextStyle.BricolageGrotesque_24pt_Regular.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1E3A5F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          debugPrint('Forgot Password pressed');
                          // Navigator.pushNamed(context, '/forgot-password');
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          overlayColor: Colors.transparent,
                        ),
                        child: Text(
                          'Forget Password?',
                          style: AppTextStyle.SFProDisplay_Regular.copyWith(
                            fontSize: 12,
                          )
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                  ///--- Login Button
                  CustomElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        debugPrint('Email: ${_emailController.text}');
                        debugPrint('Password: ${_passwordController.text}');

                        Navigator.pushNamed(context, AppRoutes.bottomNav);
                      }
                    },
                    buttonText: 'Log in',
                    backgroundColor: const Color(0xFF1E3A5F),
                    foregroundColor: Colors.white,
                    height: 56,
                    isFullWidth: true,
                    isRounded: true,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),

                  const SizedBox(height: 24),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate back to Welcome Screen or to Create Account
                          Navigator.pushReplacementNamed(context, AppRoutes.createAccount);
                          debugPrint('Sign Up pressed');
                        },
                        child: Text(
                          'Sign Up',
                          style: const TextStyle(
                            color: Color(0xFF1E3A5F),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}