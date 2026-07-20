class SettingsContentResponse {
  final int code;
  final SettingsContentData? data;

  SettingsContentResponse({
    required this.code,
    this.data,
  });

  factory SettingsContentResponse.fromJson(Map<String, dynamic> json) {
    return SettingsContentResponse(
      code: json['code'] ?? 0,
      data: json['data'] != null
          ? SettingsContentData.fromJson(json['data'])
          : null,
    );
  }
}

class SettingsContentData {
  final String id;
  final String key;
  final String value;

  SettingsContentData({
    required this.id,
    required this.key,
    required this.value,
  });

  factory SettingsContentData.fromJson(Map<String, dynamic> json) {
    return SettingsContentData(
      id: json['_id'] ?? json['id'] ?? '',
      key: json['key'] ?? '',
      value: json['value'] ?? '',
    );
  }
}