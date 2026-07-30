/**
class OCRResponse {
  final int code;
  final String message;
  final OCRData? data;

  OCRResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory OCRResponse.fromJson(Map<String, dynamic> json) {
    return OCRResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? OCRData.fromJson(json['data']) : null,
    );
  }
}

class OCRData {
  final String userId;
  final String loadIdString;
  final String companyName;

  /// New API shape: multiple GeoJSON points + address strings
  final List<LocationData> pickupLocations;
  final List<String> pickupAddresses;
  final List<LocationData> deliveryLocations;
  final List<String> deliveryAddresses;

  final String pickupDate;
  final String bolImage;
  final bool isModified;
  final List<String> modifiedFields;
  final String id;
  final String createdAt;
  final String updatedAt;

  // Rate / charge fields (optional)
  final String? rate;
  final String? totalCharge;
  final String? price;
  final String? totalPrice;
  final String? value;

  OCRData({
    required this.userId,
    required this.loadIdString,
    required this.companyName,
    this.pickupLocations = const [],
    this.pickupAddresses = const [],
    this.deliveryLocations = const [],
    this.deliveryAddresses = const [],
    required this.pickupDate,
    required this.bolImage,
    required this.isModified,
    required this.modifiedFields,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.rate,
    this.totalCharge,
    this.price,
    this.totalPrice,
    this.value,
  });

  /// First pickup address (for single-field UI)
  String get pickupAddress =>
      pickupAddresses.isNotEmpty ? pickupAddresses.first : '';

  /// First delivery address (for single-field UI)
  String get deliveryAddress =>
      deliveryAddresses.isNotEmpty ? deliveryAddresses.first : '';

  /// First pickup GeoJSON point
  LocationData? get pickupLocation =>
      pickupLocations.isNotEmpty ? pickupLocations.first : null;

  /// First delivery GeoJSON point
  LocationData? get deliveryLocation =>
      deliveryLocations.isNotEmpty ? deliveryLocations.first : null;

  /// First pickup [lng, lat]
  List<double>? get firstPickupCoordinates {
    final coords = pickupLocation?.coordinates;
    if (coords == null || coords.length < 2) return null;
    return coords;
  }

  /// First delivery [lng, lat]
  List<double>? get firstDeliveryCoordinates {
    final coords = deliveryLocation?.coordinates;
    if (coords == null || coords.length < 2) return null;
    return coords;
  }

  /// All pickup coords [lng, lat]
  List<List<double>> get allPickupCoordinates => pickupLocations
      .map((e) => e.coordinates)
      .where((c) => c.length >= 2)
      .toList();

  /// All delivery coords [lng, lat]
  List<List<double>> get allDeliveryCoordinates => deliveryLocations
      .map((e) => e.coordinates)
      .where((c) => c.length >= 2)
      .toList();

  factory OCRData.fromJson(Map<String, dynamic> json) {
    final pickupLocations = _parseLocations(
      json['pickupLocations'] ?? json['pickupLocation'],
    );
    final deliveryLocations = _parseLocations(
      json['deliveryLocations'] ?? json['deliveryLocation'],
    );
    final pickupAddresses = _parseAddresses(
      json['pickupAddresses'] ?? json['pickupAddress'],
    );
    final deliveryAddresses = _parseAddresses(
      json['deliveryAddresses'] ?? json['deliveryAddress'],
    );

    return OCRData(
      userId: json['userId']?.toString() ?? '',
      loadIdString: json['loadIdString']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      pickupLocations: pickupLocations,
      pickupAddresses: pickupAddresses,
      deliveryLocations: deliveryLocations,
      deliveryAddresses: deliveryAddresses,
      pickupDate: json['pickupDate']?.toString() ?? '',
      bolImage: json['bolImage']?.toString() ?? '',
      isModified: json['isModified'] == true,
      modifiedFields: List<String>.from(json['modifiedFields'] ?? const []),
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      rate: json['rate']?.toString() ??
          json['charge']?.toString() ??
          json['price']?.toString(),
      totalCharge:
          json['totalCharge']?.toString() ?? json['totalPrice']?.toString(),
      price: json['price']?.toString(),
      totalPrice: json['totalPrice']?.toString(),
      value: json['value']?.toString(),
    );
  }

  /// Accepts a single GeoJSON map OR a list of maps.
  static List<LocationData> _parseLocations(dynamic raw) {
    if (raw == null) return const [];

    if (raw is Map) {
      return [LocationData.fromJson(Map<String, dynamic>.from(raw))];
    }

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => LocationData.fromJson(Map<String, dynamic>.from(e)))
          .where((e) => e.coordinates.length >= 2)
          .toList();
    }

    return const [];
  }

  /// Accepts a single string OR a list of strings.
  static List<String> _parseAddresses(dynamic raw) {
    if (raw == null) return const [];

    if (raw is String) {
      final text = raw.trim();
      return text.isEmpty ? const [] : [text];
    }

    if (raw is List) {
      return raw
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return const [];
  }

  /// Display date as MM/dd/yyyy
  String get formattedPickupDate {
    if (pickupDate.isEmpty) return '';
    try {
      final date = DateTime.parse(pickupDate).toLocal();
      return '${date.month.toString().padLeft(2, '0')}/'
          '${date.day.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return pickupDate;
    }
  }

  String get companyInitials {
    if (companyName.isEmpty) return '';
    final parts = companyName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return companyName.substring(0, companyName.length >= 2 ? 2 : 1).toUpperCase();
  }
}

/// GeoJSON Point: coordinates are [lng, lat]
class LocationData {
  final String type;
  final List<double> coordinates;

  LocationData({
    required this.type,
    required this.coordinates,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    final rawCoords = json['coordinates'];
    final coords = <double>[];

    if (rawCoords is List) {
      for (final item in rawCoords) {
        if (item is num) {
          coords.add(item.toDouble());
        } else {
          final parsed = double.tryParse(item?.toString() ?? '');
          if (parsed != null) coords.add(parsed);
        }
      }
    }

    return LocationData(
      type: json['type']?.toString() ?? 'Point',
      coordinates: coords,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  double? get lng => coordinates.length >= 2 ? coordinates[0] : null;
  double? get lat => coordinates.length >= 2 ? coordinates[1] : null;
}
*/











