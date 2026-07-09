import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tag/core/theme/app_colors.dart';

// Data Model for Load
class LoadModel {
  final String id;
  final String driverName;
  final LoadStatus status;
  final String pickupLocation;
  final DateTime pickupDateTime;
  final String deliveryLocation;
  final DateTime deliveryDateTime;
  final double rate;

  LoadModel({
    required this.id,
    required this.driverName,
    required this.status,
    required this.pickupLocation,
    required this.pickupDateTime,
    required this.deliveryLocation,
    required this.deliveryDateTime,
    required this.rate,
  });
}

enum LoadStatus { inProgress, completed, missingPOD }

// Sample Data
class LoadData {
  static List<LoadModel> getLoads() {
    return [
      LoadModel(
        id: '#LD-8821',
        driverName: 'John',
        status: LoadStatus.inProgress,
        pickupLocation: 'Chicago, IL',
        pickupDateTime: DateTime(2024, 10, 24, 8, 0),
        deliveryLocation: 'Dallas, TX',
        deliveryDateTime: DateTime(2024, 10, 26, 14, 30),
        rate: 1250.00,
      ),
      LoadModel(
        id: '#LD-8822',
        driverName: 'Hanna',
        status: LoadStatus.inProgress,
        pickupLocation: 'Chicago, IL',
        pickupDateTime: DateTime(2024, 10, 24, 8, 0),
        deliveryLocation: 'Dallas, TX',
        deliveryDateTime: DateTime(2024, 10, 26, 14, 30),
        rate: 1250.00,
      ),
      LoadModel(
        id: '#LD-8823',
        driverName: 'Dhon',
        status: LoadStatus.completed,
        pickupLocation: 'Chicago, IL',
        pickupDateTime: DateTime(2024, 10, 24, 8, 0),
        deliveryLocation: 'Dallas, TX',
        deliveryDateTime: DateTime(2024, 10, 26, 14, 30),
        rate: 1250.00,
      ),
      LoadModel(
        id: '#LD-8824',
        driverName: 'John',
        status: LoadStatus.missingPOD,
        pickupLocation: 'Los Angeles, CA',
        pickupDateTime: DateTime(2024, 10, 25, 9, 0),
        deliveryLocation: 'Phoenix, AZ',
        deliveryDateTime: DateTime(2024, 10, 26, 16, 0),
        rate: 980.00,
      ),
      LoadModel(
        id: '#LD-8825',
        driverName: 'Keli',
        status: LoadStatus.completed,
        pickupLocation: 'Miami, FL',
        pickupDateTime: DateTime(2024, 10, 23, 7, 30),
        deliveryLocation: 'Atlanta, GA',
        deliveryDateTime: DateTime(2024, 10, 24, 12, 0),
        rate: 750.00,
      ),
    ];
  }
}

class LoadScreen extends StatefulWidget {
  const LoadScreen({super.key});

  @override
  State<LoadScreen> createState() => _LoadScreenState();
}

class _LoadScreenState extends State<LoadScreen> {
  String _selectedFilter = 'All';
  String _selectedDriver = 'All Drivers';
  late final List<LoadModel> _allLoads;
  late List<LoadModel> _filteredLoads;

  final List<String> _filters = [
    'All',
    'In Progress',
    'Completed',
    'Missing POD'
  ];

  // List of unique driver names
  late List<String> _driverList;

  @override
  void initState() {
    super.initState();
    _allLoads = LoadData.getLoads();
    _filteredLoads = _allLoads;

    // Extract unique driver names
    final drivers = _allLoads.map((load) => load.driverName).toSet().toList();
    drivers.sort(); // Sort alphabetically
    _driverList = ['All Drivers', ...drivers];
  }

  List<LoadModel> _filterLoads(String filter, String driver) {
    List<LoadModel> result = _allLoads;

    // Apply status filter
    switch (filter) {
      case 'In Progress':
        result = result.where((load) => load.status == LoadStatus.inProgress).toList();
        break;
      case 'Completed':
        result = result.where((load) => load.status == LoadStatus.completed).toList();
        break;
      case 'Missing POD':
        result = result.where((load) => load.status == LoadStatus.missingPOD).toList();
        break;
      default:
        break;
    }

    // Apply driver filter
    if (driver != 'All Drivers') {
      result = result.where((load) => load.driverName == driver).toList();
    }

    return result;
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _filteredLoads = _filterLoads(filter, _selectedDriver);
    });
  }

  void _applyDriverFilter(String driver) {
    setState(() {
      _selectedDriver = driver;
      _filteredLoads = _filterLoads(_selectedFilter, driver);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 60.0, bottom: 20),
        child: Column(
          children: [
            // Driver Filter Dropdown
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildDriverFilter(),
            ),

            const SizedBox(height: 16),

            // Status Filter Tabs
            RepaintBoundary(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8ECF1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _applyFilter(filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                                : null,
                          ),
                          child: Text(
                            filter,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF1E3A5F)
                                  : const Color(0xFF6B7280),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Load List
            Expanded(
              child: _filteredLoads.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No loads found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try changing your filters',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredLoads.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return RepaintBoundary(
                    child: LoadCard(load: _filteredLoads[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECF1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDriver,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280)),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E3A5F),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: _driverList.map((driver) {
            return DropdownMenuItem<String>(
              value: driver,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 18,
                      color: driver == 'All Drivers'
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 8),
                    Text(driver),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              _applyDriverFilter(value);
            }
          },
        ),
      ),
    );
  }
}

class LoadCard extends StatelessWidget {
  final LoadModel load;

  const LoadCard({super.key, required this.load});

  String _getStatusText() {
    switch (load.status) {
      case LoadStatus.inProgress:
        return 'IN PROGRESS';
      case LoadStatus.completed:
        return 'Completed';
      case LoadStatus.missingPOD:
        return 'Missing POD';
    }
  }

  Color _getStatusBgColor() {
    switch (load.status) {
      case LoadStatus.inProgress:
        return const Color(0xFFEFF6FF);
      case LoadStatus.completed:
        return const Color(0xFFF0FDF4);
      case LoadStatus.missingPOD:
        return const Color(0xFFFFF7ED);
    }
  }

  Color _getStatusTextColor() {
    switch (load.status) {
      case LoadStatus.inProgress:
        return const Color(0xFF2563EB);
      case LoadStatus.completed:
        return const Color(0xFF16A34A);
      case LoadStatus.missingPOD:
        return const Color(0xFFEA580C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, HH:mm');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                load.id,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getStatusBgColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: _getStatusTextColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.person,
                size: 20,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              Text(
                load.driverName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 40,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: CustomPaint(
                      painter: DottedLinePainter(
                        color: const Color(0xFFD1D5DB),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF3B82F6),
                        width: 2,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            load.pickupLocation,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateFormat.format(load.pickupDateTime),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            load.deliveryLocation,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateFormat.format(load.deliveryDateTime),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Container(height: 1, color: const Color(0xFFF3F4F6)),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RATE',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${load.rate.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Navigate to load details
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom painter for dotted line
class DottedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DottedLinePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const dashWidth = 3.0;
    const dashSpace = 3.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}