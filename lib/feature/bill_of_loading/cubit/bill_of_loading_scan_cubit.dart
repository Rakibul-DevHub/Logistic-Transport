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
  /// User-facing status text, e.g. "Uploading image..."
  final String progressMessage;

  /// Overall progress 0.0 – 1.0
  final double progress;

  /// preparing | uploading | extracting
  final String stage;

  const ScanBolLoading({
    required this.progressMessage,
    this.progress = 0.0,
    this.stage = 'preparing',
  });

  @override
  List<Object?> get props => [progressMessage, progress, stage];
}

class ScanBolCancelled extends ScanBolState {
  const ScanBolCancelled();
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
  bool _isCancelled = false;
  CancelToken? _cancelToken;

  ScanBolCubit() : super(ScanBolInitial());

  @override
  Future<void> close() {
    _isClosed = true;
    _cancelToken?.cancel('Cubit closed');
    return super.close();
  }

  void _safeEmit(ScanBolState state) {
    if (!_isClosed && !isClosed && !_isCancelled) {
      emit(state);
    }
  }

  /// Cancel in-flight upload / OCR and stop emitting further results.
  void cancel() {
    developer.log('🛑 [OCR] Cancel requested');
    _isCancelled = true;
    _cancelToken?.cancel('User cancelled');
    if (!_isClosed && !isClosed) {
      emit(const ScanBolCancelled());
    }
  }

