
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/constants/app_routes.dart';
import 'feature/auth/cubit/auth_resigstration_cubit.dart';
import 'feature/splash/view/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ✅ Provide AuthRegistrationCubit at app level
        // This cubit will be reused across CreateAccount → OTP → SetPassword flow
        BlocProvider(
          create: (_) => AuthRegistrationCubit(),
        ),
        // 👇 Add other global cubits here as needed:
        // BlocProvider(create: (_) => AuthCubit()),
        // BlocProvider(create: (_) => UserCubit()),
        // BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: MaterialApp(
        title: 'Your App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
          // Optional: Add your custom text themes, input decorations, etc.
        ),

        // initialRoute: AppRoutes.splash,
        initialRoute: AppRoutes.home,
        routes: AppRoutes.routes,

        // ✅ Optional: Handle unknown routes gracefully
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                'Page not found: ${settings.name}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
