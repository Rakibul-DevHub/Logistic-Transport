/**
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tag/core/theme/app_text_style.dart';

import '../../../core/theme/app_colors.dart';

class BillOfLoadingScreen extends StatelessWidget {
  final String imagePath;

  const BillOfLoadingScreen({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Text(
                    'Scan bill of lading',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // OCR Success Message
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFDBEAFE),
                        ),
                      ),
                      child: Row(
                        children: [
                           Icon(
                            Icons.check_circle,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                           Expanded(
                            child: Text(
                              'OCR Extraction Complete. Please verify details.',
                              style: AppTextStyle.SFProDisplay_Regular
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Document Preview
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.picture_as_pdf,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Scanned Document',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.visibility,
                                    size: 16,
                                    color: Colors.grey[700],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'View Original',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Billing Details Section
                    const Text(
                      'Billing Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A5F),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Load ID
                    _buildDetailCard(
                      label: 'LOAD ID',
                      value: 'LD-882941-X',
                      icon: Icons.confirmation_number,
                    ),

                    const SizedBox(height: 12),

                    // Company/Broker
                    _buildDetailCard(
                      label: 'COMPANY/BROKER',
                      value: 'SwiftLogix Global',
                      icon: Icons.business,
                    ),

                    const SizedBox(height: 12),

                    // Pickup Location
                    _buildDetailCard(
                      label: 'PICKUP LOCATION',
                      value: '1422 Industrial Way, Chicago, IL',
                      icon: Icons.location_on,
                      iconColor: const Color(0xFF12B76A),
                    ),

                    const SizedBox(height: 12),

                    // Delivery Location
                    _buildDetailCard(
                      label: 'DELIVERY LOCATION',
                      value: '9900 Logistics Blvd, Dallas, TX',
                      icon: Icons.location_on,
                      iconColor: const Color(0xFFEF5350),
                    ),

                    const SizedBox(height: 12),

                    // Shipment Date
                    _buildDetailCard(
                      label: 'SHIPMENT DATE',
                      value: '05/24/2024',
                      icon: Icons.calendar_today,
                    ),

                    const SizedBox(height: 12),

                    // Rate
                    _buildDetailCard(
                      label: 'RATE (\$)',
                      value: '\$ 2,450.00',
                      icon: Icons.attach_money,
                      valueColor: const Color(0xFF12B76A),
                    ),

                    const SizedBox(height: 24),

                    // Save Load & Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to next screen or save load
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A5F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save Load & Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Retake Scan Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          'Retake Scan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A5F),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF1E3A5F),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
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

  Widget _buildDetailCard({
    required String label,
    required String value,
    required IconData icon,
    Color? iconColor,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: iconColor ?? const Color(0xFF1E3A5F),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF1E3A5F),
            ),
          ),
        ],
      ),
    );
  }
}*/













import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tag/core/theme/app_text_style.dart';
import 'package:tag/core/theme/app_colors.dart';

import '../../../core/constants/app_routes.dart';

class BillOfLoadingScreen extends StatelessWidget {
  final String imagePath;

  const BillOfLoadingScreen({
    super.key,
    required this.imagePath,
  });

  /// ✅ Show captured image in full-screen dialog
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
            // Full-screen zoomable image
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
                        Icon(
                          Icons.broken_image_rounded,
                          size: 80,
                          color: Colors.grey[600],
                        ),
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
            // Top bar with close button & title
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
            // Bottom hint: zoom instructions
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pinch_rounded, size: 16, color: Colors.white70),
                      const SizedBox(width: 8),
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

  /// ✅ Build a beautiful placeholder when no image is available
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

  /// ✅ Detail Card Widget
  Widget _buildDetailCard({
    required String label,
    required String value,
    required IconData icon,
    Color? iconColor,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor ?? const Color(0xFF1E3A5F)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: valueColor ?? const Color(0xFF1E3A5F)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Text(
                    'Scan bill of lading',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // OCR Success Message
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
                          Expanded(
                            child: Text(
                              'OCR Extraction Complete. Please verify details.',
                              style: AppTextStyle.SFProDisplay_Regular,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ✅ Document Preview - IMPROVED DESIGN
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
                              // Background: Show actual image or placeholder
                              if (imagePath.isNotEmpty && File(imagePath).existsSync())
                                Image.file(
                                  File(imagePath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                                )
                              else
                                _buildImagePlaceholder(),

                              // Overlay: Subtle gradient for better badge visibility
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

                              // ✅ "View Original" Badge
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
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.grey[600]),
                                    ],
                                  ),
                                ),
                              ),

                              // Tap Indicator: Subtle ripple effect
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

                    // Billing Details Section
                    const Text(
                      'Billing Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
                    ),

                    const SizedBox(height: 16),

                    // Load ID
                    _buildDetailCard(label: 'LOAD ID', value: 'LD-882941-X', icon: Icons.confirmation_number),
                    const SizedBox(height: 12),

                    // Company/Broker
                    _buildDetailCard(label: 'COMPANY/BROKER', value: 'SwiftLogix Global', icon: Icons.business),
                    const SizedBox(height: 12),

                    // Pickup Location
                    _buildDetailCard(
                      label: 'PICKUP LOCATION',
                      value: '1422 Industrial Way, Chicago, IL',
                      icon: Icons.location_on,
                      iconColor: const Color(0xFF12B76A),
                    ),
                    const SizedBox(height: 12),

                    // Delivery Location
                    _buildDetailCard(
                      label: 'DELIVERY LOCATION',
                      value: '9900 Logistics Blvd, Dallas, TX',
                      icon: Icons.location_on,
                      iconColor: const Color(0xFFEF5350),
                    ),
                    const SizedBox(height: 12),

                    // Shipment Date
                    _buildDetailCard(label: 'SHIPMENT DATE', value: '05/24/2024', icon: Icons.calendar_today),
                    const SizedBox(height: 12),

                    // Rate
                    _buildDetailCard(
                      label: 'RATE (\$)',
                      value: '\$ 2,450.00',
                      icon: Icons.attach_money,
                      valueColor: const Color(0xFF12B76A),
                    ),

                    const SizedBox(height: 24),

                    // Save Load & Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A5F),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Save Load & Continue',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Retake Scan Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.camScan),
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          'Retake Scan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1E3A5F), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
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