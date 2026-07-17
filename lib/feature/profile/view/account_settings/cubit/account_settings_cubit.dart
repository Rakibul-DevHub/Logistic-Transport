/**
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import '../model/account_settings_data.dart';

// ==================== STATES ====================
abstract class AccountSettingsState extends Equatable {
  const AccountSettingsState();

  @override
  List<Object?> get props => [];
}

class AccountSettingsInitial extends AccountSettingsState {}

class AccountSettingsLoading extends AccountSettingsState {}

class AccountSettingsSuccess extends AccountSettingsState {
  final UserData userData;

  const AccountSettingsSuccess({required this.userData});

  @override
  List<Object?> get props => [userData];
}

class AccountSettingsFailure extends AccountSettingsState {
  final String errorMessage;

  const AccountSettingsFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

// ==================== CUBIT ====================
class AccountSettingsCubit extends Cubit<AccountSettingsState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  AccountSettingsCubit() : super(AccountSettingsInitial());

  Future<void> getUserProfile() async {
    try {
      emit(AccountSettingsLoading());

      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        emit(const AccountSettingsFailure(
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
          emit(AccountSettingsSuccess(userData: userProfile.data!));
        } else {
          emit(const AccountSettingsFailure(
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

        emit(AccountSettingsFailure(errorMessage: errorMsg));
      }
    } catch (e) {
      emit(AccountSettingsFailure(
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  // Upload image
  Future<String?> uploadImage(File imageFile) async {
    try {
      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('❌ No access token found');
        return null;
      }

      final response = await _networkCaller.uploadImage(
        AppUrl.singleImageUpload,
        imageFile: imageFile,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
        fileFieldName: 'file',
        method: 'POST',
      );

      if (response.isSuccess) {
        final filename = response.jsonResponse?['data']?['filename'];
        debugPrint('✅ Upload successful: $filename');
        return filename;
      } else {
        debugPrint('❌ Upload failed: ${response.errorMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String name,
    required String phone,
    required String address,
    required String profileImage,
  }) async {
    try {
      emit(AccountSettingsLoading());

      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        emit(const AccountSettingsFailure(
          errorMessage: 'Please login again',
        ));
        return;
      }

      final Map<String, dynamic> requestBody = {
        'name': name,
        'phone': phone,
        'address': address,
        'profileImage': profileImage,
      };

      final response = await _networkCaller.putRequest(
        AppUrl.userProfileUpdate,
        body: requestBody,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.isSuccess) {
        final userDataJson = response.jsonResponse?['data'];
        if (userDataJson != null) {
          final userData = UserData.fromJson(userDataJson);
          emit(AccountSettingsSuccess(userData: userData));
        } else {
          await getUserProfile();
        }
      } else {
        String errorMsg = response.errorMessage ?? 'Failed to update profile';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }

        emit(AccountSettingsFailure(errorMessage: errorMsg));
      }
    } catch (e) {
      emit(AccountSettingsFailure(
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      emit(AccountSettingsLoading());

      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        emit(const AccountSettingsFailure(
          errorMessage: 'Please login again',
        ));
        return;
      }

      final Map<String, dynamic> requestBody = {
        'currentPassword': currentPassword,
        'password': newPassword,
        'confirmPassword': confirmPassword,
      };

      final response = await _networkCaller.postRequest(
        AppUrl.changePassword,
        body: requestBody,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.isSuccess) {
        final userDataJson = response.jsonResponse?['data'];
        if (userDataJson != null) {
          final userData = UserData.fromJson(userDataJson);
          emit(AccountSettingsSuccess(userData: userData));
        } else {
          await getUserProfile();
        }
      } else {
        String errorMsg = response.errorMessage ?? 'Failed to change password';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }

        emit(AccountSettingsFailure(errorMessage: errorMsg));
      }
    } catch (e) {
      emit(AccountSettingsFailure(
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  // ✅ Delete Account
  Future<bool> deleteAccount() async {
    try {
      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('❌ No access token found');
        return false;
      }

      debugPrint('🗑️ Deleting account...');

      final response = await _networkCaller.deleteRequest(
        AppUrl.deleteUserAccount,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      debugPrint('📡 Delete Response Status: ${response.statusCode}');
      debugPrint('📡 Delete Response Body: ${response.jsonResponse}');

      if (response.isSuccess) {
        // Clear all stored tokens
        await _storage.deleteAllTokens();
        debugPrint('✅ Account deleted successfully');
        return true;
      } else {
        String errorMsg = response.errorMessage ?? 'Failed to delete account';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }
        debugPrint('❌ Delete failed: $errorMsg');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Delete account error: $e');
      return false;
    }
  }

  void resetState() {
    emit(AccountSettingsInitial());
  }
}*/









