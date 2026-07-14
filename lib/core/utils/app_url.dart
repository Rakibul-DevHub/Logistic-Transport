class AppUrl {
  AppUrl._();

  static const String baseUrl = "https://pjxppsdl-8083.inc1.devtunnels.ms/api/v1";
  static const String imageBaseUrl = "https://pjxppsdl-8083.inc1.devtunnels.ms/uploads";

  static const String createAccount = "$baseUrl/auth/register";
  static const String userProfile = "$baseUrl/user/me";
  static const String userProfileUpdate = "$baseUrl/user/me";
  static const String logIn = "$baseUrl/auth/login";
  static const String logOut = "$baseUrl/auth/logout";
  static const String changePassword = "$baseUrl/auth/change-password";
  static const String forgotPassword = "$baseUrl/auth/forgot-password";
  static const String resetPassword = "$baseUrl/auth/reset-password";
  static const String verifyOtp = "$baseUrl/auth/verify-email";
  static const String deleteUserAccount = "$baseUrl/user/me";

  static const String singleImageUpload = "$baseUrl/upload";

  static const String activeSubscriptionPlans = "$baseUrl/plan";
  static const String myActivePlan = "$baseUrl/user-plan/me";
  static const String subscriptionFreeTrial = "$baseUrl/user-plan/start-trial";
  static const String subscriptionPurchase = "$baseUrl/user-plan/start-trial";

  static const String updatePersonalInformationProfileImage = "uploads";

}