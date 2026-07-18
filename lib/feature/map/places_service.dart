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
    if (query.length < 2) return [];

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
        .map((p) => PlaceSuggestion(
      placeId: p['place_id']?.toString() ?? '',
      description: p['description']?.toString() ?? '',
    ))
        .where((e) => e.placeId.isNotEmpty)
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
      },
    );

    final results = response.data?['results'] as List? ?? [];
    if (results.isEmpty) return null;
    return results.first['formatted_address']?.toString();
  }
}