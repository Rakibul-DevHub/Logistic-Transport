// lib/feature/profile/cubit/image_upload_event.dart
import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ImageUploadEvent extends Equatable {
  const ImageUploadEvent();

  @override
  List<Object?> get props => [];
}

class UploadProfileImage extends ImageUploadEvent {
  final File imageFile;

  const UploadProfileImage({required this.imageFile});

  @override
  List<Object?> get props => [imageFile];
}

class UploadMultipleImages extends ImageUploadEvent {
  final List<File> imageFiles;

  const UploadMultipleImages({required this.imageFiles});

  @override
  List<Object?> get props => [imageFiles];
}

class ClearImageUploadState extends ImageUploadEvent {}