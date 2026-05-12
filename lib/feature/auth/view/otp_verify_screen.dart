
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pinput/pinput.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';
import '../../../core/constants/app_routes.dart';
import '../cubit/auth_resigstration_cubit.dart';
import '../../../shared/components/custom_background.dart';
import '../../../shared/components/Custom_Elevated_Button.dart';

// ============================================
// OTP VERIFICATION SCREEN
// ============================================
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  int _resendTimer = 60;
  bool _canResend = false;

  // ✅ Get email from Cubit instead of constructor
  String get _userEmail => context.read<AuthRegistrationCubit>().email;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
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

  void _handleVerifyOTP() {
    final String otp = _otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 6-digit verification code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    context.read<AuthRegistrationCubit>().setLoading(true);

    // TODO: Replace with actual API call
    // Example: await authRepository.verifyOtp(email: _userEmail, otp: otp);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      setState(() => _isLoading = false);
      context.read<AuthRegistrationCubit>().setLoading(false);

      // ✅ Clear sensitive data after successful verification
      context.read<AuthRegistrationCubit>().clearData();

      // Navigate to next screen
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

  void _handleResendCode() {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
      _resendTimer = 60;
    });

    // TODO: Implement actual resend OTP API call
    debugPrint('Resending OTP to: $_userEmail');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification code resent successfully!'),
        backgroundColor: Colors.green,
      ),
    );

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
          child: Padding(
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
                      'Verification',
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

                // Email info text - ✅ Using cubit email
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                            Text("We've sent a verification code to your email:",style: AppTextStyle.SFProDisplay_Regular,),
                            Text(_userEmail,style: AppTextStyle.SFProDisplay_Regular.copyWith(
                              fontWeight: FontWeight.bold
                            ),),
                      ],
                    ),
                  ],
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

                // Resend Code Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                BlocBuilder<AuthRegistrationCubit, AuthRegistrationState>(
                  builder: (context, state) {
                    return CustomElevatedButton(
                      onPressed: (state.isLoading || _isLoading) ? null : _handleVerifyOTP,
                      buttonText: (state.isLoading || _isLoading)
                          ? 'Verifying...'
                          : 'Confirm code',
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      height: 56,
                      isFullWidth: true,
                      isRounded: true,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    );
                  },
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}