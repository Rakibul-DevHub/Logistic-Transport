// driver_screen_cubit.dart

import 'package:dio/dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import '../model/driver_data.dart';

class DriverService {
  DriverService._internal() {
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  static final DriverService instance = DriverService._internal();

  /// Keeps existing `DriverService()` call sites working as the singleton.
  factory DriverService() => instance;

  final Dio _dio = Dio();

  List<Driver>? _cachedDrivers;

  bool get hasCache => _cachedDrivers != null;

  List<Driver> get cachedDrivers =>
      List<Driver>.unmodifiable(_cachedDrivers ?? const []);

  /// Sorted unique driver names from cache (empty if no cache yet).
  List<String> get cachedDriverNames {
    final names = cachedDrivers
        .map((d) => d.name.trim())
        .where((n) => n.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }

  void clearCache() {
    _cachedDrivers = null;
  }

  void _setCache(List<Driver> drivers) {
    _cachedDrivers = List<Driver>.from(drivers);
  }

  Future<String> _authHeader() async {
    final token = await SecureStorageService.instance.getAccessToken();
    if (token == null || token.isEmpty) {
      throw DriverApiException('Not authenticated. Please log in again.');
    }
    return 'Bearer $token';
  }

  /// GET /user/drivers/sub-drivers
  /// Returns cached list unless [forceRefresh] is true or cache is empty.
  Future<List<Driver>> fetchDrivers({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedDrivers != null) {
      return List<Driver>.from(_cachedDrivers!);
    }

    try {
      final response = await _dio.get(
        AppUrl.getDriverList,
        options: Options(headers: {'Authorization': await _authHeader()}),
      );

      final data = response.data['data'];
      if (data is! List) {
        _setCache(const []);
        return [];
      }

      final drivers = data
          .whereType<Map>()
          .map((e) => Driver.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      _setCache(drivers);
      return List<Driver>.from(drivers);
    } on DioException catch (e) {
      throw DriverApiException(
        _extractMessage(e, fallback: 'Could not load drivers'),
      );
    } catch (e) {
      throw DriverApiException('An unexpected error occurred: $e');
    }
  }

  /// Convenience: names for dropdowns (`['All Drivers', ...]` if [includeAll]).
  Future<List<String>> getDriverNames({
    bool forceRefresh = false,
    bool includeAll = true,
  }) async {
    await fetchDrivers(forceRefresh: forceRefresh);
    final names = cachedDriverNames;
    if (!includeAll) return names;
    return ['All Drivers', ...names];
  }

  /// POST /user/drivers/sub-drivers
  Future<Driver> addDriver({
    required String name,
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        AppUrl.addDriver,
        data: {'name': name, 'email': email},
        options: Options(headers: {'Authorization': await _authHeader()}),
      );

      final data = response.data['data'];
      if (data is! Map) {
        throw DriverApiException('Unexpected response from server.');
      }

      final driver = Driver.fromJson(Map<String, dynamic>.from(data));
      final current = List<Driver>.from(_cachedDrivers ?? const []);
      current.add(driver);
      _setCache(current);
      return driver;
    } on DioException catch (e) {
      throw DriverApiException(
        _extractMessage(e, fallback: 'Could not add driver'),
      );
    } catch (e) {
      if (e is DriverApiException) rethrow;
      throw DriverApiException('An unexpected error occurred: $e');
    }
  }

  /// DELETE /user/drivers/sub-drivers/:id
  Future<void> deleteDriver(String subDriverId) async {
    try {
      await _dio.delete(
        AppUrl.deleteDriver(subDriverId),
        options: Options(headers: {'Authorization': await _authHeader()}),
      );

      if (_cachedDrivers != null) {
        _setCache(
          _cachedDrivers!.where((d) => d.id != subDriverId).toList(),
        );
      }
    } on DioException catch (e) {
      throw DriverApiException(
        _extractMessage(e, fallback: 'Could not remove driver'),
      );
    } catch (e) {
      throw DriverApiException('An unexpected error occurred: $e');
    }
  }

  String _extractMessage(DioException e, {required String fallback}) {
    try {
      final data = e.response?.data;

      if (data is Map) {
        if (data.containsKey('message')) return data['message'].toString();
        if (data.containsKey('error')) return data['error'].toString();
        if (data.containsKey('errors')) {
          final errors = data['errors'];
          if (errors is Map) {
            return errors.values.whereType<String>().join(', ');
          }
          return errors.toString();
        }
        if (data.containsKey('msg')) return data['msg'].toString();
        return data.toString();
      }

      if (data is String) return data;

      if (e.response?.statusCode == 409) {
        return 'Driver with this email already exists.';
      }
      if (e.response?.statusCode == 404) return 'Driver not found.';
      if (e.response?.statusCode == 400) {
        return 'Invalid request. Please check your input.';
      }
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return 'Session expired. Please log in again.';
      }

      return e.message ?? fallback;
    } catch (_) {
      return fallback;
    }
  }
}

class DriverApiException implements Exception {
  final String message;
  DriverApiException(this.message);

  @override
  String toString() => message;
}
