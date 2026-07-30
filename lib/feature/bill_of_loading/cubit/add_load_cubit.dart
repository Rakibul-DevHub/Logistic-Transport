/**
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import '../model/add_load_data.dart';

abstract class AddLoadState extends Equatable {
  const AddLoadState();

  @override
  List<Object?> get props => [];
}

class AddLoadInitial extends AddLoadState {}

class AddLoadLoading extends AddLoadState {
  final String? progressMessage;

  const AddLoadLoading({this.progressMessage});

  @override
  List<Object?> get props => [progressMessage];
}

class AddLoadSuccess extends AddLoadState {
  final AddLoadData data;
  final String message;

  const AddLoadSuccess({
    required this.data,
    this.message = 'Load created successfully',
  });

  @override
  List<Object?> get props => [data, message];
}

class AddLoadFailure extends AddLoadState {
  final String errorMessage;

  const AddLoadFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class AddLoadCubit extends Cubit<AddLoadState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  AddLoadCubit() : super(AddLoadInitial());

  Future<void> createManualLoad({
    required String loadId,
    required String companyName,
    required List<double> pickupCoordinates,
    required List<double> deliveryCoordinates,
    required String pickupDateIso,
    required num rate,
    String? pickupAddress,
    String? deliveryAddress,
    File? bolImageFile,
    String? notes,
  }) async
  {
    try {
      emit(const AddLoadLoading(progressMessage: 'Preparing...'));

      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        emit(const AddLoadFailure(errorMessage: 'Please login again'));
        return;
      }

      String? uploadedBolPath;

      if (bolImageFile != null) {
        if (!await bolImageFile.exists()) {
          emit(const AddLoadFailure(errorMessage: 'Image file not found'));
          return;
        }

        emit(const AddLoadLoading(progressMessage: 'Uploading document...'));

        final uploadResponse = await _networkCaller.uploadImage(
          AppUrl.singleImageUpload,
          imageFile: bolImageFile,
          headers: {'Authorization': 'Bearer $token'},
          fileFieldName: 'file',
          method: 'POST',
        );

        if (!uploadResponse.isSuccess || uploadResponse.jsonResponse == null) {
          emit(AddLoadFailure(
            errorMessage:
            uploadResponse.errorMessage ?? 'Failed to upload document',
          ));
          return;
        }

        final uploadData = uploadResponse.jsonResponse?['data'];
        if (uploadData is Map) {
          uploadedBolPath = uploadData['path']?.toString() ??
              uploadData['filename']?.toString() ??
              uploadData['url']?.toString()?.split('/').last;
        }

        if (uploadedBolPath == null || uploadedBolPath.isEmpty) {
          emit(const AddLoadFailure(
            errorMessage: 'Could not get uploaded image path',
          ));
          return;
        }
      }

      final cleanedNotes = notes?.trim();
      final cleanedPickupAddress = pickupAddress?.trim() ?? '';
      final cleanedDeliveryAddress = deliveryAddress?.trim() ?? '';

      final body = <String, dynamic>{
        'loadId': loadId.trim(),
        'companyName': companyName.trim(),
        'pickupCoordinates': pickupCoordinates,
        'pickupAddress': cleanedPickupAddress,
        'deliveryCoordinates': deliveryCoordinates,
        'deliveryAddress': cleanedDeliveryAddress,
        'pickupDate': pickupDateIso,
        'rate': rate,
        if (uploadedBolPath != null && uploadedBolPath.isNotEmpty)
          'bolImage': uploadedBolPath,
        if (cleanedNotes != null && cleanedNotes.isNotEmpty) 'notes': cleanedNotes,
      };

      emit(const AddLoadLoading(progressMessage: 'Creating load...'));

      final response = await _networkCaller.postRequest(
        AppUrl.addLoad,
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final parsed = AddLoadResponse.fromJson(response.jsonResponse!);
        if (parsed.data != null) {
          // Keep addresses on success object if API doesn't echo them back
          final data = AddLoadData(
            id: parsed.data!.id,
            userId: parsed.data!.userId,
            parentDriverId: parsed.data!.parentDriverId,
            loadId: parsed.data!.loadId,
            companyName: parsed.data!.companyName,
            pickupCoordinates: parsed.data!.pickupCoordinates,
            deliveryCoordinates: parsed.data!.deliveryCoordinates,
            pickupAddress: parsed.data!.pickupAddress?.isNotEmpty == true
                ? parsed.data!.pickupAddress
                : cleanedPickupAddress,
            deliveryAddress: parsed.data!.deliveryAddress?.isNotEmpty == true
                ? parsed.data!.deliveryAddress
                : cleanedDeliveryAddress,
            pickupDate: parsed.data!.pickupDate,
            rate: parsed.data!.rate,
            bolImage: parsed.data!.bolImage,
            notes: parsed.data!.notes,
            status: parsed.data!.status,
            createdAt: parsed.data!.createdAt,
            updatedAt: parsed.data!.updatedAt,
          );

          emit(AddLoadSuccess(
            data: data,
            message: parsed.message ?? 'Load created successfully',
          ));
          return;
        }
      }

      emit(AddLoadFailure(
        errorMessage: response.errorMessage ??
            response.jsonResponse?['message']?.toString() ??
            'Failed to create load',
      ));
    } catch (e) {
      emit(AddLoadFailure(errorMessage: e.toString()));
    }
  }



  /// Create load from OCR scan (edited form values)
  Future<void> createFromOcr({
    required String loadId,
    required String companyName,
    required String pickupAddress,
    required String deliveryAddress,
    required String pickupDateIso,
    required num rate,
    List<double>? pickupCoordinates,
    List<double>? deliveryCoordinates,
    String? bolImage,
    bool isModified = false,
  }) async {
    try {
      emit(const AddLoadLoading(progressMessage: 'Creating load from scan...'));

      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        emit(const AddLoadFailure(errorMessage: 'Please login again'));
        return;
      }

      final body = <String, dynamic>{
        'loadId': loadId.trim(),
        'companyName': companyName.trim(),
        'pickupAddress': pickupAddress.trim(),
        'deliveryAddress': deliveryAddress.trim(),
        'pickupDate': pickupDateIso,
        'rate': rate,
        if (pickupCoordinates != null && pickupCoordinates.length >= 2)
          'pickupCoordinates': pickupCoordinates,
        if (deliveryCoordinates != null && deliveryCoordinates.length >= 2)
          'deliveryCoordinates': deliveryCoordinates,
        if (bolImage != null && bolImage.isNotEmpty) 'bolImage': bolImage,
        'isModified': isModified,
      };

      final response = await _networkCaller.postRequest(
        AppUrl.createBillOfLoad, // /load/create-from-ocr
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final parsed = AddLoadResponse.fromJson(response.jsonResponse!);
        if (parsed.data != null) {
          final data = AddLoadData(
            id: parsed.data!.id,
            userId: parsed.data!.userId,
            parentDriverId: parsed.data!.parentDriverId,
            loadId: parsed.data!.loadId ?? loadId.trim(),
            companyName: parsed.data!.companyName ?? companyName.trim(),
            pickupCoordinates:
            parsed.data!.pickupCoordinates ?? pickupCoordinates,
            deliveryCoordinates:
            parsed.data!.deliveryCoordinates ?? deliveryCoordinates,
            pickupAddress: (parsed.data!.pickupAddress?.isNotEmpty == true)
                ? parsed.data!.pickupAddress
                : pickupAddress.trim(),
            deliveryAddress: (parsed.data!.deliveryAddress?.isNotEmpty == true)
                ? parsed.data!.deliveryAddress
                : deliveryAddress.trim(),
            pickupDate: parsed.data!.pickupDate ?? pickupDateIso,
            rate: parsed.data!.rate ?? rate,
            bolImage: parsed.data!.bolImage ?? bolImage,
            notes: parsed.data!.notes,
            status: parsed.data!.status ?? 'pending',
            createdAt: parsed.data!.createdAt,
            updatedAt: parsed.data!.updatedAt,
          );

          emit(AddLoadSuccess(
            data: data,
            message: parsed.message ?? 'Load created successfully',
          ));
          return;
        }
      }

      // Fallback: still open details with form/OCR data if API shape differs
      emit(AddLoadSuccess(
        data: AddLoadData(
          loadId: loadId.trim(),
          companyName: companyName.trim(),
          pickupAddress: pickupAddress.trim(),
          deliveryAddress: deliveryAddress.trim(),
          pickupCoordinates: pickupCoordinates,
          deliveryCoordinates: deliveryCoordinates,
          pickupDate: pickupDateIso,
          rate: rate,
          bolImage: bolImage,
          status: 'pending',
        ),
        message: response.errorMessage ??
            response.jsonResponse?['message']?.toString() ??
            'Load prepared from scan',
      ));
    } catch (e) {
      emit(AddLoadFailure(errorMessage: e.toString()));
    }
  }

  void reset() => emit(AddLoadInitial());
}*/