class OCRResponse {
  final int code;
  final String message;
  final OCRData? data;

  OCRResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory OCRResponse.fromJson(Map<String, dynamic> json) {
    return OCRResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? OCRData.fromJson(json['data']) : null,
    );
  }
}

class OCRData {
  final String userId;
  final String loadIdString;
  final String companyName;

  final List<LocationData> pickupLocations;
  final List<String> pickupAddresses;
  final List<LocationData> deliveryLocations;
  final List<String> deliveryAddresses;

  final String pickupDate;
  final String bolImage;
  final bool isModified;
  final List<String> modifiedFields;
  final String id;
  final String createdAt;
  final String updatedAt;

  final String? rate;
  final String? totalCharge;
  final String? price;
  final String? totalPrice;
  final String? value;

  OCRData({
    required this.userId,
    required this.loadIdString,
    required this.companyName,
    this.pickupLocations = const [],
    this.pickupAddresses = const [],
    this.deliveryLocations = const [],
    this.deliveryAddresses = const [],
    required this.pickupDate,
    required this.bolImage,
    required this.isModified,
    required this.modifiedFields,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.rate,
    this.totalCharge,
    this.price,
    this.totalPrice,
    this.value,
  });

  String get pickupAddress =>
      pickupAddresses.isNotEmpty ? pickupAddresses.first : '';

  String get deliveryAddress =>
      deliveryAddresses.isNotEmpty ? deliveryAddresses.first : '';

  LocationData? get pickupLocation =>
      pickupLocations.isNotEmpty ? pickupLocations.first : null;

  LocationData? get deliveryLocation =>
      deliveryLocations.isNotEmpty ? deliveryLocations.first : null;

