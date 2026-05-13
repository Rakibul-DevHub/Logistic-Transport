// lib/core/models/signup_data.dart
class CreateAccountData {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  CreateAccountData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  // Optional: Add toJson and fromJson methods if needed for API calls
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
    };
  }

  factory CreateAccountData.fromJson(Map<String, dynamic> json) {
    return CreateAccountData(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
    );
  }
}