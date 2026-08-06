import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tag/core/constants/app_routes.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/utils/app_url.dart';
import 'package:tag/feature/bill_of_loading/model/add_load_data.dart';
import 'package:tag/feature/load/view/expense/controller/add_load_expense_cubit.dart';
import 'package:tag/feature/load/view/expense/model/load_expense_data.dart';
import 'package:tag/feature/map/map_screen.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../shared/components/Custom_Elevated_Button.dart';
import '../../../shared/widget/bottom_nav.dart';
import '../../../shared/widget/immersive_safe_area.dart';
import '../cubit/pod_upload_cubit.dart';
import '../cubit/load_details_cubit.dart';
import 'bol_screen.dart';

class LoadDetailsArgs {
  final AddLoadData? load;
  final bool refreshHomeOnPop;

  const LoadDetailsArgs({
    this.load,
    this.refreshHomeOnPop = false,
  });
}

class LoadDetailsScreen extends StatefulWidget {
  final AddLoadData? load;

  /// When true (new load create → details), popping back silently refreshes
  /// Home load/report data (skips profile avatar/name).
  final bool refreshHomeOnPop;

  const LoadDetailsScreen({
    super.key,
    this.load,
    this.refreshHomeOnPop = false,
  });

  @override
  State<LoadDetailsScreen> createState() => _LoadDetailsScreenState();
}

class _LoadDetailsScreenState extends State<LoadDetailsScreen> {
  bool _bolUploaded = false;
  bool _podUploaded = false;
  bool _isUploadingPod = false;
  File? _bolImage;
  File? _podImage;
  String? _bolImageUrl;
  String? _podImageUrl;
  final ImagePicker _picker = ImagePicker();
  late final AddLoadExpenseCubit _expenseCubit;
  late final PODCubit _podCubit;
  late final LoadDetailsCubit _loadDetailsCubit;
  List<LoadExpenseData> _expenses = [];
  double _expenseTotal = 0;

  AddLoadData? get _load => widget.load;

  @override
  void initState() {
    super.initState();
    _expenseCubit = AddLoadExpenseCubit();
    _podCubit = PODCubit();
    _loadDetailsCubit = LoadDetailsCubit();

    // Check if BOL image exists from load data
    if (_load?.bolImage != null && _load!.bolImage!.isNotEmpty) {
      _bolImageUrl = _load!.bolImage;
      if (_bolImageUrl!.startsWith('http')) {
        _bolImageUrl = _bolImageUrl;
      } else {
        _bolImageUrl = '${AppUrl.imageBaseUrl}/$_bolImageUrl';
      }
      _bolUploaded = true;
    }

    // Check if POD images exist from load data
    _updatePodImageFromLoad();

    _fetchExpenses();
  }

  void _updatePodImageFromLoad() {
    final loadData = _getCurrentLoadData();
    if (loadData.podImages != null && loadData.podImages!.isNotEmpty) {
      final podImage = loadData.podImages!.first;
      if (podImage.isNotEmpty) {
        _podImageUrl = podImage.startsWith('http')
            ? podImage
            : '${AppUrl.imageBaseUrl}/$podImage';
        _podUploaded = true;
      }
    }
  }

  @override
  void dispose() {
    _expenseCubit.close();
    _podCubit.close();
    _loadDetailsCubit.close();
    super.dispose();
  }

  void _popDetails() {
    Navigator.pop(context);
  }

  Future<void> _fetchExpenses() async {
    final mongoId = _load?.id?.trim() ?? '';
    if (mongoId.isEmpty) return;
    await _expenseCubit.fetchExpenses(mongoId);
  }

  // Helper to get the current load data
  AddLoadData _getCurrentLoadData() {
    final state = _loadDetailsCubit.state;
    if (state is LoadDetailsSuccess) {
      return state.loadData;
    }
    return widget.load!;
  }

  String get _expenseText => '\$${_expenseTotal.toStringAsFixed(2)}';

  String get _loadIdText {
    final load = _getCurrentLoadData();
    final id = load.loadId;
    if (id != null && id.isNotEmpty) return '#$id';
    return '#—';
  }

