/**
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import '../../../core/utils/app_url.dart';
import '../model/create_account_data.dart';

// ==================== EVENTS ====================
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
  final String? errorMessage;

  const AuthRegistrationState({
    this.email = '',
    this.fullName = '',
    this.password = '',
    this.isLoading = false,
    this.isSuccess = false,
    this.verificationToken,
    this.errorMessage,
  });

  AuthRegistrationState copyWith({
    String? email,
    String? fullName,
    String? password,
    bool? isLoading,
    bool? isSuccess,
    String? verificationToken,
    String? errorMessage,
  }) {
    return AuthRegistrationState(
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      verificationToken: verificationToken ?? this.verificationToken,
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
    errorMessage,
  ];
}

// ==================== CUBIT ====================
class AuthRegistrationCubit extends Cubit<AuthRegistrationState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

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
      // Set loading state
      emit(state.copyWith(
        isLoading: true,
        errorMessage: null,
        isSuccess: false,
      ));

      // Prepare request body
      final requestData = CreateAccountData(
        name: fullName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      // Make API call
      final response = await _networkCaller.postRequest(
        AppUrl.createAccount,
        body: requestData.toJson(),
      );

      // Handle response
      if (response.isSuccess) {
        // Extract verification token from response
        String? token = response.jsonResponse?['data']?['verificationToken'];

        emit(state.copyWith(
          isLoading: false,
          isSuccess: true,
          verificationToken: token,
          errorMessage: null,
        ));
      } else {
        // Handle error
        String errorMsg = response.errorMessage ?? 'Registration failed';

        // Try to get error message from response
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ?? errorMsg;
        }

        emit(state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: errorMsg,
        ));
      }
    } catch (e) {
      // Handle exception
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: 'An error occurred: ${e.toString()}',
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

  /// Getters for easy access
  String get email => state.email;
  String get fullName => state.fullName;
  String get password => state.password;
  bool get isLoading => state.isLoading;
  bool get isSuccess => state.isSuccess;
  String? get verificationToken => state.verificationToken;
  String? get errorMessage => state.errorMessage;
}*/















