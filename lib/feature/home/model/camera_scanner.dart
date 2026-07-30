import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;
import '../../../feature/bill_of_loading/cubit/bill_of_loading_scan_cubit.dart';
import '../../../feature/bill_of_loading/scan_bill_of_loading.dart';

class CameraScanScreen extends StatefulWidget {
  const CameraScanScreen({super.key});

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    developer.log('📷 CameraScanScreen: initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showImageSourceDialog();
    });
  }

  Future<void> _showImageSourceDialog() async {
    if (_isDialogShowing) return;

    setState(() {
      _isDialogShowing = true;
    });

    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
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
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.camera_alt,
                  size: 28, color: Color(0xFF1E3A5F)),
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
              leading: const Icon(Icons.photo_library,
                  size: 28, color: Color(0xFF1E3A5F)),
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
    ).whenComplete(() {
      if (mounted) {
        setState(() {
          _isDialogShowing = false;
        });
      }
    });
  }

  Future<void> _captureImage(ImageSource source) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      developer.log('📷 Starting image capture from: $source');

      final XFile? photo;

      if (source == ImageSource.camera) {
        photo = await _picker.pickImage(
          source: source,
          preferredCameraDevice: CameraDevice.rear,
          imageQuality: 90,
        );
      } else {
        photo = await _picker.pickImage(
          source: source,
          imageQuality: 90,
        );
      }

      developer.log('📷 Capture result: photo = ${photo?.path ?? "null"}');

      if (photo != null && mounted) {
        developer.log('✅ Image selected: ${photo.path}');
        final String imagePath = photo.path;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => ScanBolCubit(),
              child: OCRLoadingScreen(imagePath: imagePath),
            ),
          ),
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_isDialogShowing) {
              Navigator.pop(context);
            }
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Scan Document',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Loading image...',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt, size: 80, color: Colors.white54),
                  const SizedBox(height: 16),
                  const Text(
                    'Select an option to continue',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showImageSourceDialog(),
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Choose Image Source'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
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

// OCR Loading Screen
class OCRLoadingScreen extends StatefulWidget {
  final String imagePath;

  const OCRLoadingScreen({super.key, required this.imagePath});

  @override
  State<OCRLoadingScreen> createState() => _OCRLoadingScreenState();
}

class _OCRLoadingScreenState extends State<OCRLoadingScreen> {
  bool _isProcessing = false;
  bool _didCancel = false;

  @override
  void initState() {
    super.initState();
    _startOCR();
  }

  void _startOCR() {
    if (!_isProcessing && mounted) {
      setState(() {
        _isProcessing = true;
        _didCancel = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_didCancel) {
          context.read<ScanBolCubit>().processOCR(widget.imagePath);
        }
      });
    }
  }

  Future<bool> _confirmCancel() async {
    if (!_isProcessing) return true;

    // IMPORTANT: read cubit from this screen's context (not dialog context)
    final cubit = context.read<ScanBolCubit>();

    final shouldPop = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: const Text(
              'Cancel Processing?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Are you sure you want to cancel document processing? Your progress will be lost.',
              style: TextStyle(fontSize: 15),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1E3A5F),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldPop) {
      _didCancel = true;
      _isProcessing = false;
      cubit.cancel();
    }

    return shouldPop;
  }

  Future<void> _handleBackPress() async {
    final shouldPop = await _confirmCancel();
    if (shouldPop && mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildStageRow({
    required String label,
    required bool isActive,
    required bool isDone,
  }) {
    final color = isDone
        ? const Color(0xFF2E7D32)
        : isActive
            ? const Color(0xFF1E3A5F)
            : Colors.grey[400]!;

    return Row(
      children: [
        Icon(
          isDone
              ? Icons.check_circle
              : isActive
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressUI(ScanBolLoading state) {
    final progress = state.progress.clamp(0.0, 1.0);
    final percent = (progress * 100).round();
    final stage = state.stage;

    final preparingDone = stage != 'preparing';
    final uploadingDone = stage == 'extracting';
    final extractingActive = stage == 'extracting';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              state.progressMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E3A5F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              stage == 'uploading'
                  ? 'Sending your BOL image to the server'
                  : stage == 'extracting'
                      ? 'Reading load details from the document'
                      : 'Getting things ready',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: const Color(0xFFE8EEF5),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF1E3A5F),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A5F),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStageRow(
                    label: 'Preparing image',
                    isActive: stage == 'preparing',
                    isDone: preparingDone,
                  ),
                  const SizedBox(height: 8),
                  _buildStageRow(
                    label: 'Uploading image',
                    isActive: stage == 'uploading',
                    isDone: uploadingDone,
                  ),
                  const SizedBox(height: 8),
                  _buildStageRow(
                    label: 'Extracting data',
                    isActive: extractingActive,
                    isDone: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: _handleBackPress,
              icon: const Icon(Icons.cancel_outlined, size: 20),
              label: const Text('Cancel Processing'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[800],
                side: BorderSide(color: Colors.grey[400]!),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _confirmCancel();
        if (!mounted) return;
        if (shouldPop) {
          Navigator.of(this.context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _handleBackPress,
            tooltip: 'Cancel processing',
          ),
          title: const Text(
            'Processing Document',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<ScanBolCubit, ScanBolState>(
          listener: (context, state) {
            if (_didCancel) return;

            // Cancelled: navigation is handled by _handleBackPress / system back
            if (state is ScanBolCancelled) return;

            if (state is ScanBolSuccess) {
              setState(() {
                _isProcessing = false;
              });
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ScanBillOfLoadingScreen(
                    imagePath: widget.imagePath,
                    ocrData: state.ocrData,
                  ),
                ),
              );
            } else if (state is ScanBolFailure) {
              setState(() {
                _isProcessing = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ScanBolLoading) {
              return _buildProgressUI(state);
            }

            if (state is ScanBolFailure) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Failed to Process Document',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A5F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Column(
                          children: [
                            Text(
                              state.errorMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[800],
                              ),
                            ),
                            if (state.detailedError != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  state.detailedError!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ],
                            if (state.statusCode != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Status Code: ${state.statusCode}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              developer.log('🔄 [UI] Retry button pressed');
                              context.read<ScanBolCubit>().resetState();
                              setState(() {
                                _isProcessing = false;
                              });
                              _startOCR();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A5F),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () {
                              developer.log('🔙 [UI] Cancel button pressed');
                              context.read<ScanBolCubit>().cancel();
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }

            // Initial / cancelled
            return _buildProgressUI(
              const ScanBolLoading(
                progressMessage: 'Initializing...',
                progress: 0.05,
                stage: 'preparing',
              ),
            );
          },
        ),
      ),
    );
  }
}
