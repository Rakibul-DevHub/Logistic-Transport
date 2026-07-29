import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Get pickup addresses (multiple)
  List<String> get _pickupAddresses {
    if (_load?.pickupAddresses != null && _load!.pickupAddresses!.isNotEmpty) {
      return _load!.pickupAddresses!;
    }
    final single = _load?.pickupAddress;
    if (single != null && single.isNotEmpty) {
      return [single];
    }
    final coords = _load?.pickupCoordinates;
    if (coords != null && coords.isNotEmpty) {
      return coords.map((coord) {
        if (coord.length >= 2) {
          return '${coord[0].toStringAsFixed(6)}, ${coord[1].toStringAsFixed(6)}';
        }
        return '—';
      }).toList();
    }
    return ['—'];
  }

  // Get delivery addresses (multiple)
  List<String> get _deliveryAddresses {
    if (_load?.deliveryAddresses != null && _load!.deliveryAddresses!.isNotEmpty) {
      return _load!.deliveryAddresses!;
    }
    final single = _load?.deliveryAddress;
    if (single != null && single.isNotEmpty) {
      return [single];
    }
    final coords = _load?.deliveryCoordinates;
    if (coords != null && coords.isNotEmpty) {
      return coords.map((coord) {
        if (coord.length >= 2) {
          return '${coord[0].toStringAsFixed(6)}, ${coord[1].toStringAsFixed(6)}';
        }
        return '—';
      }).toList();
    }
    return ['—'];
  }

  // Get pickup coordinates (for map)
  List<List<double>> get _allPickupCoords {
    final coords = _load?.pickupCoordinates;
    if (coords == null) return const [];
    return coords.where((c) => c.length >= 2).toList();
  }

  // Get delivery coordinates (for map)
  List<List<double>> get _allDeliveryCoords {
    final coords = _load?.deliveryCoordinates;
    if (coords == null) return const [];
    return coords.where((c) => c.length >= 2).toList();
  }

  List<double>? get _firstPickupCoords {
    final coords = _allPickupCoords;
    return coords.isNotEmpty ? coords.first : null;
  }

  List<double>? get _firstDeliveryCoords {
    final coords = _allDeliveryCoords;
    return coords.isNotEmpty ? coords.first : null;
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

  Future<void> _copyLocationAddress(String address) async {
    final text = address.trim();
    if (text.isEmpty || text == '—') return;

    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address copied'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildCopyableAddress(String address) {
    return Tooltip(
      message: 'Long press to copy',
      child: GestureDetector(
        onLongPress: () => _copyLocationAddress(address),
        behavior: HitTestBehavior.opaque,
        child: Text(
          address,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B),
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Future<void> _openRouteMap() async {
    final pickups = _allPickupCoords;
    final deliveries = _allDeliveryCoords;
    if (pickups.isEmpty && deliveries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location coordinates not available')),
      );
      return;
    }

    await MapScreen.openViewRoute(
      context,
      title: 'Load Locations',
      pickupCoordinatesList: pickups,
      deliveryCoordinatesList: deliveries,
      pickupLabels: _pickupAddresses,
      deliveryLabels: _deliveryAddresses,
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
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.addExpense,
                  arguments: _load?.id ?? '',
                );
              },
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

  /// Route card with dashed line, pin/flag icons, and aligned dots
  /// Route card with dashed line, pin/flag icons, and aligned dots
  Widget _buildRouteCard() {
    const double iconSize = 36.0;
    final pickupAddresses = _pickupAddresses;
    final deliveryAddresses = _deliveryAddresses;

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
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT COLUMN: Timeline & Icons
                SizedBox(
                  width: iconSize,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Vertical Dashed Line
                      Positioned(
                        top: iconSize * 0.6,
                        bottom: iconSize * 0.6,
                        left: (iconSize / 2) - 1,
                        child: CustomPaint(
                          painter: DottedLinePainter(
                            color: const Color(0xFFCBD5E1),
                            dashWidth: 4,
                            dashSpace: 4,
                            isHorizontal: false,
                          ),
                          size: const Size(2, double.infinity),
                        ),
                      ),
                      // Main Icons
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Pickup Icon (Pin)
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: AppColors.primaryColor,
                              size: 24,
                            ),
                          ),
                          // Delivery Icon (Flag)
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.flag,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // RIGHT COLUMN: Addresses
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PICKUP SECTION
                      ...List.generate(pickupAddresses.length, (index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            top: index == 0 ? 6 : 0,
                            bottom: 12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Small Blue Dot
                              Padding(
                                padding: const EdgeInsets.only(top: 6, right: 12),
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (index == 0)
                                      const Text(
                                        'PICKUP LOCATION',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF6B7280),
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    const SizedBox(height: 2),
                                    _buildCopyableAddress(pickupAddresses[index]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      // DIVIDER BETWEEN PICKUP AND DELIVERY
                      if (pickupAddresses.isNotEmpty && deliveryAddresses.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Divider(
                            color: const Color(0xFFE2E8F0),
                            thickness: 1,
                            height: 1,
                          ),
                        ),

                      // DELIVERY SECTION
                      ...List.generate(deliveryAddresses.length, (index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            top: index == 0 ? 6 : 0,
                            bottom: index == deliveryAddresses.length - 1 ? 0 : 12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Small Blue Dot
                              Padding(
                                padding: const EdgeInsets.only(top: 6, right: 12),
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (index == 0)
                                      const Text(
                                        'DELIVERY LOCATION',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF6B7280),
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    const SizedBox(height: 2),
                                    _buildCopyableAddress(
                                      deliveryAddresses[index],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
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
    final hasRoute =
        _allPickupCoords.isNotEmpty || _allDeliveryCoords.isNotEmpty;

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
                      'VIEW MAP',
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
                            'Tap to view all locations',
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
                  onPressed: _viewFullBolImage,
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
              onTap: _viewFullBolImage,
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

// Custom painter for dotted line
class DottedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final bool isHorizontal;

  DottedLinePainter({
    required this.color,
    this.dashWidth = 6,
    this.dashSpace = 4,
    this.isHorizontal = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    if (isHorizontal) {
      double startX = 0;
      double endX = size.width;
      double y = size.height / 2;

      double currentX = startX;
      while (currentX < endX) {
        canvas.drawLine(
          Offset(currentX, y),
          Offset(currentX + dashWidth, y),
          paint,
        );
        currentX += dashWidth + dashSpace;
      }
    } else {
      double startY = 0;
      double endY = size.height;
      double x = size.width / 2;

      double currentY = startY;
      while (currentY < endY) {
        canvas.drawLine(
          Offset(x, currentY),
          Offset(x, currentY + dashWidth),
          paint,
        );
        currentY += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}