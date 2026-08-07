import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import 'package:tag/feature/bill_of_loading/model/add_load_data.dart';

import '../model/load_details_data.dart';

// ==================== STATES ====================

abstract class LoadDetailsState extends Equatable {
  const LoadDetailsState();
  @override
  List<Object?> get props => [];
}

class LoadDetailsInitial extends LoadDetailsState {}

class LoadDetailsLoading extends LoadDetailsState {}

class LoadDetailsSuccess extends LoadDetailsState {
  final AddLoadData loadData;

  const LoadDetailsSuccess({required this.loadData});

  @override
  List<Object?> get props => [loadData];
}

class LoadDetailsFailure extends LoadDetailsState {
  final String errorMessage;

  const LoadDetailsFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

// ==================== CUBIT ====================

class LoadDetailsCubit extends Cubit<LoadDetailsState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  LoadDetailsCubit() : super(LoadDetailsInitial());

  /// Fetch load details by ID
  Future<void> fetchLoadDetails(String loadId) async {
    emit(LoadDetailsLoading());
    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.isEmpty) {
        emit(const LoadDetailsFailure(errorMessage: 'Please login again'));
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.getIdLoadDetails(loadId),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (!response.isSuccess || response.jsonResponse == null) {
        emit(LoadDetailsFailure(
          errorMessage: response.errorMessage ?? 'Failed to load details',
        ));
        return;
      }

      final parsed = LoadDetailsResponse.fromJson(response.jsonResponse!);
      if (parsed.data == null) {
        emit(const LoadDetailsFailure(
          errorMessage: 'Load data not found',
        ));
        return;
      }

      emit(LoadDetailsSuccess(loadData: parsed.data!));
    } catch (e) {
      debugPrint('❌ LoadDetailsCubit error: $e');
      emit(LoadDetailsFailure(errorMessage: e.toString()));
    }
  }

  /// Refresh load details silently (no loading state emitted)
  Future<void> refreshLoadDetails(String loadId) async {
    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.isEmpty) {
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.getIdLoadDetails(loadId),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (!response.isSuccess || response.jsonResponse == null) {
        return;
      }

      final parsed = LoadDetailsResponse.fromJson(response.jsonResponse!);
      if (parsed.data != null) {
        // Emit success with updated data without showing loading state
        emit(LoadDetailsSuccess(loadData: parsed.data!));
      }
    } catch (e) {
      debugPrint('❌ LoadDetailsCubit refresh error: $e');
      // Don't emit failure on refresh, keep current state
    }
  }
}