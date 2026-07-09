// lib/feature/auth/model/reset_password_data.dart

class ResetPasswordRequest {
  final String email;
  final String otp;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ResetPasswordRequest(
      email: json['email'],
      otp: json['otp'],
      newPassword: json['newPassword'],
      confirmPassword: json['confirmPassword'],
    );
  }
}

class ResetPasswordResponse {
  final int code;
  final String? message;
  final bool success;

  ResetPasswordResponse({
    required this.code,
    this.message,
    this.success = false,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      code: json['code'] ?? 0,
      message: json['message'],
      success: json['success'] ?? json['code'] == 200,
    );
  }
}