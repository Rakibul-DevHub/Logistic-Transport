import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';
import 'package:tag/feature/bill_of_loading/cubit/add_load_cubit.dart';
import 'package:tag/feature/map/map_screen.dart';
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
  late TextEditingController pickupDateController;
  late TextEditingController rateController;

  // Same pattern as Add Load — map / suggestions, not free-text only
  final List<ScanRouteLocation> _pickupLocations = [];
  final List<ScanRouteLocation> _deliveryLocations = [];

  DateTime? _selectedPickupDate;
  bool _isModified = false;
  bool _updatingLocationFromMap = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final data = widget.ocrData;

    loadIdController = TextEditingController(text: data?.loadIdString ?? '');
    companyController = TextEditingController(text: data?.companyName ?? '');

    _initLocationsFromOcr(data);

    final ocrDateText = data?.formattedPickupDate ?? '';
    pickupDateController = TextEditingController(text: ocrDateText);
    _selectedPickupDate =
        _parseDate(ocrDateText) ?? _parseDate(data?.pickupDate ?? '');

    rateController = TextEditingController(
      text: data?.rate ?? data?.totalCharge ?? data?.price ?? '',
    );
  }

  void _initLocationsFromOcr(OCRData? data) {
    _pickupLocations.clear();
    _deliveryLocations.clear();

    // Prefer list fields; fall back to singular getters so OCR always shows
    List<String> pickupAddrs = List<String>.from(data?.pickupAddresses ?? const []);
    List<String> deliveryAddrs =
        List<String>.from(data?.deliveryAddresses ?? const []);
    final pickupCoords =
        List<List<double>>.from(data?.allPickupCoordinates ?? const []);
    final deliveryCoords =
        List<List<double>>.from(data?.allDeliveryCoordinates ?? const []);

    if (pickupAddrs.isEmpty && (data?.pickupAddress.isNotEmpty ?? false)) {
      pickupAddrs = [data!.pickupAddress];
    }
    if (deliveryAddrs.isEmpty && (data?.deliveryAddress.isNotEmpty ?? false)) {
      deliveryAddrs = [data!.deliveryAddress];
    }

    if (pickupAddrs.isEmpty) {
      _pickupLocations.add(ScanRouteLocation(
        controller: TextEditingController(),
        coords: null,
      ));
    } else {
      for (var i = 0; i < pickupAddrs.length; i++) {
        _pickupLocations.add(ScanRouteLocation(
          controller: TextEditingController(text: pickupAddrs[i]),
          coords: i < pickupCoords.length
              ? List<double>.from(pickupCoords[i])
              : null,
        ));
      }
    }

    if (deliveryAddrs.isEmpty) {
      _deliveryLocations.add(ScanRouteLocation(
        controller: TextEditingController(),
        coords: null,
      ));
    } else {
      for (var i = 0; i < deliveryAddrs.length; i++) {
        _deliveryLocations.add(ScanRouteLocation(
          controller: TextEditingController(text: deliveryAddrs[i]),
          coords: i < deliveryCoords.length
              ? List<double>.from(deliveryCoords[i])
              : null,
        ));
      }
    }
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
    pickupDateController.dispose();
    rateController.dispose();
    for (final location in _pickupLocations) {
      location.controller.dispose();
    }
    for (final location in _deliveryLocations) {
      location.controller.dispose();
    }
    super.dispose();
  }

  void _addPickupLocation() {
    setState(() {
      _isModified = true;
      _pickupLocations.add(ScanRouteLocation(
        controller: TextEditingController(),
        coords: null,
      ));
    });
  }

  void _addDeliveryLocation() {
    setState(() {
      _isModified = true;
      _deliveryLocations.add(ScanRouteLocation(
        controller: TextEditingController(),
        coords: null,
      ));
    });
  }

  void _removePickupLocation(int index) {
    if (_pickupLocations.length <= 1) return;
    setState(() {
      _isModified = true;
      _pickupLocations[index].controller.dispose();
      _pickupLocations.removeAt(index);
    });
  }

  void _removeDeliveryLocation(int index) {
    if (_deliveryLocations.length <= 1) return;
    setState(() {
      _isModified = true;
      _deliveryLocations[index].controller.dispose();
      _deliveryLocations.removeAt(index);
    });
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
    final rateText = rateController.text.trim();

    for (final location in _pickupLocations) {
      if (location.controller.text.trim().isEmpty || location.coords == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please set all pickup locations (tap to pick on map if needed)',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    for (final location in _deliveryLocations) {
      if (location.controller.text.trim().isEmpty || location.coords == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please set all delivery locations (tap to pick on map if needed)',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final rate = num.tryParse(rateText) ?? 0;

    context.read<AddLoadCubit>().createFromOcr(
      loadId: loadId,
      companyName: company,
      ocrCopyId: widget.ocrData?.id ?? '',
      pickupAddresses:
          _pickupLocations.map((e) => e.controller.text.trim()).toList(),
      deliveryAddresses:
          _deliveryLocations.map((e) => e.controller.text.trim()).toList(),
      pickupDateIso: _toIsoDate(),
      rate: rate,
      pickupCoordinates: _pickupLocations.map((e) => e.coords!).toList(),
      deliveryCoordinates: _deliveryLocations.map((e) => e.coords!).toList(),
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

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    Widget? trailing,
  }) {
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
          if (trailing != null) ...[
            const Spacer(),
            trailing,
          ],
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

  Future<void> _pickLocationOnMap({
    required ScanRouteLocation locationData,
    required String mapTitle,
  }) async {
    final result = await MapScreen.openPickLocation(
      context,
      title: mapTitle,
      initialLng: locationData.coords != null && locationData.coords!.length >= 2
          ? locationData.coords![0]
          : null,
      initialLat: locationData.coords != null && locationData.coords!.length >= 2
          ? locationData.coords![1]
          : null,
    );

    if (result == null || !mounted) return;

    _updatingLocationFromMap = true;
    setState(() {
      _isModified = true;
      locationData.coords = result.coordinates;
      locationData.controller.text = result.address?.trim().isNotEmpty == true
          ? result.address!.trim()
          : '${result.lng.toStringAsFixed(7)}, ${result.lat.toStringAsFixed(7)}';
    });
    _updatingLocationFromMap = false;
  }

  Widget _buildLocationField({
    required ScanRouteLocation locationData,
    required String label,
    required IconData icon,
    required String mapTitle,
    required bool canRemove,
    required VoidCallback onRemove,
  }) {
    final hasCoords =
        locationData.coords != null && locationData.coords!.length >= 2;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(label),
              const SizedBox(height: 6),
              TextFormField(
                controller: locationData.controller,
                onChanged: (_) {
                  if (_updatingLocationFromMap) return;
                  setState(() {
                    _isModified = true;
                    // Text edited — require map pin again for fresh coordinates
                    locationData.coords = null;
                  });
                },
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Location is required';
                  }
                  if (locationData.coords == null ||
                      locationData.coords!.length < 2) {
                    return 'Tap the location icon to set on map';
                  }
                  return null;
                },
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E3A5F),
                ),
                decoration: InputDecoration(
                  hintText: 'Enter address or tap icon for map',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB0B7C3),
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: IconButton(
                    tooltip: 'Open map',
                    onPressed: () => _pickLocationOnMap(
                      locationData: locationData,
                      mapTitle: mapTitle,
                    ),
                    icon: Icon(
                      icon,
                      size: 20,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.textFieldWhiteColor,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
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
                    borderSide: BorderSide(
                      color: AppColors.primaryColor,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFEF4444),
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFEF4444),
                      width: 1.5,
                    ),
                  ),
                  errorStyle: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
              if (hasCoords) ...[
                const SizedBox(height: 4),
                Text(
                  'lng, lat: '
                  '${locationData.coords![0].toStringAsFixed(6)}, '
                  '${locationData.coords![1].toStringAsFixed(6)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (canRemove)
          Padding(
            padding: const EdgeInsets.only(top: 30, left: 8),
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: Colors.red.shade400,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Route Details: editable address text; map opens only from the left icon
  Widget _buildRouteDetailsSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.route_rounded,
            title: 'Route Details',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _addPickupLocation,
                  icon: Icon(
                    Icons.add_location_alt,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                  tooltip: 'Add Pickup Location',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addDeliveryLocation,
                  icon: Icon(
                    Icons.add_location,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                  tooltip: 'Add Delivery Location',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          ...List.generate(_pickupLocations.length, (index) {
            final isLast = index == _pickupLocations.length - 1;
            final canRemove = _pickupLocations.length > 1;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationField(
                  locationData: _pickupLocations[index],
                  label:
                      'PICKUP LOCATION ${_pickupLocations.length > 1 ? index + 1 : ''}'
                          .trim(),
                  icon: Icons.location_on_outlined,
                  mapTitle:
                      'Pick Pickup Location ${_pickupLocations.length > 1 ? index + 1 : ''}'
                          .trim(),
                  canRemove: canRemove,
                  onRemove: () => _removePickupLocation(index),
                ),
                if (!isLast) const SizedBox(height: 14),
              ],
            );
          }),
          if (_deliveryLocations.isNotEmpty) const SizedBox(height: 14),
          ...List.generate(_deliveryLocations.length, (index) {
            final isLast = index == _deliveryLocations.length - 1;
            final canRemove = _deliveryLocations.length > 1;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationField(
                  locationData: _deliveryLocations[index],
                  label:
                      'DELIVERY LOCATION ${_deliveryLocations.length > 1 ? index + 1 : ''}'
                          .trim(),
                  icon: Icons.flag_outlined,
                  mapTitle:
                      'Pick Delivery Location ${_deliveryLocations.length > 1 ? index + 1 : ''}'
                          .trim(),
                  canRemove: canRemove,
                  onRemove: () => _removeDeliveryLocation(index),
                ),
                if (!isLast) const SizedBox(height: 14),
              ],
            );
          }),
        ],
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
                              _buildRouteDetailsSection(),
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

/// Same helper as Add Load route rows (avoid name clash with OCR LocationData)
class ScanRouteLocation {
  final TextEditingController controller;
  List<double>? coords;

  ScanRouteLocation({
    required this.controller,
    this.coords,
  });
}

