import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/components/Custom_Elevated_Button.dart';

class AddLoadScreen extends StatefulWidget {
  const AddLoadScreen({super.key});

  @override
  State<AddLoadScreen> createState() => _AddLoadScreenState();
}

class _AddLoadScreenState extends State<AddLoadScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _loadIdController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _pickupLocationController = TextEditingController();
  final TextEditingController _deliveryLocationController = TextEditingController();
  final TextEditingController _pickupDateController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Document state
  File? _pickedImageFile;
  bool _isPickingImage = false;

  @override
  void dispose() {
    _loadIdController.dispose();
    _companyController.dispose();
    _pickupLocationController.dispose();
    _deliveryLocationController.dispose();
    _pickupDateController.dispose();
    _rateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ─── View Full Image Dialog ─────────────────────────────────────────────────
  void _viewFullImage() {
    if (_pickedImageFile == null) return;

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
                _pickedImageFile!,
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
                      ],
                    ),
                  );
                },
              ),
            ),
            // Top bar with close button
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
                      'Document Preview',
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
            // Bottom hint for zoom instructions
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

  // ─── Date Picker ─────────────────────────────────────────────────────────────
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
        _pickupDateController.text =
        '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  // ─── Pick image — stays on THIS screen, no navigation ────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    // Pop the bottom sheet first, then pick
    if (Navigator.canPop(context)) Navigator.pop(context);

    // Small delay to let the bottom sheet close cleanly before camera/gallery opens
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    setState(() => _isPickingImage = true);

    try {
      final XFile? picked;

      if (source == ImageSource.camera) {
        picked = await ImagePicker().pickImage(
          source: source,
          preferredCameraDevice: CameraDevice.rear,
          imageQuality: 90,
        );
      } else {
        picked = await ImagePicker().pickImage(
          source: source,
          imageQuality: 90,
        );
      }

      if (!mounted) return;

      if (picked != null) {
        setState(() {
          _pickedImageFile = File(picked!.path);
          _isPickingImage = false;
        });
      } else {
        setState(() => _isPickingImage = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPickingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ─── Bottom sheet for source selection ───────────────────────────────────────
  void _showSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // drag handle
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
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightBlueColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.camera_alt_rounded, color: AppColors.primaryColor, size: 22),
              ),
              title: const Text(
                'Take a Photo',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F)),
              ),
              subtitle: const Text(
                'Capture document with camera',
                style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            const Divider(height: 1, indent: 72, endIndent: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightBlueColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.photo_library_rounded, color: AppColors.primaryColor, size: 22),
              ),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F)),
              ),
              subtitle: const Text(
                'Select an existing photo',
                style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── Save ─────────────────────────────────────────────────────────────────────
  void _onSave() {
    if (_formKey.currentState!.validate()) {
      // Here you can save all data including the image file
      debugPrint('=== SAVED LOAD DATA ===');
      debugPrint('Load ID: ${_loadIdController.text}');
      debugPrint('Company: ${_companyController.text}');
      debugPrint('Pickup: ${_pickupLocationController.text}');
      debugPrint('Delivery: ${_deliveryLocationController.text}');
      debugPrint('Date: ${_pickupDateController.text}');
      debugPrint('Rate: ${_rateController.text}');
      debugPrint('Notes: ${_notesController.text}');
      debugPrint('Image Path: ${_pickedImageFile?.path}');
      debugPrint('=======================');

      Navigator.pop(context);
    }
  }

  // ─── Scan BOL ─────────────────────────────────────────────────────────────────
  void _onScanBOL() {
    Navigator.pushNamed(context, AppRoutes.camScan);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────────
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
            style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600),
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
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1E3A5F),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFFB0B7C3),
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.textFieldWhiteColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: prefixIcon == null ? 12 : 0,
          vertical: maxLines > 1 ? 14 : 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
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

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 2)),
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldGroup({required String label, required Widget field, bool required = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, required: required),
        const SizedBox(height: 6),
        field,
      ],
    );
  }

  // ─── Sections ─────────────────────────────────────────────────────────────────
  Widget _buildBasicInfoSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(icon: Icons.info_outline_rounded, title: 'Basic Info'),
          _buildFieldGroup(
            label: 'LOAD ID',
            field: _buildTextField(
              controller: _loadIdController,
              hint: 'Enter Load ID',
              validator: (v) => v == null || v.trim().isEmpty ? 'Load ID is required' : null,
            ),
          ),
          const SizedBox(height: 14),
          _buildFieldGroup(
            label: 'COMPANY/BROKER',
            field: _buildTextField(
              controller: _companyController,
              hint: 'Enter company name',
              validator: (v) => v == null || v.trim().isEmpty ? 'Company name is required' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteDetailsSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(icon: Icons.route_rounded, title: 'Route Details'),
          _buildFieldGroup(
            label: 'PICKUP LOCATION',
            field: _buildTextField(
              controller: _pickupLocationController,
              hint: 'City, State or Zip',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.location_on_outlined, size: 18, color: Colors.grey[400]),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Pickup location is required' : null,
            ),
          ),
          const SizedBox(height: 14),
          _buildFieldGroup(
            label: 'DELIVERY LOCATION',
            field: _buildTextField(
              controller: _deliveryLocationController,
              hint: 'City, State or Zip',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.flag_outlined, size: 18, color: Colors.grey[400]),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Delivery location is required' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePaymentSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(icon: Icons.calendar_today_outlined, title: 'Date & Payment'),
          _buildFieldGroup(
            label: 'PICKUP DATE',
            field: _buildTextField(
              controller: _pickupDateController,
              hint: 'mm/dd/yyyy',
              readOnly: true,
              onTap: () => _selectDate(context),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.calendar_month_outlined, size: 18, color: Colors.grey[400]),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Pickup date is required' : null,
            ),
          ),
          const SizedBox(height: 14),
          _buildFieldGroup(
            label: 'RATE (\$)',
            field: TextFormField(
              controller: _rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => v == null || v.trim().isEmpty ? 'Rate is required' : null,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E3A5F),
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFB0B7C3),
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon:  Padding(
                  padding: EdgeInsets.only(left: 12, right: 4, top: 12, bottom: 12),
                  child: Icon(Icons.attach_money,color: AppColors.primaryColor,size: 20,)
                ),
                filled: true,
                fillColor: AppColors.textFieldWhiteColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
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
            ),
          ),
        ],
      ),
    );
  }

  // ─── Document section — shows image preview inline, no navigation ─────────────
  Widget _buildDocumentSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(icon: Icons.file_copy_outlined, title: 'Document (Optional)'),

          // ── State 1: Loading spinner ──────────────────────────────────────
          if (_isPickingImage)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDDE1E9), width: 1.5),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryColor),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Opening...',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )

          // ── State 2: Image picked — show preview inline ───────────────────
          else if (_pickedImageFile != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image preview card with tap to view full screen
                GestureDetector(
                  onTap: _viewFullImage,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // The photo itself
                        Image.file(
                          _pickedImageFile!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            color: AppColors.textFieldWhiteColor,
                            child: const Center(child: Icon(Icons.broken_image_rounded, size: 48, color: Colors.grey)),
                          ),
                        ),
                        // Dark gradient at bottom for actions overlay
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // View full screen button
                                GestureDetector(
                                  onTap: _viewFullImage,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withOpacity(0.4)),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.visibility_rounded, size: 14, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('Preview', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ),
                                // Action buttons
                                Row(
                                  children: [
                                    // Retake / change
                                    GestureDetector(
                                      onTap: _showSourceSheet,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.white.withOpacity(0.4)),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.refresh_rounded, size: 14, color: Colors.white),
                                            SizedBox(width: 4),
                                            Text('Change', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Remove
                                    GestureDetector(
                                      onTap: () => setState(() => _pickedImageFile = null),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.delete_outline_rounded, size: 14, color: Colors.white),
                                            SizedBox(width: 4),
                                            Text('Remove', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )

          // ── State 3: Empty — upload prompt ───────────────────────────────
          else
            GestureDetector(
              onTap: _showSourceSheet,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFDDE1E9),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlueColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.cloud_upload_outlined, size: 26, color: AppColors.primaryColor),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Upload BOL',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Take photo or choose from gallery',
                      style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(icon: Icons.sticky_note_2_outlined, title: 'Notes (Optional)'),
          _buildFieldGroup(
            label: '',
            required: false,
            field: _buildTextField(
              controller: _notesController,
              hint: 'Add any specific load details or instructions here...',
              maxLines: 4,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: AppColors.backgroundColor,
        centerTitle: true,
        title: Text(
          'Add Load',
          style: AppTextStyle.SFProDisplay_Regular.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A5F),
          ),
        ),
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset('assets/icons/back_button_with_circle.svg'),
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Required fields notice
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                    '* Required fields',
                    style: AppTextStyle.SFProDisplay_Regular.copyWith(
                        fontSize: 12
                    )
                ),
              ),

              // Scrollable body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfoSection(),
                      const SizedBox(height: 12),
                      _buildRouteDetailsSection(),
                      const SizedBox(height: 12),
                      _buildDatePaymentSection(),
                      const SizedBox(height: 12),
                      _buildDocumentSection(),
                      const SizedBox(height: 12),
                      _buildNotesSection(),
                      const SizedBox(height: 24),

                      // Save Load & Continue
                      CustomElevatedButton(
                        onPressed: _onSave,
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

                      // Save & assign to driver
                      CustomElevatedButton(
                        onPressed: _onScanBOL,
                        hasShadow: false,
                        buttonText: 'Save & assign load to a driver',
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
      ),
    );
  }
}