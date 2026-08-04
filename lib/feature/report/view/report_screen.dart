/**
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';
import 'package:tag/feature/report/cubit/report_cubit.dart';
import 'package:tag/feature/report/model/report_data.dart';
import 'package:tag/shared/widget/immersive_safe_area.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportCubit()..fetchThisMonth(),
      child: const _ReportView(),
    );
  }
}

class _ReportView extends StatefulWidget {
  const _ReportView();

  @override
  State<_ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<_ReportView> {
  /// true = This Month, false = This Week
  bool _isThisMonth = true;

  /// When true, calendar custom range is active (chip visible).
  bool _hasCustomRange = false;

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  bool _showCalendar = false;

  /// Active fetch window.
  late DateTime _activeStart;
  late DateTime _activeEnd;

  /// First day shown on the 7-day chart (arrows shift this by ±1 day).
  late DateTime _chartStart;

  /// Calendar draft range (before Apply).
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  /// Loaded daily rows keyed by yyyy-MM-dd.
  final Map<String, DailyReport> _dailyByDate = {};

  static final NumberFormat _money = NumberFormat('#,##0.00');
  static final DateFormat _rangeLabel = DateFormat('MMM d, yyyy');
  static final DateFormat _dayKey = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _activeStart = DateTime(now.year, now.month, 1);
    _activeEnd = DateTime(now.year, now.month + 1, 0);
    _chartStart = _activeStart;
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String _keyFor(DateTime d) => _dayKey.format(_dateOnly(d));

  void _setActiveRange(DateTime start, DateTime end) {
    final from = _dateOnly(start);
    final to = _dateOnly(end);
    if (from.isBefore(to) || from.isAtSameMomentAs(to)) {
      _activeStart = from;
      _activeEnd = to;
    } else {
      _activeStart = to;
      _activeEnd = from;
    }
  }

  void _ingestDaily(List<DailyReport> daily) {
    _dailyByDate
      ..clear()
      ..addEntries(
        daily.map((d) {
          // Normalize to date-only local key (yyyy-MM-dd).
          final key = _keyFor(d.date);
          return MapEntry(key, d);
        }),
      );

    // Keep / clamp chart window inside active range (never jump to wrong week).
    _chartStart = _clampChartStart(_dateOnly(_chartStart));
  }

  int get _rangeDayCount =>
      _activeEnd.difference(_activeStart).inDays + 1;

  /// Chart always shows up to 7 day slots.
  int get _windowDays {
    final span = _rangeDayCount;
    if (span <= 0) return 1;
    return span < 7 ? span : 7;
  }

  DateTime get _minChartStart => _activeStart;

  DateTime get _maxChartStart {
    final span = _rangeDayCount;
    if (span <= _windowDays) return _activeStart;
    return _activeEnd.subtract(Duration(days: _windowDays - 1));
  }

  DateTime _clampChartStart(DateTime value) {
    var v = _dateOnly(value);
    if (v.isBefore(_minChartStart)) return _minChartStart;
    if (v.isAfter(_maxChartStart)) return _maxChartStart;
    return v;
  }

  bool get _canScrollLeft => _chartStart.isAfter(_minChartStart);

  bool get _canScrollRight => _chartStart.isBefore(_maxChartStart);

  /// Exactly [_windowDays] consecutive calendar days starting at [_chartStart].
  List<DailyReport> get _visibleDays {
    final start = _dateOnly(_chartStart);
    return List.generate(_windowDays, (i) {
      final day = DateTime(start.year, start.month, start.day + i);
      if (day.isAfter(_activeEnd)) {
        return DailyReport(
          date: day,
          day: DailyReport.weekdayShort(day.weekday),
          income: 0,
          expenses: 0,
          profit: 0,
        );
      }
      return _dailyByDate[_keyFor(day)] ??
          DailyReport(
            date: day,
            day: DailyReport.weekdayShort(day.weekday),
            income: 0,
            expenses: 0,
            profit: 0,
          );
    });
  }

  /// Chart bottom label.
  /// Calendar range → weekday / date / month (3 lines).
  /// Otherwise → weekday / date.
  String _chartDayLabel(DateTime date) {
    final dayName = DailyReport.weekdayShort(date.weekday);
    final dayNumber = date.day.toString().padLeft(2, '0');
    if (_hasCustomRange) {
      final month = DateFormat('MMM').format(date).toUpperCase();
      return '$dayName§$dayNumber§$month';
    }
    return '$dayName§$dayNumber';
  }

  /// Chart ◀ / ▶ / swipe — scroll the 7-day window by 1 day.
  void _shiftChartByOneDay(int delta) {
    final next = _clampChartStart(
      _dateOnly(_chartStart).add(Duration(days: delta)),
    );
    if (next.isAtSameMomentAs(_dateOnly(_chartStart))) return;
    setState(() {
      _chartStart = next;
      _selectedDay = next;
      _focusedDay = next;
    });
  }

  void _onThisWeek() {
    final now = DateTime.now();
    final monday = _dateOnly(now).subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    setState(() {
      _isThisMonth = false;
      _hasCustomRange = false;
      _rangeStart = null;
      _rangeEnd = null;
      _setActiveRange(monday, sunday);
      _chartStart = monday;
      _selectedDay = monday;
      _focusedDay = monday;
    });
    context.read<ReportCubit>().fetchThisWeek();
  }

  void _onThisMonth() {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, 1);
    final last = DateTime(now.year, now.month + 1, 0);
    setState(() {
      _isThisMonth = true;
      _hasCustomRange = false;
      _rangeStart = null;
      _rangeEnd = null;
      _setActiveRange(first, last);
      // Chart starts on the 1st so days 1–7 line up exactly.
      _chartStart = first;
      _selectedDay = first;
      _focusedDay = first;
    });
    context.read<ReportCubit>().fetchThisMonth();
  }

  void _clearCustomRange() {
    if (_isThisMonth) {
      _onThisMonth();
    } else {
      _onThisWeek();
    }
  }

  void _openCalendar() {
    setState(() {
      _showCalendar = true;
      // Fresh pick — start empty so first tap = start, second = end.
      _rangeStart = null;
      _rangeEnd = null;
      _focusedDay = _dateOnly(_selectedDay);
    });
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _rangeStart = start == null ? null : _dateOnly(start);
      _rangeEnd = end == null ? null : _dateOnly(end);
      _focusedDay = _dateOnly(focusedDay);
      if (_rangeStart != null) {
        _selectedDay = _rangeStart!;
      }
    });
  }

  void _applyDateRange() {
    final start = _rangeStart;
    if (start == null) return;

    final end = _rangeEnd ?? start;
    final from = start.isBefore(end) ? start : end;
    final to = start.isBefore(end) ? end : start;

    setState(() {
      _showCalendar = false;
      _hasCustomRange = true;
      _setActiveRange(from, to);
      // Keep selection chip dates (range) — scrolling won't overwrite these.
      _rangeStart = _activeStart;
      _rangeEnd = _activeEnd;
      _chartStart = _activeStart;
      _selectedDay = _activeStart;
      _focusedDay = _activeStart;
    });
    context.read<ReportCubit>().fetchRange(_activeStart, _activeEnd);
  }

  Map<String, dynamic> _categoriesFrom(ReportSummary summary) {
    const defaults = {
      'Fuel': {
        'amount': 0.0,
        'subtitle': 'Scheduled fuel spend',
      },
      'Maintenance': {
        'amount': 0.0,
        'subtitle': 'Scheduled & ad-hoc repairs',
      },
      'Tolls': {
        'amount': 0.0,
        'subtitle': 'Electronic pass transponders',
      },
      'Others': {
        'amount': 0.0,
        'subtitle': 'Fleet & liability coverage',
      },
    };

    final amounts = <String, double>{
      for (final key in defaults.keys) key: 0.0,
    };

    // Sum amounts per UI category (multiple API rows can map to one card).
    for (final item in summary.expenseBreakdown) {
      final key = _mapCategoryKey(item.name);
      amounts[key] = (amounts[key] ?? 0) + item.amount;
    }

    final breakdownTotal =
        amounts.values.fold<double>(0, (sum, v) => sum + v);
    // Prefer summary total; if Fuel alone exceeds it, use breakdown sum
    // so percentages stay within 0–100.
    var base = summary.totalExpenses;
    if (base <= 0 || (breakdownTotal > 0 && breakdownTotal > base + 0.01)) {
      base = breakdownTotal;
    }

    final result = <String, dynamic>{};
    for (final key in defaults.keys) {
      final amount = amounts[key] ?? 0.0;
      final pct = base > 0 ? ((amount / base) * 100).clamp(0.0, 100.0) : 0.0;
      final defaultSubtitle = defaults[key]!['subtitle'] as String;
      result[key] = {
        'amount': amount,
        'subtitle': amount > 0
            ? '${pct.toStringAsFixed(0)}% of total expenses'
            : defaultSubtitle,
      };
    }

    return result;
  }

  String _mapCategoryKey(String raw) {
    final n = raw.trim().toLowerCase();
    if (n.contains('fuel')) return 'Fuel';
    if (n.contains('maint')) return 'Maintenance';
    if (n.contains('toll')) return 'Tolls';
    if (n.contains('other')) return 'Others';
    return 'Others';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      body: ImmersiveSafeArea(
        child: Stack(
          children: [
            BlocConsumer<ReportCubit, ReportState>(
              listener: (context, state) {
                if (state is ReportSuccess) {
                  setState(() => _ingestDaily(state.data.dailyReports));
                }
              },
              builder: (context, state) {
                if (state is ReportLoading || state is ReportInitial) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildToggleHeader(),
                      ),
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                if (state is ReportFailure) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildToggleHeader(),
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.errorMessage,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: () {
                                    if (_hasCustomRange) {
                                      context
                                          .read<ReportCubit>()
                                          .fetchRange(
                                            _activeStart,
                                            _activeEnd,
                                          );
                                    } else if (_isThisMonth) {
                                      context
                                          .read<ReportCubit>()
                                          .fetchThisMonth();
                                    } else {
                                      context
                                          .read<ReportCubit>()
                                          .fetchThisWeek();
                                    }
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                final data = (state as ReportSuccess).data;
                final week = _visibleDays;
                final weekDays = week
                    .map((d) => _chartDayLabel(d.date))
                    .toList(growable: false);
                final incomeData =
                    week.map((d) => d.income).toList(growable: false);
                final expenseData =
                    week.map((d) => d.expenses).toList(growable: false);
                // Full selected range profit (month/week/custom) — not just 7 chart days.
                final totalProfit = data.summary.totalProfit;
                final growth = data.trend.isPositive
                    ? data.trend.percentage.abs()
                    : -data.trend.percentage.abs();
                final categories = _categoriesFrom(data.summary);

                return SingleChildScrollView(
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
                );
              },
            ),
            if (_showCalendar)
              Material(
                color: Colors.black.withValues(alpha: 0.5),
                child: SafeArea(
                  child: Center(
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
                                const Text(
                                  "Select Date Range",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => setState(
                                    () => _showCalendar = false,
                                  ),
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _rangeStart == null
                                    ? 'Tap a start date, then an end date'
                                    : _rangeEnd == null
                                        ? 'Start: ${_rangeLabel.format(_rangeStart!)}  ·  tap end date'
                                        : '${_rangeLabel.format(_rangeStart!)}  →  ${_rangeLabel.format(_rangeEnd!)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 400,
                              child: TableCalendar(
                                firstDay: DateTime(2020, 1, 1),
                                lastDay: DateTime(2035, 12, 31),
                                focusedDay: _focusedDay.isBefore(
                                        DateTime(2020, 1, 1))
                                    ? DateTime(2020, 1, 1)
                                    : _focusedDay.isAfter(DateTime(2035, 12, 31))
                                        ? DateTime(2035, 12, 31)
                                        : _focusedDay,
                                rangeStartDay: _rangeStart,
                                rangeEndDay: _rangeEnd,
                                rangeSelectionMode:
                                    RangeSelectionMode.toggledOn,
                                onRangeSelected: _onRangeSelected,
                                onPageChanged: (focused) {
                                  setState(
                                    () => _focusedDay = _dateOnly(focused),
                                  );
                                },
                                headerStyle: const HeaderStyle(
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                ),
                                daysOfWeekStyle: const DaysOfWeekStyle(
                                  weekdayStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  weekendStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                                calendarStyle: CalendarStyle(
                                  outsideDaysVisible: false,
                                  weekendTextStyle: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  todayDecoration: BoxDecoration(
                                    color: const Color(0xFF1E3A5F)
                                        .withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  selectedDecoration: const BoxDecoration(
                                    color: Color(0xFF1E3A5F),
                                    shape: BoxShape.circle,
                                  ),
                                  rangeStartDecoration: const BoxDecoration(
                                    color: Color(0xFF1E3A5F),
                                    shape: BoxShape.circle,
                                  ),
                                  rangeEndDecoration: const BoxDecoration(
                                    color: Color(0xFF1E3A5F),
                                    shape: BoxShape.circle,
                                  ),
                                  rangeHighlightColor: const Color(0xFF1E3A5F)
                                      .withValues(alpha: 0.15),
                                  withinRangeTextStyle: const TextStyle(
                                    color: Colors.black87,
                                  ),
                                  selectedTextStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                availableGestures: AvailableGestures.all,
                                startingDayOfWeek: StartingDayOfWeek.monday,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _rangeStart == null
                                    ? null
                                    : _applyDateRange,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A5F),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      Colors.grey.shade300,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Apply',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E9EF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _onThisWeek,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isThisMonth && !_hasCustomRange
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "This Week",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: !_isThisMonth && !_hasCustomRange
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _onThisMonth,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isThisMonth && !_hasCustomRange
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "This Month",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _isThisMonth && !_hasCustomRange
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _openCalendar,
                icon: SvgPicture.asset(
                  'assets/icons/calendar.svg',
                  width: 22,
                  height: 22,
                ),
              ),
            ],
          ),
        ),
        if (_hasCustomRange) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E9EF)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.date_range,
                  size: 18,
                  color: Color(0xFF1E3A5F),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _activeStart.isAtSameMomentAs(_activeEnd)
                        ? _rangeLabel.format(_activeStart)
                        : '${_rangeLabel.format(_activeStart)}  →  ${_rangeLabel.format(_activeEnd)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _clearCustomRange,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E9EF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInsightCard({
    required List<String> weekDays,
    required List<double> incomeData,
    required List<double> expenseData,
    required double totalProfit,
    required double growth,
  }) {
    final isPositiveGrowth = growth >= 0;
    final growthColor =
        isPositiveGrowth ? Colors.green.shade600 : Colors.red.shade600;
    final growthIcon =
        isPositiveGrowth ? Icons.trending_up : Icons.trending_down;

    final profitColor =
        totalProfit >= 0 ? Colors.black87 : Colors.red.shade600;

    // Dynamic chart scale (same look as before, real API values).
    double maxY = 1;
    for (final v in [...incomeData, ...expenseData]) {
      if (v > maxY) maxY = v;
    }
    maxY = maxY <= 0 ? 1 : maxY * 1.25;

    // Silence unused (growth UI remains commented as in original design).
    // ignore: unused_local_variable
    final _ = (growthColor, growthIcon);

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
          Text(
            "Profit Insight",
            style: AppTextStyle.SFProDisplay_Regular.copyWith(
              color: AppColors.textGreyColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                totalProfit >= 0
                    ? "\$${_money.format(totalProfit)}"
                    : "-\$${_money.format(totalProfit.abs())}",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: profitColor,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragEnd: (details) {
              final v = details.primaryVelocity ?? 0;
              if (v < -200) {
                _shiftChartByOneDay(1);
              } else if (v > 200) {
                _shiftChartByOneDay(-1);
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: _canScrollLeft
                        ? () => _shiftChartByOneDay(-1)
                        : null,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _canScrollLeft
                              ? Colors.black
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        size: 18,
                        color: _canScrollLeft
                            ? Colors.black87
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // One column per calendar day → bar sits exactly on its date.
                Expanded(
                  child: SizedBox(
                    height: 220,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(weekDays.length, (index) {
                        final day = weekDays[index];
                        final parts = day.split('§');
                        final dayName = parts.isNotEmpty ? parts[0] : '';
                        final dayNumber =
                            parts.length > 1 ? parts[1] : '';
                        final monthName =
                            parts.length > 2 ? parts[2] : '';
                        final income =
                            index < incomeData.length ? incomeData[index] : 0.0;
                        final expense = index < expenseData.length
                            ? expenseData[index]
                            : 0.0;
                        final incomeH =
                            maxY <= 0 ? 0.0 : (income / maxY) * 150.0;
                        final expenseH =
                            maxY <= 0 ? 0.0 : (expense / maxY) * 150.0;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          width: 7,
                                          height: incomeH.clamp(0.0, 150.0),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF3B82F6),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4),
                                              topRight: Radius.circular(4),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        Container(
                                          width: 7,
                                          height: expenseH.clamp(0.0, 150.0),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF59E0B),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4),
                                              topRight: Radius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  dayName,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dayNumber,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                if (monthName.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    monthName,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: _canScrollRight
                        ? () => _shiftChartByOneDay(1)
                        : null,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _canScrollRight
                              ? Colors.black
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: _canScrollRight
                            ? Colors.black87
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(Map<String, dynamic> categories) {
    String amountOf(String key) {
      final raw = categories[key]?['amount'];
      final value = raw is num ? raw.toDouble() : 0.0;
      return "\$${_money.format(value)}";
    }

    String subtitleOf(String key, String fallback) {
      final raw = categories[key]?['subtitle']?.toString();
      if (raw == null || raw.isEmpty) return fallback;
      return raw;
    }

    return Column(
      children: [
        _buildCategoryCard(
          title: "Fuel",
          titleColor: AppColors.fuel,
          amount: amountOf('Fuel'),
          subtitle: subtitleOf('Fuel', '0% of total expenses'),
          svgAsset: 'assets/icons/fuel_station.svg',
        ),
        const SizedBox(height: 12),
        _buildCategoryCard(
          title: "Maintenance",
          titleColor: AppColors.maintenance,
          amount: amountOf('Maintenance'),
          subtitle:
              subtitleOf('Maintenance', 'Scheduled & ad-hoc repairs'),
          svgAsset: 'assets/icons/maintenance_truck.svg',
        ),
        const SizedBox(height: 12),
        _buildCategoryCard(
          title: "Tolls",
          titleColor: AppColors.tolls,
          amount: amountOf('Tolls'),
          subtitle:
              subtitleOf('Tolls', 'Electronic pass transponders'),
          svgAsset: 'assets/icons/truck_tolls.svg',
        ),
        const SizedBox(height: 12),
        _buildCategoryCard(
          title: "Others",
          titleColor: AppColors.others,
          amount: amountOf('Others'),
          subtitle:
              subtitleOf('Others', 'Fleet & liability coverage'),
          svgAsset: 'assets/icons/others_cost.svg',
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String amount,
    required String subtitle,
    required String svgAsset,
    Color titleColor = AppColors.primaryColor,
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
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: titleColor,
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
*/










