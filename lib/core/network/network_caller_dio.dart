/**
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'network_response_dio.dart';

class NetworkCallerDio {
  final Dio _dio;

  NetworkCallerDio() : _dio = Dio(
    BaseOptions(
      validateStatus: (status) {
        // Accept any status code, we'll handle them in _handleResponse
        return status != null && status >= 200 && status < 600;
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Generic function to handle any HTTP request (GET, POST, PUT, DELETE)
  Future<NetworkResponseDio> _request(
      String method,
      String url, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        bool isLogin = false,
      }) async {
    final Map<String, String> requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    try {
      debugPrint('🌐 $method Request to: $url');
      debugPrint('📋 Headers: $requestHeaders');
      if (body != null) {
        debugPrint('📦 Body: $body');
      }

      Response response;

      switch (method.toUpperCase()) {
        case 'POST':
          response = await _dio.post(
            url,
            data: body,
            options: Options(headers: requestHeaders),
          );
          break;

        case 'GET':
          response = await _dio.get(
            url,
            options: Options(headers: requestHeaders),
          );
          break;

        case 'PUT':
          response = await _dio.put(
            url,
            data: body,
            options: Options(headers: requestHeaders),
          );
          break;

        case 'DELETE':
          response = await _dio.delete(
            url,
            data: body,
            options: Options(headers: requestHeaders),
          );
          break;

        case 'PATCH':
          response = await _dio.patch(
            url,
            data: body,
            options: Options(headers: requestHeaders),
          );
          break;

        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.data}');

      return _handleResponse(response, isLogin);
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.message}');
      debugPrint('❌ Dio Error Response: ${e.response?.data}');

      // If we have a response, handle it
      if (e.response != null) {
        return _handleResponse(e.response!, isLogin);
      }

      return NetworkResponseDio(
        isSuccess: false,
        errorMessage: e.message ?? 'Network error occurred',
      );
    } catch (e) {
      debugPrint('❌ Error: $e');
      return NetworkResponseDio(
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Handles response from the HTTP request and returns a NetworkResponse
  NetworkResponseDio _handleResponse(Response response, bool isLogin) {
    try {
      // Safely parse response data
      Map<String, dynamic> jsonResponse = {};
      if (response.data != null) {
        if (response.data is Map) {
          jsonResponse = response.data as Map<String, dynamic>;
        } else if (response.data is String) {
          // Try to parse if it's a JSON string
          try {
            // You might want to add jsonDecode here if needed
            // jsonResponse = jsonDecode(response.data);
          } catch (_) {}
        }
      }

      // Success status codes (2xx)
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return NetworkResponseDio(
          isSuccess: true,
          jsonResponse: jsonResponse,
          statusCode: response.statusCode,
        );
      }

      // Client errors (400, 401, 403, 404) - return as failure but don't throw
      if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 422) {

        String errorMessage = jsonResponse['message'] ??
            jsonResponse['error'] ??
            'Request failed';

        // If there are validation errors (common in 400/422 responses)
        if (jsonResponse['errors'] != null) {
          final errors = jsonResponse['errors'];
          if (errors is Map) {
            errorMessage = errors.values.join(', ');
          } else if (errors is List) {
            errorMessage = errors.join(', ');
          } else {
            errorMessage = errors.toString();
          }
        }

        // Check for nested error messages
        if (jsonResponse['data'] != null && jsonResponse['data'] is Map) {
          final data = jsonResponse['data'] as Map;
          if (data['message'] != null) {
            errorMessage = data['message'].toString();
          }
        }

        // If it's 401 and not login, handle token expiration
        if (response.statusCode == 401 && !isLogin) {
          debugPrint('🔄 Token expired - need to refresh');
        }

        return NetworkResponseDio(
          isSuccess: false,
          statusCode: response.statusCode,
          jsonResponse: jsonResponse,
          errorMessage: errorMessage,
        );
      }

      // Server errors (500+)
      return NetworkResponseDio(
        isSuccess: false,
        statusCode: response.statusCode,
        jsonResponse: jsonResponse,
        errorMessage: jsonResponse['message'] ?? 'Server error occurred',
      );
    } catch (e) {
      return NetworkResponseDio(
        isSuccess: false,
        errorMessage: 'Error parsing response: ${e.toString()}',
      );
    }
  }

  // GET Request
  Future<NetworkResponseDio> getRequest(
      String url, {
        Map<String, String>? headers,
        bool isLogin = false,
      }) async {
    return _request('GET', url, headers: headers, isLogin: isLogin);
  }

  // POST Request
  Future<NetworkResponseDio> postRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request(
      'POST',
      url,
      body: body,
      isLogin: isLogin,
      headers: headers,
    );
  }

  // PUT Request
  Future<NetworkResponseDio> putRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request(
      'PUT',
      url,
      body: body,
      isLogin: isLogin,
      headers: headers,
    );
  }

  // DELETE Request
  Future<NetworkResponseDio> deleteRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request(
      'DELETE',
      url,
      body: body,
      isLogin: isLogin,
      headers: headers,
    );
  }

  // PATCH Request
  Future<NetworkResponseDio> patchRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request(
      'PATCH',
      url,
      body: body,
      isLogin: isLogin,
      headers: headers,
    );
  }

  // ============ IMAGE UPLOAD USING DIO'S NATIVE FORMDATA ============

  /// Upload image using Dio's native FormData
  /// This uses Dio's built-in multipart/form-data support
  Future<NetworkResponseDio> uploadImage(
      String url, {
        required File imageFile,
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        bool isLogin = false,
        String fileFieldName = 'profileImage',
      }) async {
    try {
      // Prepare headers
      final Map<String, String> requestHeaders = <String, String>{
        ...?headers,
      };

      debugPrint('🌐 Upload Request to: $url');
      debugPrint('📋 Headers: $requestHeaders');

      // Create FormData using Dio's native FormData
      FormData formData = FormData();

      // Add text fields if any
      if (body != null) {
        body.forEach((key, value) {
          if (value != null) {
            formData.fields.add(MapEntry(key, value.toString()));
          }
        });
      }

      // Add image file using Dio's MultipartFile
      if (imageFile.existsSync()) {
        String fileName = imageFile.path.split('/').last;
        String contentType = _getContentType(fileName);

        MultipartFile multipartFile = await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        );

        if (contentType.isNotEmpty) {
          multipartFile = await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
            contentType: DioMediaType.parse(contentType),
          );
        }

        formData.files.add(
          MapEntry(
            fileFieldName,
            multipartFile,
          ),
        );

        debugPrint('📎 File attached: $fileName (${await imageFile.length()} bytes)');
      } else {
        return NetworkResponseDio(
          isSuccess: false,
          errorMessage: 'Image file does not exist',
        );
      }

      // Send request with Dio
      final response = await _dio.put(
        url,
        data: formData,
        options: Options(
          headers: requestHeaders,
          contentType: 'multipart/form-data',
        ),
      );

      debugPrint('✅ Upload Response Status: ${response.statusCode}');
      debugPrint('📄 Upload Response Body: ${response.data}');

      return _handleResponse(response, isLogin);
    } catch (e) {
      debugPrint('❌ Upload Error: $e');
      return NetworkResponseDio(
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Upload multiple images using Dio's native FormData
  Future<NetworkResponseDio> uploadMultipleImages(
      String url, {
        required List<File> imageFiles,
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        bool isLogin = false,
        String fileFieldName = 'images',
      }) async {
    try {
      final Map<String, String> requestHeaders = <String, String>{
        ...?headers,
      };

      debugPrint('🌐 Multiple Upload Request to: $url');

      FormData formData = FormData();

      // Add text fields
      if (body != null) {
        body.forEach((key, value) {
          if (value != null) {
            formData.fields.add(MapEntry(key, value.toString()));
          }
        });
      }

      // Add multiple image files
      for (int i = 0; i < imageFiles.length; i++) {
        File file = imageFiles[i];
        if (file.existsSync()) {
          String fileName = file.path.split('/').last;
          String contentType = _getContentType(fileName);

          MultipartFile multipartFile = await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          );

          if (contentType.isNotEmpty) {
            multipartFile = await MultipartFile.fromFile(
              file.path,
              filename: fileName,
              contentType: DioMediaType.parse(contentType),
            );
          }

          formData.files.add(
            MapEntry(
              '$fileFieldName[$i]',
              multipartFile,
            ),
          );
          debugPrint('📎 File $i attached: $fileName');
        }
      }

      final response = await _dio.put(
        url,
        data: formData,
        options: Options(
          headers: requestHeaders,
          contentType: 'multipart/form-data',
        ),
      );

      debugPrint('✅ Upload Response Status: ${response.statusCode}');
      return _handleResponse(response, isLogin);
    } catch (e) {
      debugPrint('❌ Upload Error: $e');
      return NetworkResponseDio(
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Upload image with progress tracking
  Future<NetworkResponseDio> uploadImageWithProgress(
      String url, {
        required File imageFile,
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        bool isLogin = false,
        String fileFieldName = 'profileImage',
        Function(int sent, int total)? onProgress,
      }) async {
    try {
      final Map<String, String> requestHeaders = <String, String>{
        ...?headers,
      };

      debugPrint('🌐 Upload Request to: $url');

      FormData formData = FormData();

      // Add text fields
      if (body != null) {
        body.forEach((key, value) {
          if (value != null) {
            formData.fields.add(MapEntry(key, value.toString()));
          }
        });
      }

      // Add image file
      if (imageFile.existsSync()) {
        String fileName = imageFile.path.split('/').last;
        String contentType = _getContentType(fileName);

        MultipartFile multipartFile = await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        );

        if (contentType.isNotEmpty) {
          multipartFile = await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
            contentType: DioMediaType.parse(contentType),
          );
        }

        formData.files.add(
          MapEntry(
            fileFieldName,
            multipartFile,
          ),
        );

        debugPrint('📎 File attached: $fileName (${await imageFile.length()} bytes)');
      } else {
        return NetworkResponseDio(
          isSuccess: false,
          errorMessage: 'Image file does not exist',
        );
      }

      // Send request with progress tracking
      final response = await _dio.put(
        url,
        data: formData,
        options: Options(
          headers: requestHeaders,
          contentType: 'multipart/form-data',
        ),
        onSendProgress: (sent, total) {
          if (onProgress != null) {
            onProgress(sent, total);
          }
          debugPrint('📤 Upload Progress: $sent / $total bytes');
        },
      );

      debugPrint('✅ Upload Response Status: ${response.statusCode}');
      debugPrint('📄 Upload Response Body: ${response.data}');

      return _handleResponse(response, isLogin);
    } catch (e) {
      debugPrint('❌ Upload Error: $e');
      return NetworkResponseDio(
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Helper to get content type based on file extension
  String _getContentType(String fileName) {
    String extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'svg':
        return 'image/svg+xml';
      default:
        return 'image/jpeg';
    }
  }
}*/














