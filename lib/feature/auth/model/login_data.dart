// lib/feature/auth/model/login_data.dart

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json['email'],
      password: json['password'],
    );
  }
}

class LoginResponse {
  final int code;
  final LoginData? data;
  final String? message;

  LoginResponse({
    required this.code,
    this.data,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      code: json['code'] ?? 0,
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}

class LoginData {
  final User? user;
  final Tokens? tokens;

  LoginData({
    this.user,
    this.tokens,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      tokens: json['tokens'] != null ? Tokens.fromJson(json['tokens']) : null,
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final Location? location;
  final String profileImage;
  final String role;
  final String status;
  final bool isEmailVerified;
  final bool isResetPassword;
  final bool isDeleted;
  final int failedLoginAttempts;
  final int step;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.location,
    required this.profileImage,
    required this.role,
    required this.status,
    required this.isEmailVerified,
    required this.isResetPassword,
    required this.isDeleted,
    required this.failedLoginAttempts,
    required this.step,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      profileImage: json['profileImage'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      isEmailVerified: json['isEmailVerified'] ?? false,
      isResetPassword: json['isResetPassword'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      failedLoginAttempts: json['failedLoginAttempts'] ?? 0,
      step: json['step'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class Location {
  final String type;
  final List<num> coordinates; // ✅ FIXED: Use num instead of double

  Location({
    required this.type,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] ?? '',
      coordinates: List<num>.from(json['coordinates'] ?? []), // ✅ FIXED
    );
  }

  // Helper method to get coordinates as doubles when needed
  List<double> get coordinatesAsDoubles {
    return coordinates.map((e) => e.toDouble()).toList();
  }
}

class Tokens {
  final String accessToken;
  final String refreshToken;

  Tokens({
    required this.accessToken,
    required this.refreshToken,
  });

  factory Tokens.fromJson(Map<String, dynamic> json) {
    return Tokens(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }
}