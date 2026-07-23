/**
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tag/core/constants/app_routes.dart';
import 'package:tag/core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../shared/components/Custom_Elevated_Button.dart';

class LoadDetailsScreen extends StatefulWidget {
  const LoadDetailsScreen({super.key});

  @override
  State<LoadDetailsScreen> createState() => _LoadDetailsScreenState();
}

class _LoadDetailsScreenState extends State<LoadDetailsScreen> {
  bool _bolUploaded = false;
  bool _podUploaded = false;
  File? _bolImage;
  final ImagePicker _picker = ImagePicker();

  // BOL image zoom state
  double _bolScale = 1.0;
  final TransformationController _bolTransformController =
  TransformationController();

  @override
  void dispose() {
    _bolTransformController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    setState(() {
      _bolScale = (_bolScale + 0.25).clamp(1.0, 4.0);
      _bolTransformController.value = Matrix4.identity()..scale(_bolScale);
    });
  }

  void _zoomOut() {
    setState(() {
      _bolScale = (_bolScale - 0.25).clamp(1.0, 4.0);
      _bolTransformController.value = Matrix4.identity()..scale(_bolScale);
    });
  }

  Future<void> _showImageSourceDialogForBOL() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Wrap(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Select Image Source',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlueColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                      ),
                      title: const Text(
                        'Camera',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      subtitle: const Text(
                        'Take a new photo',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF888888),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _pickBOLImage(ImageSource.camera);
                      },
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlueColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                      ),
                      title: const Text(
                        'Gallery',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      subtitle: const Text(
                        'Choose from gallery',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF888888),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _pickBOLImage(ImageSource.gallery);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickBOLImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _bolImage = File(pickedFile.path);
          _bolUploaded = true;
        });

        // Navigate to BillOfLoad screen after image is picked
        if (mounted) {
          Navigator.pushNamed(context, AppRoutes.billOfLoad);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSuccessBanner(),
            const SizedBox(height: 10),
            if (!_bolUploaded)
              _buildWarningCard(
                label: 'BOL: Missing',
                subtitle: 'Bill of Lading required',
                buttonLabel: 'Upload BOL',
                onUpload: _showImageSourceDialogForBOL,
              ),
            if (!_bolUploaded) const SizedBox(height: 8),
            if (!_podUploaded)
              _buildWarningCard(
                label: 'POD: Missing',
                subtitle: 'Proof of Delivery required',
                buttonLabel: 'Upload POD',
                onUpload: () => setState(() => _podUploaded = true),
              ),
            if (!_podUploaded) const SizedBox(height: 12),
            _buildLoadIdCard(),
            const SizedBox(height: 12),
            _buildIncomeExpenseRow(),
            const SizedBox(height: 12),
            _buildRouteCard(),
            const SizedBox(height: 12),
            _buildMapPreview(),
            const SizedBox(height: 12),
            _buildCarrierCard(),
            const SizedBox(height: 12),
            _buildEquipmentCard(),
            const SizedBox(height: 12),
            _buildBolScanCard(),
            const SizedBox(height: 60),
            CustomElevatedButton(
              onPressed: () {},
              buttonText: 'Add Expense',
              isOutlined: true,
              borderSide: BorderSide(),
              backgroundColor: AppColors.whiteColor,
              foregroundColor: AppColors.primaryColor,
              height: 44,
              borderRadius: BorderRadius.circular(30),
              isFullWidth: true,
              hasShadow: false,
              icon: const Icon(Icons.add_circle_outline, size: 20),
              gap: 8,
            ),
            const SizedBox(height: 8),
            CustomElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.proofOfDelivery);
              },
              buttonText: 'Upload POD/Signed BOL',
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.whiteColor,
              height: 48,
              borderRadius: BorderRadius.circular(30),
              isFullWidth: true,
              hasShadow: false,
              icon: SvgPicture.asset(
                'assets/icons/upload.svg',
                colorFilter: const ColorFilter.mode(
                  AppColors.whiteColor,
                  BlendMode.srcIn,
                ),
              ),
              gap: 8,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      surfaceTintColor: AppColors.backgroundColor,
      leading: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: InkWell(
          onTap:()=> Navigator.pop(context),
          child: SvgPicture.asset('assets/icons/back_button_with_circle.svg'),
        ),
      ),
      title: const Text(
        'Load details',
        style: TextStyle(
          color: Color(0xFF1A1A2E),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.lightBlueColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightBlueColor),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.primaryColor, size: 18),
          SizedBox(width: 8),
          Text(
            'Load created successfully',
            style: AppTextStyle.SFProDisplay_Regular,
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard({
    required String label,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onUpload,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderTwo),
      ),
      child: Row(
        children: [
          SvgPicture.asset('assets/icons/warning.svg'),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: onUpload,
            icon: SvgPicture.asset('assets/icons/upload.svg'),
            label: Text(buttonLabel, style: AppTextStyle.SFProDisplay_Regular),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.lightBlueColor,
              foregroundColor: AppColors.lightBlueColor,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadIdCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LOAD ID',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF888888),
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF27AE60),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '#LD-984210',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Color(0xFF888888),
              ),
              const SizedBox(width: 5),
              const Text(
                'Oct 24, 2023',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF555555)),
              ),
              const SizedBox(width: 16),
              SvgPicture.asset('assets/icons/weight.svg', width: 15),
              const SizedBox(width: 5),
              const Text(
                '42,500 lbs',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF555555)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/money.svg'),
                    SizedBox(width: 4),
                    Text(
                      'INCOME',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF888888),
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  '\$3,450.00',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/expense.svg'),
                    SizedBox(width: 4),
                    Text(
                      'EXPENSE',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF888888),
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  '\$0.00',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteCard() {
    const double iconSize = 32.0;
    const double lineWidth = 2.0;
    const double midGap = 20.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.route_outlined,
                size: 16,
                color: AppColors.primaryColor,
              ),
              SizedBox(width: 6),
              Text(
                'Route Information',
                style: AppTextStyle.SFProDisplay_Regular.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pickup & Delivery with SVG icons
          IntrinsicHeight(
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

                // RIGHT: pickup field + delivery field
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pickup Location
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PICKUP LOCATION',
                            style: TextStyle(
                              fontSize: 11,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Chicago Logistics Center',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E3A5F),
                            ),
                          ),
                          Text(
                            '1200 Industrial Way, Chicago, IL 60601',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: midGap),

                      // Delivery Location
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DELIVERY LOCATION',
                            style: TextStyle(
                              fontSize: 11,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Dallas Distribution Hub',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E3A5F),
                            ),
                          ),
                          Text(
                            '4500 Commerce Blvd, Dallas, TX 75201',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Text(
              'Map preview',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: Stack(
              children: [
                Image.asset('assets/images/demo_map.png'),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Column(
                    children: [
                      _mapControlButton(Icons.add, () {}),
                      const SizedBox(height: 4),
                      _mapControlButton(Icons.remove, () {}),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapControlButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF555555)),
      ),
    );
  }

  Widget _buildCarrierCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CARRIER INFO',
            style: TextStyle(
              fontSize: 9.5,
              color: Color(0xFF888888),
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SvgPicture.asset('assets/icons/carrier.svg'),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Swift Transports Inc.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    '#T12345678',
                    style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EQUIPMENT',
            style: TextStyle(
              fontSize: 9.5,
              color: Color(0xFF888888),
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SvgPicture.asset('assets/icons/equipment.svg'),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "53' Reefer",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    'Temp: -10°F Continuous',
                    style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBolScanCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.description_outlined,
                      size: 18,
                      color: Color(0xFF1A3C6E),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'BOL Scan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'VIEW FULL',
                    style: AppTextStyle.SFProDisplay_Regular.copyWith(
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // if (_bolImage != null)
            // Image.file(_bolImage!)
          Image.asset('assets/images/demo_bol.jpg'),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}*/








