import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/feature/auth/view/login_screen.dart';
import 'package:tag/feature/welcome/view/welcome_screen.dart';

import '../../feature/onboard/controller/onboard_cubit.dart';
import '../../main.dart';
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
  static const String signup = '/signup';
  static const String home = '/home';

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
    signup: (context) => const WelcomeScreen(),
    home: (context) => const HomeScreen(),
  };
}