  List<double>? get firstPickupCoordinates {
    final coords = pickupLocation?.coordinates;
    if (coords == null || coords.length < 2) return null;
    return coords;
  }

  List<double>? get firstDeliveryCoordinates {
    final coords = deliveryLocation?.coordinates;
    if (coords == null || coords.length < 2) return null;
    return coords;
  }

  List<List<double>> get allPickupCoordinates => pickupLocations
      .map((e) => e.coordinates)
      .where((c) => c.length >= 2)
      .toList();

  List<List<double>> get allDeliveryCoordinates => deliveryLocations
      .map((e) => e.coordinates)
      .where((c) => c.length >= 2)
      .toList();

  factory OCRData.fromJson(Map<String, dynamic> json) {
    final pickupLocations = _parseLocations(
      json['pickupLocations'] ?? json['pickupLocation'],
    );
    final deliveryLocations = _parseLocations(
      json['deliveryLocations'] ?? json['deliveryLocation'],
    );
    final pickupAddresses = _parseAddresses(
      json['pickupAddresses'] ?? json['pickupAddress'],
    );
    final deliveryAddresses = _parseAddresses(
      json['deliveryAddresses'] ?? json['deliveryAddress'],
    );

    return OCRData(
      userId: json['userId']?.toString() ?? '',
      loadIdString: json['loadIdString']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      pickupLocations: pickupLocations,
      pickupAddresses: pickupAddresses,
      deliveryLocations: deliveryLocations,
      deliveryAddresses: deliveryAddresses,
      pickupDate: json['pickupDate']?.toString() ?? '',
      bolImage: json['bolImage']?.toString() ?? '',
      isModified: json['isModified'] == true,
      modifiedFields: List<String>.from(json['modifiedFields'] ?? const []),
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      rate: json['rate']?.toString() ??
          json['charge']?.toString() ??
          json['price']?.toString(),
      totalCharge:
      json['totalCharge']?.toString() ?? json['totalPrice']?.toString(),
      price: json['price']?.toString(),
      totalPrice: json['totalPrice']?.toString(),
      value: json['value']?.toString(),
    );
  }

  static List<LocationData> _parseLocations(dynamic raw) {
    if (raw == null) return const [];

    if (raw is Map) {
      return [LocationData.fromJson(Map<String, dynamic>.from(raw))];
    }

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => LocationData.fromJson(Map<String, dynamic>.from(e)))
          .where((e) => e.coordinates.length >= 2)
          .toList();
    }

    return const [];
  }

  static List<String> _parseAddresses(dynamic raw) {
    if (raw == null) return const [];

    if (raw is String) {
      final text = raw.trim();
      return text.isEmpty ? const [] : [text];
    }

    if (raw is List) {
      return raw
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return const [];
  }

  String get formattedPickupDate {
    if (pickupDate.isEmpty) return '';
    try {
      final date = DateTime.parse(pickupDate).toLocal();
      return '${date.month.toString().padLeft(2, '0')}/'
          '${date.day.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return pickupDate;
    }
  }

  String get companyInitials {
    if (companyName.isEmpty) return '';
    final parts = companyName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return companyName.substring(0, companyName.length >= 2 ? 2 : 1).toUpperCase();
  }
}

class LocationData {
  final String type;
  final List<double> coordinates; // [lng, lat]

  LocationData({
    required this.type,
    required this.coordinates,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    final rawCoords = json['coordinates'];
    final coords = <double>[];

    if (rawCoords is List) {
      for (final item in rawCoords) {
        if (item is num) {
          coords.add(item.toDouble());
        } else {
          final parsed = double.tryParse(item?.toString() ?? '');
          if (parsed != null) coords.add(parsed);
        }
      }
    }

    return LocationData(
      type: json['type']?.toString() ?? 'Point',
      coordinates: coords,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  double? get lng => coordinates.length >= 2 ? coordinates[0] : null;
  double? get lat => coordinates.length >= 2 ? coordinates[1] : null;
}
