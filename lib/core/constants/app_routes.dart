
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/feature/auth/view/create_account_screen.dart';
import 'package:tag/feature/auth/view/login_screen.dart';
import 'package:tag/feature/auth/view/otp_verify_screen.dart';
import 'package:tag/feature/bill_of_loading/add_loading.dart';
import 'package:tag/feature/bill_of_loading/scan_bill_of_loading.dart';
import 'package:tag/feature/home/model/camera_scanner.dart';
import 'package:tag/feature/load/view/bol_screen.dart';
import 'package:tag/feature/load/view/load_details_screen.dart';
import 'package:tag/feature/load/view/load_screen.dart';
import 'package:tag/feature/load/view/pod_screen.dart';
import 'package:tag/feature/notification/view/notification_screen.dart';
import 'package:tag/feature/profile/view/account_settings/account_settings_screen.dart';
import 'package:tag/feature/profile/view/accountant/accountant_screen.dart';
import 'package:tag/feature/profile/view/app_preferences/app_preference_screen.dart';
import 'package:tag/feature/profile/view/help_and_support/help_support_screen.dart';
import 'package:tag/feature/profile/view/manage_drivers/drivers_screen.dart';
import 'package:tag/feature/profile/view/profile_screen.dart';
import 'package:tag/feature/profile/view/subscription/subscription_screen.dart';
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
  static const String scanBillOfLoading = '/scanBillOfLoading';
  static const String loadDetails = '/loadDetails';
  static const String billOfLoad = '/billOfLoad';
  static const String proofOfDelivery = '/proofOfDelivery';
  static const String addLoading = '/addLoading';
  static const String camScan = '/camScan';
  static const String notification = '/notification';
  static const String load = '/load';
  static const String report = '/report';
  static const String profile = '/profile';
  static const String accoutnSettings = '/accoutnSettings';
  static const String subscriptionScreen = '/subscriptionScreen';
  static const String appPreferencesScreen = '/appPreferencesScreen';
  static const String helpSupportScreen = '/helpSupportScreen';
  static const String sendToAccountantScreen = '/sendToAccountantScreen';
  static const String drivers = '/drivers';

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
    // bol: (context) => const BillOfLoadingScreen(imagePath: imagePath ?? ''),
    scanBillOfLoading: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      return ScanBillOfLoadingScreen(imagePath: args ?? '');
    },
    loadDetails: (context) => const LoadDetailsScreen(),
    billOfLoad: (context) => const BOLScreen(),
    proofOfDelivery: (context) => const PODScreen(),
    addLoading: (context) => const AddLoadScreen(),
    camScan: (context) => const CameraScanScreen(),
    notification: (context) => const NotificationScreen(),
    load: (context) => const LoadScreen(),
    report: (context) => const ReportScreen(),
    profile: (context) => const ProfileScreen(),
    accoutnSettings: (context) => const AccountSettingScreen(),
    subscriptionScreen: (context) => const SubscriptionScreen(),
    appPreferencesScreen: (context) => const AppPreferencesScreen(),
    helpSupportScreen: (context) => const HelpSupportScreen(),
    sendToAccountantScreen: (context) => const SendToAccountantScreen(),
    drivers: (context) => const DriversScreen(),

  };
}