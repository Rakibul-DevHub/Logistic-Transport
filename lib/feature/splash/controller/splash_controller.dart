// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
//
// class SplashController extends GetxController {
//   final RxInt _currentImageIndex = 0.obs;
//
//   // List of images to show (add your image assets here)
//   final List<String> splashImages = [
//     'assets/images/splash_logo.png', // Your central image
//   ];
//
//   int get currentImageIndex => _currentImageIndex.value;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _initializeSplash();
//   }
//
//   Future<void> _initializeSplash() async {
//     // Wait for assets to load
//     await Future.delayed(const Duration(milliseconds: 500));
//
//     // Navigate to next screen after delay
//     await _navigateToNextScreen();
//   }
//
//   Future<void> _navigateToNextScreen() async {
//     // Simulate loading time (3 seconds total)
//     await Future.delayed(const Duration(seconds: 3));
//
//     // Navigate to your main screen
//     Get.offAllNamed('/home'); // Change this to your actual route
//
//     // OR if you're not using GetX navigation:
//     // Get.to(() => const HomeScreen());
//   }
//
//   void updateImageIndex(int index) {
//     _currentImageIndex.value = index;
//   }
// }