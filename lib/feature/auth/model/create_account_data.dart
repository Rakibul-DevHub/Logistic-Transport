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