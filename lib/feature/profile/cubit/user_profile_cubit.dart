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
}