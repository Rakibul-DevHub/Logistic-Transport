import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;
import '../../../core/constants/app_routes.dart';

class CameraScanScreen extends StatefulWidget {
  const CameraScanScreen({super.key});

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    developer.log('📷 CameraScanScreen: initState called');
    // Navigate to camera immediately
    _captureImage();
  }

  Future<void> _captureImage() async {
    try {
      developer.log('📷 Starting image capture...');
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 90,
      );

      developer.log('📷 Capture result: photo = ${photo?.path ?? "null"}');

      if (photo != null && mounted) {
        developer.log('✅ Photo captured: ${photo.path}');
        // Navigate immediately - no delay
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.bol,
          arguments: photo.path,
        );
      } else if (mounted) {
        developer.log('⚠️ User cancelled camera');
        Navigator.pop(context);
      }
    } catch (e, stack) {
      developer.log('❌ Error capturing image: $e', error: e, stackTrace: stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log('🎨 CameraScanScreen: build() called');
    // Just show a black screen while launching - super fast
    return Scaffold(
      backgroundColor: Colors.black,
      body: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}