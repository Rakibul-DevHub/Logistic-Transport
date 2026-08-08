import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:signature/signature.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/utils/app_url.dart';
import 'package:tag/shared/components/Custom_Elevated_Button.dart';
import 'cubit/signed_bol_cubit.dart';

class BOLScreenArgs {
  final String? imagePath;
  final String? imageUrl;
  final String? loadId;  // This should be the _id from the load data
  final File? imageFile;
  final Function(String? signedImagePath)? onSignatureComplete;

  const BOLScreenArgs({
    this.imagePath,
    this.imageUrl,
    this.loadId,
    this.imageFile,
    this.onSignatureComplete,
  });

  bool get hasImage => imagePath != null || imageUrl != null || imageFile != null;
}

class BOLScreen extends StatefulWidget {
  const BOLScreen({super.key});

  @override
  State<BOLScreen> createState() => _BOLScreenState();
}

class _BOLScreenState extends State<BOLScreen> {
  late SignatureController _signatureController;
  BOLScreenArgs? _args;

  bool _hasSignature = false;
  bool _signaturePadVisible = false;
  File? _bolImage;
  String? _bolImageUrl;
  String? _loadId;  // This will store the _id from the load
  bool _isProcessing = false;
  bool _isDownloading = false;
  File? _signedImage;
  File? _downloadedImageFile;
  bool _isUploading = false;
  bool _uploadCompleted = false;
  String _uploadError = '';

  final GlobalKey _signatureKey = GlobalKey();
  late SignedBolCubit _signedBolCubit;

  // A4 paper ratio (1:1.414) - signature area at bottom right
  static const double _kSignatureWidthRatio = 0.35;
  static const double _kSignatureHeightRatio = 0.12;
  static const double _kSignatureMargin = 30.0;

