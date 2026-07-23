// cubit/bill_of_loading_scan_cubit.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import 'dart:developer' as developer;
import '../model/bill_of_load_data.dart';

// ==================== STATES ====================
abstract class ScanBolState extends Equatable {
  const ScanBolState();

  @override
  List<Object?> get props => [];
}

class ScanBolInitial extends ScanBolState {}

class ScanBolLoading extends ScanBolState {
  final String? progressMessage;

  const ScanBolLoading({this.progressMessage});

  @override
  List<Object?> get props => [progressMessage];
}

class ScanBolSuccess extends ScanBolState {
  final OCRData ocrData;

  const ScanBolSuccess({required this.ocrData});

  @override
  List<Object?> get props => [ocrData];
}

class ScanBolFailure extends ScanBolState {
  final String errorMessage;
  final String? detailedError;
  final int? statusCode;

  const ScanBolFailure({
    required this.errorMessage,
    this.detailedError,
    this.statusCode,
  });

  @override
  List<Object?> get props => [errorMessage, detailedError, statusCode];
}

// ==================== CUBIT ====================
class ScanBolCubit extends Cubit<ScanBolState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  bool _isClosed = false;

  ScanBolCubit() : super(ScanBolInitial());

  @override
  Future<void> close() {
    _isClosed = true;
    return super.close();
  }

  // ✅ Safe emit method
  void _safeEmit(ScanBolState state) {
    if (!_isClosed && !isClosed) {
      emit(state);
    }
  }

  Future<void> processOCR(String imagePath) async {
    try {
      developer.log('🚀 [OCR] ========== STARTING OCR PROCESS ==========');
      developer.log('📁 [OCR] Image path: $imagePath');

      _safeEmit(const ScanBolLoading(progressMessage: 'Preparing image...'));

      // Step 1: Get access token
      developer.log('🔑 [OCR] Getting access token...');
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null || token.isEmpty) {
        developer.log('❌ [OCR] No access token found');
        _safeEmit(const ScanBolFailure(
          errorMessage: 'Please login again',
        ));
        return;
      }
      developer.log('✅ [OCR] Access token obtained: ${token.substring(0, 20)}...');

      // Step 2: Check if image file exists
      developer.log('📁 [OCR] Checking if image file exists...');
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        developer.log('❌ [OCR] Image file not found at path: $imagePath');
        _safeEmit(const ScanBolFailure(
          errorMessage: 'Image file not found',
        ));
        return;
      }

      final fileSize = await imageFile.length();
      developer.log('✅ [OCR] Image file exists. Size: $fileSize bytes');
      developer.log('📄 [OCR] File name: ${imageFile.path.split('/').last}');

      // Step 3: Upload the image
      developer.log('📤 [OCR] ========== STARTING IMAGE UPLOAD ==========');
      developer.log('📤 [OCR] Upload URL: ${AppUrl.singleImageUpload}');
      developer.log('📤 [OCR] File field name: "file"');
      developer.log('📤 [OCR] File path: ${imageFile.path}');

      _safeEmit(const ScanBolLoading(progressMessage: 'Uploading image...'));

      final uploadResponse = await _networkCaller.uploadImage(
        AppUrl.singleImageUpload,
        imageFile: imageFile,
        headers: {'Authorization': 'Bearer $token'},
        fileFieldName: 'file',
        method: 'POST',
      );

      developer.log('📡 [OCR] ========== UPLOAD RESPONSE ==========');
      developer.log('📡 [OCR] Status Code: ${uploadResponse.statusCode}');
      developer.log('📡 [OCR] Is Success: ${uploadResponse.isSuccess}');
      developer.log('📡 [OCR] Error Message: ${uploadResponse.errorMessage}');
      developer.log('📡 [OCR] Full Response: ${uploadResponse.jsonResponse}');

      // Step 4: Check upload response
      if (!uploadResponse.isSuccess) {
        String errorMsg = uploadResponse.errorMessage ?? 'Failed to upload image';

        if (uploadResponse.jsonResponse != null) {
          final errorData = uploadResponse.jsonResponse;
          if (errorData is Map) {
            errorMsg = errorData?['message']?.toString() ??
                errorData?['error']?.toString() ??
                errorData?['msg']?.toString() ??
                errorMsg;
            developer.log('📡 [OCR] Extracted error from response: $errorMsg');
          }
        }

        developer.log('❌ [OCR] Image upload failed: $errorMsg');
        _safeEmit(ScanBolFailure(
          errorMessage: 'Failed to upload image',
          detailedError: errorMsg,
          statusCode: uploadResponse.statusCode,
        ));
        return;
      }

      if (uploadResponse.jsonResponse == null) {
        developer.log('❌ [OCR] Upload response is null');
        _safeEmit(const ScanBolFailure(
          errorMessage: 'Invalid upload response',
          detailedError: 'Response body is null',
        ));
        return;
      }

      // Step 5: Extract filename from response
      developer.log('🔍 [OCR] ========== EXTRACTING FILENAME ==========');
      final uploadData = uploadResponse.jsonResponse?['data'];
      developer.log('📦 [OCR] Upload data: $uploadData');

      if (uploadData == null) {
        developer.log('❌ [OCR] Upload data is null');
        developer.log('📦 [OCR] Full response: ${uploadResponse.jsonResponse}');
        _safeEmit(ScanBolFailure(
          errorMessage: 'Invalid upload response format',
          detailedError: 'Data field is missing in response',
        ));
        return;
      }

      // Try to get filename from different possible fields
      String? filename;
      if (uploadData is Map) {
        developer.log('🔍 [OCR] Upload data keys: ${uploadData.keys}');

        filename = uploadData['path']?.toString();
        developer.log('🔍 [OCR] path field: $filename');

        if (filename == null || filename.isEmpty) {
          filename = uploadData['filename']?.toString();
          developer.log('🔍 [OCR] filename field: $filename');
        }

        if (filename == null || filename.isEmpty) {
          final url = uploadData['url']?.toString();
          developer.log('🔍 [OCR] url field: $url');
          if (url != null && url.isNotEmpty) {
            filename = url.split('/').last;
            developer.log('🔍 [OCR] Extracted from URL: $filename');
          }
        }
      }

      developer.log('📝 [OCR] Final extracted filename: $filename');

      if (filename == null || filename.isEmpty) {
        developer.log('❌ [OCR] Could not extract filename from upload response');
        developer.log('📦 [OCR] Full upload data: $uploadData');
        _safeEmit(ScanBolFailure(
          errorMessage: 'Could not get image filename',
          detailedError: 'Filename not found in upload response',
        ));
        return;
      }

      developer.log('✅ [OCR] Image uploaded successfully. Filename: $filename');

      // Step 6: Call OCR API with increased timeout
      developer.log('🤖 [OCR] ========== CALLING OCR API ==========');
      developer.log('🤖 [OCR] OCR URL: ${AppUrl.scanDocOcr}');
      developer.log('🤖 [OCR] Payload: {"bolImage": "$filename"}');
      _safeEmit(const ScanBolLoading(progressMessage: 'Extracting data from document...'));

      final ocrResponse = await _callOCRAPIWithTimeout(filename, token);

      developer.log('📡 [OCR] ========== OCR RESPONSE ==========');
      developer.log('📡 [OCR] Code: ${ocrResponse.code}');
      developer.log('📡 [OCR] Message: ${ocrResponse.message}');
      developer.log('📡 [OCR] Data: ${ocrResponse.data}');

      // Step 7: Process OCR response
      if (ocrResponse.data != null) {
        developer.log('✅ [OCR] ========== OCR SUCCESS ==========');
        developer.log('📋 [OCR] Load ID: ${ocrResponse.data!.loadIdString}');
        developer.log('📋 [OCR] Company: ${ocrResponse.data!.companyName}');
        developer.log('📋 [OCR] Pickup: ${ocrResponse.data!.pickupAddress}');
        developer.log('📋 [OCR] Delivery: ${ocrResponse.data!.deliveryAddress}');
        developer.log('📋 [OCR] Date: ${ocrResponse.data!.pickupDate}');
        developer.log('📋 [OCR] Bol Image: ${ocrResponse.data!.bolImage}');
        developer.log('📋 [OCR] Is Modified: ${ocrResponse.data!.isModified}');
        developer.log('✅ [OCR] =====================================');

        _safeEmit(ScanBolSuccess(ocrData: ocrResponse.data!));
      } else {
        developer.log('❌ [OCR] No data received from OCR');
        developer.log('📡 [OCR] OCR Response: $ocrResponse');
        _safeEmit(ScanBolFailure(
          errorMessage: 'No data received from OCR',
          detailedError: 'OCR response code: ${ocrResponse.code}, message: ${ocrResponse.message}',
        ));
      }
    } catch (e, stackTrace) {
      developer.log('❌ [OCR] ========== EXCEPTION OCCURRED ==========');
      developer.log('❌ [OCR] Exception: $e');
      developer.log('📚 [OCR] Stack trace: $stackTrace');
      developer.log('❌ [OCR] =========================================');
      _safeEmit(ScanBolFailure(
        errorMessage: 'An error occurred',
        detailedError: e.toString(),
      ));
    }
  }

  Future<OCRResponse> _callOCRAPIWithTimeout(String filename, String token) async {
    try {
      developer.log('📤 [OCR API] Sending request to OCR endpoint');
      developer.log('📤 [OCR API] URL: ${AppUrl.scanDocOcr}');
      developer.log('📤 [OCR API] Payload: {"bolImage": "$filename"}');

      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
          sendTimeout: const Duration(minutes: 2),
          validateStatus: (status) => status != null && status >= 200 && status < 600,
        ),
      );

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          developer.log('📤 [DIO] Request: ${options.method} ${options.path}');
          developer.log('📤 [DIO] Headers: ${options.headers}');
          developer.log('📤 [DIO] Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          developer.log('📥 [DIO] Response Status: ${response.statusCode}');
          developer.log('📥 [DIO] Response Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          developer.log('❌ [DIO] Error: ${error.message}');
          developer.log('❌ [DIO] Error Type: ${error.type}');
          if (error.response != null) {
            developer.log('❌ [DIO] Error Status: ${error.response?.statusCode}');
            developer.log('❌ [DIO] Error Data: ${error.response?.data}');
          }
          return handler.next(error);
        },
      ));

      final stopwatch = Stopwatch()..start();
      developer.log('⏱️ [OCR API] Request started at: ${DateTime.now()}');

      final response = await dio.post(
        AppUrl.scanDocOcr,
        data: {
          'bolImage': filename,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      stopwatch.stop();
      developer.log('⏱️ [OCR API] Request completed in: ${stopwatch.elapsedMilliseconds}ms');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return OCRResponse.fromJson(response.data);
      } else {
        String errorMsg = 'Server returned status code: ${response.statusCode}';
        if (response.data != null) {
          final data = response.data as Map?;
          if (data != null) {
            errorMsg = data['message']?.toString() ?? data['error']?.toString() ?? errorMsg;
          }
        }
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      developer.log('❌ [OCR API] ========== DIO ERROR DETAILS ==========');
      developer.log('❌ [OCR API] Error Message: ${e.message}');
      developer.log('❌ [OCR API] Error Type: ${e.type}');
      developer.log('❌ [OCR API] Error Response: ${e.response}');

      if (e.response != null) {
        developer.log('❌ [OCR API] Status Code: ${e.response?.statusCode}');
        developer.log('❌ [OCR API] Response Data: ${e.response?.data}');
      }

      if (e.requestOptions != null) {
        developer.log('❌ [OCR API] Request URL: ${e.requestOptions.uri}');
        developer.log('❌ [OCR API] Request Data: ${e.requestOptions.data}');
      }
      developer.log('❌ [OCR API] ==========================================');

      throw Exception('OCR request failed: ${e.message}');
    } catch (e) {
      developer.log('❌ [OCR API] General Exception: $e');
      rethrow;
    }
  }

  void resetState() {
    developer.log('🔄 [OCR] Resetting state');
    if (!_isClosed && !isClosed) {
      emit(ScanBolInitial());
    }
  }
}