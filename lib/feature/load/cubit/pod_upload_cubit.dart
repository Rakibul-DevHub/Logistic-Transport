import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';

// ==================== POD STATES ====================

abstract class PODState extends Equatable {
  const PODState();
  @override
  List<Object?> get props => [];
}

class PODInitial extends PODState {}

class PODLoading extends PODState {}

class PODUploadSuccess extends PODState {
  final String imageUrl;
  const PODUploadSuccess({required this.imageUrl});
  @override
  List<Object?> get props => [imageUrl];
}

class PODFailure extends PODState {
  final String errorMessage;
  const PODFailure({required this.errorMessage});
  @override
  List<Object?> get props => [errorMessage];
}

// ==================== POD CUBIT ====================

class PODCubit extends Cubit<PODState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  PODCubit() : super(PODInitial());

  /// Upload POD image to the server
  Future<void> uploadPOD({
    required String loadId,
    required File imageFile,
  }) async {
    emit(PODLoading());
    try {
      // Get access token from secure storage
      final token = await _storage.getAccessToken();

      if (token == null || token.isEmpty) {
        emit(const PODFailure(errorMessage: 'Please login again'));
        return;
      }

      debugPrint('📤 Uploading POD for load: $loadId');
      debugPrint('📎 File size: ${await imageFile.length()} bytes');

      // Try with 'podImage' field name (matches the response structure)
      final response = await _networkCaller.uploadImage(
        AppUrl.uploadPod(loadId),
        imageFile: imageFile,
        fileFieldName: 'podImage', // Use 'podImage' as it matches the response
        headers: {
          'Authorization': 'Bearer $token',
        },
        method: 'POST',
      );

      debugPrint('📊 Upload Response Status: ${response.statusCode}');
      debugPrint('📊 Upload Response Success: ${response.isSuccess}');
      debugPrint('📊 Upload Response Data: ${response.jsonResponse}');

      if (!response.isSuccess) {
        // Handle specific error cases
        if (response.statusCode == 401) {
          await _storage.deleteAccessToken();
          emit(const PODFailure(
            errorMessage: 'Session expired. Please login again.',
          ));
          return;
        }

        // If 'podImage' fails, try with 'image' as fallback
        if (response.errorMessage?.contains('Unexpected field') == true) {
          debugPrint('🔄 Retrying with field name: image');
          final retryResponse = await _networkCaller.uploadImage(
            AppUrl.uploadPod(loadId),
            imageFile: imageFile,
            fileFieldName: 'image',
            headers: {
              'Authorization': 'Bearer $token',
            },
            method: 'POST',
          );

          if (retryResponse.isSuccess && retryResponse.jsonResponse != null) {
            final data = retryResponse.jsonResponse!['data'] as Map<String, dynamic>?;
            String? imageUrl;

            if (data != null && data['podImages'] != null) {
              final podImages = data['podImages'] as List;
              if (podImages.isNotEmpty) {
                final imagePath = podImages.first.toString();
                imageUrl = imagePath.startsWith('http')
                    ? imagePath
                    : '${AppUrl.imageBaseUrl}/$imagePath';
              }
            }

            if (imageUrl != null) {
              emit(PODUploadSuccess(imageUrl: imageUrl));
              return;
            }
          }
        }

        emit(PODFailure(
          errorMessage: response.errorMessage ?? 'Failed to upload POD',
        ));
        return;
      }

      if (response.jsonResponse == null) {
        emit(const PODFailure(errorMessage: 'No response from server'));
        return;
      }

      // Parse the response to get the image URL
      final data = response.jsonResponse!['data'] as Map<String, dynamic>?;
      String? imageUrl;

      if (data != null && data['podImages'] != null) {
        final podImages = data['podImages'];
        if (podImages is List && podImages.isNotEmpty) {
          final imagePath = podImages.first.toString();
          imageUrl = imagePath.startsWith('http')
              ? imagePath
              : '${AppUrl.imageBaseUrl}/$imagePath';
          debugPrint('✅ POD Image URL: $imageUrl');
        }
      }

      if (imageUrl != null && imageUrl.isNotEmpty) {
        emit(PODUploadSuccess(imageUrl: imageUrl));
      } else {
        emit(const PODFailure(errorMessage: 'No image URL returned from server'));
      }
    } catch (e) {
      debugPrint('❌ PODCubit error: $e');
      emit(PODFailure(errorMessage: e.toString()));
    }
  }

  /// Reset the state to initial
  void reset() {
    emit(PODInitial());
  }
}