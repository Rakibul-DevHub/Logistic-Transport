import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/components/gradient_arc_loader.dart';
import '../controller/splash_cubit.dart';

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
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigate) {
          _navigateToNext(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: const Column(
            children: [
              Expanded(
                child: Center(
                  child: _SplashImage(),
                ),
              ),
              _LoaderWidget(),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToNext(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboard);
      }
    });
  }
}

// Optimized image widget with caching
class _SplashImage extends StatefulWidget {
  const _SplashImage();

  @override
  State<_SplashImage> createState() => _SplashImageState();
}

class _SplashImageState extends State<_SplashImage> {
  static Widget? _cachedImage; // Static cache shared across instances

  @override
  void initState() {
    super.initState();
    // Create cached image only once for the entire app lifecycle
    _cachedImage ??= SvgPicture.asset(
      'assets/images/splash_image.svg',
      fit: BoxFit.contain,
      width: 250,
      height: 250,
      placeholderBuilder: (context) => const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 280, maxHeight: 280),
      child: _ResponsiveImage(),
    );
  }
}

// Separate widget for responsive sizing
class _ResponsiveImage extends StatelessWidget {
  const _ResponsiveImage();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: _SplashImageState._cachedImage ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

// Optimized loader widget
class _LoaderWidget extends StatelessWidget {
  const _LoaderWidget();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 48),
      child: GradientArcLoader(
        size: 72,
        duration: Duration(milliseconds: 1400),
      ),
    );
  }
}