  Future<void> processOCR(String imagePath) async {
    _isCancelled = false;
    _cancelToken = CancelToken();

    try {
      developer.log('🚀 [OCR] ========== STARTING OCR PROCESS ==========');
      developer.log('📁 [OCR] Image path: $imagePath');

      _safeEmit(const ScanBolLoading(
        progressMessage: 'Preparing image...',
        progress: 0.08,
        stage: 'preparing',
      ));

      final token = await SecureStorageService.instance.getAccessToken();
      if (_isCancelled) return;

      if (token == null || token.isEmpty) {
        _safeEmit(const ScanBolFailure(errorMessage: 'Please login again'));
        return;
      }

      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        _safeEmit(const ScanBolFailure(errorMessage: 'Image file not found'));
        return;
      }

      if (_isCancelled) return;

      _safeEmit(const ScanBolLoading(
        progressMessage: 'Uploading image...',
        progress: 0.15,
        stage: 'uploading',
      ));

      final uploadResponse = await _networkCaller.uploadImageWithProgress(
        AppUrl.singleImageUpload,
        imageFile: imageFile,
        headers: {'Authorization': 'Bearer $token'},
        fileFieldName: 'file',
        method: 'POST',
        cancelToken: _cancelToken,
        onProgress: (sent, total) {
          if (_isCancelled || total <= 0) return;
          // Map upload bytes to 0.15 → 0.55 overall
          final uploadFraction = (sent / total).clamp(0.0, 1.0);
          final overall = 0.15 + (uploadFraction * 0.40);
          final percent = (uploadFraction * 100).round();
          _safeEmit(ScanBolLoading(
            progressMessage: 'Uploading image... $percent%',
            progress: overall,
            stage: 'uploading',
          ));
        },
      );

      if (_isCancelled) return;

      if (uploadResponse.errorMessage == 'cancelled') {
        return;
      }

      if (!uploadResponse.isSuccess) {
        String errorMsg =
            uploadResponse.errorMessage ?? 'Failed to upload image';

        final errorData = uploadResponse.jsonResponse;
        if (errorData != null) {
          errorMsg = errorData['message']?.toString() ??
              errorData['error']?.toString() ??
              errorData['msg']?.toString() ??
              errorMsg;
        }

        _safeEmit(ScanBolFailure(
          errorMessage: 'Failed to upload image',
          detailedError: errorMsg,
          statusCode: uploadResponse.statusCode,
        ));
        return;
      }

      if (uploadResponse.jsonResponse == null) {
        _safeEmit(const ScanBolFailure(
          errorMessage: 'Invalid upload response',
          detailedError: 'Response body is null',
        ));
        return;
      }

      final uploadData = uploadResponse.jsonResponse?['data'];
      if (uploadData == null) {
        _safeEmit(const ScanBolFailure(
          errorMessage: 'Invalid upload response format',
          detailedError: 'Data field is missing in response',
        ));
        return;
      }

      String? filename;
      if (uploadData is Map) {
        filename = uploadData['path']?.toString();
        if (filename == null || filename.isEmpty) {
          filename = uploadData['filename']?.toString();
        }
        if (filename == null || filename.isEmpty) {
          final url = uploadData['url']?.toString();
          if (url != null && url.isNotEmpty) {
            filename = url.split('/').last;
          }
        }
      }

      if (filename == null || filename.isEmpty) {
        _safeEmit(const ScanBolFailure(
          errorMessage: 'Could not get image filename',
          detailedError: 'Filename not found in upload response',
        ));
        return;
      }

      if (_isCancelled) return;

      _safeEmit(const ScanBolLoading(
        progressMessage: 'Extracting data from document...',
        progress: 0.60,
        stage: 'extracting',
      ));

      // Soft progress while OCR runs (indeterminate-ish)
      _bumpExtractProgress();

      final ocrResponse = await _callOCRAPIWithTimeout(filename, token);

      if (_isCancelled) return;

      if (ocrResponse.data != null) {
        _safeEmit(const ScanBolLoading(
          progressMessage: 'Almost done...',
          progress: 0.95,
          stage: 'extracting',
        ));
        _safeEmit(ScanBolSuccess(ocrData: ocrResponse.data!));
      } else {
        _safeEmit(ScanBolFailure(
          errorMessage: 'No data received from OCR',
          detailedError:
              'OCR response code: ${ocrResponse.code}, message: ${ocrResponse.message}',
        ));
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e) || _isCancelled) {
        developer.log('🛑 [OCR] Request cancelled');
        return;
      }
      _safeEmit(ScanBolFailure(
        errorMessage: 'An error occurred',
        detailedError: e.message ?? e.toString(),
      ));
    } catch (e, stackTrace) {
      if (_isCancelled) return;
      developer.log('❌ [OCR] Exception: $e');
      developer.log('📚 [OCR] Stack trace: $stackTrace');
      _safeEmit(ScanBolFailure(
        errorMessage: 'An error occurred',
        detailedError: e.toString(),
      ));
    }
  }

  void _bumpExtractProgress() {
    // Fire-and-forget soft bumps while waiting for OCR
    Future(() async {
      const steps = [0.68, 0.75, 0.82, 0.88];
      for (final value in steps) {
        await Future.delayed(const Duration(seconds: 2));
        if (_isCancelled || _isClosed || isClosed) return;
        if (state is! ScanBolLoading) return;
        final current = state as ScanBolLoading;
        if (current.stage != 'extracting') return;
        if (current.progress >= value) continue;
        _safeEmit(ScanBolLoading(
          progressMessage: current.progressMessage,
          progress: value,
          stage: 'extracting',
        ));
      }
    });
  }

  Future<OCRResponse> _callOCRAPIWithTimeout(String filename, String token) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
        sendTimeout: const Duration(minutes: 2),
        validateStatus: (status) => status != null && status >= 200 && status < 600,
      ),
    );

    final response = await dio.post(
      AppUrl.scanDocOcr,
      data: {'bolImage': filename},
      cancelToken: _cancelToken,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return OCRResponse.fromJson(response.data);
    }

    String errorMsg = 'Server returned status code: ${response.statusCode}';
    if (response.data is Map) {
      final data = response.data as Map;
      errorMsg =
          data['message']?.toString() ?? data['error']?.toString() ?? errorMsg;
    }
    throw Exception(errorMsg);
  }

  void resetState() {
    developer.log('🔄 [OCR] Resetting state');
    _isCancelled = false;
    _cancelToken = null;
    if (!_isClosed && !isClosed) {
      emit(ScanBolInitial());
    }
  }
}