  String get _statusText {
    final load = _getCurrentLoadData();
    return (load.status ?? 'pending').toUpperCase();
  }

  String get _dateText {
    final load = _getCurrentLoadData();
    final raw = load.pickupDate;
    if (raw == null || raw.isEmpty) return '—';
    try {
      return DateFormat('MMM d, yyyy').format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw;
    }
  }

  String get _incomeText {
    final load = _getCurrentLoadData();
    final rate = load.rate;
    if (rate == null) return '\$0.00';
    return '\$${rate.toStringAsFixed(2)}';
  }

  String get _companyName {
    final load = _getCurrentLoadData();
    final name = load.companyName;
    if (name != null && name.isNotEmpty) return name;
    return '—';
  }

  // Get pickup addresses (multiple)
  List<String> get _pickupAddresses {
    final load = _getCurrentLoadData();
    if (load.pickupAddresses != null && load.pickupAddresses!.isNotEmpty) {
      return load.pickupAddresses!;
    }
    final single = load.pickupAddress;
    if (single != null && single.isNotEmpty) {
      return [single];
    }
    final coords = load.pickupCoordinates;
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
    final load = _getCurrentLoadData();
    if (load.deliveryAddresses != null && load.deliveryAddresses!.isNotEmpty) {
      return load.deliveryAddresses!;
    }
    final single = load.deliveryAddress;
    if (single != null && single.isNotEmpty) {
      return [single];
    }
    final coords = load.deliveryCoordinates;
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
    final load = _getCurrentLoadData();
    final coords = load.pickupCoordinates;
    if (coords == null) return const [];
    return coords.where((c) => c.length >= 2).toList();
  }

  // Get delivery coordinates (for map)
  List<List<double>> get _allDeliveryCoords {
    final load = _getCurrentLoadData();
    final coords = load.deliveryCoordinates;
    if (coords == null) return const [];
    return coords.where((c) => c.length >= 2).toList();
  }

  String? get _notes {
    final load = _getCurrentLoadData();
    final n = load.notes;
    if (n == null || n.trim().isEmpty) return null;
    return n.trim();
  }

  String? get _bolImageUrlDisplay {
    final load = _getCurrentLoadData();
    final path = load.bolImage;
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '${AppUrl.imageBaseUrl}/$path';
  }

