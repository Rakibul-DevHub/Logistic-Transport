/**
class AddLoadResponse {
  final int? code;
  final String? message;
  final AddLoadData? data;

  AddLoadResponse({
    this.code,
    this.message,
    this.data,
  });

  factory AddLoadResponse.fromJson(Map<String, dynamic> json) {
    return AddLoadResponse(
      code: json['code'] as int?,
      message: json['message']?.toString(),
      data: json['data'] != null
          ? AddLoadData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AddLoadData {
  final String? id;
  final String? userId;
  final String? parentDriverId;
  final String? loadId;
  final String? companyName;
  final List<double>? pickupCoordinates;
  final List<double>? deliveryCoordinates;
  final String? pickupDate;
  final num? rate;
  final String? bolImage;
  final String? notes;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  AddLoadData({
    this.id,
    this.userId,
    this.parentDriverId,
    this.loadId,
    this.companyName,
    this.pickupCoordinates,
    this.deliveryCoordinates,
    this.pickupDate,
    this.rate,
    this.bolImage,
    this.notes,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory AddLoadData.fromJson(Map<String, dynamic> json) {
    List<double>? parseCoords(dynamic location) {
      if (location is Map && location['coordinates'] is List) {
        return (location['coordinates'] as List)
            .map((e) => (e as num).toDouble())
            .toList();
      }
      if (location is List) {
        return location.map((e) => (e as num).toDouble()).toList();
      }
      return null;
    }

    return AddLoadData(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      userId: json['userId']?.toString(),
      parentDriverId: json['parentDriverId']?.toString(),
      loadId: json['loadId']?.toString(),
      companyName: json['companyName']?.toString(),
      pickupCoordinates: parseCoords(json['pickupLocation'] ?? json['pickupCoordinates']),
      deliveryCoordinates:
      parseCoords(json['deliveryLocation'] ?? json['deliveryCoordinates']),
      pickupDate: json['pickupDate']?.toString(),
      rate: json['rate'] as num?,
      bolImage: json['bolImage']?.toString(),
      notes: json['notes']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}*/










class AddLoadResponse {
  final int? code;
  final String? message;
  final AddLoadData? data;

  AddLoadResponse({
    this.code,
    this.message,
    this.data,
  });

  factory AddLoadResponse.fromJson(Map<String, dynamic> json) {
    return AddLoadResponse(
      code: json['code'] as int?,
      message: json['message']?.toString(),
      data: json['data'] != null
          ? AddLoadData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AddLoadData {
  final String? id;
  final String? userId;
  final String? parentDriverId;
  final String? loadId;
  final String? companyName;
  final List<double>? pickupCoordinates;
  final List<double>? deliveryCoordinates;
  final String? pickupAddress;
  final String? deliveryAddress;
  final String? pickupDate;
  final num? rate;
  final String? bolImage;
  final String? notes;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  AddLoadData({
    this.id,
    this.userId,
    this.parentDriverId,
    this.loadId,
    this.companyName,
    this.pickupCoordinates,
    this.deliveryCoordinates,
    this.pickupAddress,
    this.deliveryAddress,
    this.pickupDate,
    this.rate,
    this.bolImage,
    this.notes,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory AddLoadData.fromJson(Map<String, dynamic> json) {
    List<double>? parseCoords(dynamic location) {
      if (location is Map && location['coordinates'] is List) {
        return (location['coordinates'] as List)
            .map((e) => (e as num).toDouble())
            .toList();
      }
      if (location is List) {
        return location.map((e) => (e as num).toDouble()).toList();
      }
      return null;
    }

    return AddLoadData(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      userId: json['userId']?.toString(),
      parentDriverId: json['parentDriverId']?.toString(),
      loadId: json['loadId']?.toString(),
      companyName: json['companyName']?.toString(),
      pickupCoordinates:
      parseCoords(json['pickupLocation'] ?? json['pickupCoordinates']),
      deliveryCoordinates:
      parseCoords(json['deliveryLocation'] ?? json['deliveryCoordinates']),
      pickupAddress: json['pickupAddress']?.toString(),
      deliveryAddress: json['deliveryAddress']?.toString(),
      pickupDate: json['pickupDate']?.toString(),
      rate: json['rate'] as num?,
      bolImage: json['bolImage']?.toString(),
      notes: json['notes']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}