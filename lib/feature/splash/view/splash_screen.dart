
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/components/gradient_arc_loader.dart';
import 'splash_cubit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit()..startSplash(),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    // Listen for navigation trigger
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigate) {
          _navigateToNext(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: Column(
            children: [
              // Center: Your Image (No Text)
              const Expanded(
                child: Center(
                  child: _CenterImage(),
                ),
              ),

              // Bottom: Custom Loader
              const _LoaderSection(),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToNext(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.onboard);
  }
}

// ============ UI Widgets (Keep them private & focused) ============

class _CenterImage extends StatelessWidget {
  const _CenterImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280, maxHeight: 280),
      padding: const EdgeInsets.all(0),
      child: SvgPicture.asset(
        'assets/images/splash_image.svg',
        width: MediaQuery.of(context).size.width,
        height: 250,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _LoaderSection extends StatelessWidget {
  const _LoaderSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Your custom GradientArcLoader
          GradientArcLoader(
            size: 72,
            duration: const Duration(milliseconds: 1400),
          ),
        ],
      ),
    );
  }
}





///
///
///
/// todo:: with video//gif//svg
///
///
///





// import 'package:flutter/material.dart';
// import 'package:gif_view/gif_view.dart';
// import '../../../core/constants/app_routes.dart';
// import '../../../shared/components/gradient_arc_loader.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   bool _isGifInitialized = false;
//   bool _hasNavigated = false;
//   late GifController _gifController;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeGif();
//
//     // Fallback navigation after 10 seconds (in case GIF fails)
//     Future.delayed(const Duration(seconds: 10), () {
//       if (mounted && !_hasNavigated) {
//         _hasNavigated = true;
//         _navigateToNext(context);
//       }
//     });
//   }
//
//   Future<void> _initializeGif() async {
//     _gifController = GifController();
//
//     // Simulate initialization delay
//     await Future.delayed(const Duration(milliseconds: 500));
//
//     if (mounted) {
//       setState(() {
//         _isGifInitialized = true;
//       });
//
//       // Start playing GIF
//       // _gifController.repeat();
//
//       // Get GIF duration (approx 8 seconds)
//       // Navigate after 8 seconds
//       Future.delayed(const Duration(seconds: 8), () {
//         if (mounted && !_hasNavigated) {
//           _hasNavigated = true;
//           _navigateToNext(context);
//         }
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _gifController.dispose();
//     super.dispose();
//   }
//
//   void _navigateToNext(BuildContext context) {
//     Navigator.pushReplacementNamed(context, AppRoutes.onboard);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: Center(
//                 child: _isGifInitialized
//                     ? GestureDetector(
//                   onTap: () {
//                     if (!_hasNavigated) {
//                       _hasNavigated = true;
//                       _navigateToNext(context);
//                     }
//                   },
//                   child: Container(
//                     constraints: const BoxConstraints(maxWidth: double.infinity, maxHeight: 350),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(16),
//                       child: GifView.asset(
//                         'assets/images/splash_screen_gify.gif',
//                         cubit: _gifController,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 )
//                     : Container(
//                   constraints: const BoxConstraints(maxWidth: 280, maxHeight: 280),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade200,
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: const Center(
//                     child: CircularProgressIndicator(
//                       color: Color(0xFF1E3A5F),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 48),
//               child: Column(
//                 children: [
//                   const GradientArcLoader(
//                     size: 72,
//                     duration: Duration(milliseconds: 1400),
//                   ),
//                   const SizedBox(height: 16),
//                   if (_isGifInitialized)
//                     const Text(
//                       'Loading...',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }