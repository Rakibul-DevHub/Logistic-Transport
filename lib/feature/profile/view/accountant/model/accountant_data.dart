class AccountantResponse {
  final int code;
  final String? message;
  final AccountantData? data;

  AccountantResponse({
    required this.code,
    this.message,
    this.data,
  });

  factory AccountantResponse.fromJson(Map<String, dynamic> json) {
    return AccountantResponse(
      code: json['code'] ?? 0,
      message: json['message']?.toString(),
      data: json['data'] != null
          ? AccountantData.fromJson(
              Map<String, dynamic>.from(json['data'] as Map),
            )
          : null,
    );
  }
}

class AccountantData {
  final String id;
  final String key;
  final String userId;
  final AccountantValue value;

  AccountantData({
    required this.id,
    required this.key,
    required this.userId,
    required this.value,
  });

  factory AccountantData.fromJson(Map<String, dynamic> json) {
    final rawValue = json['value'];
    return AccountantData(
      id: (json['_id'] ?? '').toString(),
      key: (json['key'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      value: rawValue is Map
          ? AccountantValue.fromJson(Map<String, dynamic>.from(rawValue))
          : AccountantValue(name: '', email: ''),
    );
  }
}

class AccountantValue {
  final String name;
  final String email;

  AccountantValue({
    required this.name,
    required this.email,
  });

  factory AccountantValue.fromJson(Map<String, dynamic> json) {
    return AccountantValue(
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }
}

class SendReportAccountantResponse {
  final int code;
  final String? message;
  final String? sentTo;

  SendReportAccountantResponse({
    required this.code,
    this.message,
    this.sentTo,
  });

  factory SendReportAccountantResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return SendReportAccountantResponse(
      code: json['code'] ?? 0,
      message: json['message']?.toString(),
      sentTo: data is Map ? data['sentTo']?.toString() : null,
    );
  }
}
