/**
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import '../view/account_settings/model/account_settings_data.dart';

// ==================== STATES ====================
abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileSuccess extends UserProfileState {
  final UserData userData;

  const UserProfileSuccess({required this.userData});

  @override
  List<Object?> get props => [userData];
}

class UserProfileFailure extends UserProfileState {
  final String errorMessage;

  const UserProfileFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

// ==================== CUBIT ====================
class UserProfileCubit extends Cubit<UserProfileState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  UserProfileCubit() : super(UserProfileInitial());

  Future<void> getUserProfile() async {
    try {
      emit(UserProfileLoading());

      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        emit(const UserProfileFailure(
          errorMessage: 'Please login again',
        ));
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.userProfile,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.isSuccess) {
        final userProfile = AccountSettingResponse.fromJson(
          response.jsonResponse ?? {},
        );

        if (userProfile.data != null) {
          emit(UserProfileSuccess(userData: userProfile.data!));
        } else {
          emit(const UserProfileFailure(
            errorMessage: 'Invalid response from server',
          ));
        }
      } else {
        String errorMsg = response.errorMessage ?? 'Failed to load profile';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }

        emit(UserProfileFailure(errorMessage: errorMsg));
      }
    } catch (e) {
      emit(UserProfileFailure(
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  void resetState() {
    emit(UserProfileInitial());
  }
}*/





///
///
/// todo:: caching
///
///




import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import '../view/account_settings/model/account_settings_data.dart';

// ==================== STATES ====================
abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileSuccess extends UserProfileState {
  final UserData userData;
  final bool isFromCache;

  const UserProfileSuccess({
    required this.userData,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [userData, isFromCache];
}

class UserProfileFailure extends UserProfileState {
  final String errorMessage;

  const UserProfileFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

// ==================== CUBIT ====================
class UserProfileCubit extends Cubit<UserProfileState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  /// MUST match AccountSettingsCubit cache key
  static const String cacheKey = 'user_profile_cache';

  UserProfileCubit() : super(UserProfileInitial());

  /// - Default: show SharedPreferences cache (name / email / image). No API.
  /// - forceRefresh: true → fetch API (after Account Settings save).
  Future<void> getUserProfile({bool forceRefresh = false}) async {
    try {
      final cachedData = await getCachedUserData();

      // ✅ Use cache only — no spinner, no network
      if (!forceRefresh && cachedData != null) {
        emit(UserProfileSuccess(userData: cachedData, isFromCache: true));
        return;
      }

      // Keep showing cache while refreshing (no flash)
      if (cachedData != null) {
        emit(UserProfileSuccess(userData: cachedData, isFromCache: true));
      } else {
        emit(UserProfileLoading());
      }

      final accessToken = await _storage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        emit(const UserProfileFailure(errorMessage: 'Please login again'));
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.userProfile,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.isSuccess) {
        final userProfile = AccountSettingResponse.fromJson(
          response.jsonResponse ?? {},
        );

        if (userProfile.data != null) {
          await cacheUserData(userProfile.data!);
          emit(UserProfileSuccess(
            userData: userProfile.data!,
            isFromCache: false,
          ));
        } else {
          if (cachedData != null) {
            emit(UserProfileSuccess(userData: cachedData, isFromCache: true));
          } else {
            emit(const UserProfileFailure(
              errorMessage: 'Invalid response from server',
            ));
          }
        }
      } else {
        if (cachedData != null) {
          emit(UserProfileSuccess(userData: cachedData, isFromCache: true));
          return;
        }

        String errorMsg = response.errorMessage ?? 'Failed to load profile';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }
        emit(UserProfileFailure(errorMessage: errorMsg));
      }
    } catch (e) {
      final cachedData = await getCachedUserData();
      if (cachedData != null) {
        emit(UserProfileSuccess(userData: cachedData, isFromCache: true));
        return;
      }
      emit(UserProfileFailure(
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  static Future<void> cacheUserData(UserData userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, jsonEncode(userData.toJson()));
      debugPrint('✅ Profile cache saved');
    } catch (e) {
      debugPrint('❌ Failed to cache profile: $e');
    }
  }

  static Future<UserData?> getCachedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(cacheKey);
      if (jsonString == null) return null;
      return UserData.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('❌ Failed to read profile cache: $e');
      return null;
    }
  }

  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(cacheKey);
      debugPrint('✅ Profile cache cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear profile cache: $e');
    }
  }

  void resetState() => emit(UserProfileInitial());
}