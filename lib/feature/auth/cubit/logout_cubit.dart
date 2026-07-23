/**
// lib/feature/auth/cubit/logout_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';

// ==================== STATES ====================
abstract class LogoutState extends Equatable {
  const LogoutState();

  @override
  List<Object?> get props => [];
}

class LogoutInitial extends LogoutState {}

class LogoutLoading extends LogoutState {}

class LogoutSuccess extends LogoutState {}

class LogoutFailure extends LogoutState {
  final String errorMessage;

  const LogoutFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

// ==================== CUBIT ====================
class LogoutCubit extends Cubit<LogoutState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  LogoutCubit() : super(LogoutInitial());

  Future<void> logout() async {
    try {
      emit(LogoutLoading());

      // Get access token from secure storage
      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        // If no token, just clear storage and navigate to login
        await _storage.deleteAllTokens();
        emit(LogoutSuccess());
        return;
      }

      // Call logout API with bearer token
      final response = await _networkCaller.postRequest(
        AppUrl.logOut,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      // Clear all tokens regardless of API response
      await _storage.deleteAllTokens();

      if (response.isSuccess) {
        emit(LogoutSuccess());
      } else {
        // Even if API fails, we still logged out locally
        // But we emit success anyway since tokens are cleared
        emit(LogoutSuccess());
      }
    } catch (e) {
      // Even on error, clear tokens and emit success
      try {
        await _storage.deleteAllTokens();
      } catch (_) {}

      // Still emit success so user can navigate to login
      emit(LogoutSuccess());
    }
  }
}*/







///
///
///
/// todo:: clearing cache
///
///




import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import 'package:tag/feature/profile/cubit/user_profile_cubit.dart';

abstract class LogoutState extends Equatable {
  const LogoutState();

  @override
  List<Object?> get props => [];
}

class LogoutInitial extends LogoutState {}

class LogoutLoading extends LogoutState {}

class LogoutSuccess extends LogoutState {}

class LogoutFailure extends LogoutState {
  final String errorMessage;

  const LogoutFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class LogoutCubit extends Cubit<LogoutState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  LogoutCubit() : super(LogoutInitial());

  Future<void> logout() async {
    try {
      emit(LogoutLoading());

      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        await _storage.deleteAllTokens();
        await UserProfileCubit.clearCache();
        emit(LogoutSuccess());
        return;
      }

      await _networkCaller.postRequest(
        AppUrl.logOut,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      await _storage.deleteAllTokens();
      await UserProfileCubit.clearCache();
      emit(LogoutSuccess());
    } catch (e) {
      try {
        await _storage.deleteAllTokens();
        await UserProfileCubit.clearCache();
      } catch (_) {}
      emit(LogoutSuccess());
    }
  }
}