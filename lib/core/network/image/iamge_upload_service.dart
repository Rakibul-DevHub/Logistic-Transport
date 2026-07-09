import 'dart:io';
import 'package:flutter/cupertino.dart';
import '../../utils/app_url.dart';
import '../network_caller_dio.dart';
import '../secure_storage_service.dart';

class ImageUploadService {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        debugPrint('No access token found');
        return null;
      }

      // Use Dio's native upload method
      final response = await _networkCaller.uploadImage(
        AppUrl.updatePersonalInformationProfileImage,
        imageFile: imageFile,
        headers: {'Authorization': 'Bearer $token'},
        fileFieldName: 'profileImage',
      );

      debugPrint('📡 Upload response status: ${response.statusCode}');
      debugPrint('📡 Upload response success: ${response.isSuccess}');
      debugPrint('📡 Upload response body: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        String? imageUrl;

        // Try different paths to get the image URL
        imageUrl = response.jsonResponse?['data']?['attributes']?['updatedUser']?['profileImage']?['imageUrl'];

        if (imageUrl == null) {
          imageUrl = response.jsonResponse?['data']?['attributes']?['profileImage']?['imageUrl'];
        }

        if (imageUrl == null) {
          imageUrl = response.jsonResponse?['data']?['profileImage']?['imageUrl'];
        }

        if (imageUrl != null) {
          debugPrint('✅ Image uploaded successfully: $imageUrl');
          return _getFullImageUrl(imageUrl);
        } else {
          debugPrint('❌ Could not extract image URL from response');
          return null;
        }
      }

      debugPrint('❌ Upload failed: ${response.errorMessage}');
      return null;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<List<String>?> uploadMultipleImages(List<File> imageFiles) async {
    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        debugPrint('No access token found');
        return null;
      }

      final response = await _networkCaller.uploadMultipleImages(
        AppUrl.updatePersonalInformationProfileImage, // Update with your URL
        imageFiles: imageFiles,
        headers: {'Authorization': 'Bearer $token'},
        fileFieldName: 'images',
      );

      if (response.isSuccess && response.jsonResponse != null) {
        List<String> imageUrls = [];

        // Parse based on your API response structure
        // Example 1: If response has data.images array
        final imagesData = response.jsonResponse?['data']?['images'];
        if (imagesData is List) {
          for (var image in imagesData) {
            String? url = image['imageUrl'] ?? image['url'];
            if (url != null) {
              imageUrls.add(_getFullImageUrl(url));
            }
          }
        }

        // Example 2: If response has data.attributes.images
        if (imageUrls.isEmpty) {
          final imagesData = response.jsonResponse?['data']?['attributes']?['images'];
          if (imagesData is List) {
            for (var image in imagesData) {
              String? url = image['imageUrl'] ?? image['url'];
              if (url != null) {
                imageUrls.add(_getFullImageUrl(url));
              }
            }
          }
        }

        if (imageUrls.isNotEmpty) {
          debugPrint('✅ Images uploaded successfully: $imageUrls');
          return imageUrls;
        }
        return null;
      }

      debugPrint('❌ Upload failed: ${response.errorMessage}');
      return null;
    } catch (e) {
      debugPrint('Error uploading images: $e');
      return null;
    }
  }

  String _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return "assets/images/dummy_user_image.png";
    }
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    String cleanPath = imagePath;
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    return '${AppUrl.imageBaseUrl}/$cleanPath';
  }
}