import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pinput/pinput.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';
import '../../../core/constants/app_routes.dart';
import '../cubit/auth_registration_cubit.dart';
import '../../../shared/components/custom_background.dart';
import '../../../shared/components/Custom_Elevated_Button.dart';

/// ============================================
/// OTP VERIFICATION SCREEN
/// ============================================
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  int _resendTimer = 60;
  bool _canResend = false;

  /// For password reset flow
  String? _email;
  String? _resetToken;
  bool _isPasswordReset = false;

  /// Flag to track if arguments have been loaded
  bool _argsLoaded = false;

  /// Flag to prevent multiple navigation
  bool _isNavigating = false;

  /// Get email from Cubit or arguments
  String get _userEmail {
    if (_isPasswordReset && _email != null) {
      return _email!;
    }
    return context.read<AuthRegistrationCubit>().email;
  }

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsLoaded) {
      _getArguments();
    }
  }

  void _getArguments() {
    try {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map) {
        _email = args['email'] as String?;
        _resetToken = args['resetToken'] as String?;
        _isPasswordReset = args['isPasswordReset'] ?? false;
        _argsLoaded = true;

        if (_isPasswordReset) {
          debugPrint('🔄 Password Reset Flow - Email: $_email');
          debugPrint('🔄 Password Reset Flow - Token: $_resetToken');

          /// Update cubit with reset token for verification
          final cubit = context.read<AuthRegistrationCubit>();
          cubit.updateRegistrationData(
            email: _email ?? '',
            fullName: '',
            password: '',
          );
          // Manually set verification token
          cubit.emit(cubit.state.copyWith(
            verificationToken: _resetToken,
          ));
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error getting arguments: $e');
    }
  }

  void _startResendTimer() {
    if (!mounted) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
        _startResendTimer();
      } else {
        setState(() => _canResend = true);
      }
    });
  }

  /// Verify OTP using Cubit
  Future<void> _handleVerifyOTP() async {
    final String otp = _otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 6-digit verification code'),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 800),
        ),
      );
      return;
    }

    /// Both flows use API verification
    _isNavigating = false;
    final cubit = context.read<AuthRegistrationCubit>();

    /// For password reset, we need to store the reset token in the cubit
    if (_isPasswordReset && _resetToken != null) {
      cubit.emit(cubit.state.copyWith(
        verificationToken: _resetToken,
      ));
    }

    cubit.verifyOtp(otp: otp);
  }

  /// Resend OTP using Cubit
  Future<void> _handleResendCode() async {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
      _resendTimer = 60;
    });

    if (_isPasswordReset) {
      /// For password reset - go back to forgot password
      Navigator.pop(context);
    } else {
      /// For registration - call cubit resend
      context.read<AuthRegistrationCubit>().resendOtp();
    }

    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: BlocConsumer<AuthRegistrationCubit, AuthRegistrationState>(
            listener: (context, state) {
              /// Prevent multiple navigation on repeated state changes
              if (_isNavigating) return;

              if (state.isSuccess) {
                _isNavigating = true;

                if (_isPasswordReset) {
                  /// Password reset OTP verified - navigate to reset password
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('OTP verified successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(milliseconds: 600),
                    ),
                  );

                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.resetPassword,
                    arguments: {
                      'email': _email ?? '',
                      'resetToken': _resetToken ?? '',
                      'otp': _otpController.text.trim(),
                    },
                  );
                } else {
                  /// Registration OTP verified - navigate to login
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email verified successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(milliseconds: 600),
                    ),
                  );
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              } else if (state.errorMessage != null) {
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                    duration: const Duration(milliseconds: 800),
                  ),
                );
              }
            },
            builder: (context, state) {
              // For password reset flow, we don't need to check token from cubit
              if (!_isPasswordReset) {
                final token = context.read<AuthRegistrationCubit>().verificationToken;
                if (token == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Verification token not found. Please try again.'),
                        backgroundColor: AppColors.redColor,
                        duration: Duration(milliseconds: 800),
                      ),
                    );
                    Navigator.pop(context);
                  });
                  return const SizedBox.shrink();
                }
              }

              final isLoading = state.isLoading;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Header with Back Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: SvgPicture.asset(
                            'assets/icons/back_button_with_circle.svg',
                            height: 40,
                            width: 40,
                          ),
                        ),
                        Text(
                          _isPasswordReset ? 'Reset Password' : 'Verification',
                          style: AppTextStyle.SFProDisplay_Regular.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Email info text
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "We've sent a verification code to your email:",
                            style: AppTextStyle.SFProDisplay_Regular,
                          ),
                          Text(
                            _userEmail,
                            style: AppTextStyle.SFProDisplay_Regular.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // OTP Input Field
                    Center(
                      child: Pinput(
                        controller: _otpController,
                        length: 6,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        defaultPinTheme: PinTheme(
                          width: 50,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primaryColor, width: 0.6),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        focusedPinTheme: PinTheme(
                          width: 50,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primaryColor, width: 1.7),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        submittedPinTheme: PinTheme(
                          width: 50,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primaryColor, width: 1),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        onCompleted: (pin) => _handleVerifyOTP(),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Optimized: Hide text when timer is running
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_canResend)
                            Text(
                              "Didn't get the code? ",
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          if (!_canResend)
                            Text(
                              '00:${_resendTimer.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          if (_canResend)
                            GestureDetector(
                              onTap: _handleResendCode,
                              child: Text(
                                'Resend Code',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Confirm Button with loading state
                    CustomElevatedButton(
                      onPressed: isLoading ? null : _handleVerifyOTP,
                      buttonText: isLoading ? 'Verifying...' : 'Confirm code',
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      height: 56,
                      isFullWidth: true,
                      isRounded: true,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}