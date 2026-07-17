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
  final LocationData? pickupLocation;
  final String pickupAddress;
  final LocationData? deliveryLocation;
  final String deliveryAddress;
  final String pickupDate;
  final String bolImage;
  final bool isModified;
  final List<String> modifiedFields;
  final String id;
  final String createdAt;
  final String updatedAt;

  // ✅ Rate/charge fields
  final String? rate;
  final String? totalCharge;
  final String? price;
  final String? totalPrice;
  final String? value;

  OCRData({
    required this.userId,
    required this.loadIdString,
    required this.companyName,
    this.pickupLocation,
    required this.pickupAddress,
    this.deliveryLocation,
    required this.deliveryAddress,
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

  factory OCRData.fromJson(Map<String, dynamic> json) {
    return OCRData(
      userId: json['userId'] ?? '',
      loadIdString: json['loadIdString'] ?? '',
      companyName: json['companyName'] ?? '',
      pickupLocation: json['pickupLocation'] != null
          ? LocationData.fromJson(json['pickupLocation'])
          : null,
      pickupAddress: json['pickupAddress'] ?? '',
      deliveryLocation: json['deliveryLocation'] != null
          ? LocationData.fromJson(json['deliveryLocation'])
          : null,
      deliveryAddress: json['deliveryAddress'] ?? '',
      pickupDate: json['pickupDate'] ?? '',
      bolImage: json['bolImage'] ?? '',
      isModified: json['isModified'] ?? false,
      modifiedFields: List<String>.from(json['modifiedFields'] ?? []),
      id: json['_id'] ?? json['id'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      rate: json['rate']?.toString() ?? json['charge']?.toString() ?? json['price']?.toString(),
      totalCharge: json['totalCharge']?.toString() ?? json['totalPrice']?.toString(),
      price: json['price']?.toString(),
      totalPrice: json['totalPrice']?.toString(),
      value: json['value']?.toString(),
    );
  }

  // ✅ Helper method to format pickup date (null safe)
  String get formattedPickupDate {
    if (pickupDate.isEmpty) return '';
    try {
      final date = DateTime.parse(pickupDate);
      return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return pickupDate;
    }
  }

  // Helper to get initials for company
  String get companyInitials {
    if (companyName.isEmpty) return '';
    final parts = companyName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return companyName.substring(0, 2).toUpperCase();
  }
}

class LocationData {
  final String type;
  final List<double> coordinates;

  LocationData({
    required this.type,
    required this.coordinates,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      type: json['type'] ?? '',
      coordinates: List<double>.from(json['coordinates'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}