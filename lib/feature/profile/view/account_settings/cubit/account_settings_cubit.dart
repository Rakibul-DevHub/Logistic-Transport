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

      debugPrint('🔑 Access Token: $accessToken');
      debugPrint('🌐 Fetching user profile from: ${AppUrl.userProfile}');

      final response = await _networkCaller.getRequest(
        AppUrl.userProfile,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      debugPrint('📡 Response Status: ${response.statusCode}');
      debugPrint('📡 Response Body: ${response.jsonResponse}');

      if (response.isSuccess) {
        final userProfile = AccountSettingResponse.fromJson(
          response.jsonResponse ?? {},
        );

        if (userProfile.data != null) {
          debugPrint('✅ User Data: ${userProfile.data!.name}');
          debugPrint('✅ User Email: ${userProfile.data!.email}');
          emit(AccountSettingsSuccess(userData: userProfile.data!));
        } else {
          debugPrint('❌ No user data in response');
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

        debugPrint('❌ Error: $errorMsg');
        emit(AccountSettingsFailure(errorMessage: errorMsg));
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
      emit(AccountSettingsFailure(
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

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

      debugPrint('🌐 Changing password...');

      final response = await _networkCaller.postRequest(
        AppUrl.changePassword,
        body: requestBody,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      debugPrint('📡 Change Password Response Status: ${response.statusCode}');
      debugPrint('📡 Change Password Response Body: ${response.jsonResponse}');

      if (response.isSuccess) {
        debugPrint('✅ Password changed successfully');

        // The change-password response already returns the updated user
        // object under `data`, so use it directly instead of firing a
        // second request via getUserProfile().
        final userDataJson = response.jsonResponse?['data'];
        if (userDataJson != null) {
          final userData = UserData.fromJson(userDataJson);
          emit(AccountSettingsSuccess(userData: userData));
        } else {
          // Fallback: response didn't include user data for some reason —
          // fetch it separately so the UI still has something to show.
          debugPrint('⚠️ No user data in change-password response, '
              'falling back to getUserProfile()');
          await getUserProfile();
        }
      } else {
        String errorMsg = response.errorMessage ?? 'Failed to change password';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }

        debugPrint('❌ Password change failed: $errorMsg');
        emit(AccountSettingsFailure(errorMessage: errorMsg));
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
      emit(AccountSettingsFailure(
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  void resetState() {
    emit(AccountSettingsInitial());
  }
}