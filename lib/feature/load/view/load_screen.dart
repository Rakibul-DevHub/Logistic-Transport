import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Data Model for Load
class LoadModel {
  final String id;
  final String companyName;
  final LoadStatus status;
  final String pickupLocation;
  final DateTime pickupDateTime;
  final String deliveryLocation;
  final DateTime deliveryDateTime;
  final double rate;

  LoadModel({
    required this.id,
    required this.companyName,
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
        companyName: 'Swift Logistical Corp',
        status: LoadStatus.inProgress,
        pickupLocation: 'Chicago, IL',
        pickupDateTime: DateTime(2024, 10, 24, 8, 0),
        deliveryLocation: 'Dallas, TX',
        deliveryDateTime: DateTime(2024, 10, 26, 14, 30),
        rate: 1250.00,
      ),
      LoadModel(
        id: '#LD-8822',
        companyName: 'Swift Logistical Corp',
        status: LoadStatus.inProgress,
        pickupLocation: 'Chicago, IL',
        pickupDateTime: DateTime(2024, 10, 24, 8, 0),
        deliveryLocation: 'Dallas, TX',
        deliveryDateTime: DateTime(2024, 10, 26, 14, 30),
        rate: 1250.00,
      ),
      LoadModel(
        id: '#LD-8823',
        companyName: 'Swift Logistical Corp',
        status: LoadStatus.completed,
        pickupLocation: 'Chicago, IL',
        pickupDateTime: DateTime(2024, 10, 24, 8, 0),
        deliveryLocation: 'Dallas, TX',
        deliveryDateTime: DateTime(2024, 10, 26, 14, 30),
        rate: 1250.00,
      ),
      LoadModel(
        id: '#LD-8824',
        companyName: 'Fast Freight Inc',
        status: LoadStatus.missingPOD,
        pickupLocation: 'Los Angeles, CA',
        pickupDateTime: DateTime(2024, 10, 25, 9, 0),
        deliveryLocation: 'Phoenix, AZ',
        deliveryDateTime: DateTime(2024, 10, 26, 16, 0),
        rate: 980.00,
      ),
      LoadModel(
        id: '#LD-8825',
        companyName: 'Express Transport LLC',
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
  late List<LoadModel> _allLoads;
  late List<LoadModel> _filteredLoads;

  final List<String> _filters = ['All', 'In Progress', 'Completed', 'Missing POD'];

  @override
  void initState() {
    super.initState();
    _allLoads = LoadData.getLoads();
    _filteredLoads = _allLoads;
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      switch (filter) {
        case 'In Progress':
          _filteredLoads = _allLoads
              .where((load) => load.status == LoadStatus.inProgress)
              .toList();
          break;
        case 'Completed':
          _filteredLoads = _allLoads
              .where((load) => load.status == LoadStatus.completed)
              .toList();
          break;
        case 'Missing POD':
          _filteredLoads = _allLoads
              .where((load) => load.status == LoadStatus.missingPOD)
              .toList();
          break;
        default:
          _filteredLoads = _allLoads;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Loads',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _applyFilter(filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1E3A5F)
                              : const Color(0xFFE8ECF1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Load List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredLoads.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return LoadCard(load: _filteredLoads[index]);
              },
            ),
          ),
        ],
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

  Color _getStatusColor() {
    switch (load.status) {
      case LoadStatus.inProgress:
        return const Color(0xFFE3F2FD);
      case LoadStatus.completed:
        return const Color(0xFFE8F5E9);
      case LoadStatus.missingPOD:
        return const Color(0xFFFFF3E0);
    }
  }

  Color _getStatusTextColor() {
    switch (load.status) {
      case LoadStatus.inProgress:
        return const Color(0xFF1976D2);
      case LoadStatus.completed:
        return const Color(0xFF388E3C);
      case LoadStatus.missingPOD:
        return const Color(0xFFF57C00);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, HH:mm');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Header: Load ID and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                load.id,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: _getStatusTextColor(),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Company Name
          Text(
            load.companyName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 20),

          // Pickup Location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E3A5F),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      load.pickupLocation,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(load.pickupDateTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Delivery Location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E3A5F),
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: Color(0xFF1E3A5F), width: 2),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      load.deliveryLocation,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(load.deliveryDateTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Rate and Details Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RATE',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${load.rate.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigate to details
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  children: [
                    Text(
                      'Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 18,
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
}
