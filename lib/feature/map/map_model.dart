enum MapMode {
  /// Drop a pin and confirm (Add Load pickup/delivery)
  pickLocation,

  /// Show pickup → delivery route (later: Load Details, etc.)
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

  /// For viewRoute: [lng, lat]
  final List<double>? pickupCoordinates;
  final List<double>? deliveryCoordinates;
  final String? pickupLabel;
  final String? deliveryLabel;

  const MapScreenArgs({
    required this.mode,
    this.title = 'Map',
    this.initialLat,
    this.initialLng,
    this.pickupCoordinates,
    this.deliveryCoordinates,
    this.pickupLabel,
    this.deliveryLabel,
  });
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