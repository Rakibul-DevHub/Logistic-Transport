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

    // Google sometimes returns only a Plus Code, such as:
    // Q9VX+C99, Dhaka 1212, Bangladesh.
    // In that case, get the nearest named place instead.
    if (firstAddress == null ||
        firstAddress.isEmpty ||
        _startsWithPlusCode(firstAddress)) {
      final nearestPlace = await _getNearestNamedPlace(lat, lng);

      if (nearestPlace != null && nearestPlace.isNotEmpty) {
        return nearestPlace;
      }

      // If no named place is available, use the first normal address
      // returned by the Geocoding API.
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
///
/// todo:: trying to mark the road path
///
///
///
///




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
}