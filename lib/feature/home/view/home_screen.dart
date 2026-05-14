
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tag/core/constants/app_routes.dart';
import 'package:tag/core/theme/app_text_style.dart';
import 'package:tag/feature/home/bill_of_loading/bill_of_loading.dart';
import 'package:tag/feature/notification/view/notification_screen.dart';
import '../../../shared/widget/build_action_button.dart';
import '../../../shared/widget/build_load_card.dart';
import '../../../shared/widget/build_status_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section - FIXED
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Location Section - Fixed layout
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/location_with_icon.svg',
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Reine, Norway',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A5F),
                        ),
                      ),
                    ],
                  ),
                  // Notification Button
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.notification,
                      );

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
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Net Profit Card - Large Dark Card
              Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Net Profit',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '\$4,300',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // Total Income
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Income',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '\$12,500',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Total Expense
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Expense',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '\$8,200',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFEF5350),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons Row - White cards
              Row(
                children: [
                  Expanded(
                    child: buildActionButton(
                      title: 'Scan BOL',
                      icon: 'assets/icons/scan.svg',
                      onTap: () {
                        // Navigator.pushReplacement(context, AppRoutes.bol);
                        Navigator.pushNamed(context, AppRoutes.camScan);
                        // AppRoutes.camScan;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildActionButton(
                      title: 'Add Load',
                      icon: 'assets/icons/add.svg',
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Status Overview Section - USING THE SCROLLABLE METHOD
              buildStatusSection(),

              const SizedBox(height: 24),

              // Assigned Load Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Assigned Load',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
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
              ),

              const SizedBox(height: 12),

              // Assigned Load Cards
              Column(
                children: [
                  buildLoadCard(
                    loadNumber: '#LD-8829',
                    company: 'Amazon Logistics',
                    date: 'Oct 24, 2023',
                    status: 'Missing POD',
                    statusColor: const Color(0xFFFF9800),
                    amount: "+\$850",
                  ),
                  const SizedBox(height: 12),
                  buildLoadCard(
                    loadNumber: '#LD-8829',
                    company: 'Amazon Logistics',
                    date: 'Oct 24, 2023',
                    status: 'Delivered',
                    statusColor: const Color(0xFF4CAF50),
                    amount: '+\$850',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // My Loads Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Loads',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
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
              ),

              const SizedBox(height: 12),

              // My Loads Cards
              Column(
                children: [
                  buildLoadCard(
                    loadNumber: '#LD-8829',
                    company: 'Amazon Logistics',
                    date: 'Oct 24, 2023',
                    status: 'Delivered',
                    statusColor: const Color(0xFF4CAF50),
                    amount: '+\$850',
                  ),
                  const SizedBox(height: 12),
                  buildLoadCard(
                    loadNumber: '#LD-8829',
                    company: 'Amazon Logistics',
                    date: 'Oct 24, 2023',
                    status: 'Delivered',
                    statusColor: const Color(0xFF4CAF50),
                    amount: '+\$850',
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Status Overview Section
  Widget buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'Status Overview',
          style: AppTextStyle.SFProDisplay_Regular.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 16),

        // Horizontal Cards
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _getStatusData().length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final data = _getStatusData()[index];

              return buildStatusCard(
                title: data['title'],
                count: data['count'],
                icon: data['icon'],
                color: data['color'],
              );
            },
          ),
        ),
      ],
    );
  }

  // Status Data
  List<Map<String, dynamic>> _getStatusData() {
    return [
      {
        'title': 'Completed',
        'count': '21',
        'icon': 'assets/icons/completed.svg',
        'color': const Color(0xFF12B76A),
      },
      {
        'title': 'Missing POD',
        'count': '03',
        'icon': 'assets/icons/missing_pod.svg',
        'color': const Color(0xFFEAAA08),
      },
      {
        'title': 'Missing Expense',
        'count': '12',
        'icon': 'assets/icons/expense.svg',
        'color': const Color(0xFFD92D20),
      },
    ];
  }
}