///
///
///
/// todo:: implementing api
///
///
///




import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tag/core/constants/app_routes.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/utils/app_url.dart';
import 'package:tag/feature/bill_of_loading/model/add_load_data.dart';
import 'package:tag/feature/map/map_screen.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../shared/components/Custom_Elevated_Button.dart';

class LoadDetailsScreen extends StatefulWidget {
  final AddLoadData? load;

  const LoadDetailsScreen({super.key, this.load});

  @override
  State<LoadDetailsScreen> createState() => _LoadDetailsScreenState();
}

class _LoadDetailsScreenState extends State<LoadDetailsScreen> {
  bool _bolUploaded = false;
  bool _podUploaded = false;
  File? _bolImage;
  final ImagePicker _picker = ImagePicker();

  AddLoadData? get _load => widget.load;

  @override
  void initState() {
    super.initState();
    // If load already has a BOL image from create API
    if (_load?.bolImage != null && _load!.bolImage!.isNotEmpty) {
      _bolUploaded = true;
    }
  }

  String get _loadIdText {
    final id = _load?.loadId;
    if (id != null && id.isNotEmpty) return '#$id';
    return '#—';
  }

  String get _statusText => (_load?.status ?? 'pending').toUpperCase();

  String get _dateText {
    final raw = _load?.pickupDate;
    if (raw == null || raw.isEmpty) return '—';
    try {
      return DateFormat('MMM d, yyyy').format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw;
    }
  }

  String get _incomeText {
    final rate = _load?.rate;
    if (rate == null) return '\$0.00';
    return '\$${rate.toStringAsFixed(2)}';
  }

