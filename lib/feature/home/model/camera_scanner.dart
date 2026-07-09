/**
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
}*/








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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    developer.log('📷 CameraScanScreen: initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showImageSourceDialog();
    });
  }

  Future<void> _showImageSourceDialog() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, size: 28, color: Color(0xFF1E3A5F)),
              title: const Text(
                'Take a Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text('Capture a new document with camera'),
              onTap: () {
                Navigator.pop(context);
                _captureImage(ImageSource.camera);
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.photo_library, size: 28, color: Color(0xFF1E3A5F)),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text('Select an existing document from gallery'),
              onTap: () {
                Navigator.pop(context);
                _captureImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _captureImage(ImageSource source) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      developer.log('📷 Starting image capture from: $source');

      // ✅ FIX: Use conditional parameters based on source
      final XFile? photo;

      if (source == ImageSource.camera) {
        // For camera, specify rear camera
        photo = await _picker.pickImage(
          source: source,
          preferredCameraDevice: CameraDevice.rear,
          imageQuality: 90,
        );
      } else {
        // For gallery, don't specify camera device
        photo = await _picker.pickImage(
          source: source,
          imageQuality: 90,
        );
      }

      developer.log('📷 Capture result: photo = ${photo?.path ?? "null"}');

      if (photo != null && mounted) {
        developer.log('✅ Image selected: ${photo.path}');
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.scanBillOfLoading,
          arguments: photo.path,
        );
      } else if (mounted) {
        developer.log('⚠️ User cancelled selection');
        Navigator.pop(context);
      }
    } catch (e, stack) {
      developer.log('❌ Error selecting image: $e', error: e, stackTrace: stack);
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log('🎨 CameraScanScreen: build() called');
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _isLoading
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'Loading image...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 60, color: Colors.white54),
            const SizedBox(height: 16),
            const Text(
              'Select an option',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showImageSourceDialog(),
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Choose Image Source'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}