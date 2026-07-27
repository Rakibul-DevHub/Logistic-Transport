/**
import 'package:dio/dio.dart';
import 'package:tag/core/utils/map_api_config.dart';

class PlaceSuggestion {
  final String placeId;
  final String description;

  const PlaceSuggestion({
    required this.placeId,
    required this.description,
  });
}

class PlaceLatLng {
  final double lat;
  final double lng;
  final String? address;

  const PlaceLatLng({
    required this.lat,
    required this.lng,
    this.address,
  });

  List<double> get coordinates => [lng, lat];
}

class PlacesService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  Future<List<PlaceSuggestion>> getSuggestions(String input) async {
    final query = input.trim();

    if (query.length < 2) {
      return [];
    }

    final response = await _dio.get(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json',
      queryParameters: {
        'input': query,
        'key': MapApiConfig.apiKey,
        'types': 'geocode',
      },
    );

    final status = response.data?['status']?.toString();

    if (status != 'OK' && status != 'ZERO_RESULTS') {
      throw Exception(
        response.data?['error_message']?.toString() ??
            'Places autocomplete failed ($status)',
      );
    }

    final predictions = response.data?['predictions'] as List? ?? [];

    return predictions
        .map(
          (prediction) => PlaceSuggestion(
        placeId: prediction['place_id']?.toString() ?? '',
        description: prediction['description']?.toString() ?? '',
      ),
    )
        .where((suggestion) => suggestion.placeId.isNotEmpty)
        .toList();
  }

  Future<PlaceLatLng> getPlaceLatLng(String placeId) async {
    final response = await _dio.get(
      'https://maps.googleapis.com/maps/api/place/details/json',
      queryParameters: {
        'place_id': placeId,
        'fields': 'geometry,formatted_address,name',
        'key': MapApiConfig.apiKey,
      },
    );

    final status = response.data?['status']?.toString();

    if (status != 'OK') {
      throw Exception(
        response.data?['error_message']?.toString() ??
            'Place details failed ($status)',
      );
    }

    final result = response.data?['result'];
    final location = result?['geometry']?['location'];

    final lat = (location?['lat'] as num?)?.toDouble();
    final lng = (location?['lng'] as num?)?.toDouble();

    if (lat == null || lng == null) {
      throw Exception('No coordinates found for this place');
    }

    return PlaceLatLng(
      lat: lat,
      lng: lng,
      address: result?['formatted_address']?.toString() ??
          result?['name']?.toString(),
    );
  }

  Future<String?> reverseGeocode(double lat, double lng) async {
    final response = await _dio.get(
      'https://maps.googleapis.com/maps/api/geocode/json',
      queryParameters: {
        'latlng': '$lat,$lng',
        'key': MapApiConfig.apiKey,
        'language': 'en',
      },
    );

    final status = response.data?['status']?.toString();

    if (status != 'OK' && status != 'ZERO_RESULTS') {
      throw Exception(
        response.data?['error_message']?.toString() ??
            'Reverse geocoding failed ($status)',
      );
    }

    final results = response.data?['results'] as List? ?? [];

    if (results.isEmpty) {
      return _getNearestNamedPlace(lat, lng);
    }

    final firstAddress =
    results.first['formatted_address']?.toString().trim();

    if (firstAddress == null ||
        firstAddress.isEmpty ||
        _startsWithPlusCode(firstAddress)) {
      final nearestPlace = await _getNearestNamedPlace(lat, lng);

      if (nearestPlace != null && nearestPlace.isNotEmpty) {
        return nearestPlace;
      }

      for (final result in results) {
        final address =
        result['formatted_address']?.toString().trim();

        if (address != null &&
            address.isNotEmpty &&
            !_startsWithPlusCode(address)) {
          return address;
        }
      }
    }

    return firstAddress;
  }

  Future<String?> _getNearestNamedPlace(
      double lat,
      double lng,
      ) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
        queryParameters: {
          'location': '$lat,$lng',
          'rankby': 'distance',
          'key': MapApiConfig.apiKey,
          'language': 'en',
        },
      );

      final status = response.data?['status']?.toString();

      if (status != 'OK') {
        return null;
      }

      final results = response.data?['results'] as List? ?? [];

      if (results.isEmpty) {
        return null;
      }

      for (final result in results) {
        final name = result['name']?.toString().trim();
        final vicinity = result['vicinity']?.toString().trim();

        if (name == null ||
            name.isEmpty ||
            _startsWithPlusCode(name)) {
          continue;
        }

        if (vicinity == null || vicinity.isEmpty) {
          return name;
        }

        if (vicinity.toLowerCase().contains(name.toLowerCase())) {
          return vicinity;
        }

        return '$name, $vicinity';
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<List<double>>> getDrivingRoute({
    required List<double> pickupCoordinates,
    required List<double> deliveryCoordinates,
  }) async {
    if (pickupCoordinates.length < 2 ||
        deliveryCoordinates.length < 2) {
      throw Exception('Invalid route coordinates');
    }

    final pickupLng = pickupCoordinates[0];
    final pickupLat = pickupCoordinates[1];
    final deliveryLng = deliveryCoordinates[0];
    final deliveryLat = deliveryCoordinates[1];

    final response = await _dio.get(
      'https://maps.googleapis.com/maps/api/directions/json',
      queryParameters: {
        'origin': '$pickupLat,$pickupLng',
        'destination': '$deliveryLat,$deliveryLng',
        'mode': 'driving',
        'alternatives': 'false',
        'key': MapApiConfig.apiKey,
      },
    );

    final status = response.data?['status']?.toString();

    if (status != 'OK') {
      throw Exception(
        response.data?['error_message']?.toString() ??
            'Could not find driving route ($status)',
      );
    }

    final routes = response.data?['routes'] as List? ?? [];

    if (routes.isEmpty) {
      throw Exception('No driving route was found');
    }

    final encodedPolyline =
    routes.first['overview_polyline']?['points']?.toString();

    if (encodedPolyline == null || encodedPolyline.isEmpty) {
      throw Exception('The route did not contain a polyline');
    }

    return _decodePolyline(encodedPolyline);
  }

  List<List<double>> _decodePolyline(String encoded) {
    final coordinates = <List<double>>[];

    var index = 0;
    var latitude = 0;
    var longitude = 0;

    while (index < encoded.length) {
      var result = 0;
      var shift = 0;
      var byte = 0;

      do {
        if (index >= encoded.length) {
          throw Exception('Invalid encoded route');
        }

        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final latitudeChange =
      (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      latitude += latitudeChange;

      result = 0;
      shift = 0;

      do {
        if (index >= encoded.length) {
          throw Exception('Invalid encoded route');
        }

        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final longitudeChange =
      (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      longitude += longitudeChange;

      coordinates.add([
        longitude / 100000.0,
        latitude / 100000.0,
      ]);
    }

    return coordinates;
  }

  bool _startsWithPlusCode(String value) {
    final plusCodePattern = RegExp(
      r'^[23456789CFGHJMPQRVWX]{4,8}\+[23456789CFGHJMPQRVWX]{2,3}',
      caseSensitive: false,
    );

    return plusCodePattern.hasMatch(value.trim());
  }
}*/










