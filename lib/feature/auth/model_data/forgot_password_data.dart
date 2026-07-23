// lib/feature/auth/model_data/forgot_password_data.dart

class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordRequest(
      email: json['email'],
    );
  }
}

class ForgotPasswordResponse {
  final int code;
  final String? message;
  final String? resetToken;

  ForgotPasswordResponse({
    required this.code,
    this.message,
    this.resetToken,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      code: json['code'] ?? 0,
      message: json['message'],
      resetToken: json['data']?['resetToken'] ?? json['resetToken'],
    );
  }
}