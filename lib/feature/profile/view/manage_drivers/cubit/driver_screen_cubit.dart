/**
import 'package:dio/dio.dart';
import '../../../../../core/network/secure_storage_service.dart';
import '../../../../../core/utils/app_url.dart';
import '../model/driver_data.dart';


class DriverService {
  final Dio _dio = Dio();

  Future<String> _authHeader() async {
    final token = await SecureStorageService.instance.getAccessToken();
    if (token == null || token.isEmpty) {
      throw DriverApiException('Not authenticated. Please log in again.');
    }
    return 'Bearer $token';
  }

  /// GET /user/drivers/sub-drivers
  Future<List<Driver>> fetchDrivers() async {
    try {
      final response = await _dio.get(
        AppUrl.getDriverList,
        options: Options(headers: {'Authorization': await _authHeader()}),
      );

      final data = response.data['data'];
      if (data is! List) return [];

      return data
          .whereType<Map<String, dynamic>>()
          .map((e) => Driver.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw DriverApiException(_extractMessage(e, fallback: 'Could not load drivers'));
    }
  }

  /// POST /user/drivers/sub-drivers
  /// body: { "name": ..., "email": ... }
  Future<Driver> addDriver({required String name, required String email}) async {
    try {
      final response = await _dio.post(
        AppUrl.addDriver,
        data: {'name': name, 'email': email},
        options: Options(headers: {'Authorization': await _authHeader()}),
      );

      final data = response.data['data'];
      if (data is! Map<String, dynamic>) {
        throw DriverApiException('Unexpected response from server.');
      }
      return Driver.fromJson(data);
    } on DioException catch (e) {
      throw DriverApiException(_extractMessage(e, fallback: 'Could not add driver'));
    }
  }

  /// DELETE /user/drivers/sub-drivers/:id
  Future<void> deleteDriver(String subDriverId) async {
    try {
      await _dio.delete(
        AppUrl.deleteDriver(subDriverId),
        options: Options(headers: {'Authorization': await _authHeader()}),
      );
    } on DioException catch (e) {
      throw DriverApiException(_extractMessage(e, fallback: 'Could not remove driver'));
    }
  }

  String _extractMessage(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return e.message ?? fallback;
  }
}

class DriverApiException implements Exception {
  final String message;
  DriverApiException(this.message);

  @override
  String toString() => message;
}*/









// driver_screen_cubit.dart

import 'package:dio/dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import '../model/driver_data.dart';

class DriverService {
  final Dio _dio = Dio();

  // Add logging interceptor for debugging
  DriverService() {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<String> _authHeader() async {
    final token = await SecureStorageService.instance.getAccessToken();
    if (token == null || token.isEmpty) {
      throw DriverApiException('Not authenticated. Please log in again.');
    }
    return 'Bearer $token';
  }

  /// GET /user/drivers/sub-drivers
  Future<List<Driver>> fetchDrivers() async {
    try {
      final response = await _dio.get(
        AppUrl.getDriverList,
        options: Options(headers: {'Authorization': await _authHeader()}),
      );

      // Log the full response for debugging
      print('📡 GET Drivers Response: ${response.data}');

      final data = response.data['data'];
      if (data is! List) return [];

      return data
          .whereType<Map<String, dynamic>>()
          .map((e) => Driver.fromJson(e))
          .toList();
    } on DioException catch (e) {
      print('❌ GET Drivers Error: ${e.response?.data}');
      print('❌ Status Code: ${e.response?.statusCode}');
      throw DriverApiException(_extractMessage(e, fallback: 'Could not load drivers'));
    } catch (e) {
      print('❌ Unexpected Error: $e');
      throw DriverApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// POST /user/drivers/sub-drivers
  /// body: { "name": ..., "email": ... }
  Future<Driver> addDriver({required String name, required String email}) async {
    try {
      final response = await _dio.post(
        AppUrl.addDriver,
        data: {'name': name, 'email': email},
        options: Options(headers: {'Authorization': await _authHeader()}),
      );

      // Log the full response for debugging
      print('📡 POST Add Driver Response: ${response.data}');
      print('📡 Status Code: ${response.statusCode}');

      final data = response.data['data'];
      if (data is! Map<String, dynamic>) {
        throw DriverApiException('Unexpected response from server.');
      }
      return Driver.fromJson(data);
    } on DioException catch (e) {
      // Log detailed error information
      print('❌ POST Add Driver Error: ${e.response?.data}');
      print('❌ Status Code: ${e.response?.statusCode}');
      print('❌ Error Message: ${e.message}');

      String errorMsg = _extractMessage(e, fallback: 'Could not add driver');
      print('❌ Extracted Error: $errorMsg');
      throw DriverApiException(errorMsg);
    } catch (e) {
      print('❌ Unexpected Error: $e');
      throw DriverApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// DELETE /user/drivers/sub-drivers/:id
  Future<void> deleteDriver(String subDriverId) async {
    try {
      final response = await _dio.delete(
        AppUrl.deleteDriver(subDriverId),
        options: Options(headers: {'Authorization': await _authHeader()}),
      );

      // Log the full response for debugging
      print('📡 DELETE Driver Response: ${response.data}');
      print('📡 Status Code: ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ DELETE Driver Error: ${e.response?.data}');
      print('❌ Status Code: ${e.response?.statusCode}');
      throw DriverApiException(_extractMessage(e, fallback: 'Could not remove driver'));
    } catch (e) {
      print('❌ Unexpected Error: $e');
      throw DriverApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  String _extractMessage(DioException e, {required String fallback}) {
    try {
      final data = e.response?.data;

      // Handle different response formats
      if (data is Map) {
        // Try to get message from different possible keys
        if (data.containsKey('message')) {
          return data['message'].toString();
        }
        if (data.containsKey('error')) {
          return data['error'].toString();
        }
        if (data.containsKey('errors')) {
          final errors = data['errors'];
          if (errors is Map) {
            // If there are field-specific errors, combine them
            return errors.values
                .whereType<String>()
                .join(', ');
          }
          return errors.toString();
        }
        if (data.containsKey('msg')) {
          return data['msg'].toString();
        }
        // If we can't find a message, return the whole data as string
        return data.toString();
      }

      // If data is a string, use it as the message
      if (data is String) {
        return data;
      }

      // Check for common error status codes
      if (e.response?.statusCode == 409) {
        return 'Driver with this email already exists.';
      }

      if (e.response?.statusCode == 404) {
        return 'Driver not found.';
      }

      if (e.response?.statusCode == 400) {
        return 'Invalid request. Please check your input.';
      }

      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return 'Session expired. Please log in again.';
      }

      // Use Dio's error message as fallback
      return e.message ?? fallback;
    } catch (e) {
      // If something goes wrong extracting the message, use the fallback
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