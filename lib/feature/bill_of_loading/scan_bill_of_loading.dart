/**
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';
import 'package:tag/feature/bill_of_loading/cubit/add_load_cubit.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/components/Custom_Elevated_Button.dart';
import 'model/bill_of_load_data.dart';

class ScanBillOfLoadingScreen extends StatelessWidget {
  final String imagePath;
  final OCRData? ocrData;

  const ScanBillOfLoadingScreen({
    super.key,
    required this.imagePath,
    this.ocrData,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddLoadCubit(),
      child: _ScanBillOfLoadingView(
        imagePath: imagePath,
        ocrData: ocrData,
      ),
    );
  }
}

class _ScanBillOfLoadingView extends StatefulWidget {
  final String imagePath;
  final OCRData? ocrData;

  const _ScanBillOfLoadingView({
    required this.imagePath,
    this.ocrData,
  });

  @override
  State<_ScanBillOfLoadingView> createState() => _ScanBillOfLoadingViewState();
}

class _ScanBillOfLoadingViewState extends State<_ScanBillOfLoadingView> {
  late TextEditingController loadIdController;
  late TextEditingController companyController;
  late TextEditingController pickupLocationController;
  late TextEditingController deliveryLocationController;
  late TextEditingController shipmentDateController;
  late TextEditingController rateController;

  bool _isModified = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final data = widget.ocrData;

    loadIdController = TextEditingController(text: data?.loadIdString ?? '');
    companyController = TextEditingController(text: data?.companyName ?? '');
    pickupLocationController =
        TextEditingController(text: data?.pickupAddress ?? '');
    deliveryLocationController =
        TextEditingController(text: data?.deliveryAddress ?? '');
    shipmentDateController =
        TextEditingController(text: data?.formattedPickupDate ?? '');
    rateController = TextEditingController(
      text: data?.rate ?? data?.totalCharge ?? data?.price ?? '',
    );
  }

  @override
  void dispose() {
    loadIdController.dispose();
    companyController.dispose();
    pickupLocationController.dispose();
    deliveryLocationController.dispose();
    shipmentDateController.dispose();
    rateController.dispose();
    super.dispose();
  }

  /// mm/dd/yyyy or ISO → ISO8601
  String _toIsoDate(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return DateTime.now().toUtc().toIso8601String();

    try {
      return DateTime.parse(raw).toUtc().toIso8601String();
    } catch (_) {}

    final parts = raw.split('/');
    if (parts.length == 3) {
      final month = int.tryParse(parts[0]);
      final day = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (month != null && day != null && year != null) {
        return DateTime.utc(year, month, day).toIso8601String();
      }
    }

    return DateTime.now().toUtc().toIso8601String();
  }

  void _saveAndContinue() {
    final loadId = loadIdController.text.trim();
    final company = companyController.text.trim();
    final pickup = pickupLocationController.text.trim();
    final delivery = deliveryLocationController.text.trim();
    final dateText = shipmentDateController.text.trim();
    final rateText = rateController.text.trim();

    if (loadId.isEmpty || company.isEmpty || pickup.isEmpty || delivery.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill Load ID, Company, Pickup and Delivery'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final rate = num.tryParse(rateText) ?? 0;
    final pickupDateIso = _toIsoDate(
      dateText.isNotEmpty
          ? dateText
          : (widget.ocrData?.pickupDate ?? ''),
    );

    context.read<AddLoadCubit>().createFromOcr(
      loadId: loadId,
      companyName: company,
      pickupAddress: pickup,
      deliveryAddress: delivery,
      pickupDateIso: pickupDateIso,
      rate: rate,
      pickupCoordinates: widget.ocrData?.pickupLocation?.coordinates,
      deliveryCoordinates: widget.ocrData?.deliveryLocation?.coordinates,
      bolImage: widget.ocrData?.bolImage,
      isModified: _isModified || (widget.ocrData?.isModified ?? false),
    );
  }

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
                    child: Text(
                      'Failed to load image',
                      style: AppTextStyle.SFProDisplay_Regular.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.primaryColor),
            const SizedBox(height: 12),
            Text(
              'Scanned Document',
              style: AppTextStyle.SFProDisplay_Regular.copyWith(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                  onChanged: (_) => setState(() => _isModified = true),
                  style: AppTextStyle.SFProDisplay_Regular.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? const Color(0xFF1E3A5F),
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: AppTextStyle.SFProDisplay_Regular.copyWith(
                      fontSize: 15,
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

  Widget _buildEditableDoubleInfoCard({
    required String label1,
    required TextEditingController controller1,
    required String label2,
    required TextEditingController controller2,
    IconData? icon1,
    IconData? icon2,
    TextInputType? keyboardType1,
    TextInputType? keyboardType2,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildEditableInfoField(
            label: label1,
            controller: controller1,
            icon: icon1,
            keyboardType: keyboardType1,
          ),
          const SizedBox(height: 16),
          _buildEditableInfoField(
            label: label2,
            controller: controller2,
            icon: icon2,
            keyboardType: keyboardType2,
          ),
        ],
      ),
    );
  }

  Widget _buildEditableLocationCard() {
    const double iconSize = 32.0;
    const double lineWidth = 2.0;
    const double midGap = 20.0;

    Widget field({
      required String label,
      required TextEditingController controller,
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
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: controller,
              onChanged: (_) => setState(() => _isModified = true),
              style: AppTextStyle.SFProDisplay_Regular.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E3A5F),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
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
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Expanded(
              child: Column(
                children: [
                  field(
                    label: 'PICKUP LOCATION',
                    controller: pickupLocationController,
                  ),
                  const SizedBox(height: midGap),
                  field(
                    label: 'DELIVERY LOCATION',
                    controller: deliveryLocationController,
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
    return BlocConsumer<AddLoadCubit, AddLoadState>(
      listener: (context, state) {
        if (state is AddLoadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.loadDetails,
            arguments: state.data, // ✅ shows on Load Details
          );
        } else if (state is AddLoadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AddLoadLoading;

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
              onTap: isLoading ? null : () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset('assets/icons/back_button_with_circle.svg'),
              ),
            ),
            actions: [
              if (widget.ocrData != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 14, color: Colors.green[600]),
                        const SizedBox(width: 4),
                        Text(
                          'OCR Extracted',
                          style: AppTextStyle.SFProDisplay_Regular.copyWith(
                            fontSize: 10,
                            color: Colors.green[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                  Icon(Icons.check_circle,
                                      color: AppColors.primaryColor, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.ocrData != null
                                          ? 'OCR Extraction Complete. Please verify and edit details.'
                                          : 'Please fill in the bill of lading details.',
                                      style: AppTextStyle.SFProDisplay_Regular.copyWith(
                                        fontSize: 14,
                                        color: const Color(0xFF1E3A5F),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
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
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: widget.imagePath.isNotEmpty &&
                                      File(widget.imagePath).existsSync()
                                      ? Image.file(
                                    File(widget.imagePath),
                                    fit: BoxFit.cover,
                                  )
                                      : _buildImagePlaceholder(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Billing Details',
                              style: AppTextStyle.SFProDisplay_Regular.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildEditableDoubleInfoCard(
                              label1: 'LOAD ID',
                              controller1: loadIdController,
                              label2: 'COMPANY/BROKER',
                              controller2: companyController,
                              icon1: Icons.confirmation_number_outlined,
                              icon2: Icons.business_outlined,
                            ),
                            const SizedBox(height: 12),
                            _buildEditableLocationCard(),
                            const SizedBox(height: 12),
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
                            CustomElevatedButton(
                              onPressed: isLoading ? null : _saveAndContinue,
                              buttonText: isLoading
                                  ? 'Saving...'
                                  : 'Save Load & Continue',
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: AppColors.whiteColor,
                              height: 56,
                              isFullWidth: true,
                              hasShadow: false,
                              borderRadius: BorderRadius.circular(30),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 12),
                            CustomElevatedButton(
                              onPressed: isLoading ? null : () => Navigator.pop(context),
                              buttonText: 'Retake Scan',
                              backgroundColor: AppColors.lightBlueColor,
                              foregroundColor: AppColors.primaryColor,
                              height: 56,
                              isFullWidth: true,
                              hasShadow: false,
                              borderRadius: BorderRadius.circular(30),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.25),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primaryColor),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}*/










