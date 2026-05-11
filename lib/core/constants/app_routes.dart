import 'package:flutter_bloc/flutter_bloc.dart';

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
  static const String home = '/home';

  ///
  /// ==============Route map
  ///
  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    // onboard: (context) =>  OnboardingScreen(),
    onboard: (context) => BlocProvider(
      create: (_) => OnboardingCubit(3),
      child: const OnboardingScreen(),
    ),
    home: (context) => const HomeScreen(),
  };
}