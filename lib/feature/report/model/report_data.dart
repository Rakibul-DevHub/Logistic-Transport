class ReportResponse {
  final int? code;
  final String? message;
  final ReportData? data;

  const ReportResponse({
    this.code,
    this.message,
    this.data,
  });

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    return ReportResponse(
      code: json['code'] is int ? json['code'] as int : int.tryParse('${json['code']}'),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? ReportData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ReportData {
  final ReportSummary summary;
  final List<DailyReport> dailyReports;
  final ReportTrend trend;

  const ReportData({
    required this.summary,
    required this.dailyReports,
    required this.trend,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    final dailyRaw = json['dailyReports'];
    return ReportData(
      summary: json['summary'] is Map<String, dynamic>
          ? ReportSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : ReportSummary.empty(),
      dailyReports: dailyRaw is List
          ? dailyRaw
              .whereType<Map>()
              .map((e) => DailyReport.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      trend: json['trend'] is Map<String, dynamic>
          ? ReportTrend.fromJson(json['trend'] as Map<String, dynamic>)
          : ReportTrend.empty(),
    );
  }
}

class ReportSummary {
  final double totalIncome;
  final double totalExpenses;
  final double totalProfit;
  final double profitMargin;
  final List<ExpenseBreakdownItem> expenseBreakdown;

  const ReportSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalProfit,
    required this.profitMargin,
    required this.expenseBreakdown,
  });

  factory ReportSummary.empty() => const ReportSummary(
        totalIncome: 0,
        totalExpenses: 0,
        totalProfit: 0,
        profitMargin: 0,
        expenseBreakdown: [],
      );

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    final breakdownRaw = json['expenseBreakdown'];
    return ReportSummary(
      totalIncome: _toDouble(json['totalIncome']),
      totalExpenses: _toDouble(json['totalExpenses']),
      totalProfit: _toDouble(json['totalProfit']),
      profitMargin: _toDouble(json['profitMargin']),
      expenseBreakdown: breakdownRaw is List
          ? breakdownRaw
              .whereType<Map>()
              .map((e) =>
                  ExpenseBreakdownItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}

class ExpenseBreakdownItem {
  final String name;
  final double amount;
  final double? percentage;

  const ExpenseBreakdownItem({
    required this.name,
    required this.amount,
    this.percentage,
  });

  factory ExpenseBreakdownItem.fromJson(Map<String, dynamic> json) {
    final name = (json['category'] ??
            json['type'] ??
            json['name'] ??
            json['label'] ??
            'Others')
        .toString();
    return ExpenseBreakdownItem(
      name: name,
      amount: _toDouble(json['amount'] ?? json['total'] ?? json['value']),
      percentage: json['percentage'] != null || json['percent'] != null
          ? _toDouble(json['percentage'] ?? json['percent'])
          : null,
    );
  }
}

class DailyReport {
  final DateTime date;
  final String day;
  final double income;
  final double expenses;
  final double profit;

  const DailyReport({
    required this.date,
    required this.day,
    required this.income,
    required this.expenses,
    required this.profit,
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date']?.toString() ?? '';
    DateTime parsed;
    try {
      parsed = DateTime.parse(rawDate);
    } catch (_) {
      parsed = DateTime.now();
    }
    return DailyReport(
      date: DateTime(parsed.year, parsed.month, parsed.day),
      day: (json['day'] ?? '').toString().toUpperCase(),
      income: _toDouble(json['income']),
      expenses: _toDouble(json['expenses']),
      profit: _toDouble(json['profit']),
    );
  }

  String get chartLabel {
    // Always derive from calendar date so labels never drift from bars.
    final dayName = weekdayShort(date.weekday);
    final dayNumber = date.day.toString().padLeft(2, '0');
    return '$dayName $dayNumber';
  }

  static String weekdayShort(int weekday) {
    const names = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    if (weekday < 1 || weekday > 7) return 'MON';
    return names[weekday - 1];
  }
}

class ReportTrend {
  final double percentage;
  final bool isPositive;

  const ReportTrend({
    required this.percentage,
    required this.isPositive,
  });

  factory ReportTrend.empty() =>
      const ReportTrend(percentage: 0, isPositive: true);

  factory ReportTrend.fromJson(Map<String, dynamic> json) {
    return ReportTrend(
      percentage: _toDouble(json['percentage']),
      isPositive: json['isPositive'] == true ||
          json['isPositive']?.toString().toLowerCase() == 'true',
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}