// // lib/feature/auth/cubit/auth_registration_cubit.dart
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:tag/core/network/network_caller_dio.dart';
// import 'package:tag/core/network/network_response_dio.dart';
//
// import '../../../core/utils/app_url.dart';
// import '../model/create_account_data.dart';
//
// // ==================== EVENTS ====================
// abstract class AuthRegistrationEvent extends Equatable {
//   const AuthRegistrationEvent();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class UpdateRegistrationData extends AuthRegistrationEvent {
//   final String email;
//   final String fullName;
//   final String password;
//
//   const UpdateRegistrationData({
//     required this.email,
//     required this.fullName,
//     required this.password,
//   });
//
//   @override
//   List<Object?> get props => [email, fullName, password];
// }
//
// class RegisterUser extends AuthRegistrationEvent {
//   final String email;
//   final String fullName;
//   final String password;
//   final String confirmPassword;
//
//   const RegisterUser({
//     required this.email,
//     required this.fullName,
//     required this.password,
//     required this.confirmPassword,
//   });
//
//   @override
//   List<Object?> get props => [email, fullName, password, confirmPassword];
// }
//
// class VerifyOtp extends AuthRegistrationEvent {
//   final String otp;
//
//   const VerifyOtp({required this.otp});
//
//   @override
//   List<Object?> get props => [otp];
// }
//
// class ResendOtp extends AuthRegistrationEvent {
//   const ResendOtp();
// }
//
// class ClearRegistrationData extends AuthRegistrationEvent {
//   const ClearRegistrationData();
// }
//
// // ==================== STATE ====================
// class AuthRegistrationState extends Equatable {
//   final String email;
//   final String fullName;
//   final String password;
//   final bool isLoading;
//   final bool isSuccess;
//   final String? verificationToken;
//   final String? errorMessage;
//
//   const AuthRegistrationState({
//     this.email = '',
//     this.fullName = '',
//     this.password = '',
//     this.isLoading = false,
//     this.isSuccess = false,
//     this.verificationToken,
//     this.errorMessage,
//   });
//
//   AuthRegistrationState copyWith({
//     String? email,
//     String? fullName,
//     String? password,
//     bool? isLoading,
//     bool? isSuccess,
//     String? verificationToken,
//     String? errorMessage,
//   }) {
//     return AuthRegistrationState(
//       email: email ?? this.email,
//       fullName: fullName ?? this.fullName,
//       password: password ?? this.password,
//       isLoading: isLoading ?? this.isLoading,
//       isSuccess: isSuccess ?? this.isSuccess,
//       verificationToken: verificationToken ?? this.verificationToken,
//       errorMessage: errorMessage,
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//     email,
//     fullName,
//     password,
//     isLoading,
//     isSuccess,
//     verificationToken,
//     errorMessage,
//   ];
// }
//
// // ==================== CUBIT ====================
// class AuthRegistrationCubit extends Cubit<AuthRegistrationState> {
//   final NetworkCallerDio _networkCaller = NetworkCallerDio();
//
//   AuthRegistrationCubit() : super(const AuthRegistrationState());
//
//   /// Store registration data from CreateAccountScreen
//   void updateRegistrationData({
//     required String email,
//     required String fullName,
//     required String password,
//   }) {
//     emit(state.copyWith(
//       email: email.trim(),
//       fullName: fullName.trim(),
//       password: password,
//       errorMessage: null,
//       isSuccess: false,
//     ));
//   }
//
//   /// Register user with API
//   Future<void> registerUser({
//     required String email,
//     required String fullName,
//     required String password,
//     required String confirmPassword,
//   }) async {
//     try {
//       // Set loading state
//       emit(state.copyWith(
//         isLoading: true,
//         errorMessage: null,
//         isSuccess: false,
//         verificationToken: null,
//       ));
//
//       // Prepare request body
//       final requestData = CreateAccountData(
//         name: fullName,
//         email: email,
//         password: password,
//         confirmPassword: confirmPassword,
//       );
//
//       // Make API call
//       final response = await _networkCaller.postRequest(
//         AppUrl.createAccount,
//         body: requestData.toJson(),
//       );
//
//       // Handle response
//       if (response.isSuccess) {
//         // Extract verification token from response
//         String? token = response.jsonResponse?['data']?['verificationToken'];
//
//         debugPrint('✅ Verification Token received: $token');
//
//         emit(state.copyWith(
//           isLoading: false,
//           isSuccess: true,
//           verificationToken: token,
//           errorMessage: null,
//         ));
//       } else {
//         // Handle error
//         String errorMsg = response.errorMessage ?? 'Registration failed';
//
//         // Try to get error message from response
//         if (response.jsonResponse != null) {
//           errorMsg = response.jsonResponse?['message'] ?? errorMsg;
//         }
//
//         emit(state.copyWith(
//           isLoading: false,
//           isSuccess: false,
//           errorMessage: errorMsg,
//           verificationToken: null,
//         ));
//       }
//     } catch (e) {
//       // Handle exception
//       emit(state.copyWith(
//         isLoading: false,
//         isSuccess: false,
//         errorMessage: 'An error occurred: ${e.toString()}',
//         verificationToken: null,
//       ));
//     }
//   }
//
//   /// Verify OTP with API
//   Future<void> verifyOtp({
//     required String otp,
//   }) async {
//     try {
//       // Check if verification token exists
//       final token = state.verificationToken;
//       if (token == null) {
//         emit(state.copyWith(
//           errorMessage: 'Verification token not found. Please try again.',
//           isLoading: false,
//         ));
//         return;
//       }
//
//       emit(state.copyWith(
//         isLoading: true,
//         errorMessage: null,
//       ));
//
//       debugPrint('🔑 Using Verification Token: $token');
//       debugPrint('📱 Verifying OTP: $otp');
//
//       // Prepare request body
//       final Map<String, dynamic> requestBody = {
//         'otp': otp,
//       };
//
//       // Make API call with verification token in headers
//       final response = await _networkCaller.postRequest(
//         AppUrl.verifyOtp,
//         body: requestBody,
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       debugPrint('📡 OTP Verification Response Status: ${response.statusCode}');
//       debugPrint('📡 OTP Verification Response Body: ${response.jsonResponse}');
//
//       if (response.isSuccess) {
//         // Verification successful
//         emit(state.copyWith(
//           isLoading: false,
//           isSuccess: true,
//           errorMessage: null,
//         ));
//       } else {
//         // Handle error
//         String errorMsg = response.errorMessage ?? 'Verification failed';
//
//         if (response.jsonResponse != null) {
//           errorMsg = response.jsonResponse?['message'] ?? errorMsg;
//         }
//
//         emit(state.copyWith(
//           isLoading: false,
//           isSuccess: false,
//           errorMessage: errorMsg,
//         ));
//       }
//     } catch (e) {
//       debugPrint('❌ OTP Verification Error: $e');
//       emit(state.copyWith(
//         isLoading: false,
//         isSuccess: false,
//         errorMessage: 'Error verifying OTP: ${e.toString()}',
//       ));
//     }
//   }
//
//   /// Resend OTP
//   Future<void> resendOtp() async {
//     try {
//       // Check if verification token exists
//       final token = state.verificationToken;
//       if (token == null) {
//         emit(state.copyWith(
//           errorMessage: 'Verification token not found. Please try again.',
//           isLoading: false,
//         ));
//         return;
//       }
//
//       emit(state.copyWith(
//         isLoading: true,
//         errorMessage: null,
//       ));
//
//       debugPrint('🔑 Resending OTP with Token: $token');
//
//       // Make API call to resend OTP
//       final response = await _networkCaller.postRequest(
//         AppUrl.verifyOtp,
//         body: {}, // Empty body for resend
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       debugPrint('📡 Resend OTP Response Status: ${response.statusCode}');
//       debugPrint('📡 Resend OTP Response Body: ${response.jsonResponse}');
//
//       if (response.isSuccess) {
//         emit(state.copyWith(
//           isLoading: false,
//           errorMessage: null,
//         ));
//       } else {
//         String errorMsg = response.errorMessage ?? 'Failed to resend code';
//
//         if (response.jsonResponse != null) {
//           errorMsg = response.jsonResponse?['message'] ?? errorMsg;
//         }
//
//         emit(state.copyWith(
//           isLoading: false,
//           errorMessage: errorMsg,
//         ));
//       }
//     } catch (e) {
//       debugPrint('❌ Resend OTP Error: $e');
//       emit(state.copyWith(
//         isLoading: false,
//         errorMessage: 'Error resending OTP: ${e.toString()}',
//       ));
//     }
//   }
//
//   /// Clear sensitive data after flow completion
//   void clearData() {
//     emit(const AuthRegistrationState());
//   }
//
//   /// Reset error state
//   void clearError() {
//     emit(state.copyWith(errorMessage: null));
//   }
//
//   /// Set loading state for API operations
//   void setLoading(bool value) {
//     emit(state.copyWith(isLoading: value));
//   }
//
//   /// Set error message
//   void setError(String message) {
//     emit(state.copyWith(errorMessage: message, isLoading: false));
//   }
//
//   // ==================== GETTERS ====================
//   String get email => state.email;
//   String get fullName => state.fullName;
//   String get password => state.password;
//   bool get isLoading => state.isLoading;
//   bool get isSuccess => state.isSuccess;
//   String? get verificationToken => state.verificationToken;
//   String? get errorMessage => state.errorMessage;
// }






