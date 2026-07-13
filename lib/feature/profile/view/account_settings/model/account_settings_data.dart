/**
class AccountSettingResponse {
  final int code;
  final UserData? data;

  AccountSettingResponse({
    required this.code,
    this.data,
  });

  factory AccountSettingResponse.fromJson(Map<String, dynamic> json) {
    return AccountSettingResponse(
      code: json['code'] ?? 0,
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }
}

class UserData {
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

  UserData({
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

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      profileImage: json['profileImage'] ?? 'users/user.png',
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

  // Helper to get initials for avatar
  String get initials {
    if (name.isEmpty) return '';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
}

class Location {
  final String type;
  final List<num> coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] ?? '',
      coordinates: List<num>.from(json['coordinates'] ?? []),
    );
  }
}*/










///
///
///
/// todo: updating
///
///
///





// lib/feature/profile/view/account_settings/model/account_settings_data.dart

class AccountSettingResponse {
  final int code;
  final UserData? data;

  AccountSettingResponse({
    required this.code,
    this.data,
  });

  factory AccountSettingResponse.fromJson(Map<String, dynamic> json) {
    return AccountSettingResponse(
      code: json['code'] ?? 0,
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }
}

class UserData {
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
  final String phone; // ✅ Added phone
  final String? address; // ✅ Added address

  UserData({
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
    required this.phone,
    this.address,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      profileImage: json['profileImage'] ?? 'users/user.png',
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      isEmailVerified: json['isEmailVerified'] ?? false,
      isResetPassword: json['isResetPassword'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      failedLoginAttempts: json['failedLoginAttempts'] ?? 0,
      step: json['step'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      phone: json['phone'],
      address: json['address'],
    );
  }

  // Helper to get initials for avatar
  String get initials {
    if (name.isEmpty) return '';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
}

class Location {
  final String type;
  final List<num> coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] ?? '',
      coordinates: List<num>.from(json['coordinates'] ?? []),
    );
  }
}