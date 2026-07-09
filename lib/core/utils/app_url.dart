class AppUrl {
  AppUrl._();

  static const String baseUrl = "https://pjxppsdl-8083.inc1.devtunnels.ms/api/v1";
  static const String imageBaseUrl = "https://pjxppsdl-8083.inc1.devtunnels.ms/uploads";

  static const String createAccount = "$baseUrl/auth/register";
  static const String logIn = "$baseUrl/auth/login";
  static const String verifyOtp = "$baseUrl/auth/verify-email";

  static const String updatePersonalInformationProfileImage = "uploads";

}