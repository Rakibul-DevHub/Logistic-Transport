
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

/// ==================== CUBIT ====================
class AccountSettingsCubit extends Cubit<AccountSettingsState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  AccountSettingsCubit() : super(AccountSettingsInitial());

  Future<void> getUserProfile() async {
    try {
      emit(AccountSettingsLoading());

      // Get access token from secure storage
      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        emit(const AccountSettingsFailure(
          errorMessage: 'Please login again',
        ));
        return;
      }

      // Call user profile API with bearer token
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

  void resetState() {
    emit(AccountSettingsInitial());
  }
}