// lib/feature/auth/cubit/auth_registration_cubit.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/network_response_dio.dart';
import '../../../core/network/secure_storage_service.dart';
import '../../../core/utils/app_url.dart';
import '../model/create_account_data.dart';

// ==================== EVENTS ====================
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

  AuthRegistrationCubit() : super(const AuthRegistrationState()) {
    debugPrint('🆕 AuthRegistrationCubit CREATED — hashCode: $hashCode');
  }

  @override
  void onChange(Change<AuthRegistrationState> change) {
    super.onChange(change);
    debugPrint('🔄 [CUBIT $hashCode] STATE CHANGE:');
    debugPrint('    FROM -> token=${change.currentState.verificationToken}, '
        'isLoading=${change.currentState.isLoading}, '
        'isSuccess=${change.currentState.isSuccess}, '
        'error=${change.currentState.errorMessage}');
    debugPrint('    TO   -> token=${change.nextState.verificationToken}, '
        'isLoading=${change.nextState.isLoading}, '
        'isSuccess=${change.nextState.isSuccess}, '
        'error=${change.nextState.errorMessage}');
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    debugPrint('💥 [CUBIT $hashCode] onError: $error');
    debugPrint('$stackTrace');
    super.onError(error, stackTrace);
  }

  /// Store registration data from CreateAccountScreen
  void updateRegistrationData({
    required String email,
    required String fullName,
    required String password,
  }) {
    debugPrint('📝 updateRegistrationData() called — email=$email, fullName=$fullName');
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
    debugPrint('════════════════════════════════════════');
    debugPrint('🟦 registerUser() CALLED at ${DateTime.now()}');
    debugPrint('🟦 Cubit instance hashCode: $hashCode');
    debugPrint('🟦 email=$email, fullName=$fullName');
    debugPrint('════════════════════════════════════════');

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

      debugPrint('🌐 Sending register request...');

      final response = await _networkCaller.postRequest(
        AppUrl.createAccount,
        body: requestData.toJson(),
      );

      debugPrint('🌐 registerUser response received. isSuccess=${response.isSuccess}');
      debugPrint('🌐 registerUser response body: ${response.jsonResponse}');

      if (response.isSuccess) {
        // Try different paths for verification token
        String? token;
        if (response.jsonResponse != null) {
          // Try path: data.verificationToken
          if (response.jsonResponse?['data'] != null) {
            token = response.jsonResponse?['data']?['verificationToken'];
          }
          // Try path: verificationToken directly
          if (token == null) {
            token = response.jsonResponse?['verificationToken'];
          }
        }

        debugPrint('✅ Verification Token parsed: $token');
        debugPrint('✅ About to emit state with verificationToken set. '
            'Cubit hashCode=$hashCode');

        emit(state.copyWith(
          isLoading: false,
          isSuccess: true,
          verificationToken: token,
          errorMessage: null,
        ));

        debugPrint('✅ Emit complete. state.verificationToken is now: '
            '${state.verificationToken}');
      } else {
        String errorMsg = response.errorMessage ?? 'Registration failed';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }

        debugPrint('❌ registerUser failed: $errorMsg');

        emit(state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: errorMsg,
          verificationToken: null,
        ));
      }
    } catch (e, st) {
      debugPrint('💥 registerUser() EXCEPTION: $e');
      debugPrint('$st');
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
    debugPrint('════════════════════════════════════════');
    debugPrint('🟢 verifyOtp() CALLED at ${DateTime.now()}');
    debugPrint('🟢 Cubit instance hashCode: $hashCode');
    debugPrint('🟢 Current state.verificationToken: ${state.verificationToken}');
    debugPrint('🟢 Current state.isLoading: ${state.isLoading}');
    debugPrint('🟢 Current state.isSuccess: ${state.isSuccess}');
    debugPrint('🟢 Current state.email: ${state.email}');
    debugPrint('🟢 OTP passed in: $otp');
    debugPrint('════════════════════════════════════════');

    try {
      final token = state.verificationToken;
      if (token == null) {
        debugPrint('🔴 TOKEN IS NULL — bailing out of verifyOtp().');
        debugPrint('🔴 Possible causes:');
        debugPrint('🔴   1) clearData() already ran (post-success reset)');
        debugPrint('🔴   2) verifyOtp() called twice (Pinput onCompleted '
            'firing + manual button tap both firing)');
        debugPrint('🔴   3) A different Cubit instance is being read here '
            'than the one registerUser() ran on (check BlocProvider scope)');
        emit(state.copyWith(
          errorMessage: 'Verification token not found. Please try again.',
          isLoading: false,
        ));
        return;
      }

      if (state.isLoading) {
        debugPrint('🟠 WARNING: verifyOtp() called while already isLoading=true. '
            'This strongly suggests a DUPLICATE call — e.g. Pinput onCompleted '
            'firing alongside a manual Confirm-button tap.');
      }

      emit(state.copyWith(
        isLoading: true,
        errorMessage: null,
      ));

      debugPrint('🔑 Using Verification Token: $token');
      debugPrint('📱 Verifying OTP: $otp');

      final Map<String, dynamic> requestBody = {
        'otp': otp,
      };

      debugPrint('🌐 Sending verify-email request...');

      final response = await _networkCaller.postRequest(
        AppUrl.verifyOtp,
        body: requestBody,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📡 OTP Verification Response Status: ${response.statusCode}');
      debugPrint('📡 OTP Verification Response Body: ${response.jsonResponse}');

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

        debugPrint('✅ Access Token received: $accessToken');
        debugPrint('✅ Refresh Token received: $refreshToken');

        try {
          debugPrint('💾 Attempting to save tokens to secure storage...');
          if (accessToken != null && accessToken.isNotEmpty) {
            await _storage.saveAccessToken(accessToken);
            debugPrint('💾 accessToken saved.');
          }
          if (refreshToken != null && refreshToken.isNotEmpty) {
            await _storage.saveRefreshToken(refreshToken);
            debugPrint('💾 refreshToken saved.');
          }
          if (state.email.isNotEmpty) {
            await _storage.saveUserEmail(state.email);
            debugPrint('💾 email saved.');
          }
        } catch (storageError, st) {
          debugPrint('⚠️ Failed to persist tokens locally: $storageError');
          debugPrint('$st');
          // Intentionally swallowed — verification still counts as success.
        }

        debugPrint('✅ About to emit isSuccess=true. Cubit hashCode=$hashCode');

        emit(state.copyWith(
          isLoading: false,
          isSuccess: true,
          accessToken: accessToken,
          refreshToken: refreshToken,
          errorMessage: null,
        ));

        debugPrint('✅ Emit complete. state.isSuccess is now: ${state.isSuccess}');
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

        debugPrint('❌ OTP Verification Error: $errorMsg');

        emit(state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: errorMsg,
        ));
      }
    } catch (e, st) {
      debugPrint('💥 verifyOtp() EXCEPTION: $e');
      debugPrint('$st');
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: 'Error verifying OTP: ${e.toString()}',
      ));
    }
  }

  /// Resend OTP
  Future<void> resendOtp() async {
    debugPrint('════════════════════════════════════════');
    debugPrint('🟣 resendOtp() CALLED at ${DateTime.now()}');
    debugPrint('🟣 Cubit instance hashCode: $hashCode');
    debugPrint('🟣 Current state.verificationToken: ${state.verificationToken}');
    debugPrint('════════════════════════════════════════');

    try {
      final token = state.verificationToken;
      if (token == null) {
        debugPrint('🔴 resendOtp(): TOKEN IS NULL — bailing out.');
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

      debugPrint('🔑 Resending OTP with Token: $token');

      final Map<String, dynamic> requestBody = {};

      final response = await _networkCaller.postRequest(
        AppUrl.verifyOtp,
        body: requestBody,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📡 Resend OTP Response Status: ${response.statusCode}');
      debugPrint('📡 Resend OTP Response Body: ${response.jsonResponse}');

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
          debugPrint('✅ New Verification Token received: $newToken');
          emit(state.copyWith(
            isLoading: false,
            verificationToken: newToken,
            errorMessage: null,
          ));
        } else {
          debugPrint('ℹ️ No new token returned from resend — keeping existing token.');
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

        debugPrint('❌ resendOtp failed: $errorMsg');

        emit(state.copyWith(
          isLoading: false,
          errorMessage: errorMsg,
        ));
      }
    } catch (e, st) {
      debugPrint('💥 resendOtp() EXCEPTION: $e');
      debugPrint('$st');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Error resending OTP: ${e.toString()}',
      ));
    }
  }

  /// Clear sensitive data after flow completion
  void clearData() {
    debugPrint('🧹 clearData() CALLED at ${DateTime.now()} — Cubit hashCode=$hashCode');
    debugPrint('🧹 State BEFORE clear: token=${state.verificationToken}, '
        'isSuccess=${state.isSuccess}');
    emit(const AuthRegistrationState());
    debugPrint('🧹 State AFTER clear: token=${state.verificationToken}, '
        'isSuccess=${state.isSuccess}');
  }

  /// Reset error state
  void clearError() {
    debugPrint('🧽 clearError() called');
    emit(state.copyWith(errorMessage: null));
  }

  /// Set loading state for API operations
  void setLoading(bool value) {
    debugPrint('⏳ setLoading($value) called');
    emit(state.copyWith(isLoading: value));
  }

  /// Set error message
  void setError(String message) {
    debugPrint('⚠️ setError("$message") called');
    emit(state.copyWith(errorMessage: message, isLoading: false));
  }

  // ==================== GETTERS ====================
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