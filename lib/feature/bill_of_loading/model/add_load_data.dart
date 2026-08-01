/**

class AddLoadData {
  final String? id;
  final String? userId;
  final String? parentDriverId;
  final String? loadId;
  final String? companyName;
  final List<List<double>>? pickupCoordinates; // Changed to List of List
  final List<List<double>>? deliveryCoordinates; // Changed to List of List
  final List<String>? pickupAddresses; // Changed to List
  final List<String>? deliveryAddresses; // Changed to List
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
    this.pickupAddresses,
    this.deliveryAddresses,
    this.pickupDate,
    this.rate,
    this.bolImage,
    this.notes,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory AddLoadData.fromJson(Map<String, dynamic> json) {
    List<List<double>>? parseCoordsList(dynamic locationData) {
      if (locationData is List) {
        // Check if it's a list of coordinates or list of locations
        if (locationData.isNotEmpty) {
          // If first element is a Map with coordinates
          if (locationData.first is Map) {
            return locationData.map((item) {
              if (item is Map && item['coordinates'] is List) {
                return (item['coordinates'] as List)
                    .map((e) => (e as num).toDouble())
                    .toList();
              }
              return <double>[];
            }).where((list) => list.isNotEmpty).toList();
          }
          // If first element is a List (coordinates)
          else if (locationData.first is List) {
            return locationData
                .map((item) => (item as List)
                .map((e) => (e as num).toDouble())
                .toList())
                .toList();
          }
        }
      }
      return null;
    }

    List<String>? parseAddresses(dynamic addressData) {
      if (addressData is List) {
        return addressData.map((e) => e.toString()).toList();
      }
      return null;
    }

    return AddLoadData(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      userId: json['userId']?.toString(),
      parentDriverId: json['parentDriverId']?.toString(),
      loadId: json['loadId']?.toString(),
      companyName: json['companyName']?.toString(),
      pickupCoordinates: parseCoordsList(json['pickupLocations'] ?? json['pickupCoordinates']),
      deliveryCoordinates: parseCoordsList(json['deliveryLocations'] ?? json['deliveryCoordinates']),
      pickupAddresses: parseAddresses(json['pickupAddresses']) ??
          (json['pickupAddress'] != null ? [json['pickupAddress'].toString()] : null),
      deliveryAddresses: parseAddresses(json['deliveryAddresses']) ??
          (json['deliveryAddress'] != null ? [json['deliveryAddress'].toString()] : null),
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







///
///
///
/// todo;; updating hte model and design
///
///
///



class AddLoadData {
  final String? id;
  final String? userId;
  final String? parentDriverId;
  final String? loadId;
  final String? companyName;
  final String? driverName;
  final List<List<double>>? pickupCoordinates;
  final List<List<double>>? deliveryCoordinates;
  final List<String>? pickupAddresses;
  final List<String>? deliveryAddresses;
  final String? pickupDate;
  final String? deliveryDate;
  final num? rate;
  final String? bolImage;
  final String? notes;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final List<String>? missingBolImages;
  final List<String>? podImages;

  AddLoadData({
    this.id,
    this.userId,
    this.parentDriverId,
    this.loadId,
    this.companyName,
    this.driverName,
    this.pickupCoordinates,
    this.deliveryCoordinates,
    this.pickupAddresses,
    this.deliveryAddresses,
    this.pickupDate,
    this.deliveryDate,
    this.rate,
    this.bolImage,
    this.notes,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.missingBolImages,
    this.podImages,
  });

  factory AddLoadData.fromJson(Map<String, dynamic> json) {
    // Parse pickup locations
    List<List<double>>? parsePickupCoords(dynamic locationData) {
      if (locationData is List) {
        final coords = <List<double>>[];
        for (var item in locationData) {
          if (item is Map && item['coordinates'] is List) {
            final coordList = (item['coordinates'] as List)
                .map((e) => (e as num).toDouble())
                .toList();
            if (coordList.length >= 2) {
              coords.add(coordList);
            }
          } else if (item is List) {
            final coordList = item.map((e) => (e as num).toDouble()).toList();
            if (coordList.length >= 2) {
              coords.add(coordList);
            }
          }
        }
        return coords.isNotEmpty ? coords : null;
      }
      return null;
    }

    // Parse delivery locations
    List<List<double>>? parseDeliveryCoords(dynamic locationData) {
      if (locationData is List) {
        final coords = <List<double>>[];
        for (var item in locationData) {
          if (item is Map && item['coordinates'] is List) {
            final coordList = (item['coordinates'] as List)
                .map((e) => (e as num).toDouble())
                .toList();
            if (coordList.length >= 2) {
              coords.add(coordList);
            }
          } else if (item is List) {
            final coordList = item.map((e) => (e as num).toDouble()).toList();
            if (coordList.length >= 2) {
              coords.add(coordList);
            }
          }
        }
        return coords.isNotEmpty ? coords : null;
      }
      return null;
    }

    // Parse addresses
    List<String>? parseAddresses(dynamic addressData) {
      if (addressData is List) {
        final addresses = addressData
            .map((e) => e?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
        return addresses.isNotEmpty ? addresses : null;
      }
      if (addressData is String && addressData.isNotEmpty) {
        return [addressData];
      }
      return null;
    }

    // Try to get pickup coordinates from pickupLocations or pickupCoordinates
    List<List<double>>? pickupCoords;
    if (json['pickupLocations'] != null) {
      pickupCoords = parsePickupCoords(json['pickupLocations']);
    } else if (json['pickupCoordinates'] != null) {
      final coords = json['pickupCoordinates'];
      if (coords is List) {
        pickupCoords = coords
            .map((e) => (e as List).map((c) => (c as num).toDouble()).toList())
            .toList();
      }
    }

    // Try to get delivery coordinates from deliveryLocations or deliveryCoordinates
    List<List<double>>? deliveryCoords;
    if (json['deliveryLocations'] != null) {
      deliveryCoords = parseDeliveryCoords(json['deliveryLocations']);
    } else if (json['deliveryCoordinates'] != null) {
      final coords = json['deliveryCoordinates'];
      if (coords is List) {
        deliveryCoords = coords
            .map((e) => (e as List).map((c) => (c as num).toDouble()).toList())
            .toList();
      }
    }

    // Get addresses
    List<String>? pickupAddrs;
    if (json['pickupAddresses'] != null) {
      pickupAddrs = parseAddresses(json['pickupAddresses']);
    } else if (json['pickupAddress'] != null) {
      pickupAddrs = [json['pickupAddress'].toString()];
    }

    List<String>? deliveryAddrs;
    if (json['deliveryAddresses'] != null) {
      deliveryAddrs = parseAddresses(json['deliveryAddresses']);
    } else if (json['deliveryAddress'] != null) {
      deliveryAddrs = [json['deliveryAddress'].toString()];
    }

    String? nestedName(dynamic value) {
      if (value is Map) {
        final name = value['name'] ?? value['fullName'] ?? value['userName'];
        if (name != null && name.toString().trim().isNotEmpty) {
          return name.toString().trim();
        }
      }
      return null;
    }

    final parsedDriverName = json['driverName']?.toString().trim().isNotEmpty == true
            ? json['driverName'].toString().trim()
            : json['userName']?.toString().trim().isNotEmpty == true
                ? json['userName'].toString().trim()
                : nestedName(json['driver']) ??
                    nestedName(json['user']) ??
                    nestedName(json['assignedDriver']);

    return AddLoadData(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      userId: json['userId']?.toString(),
      parentDriverId: json['parentDriverId']?.toString(),
      loadId: json['loadId']?.toString(),
      companyName: json['companyName']?.toString(),
      driverName: parsedDriverName,
      pickupCoordinates: pickupCoords,
      deliveryCoordinates: deliveryCoords,
      pickupAddresses: pickupAddrs,
      deliveryAddresses: deliveryAddrs,
      pickupDate: json['pickupDate']?.toString(),
      deliveryDate: json['deliveryDate']?.toString() ??
          json['deliveredAt']?.toString() ??
          json['completedAt']?.toString(),
      rate: json['rate'] as num?,
      bolImage: json['bolImage']?.toString(),
      notes: json['notes']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      missingBolImages: (json['missingBolImages'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      podImages: (json['podImages'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  // Helper method to get single pickup address (for backward compatibility)
  String? get pickupAddress {
    if (pickupAddresses != null && pickupAddresses!.isNotEmpty) {
      return pickupAddresses!.first;
    }
    return null;
  }

  // Helper method to get single delivery address (for backward compatibility)
  String? get deliveryAddress {
    if (deliveryAddresses != null && deliveryAddresses!.isNotEmpty) {
      return deliveryAddresses!.first;
    }
    return null;
  }

  // Helper method to get single pickup coordinates (for backward compatibility)
  List<double>? get pickupCoordinate {
    if (pickupCoordinates != null && pickupCoordinates!.isNotEmpty) {
      return pickupCoordinates!.first;
    }
    return null;
  }

  // Helper method to get single delivery coordinates (for backward compatibility)
  List<double>? get deliveryCoordinate {
    if (deliveryCoordinates != null && deliveryCoordinates!.isNotEmpty) {
      return deliveryCoordinates!.first;
    }
    return null;
  }
}

// AddLoadResponse class
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