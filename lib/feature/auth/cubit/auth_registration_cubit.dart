import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import '../../../core/network/secure_storage_service.dart';
import '../../../core/utils/app_url.dart';
import '../model_data/create_account_data.dart';

/// ==================== EVENTS ====================
abstract class AuthRegistrationEvent extends Equatable {
  const AuthRegistrationEvent();

  @override
  List<Object?> get props => [];
}

class UpdateRegistrationData extends AuthRegistrationEvent {
  final String email;
  final String fullName;
  final String password;

  const UpdateRegistrationData({
    required this.email,
    required this.fullName,
    required this.password,
  });

  @override
  List<Object?> get props => [email, fullName, password];
}

class RegisterUser extends AuthRegistrationEvent {
  final String email;
  final String fullName;
  final String password;
  final String confirmPassword;

  const RegisterUser({
    required this.email,
    required this.fullName,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [email, fullName, password, confirmPassword];
}

class VerifyOtp extends AuthRegistrationEvent {
  final String otp;

  const VerifyOtp({required this.otp});

  @override
  List<Object?> get props => [otp];
}

class ResendOtp extends AuthRegistrationEvent {
  const ResendOtp();
}

class ClearRegistrationData extends AuthRegistrationEvent {
  const ClearRegistrationData();
}

// ==================== STATE ====================
class AuthRegistrationState extends Equatable {
  final String email;
  final String fullName;
  final String password;
  final bool isLoading;
  final bool isSuccess;
  final String? verificationToken;
  final String? accessToken;
  final String? refreshToken;
  final String? errorMessage;

  const AuthRegistrationState({
    this.email = '',
    this.fullName = '',
    this.password = '',
    this.isLoading = false,
    this.isSuccess = false,
    this.verificationToken,
    this.accessToken,
    this.refreshToken,
    this.errorMessage,
  });

  AuthRegistrationState copyWith({
    String? email,
    String? fullName,
    String? password,
    bool? isLoading,
    bool? isSuccess,
    String? verificationToken,
    String? accessToken,
    String? refreshToken,
    String? errorMessage,
  }) {
    return AuthRegistrationState(
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      verificationToken: verificationToken ?? this.verificationToken,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    email,
    fullName,
    password,
    isLoading,
    isSuccess,
    verificationToken,
    accessToken,
    refreshToken,
    errorMessage,
  ];
}

// ==================== CUBIT ====================
class AuthRegistrationCubit extends Cubit<AuthRegistrationState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  AuthRegistrationCubit() : super(const AuthRegistrationState());

  /// Store registration data from CreateAccountScreen
  void updateRegistrationData({
    required String email,
    required String fullName,
    required String password,
  }) {
    emit(state.copyWith(
      email: email.trim(),
      fullName: fullName.trim(),
      password: password,
      errorMessage: null,
      isSuccess: false,
    ));
  }

  /// Register user with API
  Future<void> registerUser({
    required String email,
    required String fullName,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      emit(state.copyWith(
        isLoading: true,
        errorMessage: null,
        isSuccess: false,
        verificationToken: null,
      ));

      final requestData = CreateAccountData(
        name: fullName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      final response = await _networkCaller.postRequest(
        AppUrl.createAccount,
        body: requestData.toJson(),
      );

      if (response.isSuccess) {
        String? token;
        if (response.jsonResponse != null) {
          if (response.jsonResponse?['data'] != null) {
            token = response.jsonResponse?['data']?['verificationToken'];
          }
          if (token == null) {
            token = response.jsonResponse?['verificationToken'];
          }
        }

        emit(state.copyWith(
          isLoading: false,
          isSuccess: true,
          verificationToken: token,
          errorMessage: null,
        ));
      } else {
        String errorMsg = response.errorMessage ?? 'Registration failed';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }

        emit(state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: errorMsg,
          verificationToken: null,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: 'An error occurred: ${e.toString()}',
        verificationToken: null,
      ));
    }
  }

  /// Verify OTP with API
  Future<void> verifyOtp({
    required String otp,
  }) async {
    try {
      final token = state.verificationToken;
      if (token == null) {
        emit(state.copyWith(
          errorMessage: 'Verification token not found. Please try again.',
          isLoading: false,
        ));
        return;
      }

      emit(state.copyWith(
        isLoading: true,
        errorMessage: null,
        isSuccess: false,
      ));

      final Map<String, dynamic> requestBody = {
        'otp': otp,
      };

      final response = await _networkCaller.postRequest(
        AppUrl.verifyOtp,
        body: requestBody,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.isSuccess) {
        String? accessToken;
        String? refreshToken;

        if (response.jsonResponse != null) {
          if (response.jsonResponse?['data'] != null) {
            final data = response.jsonResponse?['data'];
            accessToken = data?['accessToken'] ?? data?['access_token'];
            refreshToken = data?['refreshToken'] ?? data?['refresh_token'];
          }
          if (accessToken == null) {
            accessToken = response.jsonResponse?['accessToken'] ??
                response.jsonResponse?['access_token'];
          }
          if (refreshToken == null) {
            refreshToken = response.jsonResponse?['refreshToken'] ??
                response.jsonResponse?['refresh_token'];
          }
        }

        // Store tokens in background
        if (accessToken != null && accessToken.isNotEmpty) {
          _storage.saveAccessToken(accessToken);
        }
        if (refreshToken != null && refreshToken.isNotEmpty) {
          _storage.saveRefreshToken(refreshToken);
        }
        if (state.email.isNotEmpty) {
          _storage.saveUserEmail(state.email);
        }

        emit(state.copyWith(
          isLoading: false,
          isSuccess: true,
          accessToken: accessToken,
          refreshToken: refreshToken,
          errorMessage: null,
        ));
      } else {
        String errorMsg = response.errorMessage ?? 'Verification failed';

        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;

          if (response.jsonResponse?['errors'] != null) {
            final errors = response.jsonResponse?['errors'];
            if (errors is Map) {
              errorMsg = errors.values.join(', ');
            } else if (errors is List) {
              errorMsg = errors.join(', ');
            }
          }
        }

        emit(state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: errorMsg,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: 'Error verifying OTP: ${e.toString()}',
      ));
    }
  }

  /// Resend OTP
  Future<void> resendOtp() async {
    try {
      final token = state.verificationToken;
      if (token == null) {
        emit(state.copyWith(
          errorMessage: 'Verification token not found. Please try again.',
          isLoading: false,
        ));
        return;
      }

      emit(state.copyWith(
        isLoading: true,
        errorMessage: null,
      ));

      final response = await _networkCaller.postRequest(
        AppUrl.verifyOtp,
        body: {},
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.isSuccess) {
        String? newToken;
        if (response.jsonResponse != null) {
          if (response.jsonResponse?['data'] != null) {
            newToken = response.jsonResponse?['data']?['verificationToken'];
          }
          if (newToken == null) {
            newToken = response.jsonResponse?['verificationToken'];
          }
        }

        if (newToken != null && newToken.isNotEmpty) {
          emit(state.copyWith(
            isLoading: false,
            verificationToken: newToken,
            errorMessage: null,
          ));
        } else {
          emit(state.copyWith(
            isLoading: false,
            errorMessage: null,
          ));
        }
      } else {
        String errorMsg = response.errorMessage ?? 'Failed to resend code';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }

        emit(state.copyWith(
          isLoading: false,
          errorMessage: errorMsg,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Error resending OTP: ${e.toString()}',
      ));
    }
  }

  /// Clear sensitive data after flow completion
  void clearData() {
    emit(const AuthRegistrationState());
  }

  /// Reset error state
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  /// Set loading state for API operations
  void setLoading(bool value) {
    emit(state.copyWith(isLoading: value));
  }

  /// Set error message
  void setError(String message) {
    emit(state.copyWith(errorMessage: message, isLoading: false));
  }

  /// ==================== GETTERS ====================
  String get email => state.email;
  String get fullName => state.fullName;
  String get password => state.password;
  bool get isLoading => state.isLoading;
  bool get isSuccess => state.isSuccess;
  String? get verificationToken => state.verificationToken;
  String? get accessToken => state.accessToken;
  String? get refreshToken => state.refreshToken;
  String? get errorMessage => state.errorMessage;
}