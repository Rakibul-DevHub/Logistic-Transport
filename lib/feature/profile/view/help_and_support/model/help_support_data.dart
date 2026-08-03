class HelpSupportResponse {
  final int? code;
  final HelpSupportData? data;

  const HelpSupportResponse({this.code, this.data});

  factory HelpSupportResponse.fromJson(Map<String, dynamic> json) {
    return HelpSupportResponse(
      code: json['code'] is int
          ? json['code'] as int
          : int.tryParse('${json['code']}'),
      data: json['data'] is Map<String, dynamic>
          ? HelpSupportData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class HelpSupportData {
  final String id;
  final String key;
  final String details;
  final String phone;
  final String email;

  const HelpSupportData({
    required this.id,
    required this.key,
    required this.details,
    required this.phone,
    required this.email,
  });

  factory HelpSupportData.empty() => const HelpSupportData(
        id: '',
        key: '',
        details: '',
        phone: '',
        email: '',
      );

  factory HelpSupportData.fromJson(Map<String, dynamic> json) {
    final value = json['value'];
    Map<String, dynamic> valueMap = const {};
    if (value is Map<String, dynamic>) {
      valueMap = value;
    } else if (value is Map) {
      valueMap = Map<String, dynamic>.from(value);
    }

    return HelpSupportData(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      key: (json['key'] ?? '').toString(),
      details: (valueMap['details'] ?? '').toString(),
      phone: (valueMap['phone'] ?? '').toString(),
      email: (valueMap['email'] ?? '').toString(),
    );
  }
}