///
///
///todo:: updating for the internal refresh of report
///
///








import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';
import 'package:tag/feature/report/cubit/report_cubit.dart';
import 'package:tag/feature/report/model/report_data.dart';
import 'package:tag/shared/widget/immersive_safe_area.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => ReportScreenState();
}

class ReportScreenState extends State<ReportScreen> {
  /// true = This Month, false = This Week
  bool _isThisMonth = true;

  /// When true, calendar custom range is active (chip visible).
  bool _hasCustomRange = false;

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  bool _showCalendar = false;

  /// Active fetch window.
  late DateTime _activeStart;
  late DateTime _activeEnd;

  /// First day shown on the 7-day chart (arrows shift this by ±1 day).
  late DateTime _chartStart;

  /// Calendar draft range (before Apply).
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  /// Loaded daily rows keyed by yyyy-MM-dd.
  final Map<String, DailyReport> _dailyByDate = {};

  static final NumberFormat _money = NumberFormat('#,##0.00');
  static final DateFormat _rangeLabel = DateFormat('MMM d, yyyy');
  static final DateFormat _dayKey = DateFormat('yyyy-MM-dd');

  late final ReportCubit _reportCubit;
  bool _isSilentRefreshing = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _activeStart = DateTime(now.year, now.month, 1);
    _activeEnd = DateTime(now.year, now.month + 1, 0);
    _chartStart = _activeStart;