///
///
///
/// todo:: adding data
///
///
///
///





import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';
import 'package:tag/feature/bill_of_loading/cubit/add_load_cubit.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/components/Custom_Elevated_Button.dart';
import 'model/bill_of_load_data.dart';

class ScanBillOfLoadingScreen extends StatelessWidget {
  final String imagePath;
  final OCRData? ocrData;

  const ScanBillOfLoadingScreen({
    super.key,
    required this.imagePath,
    this.ocrData,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddLoadCubit(),
      child: _ScanBillOfLoadingView(
        imagePath: imagePath,
        ocrData: ocrData,
      ),
    );
  }
}

class _ScanBillOfLoadingView extends StatefulWidget {
  final String imagePath;
  final OCRData? ocrData;

  const _ScanBillOfLoadingView({
    required this.imagePath,
    this.ocrData,
  });

  @override
  State<_ScanBillOfLoadingView> createState() => _ScanBillOfLoadingViewState();
}

class _ScanBillOfLoadingViewState extends State<_ScanBillOfLoadingView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController loadIdController;
  late TextEditingController companyController;
  late TextEditingController pickupLocationController;
  late TextEditingController deliveryLocationController;
  late TextEditingController pickupDateController;
  late TextEditingController rateController;

  DateTime? _selectedPickupDate;
  bool _isModified = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final data = widget.ocrData;

    loadIdController = TextEditingController(text: data?.loadIdString ?? '');
    companyController = TextEditingController(text: data?.companyName ?? '');
    pickupLocationController =
        TextEditingController(text: data?.pickupAddress ?? '');
    deliveryLocationController =
        TextEditingController(text: data?.deliveryAddress ?? '');

    // Prefill pickup date from OCR when available (same display as Add Load)
    final ocrDateText = data?.formattedPickupDate ?? '';
    pickupDateController = TextEditingController(text: ocrDateText);
    _selectedPickupDate = _parseDate(ocrDateText) ??
        _parseDate(data?.pickupDate ?? '');

    rateController = TextEditingController(
      text: data?.rate ?? data?.totalCharge ?? data?.price ?? '',
    );
  }

  DateTime? _parseDate(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;

    try {
      return DateTime.parse(text).toLocal();
    } catch (_) {}

    final parts = text.split('/');
    if (parts.length == 3) {
      final month = int.tryParse(parts[0]);
      final day = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (month != null && day != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  @override
  void dispose() {
    loadIdController.dispose();
    companyController.dispose();
    pickupLocationController.dispose();
    deliveryLocationController.dispose();
    pickupDateController.dispose();
    rateController.dispose();
    super.dispose();
  }

  /// Same date picker as Add Load
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedPickupDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF1E3A5F),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedPickupDate = picked;
        _isModified = true;
        pickupDateController.text =
        '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }

  String _toIsoDate() {
    if (_selectedPickupDate != null) {
      final d = _selectedPickupDate!;
      return DateTime.utc(d.year, d.month, d.day).toIso8601String();
    }

    final parsed = _parseDate(pickupDateController.text);
    if (parsed != null) {
      return DateTime.utc(parsed.year, parsed.month, parsed.day)
          .toIso8601String();
    }

    final ocrRaw = widget.ocrData?.pickupDate;
    if (ocrRaw != null && ocrRaw.trim().isNotEmpty) {
      try {
        return DateTime.parse(ocrRaw).toUtc().toIso8601String();
      } catch (_) {}
    }

    return DateTime.now().toUtc().toIso8601String();
  }

  void _saveAndContinue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final loadId = loadIdController.text.trim();
    final company = companyController.text.trim();
    final pickup = pickupLocationController.text.trim();
    final delivery = deliveryLocationController.text.trim();
    final rateText = rateController.text.trim();

    if (pickup.isEmpty || delivery.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill Pickup and Delivery locations'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final rate = num.tryParse(rateText) ?? 0;

    context.read<AddLoadCubit>().createFromOcr(
      loadId: loadId,
      companyName: company,
      pickupAddress: pickup,
      deliveryAddress: delivery,
      pickupDateIso: _toIsoDate(),
      rate: rate,
      pickupCoordinates: widget.ocrData?.pickupLocation?.coordinates,
      deliveryCoordinates: widget.ocrData?.deliveryLocation?.coordinates,
      bolImage: widget.ocrData?.bolImage,
      isModified: _isModified || (widget.ocrData?.isModified ?? false),
    );
  }

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
                    child: Text(
                      'Failed to load image',
                      style: AppTextStyle.SFProDisplay_Regular.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Pinch to zoom • Drag to pan',
                  style: AppTextStyle.SFProDisplay_Regular.copyWith(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            Icon(Icons.receipt_long_rounded,
                size: 48, color: AppColors.primaryColor),
            const SizedBox(height: 12),
            Text(
              'Scanned Document',
              style: AppTextStyle.SFProDisplay_Regular.copyWith(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = true}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B7280),
          letterSpacing: 0.2,
        ),
        children: required
            ? const [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontWeight: FontWeight.w600,
            ),
          ),
        ]
            : [],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onChanged: (_) => setState(() => _isModified = true),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1E3A5F),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFB0B7C3)),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.textFieldWhiteColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: prefixIcon == null ? 12 : 0,
          vertical: maxLines > 1 ? 14 : 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
      ),
    );
  }

  Widget _buildFieldGroup({
    required String label,
    required Widget field,
    bool required = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, required: required),
        const SizedBox(height: 6),
        field,
      ],
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1E3A5F)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A5F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.info_outline_rounded,
            title: 'Basic Info',
          ),
          _buildFieldGroup(
            label: 'LOAD ID',
            field: _buildTextField(
              controller: loadIdController,
              hint: 'Enter Load ID',
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Load ID is required' : null,
            ),
          ),
          const SizedBox(height: 14),
          _buildFieldGroup(
            label: 'COMPANY/BROKER',
            field: _buildTextField(
              controller: companyController,
              hint: 'Enter company name',
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Company name is required'
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Same Date & Payment section as Add Load (PICKUP DATE picker + RATE)
  Widget _buildDatePaymentSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.calendar_today_outlined,
            title: 'Date & Payment',
          ),
          _buildFieldGroup(
            label: 'PICKUP DATE',
            field: _buildTextField(
              controller: pickupDateController,
              hint: 'mm/dd/yyyy',
              readOnly: true,
              onTap: () => _selectDate(context),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                  color: Colors.grey[400],
                ),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Pickup date is required'
                  : null,
            ),
          ),
          const SizedBox(height: 14),
          _buildFieldGroup(
            label: 'RATE (\$)',
            field: TextFormField(
              controller: rateController,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() => _isModified = true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Rate is required';
                if (num.tryParse(v.trim()) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E3A5F),
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle:
                const TextStyle(fontSize: 14, color: Color(0xFFB0B7C3)),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(
                      left: 12, right: 4, top: 12, bottom: 12),
                  child: Icon(
                    Icons.attach_money,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                ),
                filled: true,
                fillColor: AppColors.textFieldWhiteColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                  BorderSide(color: AppColors.primaryColor, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                  const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                  const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                ),
                errorStyle:
                const TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableLocationCard() {
    const double iconSize = 32.0;
    const double lineWidth = 2.0;
    const double midGap = 20.0;

    Widget field({
      required String label,
      required TextEditingController controller,
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
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: controller,
              onChanged: (_) => setState(() => _isModified = true),
              style: AppTextStyle.SFProDisplay_Regular.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E3A5F),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
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
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Expanded(
              child: Column(
                children: [
                  field(
                    label: 'PICKUP LOCATION',
                    controller: pickupLocationController,
                  ),
                  const SizedBox(height: midGap),
                  field(
                    label: 'DELIVERY LOCATION',
                    controller: deliveryLocationController,
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
    return BlocConsumer<AddLoadCubit, AddLoadState>(
      listener: (context, state) {
        if (state is AddLoadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.loadDetails,
            arguments: state.data,
          );
        } else if (state is AddLoadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AddLoadLoading;

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
              onTap: isLoading ? null : () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                    'assets/icons/back_button_with_circle.svg'),
              ),
            ),
            // actions: [
            //   if (widget.ocrData != null)
            //     Padding(
            //       padding: const EdgeInsets.only(right: 16),
            //       child: Container(
            //         padding:
            //         const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //         decoration: BoxDecoration(
            //           color: Colors.green.withOpacity(0.1),
            //           borderRadius: BorderRadius.circular(12),
            //         ),
            //         child: Row(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             Icon(Icons.check_circle,
            //                 size: 14, color: Colors.green[600]),
            //             const SizedBox(width: 4),
            //             Text(
            //               'OCR Extracted',
            //               style: AppTextStyle.SFProDisplay_Regular.copyWith(
            //                 fontSize: 10,
            //                 color: Colors.green[600],
            //                 fontWeight: FontWeight.w600,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            // ],
          ),
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFDBEAFE)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: AppColors.primaryColor,
                                        size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        widget.ocrData != null
                                            ? 'OCR Extraction Complete. Please verify and edit details.'
                                            : 'Please fill in the bill of lading details.',
                                        style: AppTextStyle.SFProDisplay_Regular
                                            .copyWith(
                                          fontSize: 14,
                                          color: const Color(0xFF1E3A5F),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
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
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: widget.imagePath.isNotEmpty &&
                                        File(widget.imagePath).existsSync()
                                        ? Image.file(
                                      File(widget.imagePath),
                                      fit: BoxFit.cover,
                                    )
                                        : _buildImagePlaceholder(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Billing Details',
                                style:
                                AppTextStyle.SFProDisplay_Regular.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildBasicInfoSection(),
                              const SizedBox(height: 12),
                              _buildEditableLocationCard(),
                              const SizedBox(height: 12),
                              _buildDatePaymentSection(),
                              const SizedBox(height: 24),
                              CustomElevatedButton(
                                onPressed:
                                isLoading ? null : _saveAndContinue,
                                buttonText: isLoading
                                    ? 'Saving...'
                                    : 'Save Load & Continue',
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: AppColors.whiteColor,
                                height: 56,
                                isFullWidth: true,
                                hasShadow: false,
                                borderRadius: BorderRadius.circular(30),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              const SizedBox(height: 12),
                              CustomElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => Navigator.pop(context),
                                buttonText: 'Save & assign load to a driver',
                                backgroundColor: AppColors.lightBlueColor,
                                foregroundColor: AppColors.primaryColor,
                                height: 56,
                                isFullWidth: true,
                                hasShadow: false,
                                borderRadius: BorderRadius.circular(30),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.25),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryColor),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}