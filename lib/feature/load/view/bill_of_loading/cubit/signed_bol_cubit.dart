import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';

// ==================== STATES ====================

abstract class SignedBolState extends Equatable {
  const SignedBolState();
  @override
  List<Object?> get props => [];
}

class SignedBolInitial extends SignedBolState {}

class SignedBolLoading extends SignedBolState {}

class SignedBolUploadSuccess extends SignedBolState {
  final String imageUrl;
  const SignedBolUploadSuccess({required this.imageUrl});
  @override
  List<Object?> get props => [imageUrl];
}

class SignedBolFailure extends SignedBolState {
  final String errorMessage;
  const SignedBolFailure({required this.errorMessage});
  @override
  List<Object?> get props => [errorMessage];
}

// ==================== CUBIT ====================

class SignedBolCubit extends Cubit<SignedBolState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  SignedBolCubit() : super(SignedBolInitial()) {
    debugPrint('🔵 SignedBolCubit created');
  }

  @override
  Future<void> close() {
    debugPrint('🔴 SignedBolCubit closing');
    return super.close();
  }

  Future<void> uploadSignedBol({
    required String loadId,
    required File imageFile,
  }) async {
    debugPrint('📤 ========== UPLOAD SIGNED BOL START ==========');
    debugPrint('📤 loadId: $loadId');
    debugPrint('📤 imageFile path: ${imageFile.path}');
    debugPrint('📤 imageFile exists: ${imageFile.existsSync()}');

    if (imageFile.existsSync()) {
      debugPrint('📤 imageFile size: ${imageFile.lengthSync()} bytes');
    } else {
      debugPrint('❌ imageFile does NOT exist!');
      emit(const SignedBolFailure(
        errorMessage: 'Image file does not exist',
      ));
      return;
    }

    emit(SignedBolLoading());
    debugPrint('📤 Emitted SignedBolLoading state');

    try {
      final token = await _storage.getAccessToken();
      debugPrint('📤 Token retrieved: ${token != null ? "Yes (length: ${token.length})" : "No"}');

      if (token == null || token.isEmpty) {
        debugPrint('❌ No access token available');
        emit(const SignedBolFailure(errorMessage: 'Please login again'));
        return;
      }

      final url = AppUrl.uploadSignedBol(loadId);
      debugPrint('📤 Upload URL: $url');

      // ✅ Use the correct field name from Postman: "bolImage"
      const String fieldName = 'bolImage';
      debugPrint('📤 Using field name: "$fieldName"');

      final response = await _networkCaller.uploadImage(
        url,
        imageFile: imageFile,
        fileFieldName: fieldName,
        headers: {
          'Authorization': 'Bearer $token',
        },
        method: 'POST',
      );

      debugPrint('📤 Response status: ${response.statusCode}');
      debugPrint('📤 Response isSuccess: ${response.isSuccess}');
      debugPrint('📤 Response body: ${response.jsonResponse}');
      debugPrint('📤 Response errorMessage: ${response.errorMessage}');

      if (!response.isSuccess || response.jsonResponse == null) {
        debugPrint('❌ Upload failed');

        if (response.statusCode == 401) {
          debugPrint('🔄 Token expired, clearing...');
          await _storage.deleteAccessToken();
          emit(const SignedBolFailure(
            errorMessage: 'Session expired. Please login again.',
          ));
          return;
        }
        emit(SignedBolFailure(
          errorMessage: response.errorMessage ?? 'Failed to upload signed BOL',
        ));
        return;
      }

      debugPrint('📤 Parsing response data...');

      // ✅ The response from your API has the data directly in the root
      // The response structure is: { "code": 200, "data": { ... } }
      // So we need to check both root-level and data-level
      Map<String, dynamic> responseData = response.jsonResponse!;
      String? imageUrl;

      // First, check if the response itself has the fields directly
      if (responseData['signedBolImages'] != null) {
        final signedBolImages = responseData['signedBolImages'] as List;
        if (signedBolImages.isNotEmpty) {
          final imagePath = signedBolImages.first.toString();
          imageUrl = imagePath.startsWith('http')
              ? imagePath
              : '${AppUrl.imageBaseUrl}/$imagePath';
          debugPrint('✅ Signed BOL Image URL from root: $imageUrl');
        }
      }

      // If not found in root, check in the data object
      if (imageUrl == null && responseData['data'] is Map<String, dynamic>) {
        final data = responseData['data'] as Map<String, dynamic>;
        if (data['signedBolImages'] != null) {
          final signedBolImages = data['signedBolImages'] as List;
          if (signedBolImages.isNotEmpty) {
            final imagePath = signedBolImages.first.toString();
            imageUrl = imagePath.startsWith('http')
                ? imagePath
                : '${AppUrl.imageBaseUrl}/$imagePath';
            debugPrint('✅ Signed BOL Image URL from data: $imageUrl');
          }
        }
      }

      // Also check for bolImage field as a fallback
      if (imageUrl == null && responseData['bolImage'] != null) {
        final imagePath = responseData['bolImage'].toString();
        imageUrl = imagePath.startsWith('http')
            ? imagePath
            : '${AppUrl.imageBaseUrl}/$imagePath';
        debugPrint('✅ Image URL from bolImage: $imageUrl');
      }

      if (imageUrl == null && responseData['data'] is Map<String, dynamic>) {
        final data = responseData['data'] as Map<String, dynamic>;
        if (data['bolImage'] != null) {
          final imagePath = data['bolImage'].toString();
          imageUrl = imagePath.startsWith('http')
              ? imagePath
              : '${AppUrl.imageBaseUrl}/$imagePath';
          debugPrint('✅ Image URL from data.bolImage: $imageUrl');
        }
      }

      if (imageUrl != null) {
        debugPrint('✅ Upload successful!');
        debugPrint('✅ Image URL: $imageUrl');
        emit(SignedBolUploadSuccess(imageUrl: imageUrl));
      } else {
        debugPrint('❌ No image URL found in response');
        debugPrint('❌ Full response: $responseData');
        emit(const SignedBolFailure(errorMessage: 'No image URL returned from server'));
      }
    } catch (e) {
      debugPrint('❌ SignedBolCubit error: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
      emit(SignedBolFailure(errorMessage: e.toString()));
    }
    debugPrint('📤 ========== UPLOAD SIGNED BOL END ==========');
  }

  void reset() {
    debugPrint('🔄 SignedBolCubit reset called');
    emit(SignedBolInitial());
  }
}