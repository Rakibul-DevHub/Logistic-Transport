import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tag/core/constants/app_routes.dart';
import 'core/network/secure_storage_service.dart';
import 'feature/auth/cubit/auth_registration_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await dotenv.load(fileName: '.env');

  // Lock orientation for consistent UI
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize secure storage
  final storage = SecureStorageService.instance;

  // Optional: Check if user is logged in
  // final isLoggedIn = await storage.isLoggedIn();
  // print('User logged in: $isLoggedIn');

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
        ),
        // Add other Bloc providers here
        // BlocProvider(create: (context) => LoginCubit()),
        // BlocProvider(create: (context) => HomeCubit()),
      ],
      child: MaterialApp(
        title: 'Tag App',
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}