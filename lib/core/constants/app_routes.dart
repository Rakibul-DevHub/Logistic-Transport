
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/feature/auth/view/create_account_screen.dart';
import 'package:tag/feature/auth/view/login_screen.dart';
import 'package:tag/feature/auth/view/otp_verify_screen.dart';
import 'package:tag/feature/load/view/load_screen.dart';
import 'package:tag/feature/profile/view/profile_screen.dart';
import 'package:tag/feature/report/view/report_screen.dart';
import 'package:tag/feature/welcome/view/welcome_screen.dart';
import 'package:tag/shared/widget/bottom_nav.dart';
import '../../feature/home/view/home_screen.dart';
import '../../feature/onboard/controller/onboard_cubit.dart';
import 'package:flutter/material.dart';
import '../../feature/splash/view/splash_screen.dart';
import 'package:tag/feature/onboard/view/onboard_screen.dart';


class AppRoutes {

  AppRoutes._();
  ///
  /// ==============Route names
  ///
  static const String splash = '/splash';
  static const String onboard = '/onboard';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String createAccount = '/createAccount';
  static const String otpVerify = '/otpVerify';
  static const String bottomNav = '/bottomNav';
  static const String home = '/home';
  static const String load = '/load';
  static const String report = '/report';
  static const String profile = '/profile';

  ///
  /// ==============Route map
  ///
  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    onboard: (context) => BlocProvider(
      create: (_) => OnboardingCubit(3),
      child: const OnboardingScreen(),
    ),
    welcome: (context) => const WelcomeScreen(),
    login: (context) => const LoginScreen(),
    createAccount: (context) => const CreateAccountScreen(),
    otpVerify: (context) => const OtpVerificationScreen(),
    bottomNav: (context) => const BottomNav(),
    home: (context) => const HomeScreen(),
    load: (context) => const LoadScreen(),
    report: (context) => const ReportScreen(),
    profile: (context) => const ProfileScreen(),

  };
}