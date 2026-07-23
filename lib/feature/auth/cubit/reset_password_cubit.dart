// lib/feature/auth/cubit/reset_password_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/utils/app_url.dart';

// ==================== STATES ====================
abstract class ResetPasswordState extends Equatable {
  const ResetPasswordState();

  @override
  List<Object?> get props => [];
}

class ResetPasswordInitial extends ResetPasswordState {}

class ResetPasswordLoading extends ResetPasswordState {}

class ResetPasswordSuccess extends ResetPasswordState {
  final String message;

  const ResetPasswordSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ResetPasswordFailure extends ResetPasswordState {
  final String errorMessage;

  const ResetPasswordFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

// ==================== CUBIT ====================
class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  ResetPasswordCubit() : super(ResetPasswordInitial());

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      emit(ResetPasswordLoading());

      final requestBody = {
        'password': newPassword,
        'confirmPassword': confirmPassword,
      };

      // ✅ Send reset token in Authorization header
      final response = await _networkCaller.postRequest(
        AppUrl.resetPassword,
        body: requestBody,
        headers: {
          'Authorization': 'Bearer $resetToken',
        },
      );

      if (response.isSuccess) {
        String message = response.jsonResponse?['message'] ??
            'Password reset successfully';

        emit(ResetPasswordSuccess(message: message));
      } else {
        String errorMsg = response.errorMessage ?? 'Failed to reset password';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }

        emit(ResetPasswordFailure(errorMessage: errorMsg));
      }
    } catch (e) {
      emit(ResetPasswordFailure(
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  void resetState() {
    emit(ResetPasswordInitial());
  }

  void clearError() {
    if (state is ResetPasswordFailure) {
      emit(ResetPasswordInitial());
    }
  }

  bool get isLoading => state is ResetPasswordLoading;
  bool get isSuccess => state is ResetPasswordSuccess;
  String? get errorMessage {
    if (state is ResetPasswordFailure) {
      return (state as ResetPasswordFailure).errorMessage;
    }
    return null;
  }
}