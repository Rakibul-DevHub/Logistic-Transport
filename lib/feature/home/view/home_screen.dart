import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tag/core/constants/app_routes.dart';
import '../../../shared/widget/build_action_button.dart';
import '../../../shared/widget/build_load_card.dart';
import '../../../shared/widget/build_status_card.dart';
import '../../../shared/widget/subscription_modal_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _subscriptionTimer;
  bool _hasShownSubscription = false;

  /// Pre-calculate status data to avoid recreation on every build
  static final List<_StatusData> _statusData = [
    _StatusData(
      title: 'Completed',
      count: '21',
      icon: 'assets/icons/completed.svg',
      color: Color(0xFF12B76A),
    ),
    _StatusData(
      title: 'Missing POD',
      count: '03',
      icon: 'assets/icons/missing_pod.svg',
      color: Color(0xFFEAAA08),
    ),
    _StatusData(
      title: 'Expense',
      count: '12',
      icon: 'assets/icons/expense.svg',
      color: Color(0xFFD92D20),
    ),
  ];

  // Static sample data - move to BLoC/Cubit in production
  static const List<_LoadData> _assignedLoads = [
    _LoadData(
      loadNumber: '#LD-8829',
      company: 'Amazon Logistics',
      date: 'Oct 24, 2023',
      status: 'Missing POD',
      statusColor: Color(0xFFFF9800),
      amount: '+\$850',
    ),
    _LoadData(
      loadNumber: '#LD-8829',
      company: 'Amazon Logistics',
      date: 'Oct 24, 2023',
      status: 'Delivered',
      statusColor: Color(0xFF4CAF50),
      amount: '+\$850',
    ),
  ];

  static const List<_LoadData> _myLoads = [
    _LoadData(
      loadNumber: '#LD-8829',
      company: 'Amazon Logistics',
      date: 'Oct 24, 2023',
      status: 'Delivered',
      statusColor: Color(0xFF4CAF50),
      amount: '+\$850',
    ),
    _LoadData(
      loadNumber: '#LD-8829',
      company: 'Amazon Logistics',
      date: 'Oct 24, 2023',
      status: 'Delivered',
      statusColor: Color(0xFF4CAF50),
      amount: '+\$850',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _subscriptionTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && !_hasShownSubscription) {
        _hasShownSubscription = true;
        showSubscriptionModal(context);
      }
    });
  }

  @override
  void dispose() {
    _subscriptionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: const SafeArea(
        child: _HomeContent(),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Main Content - Separated to prevent unnecessary rebuilds
/// ---------------------------------------------------------------------------

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeaderSection(),
          const SizedBox(height: 24),
          const _NetProfitCard(),
          const SizedBox(height: 24),
          const _ActionButtons(),
          const SizedBox(height: 24),
          const _StatusOverviewSection(),
          const SizedBox(height: 24),
          const _AssignedLoadSection(),
          const SizedBox(height: 24),
          const _MyLoadsSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header Section - Optimized with const constructors
// ---------------------------------------------------------------------------

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const _LocationWidget(),
        _NotificationButton(),
      ],
    );
  }
}

class _LocationWidget extends StatelessWidget {
  const _LocationWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          'assets/icons/location_with_icon.svg',
          height: 24,
          width: 24,
        ),
        SizedBox(width: 6),
        Text(
          'Reine, Norway',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A5F),
          ),
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacementNamed(context, AppRoutes.notification);
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SvgPicture.asset(
            'assets/icons/notification_button_with_circle.svg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Net Profit Card - Extracted and optimized
// ---------------------------------------------------------------------------

class _NetProfitCard extends StatelessWidget {
  const _NetProfitCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2E5A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Net Profit',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '\$4,300',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          _ProfitBreakdown(),
        ],
      ),
    );
  }
}

class _ProfitBreakdown extends StatelessWidget {
  const _ProfitBreakdown();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total Income',
            value: '\$12,500',
            valueColor: Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Total Expense',
            value: '\$8,200',
            valueColor: Color(0xFFEF5350),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action Buttons
// ---------------------------------------------------------------------------

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: buildActionButton(
            title: 'Scan BOL',
            icon: 'assets/icons/scan.svg',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.camScan);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: buildActionButton(
            title: 'Add Load',
            icon: 'assets/icons/add.svg',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.addLoading);
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Status Overview Section - Optimized with const and cached data
// ---------------------------------------------------------------------------

class _StatusOverviewSection extends StatelessWidget {
  const _StatusOverviewSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _HomeScreenState._statusData.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final data = _HomeScreenState._statusData[index];
              return SizedBox(
                width: 160,
                child: buildStatusCard(
                  title: data.title,
                  count: data.count,
                  icon: data.icon,
                  color: data.color,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Assigned Load Section
// ---------------------------------------------------------------------------

class _AssignedLoadSection extends StatelessWidget {
  const _AssignedLoadSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Assigned Load'),
        const SizedBox(height: 12),
        ..._HomeScreenState._assignedLoads.map(
              (load) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: buildLoadCard(
              loadNumber: load.loadNumber,
              company: load.company,
              date: load.date,
              status: load.status,
              statusColor: load.statusColor,
              amount: load.amount,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// My Loads Section
// ---------------------------------------------------------------------------

class _MyLoadsSection extends StatelessWidget {
  const _MyLoadsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'My Loads'),
        const SizedBox(height: 12),
        ..._HomeScreenState._myLoads.map(
              (load) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: buildLoadCard(
              loadNumber: load.loadNumber,
              company: load.company,
              date: load.date,
              status: load.status,
              statusColor: load.statusColor,
              amount: load.amount,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section Header - Reusable component
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const _SectionHeader({
    required this.title,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A5F),
          ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              overlayColor: Colors.transparent,
            ),
            child: const Text(
              'View all',
              style: TextStyle(
                color: Color(0xFF1E3A5F),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Data Models
// ---------------------------------------------------------------------------

class _StatusData {
  final String title;
  final String count;
  final String icon;
  final Color color;

  const _StatusData({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });
}

class _LoadData {
  final String loadNumber;
  final String company;
  final String date;
  final String status;
  final Color statusColor;
  final String amount;

  const _LoadData({
    required this.loadNumber,
    required this.company,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.amount,
  });
}