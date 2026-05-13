import 'package:flutter/cupertino.dart';

import '../../core/theme/app_text_style.dart';
import 'build_status_card.dart';

Widget buildStatusSection()
{
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