///
///
///
/// todo:: working for caching but not fully fixed
///
///
///
















// account_settings_cubit.dart

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import '../model/account_settings_data.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ==================== STATES ====================
abstract class AccountSettingsState extends Equatable {
  const AccountSettingsState();

  @override
  List<Object?> get props => [];
}

class AccountSettingsInitial extends AccountSettingsState {}

class AccountSettingsLoading extends AccountSettingsState {
  final bool isCachedData;

  const AccountSettingsLoading({this.isCachedData = false});

  @override
  List<Object?> get props => [isCachedData];
}

class AccountSettingsSuccess extends AccountSettingsState {
  final UserData userData;
  final bool isFromCache;

  const AccountSettingsSuccess({
    required this.userData,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [userData, isFromCache];
}

class AccountSettingsFailure extends AccountSettingsState {
  final String errorMessage;

  const AccountSettingsFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

// ==================== CUBIT ====================
class AccountSettingsCubit extends Cubit<AccountSettingsState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  // Cache key
  static const String _cacheKey = 'user_profile_cache';

  AccountSettingsCubit() : super(AccountSettingsInitial()) {
    // Load cached data immediately when cubit is created
    _loadCachedData();
  }

  // Load cached data on initialization
  Future<void> _loadCachedData() async {
    try {
      final cachedData = await _getCachedUserData();
      if (cachedData != null) {
        // Emit success state with cached data
        emit(AccountSettingsSuccess(
          userData: cachedData,
          isFromCache: true,
        ));
        // Then fetch fresh data in background
        _fetchFreshData();
      } else {
        // No cache, fetch from API
        getUserProfile();
      }
    } catch (e) {
      // If cache fails, fetch from API
      getUserProfile();
    }
  }

  // Fetch fresh data from API (background refresh)
  Future<void> _fetchFreshData() async {
    try {
      final accessToken = await _storage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
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
          // Cache the fresh data
          await _cacheUserData(userProfile.data!);

          // Only update UI if state is still a success from cache
          if (state is AccountSettingsSuccess) {
            emit(AccountSettingsSuccess(
              userData: userProfile.data!,
              isFromCache: false,
            ));
          }
        }
      }
    } catch (e) {
      // Silent fail for background refresh
      debugPrint('Background refresh failed: $e');
    }
  }

