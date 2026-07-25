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
}