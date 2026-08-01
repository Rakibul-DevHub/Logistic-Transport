/// In-memory auth flags set right after login / loaded from secure storage.
/// Home and other screens can read this synchronously.
class AuthSession {
  AuthSession._();

  static bool? isParentDriver;
  static bool? isOwner;
  static String? parentDriverId;
  static String? userId;

  static void setFromLogin({
    required bool isParentDriverValue,
    String? parentDriverIdValue,
    String? userIdValue,
  }) {
    isParentDriver = isParentDriverValue;
    isOwner = isParentDriverValue;
    parentDriverId =
        isParentDriverValue ? null : parentDriverIdValue;
    userId = userIdValue;
  }

  static void clear() {
    isParentDriver = null;
    isOwner = null;
    parentDriverId = null;
    userId = null;
  }
}