  Color get _statusColor {
    final load = _getCurrentLoadData();
    switch ((load.status ?? '').toLowerCase()) {
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
    final load = _getCurrentLoadData();
    switch ((load.status ?? '').toLowerCase()) {
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

  Widget _buildCopyableAddress(
      String address, {
        VoidCallback? onTap,
      }) {
    return Tooltip(
      message: onTap != null
          ? 'Tap to view on map • Long press to copy'
          : 'Long press to copy',
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () => _copyLocationAddress(address),
        behavior: HitTestBehavior.opaque,
        child: Text(
          address,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1E293B),
            height: 1.4,
            decoration: onTap != null ? TextDecoration.underline : null,
            decorationColor: const Color(0xFF94A3B8),
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

  /// Open map preview focused on one pickup or delivery point
  Future<void> _openSingleLocationMap({
    required bool isPickup,
    required int index,
    required String address,
  }) async {
    final coordsList = isPickup ? _allPickupCoords : _allDeliveryCoords;
    if (index < 0 ||
        index >= coordsList.length ||
        coordsList[index].length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location coordinates not available')),
      );
      return;
    }

    final coords = coordsList[index];
    final label = address.trim().isNotEmpty
        ? address.trim()
        : (isPickup ? 'Pickup' : 'Delivery');

    await MapScreen.openViewRoute(
      context,
      title: isPickup ? 'Pickup Location' : 'Delivery Location',
      pickupCoordinatesList: isPickup ? [coords] : const [],
      deliveryCoordinatesList: isPickup ? const [] : [coords],
      pickupLabels: isPickup ? [label] : const [],
      deliveryLabels: isPickup ? const [] : [label],
    );
  }

  // ==================== NAVIGATION METHODS ====================

  /// Navigate to POD Screen with BOL image data
  Future<void> _navigateToPOD() async {
    _showImageSourceDialogForPOD();
  }

  /// Navigate to BOL Screen for signature
  Future<void> _navigateToBOL() async {
    // Check if we have an image to sign
    if (_bolImage == null && _bolImageUrl == null && _bolImageUrlDisplay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No BOL image available to sign'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await Navigator.pushNamed(
      context,
      AppRoutes.billOfLoad,
      arguments: BOLScreenArgs(
        imagePath: _bolImage?.path,
        imageUrl: _bolImageUrl ?? _bolImageUrlDisplay,
        loadId: _getCurrentLoadData().loadId,
        imageFile: _bolImage,
        onSignatureComplete: (signedPath) {
          if (signedPath != null) {
            setState(() {
              _bolImage = File(signedPath);
              _bolUploaded = true;
            });
          }
        },
      ),
    );

    // Handle direct result if signature is returned
    if (result != null && result is String) {
      setState(() {
        _bolImage = File(result);
        _bolUploaded = true;
      });
    }
  }

  // ==================== POD IMAGE PICKING & UPLOAD ====================

  Future<void> _showImageSourceDialogForPOD() async {
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
                        _pickPODImage(ImageSource.camera);
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
                        _pickPODImage(ImageSource.gallery);
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

  Future<void> _pickPODImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final load = _getCurrentLoadData();
        final loadId = load.id?.trim() ?? '';
        if (loadId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Load ID is missing'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Show loading overlay on POD card only
        setState(() {
          _isUploadingPod = true;
          _podImage = File(pickedFile.path);
        });

        // Upload the POD image using cubit
        await _podCubit.uploadPOD(
          loadId: loadId,
          imageFile: File(pickedFile.path),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingPod = false;
          _podImage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ==================== BOL IMAGE PICKING ====================

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

        // Navigate to BOL for signing
        if (mounted) {
          _navigateToBOL();
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

  // ==================== VIEW FULL IMAGE ====================

  void _viewFullImage({
    required File? localFile,
    required String? networkUrl,
    required String title,
  }) {
    if (localFile == null && (networkUrl == null || networkUrl.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No $title available'),
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

  // ==================== SHIMMER FOR IMAGE LOADING ====================

  Widget _buildImageShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 180,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            size: 48,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  // ==================== BUILD METHOD ====================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && widget.refreshHomeOnPop) {
          BottomNavState.instance?.refreshHomeSilently();
        }
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _expenseCubit),
          BlocProvider.value(value: _podCubit),
          BlocProvider.value(value: _loadDetailsCubit),
        ],
        child: BlocListener<PODCubit, PODState>(
          listener: (context, state) {
            if (state is PODUploadSuccess) {
              // Reset upload state
              setState(() {
                _isUploadingPod = false;
                _podImage = null;
              });

              // Refresh load details using cubit (silent refresh)
              final load = _getCurrentLoadData();
              final loadId = load.id?.trim() ?? '';
              if (loadId.isNotEmpty) {
                _loadDetailsCubit.refreshLoadDetails(loadId);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('POD uploaded successfully!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            } else if (state is PODFailure) {
              setState(() {
                _isUploadingPod = false;
                _podImage = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.errorMessage}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          child: BlocListener<LoadDetailsCubit, LoadDetailsState>(
            listener: (context, state) {
              if (state is LoadDetailsSuccess) {
                // Update POD image from refreshed data
                setState(() {
                  _updatePodImageFromLoad();
                });
              }
            },
            child: BlocListener<AddLoadExpenseCubit, AddLoadExpenseState>(
              listener: (context, state) {
                if (state is LoadExpenseListSuccess) {
                  setState(() {
                    _expenses = state.expenses;
                    _expenseTotal = state.totalAmount;
                  });
                } else if (state is LoadExpenseListFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: MediaQuery(
                data: withImmersiveSafePadding(context),
                child: Scaffold(
                  backgroundColor: AppColors.backgroundColor,
                  appBar: _buildAppBar(),
                  body: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxW = constraints.maxWidth.isFinite
                          ? constraints.maxWidth
                          : MediaQuery.sizeOf(context).width;
                      final maxH = constraints.maxHeight.isFinite
                          ? constraints.maxHeight
                          : MediaQuery.sizeOf(context).height;

                      final horizontalPad = (maxW * 0.042).clamp(14.0, 20.0);
                      final verticalPad = (maxH * 0.015).clamp(10.0, 14.0);
                      final sectionGap = (maxH * 0.015).clamp(10.0, 14.0);
                      final smallGap = (maxH * 0.01).clamp(6.0, 8.0);
                      final preActionsGap = (maxH * 0.07).clamp(48.0, 60.0);
                      final bottomSpacer = (maxH * 0.12).clamp(80.0, 100.0);
                      final outlinedBtnH = (maxH * 0.055).clamp(40.0, 44.0);
                      final primaryBtnH = (maxH * 0.06).clamp(44.0, 48.0);

                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPad,
                          vertical: verticalPad,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!_bolUploaded)
                              _buildWarningCard(
                                label: 'BOL: Missing',
                                subtitle: 'Bill of Lading required',
                                buttonLabel: 'Upload BOL',
                                onUpload: _showImageSourceDialogForBOL,
                                isLoading: false,
                              ),
                            if (!_bolUploaded) SizedBox(height: smallGap),
                            if (!_podUploaded)
                              _buildWarningCard(
                                label: 'POD: Missing',
                                subtitle: 'Proof of Delivery required',
                                buttonLabel: 'Upload POD',
                                onUpload: _showImageSourceDialogForPOD,
                                isLoading: _isUploadingPod,
                              ),
                            if (!_podUploaded) SizedBox(height: sectionGap),
                            _buildLoadIdCard(),
                            SizedBox(height: sectionGap),
                            _buildIncomeExpenseRow(),
                            if (_expenses.isNotEmpty) ...[
                              SizedBox(height: sectionGap),
                              _buildExpensesSection(),
                            ],
                            SizedBox(height: sectionGap),
                            _buildRouteCard(),
                            SizedBox(height: sectionGap),
                            _buildMapPreview(),
                            SizedBox(height: sectionGap),
                            _buildCarrierCard(),
                            if (_notes != null) ...[
                              SizedBox(height: sectionGap),
                              _buildNotesCard(),
                            ],
                            SizedBox(height: sectionGap),
                            _buildBolScanCard(),
                            SizedBox(height: sectionGap),
                            _buildPodCard(),
                            SizedBox(height: preActionsGap),
                            CustomElevatedButton(
                              onPressed: () async {
                                final load = _getCurrentLoadData();
                                final mongoId = load.id?.trim() ?? '';
                                final displayId = load.loadId?.trim() ?? '';
                                if (mongoId.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Load ID is missing'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                await Navigator.pushNamed(
                                  context,
                                  AppRoutes.addExpense,
                                  arguments: ExpenseScreenArgs(
                                    loadMongoId: mongoId,
                                    displayLoadId: displayId.isNotEmpty
                                        ? displayId
                                        : mongoId,
                                    totalExpenses: _expenseTotal,
                                  ),
                                );

                                if (mounted) {
                                  await _fetchExpenses();
                                }
                              },
                              buttonText: 'Add Expense',
                              isOutlined: true,
                              borderSide: const BorderSide(),
                              backgroundColor: AppColors.whiteColor,
                              foregroundColor: AppColors.primaryColor,
                              height: outlinedBtnH,
                              borderRadius: BorderRadius.circular(30),
                              isFullWidth: true,
                              hasShadow: false,
                              icon: const Icon(Icons.add_circle_outline, size: 20),
                              gap: 8,
                            ),
                            SizedBox(height: smallGap),
                            // ✅ Button stays completely unchanged during upload
                            CustomElevatedButton(
                              onPressed: (){
                                Navigator.pushNamed(context, AppRoutes.billOfLoad);
                              },
                              buttonText: 'Upload POD/Signed BOL',
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: AppColors.whiteColor,
                              height: primaryBtnH,
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
                            SizedBox(height: bottomSpacer),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
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
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _popDetails,
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/back_button_with_circle.svg',
              ),
            ),
          ),
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

  Widget _buildWarningCard({
    required String label,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback? onUpload,
    required bool isLoading,
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
            icon: isLoading
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryColor,
              ),
            )
                : SvgPicture.asset('assets/icons/upload.svg'),
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
              if (_getCurrentLoadData().companyName != null) ...[
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
                Text(
                  _expenseText,
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
      ],
    );
  }

  Widget _buildExpensesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 16, color: AppColors.primaryColor),
              const SizedBox(width: 6),
              Text(
                'Expenses',
                style: AppTextStyle.SFProDisplay_Regular.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_expenses.length} item${_expenses.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(_expenses.length, (index) {
            final expense = _expenses[index];
            final isLast = index == _expenses.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
              child: _buildExpenseCard(expense),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(LoadExpenseData expense) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.local_gas_station_outlined,
              color: AppColors.primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.typeLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  expense.formattedDate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                if (expense.notes != null &&
                    expense.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    expense.notes!.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            expense.formattedAmount,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

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
                                    _buildCopyableAddress(
                                      pickupAddresses[index],
                                      onTap: () => _openSingleLocationMap(
                                        isPickup: true,
                                        index: index,
                                        address: pickupAddresses[index],
                                      ),
                                    ),
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
                                      onTap: () => _openSingleLocationMap(
                                        isPickup: false,
                                        index: index,
                                        address: deliveryAddresses[index],
                                      ),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final mapH = (constraints.maxWidth * 0.45).clamp(140.0, 200.0);

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
                        height: mapH,
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
      },
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

  Widget _buildBolScanCard() {
    final hasImage = _bolImage != null || _bolImageUrl != null || _bolImageUrlDisplay != null;
    final displayImage = _bolImage;

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
                if (hasImage)
                  TextButton(
                    onPressed: () => _viewFullImage(
                      localFile: displayImage,
                      networkUrl: _bolImageUrl ?? _bolImageUrlDisplay,
                      title: 'BOL',
                    ),
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
              onTap: hasImage ? () => _viewFullImage(
                localFile: displayImage,
                networkUrl: _bolImageUrl ?? _bolImageUrlDisplay,
                title: 'BOL',
              ) : null,
              child: displayImage != null
                  ? Image.file(
                displayImage,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              )
                  : (_bolImageUrlDisplay != null
                  ? Image.network(
                _bolImageUrlDisplay!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) {
                    return child;
                  }
                  return _buildImageShimmerPlaceholder();
                },
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
          if (!hasImage)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      'No BOL image available',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _showImageSourceDialogForBOL,
                      icon: const Icon(Icons.upload_file, size: 16),
                      label: const Text('Upload BOL'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
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

  // ==================== POD CARD ====================

  Widget _buildPodCard() {
    final hasImage = _podImage != null || _podImageUrl != null;
    final displayImage = _podImage;

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
                      Icons.verified_outlined,
                      size: 18,
                      color: Color(0xFF1A3C6E),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'POD Image',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
                if (hasImage && !_isUploadingPod)
                  TextButton(
                    onPressed: () => _viewFullImage(
                      localFile: displayImage,
                      networkUrl: _podImageUrl,
                      title: 'POD',
                    ),
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
          Stack(
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: GestureDetector(
                  onTap: hasImage && !_isUploadingPod
                      ? () => _viewFullImage(
                    localFile: displayImage,
                    networkUrl: _podImageUrl,
                    title: 'POD',
                  )
                      : null,
                  child: displayImage != null
                      ? Image.file(
                    displayImage,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  )
                      : (_podImageUrl != null
                      ? Image.network(
                    _podImageUrl!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) {
                        return child;
                      }
                      return _buildImageShimmerPlaceholder();
                    },
                    errorBuilder: (_, __, ___) => Container(
                      width: double.infinity,
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Failed to load image',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                      : Container(
                    width: double.infinity,
                    height: 180,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.upload_file,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No POD image available',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                ),
              ),
              // Loading Overlay - Only during upload
              if (_isUploadingPod)
                Container(
                  width: double.infinity,
                  height: 180,
                  color: Colors.black.withOpacity(0.6),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Uploading POD...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (!hasImage && !_isUploadingPod)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: TextButton.icon(
                  onPressed: _showImageSourceDialogForPOD,
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: const Text('Upload POD'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                  ),
                ),
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