///
///
/// todo: trying to improve it
///
///
///



import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:tag/core/utils/map_api_config.dart';

class PlaceSuggestion {
  final String placeId;
  final String description;

  const PlaceSuggestion({
    required this.placeId,
    required this.description,
  });
}

class PlaceLatLng {
  final double lat;
  final double lng;
  final String? address;

  const PlaceLatLng({
    required this.lat,
    required this.lng,
    this.address,
  });

  List<double> get coordinates => [lng, lat];
}

class PlacesService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  /// Prefer POIs under/near the pin (e.g. shop names), then street address.
  static const double _poiPreferRadiusMeters = 55;

  Future<List<PlaceSuggestion>> getSuggestions(String input) async {
    final query = input.trim();

    if (query.length < 2) {
      return [];
    }

    final response = await _dio.get(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json',
      queryParameters: {
        'input': query,
        'key': MapApiConfig.apiKey,
        // Allow businesses + addresses (not only geocode/street)
        'types': 'establishment|geocode',
      },
    );

    final status = response.data?['status']?.toString();

    if (status != 'OK' && status != 'ZERO_RESULTS') {
      throw Exception(
        response.data?['error_message']?.toString() ??
            'Places autocomplete failed ($status)',
      );
    }

    final predictions = response.data?['predictions'] as List? ?? [];

    return predictions
        .map(
          (prediction) => PlaceSuggestion(
        placeId: prediction['place_id']?.toString() ?? '',
        description: prediction['description']?.toString() ?? '',
      ),
    )
        .where((suggestion) => suggestion.placeId.isNotEmpty)
        .toList();
  }

  Future<PlaceLatLng> getPlaceLatLng(String placeId) async {
    final response = await _dio.get(
      'https://maps.googleapis.com/maps/api/place/details/json',
      queryParameters: {
        'place_id': placeId,
        'fields': 'geometry,formatted_address,name',
        'key': MapApiConfig.apiKey,
      },
    );

    final status = response.data?['status']?.toString();

    if (status != 'OK') {
      throw Exception(
        response.data?['error_message']?.toString() ??
            'Place details failed ($status)',
      );
    }

    final result = response.data?['result'];
    final location = result?['geometry']?['location'];

    final lat = (location?['lat'] as num?)?.toDouble();
    final lng = (location?['lng'] as num?)?.toDouble();

    if (lat == null || lng == null) {
      throw Exception('No coordinates found for this place');
    }

    final name = result?['name']?.toString().trim();
    final formatted = result?['formatted_address']?.toString().trim();

    String? address;
    if (name != null &&
        name.isNotEmpty &&
        formatted != null &&
        formatted.isNotEmpty &&
        !formatted.toLowerCase().contains(name.toLowerCase())) {
      address = '$name, $formatted';
    } else {
      address = formatted ?? name;
    }

    return PlaceLatLng(
      lat: lat,
      lng: lng,
      address: address,
    );
  }

  Future<String?> reverseGeocode(double lat, double lng) async {
    // 1) Prefer a real place/POI under the pin (what the map label shows)
    final nearestPoi = await _getNearestNamedPlace(
      lat,
      lng,
      maxDistanceMeters: _poiPreferRadiusMeters,
    );

    if (nearestPoi != null && nearestPoi.isNotEmpty) {
      return nearestPoi;
    }

    // 2) Fall back to reverse geocoding (street / premise)
    final response = await _dio.get(
      'https://maps.googleapis.com/maps/api/geocode/json',
      queryParameters: {
        'latlng': '$lat,$lng',
        'key': MapApiConfig.apiKey,
        'language': 'en',
        'result_type':
        'street_address|premise|subpremise|establishment|point_of_interest|route',
      },
    );

    final status = response.data?['status']?.toString();

    // If filtered geocode returns ZERO_RESULTS, retry without result_type
    List results = response.data?['results'] as List? ?? [];

    if ((status == 'ZERO_RESULTS' || results.isEmpty)) {
      final fallback = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'latlng': '$lat,$lng',
          'key': MapApiConfig.apiKey,
          'language': 'en',
        },
      );
      results = fallback.data?['results'] as List? ?? [];
    } else if (status != 'OK' && status != 'ZERO_RESULTS') {
      throw Exception(
        response.data?['error_message']?.toString() ??
            'Reverse geocoding failed ($status)',
      );
    }

    if (results.isEmpty) {
      return null;
    }

    final best = _pickBestGeocodeAddress(results);
    if (best != null && best.isNotEmpty) {
      return best;
    }

    return null;
  }

  String? _pickBestGeocodeAddress(List results) {
    const preferredTypes = <String>{
      'establishment',
      'point_of_interest',
      'premise',
      'subpremise',
      'street_address',
      'route',
    };

    String? bestAddress;
    var bestScore = -1;

    for (final result in results) {
      final address = result['formatted_address']?.toString().trim();
      if (address == null ||
          address.isEmpty ||
          _startsWithPlusCode(address)) {
        continue;
      }

      final types = (result['types'] as List? ?? [])
          .map((e) => e.toString())
          .toSet();

      var score = 0;
      if (types.contains('establishment') ||
          types.contains('point_of_interest')) {
        score = 100;
      } else if (types.contains('premise') ||
          types.contains('subpremise')) {
        score = 80;
      } else if (types.contains('street_address')) {
        score = 60;
      } else if (types.contains('route')) {
        score = 40;
      } else if (types.any(preferredTypes.contains)) {
        score = 20;
      } else {
        score = 10;
      }

      // Prefer more precise locations
      final locationType =
      result['geometry']?['location_type']?.toString();
      if (locationType == 'ROOFTOP') score += 15;
      if (locationType == 'RANGE_INTERPOLATED') score += 8;

      if (score > bestScore) {
        bestScore = score;
        bestAddress = address;
      }
    }

    return bestAddress;
  }

  Future<String?> _getNearestNamedPlace(
      double lat,
      double lng, {
        required double maxDistanceMeters,
      }) async {
    try {
      // Use radius (not rankby=distance) so the request is valid without type/keyword
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
        queryParameters: {
          'location': '$lat,$lng',
          'radius': maxDistanceMeters.round().clamp(20, 100),
          'key': MapApiConfig.apiKey,
          'language': 'en',
        },
      );

      final status = response.data?['status']?.toString();
      if (status != 'OK' && status != 'ZERO_RESULTS') {
        return null;
      }

      final results = response.data?['results'] as List? ?? [];
      if (results.isEmpty) return null;

      String? bestLabel;
      double bestDistance = double.infinity;

      for (final result in results) {
        final name = result['name']?.toString().trim();
        if (name == null ||
            name.isEmpty ||
            _startsWithPlusCode(name)) {
          continue;
        }

        final types = (result['types'] as List? ?? [])
            .map((e) => e.toString())
            .toList();

        // Skip generic political/area labels
        if (types.contains('route') ||
            types.contains('political') ||
            types.contains('locality') ||
            types.contains('sublocality') ||
            types.contains('country') ||
            types.contains('administrative_area_level_1') ||
            types.contains('administrative_area_level_2')) {
          continue;
        }

        final placeLat =
        (result['geometry']?['location']?['lat'] as num?)
            ?.toDouble();
        final placeLng =
        (result['geometry']?['location']?['lng'] as num?)
            ?.toDouble();

        if (placeLat == null || placeLng == null) continue;

        final distance = _distanceMeters(
          lat,
          lng,
          placeLat,
          placeLng,
        );

        if (distance > maxDistanceMeters) continue;

        // Prefer true POIs / establishments slightly
        final isPoi = types.contains('establishment') ||
            types.contains('point_of_interest') ||
            types.contains('store') ||
            types.contains('shopping_mall');

        final adjusted =
        isPoi ? distance : distance + 8; // slight bias to POI

        if (adjusted < bestDistance) {
          bestDistance = adjusted;

          final vicinity = result['vicinity']?.toString().trim();
          if (vicinity == null || vicinity.isEmpty) {
            bestLabel = name;
          } else if (vicinity
              .toLowerCase()
              .contains(name.toLowerCase())) {
            bestLabel = vicinity;
          } else {
            bestLabel = '$name, $vicinity';
          }
        }
      }

      return bestLabel;
    } catch (_) {
      return null;
    }
  }

  Future<List<List<double>>> getDrivingRoute({
    required List<double> pickupCoordinates,
    required List<double> deliveryCoordinates,
  }) async {
    if (pickupCoordinates.length < 2 ||
        deliveryCoordinates.length < 2) {
      throw Exception('Invalid route coordinates');
    }

    final pickupLng = pickupCoordinates[0];
    final pickupLat = pickupCoordinates[1];
    final deliveryLng = deliveryCoordinates[0];
    final deliveryLat = deliveryCoordinates[1];

    final response = await _dio.get(
      'https://maps.googleapis.com/maps/api/directions/json',
      queryParameters: {
        'origin': '$pickupLat,$pickupLng',
        'destination': '$deliveryLat,$deliveryLng',
        'mode': 'driving',
        'alternatives': 'false',
        'key': MapApiConfig.apiKey,
      },
    );

    final status = response.data?['status']?.toString();

    if (status != 'OK') {
      throw Exception(
        response.data?['error_message']?.toString() ??
            'Could not find driving route ($status)',
      );
    }

    final routes = response.data?['routes'] as List? ?? [];

    if (routes.isEmpty) {
      throw Exception('No driving route was found');
    }

    final encodedPolyline =
    routes.first['overview_polyline']?['points']?.toString();

    if (encodedPolyline == null || encodedPolyline.isEmpty) {
      throw Exception('The route did not contain a polyline');
    }

    return _decodePolyline(encodedPolyline);
  }

  List<List<double>> _decodePolyline(String encoded) {
    final coordinates = <List<double>>[];

    var index = 0;
    var latitude = 0;
    var longitude = 0;

    while (index < encoded.length) {
      var result = 0;
      var shift = 0;
      var byte = 0;

      do {
        if (index >= encoded.length) {
          throw Exception('Invalid encoded route');
        }

        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final latitudeChange =
      (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      latitude += latitudeChange;

      result = 0;
      shift = 0;

      do {
        if (index >= encoded.length) {
          throw Exception('Invalid encoded route');
        }

        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final longitudeChange =
      (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      longitude += longitudeChange;

      coordinates.add([
        longitude / 100000.0,
        latitude / 100000.0,
      ]);
    }

    return coordinates;
  }

  bool _startsWithPlusCode(String value) {
    final plusCodePattern = RegExp(
      r'^[23456789CFGHJMPQRVWX]{4,8}\+[23456789CFGHJMPQRVWX]{2,3}',
      caseSensitive: false,
    );

    return plusCodePattern.hasMatch(value.trim());
  }

  double _distanceMeters(
      double lat1,
      double lng1,
      double lat2,
      double lng2,
      ) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180.0;
}