///
///
///
///
///
///
///
///
///
///
///




// lib/core/network/network_caller_dio.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'network_response_dio.dart';

class NetworkCallerDio {
  final Dio _dio;

  NetworkCallerDio() : _dio = Dio(
    BaseOptions(
      validateStatus: (status) {
        // Accept any status code, we'll handle them in _handleResponse
        return status != null && status >= 200 && status < 600;
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Generic function to handle any HTTP request (GET, POST, PUT, DELETE)
  Future<NetworkResponseDio> _request(
      String method,
      String url, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        bool isLogin = false,
      }) async {
    final Map<String, String> requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    try {
      debugPrint('🌐 $method Request to: $url');
      debugPrint('📋 Headers: $requestHeaders');
      if (body != null) {
        debugPrint('📦 Body: $body');
      }

      Response response;

      switch (method.toUpperCase()) {
        case 'POST':
          response = await _dio.post(
            url,
            data: body,
            options: Options(headers: requestHeaders),
          );
          break;

        case 'GET':
          response = await _dio.get(
            url,
            options: Options(headers: requestHeaders),
          );
          break;

        case 'PUT':
          response = await _dio.put(
            url,
            data: body,
            options: Options(headers: requestHeaders),
          );
          break;

        case 'DELETE':
          response = await _dio.delete(
            url,
            data: body,
            options: Options(headers: requestHeaders),
          );
          break;

        case 'PATCH':
          response = await _dio.patch(
            url,
            data: body,
            options: Options(headers: requestHeaders),
          );
          break;

        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.data}');

      return _handleResponse(response, isLogin);
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.message}');
      debugPrint('❌ Dio Error Response: ${e.response?.data}');

      if (e.response != null) {
        return _handleResponse(e.response!, isLogin);
      }

      return NetworkResponseDio(
        isSuccess: false,
        errorMessage: e.message ?? 'Network error occurred',
      );
    } catch (e) {
      debugPrint('❌ Error: $e');
      return NetworkResponseDio(
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Handles response from the HTTP request and returns a NetworkResponse
  NetworkResponseDio _handleResponse(Response response, bool isLogin) {
    try {
      Map<String, dynamic> jsonResponse = {};
      if (response.data != null) {
        if (response.data is Map) {
          jsonResponse = response.data as Map<String, dynamic>;
        } else if (response.data is String) {
          try {
            // You might want to add jsonDecode here if needed
          } catch (_) {}
        }
      }

      // Success status codes (2xx)
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return NetworkResponseDio(
          isSuccess: true,
          jsonResponse: jsonResponse,
          statusCode: response.statusCode,
        );
      }

      // Client errors (400, 401, 403, 404) - return as failure but don't throw
      if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 422) {

        String errorMessage = jsonResponse['message'] ??
            jsonResponse['error'] ??
            'Request failed';

        if (jsonResponse['errors'] != null) {
          final errors = jsonResponse['errors'];
          if (errors is Map) {
            errorMessage = errors.values.join(', ');
          } else if (errors is List) {
            errorMessage = errors.join(', ');
          } else {
            errorMessage = errors.toString();
          }
        }

        if (jsonResponse['data'] != null && jsonResponse['data'] is Map) {
          final data = jsonResponse['data'] as Map;
          if (data['message'] != null) {
            errorMessage = data['message'].toString();
          }
        }

        if (response.statusCode == 401 && !isLogin) {
          debugPrint('🔄 Token expired - need to refresh');
        }

        return NetworkResponseDio(
          isSuccess: false,
          statusCode: response.statusCode,
          jsonResponse: jsonResponse,
          errorMessage: errorMessage,
        );
      }

      // Server errors (500+)
      return NetworkResponseDio(
        isSuccess: false,
        statusCode: response.statusCode,
        jsonResponse: jsonResponse,
        errorMessage: jsonResponse['message'] ?? 'Server error occurred',
      );
    } catch (e) {
      return NetworkResponseDio(
        isSuccess: false,
        errorMessage: 'Error parsing response: ${e.toString()}',
      );
    }
  }

  // GET Request
  Future<NetworkResponseDio> getRequest(
      String url, {
        Map<String, String>? headers,
        bool isLogin = false,
      }) async {
    return _request('GET', url, headers: headers, isLogin: isLogin);
  }

  // POST Request
  Future<NetworkResponseDio> postRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request(
      'POST',
      url,
      body: body,
      isLogin: isLogin,
      headers: headers,
    );
  }

  // PUT Request
  Future<NetworkResponseDio> putRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request(
      'PUT',
      url,
      body: body,
      isLogin: isLogin,
      headers: headers,
    );
  }

