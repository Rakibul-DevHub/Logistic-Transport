// class CreateAccountData {
//   final String fullName;
//   final String email;
//   final String password;
//
//   CreateAccountData({
//     required this.fullName,
//     required this.email,
//     required this.password,
//   });
//
//   // Optional: Add toJson and fromJson methods if needed for API calls
//   Map<String, dynamic> toJson() {
//     return {
//       'fullName': fullName,
//       'email': email,
//       'password': password,
//     };
//   }
//
//   factory CreateAccountData.fromJson(Map<String, dynamic> json) {
//     return CreateAccountData(
//       fullName: json['fullName'],
//       email: json['email'],
//       password: json['password'],
//     );
//   }
// }









// lib/core/models/create_account_data.dart
class CreateAccountData {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  CreateAccountData({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }

  factory CreateAccountData.fromJson(Map<String, dynamic> json) {
    return CreateAccountData(
      name: json['name'],
      email: json['email'],
      password: json['password'],
      confirmPassword: json['confirmPassword'],
    );
  }
}