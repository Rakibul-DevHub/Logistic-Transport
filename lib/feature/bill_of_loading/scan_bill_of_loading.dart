import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/components/Custom_Elevated_Button.dart';

class ScanBillOfLoadingScreen extends StatefulWidget {
  final String imagePath;

  const ScanBillOfLoadingScreen({super.key, required this.imagePath});

  @override
  State<ScanBillOfLoadingScreen> createState() => _ScanBillOfLoadingScreenState();
}

class _ScanBillOfLoadingScreenState extends State<ScanBillOfLoadingScreen> {
  // Editable fields
  late TextEditingController loadIdController;
  late TextEditingController companyController;
  late TextEditingController pickupLocationController;
  late TextEditingController deliveryLocationController;
  late TextEditingController shipmentDateController;
  late TextEditingController rateController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with default values
    loadIdController = TextEditingController(text: 'LD-882941-X');
    companyController = TextEditingController(text: 'SwiftLogix Global');
    pickupLocationController = TextEditingController(text: '1422 Industrial Way, Chicago, IL');
    deliveryLocationController = TextEditingController(text: '9900 Logistics Blvd, Dallas, TX');
    shipmentDateController = TextEditingController(text: '05/24/2024');
    rateController = TextEditingController(text: '2,450.00');
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    loadIdController.dispose();
    companyController.dispose();
    pickupLocationController.dispose();
    deliveryLocationController.dispose();
    shipmentDateController.dispose();
    rateController.dispose();
    super.dispose();
  }

  /// Show captured image in full-screen dialog
  void _viewOriginalImage(BuildContext context) {
    if (widget.imagePath.isEmpty) {
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
                File(widget.imagePath),
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
                          style: AppTextStyle.SFProDisplay_Regular.copyWith(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
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
                    Text(
                      'Original Document',
                      style: AppTextStyle.SFProDisplay_Regular.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pinch_rounded, size: 16, color: Colors.white70),
                      const SizedBox(width: 8),
                      Text(
                        'Pinch to zoom • Drag to pan',
                        style: AppTextStyle.SFProDisplay_Regular.copyWith(
                          color: Colors.white70,
                          fontSize: 12,
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
            Text(
              'Scanned Document',
              style: AppTextStyle.SFProDisplay_Regular.copyWith(
                color: Colors.grey[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to view original',
              style: AppTextStyle.SFProDisplay_Regular.copyWith(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Single Editable Info Field Widget
  Widget _buildEditableInfoField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    Color? valueColor,
    TextInputType? keyboardType,
    bool isEnabled = true,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.SFProDisplay_Regular.copyWith(
            fontSize: 11,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: isEnabled ? const Color(0xFFF3F4F6) : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: isEnabled
                ? Border.all(color: Colors.transparent)
                : Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: valueColor ?? const Color(0xFF1E3A5F)),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: isEnabled,
                  style: AppTextStyle.SFProDisplay_Regular.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? const Color(0xFF1E3A5F),
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: AppTextStyle.SFProDisplay_Regular.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[400],
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  keyboardType: keyboardType,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Card with two editable info fields
  Widget _buildEditableDoubleInfoCard({
    required String label1,
    required TextEditingController controller1,
    required String label2,
    required TextEditingController controller2,
    IconData? icon1,
    IconData? icon2,
    Color? valueColor1,
    Color? valueColor2,
    TextInputType? keyboardType1,
    TextInputType? keyboardType2,
    bool isEnabled = true,
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
          _buildEditableInfoField(
            label: label1,
            controller: controller1,
            icon: icon1,
            valueColor: valueColor1,
            keyboardType: keyboardType1,
            isEnabled: isEnabled,
          ),
          const SizedBox(height: 16),
          _buildEditableInfoField(
            label: label2,
            controller: controller2,
            icon: icon2,
            valueColor: valueColor2,
            keyboardType: keyboardType2,
            isEnabled: isEnabled,
          ),
        ],
      ),
    );
  }

  /// Location Card with editable fields
  Widget _buildEditableLocationCard({
    bool isEnabled = true,
  }) {
    const double iconSize = 32.0;
    const double lineWidth = 2.0;
    const double midGap = 20.0;

    Widget editableLocationField({
      required String label,
      required TextEditingController controller,
      bool isEnabled = true,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyle.SFProDisplay_Regular.copyWith(
              fontSize: 11,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: isEnabled ? const Color(0xFFF3F4F6) : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: isEnabled
                  ? Border.all(color: Colors.transparent)
                  : Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: isEnabled,
                    style: AppTextStyle.SFProDisplay_Regular.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E3A5F),
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT: icon column with Stack-based connector line
            SizedBox(
              width: iconSize,
              child: Stack(
                children: [
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/pickup_location.svg',
                        width: iconSize,
                        height: iconSize,
                      ),
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
            // RIGHT: pickup field + gap + delivery field
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  editableLocationField(
                    label: 'PICKUP LOCATION',
                    controller: pickupLocationController,
                    isEnabled: isEnabled,
                  ),
                  const SizedBox(height: midGap),
                  editableLocationField(
                    label: 'DELIVERY LOCATION',
                    controller: deliveryLocationController,
                    isEnabled: isEnabled,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Save all edited data
  void _saveAndContinue() {
    // Get all edited values
    final String loadId = loadIdController.text;
    final String company = companyController.text;
    final String pickupLocation = pickupLocationController.text;
    final String deliveryLocation = deliveryLocationController.text;
    final String shipmentDate = shipmentDateController.text;
    final String rate = rateController.text;

    // Here you can save to database, API, etc.
    debugPrint('=== SAVED DATA ===');
    debugPrint('Load ID: $loadId');
    debugPrint('Company/Broker: $company');
    debugPrint('Pickup Location: $pickupLocation');
    debugPrint('Delivery Location: $deliveryLocation');
    debugPrint('Shipment Date: $shipmentDate');
    debugPrint('Rate: $rate');
    debugPrint('Image Path: ${widget.imagePath}');
    debugPrint('==================');

    Navigator.pushNamed(context, AppRoutes.loadDetails);

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
                          Expanded(
                            child: Text(
                              'OCR Extraction Complete. Please verify details.',
                              style: AppTextStyle.SFProDisplay_Regular.copyWith(
                                fontSize: 14,
                                color: const Color(0xFF1E3A5F),
                                fontWeight: FontWeight.w500,
                              ),
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
                              if (widget.imagePath.isNotEmpty && File(widget.imagePath).existsSync())
                                Image.file(
                                  File(widget.imagePath),
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
                                        style: AppTextStyle.SFProDisplay_Regular.copyWith(
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
                    Text(
                      'Billing Details',
                      style: AppTextStyle.SFProDisplay_Regular.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blackColor,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // CARD 1: LOAD ID + COMPANY/BROKER (Editable)
                    _buildEditableDoubleInfoCard(
                      label1: 'LOAD ID',
                      controller1: loadIdController,
                      label2: 'COMPANY/BROKER',
                      controller2: companyController,
                      icon1: Icons.confirmation_number_outlined,
                      icon2: Icons.business_outlined,
                    ),

                    const SizedBox(height: 12),

                    // CARD 2: PICKUP + DELIVERY LOCATIONS (Editable)
                    _buildEditableLocationCard(),

                    const SizedBox(height: 12),

                    // CARD 3: SHIPMENT DATE + RATE (Editable)
                    _buildEditableDoubleInfoCard(
                      label1: 'SHIPMENT DATE',
                      controller1: shipmentDateController,
                      label2: 'RATE (\$)',
                      controller2: rateController,
                      icon1: Icons.calendar_today_outlined,
                      icon2: Icons.attach_money,
                      keyboardType2: TextInputType.number,
                    ),

                    const SizedBox(height: 24),

                    // Save Load & Continue Button
                    CustomElevatedButton(
                      onPressed: _saveAndContinue,
                      buttonText: 'Save Load & Continue',
                      textStyle: AppTextStyle.SFProDisplay_Regular,
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.whiteColor,
                      height: 56,
                      isFullWidth: true,
                      hasShadow: false,
                      elevation: 2,
                      borderRadius: BorderRadius.circular(30),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),

                    const SizedBox(height: 12),

                    // Retake Scan Button
                    CustomElevatedButton(
                      onPressed: () {},
                      hasShadow: false,
                      buttonText: 'Save & assign load to a driver',
                      textStyle: AppTextStyle.SFProDisplay_Regular,
                      backgroundColor: AppColors.lightBlueColor,
                      foregroundColor: AppColors.primaryColor,
                      height: 56,
                      isFullWidth: true,
                      isOutlined: false,
                      borderRadius: BorderRadius.circular(30),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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