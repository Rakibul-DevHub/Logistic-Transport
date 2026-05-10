import 'package:flutter/material.dart';
import 'feature/splash/view/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      // Start with Splash
      home: const SplashScreen(),
      // Define your routes
      routes: {
        '/home': (context) => const HomeScreen(), // Replace with your screen
        // Add more routes as needed
      },
    );
  }
}

// Placeholder for your next screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Home Screen')),
    );
  }
}