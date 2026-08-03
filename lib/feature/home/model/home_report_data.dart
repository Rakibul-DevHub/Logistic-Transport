class HomeReportResponse {
  final int? code;
  final String? message;
  final HomeReportData? data;

  const HomeReportResponse({this.code, this.message, this.data});

  factory HomeReportResponse.fromJson(Map<String, dynamic> json) {
    return HomeReportResponse(
      code: json['code'] is int
          ? json['code'] as int
          : int.tryParse('${json['code']}'),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? HomeReportData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class HomeReportData {
  final HomeReportSummary summary;
  final HomeLoadStatusCounts loadStatusCounts;

  const HomeReportData({
    required this.summary,
    required this.loadStatusCounts,
  });

  factory HomeReportData.fromJson(Map<String, dynamic> json) {
    return HomeReportData(
      summary: json['summary'] is Map<String, dynamic>
          ? HomeReportSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : HomeReportSummary.empty(),
      loadStatusCounts: json['loadStatusCounts'] is Map<String, dynamic>
          ? HomeLoadStatusCounts.fromJson(
              json['loadStatusCounts'] as Map<String, dynamic>,
            )
          : HomeLoadStatusCounts.empty(),
    );
  }
}

class HomeReportSummary {
  final double totalIncome;
  final double totalExpenses;
  final double totalProfit;
  final double profitMargin;

  const HomeReportSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalProfit,
    required this.profitMargin,
  });

  factory HomeReportSummary.empty() => const HomeReportSummary(
        totalIncome: 0,
        totalExpenses: 0,
        totalProfit: 0,
        profitMargin: 0,
      );

  factory HomeReportSummary.fromJson(Map<String, dynamic> json) {
    return HomeReportSummary(
      totalIncome: _toDouble(json['totalIncome']),
      totalExpenses: _toDouble(json['totalExpenses']),
      totalProfit: _toDouble(json['totalProfit']),
      profitMargin: _toDouble(json['profitMargin']),
    );
  }
}

class HomeLoadStatusCounts {
  final int draft;
  final int pending;
  final int inTransit;
  final int delivered;
  final int cancelled;

  const HomeLoadStatusCounts({
    required this.draft,
    required this.pending,
    required this.inTransit,
    required this.delivered,
    required this.cancelled,
  });

  factory HomeLoadStatusCounts.empty() => const HomeLoadStatusCounts(
        draft: 0,
        pending: 0,
        inTransit: 0,
        delivered: 0,
        cancelled: 0,
      );

  factory HomeLoadStatusCounts.fromJson(Map<String, dynamic> json) {
    return HomeLoadStatusCounts(
      draft: _toInt(json['draft']),
      pending: _toInt(json['pending']),
      inTransit: _toInt(json['in_transit'] ?? json['inTransit']),
      delivered: _toInt(json['delivered']),
      cancelled: _toInt(json['cancelled']),
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}