  // Cache user data
  Future<void> _cacheUserData(UserData userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(userData.toJson());
      await prefs.setString(_cacheKey, jsonString);
      debugPrint('✅ User data cached successfully');
    } catch (e) {
      debugPrint('❌ Failed to cache user data: $e');
    }
  }

  // Get cached user data
  Future<UserData?> _getCachedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);
      if (jsonString != null) {
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        return UserData.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Failed to get cached user data: $e');
      return null;
    }
  }

  // Clear cache (useful for logout)
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      debugPrint('✅ User cache cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear cache: $e');
    }
  }

  // Update user profile with cache update
  Future<void> getUserProfile({bool forceRefresh = false}) async {
    try {
      // If we already have cached data and not forcing refresh, use it
      if (!forceRefresh) {
        final cachedData = await _getCachedUserData();
        if (cachedData != null) {
          emit(AccountSettingsSuccess(
            userData: cachedData,
            isFromCache: true,
          ));
          // Fetch fresh data in background
          _fetchFreshData();
          return;
        }
      }

      // No cache or force refresh - show loading
      emit(const AccountSettingsLoading());

      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        emit(const AccountSettingsFailure(
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
          // Cache the data
          await _cacheUserData(userProfile.data!);
          emit(AccountSettingsSuccess(
            userData: userProfile.data!,
            isFromCache: false,
          ));
        } else {
          emit(const AccountSettingsFailure(
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

        emit(AccountSettingsFailure(errorMessage: errorMsg));
      }
    } catch (e) {
      emit(AccountSettingsFailure(
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  // Upload image
  Future<String?> uploadImage(File imageFile) async {
    try {
      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('❌ No access token found');
        return null;
      }

      final response = await _networkCaller.uploadImage(
        AppUrl.userProfileImageUpload,
        imageFile: imageFile,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
        fileFieldName: 'file',
        method: 'POST',
      );

      if (response.isSuccess) {
        final filename = response.jsonResponse?['data']?['filename'];
        debugPrint('✅ Upload successful: $filename');
        return filename;
      } else {
        debugPrint('❌ Upload failed: ${response.errorMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      return null;
    }
  }

  // Update user profile with cache update
  Future<void> updateUserProfile({
    required String name,
    required String phone,
    required String address,
    required String profileImage,
  }) async {
    try {
      emit(AccountSettingsLoading());

      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        emit(const AccountSettingsFailure(
          errorMessage: 'Please login again',
        ));
        return;
      }

      final Map<String, dynamic> requestBody = {
        'name': name,
        'phone': phone,
        'address': address,
        'profileImage': profileImage,
      };

      final response = await _networkCaller.putRequest(
        AppUrl.userProfileUpdate,
        body: requestBody,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.isSuccess) {
        final userDataJson = response.jsonResponse?['data'];
        if (userDataJson != null) {
          final userData = UserData.fromJson(userDataJson);
          // Update cache with new data
          await _cacheUserData(userData);
          emit(AccountSettingsSuccess(
            userData: userData,
            isFromCache: false,
          ));
        } else {
          await getUserProfile(forceRefresh: true);
        }
      } else {
        String errorMsg = response.errorMessage ?? 'Failed to update profile';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }

        emit(AccountSettingsFailure(errorMessage: errorMsg));
      }
    } catch (e) {
      emit(AccountSettingsFailure(
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  // Change password with cache update
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      emit(AccountSettingsLoading());

      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        emit(const AccountSettingsFailure(
          errorMessage: 'Please login again',
        ));
        return;
      }

      final Map<String, dynamic> requestBody = {
        'currentPassword': currentPassword,
        'password': newPassword,
        'confirmPassword': confirmPassword,
      };

      final response = await _networkCaller.postRequest(
        AppUrl.changePassword,
        body: requestBody,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.isSuccess) {
        final userDataJson = response.jsonResponse?['data'];
        if (userDataJson != null) {
          final userData = UserData.fromJson(userDataJson);
          // Update cache with new data
          await _cacheUserData(userData);
          emit(AccountSettingsSuccess(
            userData: userData,
            isFromCache: false,
          ));
        } else {
          await getUserProfile(forceRefresh: true);
        }
      } else {
        String errorMsg = response.errorMessage ?? 'Failed to change password';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }

        emit(AccountSettingsFailure(errorMessage: errorMsg));
      }
    } catch (e) {
      emit(AccountSettingsFailure(
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  // ✅ Delete Account with cache clear
  Future<bool> deleteAccount() async {
    try {
      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('❌ No access token found');
        return false;
      }

      debugPrint('🗑️ Deleting account...');

      final response = await _networkCaller.deleteRequest(
        AppUrl.deleteUserAccount,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      debugPrint('📡 Delete Response Status: ${response.statusCode}');
      debugPrint('📡 Delete Response Body: ${response.jsonResponse}');

      if (response.isSuccess) {
        // Clear all stored tokens and cache
        await _storage.deleteAllTokens();
        await clearCache();
        debugPrint('✅ Account deleted successfully');
        return true;
      } else {
        String errorMsg = response.errorMessage ?? 'Failed to delete account';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }
        debugPrint('❌ Delete failed: $errorMsg');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Delete account error: $e');
      return false;
    }
  }

  void resetState() {
    emit(AccountSettingsInitial());
  }
}