  @override
  void initState() {
    super.initState();
    debugPrint('🔵 ========== BOLScreen initState START ==========');
    debugPrint('🔵 Creating SignatureController');
    _signatureController = SignatureController(
      penStrokeWidth: 3.0,
      penColor: Colors.blue.shade700,
      exportBackgroundColor: Colors.transparent,
    );

    debugPrint('🔵 Creating SignedBolCubit');
    _signedBolCubit = SignedBolCubit();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🔵 Post frame callback - extracting arguments');
      final args = ModalRoute.of(context)!.settings.arguments;
      debugPrint('🔵 Arguments type: ${args.runtimeType}');
      debugPrint('🔵 Arguments value: $args');

      if (args is BOLScreenArgs) {
        debugPrint('✅ Args is BOLScreenArgs');
        _args = args;
        _loadId = args.loadId;  // This is the _id from the load
        _bolImageUrl = args.imageUrl;
        debugPrint('🔵 Load ID (_id): $_loadId');
        debugPrint('🔵 Image URL: $_bolImageUrl');
        debugPrint('🔵 Image File exists: ${args.imageFile != null}');
        debugPrint('🔵 Image Path: ${args.imagePath}');

        if (args.imageFile != null) {
          debugPrint('✅ Using imageFile: ${args.imageFile!.path}');
          _bolImage = args.imageFile;
          setState(() {});
        } else if (args.imagePath != null && args.imagePath!.isNotEmpty) {
          debugPrint('✅ Using imagePath: ${args.imagePath}');
          final file = File(args.imagePath!);
          if (file.existsSync()) {
            debugPrint('✅ File size: ${file.lengthSync()} bytes');
          }
          _bolImage = file;
          setState(() {});
        } else if (args.imageUrl != null && args.imageUrl!.isNotEmpty) {
          debugPrint('✅ Will download from URL: ${args.imageUrl}');
          _downloadBolImage(args.imageUrl!);
        } else {
          debugPrint('⚠️ No image source provided');
        }
      } else if (args is Map) {
        debugPrint('✅ Args is Map');
        _loadId = args['loadId'] as String?;  // This is the _id from the load
        _bolImageUrl = args['imageUrl'] as String?;
        debugPrint('🔵 Load ID from Map: $_loadId');
        debugPrint('🔵 Image URL from Map: $_bolImageUrl');

        if (args['imageFile'] != null && args['imageFile'] is File) {
          final file = args['imageFile'] as File;
          debugPrint('✅ Using imageFile from Map: ${file.path}');
          _bolImage = file;
          setState(() {});
        } else if (args['imagePath'] != null) {
          debugPrint('✅ Using imagePath from Map: ${args['imagePath']}');
          final file = File(args['imagePath'] as String);
          if (file.existsSync()) {
            debugPrint('✅ File size: ${file.lengthSync()} bytes');
          }
          _bolImage = file;
          setState(() {});
        } else if (args['imageUrl'] != null) {
          debugPrint('✅ Will download from URL from Map: ${args['imageUrl']}');
          _downloadBolImage(args['imageUrl'] as String);
        } else {
          debugPrint('⚠️ No image source in Map');
        }
        _args = const BOLScreenArgs();
      } else {
        debugPrint('⚠️ Unknown args type: ${args.runtimeType}');
        _args = const BOLScreenArgs();
      }
      debugPrint('🔵 ========== BOLScreen initState END ==========');
    });
  }

  @override
  void dispose() {
    debugPrint('🔴 ========== BOLScreen dispose START ==========');
    _signatureController.dispose();
    _signedBolCubit.close();
    _cleanupDownloadedImage();
    debugPrint('🔴 ========== BOLScreen dispose END ==========');
    super.dispose();
  }

  void _cleanupDownloadedImage() {
    if (_downloadedImageFile != null && _downloadedImageFile!.existsSync()) {
      try {
        _downloadedImageFile!.deleteSync();
        debugPrint('🗑️ Cleaned up downloaded image: ${_downloadedImageFile!.path}');
      } catch (e) {
        debugPrint('❌ Failed to cleanup downloaded image: $e');
      }
      _downloadedImageFile = null;
    }
  }

  Future<void> _downloadBolImage(String url) async {
    debugPrint('📥 ========== DOWNLOAD START ==========');
    debugPrint('📥 Download URL: $url');
    setState(() {
      _isDownloading = true;
    });

    try {
      debugPrint('📥 Sending HTTP GET request...');
      final response = await http.get(Uri.parse(url));
      debugPrint('📥 Response Status Code: ${response.statusCode}');
      debugPrint('📥 Response Body Length: ${response.bodyBytes.length} bytes');

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        debugPrint('📥 Temp Directory: ${tempDir.path}');
        final fileName = 'bol_temp_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('📥 File saved to: ${file.path}');
        debugPrint('📥 File size: ${await file.length()} bytes');

        setState(() {
          _bolImage = file;
          _downloadedImageFile = file;
          _isDownloading = false;
        });
        debugPrint('✅ BOL image downloaded successfully');
      } else {
        debugPrint('❌ Download failed with status: ${response.statusCode}');
        setState(() {
          _isDownloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download image: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Download error: $e');
      setState(() {
        _isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    debugPrint('📥 ========== DOWNLOAD END ==========');
  }

  void _startSigning() {
    debugPrint('🖊️ _startSigning called');
    debugPrint('🖊️ _hasSignature: $_hasSignature');

    if (_hasSignature) {
      debugPrint('🖊️ Signature already exists, showing remove dialog');
      _showRemoveDialog();
      return;
    }
    if (_bolImage == null && _bolImageUrl == null) {
      debugPrint('⚠️ No BOL image available');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No BOL image available to sign'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    debugPrint('🖊️ Showing signature pad');
    setState(() {
      _signaturePadVisible = true;
      _signatureController.clear();
    });
  }

  void _cancelSigning() {
    debugPrint('🖊️ _cancelSigning called');
    setState(() {
      _signaturePadVisible = false;
      _signatureController.clear();
    });
  }

  Future<void> _confirmSignature() async {
    debugPrint('✅ ========== CONFIRM SIGNATURE START ==========');
    debugPrint('✅ Signature controller isEmpty: ${_signatureController.isEmpty}');
    debugPrint('✅ Signature points count: ${_signatureController.points.length}');

    if (_signatureController.isEmpty) {
      debugPrint('⚠️ Signature is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please draw your signature first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });
    debugPrint('🔄 Processing signature...');

    try {
      debugPrint('🔄 Capturing signature image...');
      final signatureImage = await _signatureController.toImage();
      debugPrint('🔄 Signature image captured: ${signatureImage?.width}x${signatureImage?.height}');

      if (signatureImage != null) {
        debugPrint('🔄 Merging signature with BOL...');
        final mergedFile = await _mergeSignatureWithBOL(signatureImage);
        debugPrint('🔄 Merged file path: ${mergedFile?.path}');
        if (mergedFile != null) {
          debugPrint('🔄 Merged file size: ${await mergedFile.length()} bytes');
        }

        setState(() {
          _signedImage = mergedFile;
          _hasSignature = true;
          _signaturePadVisible = false;
          _isProcessing = false;
          _signatureController.clear();
        });
        debugPrint('✅ Signature applied successfully');

        if (_args?.onSignatureComplete != null) {
          debugPrint('🔄 Calling onSignatureComplete callback');
          _args!.onSignatureComplete!(mergedFile?.path);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signature applied successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        debugPrint('🔄 Starting upload process...');
        _handleUploadSignedBol();
      } else {
        debugPrint('❌ Failed to capture signature - null image');
        setState(() {
          _isProcessing = false;
        });
        throw Exception('Failed to capture signature');
      }
    } catch (e) {
      debugPrint('❌ Error in _confirmSignature: $e');
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving signature: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    debugPrint('✅ ========== CONFIRM SIGNATURE END ==========');
  }

  Future<File?> _mergeSignatureWithBOL(ui.Image signatureImage) async {
    debugPrint('🔄 ========== MERGE SIGNATURE START ==========');
    try {
      Uint8List bolBytes;
      if (_bolImage != null) {
        debugPrint('🔄 Reading BOL from file: ${_bolImage!.path}');
        bolBytes = await _bolImage!.readAsBytes();
        debugPrint('🔄 BOL bytes length: ${bolBytes.length}');
      } else if (_bolImageUrl != null) {
        debugPrint('🔄 Downloading BOL from URL: $_bolImageUrl');
        bolBytes = await _downloadImage(_bolImageUrl!);
        debugPrint('🔄 Downloaded bytes length: ${bolBytes.length}');
      } else {
        debugPrint('❌ No BOL image available');
        throw Exception('No BOL image available');
      }

      debugPrint('🔄 Decoding BOL image...');
      final bolImg = img.decodeImage(bolBytes);
      if (bolImg == null) {
        debugPrint('❌ Failed to decode BOL image');
        throw Exception('Failed to decode BOL image');
      }
      debugPrint('🔄 BOL image dimensions: ${bolImg.width}x${bolImg.height}');

      debugPrint('🔄 Getting signature bytes...');
      final signatureBytes = await signatureImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (signatureBytes == null) {
        debugPrint('❌ Failed to capture signature bytes');
        throw Exception('Failed to capture signature');
      }
      debugPrint('🔄 Signature bytes length: ${signatureBytes.lengthInBytes}');

      debugPrint('🔄 Decoding signature...');
      var signatureImg = img.decodeImage(signatureBytes.buffer.asUint8List());
      if (signatureImg == null) {
        debugPrint('❌ Failed to decode signature');
        throw Exception('Failed to decode signature');
      }
      debugPrint('🔄 Signature dimensions: ${signatureImg.width}x${signatureImg.height}');

      // Trim transparent padding
      debugPrint('🔄 Trimming transparent padding...');
      final trimmed = img.trim(signatureImg, mode: img.TrimMode.transparent);
      if (trimmed.width > 0 && trimmed.height > 0) {
        signatureImg = trimmed;
        debugPrint('🔄 Trimmed signature dimensions: ${signatureImg.width}x${signatureImg.height}');
      }

      // Calculate signature area based on document size
      final int signatureAreaWidth = (bolImg.width * _kSignatureWidthRatio).toInt();
      final int signatureAreaHeight = (bolImg.height * _kSignatureHeightRatio).toInt();
      debugPrint('🔄 Signature area: ${signatureAreaWidth}x${signatureAreaHeight}');

      // Scale signature to fit within the signature area
      final double scaleX = signatureAreaWidth / signatureImg.width;
      final double scaleY = signatureAreaHeight / signatureImg.height;
      final double scale = scaleX < scaleY ? scaleX : scaleY;
      debugPrint('🔄 Scale factor: $scale');

      final int finalWidth = (signatureImg.width * scale).round();
      final int finalHeight = (signatureImg.height * scale).round();
      debugPrint('🔄 Final signature dimensions: ${finalWidth}x${finalHeight}');

      final resizedSignature = img.copyResize(
        signatureImg,
        width: finalWidth > 0 ? finalWidth : 1,
        height: finalHeight > 0 ? finalHeight : 1,
      );

      final int margin = _kSignatureMargin.toInt();
      final int x = bolImg.width - margin - finalWidth;
      final int y = bolImg.height - margin - finalHeight;
      debugPrint('🔄 Signature position: ($x, $y)');

      final mergedImg = img.Image.from(bolImg);
      img.compositeImage(
        mergedImg,
        resizedSignature,
        dstX: x > 0 ? x : 0,
        dstY: y > 0 ? y : 0,
      );

      final tempDir = await getTemporaryDirectory();
      final fileName = 'signed_bol_${DateTime.now().millisecondsSinceEpoch}.png';
      final outputFile = File('${tempDir.path}/$fileName');
      final pngBytes = img.encodePng(mergedImg);
      await outputFile.writeAsBytes(pngBytes);

      debugPrint('✅ Merged file saved: ${outputFile.path}');
      debugPrint('✅ Merged file size: ${await outputFile.length()} bytes');
      debugPrint('🔄 ========== MERGE SIGNATURE END ==========');
      return outputFile;
    } catch (e) {
      debugPrint('❌ Error merging signature: $e');
      debugPrint('🔄 ========== MERGE SIGNATURE END (ERROR) ==========');
      return null;
    }
  }

  Future<Uint8List> _downloadImage(String url) async {
    debugPrint('🔄 Downloading image from: $url');
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        debugPrint('🔄 Downloaded ${response.bodyBytes.length} bytes');
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error downloading image: $e');
      rethrow;
    }
  }

  void _removeSignature() {
    debugPrint('🖊️ _removeSignature called');
    setState(() {
      _hasSignature = false;
      _signaturePadVisible = false;
      _signedImage = null;
      _signatureController.clear();
      _uploadCompleted = false;
      _uploadError = '';
    });
  }

  void _showRemoveDialog() {
    debugPrint('🖊️ _showRemoveDialog called');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Signature already exists',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: const Text(
          'Remove the existing signature before adding a new one.',
          style: TextStyle(fontSize: 13.5, color: Color(0xFF555555)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _removeSignature();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove & Re-sign'),
          ),
        ],
      ),
    );
  }

  void _handleUploadSignedBol() {
    debugPrint('📤 ========== HANDLE UPLOAD START ==========');
    debugPrint('📤 _signedImage: ${_signedImage?.path}');
    debugPrint('📤 _loadId: $_loadId');

    if (_signedImage == null) {
      debugPrint('❌ No signed image to upload');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No signed image to upload'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final loadId = _loadId?.trim() ?? '';
    if (loadId.isEmpty) {
      debugPrint('❌ Load ID is missing');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Load ID is missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    debugPrint('📤 Uploading signed BOL for load: $loadId');
    debugPrint('📤 Signed image path: ${_signedImage!.path}');

    // Check file exists and get size
    if (_signedImage!.existsSync()) {
      debugPrint('📤 Signed image exists: true');
      debugPrint('📤 Signed image size: ${_signedImage!.lengthSync()} bytes');
    } else {
      debugPrint('❌ Signed image does not exist!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signed image file not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadError = '';
    });

    debugPrint('📤 Calling cubit.uploadSignedBol with field: "bolImage"');
    _signedBolCubit.uploadSignedBol(
      loadId: loadId,
      imageFile: _signedImage!,
    );
    debugPrint('📤 ========== HANDLE UPLOAD END ==========');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ BOLScreen build called');
    return BlocProvider.value(
      value: _signedBolCubit,
      child: BlocListener<SignedBolCubit, SignedBolState>(
        listener: (context, state) {
          debugPrint('📢 BlocListener received state: ${state.runtimeType}');
          if (state is SignedBolUploadSuccess) {
            debugPrint('✅ Upload success! Image URL: ${state.imageUrl}');
            setState(() {
              _isUploading = false;
              _uploadCompleted = true;
              _uploadError = '';
            });
            _cleanupDownloadedImage();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Signed BOL uploaded successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            debugPrint('📤 Navigating back with signed image path: ${_signedImage?.path}');
            Navigator.pop(context, _signedImage?.path);
          } else if (state is SignedBolFailure) {
            debugPrint('❌ Upload failed: ${state.errorMessage}');
            setState(() {
              _isUploading = false;
              _uploadError = state.errorMessage;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Upload Error: ${state.errorMessage}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          } else if (state is SignedBolLoading) {
            debugPrint('⏳ Upload in progress...');
          }
        },
        child: BlocBuilder<SignedBolCubit, SignedBolState>(
          builder: (context, state) {
            final isUploading = state is SignedBolLoading || _isUploading;
            debugPrint('🏗️ BlocBuilder building, isUploading: $isUploading');

            return Scaffold(
              backgroundColor: AppColors.backgroundColor,
              appBar: _buildAppBar(),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      physics: _signaturePadVisible
                          ? const NeverScrollableScrollPhysics()
                          : const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBolCard(),
                          const SizedBox(height: 16),
                          _buildInstructionsCard(),
                          const SizedBox(height: 16),
                          if (_uploadError.isNotEmpty)
                            _buildErrorCard(),
                          _buildActionButtons(context, state),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Upload Error: $_uploadError',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      surfaceTintColor: AppColors.backgroundColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: InkWell(
          onTap: () {
            debugPrint('👆 Back button pressed');
            _cleanupDownloadedImage();
            Navigator.pop(context, _signedImage?.path);
          },
          child: SvgPicture.asset('assets/icons/back_button_with_circle.svg'),
        ),
      ),
      title: const Text(
        'BOL',
        style: TextStyle(
          color: Color(0xFF1A1A2E),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        if (_hasSignature && !_uploadCompleted)
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 12, color: Color(0xFF27AE60)),
                SizedBox(width: 4),
                Text('Signed',
                    style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF27AE60),
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        if (_uploadCompleted)
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_done, size: 12, color: Color(0xFF27AE60)),
                SizedBox(width: 4),
                Text('Uploaded',
                    style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF27AE60),
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBolCard() {
    final hasImage = _bolImage != null || _bolImageUrl != null;
    final displayImage = _signedImage ?? _bolImage;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final imageHeight = screenHeight * 0.55;
    final imageWidth = screenWidth - 32;

    // Format the display text safely
    String displayText = 'Bill of Lading Document';
    if (_loadId != null && _loadId!.isNotEmpty) {
      // If it's a MongoDB ObjectId (24 characters), show first 8 chars
      if (_loadId!.length >= 24) {
        displayText = 'Bill of Lading - ${_loadId!.substring(0, 8)}...';
      } else {
        displayText = 'Bill of Lading - #$_loadId';
      }
      debugPrint('📋 BOL Card - loadId (_id): $_loadId');
    }

    if (_isDownloading) {
      return Container(
        height: imageHeight + 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Downloading BOL image...',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                const Icon(Icons.description_outlined,
                    size: 16, color: AppColors.primaryColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    displayText,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E)),
                  ),
                ),
                if (_signaturePadVisible)
                  GestureDetector(
                    onTap: () {
                      debugPrint('👆 Clear button pressed');
                      _signatureController.clear();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, size: 14, color: Colors.red),
                          SizedBox(width: 4),
                          Text('Clear',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                if (!hasImage && !_signaturePadVisible)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'No Image',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: SizedBox(
              width: imageWidth,
              height: imageHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: hasImage
                        ? displayImage != null
                        ? Image.file(
                      displayImage,
                      fit: BoxFit.contain,
                      width: imageWidth,
                      height: imageHeight,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                        : _bolImageUrl != null
                        ? Image.network(
                      _bolImageUrl!,
                      fit: BoxFit.contain,
                      width: imageWidth,
                      height: imageHeight,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                        : _placeholder()
                        : _placeholder(),
                  ),
                  if (_signaturePadVisible)
                    Positioned.fill(
                      child: RepaintBoundary(
                        key: _signatureKey,
                        child: Container(
                          color: Colors.transparent,
                          child: Signature(
                            controller: _signatureController,
                            backgroundColor: Colors.transparent,
                            width: imageWidth,
                            height: imageHeight,
                          ),
                        ),
                      ),
                    ),
                  if (_signaturePadVisible)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        color: AppColors.primaryColor.withOpacity(0.9),
                        child: const Row(
                          children: [
                            Icon(Icons.edit, color: Colors.white, size: 13),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Drawing mode — draw your signature on the canvas',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_isProcessing)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Processing signature...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 64, color: Color(0xFF888888)),
            SizedBox(height: 12),
            Text('BOL image not found',
                style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightBlueColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline,
                  color: AppColors.primaryColor, size: 16),
              const SizedBox(width: 8),
              const Text('Instructions',
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E))),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '1. Tap "Draw Sign" to start\n'
                '2. Draw your signature directly on the document\n'
                '3. Use "Clear" button to erase and redraw\n'
                '4. Tap "Confirm & Upload" to save and upload',
            style: TextStyle(
                fontSize: 12, color: Color(0xFF555555), height: 1.65),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, SignedBolState state) {
    final isUploading = state is SignedBolLoading || _isUploading;
    debugPrint('🎯 Building action buttons, isUploading: $isUploading');

    if (_isProcessing || isUploading || _isDownloading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Processing...'),
            ],
          ),
        ),
      );
    }

    if (_signaturePadVisible) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _cancelSigning,
                  icon: const Icon(Icons.close, size: 15),
                  label: const Text('Cancel',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomElevatedButton(
                  onPressed: _confirmSignature,
                  buttonText: 'Confirm & Upload',
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.whiteColor,
                  height: 48,
                  borderRadius: BorderRadius.circular(30),
                  isFullWidth: true,
                  hasShadow: false,
                  icon: const Icon(Icons.upload, size: 18),
                  gap: 6,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        if (_hasSignature && !_uploadCompleted) ...[
          CustomElevatedButton(
            onPressed: () {
              debugPrint('👆 Done button pressed (signed but not uploaded)');
              _cleanupDownloadedImage();
              Navigator.pop(context, _signedImage?.path);
            },
            buttonText: 'Done',
            backgroundColor: Colors.grey.shade600,
            foregroundColor: AppColors.whiteColor,
            height: 48,
            borderRadius: BorderRadius.circular(30),
            isFullWidth: true,
            hasShadow: false,
            icon: const Icon(Icons.check, size: 18),
            gap: 8,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 12),
          CustomElevatedButton(
            onPressed: _handleUploadSignedBol,
            buttonText: 'Retry Upload',
            backgroundColor: Colors.orange,
            foregroundColor: AppColors.whiteColor,
            height: 48,
            borderRadius: BorderRadius.circular(30),
            isFullWidth: true,
            hasShadow: false,
            icon: const Icon(Icons.refresh, size: 18),
            gap: 8,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ] else if (_hasSignature && _uploadCompleted) ...[
          CustomElevatedButton(
            onPressed: () {
              debugPrint('👆 Done button pressed (uploaded)');
              _cleanupDownloadedImage();
              Navigator.pop(context, _signedImage?.path);
            },
            buttonText: 'Done',
            backgroundColor: Colors.green.shade600,
            foregroundColor: AppColors.whiteColor,
            height: 48,
            borderRadius: BorderRadius.circular(30),
            isFullWidth: true,
            hasShadow: false,
            icon: const Icon(Icons.check, size: 18),
            gap: 8,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ] else ...[
          CustomElevatedButton(
            onPressed: _startSigning,
            buttonText: 'Draw Sign',
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.whiteColor,
            height: 48,
            borderRadius: BorderRadius.circular(30),
            isFullWidth: true,
            hasShadow: false,
            icon: SvgPicture.asset(
              'assets/icons/signature_pen.svg',
              colorFilter: const ColorFilter.mode(
                AppColors.whiteColor,
                BlendMode.srcIn,
              ),
            ),
            gap: 8,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ],
      ],
    );
  }
}

