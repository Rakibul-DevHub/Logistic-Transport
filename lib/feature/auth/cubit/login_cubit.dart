// lib/feature/auth/cubit/login_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/network_response_dio.dart';
import 'package:tag/core/utils/app_url.dart';
import '../../../core/network/secure_storage_service.dart';
import '../model_data/login_data.dart';

// ==================== STATES ====================
abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String accessToken;
  final String refreshToken;
  final User user;

  const LoginSuccess({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}

class LoginFailure extends LoginState {
  final String errorMessage;

  const LoginFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

// ==================== CUBIT ====================
class LoginCubit extends Cubit<LoginState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  LoginCubit() : super( LoginInitial());

  /// Login user with email and password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      emit( LoginLoading());

      final requestBody = LoginRequest(
        email: email.trim(),
        password: password,
      );

      final response = await _networkCaller.postRequest(
        AppUrl.logIn,
        body: requestBody.toJson(),
        isLogin: true,
      );

      if (response.isSuccess) {
        // Parse response
        final loginResponse = LoginResponse.fromJson(
          response.jsonResponse ?? {},
        );

        if (loginResponse.data?.tokens != null &&
            loginResponse.data?.user != null) {

          final tokens = loginResponse.data!.tokens!;
          final user = loginResponse.data!.user!;

          // Store tokens securely (don't await to speed up)
          _storage.saveAccessToken(tokens.accessToken);
          _storage.saveRefreshToken(tokens.refreshToken);
          _storage.saveUserEmail(user.email);

          emit(LoginSuccess(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
            user: user,
          ));
        } else {
          emit(const LoginFailure(
            errorMessage: 'Invalid response from server',
          ));
        }
      } else {
        String errorMsg = response.errorMessage ?? 'Login failed';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }

        emit(LoginFailure(errorMessage: errorMsg));
      }
    } catch (e) {
      emit(LoginFailure(
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  /// Clear error state
  void clearError() {
    if (state is LoginFailure) {
      emit(LoginInitial());
    }
  }

  /// Reset to initial state
  void resetState() {
    emit(LoginInitial());
  }

  // ==================== GETTERS ====================
  bool get isLoading => state is LoginLoading;
  bool get isSuccess => state is LoginSuccess;
  String? get errorMessage {
    if (state is LoginFailure) {
      return (state as LoginFailure).errorMessage;
    }
    return null;
  }

  LoginSuccess? get successData {
    if (state is LoginSuccess) {
      return state as LoginSuccess;
    }
    return null;
  }
}