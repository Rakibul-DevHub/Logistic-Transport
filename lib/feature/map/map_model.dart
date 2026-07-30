enum MapMode {
  /// Drop a pin and confirm (Add Load pickup/delivery)
  pickLocation,

  /// Show pickup / delivery points (Load Details)
  viewRoute,

  /// Plain map browse
  browse,
}

class MapScreenArgs {
  final MapMode mode;
  final String title;

  /// For pickLocation
  final double? initialLat;
  final double? initialLng;

  /// For viewRoute: each item is [lng, lat]
  final List<List<double>>? pickupCoordinatesList;
  final List<List<double>>? deliveryCoordinatesList;
  final List<String>? pickupLabels;
  final List<String>? deliveryLabels;

  /// Legacy single-point fields (still accepted for older callers)
  final List<double>? pickupCoordinates;
  final List<double>? deliveryCoordinates;
  final String? pickupLabel;
  final String? deliveryLabel;

  const MapScreenArgs({
    required this.mode,
    this.title = 'Map',
    this.initialLat,
    this.initialLng,
    this.pickupCoordinatesList,
    this.deliveryCoordinatesList,
    this.pickupLabels,
    this.deliveryLabels,
    this.pickupCoordinates,
    this.deliveryCoordinates,
    this.pickupLabel,
    this.deliveryLabel,
  });

  List<List<double>> get resolvedPickupCoordinates {
    if (pickupCoordinatesList != null && pickupCoordinatesList!.isNotEmpty) {
      return pickupCoordinatesList!
          .where((c) => c.length >= 2)
          .toList();
    }
    if (pickupCoordinates != null && pickupCoordinates!.length >= 2) {
      return [pickupCoordinates!];
    }
    return const [];
  }

  List<List<double>> get resolvedDeliveryCoordinates {
    if (deliveryCoordinatesList != null &&
        deliveryCoordinatesList!.isNotEmpty) {
      return deliveryCoordinatesList!
          .where((c) => c.length >= 2)
          .toList();
    }
    if (deliveryCoordinates != null && deliveryCoordinates!.length >= 2) {
      return [deliveryCoordinates!];
    }
    return const [];
  }

  String pickupLabelAt(int index) {
    if (pickupLabels != null &&
        index < pickupLabels!.length &&
        pickupLabels![index].trim().isNotEmpty) {
      return pickupLabels![index];
    }
    if (pickupLabel != null && pickupLabel!.trim().isNotEmpty) {
      return pickupLabels == null || pickupLabels!.isEmpty
          ? pickupLabel!
          : (index == 0 ? pickupLabel! : 'Pickup ${index + 1}');
    }
    return pickupCoordinatesList != null && pickupCoordinatesList!.length > 1
        ? 'Pickup ${index + 1}'
        : 'Pickup';
  }

  String deliveryLabelAt(int index) {
    if (deliveryLabels != null &&
        index < deliveryLabels!.length &&
        deliveryLabels![index].trim().isNotEmpty) {
      return deliveryLabels![index];
    }
    if (deliveryLabel != null && deliveryLabel!.trim().isNotEmpty) {
      return deliveryLabels == null || deliveryLabels!.isEmpty
          ? deliveryLabel!
          : (index == 0 ? deliveryLabel! : 'Delivery ${index + 1}');
    }
    return deliveryCoordinatesList != null &&
            deliveryCoordinatesList!.length > 1
        ? 'Delivery ${index + 1}'
        : 'Delivery';
  }
}

class MapPickResult {
  final double lat;
  final double lng;
  final String? address;

  const MapPickResult({
    required this.lat,
    required this.lng,
    this.address,
  });

  /// API format
  List<double> get coordinates => [lng, lat];
}
