class AppUrl {
  AppUrl._();

  /// ------------------ Base URL -------------------
  static const String baseUrl = "https://pjxppsdl-8083.inc1.devtunnels.ms/api/v1";
  static const String imageBaseUrl = "https://pjxppsdl-8083.inc1.devtunnels.ms/uploads";


  /// ---------------- Image Upload ------------------------------
  static const String singleImageUpload = "$baseUrl/upload";
  static const String updateMultipleImage = "uploads"; // not used into main coding



  /// --------- Home -------------

  static const String homeReport = "$baseUrl/report/report";




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
  static String getLoad(String page, String limit, String type) {
    return "$baseUrl/load/my-loads?page=$page&limit=$limit&type=$type";
  }

  static String getIdLoadDetails(String loadId) {
    return "$baseUrl/load/$loadId";
  }

  static const String addLoadExpense = "$baseUrl/load-expense";

  static String getLoadExpense(String id) {
    return "$baseUrl/load-expense/load/$id";
  }

  /// ------------------ report ---------------
  // Dates are optional — omit both to hit `/report` with no query params.
  static String report([String? startDate, String? endDate]) {
    final hasStart = startDate != null && startDate.isNotEmpty;
    final hasEnd = endDate != null && endDate.isNotEmpty;
    if (!hasStart && !hasEnd) return "$baseUrl/report";

    final params = <String>[];
    if (hasStart) params.add("startDate=$startDate");
    if (hasEnd) params.add("endDate=$endDate");
    return "$baseUrl/report?${params.join('&')}";
  }




  /// ------------------ notification ---------------
  static String getAllNotification(String page, String limit) {
    return "$baseUrl/notification?page=$page&limit=$limit&sortField=createdAt&sortOrder=desc";
  }




  /// ------------------ profile terms-privacy help & support ---------------
  static const String termsAndConditions = "$baseUrl/setting/terms-conditions";
  static const String privacyPolicy = "$baseUrl/setting/privacy-policy";
  static const String helpSupport = "$baseUrl/setting/support";


}