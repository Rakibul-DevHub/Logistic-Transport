// lib/feature/profile/cubit/image_upload_state.dart
import 'package:equatable/equatable.dart';

class ImageUploadState extends Equatable {
  final bool isLoading;
  final String? imageUrl;
  final List<String>? imageUrls;
  final String? errorMessage;
  final bool isSuccess;

  const ImageUploadState({
    this.isLoading = false,
    this.imageUrl,
    this.imageUrls,
    this.errorMessage,
    this.isSuccess = false,
  });

  ImageUploadState copyWith({
    bool? isLoading,
    String? imageUrl,
    List<String>? imageUrls,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ImageUploadState(
      isLoading: isLoading ?? this.isLoading,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    imageUrl,
    imageUrls,
    errorMessage,
    isSuccess,
  ];
}