///
///
///
///
/// todo:: updating the design and the api implementation will be change
///
///
///
///







import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import '../model/add_load_data.dart';

// ============================================================
// 1. ADD LOAD RESPONSE CLASS (move this near the model imports)
// ============================================================
class AddLoadResponse {
  final int? code;
  final String? message;
  final AddLoadData? data;

  AddLoadResponse({
    this.code,
    this.message,
    this.data,
  });

  factory AddLoadResponse.fromJson(Map<String, dynamic> json) {
    return AddLoadResponse(
      code: json['code'] as int?,
      message: json['message']?.toString(),
      data: json['data'] != null
          ? AddLoadData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ============================================================
// 2. STATE DEFINITIONS
// ============================================================
abstract class AddLoadState extends Equatable {
  const AddLoadState();

  @override
  List<Object?> get props => [];
}

class AddLoadInitial extends AddLoadState {}

class AddLoadLoading extends AddLoadState {
  final String? progressMessage;

  const AddLoadLoading({this.progressMessage});

  @override
  List<Object?> get props => [progressMessage];
}

class AddLoadSuccess extends AddLoadState {
  final AddLoadData data;
  final String message;

  const AddLoadSuccess({
    required this.data,
    this.message = 'Load created successfully',
  });

  @override
  List<Object?> get props => [data, message];
}

class AddLoadFailure extends AddLoadState {
  final String errorMessage;

  const AddLoadFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

// ============================================================
// 3. CUBIT IMPLEMENTATION
// ============================================================
class AddLoadCubit extends Cubit<AddLoadState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  AddLoadCubit() : super(AddLoadInitial());

  Future<void> createManualLoad({
    required String loadId,
    required String companyName,
    required List<List<double>> pickupCoordinates,
    required List<List<double>> deliveryCoordinates,
    required List<String> pickupAddresses,
    required List<String> deliveryAddresses,
    required String pickupDateIso,
    required num rate,
    File? bolImageFile,
    String? notes,
  }) async {
    try {
      emit(const AddLoadLoading(progressMessage: 'Preparing...'));

      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        emit(const AddLoadFailure(errorMessage: 'Please login again'));
        return;
      }

      String? uploadedBolPath;

      if (bolImageFile != null) {
        if (!await bolImageFile.exists()) {
          emit(const AddLoadFailure(errorMessage: 'Image file not found'));
          return;
        }

        emit(const AddLoadLoading(progressMessage: 'Uploading document...'));

        final uploadResponse = await _networkCaller.uploadImage(
          AppUrl.singleImageUpload,
          imageFile: bolImageFile,
          headers: {'Authorization': 'Bearer $token'},
          fileFieldName: 'file',
          method: 'POST',
        );

        if (!uploadResponse.isSuccess || uploadResponse.jsonResponse == null) {
          emit(AddLoadFailure(
            errorMessage: uploadResponse.errorMessage ?? 'Failed to upload document',
          ));
          return;
        }

        final uploadData = uploadResponse.jsonResponse?['data'];
        if (uploadData is Map) {
          uploadedBolPath = uploadData['path']?.toString() ??
              uploadData['filename']?.toString() ??
              uploadData['url']?.toString()?.split('/').last;
        }

        if (uploadedBolPath == null || uploadedBolPath.isEmpty) {
          emit(const AddLoadFailure(
            errorMessage: 'Could not get uploaded image path',
          ));
          return;
        }
      }

      final cleanedNotes = notes?.trim();
      final cleanedPickupAddresses = pickupAddresses.map((addr) => addr.trim()).toList();
      final cleanedDeliveryAddresses = deliveryAddresses.map((addr) => addr.trim()).toList();

      final body = <String, dynamic>{
        'loadId': loadId.trim(),
        'companyName': companyName.trim(),
        'pickupCoordinates': pickupCoordinates,
        'pickupAddresses': cleanedPickupAddresses,
        'deliveryCoordinates': deliveryCoordinates,
        'deliveryAddresses': cleanedDeliveryAddresses,
        'pickupDate': pickupDateIso,
        'rate': rate,
        if (uploadedBolPath != null && uploadedBolPath.isNotEmpty)
          'bolImage': uploadedBolPath,
        if (cleanedNotes != null && cleanedNotes.isNotEmpty) 'notes': cleanedNotes,
      };

      emit(const AddLoadLoading(progressMessage: 'Creating load...'));

      final response = await _networkCaller.postRequest(
        AppUrl.addLoad,
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final parsed = AddLoadResponse.fromJson(response.jsonResponse!);
        if (parsed.data != null) {
          emit(AddLoadSuccess(
            data: parsed.data!,
            message: parsed.message ?? 'Load created successfully',
          ));
          return;
        }
      }

      emit(AddLoadFailure(
        errorMessage: response.errorMessage ??
            response.jsonResponse?['message']?.toString() ??
            'Failed to create load',
      ));
    } catch (e) {
      emit(AddLoadFailure(errorMessage: e.toString()));
    }
  }

  /// Create load from OCR scan (edited form values)
  Future<void> createFromOcr({
    required String loadId,
    required String companyName,
    required String ocrCopyId,
    required List<String> pickupAddresses,
    required List<String> deliveryAddresses,
    required String pickupDateIso,
    required num rate,
    required List<List<double>> pickupCoordinates,
    required List<List<double>> deliveryCoordinates,
  }) async {
    try {
      emit(const AddLoadLoading(progressMessage: 'Creating load from scan...'));

      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        emit(const AddLoadFailure(errorMessage: 'Please login again'));
        return;
      }

      if (ocrCopyId.trim().isEmpty) {
        emit(const AddLoadFailure(
          errorMessage: 'Missing OCR copy id. Please scan the document again.',
        ));
        return;
      }

      final cleanedPickupAddresses =
          pickupAddresses.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final cleanedDeliveryAddresses =
          deliveryAddresses.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      final body = <String, dynamic>{
        'loadId': loadId.trim(),
        'companyName': companyName.trim(),
        'ocrCopyId': ocrCopyId.trim(),
        'pickupAddresses': cleanedPickupAddresses,
        'deliveryAddresses': cleanedDeliveryAddresses,
        'pickupDate': pickupDateIso,
        'rate': rate,
        if (pickupCoordinates.isNotEmpty) 'pickupCoordinates': pickupCoordinates,
        if (deliveryCoordinates.isNotEmpty)
          'deliveryCoordinates': deliveryCoordinates,
      };

      final response = await _networkCaller.postRequest(
        AppUrl.createBillOfLoad,
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final parsed = AddLoadResponse.fromJson(response.jsonResponse!);
        if (parsed.data != null) {
          emit(AddLoadSuccess(
            data: parsed.data!,
            message: parsed.message ?? 'Load created successfully',
          ));
          return;
        }
      }

      emit(AddLoadFailure(
        errorMessage: _extractErrorMessage(
          response.errorMessage,
          response.jsonResponse,
          fallback: 'Failed to create load from OCR',
        ),
      ));
    } catch (e) {
      emit(AddLoadFailure(errorMessage: e.toString()));
    }
  }

  String _extractErrorMessage(
    String? errorMessage,
    Map<String, dynamic>? json, {
    required String fallback,
  }) {
    if (json == null) return errorMessage ?? fallback;

    final message = json['message']?.toString();
    if (message != null && message.isNotEmpty) return message;

    final errors = json['error'];
    if (errors is List && errors.isNotEmpty) {
      final parts = errors.map((e) {
        if (e is Map) {
          final path = e['path']?.toString() ?? '';
          final msg = e['message']?.toString() ?? '';
          if (path.isNotEmpty && msg.isNotEmpty) return '$path: $msg';
          return msg.isNotEmpty ? msg : path;
        }
        return e.toString();
      }).where((e) => e.isNotEmpty).toList();
      if (parts.isNotEmpty) return parts.join('\n');
    }

    return errorMessage ?? fallback;
  }

  void reset() => emit(AddLoadInitial());
}