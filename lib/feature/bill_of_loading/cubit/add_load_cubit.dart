import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import '../model/add_load_data.dart';

// ==================== STATES ====================
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

// ==================== CUBIT ====================
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

      // 1) Optional BOL upload (same NetworkCaller)
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

      // 2) Build request body HERE (not in model file)
      final cleanedNotes = notes?.trim();
      final body = <String, dynamic>{
        'loadId': loadId.trim(),
        'companyName': companyName.trim(),
        'pickupCoordinates': pickupCoordinates,
        'deliveryCoordinates': deliveryCoordinates,
        'pickupDate': pickupDateIso,
        'rate': rate,
        if (uploadedBolPath != null && uploadedBolPath.isNotEmpty)
          'bolImage': uploadedBolPath,
        if (cleanedNotes != null && cleanedNotes.isNotEmpty) 'notes': cleanedNotes,
      };

      emit(const AddLoadLoading(progressMessage: 'Creating load...'));

      // 3) Your existing NetworkCaller
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

  void reset() => emit(AddLoadInitial());
}