import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/components/Custom_Elevated_Button.dart';

class BillOfLoadingScreen extends StatelessWidget {
  final String imagePath;

  const BillOfLoadingScreen({super.key, required this.imagePath});

  /// Show captured image in full-screen dialog
  void _viewOriginalImage(BuildContext context) {
    if (imagePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No image available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_rounded, size: 80, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                    const Text(
                      'Original Document',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pinch_rounded, size: 16, color: Colors.white70),
                      SizedBox(width: 8),
                      Text(
                        'Pinch to zoom • Drag to pan',
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build placeholder when no image is available
  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[300]!, Colors.grey[200]!],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 12),
            Text('Scanned Document', style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text('Tap to view original', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  /// Single Info Field Widget
  Widget _buildInfoField({
    required String label,
    required String value,
    IconData? icon,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: valueColor ?? const Color(0xFF1E3A5F)),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? const Color(0xFF1E3A5F),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Card with two info fields
  Widget _buildDoubleInfoCard({
    required String label1,
    required String value1,
    required String label2,
    required String value2,
    IconData? icon1,
    IconData? icon2,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoField(label: label1, value: value1, icon: icon1),
          const SizedBox(height: 16),
          _buildInfoField(label: label2, value: value2, icon: icon2),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Location Card — Stack approach:
  //
  // Layout structure:
  //   Row
  //   ├── LEFT: SizedBox(width: iconSize)
  //   │         Stack (fills the SizedBox height via IntrinsicHeight on the Row)
  //   │         ├── Positioned line  →  top = iconSize/2, bottom = iconSize/2
  //   │         │                       left = iconSize/2 - 1  (centered)
  //   │         └── Column
  //   │             ├── pickup SVG icon
  //   │             └── delivery SVG icon  (no extra SizedBox; right column drives gap)
  //   └── RIGHT: Expanded Column
  //             ├── pickup field
  //             ├── SizedBox(height: gap)   ← this gap stretches the line naturally
  //             └── delivery field
  //
  // IntrinsicHeight makes the left Stack the same height as the right Column,
  // so Positioned(bottom: iconSize/2) always lands exactly at the delivery icon centre.
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLocationCard() {
    const double iconSize = 32.0; // explicit size for both SVG icons
    const double lineWidth = 2.0;
    // Gap between the bottom of the pickup info box and the top of the delivery label.
    // Tweak this value if you want more/less breathing room.
    const double midGap = 20.0;

    Widget locationField({required String label, required String value}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E3A5F),
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      // IntrinsicHeight lets the left Stack know the total height of the right Column,
      // so the Positioned line can anchor to bottom correctly.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── LEFT: icon column with Stack-based connector line ──────────
            SizedBox(
              width: iconSize,
              child: Stack(
                children: [
                  // ① The connecting line — drawn BEHIND the icons.
                  //    top    = centre of pickup icon  (iconSize / 2)
                  //    bottom = centre of delivery icon (iconSize / 2 from bottom)
                  //    left   = centre of column minus half line width
                  Positioned(
                    top: iconSize / 2,
                    bottom: iconSize / 2,
                    left: (iconSize / 2) - (lineWidth / 2),
                    width: lineWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightBlueColor,
                        borderRadius: BorderRadius.circular(lineWidth / 2),
                      ),
                    ),
                  ),

                  // ② The two icons — drawn ON TOP of the line.
                  //    They are placed in a Column that matches the right column's
                  //    height thanks to IntrinsicHeight + crossAxisAlignment.stretch.
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Pickup icon at the very top
                      SvgPicture.asset(
                        'assets/icons/pickup_location.svg',
                        width: iconSize,
                        height: iconSize,
                      ),
                      // Delivery icon at the very bottom
                      SvgPicture.asset(
                        'assets/icons/delivery_location.svg',
                        width: iconSize,
                        height: iconSize,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ── RIGHT: pickup field + gap + delivery field ──────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  locationField(
                    label: 'PICKUP LOCATION',
                    value: '1422 Industrial Way, Chicago, IL',
                  ),
                  const SizedBox(height: midGap), // drives the line length
                  locationField(
                    label: 'DELIVERY LOCATION',
                    value: '9900 Logistics Blvd, Dallas, TX',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: AppColors.backgroundColor,
        centerTitle: true,
        title: Text(
          'Scan bill of lading',
          style: AppTextStyle.SFProDisplay_Regular.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset('assets/icons/back_button_with_circle.svg'),
          ),
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // OCR Success Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFDBEAFE)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.primaryColor, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'OCR Extraction Complete. Please verify details.',
                              style: TextStyle(fontSize: 14, color: Color(0xFF1E3A5F), fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Document Preview
                    GestureDetector(
                      onTap: () => _viewOriginalImage(context),
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (imagePath.isNotEmpty && File(imagePath).existsSync())
                                Image.file(
                                  File(imagePath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                                )
                              else
                                _buildImagePlaceholder(),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                                      stops: const [0.6, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 14,
                                right: 14,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2)),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(Icons.visibility_rounded, size: 16, color: AppColors.primaryColor),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'View Original',
                                        style: TextStyle(fontSize: 13, color: Colors.grey[800], fontWeight: FontWeight.w600, letterSpacing: 0.2),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.grey[600]),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => _viewOriginalImage(context),
                                    splashColor: Colors.white.withOpacity(0.3),
                                    highlightColor: Colors.white.withOpacity(0.15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Billing Details Header
                    const Text(
                      'Billing Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
                    ),

                    const SizedBox(height: 16),

                    // CARD 1: LOAD ID + COMPANY/BROKER
                    _buildDoubleInfoCard(
                      label1: 'LOAD ID',
                      value1: 'LD-882941-X',
                      label2: 'COMPANY/BROKER',
                      value2: 'SwiftLogix Global',
                    ),

                    const SizedBox(height: 12),

                    // CARD 2: PICKUP + DELIVERY (Stack-connected line)
                    _buildLocationCard(),

                    const SizedBox(height: 12),

                    // CARD 3: SHIPMENT DATE + RATE
                    _buildDoubleInfoCard(
                      label1: 'SHIPMENT DATE',
                      value1: '05/24/2024',
                      icon1: Icons.calendar_today_outlined,
                      label2: 'RATE (\$)',
                      value2: '2,450.00',
                      icon2: Icons.attach_money,
                    ),

                    const SizedBox(height: 24),

                    // Save Load & Continue
                    CustomElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      buttonText: 'Save Load & Continue',
                      backgroundColor: const Color(0xFF1E3A5F),
                      foregroundColor: Colors.white,
                      height: 56,
                      isFullWidth: true,
                      hasShadow: false,
                      elevation: 2,
                      borderRadius: BorderRadius.circular(30),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),

                    const SizedBox(height: 12),

                    // Retake Scan
                    CustomElevatedButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.camScan),
                      hasShadow: false,
                      buttonText: 'Retake Scan',
                      backgroundColor: AppColors.lightBlueColor,
                      foregroundColor: AppColors.primaryColor,
                      height: 56,
                      isFullWidth: true,
                      isOutlined: false,
                      borderRadius: BorderRadius.circular(30),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      icon: const Icon(Icons.refresh),
                      gap: 8,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}