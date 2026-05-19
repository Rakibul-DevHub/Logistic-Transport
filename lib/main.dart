import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/constants/app_routes.dart';
import 'feature/auth/cubit/auth_registration_cubit.dart';

void main() {
  // Essential initialization only
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI (no await needed)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Optional: Lock orientation if your app doesn't need rotation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    // DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthRegistrationCubit(),
          // lazy: true is default, no need to specify
        ),
      ],
      child: MaterialApp(
        title: 'Your App',
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
