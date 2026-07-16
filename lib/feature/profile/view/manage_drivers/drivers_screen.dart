import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tag/core/theme/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/components/Custom_Elevated_Button.dart';
import 'cubit/driver_screen_cubit.dart';
import 'model/driver_data.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  final DriverService _driverService = DriverService();

  List<Driver> _drivers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Tracks in-flight per-driver deletes so we can disable/spin just that
  // card instead of the whole screen.
  final Set<String> _deletingDriverIds = {};

  // Add Driver Form Controllers
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _driverEmailController = TextEditingController();

  // Focus nodes for better keyboard handling
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Loading state for the Add Driver submit button
  bool _isSubmittingDriver = false;

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  @override
  void dispose() {
    _driverNameController.dispose();
    _driverEmailController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────
  // API calls
  // ─────────────────────────────────────────────────────────────────────

  Future<void> _fetchDrivers({bool isRefresh = false}) async {
    if (!isRefresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final drivers = await _driverService.fetchDrivers();
      if (!mounted) return;
      setState(() {
        _drivers = drivers;
        _errorMessage = '';
      });
    } on DriverApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Future<void> _submitAddDriverForm() async {
  //   if (!(_formKey.currentState?.validate() ?? false)) return;
  //
  //   final name = _driverNameController.text.trim();
  //   final email = _driverEmailController.text.trim();
  //
  //   // Quick client-side duplicate check for snappy feedback — the backend
  //   // is still the source of truth and will reject duplicates too.
  //   final existingDriver = _drivers.any(
  //         (driver) => driver.email.toLowerCase() == email.toLowerCase(),
  //   );
  //   if (existingDriver) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Driver with this email already exists'),
  //         backgroundColor: Colors.orange,
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //     return;
  //   }
  //
  //   setState(() => _isSubmittingDriver = true);
  //
  //   try {
  //     final newDriver = await _driverService.addDriver(name: name, email: email);
  //
  //     if (!mounted) return;
  //     setState(() {
  //       _drivers.insert(0, newDriver);
  //     });
  //
  //     Navigator.pop(context); // close the modal
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Driver invited successfully!'),
  //         backgroundColor: Colors.green,
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //
  //     _driverNameController.clear();
  //     _driverEmailController.clear();
  //   } on DriverApiException catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(e.message),
  //         backgroundColor: Colors.red,
  //         duration: const Duration(seconds: 3),
  //       ),
  //     );
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Failed to add driver. Please try again.'),
  //         backgroundColor: Colors.red,
  //         duration: Duration(seconds: 3),
  //       ),
  //     );
  //   } finally {
  //     if (mounted) setState(() => _isSubmittingDriver = false);
  //   }
  // }



  // drivers_screen.dart - Update the _submitAddDriverForm method

  Future<void> _submitAddDriverForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _driverNameController.text.trim();
    final email = _driverEmailController.text.trim();

    // Quick client-side duplicate check for snappy feedback
    final existingDriver = _drivers.any(
          (driver) => driver.email.toLowerCase() == email.toLowerCase(),
    );
    if (existingDriver) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Driver with this email already exists'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => _isSubmittingDriver = true);

    try {
      final newDriver = await _driverService.addDriver(name: name, email: email);

      if (!mounted) return;
      setState(() {
        _drivers.insert(0, newDriver);
      });

      // Close the modal
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Driver invited successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      _driverNameController.clear();
      _driverEmailController.clear();
    } on DriverApiException catch (e) {
      if (!mounted) return;
      // Show the error with more visibility
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  e.message,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          elevation: 6,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Failed to add driver: ${e.toString()}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          elevation: 6,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmittingDriver = false);
    }
  }

// Update the delete method too
  Future<void> _deleteDriver(Driver driver) async {
    setState(() => _deletingDriverIds.add(driver.id));

    try {
      await _driverService.deleteDriver(driver.id);

      if (!mounted) return;
      setState(() {
        _drivers.removeWhere((d) => d.id == driver.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${driver.name} has been removed'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } on DriverApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  e.message,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          elevation: 6,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Failed to remove driver: ${e.toString()}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          elevation: 6,
        ),
      );
    } finally {
      if (mounted) setState(() => _deletingDriverIds.remove(driver.id));
    }
  }


  // Future<void> _deleteDriver(Driver driver) async {
  //   setState(() => _deletingDriverIds.add(driver.id));
  //
  //   try {
  //     await _driverService.deleteDriver(driver.id);
  //
  //     if (!mounted) return;
  //     setState(() {
  //       _drivers.removeWhere((d) => d.id == driver.id);
  //     });
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('${driver.name} has been removed'),
  //         backgroundColor: Colors.red,
  //         duration: const Duration(seconds: 2),
  //       ),
  //     );
  //   } on DriverApiException catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(e.message),
  //         backgroundColor: Colors.red,
  //         duration: const Duration(seconds: 3),
  //       ),
  //     );
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Failed to remove driver. Please try again.'),
  //         backgroundColor: Colors.red,
  //         duration: Duration(seconds: 3),
  //       ),
  //     );
  //   } finally {
  //     if (mounted) setState(() => _deletingDriverIds.remove(driver.id));
  //   }
  // }

  // ─────────────────────────────────────────────────────────────────────
  // Add Driver modal
  // ─────────────────────────────────────────────────────────────────────

  void _showAddDriverModal() {
    // Clear controllers and errors before showing
    _driverNameController.clear();
    _driverEmailController.clear();
    _formKey.currentState?.reset();

    // Dismiss keyboard if open
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Add Driver',
                        style: AppTextStyle.SFProDisplay_Black.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Invite a driver to manage loads',
                        style: AppTextStyle.SFProDisplay_Regular.copyWith(
                          fontSize: 14,
                          color: const Color(0xFF888888),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form Fields - Using ListView
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shrinkWrap: true,
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Driver Name Field
                                Text(
                                  'Driver Name',
                                  style: AppTextStyle.SFProDisplay_Black.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F7FA),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE1E8ED),
                                      width: 1,
                                    ),
                                  ),
                                  child: TextFormField(
                                    controller: _driverNameController,
                                    focusNode: _nameFocusNode,
                                    style: AppTextStyle.SFProDisplay_Black.copyWith(
                                      fontSize: 14,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'John Doe',
                                      hintStyle: AppTextStyle.SFProDisplay_Regular.copyWith(
                                        fontSize: 14,
                                        color: const Color(0xFFB0B0B0),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).requestFocus(_emailFocusNode);
                                    },
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter driver name';
                                      }
                                      if (value.trim().length < 2) {
                                        return 'Name must be at least 2 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Driver Email Field
                                Text(
                                  'Driver Email',
                                  style: AppTextStyle.SFProDisplay_Black.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F7FA),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE1E8ED),
                                      width: 1,
                                    ),
                                  ),
                                  child: TextFormField(
                                    controller: _driverEmailController,
                                    focusNode: _emailFocusNode,
                                    keyboardType: TextInputType.emailAddress,
                                    style: AppTextStyle.SFProDisplay_Black.copyWith(
                                      fontSize: 14,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'driver@example.com',
                                      hintStyle: AppTextStyle.SFProDisplay_Regular.copyWith(
                                        fontSize: 14,
                                        color: const Color(0xFFB0B0B0),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) async {
                                      setModalState(() {});
                                      await _submitAddDriverForm();
                                    },
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter driver email';
                                      }
                                      final emailRegex = RegExp(
                                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                      );
                                      if (!emailRegex.hasMatch(value.trim())) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Info Text
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightBlueColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: AppColors.primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'The driver will receive an invitation to join your account.',
                                          style: AppTextStyle.SFProDisplay_Regular.copyWith(
                                            fontSize: 12,
                                            color: const Color(0xFF555555),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Buttons
                                Column(
                                  children: [
                                    // Send Invite Button
                                    _isSubmittingDriver
                                        ? const SizedBox(
                                      height: 48,
                                      child: Center(
                                        child: SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                      ),
                                    )
                                        : CustomElevatedButton(
                                      onPressed: () async {
                                        setModalState(() {});
                                        await _submitAddDriverForm();
                                      },
                                      buttonText: 'Send Invite',
                                      backgroundColor: AppColors.primaryColor,
                                      foregroundColor: Colors.white,
                                      height: 48,
                                      borderRadius: BorderRadius.circular(30),
                                      isFullWidth: true,
                                      hasShadow: false,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    const SizedBox(height: 12),

                                    // Cancel Button
                                    Center(
                                      child: TextButton(
                                        onPressed: _isSubmittingDriver
                                            ? null
                                            : () => Navigator.pop(context),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: Text(
                                          'Cancel',
                                          style: AppTextStyle.SFProDisplay_Regular.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      // Reset focus when modal is closed
      _nameFocusNode.unfocus();
      _emailFocusNode.unfocus();
    });
  }

  void _showAssignLoadDialog(Driver driver, int index) {
    // No "assign" endpoint exists yet — this stays local-only until one is
    // added on the backend. See driver_model.dart for notes.
    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Assign Driver',
            style: AppTextStyle.SFProDisplay_Black.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B2235),
            ),
          ),
          content: Text(
            'Assign ${driver.name} to a load?',
            style: AppTextStyle.SFProDisplay_Regular.copyWith(
              fontSize: 14,
              color: const Color(0xFF73809A),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _drivers[index] = driver.copyWith(
                    assignmentStatus: DriverAssignmentStatus.assigned,
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${driver.name} has been assigned!'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF213A63),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Assign'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(Driver driver) {
    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Driver',
            style: AppTextStyle.SFProDisplay_Black.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B2235),
            ),
          ),
          content: Text(
            'Are you sure you want to remove ${driver.name} from your account?',
            style: AppTextStyle.SFProDisplay_Regular.copyWith(
              fontSize: 14,
              color: const Color(0xFF73809A),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteDriver(driver);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _showAddDriverModal,
      //   backgroundColor: AppColors.primaryColor,
      //   child: const Icon(Icons.add, color: Colors.white, size: 28),
      // ),
      // drivers_screen.dart - Update the floating action button

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to Add Driver Screen and wait for result
          final result = await Navigator.push<Driver>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddDriverScreen(),
              settings: const RouteSettings(name: 'AddDriverScreen'),
            ),
          );

          // If a driver was added, refresh the list
          if (result != null) {
            _fetchDrivers();
          }
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty && _drivers.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _fetchDrivers(isRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.grey[400], size: 48),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.SFProDisplay_Regular.copyWith(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomElevatedButton(
                        onPressed: () => _fetchDrivers(),
                        buttonText: 'Retry',
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        height: 44,
                        borderRadius: BorderRadius.circular(30),
                        hasShadow: false,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_drivers.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _fetchDrivers(isRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: _buildEmptyState(),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchDrivers(isRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _drivers.length,
        itemBuilder: (context, index) {
          final driver = _drivers[index];
          return _buildDriverCard(driver, index);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Drivers Yet',
            style: AppTextStyle.SFProDisplay_Black.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first driver',
            style: AppTextStyle.SFProDisplay_Regular.copyWith(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      surfaceTintColor: AppColors.backgroundColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: InkWell(
          onTap: () => Navigator.pop(context),
          child: SvgPicture.asset('assets/icons/back_button_with_circle.svg'),
        ),
      ),
      title: Text(
        'Drivers',
        style: AppTextStyle.SFProDisplay_Black.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildDriverCard(Driver driver, int index) {
    final bool isDeleting = _deletingDriverIds.contains(driver.id);
    final bool isAssigned = driver.assignmentStatus == DriverAssignmentStatus.assigned;

    return Opacity(
      opacity: isDeleting ? 0.5 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 28,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),

                // Name and Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: AppTextStyle.SFProDisplay_Black.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        driver.email,
                        style: AppTextStyle.SFProDisplay_Regular.copyWith(
                          fontSize: 13,
                          color: const Color(0xFF888888),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isAssigned
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF8EE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAssigned ? 'Assigned' : 'Waiting',
                    style: AppTextStyle.SFProDisplay_Regular.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isAssigned
                          ? AppColors.assigned
                          : AppColors.waiting,
                    ),
                  ),
                ),

                // Menu Button
                isDeleting
                    ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
                    : PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Color(0xFF888888),
                  ),
                  onSelected: (String value) {
                    if (value == 'assign') {
                      _showAssignLoadDialog(driver, index);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(driver);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'assign',
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_add_alt_rounded,
                            color: Color(0xFF27AE60),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text('Assign'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFE53935),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // View Load Details Button
            CustomElevatedButton(
              onPressed: () {
                // Navigate to load details
              },
              buttonText: 'View Load Details',
              isOutlined: true,
              borderSide: BorderSide(color: AppColors.borderTwo),
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryColor,
              height: 44,
              borderRadius: BorderRadius.circular(30),
              isFullWidth: true,
              hasShadow: false,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}





///todo:: add driver screen

class AddDriverScreen extends StatefulWidget {
  const AddDriverScreen({super.key});

  @override
  State<AddDriverScreen> createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends State<AddDriverScreen> {
  // Form Controllers
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _driverEmailController = TextEditingController();

  // Focus nodes for better keyboard handling
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Loading state
  bool _isLoading = false;

  final DriverService _driverService = DriverService();

  @override
  void dispose() {
    _driverNameController.dispose();
    _driverEmailController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitAddDriverForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _driverNameController.text.trim();
    final email = _driverEmailController.text.trim();

    setState(() => _isLoading = true);

    try {
      final newDriver = await _driverService.addDriver(
        name: name,
        email: email,
      );

      if (!mounted) return;

      // Return the new driver to the previous screen
      Navigator.pop(context, newDriver);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Driver invited successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } on DriverApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  e.message,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          elevation: 6,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Failed to add driver. Please try again.',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          elevation: 6,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(),
            const SizedBox(height: 32),

            // Form Section
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Driver Name Field
                  _buildDriverNameField(),
                  const SizedBox(height: 20),

                  // Driver Email Field
                  _buildDriverEmailField(),
                  const SizedBox(height: 24),

                  // Info Card
                  _buildInfoCard(),
                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      surfaceTintColor: AppColors.backgroundColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: InkWell(
          onTap: () => Navigator.pop(context),
          child: SvgPicture.asset('assets/icons/back_button_with_circle.svg'),
        ),
      ),
      title: Text(
        'Add Driver',
        style: AppTextStyle.SFProDisplay_Black.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person_add_alt_rounded,
              size: 28,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invite a Driver',
                  style: AppTextStyle.SFProDisplay_Black.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add a new driver to manage loads',
                  style: AppTextStyle.SFProDisplay_Regular.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Driver Name',
              style: AppTextStyle.SFProDisplay_Black.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: AppTextStyle.SFProDisplay_Regular.copyWith(
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE1E8ED),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _driverNameController,
            focusNode: _nameFocusNode,
            style: AppTextStyle.SFProDisplay_Black.copyWith(
              fontSize: 14,
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                size: 20,
                color: Color(0xFF888888),
              ),
              hintText: 'Enter driver\'s full name',
              hintStyle: AppTextStyle.SFProDisplay_Regular.copyWith(
                fontSize: 14,
                color: const Color(0xFFB0B0B0),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_emailFocusNode);
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter driver name';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDriverEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Driver Email',
              style: AppTextStyle.SFProDisplay_Black.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: AppTextStyle.SFProDisplay_Regular.copyWith(
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE1E8ED),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _driverEmailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            style: AppTextStyle.SFProDisplay_Black.copyWith(
              fontSize: 14,
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.email_outlined,
                size: 20,
                color: Color(0xFF888888),
              ),
              hintText: 'driver@example.com',
              hintStyle: AppTextStyle.SFProDisplay_Regular.copyWith(
                fontSize: 14,
                color: const Color(0xFFB0B0B0),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              _submitAddDriverForm();
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter driver email';
              }
              final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBlueColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'The driver will receive an invitation email to join your account. They will need to verify their email to get started.',
              style: AppTextStyle.SFProDisplay_Regular.copyWith(
                fontSize: 13,
                color: const Color(0xFF555555),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Send Invite Button
        CustomElevatedButton(
          onPressed: _isLoading ? null : _submitAddDriverForm,
          buttonText: _isLoading ? 'Sending Invite...' : 'Send Invite',
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          height: 56,
          borderRadius: BorderRadius.circular(30),
          isFullWidth: true,
          hasShadow: false,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          icon: _isLoading
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
              : const Icon(Icons.send_rounded, size: 22),
          gap: 12,
        ),
        const SizedBox(height: 16),

        // Cancel Button
        Center(
          child: TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Cancel',
              style: AppTextStyle.SFProDisplay_Regular.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _isLoading ? Colors.grey : Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }
}