  String get _companyName {
    final name = _load?.companyName;
    if (name != null && name.isNotEmpty) return name;
    return '—';
  }

  String get _pickupAddress {
    final a = _load?.pickupAddress;
    if (a != null && a.isNotEmpty) return a;
    final coords = _load?.pickupCoordinates;
    if (coords != null && coords.length >= 2) {
      return '${coords[0].toStringAsFixed(6)}, ${coords[1].toStringAsFixed(6)}';
    }
    return '—';
  }

  String get _deliveryAddress {
    final a = _load?.deliveryAddress;
    if (a != null && a.isNotEmpty) return a;
    final coords = _load?.deliveryCoordinates;
    if (coords != null && coords.length >= 2) {
      return '${coords[0].toStringAsFixed(6)}, ${coords[1].toStringAsFixed(6)}';
    }
    return '—';
  }

  String? get _notes {
    final n = _load?.notes;
    if (n == null || n.trim().isEmpty) return null;
    return n.trim();
  }

  String? get _bolImageUrl {
    final path = _load?.bolImage;
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '${AppUrl.imageBaseUrl}/$path';
  }

  Color get _statusColor {
    switch ((_load?.status ?? '').toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'completed':
        return const Color(0xFF27AE60);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF27AE60);
    }
  }

  Color get _statusBg {
    switch ((_load?.status ?? '').toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFF7ED);
      case 'completed':
        return const Color(0xFFE8F5E9);
      case 'cancelled':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFE8F5E9);
    }
  }

  Future<void> _openRouteMap() async {
    final pickup = _load?.pickupCoordinates;
    final delivery = _load?.deliveryCoordinates;
    if (pickup == null ||
        delivery == null ||
        pickup.length < 2 ||
        delivery.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Route coordinates not available')),
      );
      return;
    }

    await MapScreen.openViewRoute(
      context,
      title: 'Load Route',
      pickupCoordinates: pickup,
      deliveryCoordinates: delivery,
      pickupLabel: _pickupAddress,
      deliveryLabel: _deliveryAddress,
    );
  }

  Future<void> _showImageSourceDialogForBOL() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Wrap(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Select Image Source',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlueColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                      ),
                      title: const Text(
                        'Camera',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      subtitle: const Text(
                        'Take a new photo',
                        style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _pickBOLImage(ImageSource.camera);
                      },
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlueColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                      ),
                      title: const Text(
                        'Gallery',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      subtitle: const Text(
                        'Choose from gallery',
                        style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _pickBOLImage(ImageSource.gallery);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickBOLImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _bolImage = File(pickedFile.path);
          _bolUploaded = true;
        });

        if (mounted) {
          Navigator.pushNamed(context, AppRoutes.billOfLoad);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_load != null) ...[
              _buildSuccessBanner(),
              const SizedBox(height: 10),
            ],
            if (!_bolUploaded)
              _buildWarningCard(
                label: 'BOL: Missing',
                subtitle: 'Bill of Lading required',
                buttonLabel: 'Upload BOL',
                onUpload: _showImageSourceDialogForBOL,
              ),
            if (!_bolUploaded) const SizedBox(height: 8),
            if (!_podUploaded)
              _buildWarningCard(
                label: 'POD: Missing',
                subtitle: 'Proof of Delivery required',
                buttonLabel: 'Upload POD',
                onUpload: () => setState(() => _podUploaded = true),
              ),
            if (!_podUploaded) const SizedBox(height: 12),
            _buildLoadIdCard(),
            const SizedBox(height: 12),
            _buildIncomeExpenseRow(),
            const SizedBox(height: 12),
            _buildRouteCard(),
            const SizedBox(height: 12),
            _buildMapPreview(),
            const SizedBox(height: 12),
            _buildCarrierCard(),
            if (_notes != null) ...[
              const SizedBox(height: 12),
              _buildNotesCard(),
            ],
            const SizedBox(height: 12),
            _buildBolScanCard(),
            const SizedBox(height: 60),
            CustomElevatedButton(
              onPressed: () {},
              buttonText: 'Add Expense',
              isOutlined: true,
              borderSide: const BorderSide(),
              backgroundColor: AppColors.whiteColor,
              foregroundColor: AppColors.primaryColor,
              height: 44,
              borderRadius: BorderRadius.circular(30),
              isFullWidth: true,
              hasShadow: false,
              icon: const Icon(Icons.add_circle_outline, size: 20),
              gap: 8,
            ),
            const SizedBox(height: 8),
            CustomElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.proofOfDelivery);
              },
              buttonText: 'Upload POD/Signed BOL',
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.whiteColor,
              height: 48,
              borderRadius: BorderRadius.circular(30),
              isFullWidth: true,
              hasShadow: false,
              icon: SvgPicture.asset(
                'assets/icons/upload.svg',
                colorFilter: const ColorFilter.mode(
                  AppColors.whiteColor,
                  BlendMode.srcIn,
                ),
              ),
              gap: 8,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      surfaceTintColor: AppColors.backgroundColor,
      leading: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: InkWell(
          onTap: () => Navigator.pop(context),
          child: SvgPicture.asset('assets/icons/back_button_with_circle.svg'),
        ),
      ),
      title: const Text(
        'Load details',
        style: TextStyle(
          color: Color(0xFF1A1A2E),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.lightBlueColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightBlueColor),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.primaryColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Load created successfully',
              style: AppTextStyle.SFProDisplay_Regular,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard({
    required String label,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onUpload,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderTwo),
      ),
      child: Row(
        children: [
          SvgPicture.asset('assets/icons/warning.svg'),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: onUpload,
            icon: SvgPicture.asset('assets/icons/upload.svg'),
            label: Text(buttonLabel, style: AppTextStyle.SFProDisplay_Regular),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.lightBlueColor,
              foregroundColor: AppColors.lightBlueColor,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadIdCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LOAD ID',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF888888),
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusText,
                  style: TextStyle(
                    fontSize: 10,
                    color: _statusColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _loadIdText,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Color(0xFF888888),
              ),
              const SizedBox(width: 5),
              Text(
                _dateText,
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF555555)),
              ),
              if (_load?.companyName != null) ...[
                const SizedBox(width: 16),
                const Icon(Icons.business_outlined, size: 14, color: Color(0xFF888888)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    _companyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF555555)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/money.svg'),
                    const SizedBox(width: 4),
                    const Text(
                      'INCOME',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF888888),
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _incomeText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/expense.svg'),
                    const SizedBox(width: 4),
                    const Text(
                      'EXPENSE',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF888888),
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '\$0.00',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteCard() {
    const double iconSize = 32.0;
    const double lineWidth = 2.0;
    const double midGap = 20.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route_outlined, size: 16, color: AppColors.primaryColor),
              const SizedBox(width: 6),
              Text(
                'Route Information',
                style: AppTextStyle.SFProDisplay_Regular.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PICKUP LOCATION',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            _pickupAddress,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E3A5F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: midGap),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DELIVERY LOCATION',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            _deliveryAddress,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E3A5F),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview() {
    final hasRoute = _load?.pickupCoordinates != null &&
        _load?.deliveryCoordinates != null &&
        (_load!.pickupCoordinates!.length >= 2) &&
        (_load!.deliveryCoordinates!.length >= 2);

    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Map preview',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                if (hasRoute)
                  TextButton(
                    onPressed: _openRouteMap,
                    child: Text(
                      'VIEW ROUTE',
                      style: AppTextStyle.SFProDisplay_Regular.copyWith(
                        fontSize: 11,
                        color: AppColors.primaryColor,
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
            child: GestureDetector(
              onTap: hasRoute ? _openRouteMap : null,
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/demo_map.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  if (hasRoute)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 12,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Tap to view full route',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
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

  Widget _buildCarrierCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CARRIER INFO',
            style: TextStyle(
              fontSize: 9.5,
              color: Color(0xFF888888),
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SvgPicture.asset('assets/icons/carrier.svg'),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _companyName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NOTES',
            style: TextStyle(
              fontSize: 9.5,
              color: Color(0xFF888888),
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _notes!,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1A1A2E),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }



  void _viewFullBolImage() {
    final localFile = _bolImage;
    final networkUrl = _bolImageUrl;

    if (localFile == null && (networkUrl == null || networkUrl.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No BOL image available'),
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
              child: localFile != null
                  ? Image.file(
                localFile,
                fit: BoxFit.contain,
              )
                  : Image.network(
                networkUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    'Failed to load image',
                    style: AppTextStyle.SFProDisplay_Regular.copyWith(
                      color: Colors.grey[400],
                    ),
                  ),
                ),
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

  Widget _buildBolScanCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 18,
                      color: Color(0xFF1A3C6E),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'BOL Scan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _viewFullBolImage, // ✅ VIEW FULL (not CHANGE)
                  child: Text(
                    'VIEW FULL',
                    style: AppTextStyle.SFProDisplay_Regular.copyWith(
                      fontSize: 11,
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
            child: GestureDetector(
              onTap: _viewFullBolImage, // optional: tap image also opens full view
              child: _bolImage != null
                  ? Image.file(
                _bolImage!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              )
                  : (_bolImageUrl != null
                  ? Image.network(
                _bolImageUrl!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/demo_bol.jpg',
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              )
                  : Image.asset(
                'assets/images/demo_bol.jpg',
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              )),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}