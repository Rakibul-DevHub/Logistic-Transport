// lib/feature/profile/cubit/image_upload_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';

import 'iamge_upload_service.dart';
import 'image_upload_state.dart';

class ImageUploadCubit extends Cubit<ImageUploadState> {
  final ImageUploadService _imageUploadService = ImageUploadService();

  ImageUploadCubit() : super(const ImageUploadState());

  /// Upload a single profile image
  Future<void> uploadProfileImage(File imageFile) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null, isSuccess: false));

      final imageUrl = await _imageUploadService.uploadProfileImage(imageFile);

      if (imageUrl != null) {
        emit(state.copyWith(
          isLoading: false,
          imageUrl: imageUrl,
          isSuccess: true,
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: 'Failed to upload image',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: 'Error uploading image: ${e.toString()}',
      ));
    }
  }

  /// Upload multiple images
  Future<void> uploadMultipleImages(List<File> imageFiles) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null, isSuccess: false));

      final imageUrls = await _imageUploadService.uploadMultipleImages(imageFiles);

      if (imageUrls != null && imageUrls.isNotEmpty) {
        emit(state.copyWith(
          isLoading: false,
          imageUrls: imageUrls,
          isSuccess: true,
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: 'Failed to upload images',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: 'Error uploading images: ${e.toString()}',
      ));
    }
  }

  /// Clear the upload state
  void clearState() {
    emit(const ImageUploadState());
  }

  /// Reset error state
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}