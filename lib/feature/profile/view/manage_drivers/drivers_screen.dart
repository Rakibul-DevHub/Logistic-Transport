/**
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/components/Custom_Elevated_Button.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  final List<Driver> _drivers = [
    Driver(
      name: 'James Chen',
      email: 'j.chen@logitrack.com',
      status: DriverStatus.assigned,
    ),
    Driver(
      name: 'James Chen',
      email: 'j.chen@logitrack.com',
      status: DriverStatus.pending,
    ),
    Driver(
      name: 'James Chen',
      email: 'j.chen@logitrack.com',
      status: DriverStatus.assigned,
    ),
  ];

  // Add Driver Form Controllers
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _driverEmailController = TextEditingController();

  @override
  void dispose() {
    _driverNameController.dispose();
    _driverEmailController.dispose();
    super.dispose();
  }

  void _showAddDriverModal() {
    // Clear controllers before showing
    _driverNameController.clear();
    _driverEmailController.clear();

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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Add Driver',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Invite a driver to manage loads',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF888888),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Form Fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Driver Name Field
                      const Text(
                        'Driver Name',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
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
                        child: TextField(
                          controller: _driverNameController,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1A2E),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'John Doe',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFB0B0B0),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Driver Email Field
                      const Text(
                        'Driver Email',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
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
                        child: TextField(
                          controller: _driverEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1A2E),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'driver@example.com',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFB0B0B0),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
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
                            const Expanded(
                              child: Text(
                                'The driver will receive an invitation to join your account.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF555555),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons in Column
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Send Invite Button (Top)
                      CustomElevatedButton(
                        onPressed: () {
                          if (_driverNameController.text.isNotEmpty &&
                              _driverEmailController.text.isNotEmpty) {
                            setState(() {
                              _drivers.add(
                                Driver(
                                  name: _driverNameController.text,
                                  email: _driverEmailController.text,
                                  status: DriverStatus.pending,
                                ),
                              );
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Driver invited successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all fields'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
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
                      // Cancel Button (Bottom)
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _drivers.length,
        itemBuilder: (context, index) {
          final driver = _drivers[index];
          return _buildDriverCard(driver);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDriverModal,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
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
      title: const Text(
        'Drivers',
        style: TextStyle(
          color: Color(0xFF1A1A2E),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildDriverCard(Driver driver) {
    return Container(
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      driver.email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF888888),
                      ),
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
                  color: driver.status == DriverStatus.assigned
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF8EE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  driver.status == DriverStatus.assigned ? 'Assigned' : 'Pending',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: driver.status == DriverStatus.assigned
                        ? const Color(0xFF27AE60)
                        : const Color(0xFFF5A623),
                  ),
                ),
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
    );
  }
}

enum DriverStatus {
  assigned,
  pending,
}

class Driver {
  final String name;
  final String email;
  final DriverStatus status;

  Driver({
    required this.name,
    required this.email,
    required this.status,
  });
}*/














import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/components/Custom_Elevated_Button.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  final List<Driver> _drivers = [
    Driver(
      name: 'James Chen',
      email: 'j.chen@logitrack.com',
      status: DriverStatus.assigned,
    ),
    Driver(
      name: 'James Chen',
      email: 'j.chen@logitrack.com',
      status: DriverStatus.pending,
    ),
    Driver(
      name: 'James Chen',
      email: 'j.chen@logitrack.com',
      status: DriverStatus.assigned,
    ),
  ];

  // Add Driver Form Controllers
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _driverEmailController = TextEditingController();

  @override
  void dispose() {
    _driverNameController.dispose();
    _driverEmailController.dispose();
    super.dispose();
  }

  void _showAddDriverModal() {
    // Clear controllers before showing
    _driverNameController.clear();
    _driverEmailController.clear();

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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Add Driver',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Invite a driver to manage loads',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF888888),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Form Fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Driver Name Field
                      const Text(
                        'Driver Name',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
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
                        child: TextField(
                          controller: _driverNameController,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1A2E),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'John Doe',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFB0B0B0),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Driver Email Field
                      const Text(
                        'Driver Email',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
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
                        child: TextField(
                          controller: _driverEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1A2E),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'driver@example.com',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFB0B0B0),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
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
                            const Expanded(
                              child: Text(
                                'The driver will receive an invitation to join your account.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF555555),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons in Column
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Send Invite Button (Top)
                      CustomElevatedButton(
                        onPressed: () {
                          if (_driverNameController.text.isNotEmpty &&
                              _driverEmailController.text.isNotEmpty) {
                            setState(() {
                              _drivers.add(
                                Driver(
                                  name: _driverNameController.text,
                                  email: _driverEmailController.text,
                                  status: DriverStatus.pending,
                                ),
                              );
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Driver invited successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all fields'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
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
                      // Cancel Button (Bottom)
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDriverMenu(BuildContext context, Driver driver, int index) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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

              // Assign Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person_add_alt_rounded,
                    color: Color(0xFF27AE60),
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Assign',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B2235),
                  ),
                ),
                subtitle: const Text(
                  'Assign this driver to a load',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF73809A),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showAssignLoadDialog(driver, index);
                },
              ),

              const Divider(height: 1, indent: 20, endIndent: 20),

              // Delete Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFE53935),
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Delete',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE53935),
                  ),
                ),
                subtitle: const Text(
                  'Remove this driver from your account',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF73809A),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(driver, index);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showAssignLoadDialog(Driver driver, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Assign Driver',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B2235),
            ),
          ),
          content: Text(
            'Assign ${driver.name} to a load?',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF73809A),
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
                  _drivers[index] = Driver(
                    name: driver.name,
                    email: driver.email,
                    status: DriverStatus.assigned,
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${driver.name} has been assigned!'),
                    backgroundColor: Colors.green,
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

  void _showDeleteConfirmation(Driver driver, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Driver',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B2235),
            ),
          ),
          content: Text(
            'Are you sure you want to remove ${driver.name} from your account?',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF73809A),
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
                  _drivers.removeAt(index);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${driver.name} has been removed'),
                    backgroundColor: Colors.red,
                  ),
                );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _drivers.length,
        itemBuilder: (context, index) {
          final driver = _drivers[index];
          return _buildDriverCard(driver, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDriverModal,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
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
      title: const Text(
        'Drivers',
        style: TextStyle(
          color: Color(0xFF1A1A2E),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildDriverCard(Driver driver, int index) {
    return Container(
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      driver.email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF888888),
                      ),
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
                  color: driver.status == DriverStatus.assigned
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF8EE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  driver.status == DriverStatus.assigned ? 'Assigned' : 'Pending',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: driver.status == DriverStatus.assigned
                        ? const Color(0xFF27AE60)
                        : const Color(0xFFF5A623),
                  ),
                ),
              ),
              // Vertical Menu Button
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: Color(0xFF888888),
                ),
                onSelected: (String value) {
                  if (value == 'assign') {
                    _showAssignLoadDialog(driver, index);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(driver, index);
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
    );
  }
}

enum DriverStatus {
  assigned,
  pending,
}

class Driver {
  final String name;
  final String email;
  final DriverStatus status;

  Driver({
    required this.name,
    required this.email,
    required this.status,
  });
}