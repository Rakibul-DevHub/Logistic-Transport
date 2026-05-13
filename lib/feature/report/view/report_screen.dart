import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isThisMonth = true;

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  bool _showCalendar = false;

  // Current displayed week's start date (key for _allWeeklyData)
  DateTime _currentWeekStart = DateTime.now();
  DateTime _currentWeekEnd = DateTime.now();

  // // SAMPLE DATA FOR DIFFERENT WEEKS - keys are Monday dates in yyyy-MM-dd format
  // final Map<String, Map<String, dynamic>> _allWeeklyData = {
  //   '2024-10-14': {
  //     'totalProfit': 11800.0,
  //     'growth': 8.2,
  //     'incomeData': <double>[1.7, 1.9, 1.8, 2.0, 1.9, 1.7, 2.0],
  //     'expenseData': <double>[0.8, 0.9, 0.8, 0.9, 0.8, 0.8, 0.9],
  //     'weekDays': <String>[
  //       'MON 14',
  //       'TUE 15',
  //       'WED 16',
  //       'THU 17',
  //       'FRI 18',
  //       'SAT 19',
  //       'SUN 20'
  //     ],
  //     'categories': {
  //       'Fuel': {'amount': 4650.00, 'subtitle': '37% of total expenses'},
  //       'Maintenance': {'amount': 1100.00, 'subtitle': 'Scheduled & ad-hoc repairs'},
  //       'Tolls': {'amount': 580.00, 'subtitle': 'Electronic pass transponders'},
  //       'Others': {'amount': 800.00, 'subtitle': 'Fleet & liability coverage'},
  //     },
  //   },
  //   '2024-10-21': {
  //     'totalProfit': 12450.0,
  //     'growth': 12.5,
  //     'incomeData': <double>[1.8, 2.0, 1.9, 2.1, 2.0, 1.8, 2.2],
  //     'expenseData': <double>[0.8, 0.9, 0.8, 0.9, 0.8, 0.9, 0.9],
  //     'weekDays': <String>[
  //       'MON 21',
  //       'TUE 22',
  //       'WED 23',
  //       'THU 24',
  //       'FRI 25',
  //       'SAT 26',
  //       'SUN 27'
  //     ],
  //     'categories': {
  //       'Fuel': {'amount': 4820.50, 'subtitle': '38% of total expenses'},
  //       'Maintenance': {'amount': 1240.00, 'subtitle': 'Scheduled & ad-hoc repairs'},
  //       'Tolls': {'amount': 612.20, 'subtitle': 'Electronic pass transponders'},
  //       'Others': {'amount': 850.00, 'subtitle': 'Fleet & liability coverage'},
  //     },
  //   },
  //   '2024-10-28': {
  //     'totalProfit': 13200.0,
  //     'growth': 15.2,
  //     'incomeData': <double>[2.0, 2.2, 2.1, 2.3, 2.2, 2.0, 2.4],
  //     'expenseData': <double>[0.9, 0.8, 0.9, 1.0, 0.9, 0.8, 0.9],
  //     'weekDays': <String>[
  //       'MON 28',
  //       'TUE 29',
  //       'WED 30',
  //       'THU 31',
  //       'FRI 01',
  //       'SAT 02',
  //       'SUN 03'
  //     ],
  //     'categories': {
  //       'Fuel': {'amount': 5100.00, 'subtitle': '40% of total expenses'},
  //       'Maintenance': {'amount': 980.00, 'subtitle': 'Scheduled & ad-hoc repairs'},
  //       'Tolls': {'amount': 725.00, 'subtitle': 'Electronic pass transponders'},
  //       'Others': {'amount': 920.00, 'subtitle': 'Fleet & liability coverage'},
  //     },
  //   },
  //   '2024-11-04': {
  //     'totalProfit': 11800.0,
  //     'growth': 3.5,
  //     'incomeData': <double>[1.7, 1.9, 1.8, 2.0, 1.9, 1.7, 2.1],
  //     'expenseData': <double>[0.9, 1.0, 0.9, 1.0, 0.9, 1.0, 1.0],
  //     'weekDays': <String>[
  //       'MON 04',
  //       'TUE 05',
  //       'WED 06',
  //       'THU 07',
  //       'FRI 08',
  //       'SAT 09',
  //       'SUN 10'
  //     ],
  //     'categories': {
  //       'Fuel': {'amount': 4950.00, 'subtitle': '39% of total expenses'},
  //       'Maintenance': {'amount': 1500.00, 'subtitle': 'Scheduled & ad-hoc repairs'},
  //       'Tolls': {'amount': 680.00, 'subtitle': 'Electronic pass transponders'},
  //       'Others': {'amount': 790.00, 'subtitle': 'Fleet & liability coverage'},
  //     },
  //   },
  // };





  final Map<String, Map<String, dynamic>> _allWeeklyData = {
    '2024-10-11': {
      'totalProfit': -2500.0,  // NEGATIVE PROFIT
      'growth': -8.5,           // NEGATIVE GROWTH
      'incomeData': <double>[1.2, 1.4, 1.3, 1.5, 1.4, 1.2, 1.6],
      'expenseData': <double>[1.5, 1.6, 1.5, 1.6, 1.5, 1.6, 1.6],
      'weekDays': <String>[
        'MON 07',
        'TUE 08',
        'WED 09',
        'THU 10',
        'FRI 11',
        'SAT 12',
        'SUN 13'
      ],
      'categories': {
        'Fuel': {'amount': 5200.00, 'subtitle': '42% of total expenses'},
        'Maintenance': {'amount': 1800.00, 'subtitle': 'Scheduled & ad-hoc repairs'},
        'Tolls': {'amount': 750.00, 'subtitle': 'Electronic pass transponders'},
        'Others': {'amount': 950.00, 'subtitle': 'Fleet & liability coverage'},
      },
    }, // <-- Added comma here

    '2024-10-14': {
      'totalProfit': 11800.0,
      'growth': 8.2,
      'incomeData': <double>[1.7, 1.9, 1.8, 2.0, 1.9, 1.7, 2.0],
      'expenseData': <double>[0.8, 0.9, 0.8, 0.9, 0.8, 0.8, 0.9],
      'weekDays': <String>[
        'MON 14',
        'TUE 15',
        'WED 16',
        'THU 17',
        'FRI 18',
        'SAT 19',
        'SUN 20'
      ],
      'categories': {
        'Fuel': {'amount': 4650.00, 'subtitle': '37% of total expenses'},
        'Maintenance': {'amount': 1100.00, 'subtitle': 'Scheduled & ad-hoc repairs'},
        'Tolls': {'amount': 580.00, 'subtitle': 'Electronic pass transponders'},
        'Others': {'amount': 800.00, 'subtitle': 'Fleet & liability coverage'},
      },
    },
    '2024-10-21': {
      'totalProfit': 12450.0,
      'growth': 12.5,
      'incomeData': <double>[1.8, 2.0, 1.9, 2.1, 2.0, 1.8, 2.2],
      'expenseData': <double>[0.8, 0.9, 0.8, 0.9, 0.8, 0.9, 0.9],
      'weekDays': <String>[
        'MON 21',
        'TUE 22',
        'WED 23',
        'THU 24',
        'FRI 25',
        'SAT 26',
        'SUN 27'
      ],
      'categories': {
        'Fuel': {'amount': 4820.50, 'subtitle': '38% of total expenses'},
        'Maintenance': {'amount': 1240.00, 'subtitle': 'Scheduled & ad-hoc repairs'},
        'Tolls': {'amount': 612.20, 'subtitle': 'Electronic pass transponders'},
        'Others': {'amount': 850.00, 'subtitle': 'Fleet & liability coverage'},
      },
    },
    '2024-10-28': {
      'totalProfit': 13200.0,
      'growth': 15.2,
      'incomeData': <double>[2.0, 2.2, 2.1, 2.3, 2.2, 2.0, 2.4],
      'expenseData': <double>[0.9, 0.8, 0.9, 1.0, 0.9, 0.8, 0.9],
      'weekDays': <String>[
        'MON 28',
        'TUE 29',
        'WED 30',
        'THU 31',
        'FRI 01',
        'SAT 02',
        'SUN 03'
      ],
      'categories': {
        'Fuel': {'amount': 5100.00, 'subtitle': '40% of total expenses'},
        'Maintenance': {'amount': 980.00, 'subtitle': 'Scheduled & ad-hoc repairs'},
        'Tolls': {'amount': 725.00, 'subtitle': 'Electronic pass transponders'},
        'Others': {'amount': 920.00, 'subtitle': 'Fleet & liability coverage'},
      },
    },
    '2024-11-04': {
      'totalProfit': 11800.0,
      'growth': 3.5,
      'incomeData': <double>[1.7, 1.9, 1.8, 2.0, 1.9, 1.7, 2.1],
      'expenseData': <double>[0.9, 1.0, 0.9, 1.0, 0.9, 1.0, 1.0],
      'weekDays': <String>[
        'MON 04',
        'TUE 05',
        'WED 06',
        'THU 07',
        'FRI 08',
        'SAT 09',
        'SUN 10'
      ],
      'categories': {
        'Fuel': {'amount': 4950.00, 'subtitle': '39% of total expenses'},
        'Maintenance': {'amount': 1500.00, 'subtitle': 'Scheduled & ad-hoc repairs'},
        'Tolls': {'amount': 680.00, 'subtitle': 'Electronic pass transponders'},
        'Others': {'amount': 790.00, 'subtitle': 'Fleet & liability coverage'},
      },
    },
  }; // <-- Removed the extra closing brace here



  // Sorted list of available week keys (Monday dates)
  late final List<String> _sortedWeekKeys;

  @override
  void initState() {
    super.initState();
    // Get all keys and sort them chronologically
    _sortedWeekKeys = _allWeeklyData.keys.toList()..sort();

    // Find the week that contains today's date or the closest past week
    _currentWeekStart = _findClosestWeek(_selectedDay);
    _updateWeekEnd();
  }

  void _updateWeekEnd() {
    _currentWeekEnd = _currentWeekStart.add(const Duration(days: 6));
  }

  /// Finds the week start date (Monday) that contains the given date,
  /// or the closest available week if not found
  DateTime _findClosestWeek(DateTime date) {
    // Get the Monday of the given date's week
    DateTime targetMonday = date.subtract(Duration(days: date.weekday - 1));
    String targetKey = DateFormat('yyyy-MM-dd').format(targetMonday);

    // If exact week exists, use it
    if (_allWeeklyData.containsKey(targetKey)) {
      return targetMonday;
    }

    // Otherwise, find the closest available week
    // Try to find the closest past week
    for (int i = _sortedWeekKeys.length - 1; i >= 0; i--) {
      DateTime weekStart = DateFormat('yyyy-MM-dd').parse(_sortedWeekKeys[i]);
      if (weekStart.isBefore(targetMonday) || weekStart.isAtSameMomentAs(targetMonday)) {
        return weekStart;
      }
    }

    // If no past week, return the first available week
    return DateFormat('yyyy-MM-dd').parse(_sortedWeekKeys.first);
  }

  /// Get the key for the current week start date
  String _getCurrentWeekKey() {
    return DateFormat('yyyy-MM-dd').format(_currentWeekStart);
  }

  /// Get data for the current week
  Map<String, dynamic> _getCurrentWeekData() {
    String key = _getCurrentWeekKey();
    if (_allWeeklyData.containsKey(key)) {
      return _allWeeklyData[key]!;
    }
    // Fallback: return first available data
    return _allWeeklyData[_sortedWeekKeys.first]!;
  }

  /// Get current week index in the sorted list
  int _getCurrentWeekIndex() {
    return _sortedWeekKeys.indexOf(_getCurrentWeekKey());
  }

  /// Navigate to previous week (if available)
  void _previousWeek() {
    int currentIndex = _getCurrentWeekIndex();
    if (currentIndex > 0) {
      setState(() {
        _currentWeekStart = DateFormat('yyyy-MM-dd').parse(_sortedWeekKeys[currentIndex - 1]);
        _updateWeekEnd();
        _selectedDay = _currentWeekStart;
        _focusedDay = _currentWeekStart;
      });
    }
  }

  /// Navigate to next week (if available)
  void _nextWeek() {
    int currentIndex = _getCurrentWeekIndex();
    if (currentIndex < _sortedWeekKeys.length - 1) {
      setState(() {
        _currentWeekStart = DateFormat('yyyy-MM-dd').parse(_sortedWeekKeys[currentIndex + 1]);
        _updateWeekEnd();
        _selectedDay = _currentWeekStart;
        _focusedDay = _currentWeekStart;
      });
    }
  }

  /// Handle date selection from calendar
  void _onDateSelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _currentWeekStart = _findClosestWeek(selectedDay);
      _updateWeekEnd();
      _showCalendar = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentData = _getCurrentWeekData();

    final List<String> weekDays = List<String>.from(currentData['weekDays'] ?? []);
    final List<double> incomeData = List<double>.from(currentData['incomeData'] ?? []);
    final List<double> expenseData = List<double>.from(currentData['expenseData'] ?? []);
    final double totalProfit = (currentData['totalProfit'] ?? 0.0).toDouble();
    final double growth = (currentData['growth'] ?? 0.0).toDouble();
    final Map<String, dynamic> categories = (currentData['categories'] as Map<String, dynamic>? ?? {});

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildToggleHeader(),
                  const SizedBox(height: 16),
                  _buildInsightCard(
                    weekDays: weekDays,
                    incomeData: incomeData,
                    expenseData: expenseData,
                    totalProfit: totalProfit,
                    growth: growth,
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryList(categories),
                ],
              ),
            ),
            if (_showCalendar)
              GestureDetector(
                onTap: () => setState(() => _showCalendar = false),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Select Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  IconButton(onPressed: () => setState(() => _showCalendar = false), icon: const Icon(Icons.close)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 400,
                                child: TableCalendar(
                                  firstDay: DateTime.utc(2020, 1, 1),
                                  lastDay: DateTime.utc(2035, 12, 31),
                                  focusedDay: _focusedDay.isBefore(DateTime.utc(2020, 1, 1))
                                      ? DateTime.utc(2020, 1, 1)
                                      : _focusedDay.isAfter(DateTime.utc(2035, 12, 31))
                                      ? DateTime.utc(2035, 12, 31)
                                      : _focusedDay,
                                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                                  onDaySelected: _onDateSelected,
                                  headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                                  daysOfWeekStyle: const DaysOfWeekStyle(
                                    weekdayStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                                    weekendStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
                                  ),
                                  calendarStyle: CalendarStyle(
                                    outsideDaysVisible: false,
                                    weekendTextStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                                    todayDecoration: BoxDecoration(
                                      color: const Color(0xFF1E3A5F).withValues(alpha: 0.25),
                                      shape: BoxShape.circle,
                                    ),
                                    selectedDecoration: const BoxDecoration(color: Color(0xFF1E3A5F), shape: BoxShape.circle),
                                    selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  availableGestures: AvailableGestures.all,
                                  startingDayOfWeek: StartingDayOfWeek.monday,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleHeader() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFE5E9EF), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isThisMonth = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isThisMonth ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text("This Month", style: TextStyle(fontWeight: FontWeight.w600, color: _isThisMonth ? Colors.black : Colors.grey)),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isThisMonth = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isThisMonth ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text("Last Month", style: TextStyle(fontWeight: FontWeight.w600, color: !_isThisMonth ? Colors.black : Colors.grey)),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _showCalendar = true),
            icon: SvgPicture.asset('assets/icons/calendar.svg', width: 22, height: 22),
          ),
        ],
      ),
    );
  }



  // Widget _buildInsightCard({
  //   required List<String> weekDays,
  //   required List<double> incomeData,
  //   required List<double> expenseData,
  //   required double totalProfit,
  //   required double growth,
  // })
  // {
  //   return Container(
  //     padding: const EdgeInsets.all(24),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(24),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.04),
  //           blurRadius: 10,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // TITLE
  //         const Text(
  //           "WEEKLY PROFIT INSIGHT",
  //           style: TextStyle(
  //             fontSize: 14,
  //             color: Colors.grey,
  //             fontWeight: FontWeight.w600,
  //             letterSpacing: 0.3,
  //           ),
  //         ),
  //
  //         const SizedBox(height: 16),
  //
  //         // PROFIT AND GROWTH
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               "\$${NumberFormat('#,##0.00').format(totalProfit)}",
  //               style: const TextStyle(
  //                 fontSize: 32,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.black87,
  //                 letterSpacing: -0.5,
  //               ),
  //             ),
  //             Container(
  //               padding: const EdgeInsets.symmetric(
  //                 horizontal: 12,
  //                 vertical: 6,
  //               ),
  //               decoration: BoxDecoration(
  //                 color: Colors.green.withValues(alpha: 0.1),
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Icon(
  //                     Icons.trending_up,
  //                     color: Colors.green.shade600,
  //                     size: 16,
  //                   ),
  //                   const SizedBox(width: 4),
  //                   Text(
  //                     "+${growth.toStringAsFixed(1)}%",
  //                     style: TextStyle(
  //                       color: Colors.green.shade600,
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 14,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //
  //
  //         // LEGEND
  //         Row(
  //           children: [
  //             Row(
  //               children: [
  //                 Container(
  //                   width: 10,
  //                   height: 10,
  //                   decoration: const BoxDecoration(
  //                     color: Color(0xFF3B82F6),
  //                     shape: BoxShape.circle,
  //                   ),
  //                 ),
  //                 const SizedBox(width: 8),
  //                 const Text(
  //                   "Income",
  //                   style: TextStyle(
  //                     fontSize: 13,
  //                     color: Colors.grey,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(width: 24),
  //             Row(
  //               children: [
  //                 Container(
  //                   width: 10,
  //                   height: 10,
  //                   decoration: const BoxDecoration(
  //                     color: Color(0xFFF59E0B),
  //                     shape: BoxShape.circle,
  //                   ),
  //                 ),
  //                 const SizedBox(width: 8),
  //                 const Text(
  //                   "Expenses",
  //                   style: TextStyle(
  //                     fontSize: 13,
  //                     color: Colors.grey,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //
  //         const SizedBox(height: 10),
  //
  //         // BAR CHART
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //           child: SizedBox(
  //             height: 180,
  //             child: BarChart(
  //               BarChartData(
  //                 maxY: 2.5,
  //                 gridData: const FlGridData(show: false),
  //                 borderData: FlBorderData(show: false),
  //                 barTouchData: BarTouchData(enabled: false),
  //                 titlesData: const FlTitlesData(
  //                   leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //                   topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //                   rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //                   bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //                 ),
  //                 barGroups: List.generate(
  //                   weekDays.length,
  //                       (index) {
  //                     return BarChartGroupData(
  //                       x: index,
  //                       barsSpace: 3,
  //                       barRods: [
  //                         BarChartRodData(
  //                           toY: index < incomeData.length ? incomeData[index] : 0,
  //                           width: 7,
  //                           color: const Color(0xFF3B82F6),
  //                           borderRadius: const BorderRadius.only(
  //                             topLeft: Radius.circular(4),
  //                             topRight: Radius.circular(4),
  //                           ),
  //                         ),
  //                         BarChartRodData(
  //                           toY: index < expenseData.length ? expenseData[index] : 0,
  //                           width: 7,
  //                           color: const Color(0xFFF59E0B),
  //                           borderRadius: const BorderRadius.only(
  //                             topLeft: Radius.circular(4),
  //                             topRight: Radius.circular(4),
  //                           ),
  //                         ),
  //                       ],
  //                     );
  //                   },
  //                 ),
  //                 groupsSpace: 8,
  //               ),
  //             ),
  //           ),
  //         ),
  //
  //         const SizedBox(height: 16),
  //
  //         // NAVIGATION WITH DATES AT BOTTOM
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             // LEFT ARROW
  //             GestureDetector(
  //               onTap: _previousWeek,
  //               child: Container(
  //                 width: 32,
  //                 height: 32,
  //                 decoration: BoxDecoration(
  //                   shape: BoxShape.circle,
  //                   border: Border.all(color: Colors.black, width: 1.5),
  //                 ),
  //                 child: const Icon(
  //                   Icons.chevron_left,
  //                   size: 18,
  //                   color: Colors.black87,
  //                 ),
  //               ),
  //             ),
  //
  //             // DAY LABELS - Aligned with bars
  //             Expanded(
  //               child: Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: List.generate(
  //                     weekDays.length,
  //                         (index) {
  //                       final day = weekDays[index];
  //                       final parts = day.split(' ');
  //                       final dayName = parts[0];
  //                       final dayNumber = parts.length > 1 ? parts[1] : '';
  //
  //                       return Column(
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: [
  //                           Text(
  //                             dayName,
  //                             style: const TextStyle(
  //                               fontSize: 10,
  //                               fontWeight: FontWeight.w600,
  //                               color: Colors.black87,
  //                             ),
  //                           ),
  //                           const SizedBox(height: 2),
  //                           Text(
  //                             dayNumber,
  //                             style: const TextStyle(
  //                               fontSize: 12,
  //                               fontWeight: FontWeight.bold,
  //                               color: Colors.black87,
  //                             ),
  //                           ),
  //                         ],
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               ),
  //             ),
  //
  //             // RIGHT ARROW
  //             GestureDetector(
  //               onTap: _nextWeek,
  //               child: Container(
  //                 width: 32,
  //                 height: 32,
  //                 decoration: BoxDecoration(
  //                   shape: BoxShape.circle,
  //                   border: Border.all(color: Colors.black, width: 1.5),
  //                 ),
  //                 child: const Icon(
  //                   Icons.chevron_right,
  //                   size: 18,
  //                   color: Colors.black87,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }




  Widget _buildInsightCard({
    required List<String> weekDays,
    required List<double> incomeData,
    required List<double> expenseData,
    required double totalProfit,
    required double growth,
  }) {
    // Get current week index for arrow enabling/disabling
    int currentIndex = _getCurrentWeekIndex();
    bool hasPrevious = currentIndex > 0;
    bool hasNext = currentIndex < _sortedWeekKeys.length - 1;

    // Determine growth color and icon based on positive/negative
    bool isPositiveGrowth = growth >= 0;
    Color growthColor = isPositiveGrowth ? Colors.green.shade600 : Colors.red.shade600;
    IconData growthIcon = isPositiveGrowth ? Icons.trending_up : Icons.trending_down;

    // Determine profit color (red for negative, black for positive)
    Color profitColor = totalProfit >= 0 ? Colors.black87 : Colors.red.shade600;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE AND DATE RANGE
          Text(
            "WEEKLY PROFIT INSIGHT",
            style: AppTextStyle.SFProDisplay_Regular.copyWith(
              color: AppColors.textGreyColor,
            )
          ),

          const SizedBox(height: 20),

          // PROFIT AND GROWTH
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profit amount with negative sign if applicable
              Text(
                totalProfit >= 0
                    ? "\$${NumberFormat('#,##0.00').format(totalProfit)}"
                    : "-\$${NumberFormat('#,##0.00').format(totalProfit.abs())}",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: profitColor,
                  letterSpacing: -0.5,
                ),
              ),

              // Growth percentage with proper sign and color
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: growthColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      growthIcon,
                      color: growthColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      growth >= 0
                          ? "+${growth.toStringAsFixed(1)}%"
                          : "${growth.toStringAsFixed(1)}%",
                      style: TextStyle(
                        color: growthColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // LEGEND
          Row(
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Income",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Expenses",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // BAR CHART WITH DAYS
          Column(
            children: [
              // BAR CHART
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    maxY: 2.5,
                    minY: 0,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: const FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    barGroups: List.generate(
                      weekDays.length,
                          (index) {
                        return BarChartGroupData(
                          x: index,
                          barsSpace: 3,
                          barRods: [
                            BarChartRodData(
                              toY: index < incomeData.length ? incomeData[index] : 0,
                              width: 7,
                              color: const Color(0xFF3B82F6),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                            BarChartRodData(
                              toY: index < expenseData.length ? expenseData[index] : 0,
                              width: 7,
                              color: const Color(0xFFF59E0B),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    groupsSpace: 8,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // DAY LABELS WITH ARROWS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LEFT ARROW
                  GestureDetector(
                    onTap: hasPrevious ? _previousWeek : null,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: hasPrevious ? Colors.black : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        size: 18,
                        color: hasPrevious ? Colors.black87 : Colors.grey.shade300,
                      ),
                    ),
                  ),

                  // DAY LABELS
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          weekDays.length,
                              (index) {
                            final day = weekDays[index];
                            final parts = day.split(' ');
                            final dayName = parts[0];
                            final dayNumber = parts.length > 1 ? parts[1] : '';

                            return Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    dayName,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    dayNumber,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // RIGHT ARROW
                  GestureDetector(
                    onTap: hasNext ? _nextWeek : null,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: hasNext ? Colors.black : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: hasNext ? Colors.black87 : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }







  Widget _buildCategoryList(Map<String, dynamic> categories) {
    return Column(
      children: [
        _buildCategoryCard(
          title: "Fuel",
          amount: "\$${categories['Fuel']['amount']}",
          subtitle: categories['Fuel']['subtitle'],
          svgAsset: 'assets/icons/fuel.svg',
        ),
        const SizedBox(height: 12),
        _buildCategoryCard(
          title: "Maintenance",
          amount: "\$${categories['Maintenance']['amount']}",
          subtitle: categories['Maintenance']['subtitle'],
          svgAsset: 'assets/icons/maintenance.svg',
        ),
        const SizedBox(height: 12),
        _buildCategoryCard(
          title: "Tolls",
          amount: "\$${categories['Tolls']['amount']}",
          subtitle: categories['Tolls']['subtitle'],
          svgAsset: 'assets/icons/tolls.svg',
        ),
        const SizedBox(height: 12),
        _buildCategoryCard(
          title: "Others",
          amount: "\$${categories['Others']['amount']}",
          subtitle: categories['Others']['subtitle'],
          svgAsset: 'assets/icons/others.svg',
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String amount,
    required String subtitle,
    required String svgAsset,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                svgAsset,
                width: 35,
                height: 35,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}