class AddLoadExpenseRequest {
  final String loadId;
  final String type;
  final double amount;
  final String date;
  final String? receipt;
  final String? notes;

  const AddLoadExpenseRequest({
    required this.loadId,
    required this.type,
    required this.amount,
    required this.date,
    this.receipt,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'loadId': loadId,
      'type': type,
      'amount': amount,
      'date': date,
      if (receipt != null && receipt!.isNotEmpty) 'receipt': receipt,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}

class LoadExpenseResponse {
  final int? code;
  final String? message;
  final LoadExpenseData? data;

  const LoadExpenseResponse({
    this.code,
    this.message,
    this.data,
  });

  factory LoadExpenseResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return LoadExpenseResponse(
      code: (json['code'] as num?)?.toInt(),
      message: json['message']?.toString(),
      data: rawData is Map<String, dynamic>
          ? LoadExpenseData.fromJson(rawData)
          : rawData is Map
              ? LoadExpenseData.fromJson(
                  Map<String, dynamic>.from(rawData),
                )
              : null,
    );
  }
}

class LoadExpenseListResponse {
  final int? code;
  final String? message;
  final List<LoadExpenseData> data;

  const LoadExpenseListResponse({
    this.code,
    this.message,
    this.data = const [],
  });

  factory LoadExpenseListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final items = <LoadExpenseData>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          items.add(LoadExpenseData.fromJson(item));
        } else if (item is Map) {
          items.add(
            LoadExpenseData.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return LoadExpenseListResponse(
      code: (json['code'] as num?)?.toInt(),
      message: json['message']?.toString(),
      data: items,
    );
  }
}

class LoadExpenseData {
  final String? id;
  final String? loadId;
  final String? userId;
  final String? parentDriverId;
  final String? type;
  final double? amount;
  final String? date;
  final String? receipt;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  const LoadExpenseData({
    this.id,
    this.loadId,
    this.userId,
    this.parentDriverId,
    this.type,
    this.amount,
    this.date,
    this.receipt,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory LoadExpenseData.fromJson(Map<String, dynamic> json) {
    return LoadExpenseData(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      loadId: json['loadId']?.toString(),
      userId: json['userId']?.toString(),
      parentDriverId: json['parentDriverId']?.toString(),
      type: json['type']?.toString(),
      amount: (json['amount'] as num?)?.toDouble(),
      date: json['date']?.toString(),
      receipt: json['receipt']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loadId': loadId,
      'userId': userId,
      'parentDriverId': parentDriverId,
      'type': type,
      'amount': amount,
      'date': date,
      'receipt': receipt,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  String get typeLabel {
    final raw = (type ?? '').trim();
    if (raw.isEmpty) return 'Expense';
    return raw[0].toUpperCase() + raw.substring(1);
  }

  String get formattedAmount {
    final value = amount ?? 0;
    return '\$${value.toStringAsFixed(2)}';
  }

  String get formattedDate {
    final raw = date;
    if (raw == null || raw.isEmpty) return '—';
    try {
      final parsed = DateTime.parse(raw).toLocal();
      final m = parsed.month.toString().padLeft(2, '0');
      final d = parsed.day.toString().padLeft(2, '0');
      return '$m/$d/${parsed.year}';
    } catch (_) {
      return raw;
    }
  }
}

/// Navigation args: API needs mongo `_id`, UI shows human `loadId`
class ExpenseScreenArgs {
  /// Mongo ObjectId of the load (sent as `loadId` in create/get APIs)
  final String loadMongoId;

  /// Human-readable load id shown in the UI (e.g. 790980)
  final String displayLoadId;

  final double totalExpenses;

  const ExpenseScreenArgs({
    required this.loadMongoId,
    required this.displayLoadId,
    this.totalExpenses = 0.0,
  });
}
