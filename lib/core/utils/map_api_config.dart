import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapApiConfig {
  MapApiConfig._();

  /// Used by Places / Geocoding (Dart HTTP calls)
  static String get apiKey {
    final key = dotenv.env['MAP_API_KEY']?.trim() ?? '';
    if (key.isEmpty) {
      throw Exception('MAP_API_KEY missing in .env');
    }
    return key;
  }
}