    _reportCubit = ReportCubit()..fetchThisMonth();
  }

  @override
  void dispose() {
    _reportCubit.close();
    super.dispose();
  }

  /// Silent refresh — no loading indicators.
  /// Follows the same pattern as HomeScreen's reloadSilently()
  Future<void> refreshDataSilently() async {
    if (_isSilentRefreshing || !mounted) return;
    _isSilentRefreshing = true;
    try {
      if (_hasCustomRange) {
        await _reportCubit.fetchRangeSilently(_activeStart, _activeEnd);
      } else if (_isThisMonth) {
        await _reportCubit.fetchThisMonthSilently();
      } else {
        await _reportCubit.fetchThisWeekSilently();
      }
    } finally {
      _isSilentRefreshing = false;
    }
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String _keyFor(DateTime d) => _dayKey.format(_dateOnly(d));

  void _setActiveRange(DateTime start, DateTime end) {
    final from = _dateOnly(start);
    final to = _dateOnly(end);
    if (from.isBefore(to) || from.isAtSameMomentAs(to)) {
      _activeStart = from;
      _activeEnd = to;
    } else {
      _activeStart = to;
      _activeEnd = from;
    }
  }

  void _ingestDaily(List<DailyReport> daily) {
    _dailyByDate
      ..clear()
      ..addEntries(
        daily.map((d) {
          // Normalize to date-only local key (yyyy-MM-dd).
          final key = _keyFor(d.date);
          return MapEntry(key, d);
        }),
      );

    // Keep / clamp chart window inside active range (never jump to wrong week).
    _chartStart = _clampChartStart(_dateOnly(_chartStart));
  }

  int get _rangeDayCount =>
      _activeEnd.difference(_activeStart).inDays + 1;

  /// Chart always shows up to 7 day slots.
  int get _windowDays {
    final span = _rangeDayCount;
    if (span <= 0) return 1;
    return span < 7 ? span : 7;
  }

  DateTime get _minChartStart => _activeStart;

  DateTime get _maxChartStart {
    final span = _rangeDayCount;
    if (span <= _windowDays) return _activeStart;
    return _activeEnd.subtract(Duration(days: _windowDays - 1));
  }

  DateTime _clampChartStart(DateTime value) {
    var v = _dateOnly(value);
    if (v.isBefore(_minChartStart)) return _minChartStart;
    if (v.isAfter(_maxChartStart)) return _maxChartStart;
    return v;
  }

  bool get _canScrollLeft => _chartStart.isAfter(_minChartStart);

  bool get _canScrollRight => _chartStart.isBefore(_maxChartStart);

  /// Exactly [_windowDays] consecutive calendar days starting at [_chartStart].
  List<DailyReport> get _visibleDays {
    final start = _dateOnly(_chartStart);
    return List.generate(_windowDays, (i) {
      final day = DateTime(start.year, start.month, start.day + i);
      if (day.isAfter(_activeEnd)) {
        return DailyReport(
          date: day,
          day: DailyReport.weekdayShort(day.weekday),
          income: 0,
          expenses: 0,
          profit: 0,
        );
      }
      return _dailyByDate[_keyFor(day)] ??
          DailyReport(
            date: day,
            day: DailyReport.weekdayShort(day.weekday),
            income: 0,
            expenses: 0,
            profit: 0,
          );
    });
  }

  /// Chart bottom label.
  /// Calendar range → weekday / date / month (3 lines).
  /// Otherwise → weekday / date.
  String _chartDayLabel(DateTime date) {
    final dayName = DailyReport.weekdayShort(date.weekday);
    final dayNumber = date.day.toString().padLeft(2, '0');
    if (_hasCustomRange) {
      final month = DateFormat('MMM').format(date).toUpperCase();
      return '$dayName§$dayNumber§$month';
    }
    return '$dayName§$dayNumber';
  }

  /// Chart ◀ / ▶ / swipe — scroll the 7-day window by 1 day.
  void _shiftChartByOneDay(int delta) {
    final next = _clampChartStart(
      _dateOnly(_chartStart).add(Duration(days: delta)),
    );
    if (next.isAtSameMomentAs(_dateOnly(_chartStart))) return;
    setState(() {
      _chartStart = next;
      _selectedDay = next;
      _focusedDay = next;
    });
  }

  void _onThisWeek() {
    final now = DateTime.now();
    final monday = _dateOnly(now).subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    setState(() {
      _isThisMonth = false;
      _hasCustomRange = false;
      _rangeStart = null;
      _rangeEnd = null;
      _setActiveRange(monday, sunday);
      _chartStart = monday;
      _selectedDay = monday;
      _focusedDay = monday;
    });
    _reportCubit.fetchThisWeek();
  }

  void _onThisMonth() {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, 1);
    final last = DateTime(now.year, now.month + 1, 0);
    setState(() {
      _isThisMonth = true;
      _hasCustomRange = false;
      _rangeStart = null;
      _rangeEnd = null;
      _setActiveRange(first, last);
      // Chart starts on the 1st so days 1–7 line up exactly.
      _chartStart = first;
      _selectedDay = first;
      _focusedDay = first;
    });
    _reportCubit.fetchThisMonth();
  }

  void _clearCustomRange() {
    if (_isThisMonth) {
      _onThisMonth();
    } else {
      _onThisWeek();
    }
  }

  void _openCalendar() {
    setState(() {
      _showCalendar = true;
      // Fresh pick — start empty so first tap = start, second = end.
      _rangeStart = null;
      _rangeEnd = null;
      _focusedDay = _dateOnly(_selectedDay);
    });
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _rangeStart = start == null ? null : _dateOnly(start);
      _rangeEnd = end == null ? null : _dateOnly(end);
      _focusedDay = _dateOnly(focusedDay);
      if (_rangeStart != null) {
        _selectedDay = _rangeStart!;
      }
    });
  }

  void _applyDateRange() {
    final start = _rangeStart;
    if (start == null) return;

    final end = _rangeEnd ?? start;
    final from = start.isBefore(end) ? start : end;
    final to = start.isBefore(end) ? end : start;

    setState(() {
      _showCalendar = false;
      _hasCustomRange = true;
      _setActiveRange(from, to);
      // Keep selection chip dates (range) — scrolling won't overwrite these.
      _rangeStart = _activeStart;
      _rangeEnd = _activeEnd;
      _chartStart = _activeStart;
      _selectedDay = _activeStart;
      _focusedDay = _activeStart;
    });
    _reportCubit.fetchRange(_activeStart, _activeEnd);
  }

  Map<String, dynamic> _categoriesFrom(ReportSummary summary) {
    const defaults = {
      'Fuel': {
        'amount': 0.0,
        'subtitle': 'Scheduled fuel spend',
      },
      'Maintenance': {
        'amount': 0.0,
        'subtitle': 'Scheduled & ad-hoc repairs',
      },
      'Tolls': {
        'amount': 0.0,
        'subtitle': 'Electronic pass transponders',
      },
      'Others': {
        'amount': 0.0,
        'subtitle': 'Fleet & liability coverage',
      },
    };

    final amounts = <String, double>{
      for (final key in defaults.keys) key: 0.0,
    };

    // Sum amounts per UI category (multiple API rows can map to one card).
    for (final item in summary.expenseBreakdown) {
      final key = _mapCategoryKey(item.name);
      amounts[key] = (amounts[key] ?? 0) + item.amount;
    }

    final breakdownTotal =
    amounts.values.fold<double>(0, (sum, v) => sum + v);
    // Prefer summary total; if Fuel alone exceeds it, use breakdown sum
    // so percentages stay within 0–100.
    var base = summary.totalExpenses;
    if (base <= 0 || (breakdownTotal > 0 && breakdownTotal > base + 0.01)) {
      base = breakdownTotal;
    }

    final result = <String, dynamic>{};
    for (final key in defaults.keys) {
      final amount = amounts[key] ?? 0.0;
      final pct = base > 0 ? ((amount / base) * 100).clamp(0.0, 100.0) : 0.0;
      final defaultSubtitle = defaults[key]!['subtitle'] as String;
      result[key] = {
        'amount': amount,
        'subtitle': amount > 0
            ? '${pct.toStringAsFixed(0)}% of total expenses'
            : defaultSubtitle,
      };
    }

    return result;
  }

  String _mapCategoryKey(String raw) {
    final n = raw.trim().toLowerCase();
    if (n.contains('fuel')) return 'Fuel';
    if (n.contains('maint')) return 'Maintenance';
    if (n.contains('toll')) return 'Tolls';
    if (n.contains('other')) return 'Others';
    return 'Others';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _reportCubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F9),
        body: ImmersiveSafeArea(
          child: Stack(
            children: [
              BlocConsumer<ReportCubit, ReportState>(
                listener: (context, state) {
                  if (state is ReportSuccess) {
                    setState(() => _ingestDaily(state.data.dailyReports));
                  }
                },
                builder: (context, state) {
                  if (state is ReportLoading || state is ReportInitial) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: _buildToggleHeader(),
                        ),
                        const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  if (state is ReportFailure) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: _buildToggleHeader(),
                        ),
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    state.errorMessage,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: () {
                                      if (_hasCustomRange) {
                                        _reportCubit.fetchRange(
                                          _activeStart,
                                          _activeEnd,
                                        );
                                      } else if (_isThisMonth) {
                                        _reportCubit.fetchThisMonth();
                                      } else {
                                        _reportCubit.fetchThisWeek();
                                      }
                                    },
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  final data = (state as ReportSuccess).data;
                  final week = _visibleDays;
                  final weekDays = week
                      .map((d) => _chartDayLabel(d.date))
                      .toList(growable: false);
                  final incomeData =
                  week.map((d) => d.income).toList(growable: false);
                  final expenseData =
                  week.map((d) => d.expenses).toList(growable: false);
                  // Full selected range profit (month/week/custom) — not just 7 chart days.
                  final totalProfit = data.summary.totalProfit;
                  final growth = data.trend.isPositive
                      ? data.trend.percentage.abs()
                      : -data.trend.percentage.abs();
                  final categories = _categoriesFrom(data.summary);

                  return SingleChildScrollView(
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
                  );
                },
              ),
              if (_showCalendar)
                Material(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: SafeArea(
                    child: Center(
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
                                  const Text(
                                    "Select Date Range",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => setState(
                                          () => _showCalendar = false,
                                    ),
                                    icon: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _rangeStart == null
                                      ? 'Tap a start date, then an end date'
                                      : _rangeEnd == null
                                      ? 'Start: ${_rangeLabel.format(_rangeStart!)}  ·  tap end date'
                                      : '${_rangeLabel.format(_rangeStart!)}  →  ${_rangeLabel.format(_rangeEnd!)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 400,
                                child: TableCalendar(
                                  firstDay: DateTime(2020, 1, 1),
                                  lastDay: DateTime(2035, 12, 31),
                                  focusedDay: _focusedDay.isBefore(
                                      DateTime(2020, 1, 1))
                                      ? DateTime(2020, 1, 1)
                                      : _focusedDay.isAfter(DateTime(2035, 12, 31))
                                      ? DateTime(2035, 12, 31)
                                      : _focusedDay,
                                  rangeStartDay: _rangeStart,
                                  rangeEndDay: _rangeEnd,
                                  rangeSelectionMode:
                                  RangeSelectionMode.toggledOn,
                                  onRangeSelected: _onRangeSelected,
                                  onPageChanged: (focused) {
                                    setState(
                                          () => _focusedDay = _dateOnly(focused),
                                    );
                                  },
                                  headerStyle: const HeaderStyle(
                                    formatButtonVisible: false,
                                    titleCentered: true,
                                  ),
                                  daysOfWeekStyle: const DaysOfWeekStyle(
                                    weekdayStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    weekendStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                  calendarStyle: CalendarStyle(
                                    outsideDaysVisible: false,
                                    weekendTextStyle: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    todayDecoration: BoxDecoration(
                                      color: const Color(0xFF1E3A5F)
                                          .withValues(alpha: 0.25),
                                      shape: BoxShape.circle,
                                    ),
                                    selectedDecoration: const BoxDecoration(
                                      color: Color(0xFF1E3A5F),
                                      shape: BoxShape.circle,
                                    ),
                                    rangeStartDecoration: const BoxDecoration(
                                      color: Color(0xFF1E3A5F),
                                      shape: BoxShape.circle,
                                    ),
                                    rangeEndDecoration: const BoxDecoration(
                                      color: Color(0xFF1E3A5F),
                                      shape: BoxShape.circle,
                                    ),
                                    rangeHighlightColor: const Color(0xFF1E3A5F)
                                        .withValues(alpha: 0.15),
                                    withinRangeTextStyle: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                    selectedTextStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  availableGestures: AvailableGestures.all,
                                  startingDayOfWeek: StartingDayOfWeek.monday,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _rangeStart == null
                                      ? null
                                      : _applyDateRange,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E3A5F),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                    Colors.grey.shade300,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Apply',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E9EF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _onThisWeek,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isThisMonth && !_hasCustomRange
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "This Week",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: !_isThisMonth && !_hasCustomRange
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _onThisMonth,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isThisMonth && !_hasCustomRange
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "This Month",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _isThisMonth && !_hasCustomRange
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _openCalendar,
                icon: SvgPicture.asset(
                  'assets/icons/calendar.svg',
                  width: 22,
                  height: 22,
                ),
              ),
            ],
          ),
        ),
        if (_hasCustomRange) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E9EF)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.date_range,
                  size: 18,
                  color: Color(0xFF1E3A5F),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _activeStart.isAtSameMomentAs(_activeEnd)
                        ? _rangeLabel.format(_activeStart)
                        : '${_rangeLabel.format(_activeStart)}  →  ${_rangeLabel.format(_activeEnd)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _clearCustomRange,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E9EF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInsightCard({
    required List<String> weekDays,
    required List<double> incomeData,
    required List<double> expenseData,
    required double totalProfit,
    required double growth,
  }) {
    final isPositiveGrowth = growth >= 0;
    final growthColor =
    isPositiveGrowth ? Colors.green.shade600 : Colors.red.shade600;
    final growthIcon =
    isPositiveGrowth ? Icons.trending_up : Icons.trending_down;

    final profitColor =
    totalProfit >= 0 ? Colors.black87 : Colors.red.shade600;

    // Dynamic chart scale (same look as before, real API values).
    double maxY = 1;
    for (final v in [...incomeData, ...expenseData]) {
      if (v > maxY) maxY = v;
    }
    maxY = maxY <= 0 ? 1 : maxY * 1.25;

    // Silence unused (growth UI remains commented as in original design).
    // ignore: unused_local_variable
    final _ = (growthColor, growthIcon);

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
          Text(
            "Profit Insight",
            style: AppTextStyle.SFProDisplay_Regular.copyWith(
              color: AppColors.textGreyColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                totalProfit >= 0
                    ? "\$${_money.format(totalProfit)}"
                    : "-\$${_money.format(totalProfit.abs())}",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: profitColor,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragEnd: (details) {
              final v = details.primaryVelocity ?? 0;
              if (v < -200) {
                _shiftChartByOneDay(1);
              } else if (v > 200) {
                _shiftChartByOneDay(-1);
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: _canScrollLeft
                        ? () => _shiftChartByOneDay(-1)
                        : null,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _canScrollLeft
                              ? Colors.black
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        size: 18,
                        color: _canScrollLeft
                            ? Colors.black87
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // One column per calendar day → bar sits exactly on its date.
                Expanded(
                  child: SizedBox(
                    height: 220,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(weekDays.length, (index) {
                        final day = weekDays[index];
                        final parts = day.split('§');
                        final dayName = parts.isNotEmpty ? parts[0] : '';
                        final dayNumber =
                        parts.length > 1 ? parts[1] : '';
                        final monthName =
                        parts.length > 2 ? parts[2] : '';
                        final income =
                        index < incomeData.length ? incomeData[index] : 0.0;
                        final expense = index < expenseData.length
                            ? expenseData[index]
                            : 0.0;
                        final incomeH =
                        maxY <= 0 ? 0.0 : (income / maxY) * 150.0;
                        final expenseH =
                        maxY <= 0 ? 0.0 : (expense / maxY) * 150.0;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          width: 7,
                                          height: incomeH.clamp(0.0, 150.0),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF3B82F6),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4),
                                              topRight: Radius.circular(4),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        Container(
                                          width: 7,
                                          height: expenseH.clamp(0.0, 150.0),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF59E0B),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4),
                                              topRight: Radius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  dayName,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dayNumber,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                if (monthName.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    monthName,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: _canScrollRight
                        ? () => _shiftChartByOneDay(1)
                        : null,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _canScrollRight
                              ? Colors.black
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: _canScrollRight
                            ? Colors.black87
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(Map<String, dynamic> categories) {
    String amountOf(String key) {
      final raw = categories[key]?['amount'];
      final value = raw is num ? raw.toDouble() : 0.0;
      return "\$${_money.format(value)}";
    }

    String subtitleOf(String key, String fallback) {
      final raw = categories[key]?['subtitle']?.toString();
      if (raw == null || raw.isEmpty) return fallback;
      return raw;
    }

    return Column(
      children: [
        _buildCategoryCard(
          title: "Fuel",
          titleColor: AppColors.fuel,
          amount: amountOf('Fuel'),
          subtitle: subtitleOf('Fuel', '0% of total expenses'),
          svgAsset: 'assets/icons/fuel_station.svg',
        ),
        const SizedBox(height: 12),
        _buildCategoryCard(
          title: "Maintenance",
          titleColor: AppColors.maintenance,
          amount: amountOf('Maintenance'),
          subtitle:
          subtitleOf('Maintenance', 'Scheduled & ad-hoc repairs'),
          svgAsset: 'assets/icons/maintenance_truck.svg',
        ),
        const SizedBox(height: 12),
        _buildCategoryCard(
          title: "Tolls",
          titleColor: AppColors.tolls,
          amount: amountOf('Tolls'),
          subtitle:
          subtitleOf('Tolls', 'Electronic pass transponders'),
          svgAsset: 'assets/icons/truck_tolls.svg',
        ),
        const SizedBox(height: 12),
        _buildCategoryCard(
          title: "Others",
          titleColor: AppColors.others,
          amount: amountOf('Others'),
          subtitle:
          subtitleOf('Others', 'Fleet & liability coverage'),
          svgAsset: 'assets/icons/others_cost.svg',
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String amount,
    required String subtitle,
    required String svgAsset,
    Color titleColor = AppColors.primaryColor,
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
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: titleColor,
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