  // DELETE Request
  Future<NetworkResponseDio> deleteRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request(
      'DELETE',
      url,
      body: body,
      isLogin: isLogin,
      headers: headers,
    );
  }

  // PATCH Request
  Future<NetworkResponseDio> patchRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request(
      'PATCH',
      url,
      body: body,
      isLogin: isLogin,
      headers: headers,
    );
  }

  // ============ IMAGE UPLOAD USING DIO'S NATIVE FORMDATA ============

  /// Upload image using Dio's native FormData
  /// This uses Dio's built-in multipart/form-data support
  /// ✅ Added method parameter to support both POST and PUT
  Future<NetworkResponseDio> uploadImage(
      String url, {
        required File imageFile,
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        bool isLogin = false,
        String fileFieldName = 'profileImage',
        String method = 'POST', // ✅ Added method parameter (default: POST)
      }) async {
    try {
      // Prepare headers
      final Map<String, String> requestHeaders = <String, String>{
        ...?headers,
      };

      debugPrint('🌐 Upload Request to: $url');
      debugPrint('📋 Headers: $requestHeaders');
      debugPrint('📋 Method: $method');

      // Create FormData using Dio's native FormData
      FormData formData = FormData();

      // Add text fields if any
      if (body != null) {
        body.forEach((key, value) {
          if (value != null) {
            formData.fields.add(MapEntry(key, value.toString()));
          }
        });
      }

      // Add image file using Dio's MultipartFile
      if (imageFile.existsSync()) {
        String fileName = imageFile.path.split('/').last;
        String contentType = _getContentType(fileName);

        MultipartFile multipartFile = await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        );

        if (contentType.isNotEmpty) {
          multipartFile = await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
            contentType: DioMediaType.parse(contentType),
          );
        }

        formData.files.add(
          MapEntry(
            fileFieldName,
            multipartFile,
          ),
        );

        debugPrint('📎 File attached: $fileName (${await imageFile.length()} bytes)');
      } else {
        return NetworkResponseDio(
          isSuccess: false,
          errorMessage: 'Image file does not exist',
        );
      }

      // ✅ Send request with specified method (POST or PUT)
      Response response;

      if (method.toUpperCase() == 'POST') {
        response = await _dio.post(
          url,
          data: formData,
          options: Options(
            headers: requestHeaders,
            contentType: 'multipart/form-data',
          ),
        );
      } else if (method.toUpperCase() == 'PUT') {
        response = await _dio.put(
          url,
          data: formData,
          options: Options(
            headers: requestHeaders,
            contentType: 'multipart/form-data',
          ),
        );
      } else {
        // Default to POST if method not recognized
        response = await _dio.post(
          url,
          data: formData,
          options: Options(
            headers: requestHeaders,
            contentType: 'multipart/form-data',
          ),
        );
      }

      debugPrint('✅ Upload Response Status: ${response.statusCode}');
      debugPrint('📄 Upload Response Body: ${response.data}');

      return _handleResponse(response, isLogin);
    } catch (e) {
      debugPrint('❌ Upload Error: $e');
      return NetworkResponseDio(
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Upload multiple images using Dio's native FormData
  Future<NetworkResponseDio> uploadMultipleImages(
      String url, {
        required List<File> imageFiles,
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        bool isLogin = false,
        String fileFieldName = 'images',
        String method = 'POST', // ✅ Added method parameter
      }) async {
    try {
      final Map<String, String> requestHeaders = <String, String>{
        ...?headers,
      };

      debugPrint('🌐 Multiple Upload Request to: $url');

      FormData formData = FormData();

      // Add text fields
      if (body != null) {
        body.forEach((key, value) {
          if (value != null) {
            formData.fields.add(MapEntry(key, value.toString()));
          }
        });
      }

      // Add multiple image files
      for (int i = 0; i < imageFiles.length; i++) {
        File file = imageFiles[i];
        if (file.existsSync()) {
          String fileName = file.path.split('/').last;
          String contentType = _getContentType(fileName);

          MultipartFile multipartFile = await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          );

          if (contentType.isNotEmpty) {
            multipartFile = await MultipartFile.fromFile(
              file.path,
              filename: fileName,
              contentType: DioMediaType.parse(contentType),
            );
          }

          formData.files.add(
            MapEntry(
              '$fileFieldName[$i]',
              multipartFile,
            ),
          );
          debugPrint('📎 File $i attached: $fileName');
        }
      }

      // ✅ Send request with specified method
      Response response;

      if (method.toUpperCase() == 'POST') {
        response = await _dio.post(
          url,
          data: formData,
          options: Options(
            headers: requestHeaders,
            contentType: 'multipart/form-data',
          ),
        );
      } else if (method.toUpperCase() == 'PUT') {
        response = await _dio.put(
          url,
          data: formData,
          options: Options(
            headers: requestHeaders,
            contentType: 'multipart/form-data',
          ),
        );
      } else {
        response = await _dio.post(
          url,
          data: formData,
          options: Options(
            headers: requestHeaders,
            contentType: 'multipart/form-data',
          ),
        );
      }

      debugPrint('✅ Upload Response Status: ${response.statusCode}');
      return _handleResponse(response, isLogin);
    } catch (e) {
      debugPrint('❌ Upload Error: $e');
      return NetworkResponseDio(
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Upload image with progress tracking
  Future<NetworkResponseDio> uploadImageWithProgress(
      String url, {
        required File imageFile,
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        bool isLogin = false,
        String fileFieldName = 'profileImage',
        String method = 'POST', // ✅ Added method parameter
        Function(int sent, int total)? onProgress,
      }) async {
    try {
      final Map<String, String> requestHeaders = <String, String>{
        ...?headers,
      };

      debugPrint('🌐 Upload Request to: $url');

      FormData formData = FormData();

      // Add text fields
      if (body != null) {
        body.forEach((key, value) {
          if (value != null) {
            formData.fields.add(MapEntry(key, value.toString()));
          }
        });
      }

      // Add image file
      if (imageFile.existsSync()) {
        String fileName = imageFile.path.split('/').last;
        String contentType = _getContentType(fileName);

        MultipartFile multipartFile = await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        );

        if (contentType.isNotEmpty) {
          multipartFile = await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
            contentType: DioMediaType.parse(contentType),
          );
        }

        formData.files.add(
          MapEntry(
            fileFieldName,
            multipartFile,
          ),
        );

        debugPrint('📎 File attached: $fileName (${await imageFile.length()} bytes)');
      } else {
        return NetworkResponseDio(
          isSuccess: false,
          errorMessage: 'Image file does not exist',
        );
      }

      // ✅ Send request with specified method and progress tracking
      Response response;

      if (method.toUpperCase() == 'POST') {
        response = await _dio.post(
          url,
          data: formData,
          options: Options(
            headers: requestHeaders,
            contentType: 'multipart/form-data',
          ),
          onSendProgress: (sent, total) {
            if (onProgress != null) {
              onProgress(sent, total);
            }
            debugPrint('📤 Upload Progress: $sent / $total bytes');
          },
        );
      } else if (method.toUpperCase() == 'PUT') {
        response = await _dio.put(
          url,
          data: formData,
          options: Options(
            headers: requestHeaders,
            contentType: 'multipart/form-data',
          ),
          onSendProgress: (sent, total) {
            if (onProgress != null) {
              onProgress(sent, total);
            }
            debugPrint('📤 Upload Progress: $sent / $total bytes');
          },
        );
      } else {
        response = await _dio.post(
          url,
          data: formData,
          options: Options(
            headers: requestHeaders,
            contentType: 'multipart/form-data',
          ),
          onSendProgress: (sent, total) {
            if (onProgress != null) {
              onProgress(sent, total);
            }
            debugPrint('📤 Upload Progress: $sent / $total bytes');
          },
        );
      }

      debugPrint('✅ Upload Response Status: ${response.statusCode}');
      debugPrint('📄 Upload Response Body: ${response.data}');

      return _handleResponse(response, isLogin);
    } catch (e) {
      debugPrint('❌ Upload Error: $e');
      return NetworkResponseDio(
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Helper to get content type based on file extension
  String _getContentType(String fileName) {
    String extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'svg':
        return 'image/svg+xml';
      default:
        return 'image/jpeg';
    }
  }
}


