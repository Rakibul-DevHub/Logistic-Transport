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
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    developer.log('📷 CameraScanScreen: initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureImage();
    });
  }

  Future<void> _captureImage() async {
    if (_isProcessing) {
      developer.log('⚠️ Already processing, skipping');
      return;
    }

    developer.log('📷 Starting image capture...');
    setState(() => _isProcessing = true);

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 90,
      );

      developer.log('📷 Capture result: photo = ${photo?.path ?? "null"}');

      if (photo != null) {
        developer.log('✅ Photo captured: ${photo.path}');

        // Simulate OCR processing
        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          developer.log('🔄 Navigating to BOL with path: ${photo.path}');

          // ✅ CRITICAL: Use pushReplacementNamed with context
          Navigator.pushReplacementNamed(
            context,  // 👈 Make sure context is passed!
            AppRoutes.bol,
            arguments: photo.path,
          );
        } else {
          developer.log('❌ Widget not mounted, cannot navigate');
        }
      } else {
        developer.log('⚠️ User cancelled camera or no photo returned');
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e, stack) {
      developer.log('❌ Error capturing image: $e', error: e, stackTrace: stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log('🎨 CameraScanScreen: build() called');
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isProcessing) ...[
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Launching Camera...',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ] else ...[
                const Icon(Icons.camera_alt, size: 60, color: Colors.white54),
                const SizedBox(height: 16),
                const Text(
                  'Preparing to scan...',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}