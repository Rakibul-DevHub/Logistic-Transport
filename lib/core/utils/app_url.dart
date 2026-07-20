class AppUrl {
  AppUrl._();

  /// ------------------ Base URL -------------------
  static const String baseUrl = "https://pjxppsdl-8083.inc1.devtunnels.ms/api/v1";
  static const String imageBaseUrl = "https://pjxppsdl-8083.inc1.devtunnels.ms/uploads";


  /// ---------------- Image Upload ------------------------------
  static const String singleImageUpload = "$baseUrl/upload";
  static const String updateMultipleImage = "uploads"; // not used into main coding



  /// --------- Profile -------------
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
  static const String userProfileImageUpload = "$baseUrl/upload";



  /// ----------- Subscription ----------------
  static const String activeSubscriptionPlans = "$baseUrl/plan";
  static const String myActivePlan = "$baseUrl/user-plan/me";
  static const String subscriptionFreeTrial = "$baseUrl/user-plan/start-trial";
  static const String subscriptionPurchase = "$baseUrl/user-plan/purchase";


  /// ----------------- Add Driver ----------------
  static const String addDriver = "$baseUrl/user/drivers/sub-drivers";
  static const String getDriverList = "$baseUrl/user/drivers/sub-drivers";
  static String deleteDriver(String subDriverId) {
    return "$baseUrl/user/drivers/sub-drivers/$subDriverId";
  }


  /// -------------- Document OCR --------------------
  static const String scanDocOcr = "$baseUrl/load/ocr";
  static const String createBillOfLoad = "$baseUrl/load/create-from-ocr";
  static const String addLoad = "$baseUrl/load/create-manual";



  /// -------------- Load ---------------------
  static const String loadExpense = "$baseUrl/load-expense";

  static String getMyLoad(String page, String limit) {
    return "$baseUrl/load/my-loads?page=$page&limit=$limit";
  }



  static const String termsAndConditions = "$baseUrl/setting/terms-conditions";
  static const String privacyPolicy = "$baseUrl/setting/privacy-policy";


}