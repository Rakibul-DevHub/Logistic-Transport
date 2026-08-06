import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:signature/signature.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_colors.dart';
import '../../../shared/components/Custom_Elevated_Button.dart';

class BOLScreenArgs {
  final String? imagePath;
  final String? imageUrl;
  final String? loadId;
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

class PODScreenArgs {
  final String? imagePath;
  final String? imageUrl;
  final String? loadId;
  final File? imageFile;
  final Function(String? podImagePath)? onPODComplete;

  const PODScreenArgs({
    this.imagePath,
    this.imageUrl,
    this.loadId,
    this.imageFile,
    this.onPODComplete,
  });
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
  String? _loadId;
  bool _isProcessing = false;
  File? _signedImage;

  final GlobalKey _signatureKey = GlobalKey();

  // Fixed signature placement ratios relative to the BOL image size.
  // Keeping these as constants means the signature always lands at the
  // same relative size & position on the document, regardless of screen
  // size or how many times the user re-signs.
  static const double _kSignatureWidthRatio = 0.4;
  static const double _kSignatureHeightRatio = 0.15;
  static const double _kSignatureMargin = 20.0;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 3.0,
      penColor: Colors.blue.shade700,
      exportBackgroundColor: Colors.transparent,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments;

      if (args is BOLScreenArgs) {
        _args = args;
        _loadId = args.loadId;
        _bolImageUrl = args.imageUrl;

        if (args.imageFile != null) {
          _bolImage = args.imageFile;
        } else if (args.imagePath != null && args.imagePath!.isNotEmpty) {
          _bolImage = File(args.imagePath!);
        }
        setState(() {});
      } else if (args is Map) {
        _loadId = args['loadId'] as String?;
        _bolImageUrl = args['imageUrl'] as String?;

        if (args['imageFile'] != null && args['imageFile'] is File) {
          _bolImage = args['imageFile'] as File;
        } else if (args['imagePath'] != null) {
          _bolImage = File(args['imagePath'] as String);
        }
        _args = const BOLScreenArgs();
      } else {
        _args = const BOLScreenArgs();
      }
    });
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  void _startSigning() {
    if (_hasSignature) {
      _showRemoveDialog();
      return;
    }
    if (_bolImage == null && _bolImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No BOL image available to sign'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      _signaturePadVisible = true;
      _signatureController.clear();
    });
  }

  void _cancelSigning() {
    setState(() {
      _signaturePadVisible = false;
      _signatureController.clear();
    });
  }

  Future<void> _confirmSignature() async {
    if (_signatureController.isEmpty) {
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

    try {
      // IMPORTANT: do NOT pass a fixed width/height here. The strokes are
      // recorded in the coordinate space of the actual on-screen canvas
      // (which can be 800-1000+ px tall). Forcing toImage() to a small
      // fixed box like 800x300 squashes/clips the drawing before it ever
      // reaches the resize-and-composite step below, which is what was
      // causing the saved signature to look tiny and mis-positioned
      // compared to what was actually drawn. Capturing at natural
      // resolution and trimming afterwards keeps it WYSIWYG.
      final signatureImage = await _signatureController.toImage();

      if (signatureImage != null) {
        final mergedFile = await _mergeSignatureWithBOL(signatureImage);

        setState(() {
          _signedImage = mergedFile;
          _hasSignature = true;
          _signaturePadVisible = false;
          _isProcessing = false;
          // Clear the drawing controller now that the signature has been
          // baked into _signedImage. This is what prevents the raw
          // strokes from ever being drawn again as a "second" signature.
          _signatureController.clear();
        });

        if (_args?.onSignatureComplete != null) {
          _args!.onSignatureComplete!(mergedFile?.path);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signature applied successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          _isProcessing = false;
        });
        throw Exception('Failed to capture signature');
      }
    } catch (e) {
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
  }

  Future<File?> _mergeSignatureWithBOL(ui.Image signatureImage) async {
    try {
      Uint8List bolBytes;
      if (_bolImage != null) {
        bolBytes = await _bolImage!.readAsBytes();
      } else if (_bolImageUrl != null) {
        bolBytes = await _downloadImage(_bolImageUrl!);
      } else {
        throw Exception('No BOL image available');
      }

      final bolImg = img.decodeImage(bolBytes);
      if (bolImg == null) throw Exception('Failed to decode BOL image');

      final signatureBytes = await signatureImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (signatureBytes == null) throw Exception('Failed to capture signature');

      var signatureImg = img.decodeImage(signatureBytes.buffer.asUint8List());
      if (signatureImg == null) throw Exception('Failed to decode signature');

      // Trim away the transparent padding around the drawn strokes so we
      // keep only the actual ink. Without this, the empty space captured
      // by the raw canvas would count towards "the signature" and throw
      // off both the scale and the anchor point below.
      final trimmed = img.trim(signatureImg, mode: img.TrimMode.transparent);
      if (trimmed.width > 0 && trimmed.height > 0) {
        signatureImg = trimmed;
      }

      // Fixed target box: same ratios/margin every time, so the signature
      // always occupies the same maximum footprint on the document.
      final boxWidth = (bolImg.width * _kSignatureWidthRatio).toInt();
      final boxHeight = (bolImg.height * _kSignatureHeightRatio).toInt();

      // Scale the trimmed signature to fit inside that fixed box while
      // preserving its aspect ratio (so it never looks stretched/squashed),
      // then anchor its bottom-right corner to a fixed point. Net effect:
      // no matter how big, small, or off-center the user's strokes were,
      // the saved signature always ends up the same size and in the same
      // spot on the BOL.
      final scale = [
        boxWidth / signatureImg.width,
        boxHeight / signatureImg.height,
      ].reduce((a, b) => a < b ? a : b);

      final finalWidth = (signatureImg.width * scale).round();
      final finalHeight = (signatureImg.height * scale).round();

      final resizedSignature = img.copyResize(
        signatureImg,
        width: finalWidth,
        height: finalHeight,
      );

      final margin = _kSignatureMargin.toInt();
      final x = bolImg.width - margin - finalWidth;
      final y = bolImg.height - margin - finalHeight;

      final mergedImg = img.Image.from(bolImg);

      img.compositeImage(
        mergedImg,
        resizedSignature,
        dstX: x,
        dstY: y,
      );

      final tempDir = await getTemporaryDirectory();
      final fileName = 'signed_bol_${DateTime.now().millisecondsSinceEpoch}.png';
      final outputFile = File('${tempDir.path}/$fileName');
      final pngBytes = img.encodePng(mergedImg);
      await outputFile.writeAsBytes(pngBytes);

      return outputFile;
    } catch (e) {
      debugPrint('Error merging signature: $e');
      return null;
    }
  }

  Future<Uint8List> _downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error downloading image: $e');
    }
  }

  void _removeSignature() {
    setState(() {
      _hasSignature = false;
      _signaturePadVisible = false;
      _signedImage = null;
      _signatureController.clear();
    });
  }

  void _showRemoveDialog() {
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

  @override
  Widget build(BuildContext context) {
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
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                ],
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
          onTap: () => Navigator.pop(context, _signedImage?.path),
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
        if (_hasSignature)
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
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
      ],
    );
  }

  Widget _buildBolCard() {
    final hasImage = _bolImage != null || _bolImageUrl != null;
    // Once a signature has been confirmed, _signedImage (the merged file)
    // is the single source of truth for what's displayed — the original
    // _bolImage is never shown again alongside a live signature overlay.
    final displayImage = _signedImage ?? _bolImage;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = (screenHeight * 0.55).clamp(350.0, 650.0);

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
                    _loadId != null
                        ? 'Bill of Lading - #$_loadId'
                        : 'Bill of Lading Document',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E)),
                  ),
                ),
                // Clear button — only relevant while actively drawing.
                if (_signaturePadVisible)
                  GestureDetector(
                    onTap: () => _signatureController.clear(),
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
              height: imageHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ── 1. BOL IMAGE (or already-signed merged image) ──
                  Positioned.fill(
                    child: hasImage
                        ? displayImage != null
                        ? Image.file(
                      displayImage,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                        : _bolImageUrl != null
                        ? Image.network(
                      _bolImageUrl!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
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

                  // ── 2. LIVE SIGNATURE CANVAS ──
                  // Only shown while the user is actively drawing.
                  // Once confirmed (_hasSignature == true), this is hidden
                  // entirely — the signature is already baked into
                  // displayImage at a fixed size/position, so no second
                  // signature layer is ever drawn on top.
                  if (_signaturePadVisible)
                    Positioned.fill(
                      child: RepaintBoundary(
                        key: _signatureKey,
                        child: Container(
                          color: Colors.transparent,
                          child: Signature(
                            controller: _signatureController,
                            backgroundColor: Colors.transparent,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ),

                  // ── 3. Signing mode banner ──
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

                  // ── 4. Processing indicator ──
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
                '4. Tap "Confirm" to save or "Cancel" to discard',
            style: TextStyle(
                fontSize: 12, color: Color(0xFF555555), height: 1.65),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isProcessing) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
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
                  buttonText: 'Confirm',
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.whiteColor,
                  height: 48,
                  borderRadius: BorderRadius.circular(30),
                  isFullWidth: true,
                  hasShadow: false,
                  icon: const Icon(Icons.check, size: 18),
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
        CustomElevatedButton(
          onPressed: _startSigning,
          buttonText: _hasSignature ? 'Re-sign Document' : 'Draw Sign',
          backgroundColor:
          _hasSignature ? Colors.orange : AppColors.primaryColor,
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
        if (_hasSignature) ...[
          const SizedBox(height: 12),
          CustomElevatedButton(
            onPressed: () {
              Navigator.pop(context, _signedImage?.path);
            },
            buttonText: 'Continue',
            backgroundColor: const Color(0xFF27AE60),
            foregroundColor: AppColors.whiteColor,
            height: 48,
            borderRadius: BorderRadius.circular(30),
            isFullWidth: true,
            hasShadow: false,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            gap: 8,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ],
      ],
    );
  }
}