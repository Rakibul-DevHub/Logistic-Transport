/**
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';
import 'package:tag/feature/map/location_coordinate_field.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/components/Custom_Elevated_Button.dart';
import 'cubit/add_load_cubit.dart';

class AddLoadScreen extends StatelessWidget {
  const AddLoadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddLoadCubit(),
      child: const _AddLoadView(),
    );
  }
}

class _AddLoadView extends StatefulWidget {
  const _AddLoadView();

  @override
  State<_AddLoadView> createState() => _AddLoadViewState();
}

class _AddLoadViewState extends State<_AddLoadView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _loadIdController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _pickupLocationController = TextEditingController();
  final TextEditingController _deliveryLocationController = TextEditingController();
  final TextEditingController _pickupDateController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  File? _pickedImageFile;
  bool _isPickingImage = false;
  DateTime? _selectedPickupDate;

  /// API coords [lng, lat] — set from map / suggestions
  List<double>? _pickupCoords;
  List<double>? _deliveryCoords;

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
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(_pickedImageFile!, fit: BoxFit.contain),
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
        _pickupDateController.text =
        '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (Navigator.canPop(context)) Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _isPickingImage = true);

    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 90,
      );
      if (!mounted) return;
      setState(() {
        if (picked != null) _pickedImageFile = File(picked.path);
        _isPickingImage = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPickingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not pick image: $e'), backgroundColor: Colors.red),
      );
    }
  }

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
              leading: Icon(Icons.camera_alt_rounded, color: AppColors.primaryColor),
              title: const Text('Take a Photo'),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: AppColors.primaryColor),
              title: const Text('Choose from Gallery'),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // void _onSave() {
  //   if (!_formKey.currentState!.validate()) return;
  //
  //   if (_pickupCoords == null || _deliveryCoords == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Select pickup & delivery from suggestions or map'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return;
  //   }
  //
  //   final rate = num.tryParse(_rateController.text.trim());
  //   if (rate == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Enter a valid rate'), backgroundColor: Colors.red),
  //     );
  //     return;
  //   }
  //
  //   if (_selectedPickupDate == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select pickup date'), backgroundColor: Colors.red),
  //     );
  //     return;
  //   }
  //
  //   final pickupDateIso = DateTime.utc(
  //     _selectedPickupDate!.year,
  //     _selectedPickupDate!.month,
  //     _selectedPickupDate!.day,
  //   ).toIso8601String();
  //
  //   context.read<AddLoadCubit>().createManualLoad(
  //     loadId: _loadIdController.text,
  //     companyName: _companyController.text,
  //     pickupCoordinates: _pickupCoords!,
  //     deliveryCoordinates: _deliveryCoords!,
  //     pickupDateIso: pickupDateIso,
  //     rate: rate,
  //     bolImageFile: _pickedImageFile,
  //     notes: _notesController.text,
  //   );
  // }


  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    if (_pickupCoords == null || _deliveryCoords == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select pickup & delivery from suggestions or map'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final rate = num.tryParse(_rateController.text.trim());
    if (rate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid rate'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedPickupDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select pickup date'), backgroundColor: Colors.red),
      );
      return;
    }

    final pickupDateIso = DateTime.utc(
      _selectedPickupDate!.year,
      _selectedPickupDate!.month,
      _selectedPickupDate!.day,
    ).toIso8601String();

    context.read<AddLoadCubit>().createManualLoad(
      loadId: _loadIdController.text,
      companyName: _companyController.text,
      pickupCoordinates: _pickupCoords!,
      deliveryCoordinates: _deliveryCoords!,
      pickupAddress: _pickupLocationController.text,
      deliveryAddress: _deliveryLocationController.text,
      pickupDateIso: pickupDateIso,
      rate: rate,
      bolImageFile: _pickedImageFile,
      notes: _notesController.text,
    );
  }


  void _onScanBOL() {
    Navigator.pushNamed(context, AppRoutes.camScan);
  }

  Widget _buildLabel(String text, {bool required = true}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B7280),
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
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFB0B7C3)),
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
        if (label.isNotEmpty) ...[
          _buildLabel(label, required: required),
          const SizedBox(height: 6),
        ],
        field,
      ],
    );
  }

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
          LocationCoordinateField(
            controller: _pickupLocationController,
            label: 'PICKUP LOCATION',
            hint: 'Type address or tap pin for map',
            icon: Icons.location_on_outlined,
            mapTitle: 'Pick Pickup Location',
            initialCoordinates: _pickupCoords,
            onCoordinatesChanged: (coords) {
              setState(() => _pickupCoords = coords);
            },
          ),
          const SizedBox(height: 14),
          LocationCoordinateField(
            controller: _deliveryLocationController,
            label: 'DELIVERY LOCATION',
            hint: 'Type address or tap flag for map',
            icon: Icons.flag_outlined,
            mapTitle: 'Pick Delivery Location',
            initialCoordinates: _deliveryCoords,
            onCoordinatesChanged: (coords) {
              setState(() => _deliveryCoords = coords);
            },
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
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Rate is required';
                if (num.tryParse(v.trim()) == null) return 'Enter a valid number';
                return null;
              },
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E3A5F),
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFB0B7C3)),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 4, top: 12, bottom: 12),
                  child: Icon(Icons.attach_money, color: AppColors.primaryColor, size: 20),
                ),
                filled: true,
                fillColor: AppColors.textFieldWhiteColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildDocumentSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(icon: Icons.file_copy_outlined, title: 'Document(BOL)'),
          if (_isPickingImage)
            const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ))
          else if (_pickedImageFile != null)
            GestureDetector(
              onTap: _viewFullImage,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.file(_pickedImageFile!, width: double.infinity, height: 200, fit: BoxFit.cover),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: _showSourceSheet,
                            child: const Text('Change', style: TextStyle(color: Colors.white)),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _pickedImageFile = null),
                            child: const Text('Remove', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            GestureDetector(
              onTap: _showSourceSheet,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDDE1E9)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 26, color: AppColors.primaryColor),
                    const SizedBox(height: 10),
                    const Text(
                      'Upload BOL',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F)),
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddLoadCubit, AddLoadState>(
      // listener: (context, state) {
      //   if (state is AddLoadSuccess) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text(state.message), backgroundColor: Colors.green),
      //     );
      //     Navigator.pop(context, state.data);
      //   } else if (state is AddLoadFailure) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text(state.errorMessage), backgroundColor: Colors.red),
      //     );
      //   }
      // },


      listener: (context, state) {
        if (state is AddLoadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );

          Navigator.pushReplacementNamed(
            context,
            AppRoutes.loadDetails,
            arguments: state.data,
          );
        } else if (state is AddLoadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage), backgroundColor: Colors.red),
          );
        }
      },




      builder: (context, state) {
        final isLoading = state is AddLoadLoading;
        final loadingMsg = state is AddLoadLoading ? state.progressMessage : null;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundColor,
            surfaceTintColor: AppColors.backgroundColor,
            centerTitle: true,
            elevation: 0,
            title: Text(
              'Add Load',
              style: AppTextStyle.SFProDisplay_Regular.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E3A5F),
              ),
            ),
            leading: InkWell(
              onTap: isLoading ? null : () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset('assets/icons/back_button_with_circle.svg'),
              ),
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '* Required fields',
                            style: AppTextStyle.SFProDisplay_Regular.copyWith(fontSize: 12),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
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
                              CustomElevatedButton(
                                onPressed: isLoading ? null : _onSave,
                                buttonText: isLoading
                                    ? (loadingMsg ?? 'Saving...')
                                    : 'Save Load & Continue',
                                backgroundColor: const Color(0xFF1E3A5F),
                                foregroundColor: Colors.white,
                                height: 56,
                                isFullWidth: true,
                                hasShadow: false,
                                borderRadius: BorderRadius.circular(30),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              const SizedBox(height: 12),
                              CustomElevatedButton(
                                onPressed: isLoading ? null : _onScanBOL,
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
                    ],
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.25),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppColors.primaryColor),
                          if (loadingMsg != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              loadingMsg,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
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
///
/// todo:: updating the design and the api implementation will be change
///
///
///
///




import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';
import 'package:tag/feature/load/view/load_details_screen.dart';
import 'package:tag/feature/map/location_coordinate_field.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/components/Custom_Elevated_Button.dart';
import 'cubit/add_load_cubit.dart';

class AddLoadScreen extends StatelessWidget {
  const AddLoadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddLoadCubit(),
      child: const _AddLoadView(),
    );
  }
}

class _AddLoadView extends StatefulWidget {
  const _AddLoadView();

  @override
  State<_AddLoadView> createState() => _AddLoadViewState();
}

class _AddLoadViewState extends State<_AddLoadView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _loadIdController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _pickupDateController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  File? _pickedImageFile;
  bool _isPickingImage = false;
  DateTime? _selectedPickupDate;

  // Multiple locations
  List<LocationData> _pickupLocations = [];
  List<LocationData> _deliveryLocations = [];

  @override
  void initState() {
    super.initState();
    // Add default pickup and delivery
    _pickupLocations.add(LocationData(
      controller: TextEditingController(),
      coords: null,
    ));
    _deliveryLocations.add(LocationData(
      controller: TextEditingController(),
      coords: null,
    ));
  }

  @override
  void dispose() {
    _loadIdController.dispose();
    _companyController.dispose();
    _pickupDateController.dispose();
    _rateController.dispose();
    _notesController.dispose();
    // Dispose all location controllers
    for (var location in _pickupLocations) {
      location.controller.dispose();
    }
    for (var location in _deliveryLocations) {
      location.controller.dispose();
    }
    super.dispose();
  }

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
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(_pickedImageFile!, fit: BoxFit.contain),
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
        _pickupDateController.text =
        '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (Navigator.canPop(context)) Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _isPickingImage = true);

    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 90,
      );
      if (!mounted) return;
      setState(() {
        if (picked != null) _pickedImageFile = File(picked.path);
        _isPickingImage = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPickingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not pick image: $e'), backgroundColor: Colors.red),
      );
    }
  }

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
              leading: Icon(Icons.camera_alt_rounded, color: AppColors.primaryColor),
              title: const Text('Take a Photo'),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: AppColors.primaryColor),
              title: const Text('Choose from Gallery'),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _addPickupLocation() {
    setState(() {
      _pickupLocations.add(LocationData(
        controller: TextEditingController(),
        coords: null,
      ));
    });
  }

  void _addDeliveryLocation() {
    setState(() {
      _deliveryLocations.add(LocationData(
        controller: TextEditingController(),
        coords: null,
      ));
    });
  }

  void _removePickupLocation(int index) {
    if (_pickupLocations.length <= 1) return;
    setState(() {
      _pickupLocations[index].controller.dispose();
      _pickupLocations.removeAt(index);
    });
  }

  void _removeDeliveryLocation(int index) {
    if (_deliveryLocations.length <= 1) return;
    setState(() {
      _deliveryLocations[index].controller.dispose();
      _deliveryLocations.removeAt(index);
    });
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    // Check if all locations have coordinates
    for (var location in _pickupLocations) {
      if (location.coords == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select all pickup locations from suggestions or map'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    for (var location in _deliveryLocations) {
      if (location.coords == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select all delivery locations from suggestions or map'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final rate = num.tryParse(_rateController.text.trim());
    if (rate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid rate'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedPickupDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select pickup date'), backgroundColor: Colors.red),
      );
      return;
    }

    final pickupDateIso = DateTime.utc(
      _selectedPickupDate!.year,
      _selectedPickupDate!.month,
      _selectedPickupDate!.day,
    ).toIso8601String();

    // Get all pickup coordinates and addresses
    final pickupCoords = _pickupLocations.map((loc) => loc.coords!).toList();
    final pickupAddresses = _pickupLocations.map((loc) => loc.controller.text).toList();

    // Get all delivery coordinates and addresses
    final deliveryCoords = _deliveryLocations.map((loc) => loc.coords!).toList();
    final deliveryAddresses = _deliveryLocations.map((loc) => loc.controller.text).toList();

    context.read<AddLoadCubit>().createManualLoad(
      loadId: _loadIdController.text,
      companyName: _companyController.text,
      pickupCoordinates: pickupCoords,
      deliveryCoordinates: deliveryCoords,
      pickupAddresses: pickupAddresses,
      deliveryAddresses: deliveryAddresses,
      pickupDateIso: pickupDateIso,
      rate: rate,
      bolImageFile: _pickedImageFile,
      notes: _notesController.text,
    );
  }

  void _onScanBOL() {
    Navigator.pushNamed(context, AppRoutes.camScan);
  }

  Widget _buildLabel(String text, {bool required = true}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B7280),
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
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFB0B7C3)),
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
          ),
          if (trailing != null) ...[
            const Spacer(),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _buildFieldGroup({required String label, required Widget field, bool required = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          _buildLabel(label, required: required),
          const SizedBox(height: 6),
        ],
        field,
      ],
    );
  }

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

  Widget _buildLocationField({
    required LocationData locationData,
    required String label,
    required IconData icon,
    required String mapTitle,
    required int index,
    required bool canRemove,
    required VoidCallback onRemove,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LocationCoordinateField(
            controller: locationData.controller,
            label: label,
            hint: 'Type address or tap pin for map',
            icon: icon,
            mapTitle: mapTitle,
            initialCoordinates: locationData.coords,
            onCoordinatesChanged: (coords) {
              setState(() {
                locationData.coords = coords;
              });
            },
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
                  icon: const Icon(Icons.add_location_alt, color: AppColors.primaryColor, size: 24),
                  tooltip: 'Add Pickup Location',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addDeliveryLocation,
                  icon: const Icon(Icons.add_location, color: AppColors.primaryColor, size: 24),
                  tooltip: 'Add Delivery Location',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Pickup Locations
          ...List.generate(_pickupLocations.length, (index) {
            final isLast = index == _pickupLocations.length - 1;
            final canRemove = _pickupLocations.length > 1;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationField(
                  locationData: _pickupLocations[index],
                  label: 'PICKUP LOCATION ${_pickupLocations.length > 1 ? index + 1 : ''}'.trim(),
                  icon: Icons.location_on_outlined,
                  mapTitle: 'Pick Pickup Location ${_pickupLocations.length > 1 ? index + 1 : ''}'.trim(),
                  index: index,
                  canRemove: canRemove,
                  onRemove: () => _removePickupLocation(index),
                ),
                if (!isLast) const SizedBox(height: 14),
              ],
            );
          }),
          if (_deliveryLocations.isNotEmpty) const SizedBox(height: 14),
          // Delivery Locations
          ...List.generate(_deliveryLocations.length, (index) {
            final isLast = index == _deliveryLocations.length - 1;
            final canRemove = _deliveryLocations.length > 1;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationField(
                  locationData: _deliveryLocations[index],
                  label: 'DELIVERY LOCATION ${_deliveryLocations.length > 1 ? index + 1 : ''}'.trim(),
                  icon: Icons.flag_outlined,
                  mapTitle: 'Pick Delivery Location ${_deliveryLocations.length > 1 ? index + 1 : ''}'.trim(),
                  index: index,
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
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Rate is required';
                if (num.tryParse(v.trim()) == null) return 'Enter a valid number';
                return null;
              },
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E3A5F),
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFB0B7C3)),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 4, top: 12, bottom: 12),
                  child: Icon(Icons.attach_money, color: AppColors.primaryColor, size: 20),
                ),
                filled: true,
                fillColor: AppColors.textFieldWhiteColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildDocumentSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(icon: Icons.file_copy_outlined, title: 'Document(BOL)'),
          if (_isPickingImage)
            const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ))
          else if (_pickedImageFile != null)
            GestureDetector(
              onTap: _viewFullImage,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.file(_pickedImageFile!, width: double.infinity, height: 200, fit: BoxFit.cover),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: _showSourceSheet,
                            child: const Text('Change', style: TextStyle(color: Colors.white)),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _pickedImageFile = null),
                            child: const Text('Remove', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            GestureDetector(
              onTap: _showSourceSheet,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDDE1E9)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 26, color: AppColors.primaryColor),
                    const SizedBox(height: 10),
                    const Text(
                      'Upload BOL',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F)),
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddLoadCubit, AddLoadState>(
      listener: (context, state) {
        if (state is AddLoadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );

          Navigator.pushReplacementNamed(
            context,
            AppRoutes.loadDetails,
            arguments: LoadDetailsArgs(
              load: state.data,
              refreshHomeOnPop: true,
            ),
          );
        } else if (state is AddLoadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AddLoadLoading;
        final loadingMsg = state is AddLoadLoading ? state.progressMessage : null;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundColor,
            surfaceTintColor: AppColors.backgroundColor,
            centerTitle: true,
            elevation: 0,
            title: Text(
              'Add Load',
              style: AppTextStyle.SFProDisplay_Regular.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E3A5F),
              ),
            ),
            leading: InkWell(
              onTap: isLoading ? null : () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset('assets/icons/back_button_with_circle.svg'),
              ),
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '* Required fields',
                            style: AppTextStyle.SFProDisplay_Regular.copyWith(fontSize: 12),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
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
                              CustomElevatedButton(
                                onPressed: isLoading ? null : _onSave,
                                buttonText: isLoading
                                    ? (loadingMsg ?? 'Saving...')
                                    : 'Save Load & Continue',
                                backgroundColor: const Color(0xFF1E3A5F),
                                foregroundColor: Colors.white,
                                height: 56,
                                isFullWidth: true,
                                hasShadow: false,
                                borderRadius: BorderRadius.circular(30),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              const SizedBox(height: 12),
                              CustomElevatedButton(
                                onPressed: isLoading ? null : _onScanBOL,
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
                    ],
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.25),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppColors.primaryColor),
                          if (loadingMsg != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              loadingMsg,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
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

// Helper class to manage location data
class LocationData {
  final TextEditingController controller;
  List<double>? coords;

  LocationData({
    required this.controller,
    this.coords,
  });
}