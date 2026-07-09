// lib/feature/auth/cubit/forgot_password_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/utils/app_url.dart';

// ==================== STATES ====================
abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordSuccess extends ForgotPasswordState {
  final String? resetToken;
  final String message;

  const ForgotPasswordSuccess({
    this.resetToken,
    required this.message,
  });

  @override
  List<Object?> get props => [resetToken, message];
}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String errorMessage;

  const ForgotPasswordFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

// ==================== CUBIT ====================
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  ForgotPasswordCubit() : super(ForgotPasswordInitial());

  Future<void> sendResetCode({
    required String email,
  }) async {
    try {
      emit(ForgotPasswordLoading());

      final requestBody = {
        'email': email.trim(),
      };

      final response = await _networkCaller.postRequest(
        AppUrl.forgotPassword,
        body: requestBody,
      );

      if (response.isSuccess) {
        // ✅ Get reset token from response
        String? resetToken = response.jsonResponse?['data']?['resetPasswordToken'];

        String message = response.jsonResponse?['message'] ??
            'Reset code sent to your email';

        emit(ForgotPasswordSuccess(
          resetToken: resetToken,
          message: message,
        ));
      } else {
        String errorMsg = response.errorMessage ?? 'Failed to send reset code';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }

        emit(ForgotPasswordFailure(errorMessage: errorMsg));
      }
    } catch (e) {
      emit(ForgotPasswordFailure(
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  void resetState() {
    emit(ForgotPasswordInitial());
  }

  void clearError() {
    if (state is ForgotPasswordFailure) {
      emit(ForgotPasswordInitial());
    }
  }

  bool get isLoading => state is ForgotPasswordLoading;
  bool get isSuccess => state is ForgotPasswordSuccess;
  String? get errorMessage {
    if (state is ForgotPasswordFailure) {
      return (state as ForgotPasswordFailure).errorMessage;
    }
    return null;
  }
}