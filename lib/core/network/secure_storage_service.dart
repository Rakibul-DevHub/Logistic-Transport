/**
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  // Initialize with default settings
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accountName: 'TagApp',
      synchronizable: true,
    ),
  );

  static SecureStorageService get instance => _instance;

  // Save tokens
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: 'access_token', value: token);
      print('✅ Access token saved successfully::::: $token');
    } catch (e) {
      print('❌ Error saving access token: $e');
      rethrow;
    }
  }

  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: 'refresh_token', value: token);
      print('✅ Refresh token saved successfully:::::: $token');
    } catch (e) {
      print('❌ Error saving refresh token: $e');
      rethrow;
    }
  }

  Future<void> saveUserEmail(String email) async {
    try {
      await _storage.write(key: 'user_email', value: email);
      print('✅ User email saved successfully');
    } catch (e) {
      print('❌ Error saving user email: $e');
      rethrow;
    }
  }

  // Get tokens
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: 'access_token');
    } catch (e) {
      print('❌ Error reading access token: $e');
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: 'refresh_token');
    } catch (e) {
      print('❌ Error reading refresh token: $e');
      return null;
    }
  }

  Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: 'user_email');
    } catch (e) {
      print('❌ Error reading user email: $e');
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = await getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Delete all tokens
  Future<void> deleteAllTokens() async {
    try {
      await _storage.deleteAll();
      print('✅ All tokens deleted');
    } catch (e) {
      print('❌ Error deleting tokens: $e');
      rethrow;
    }
  }

  // Delete specific keys
  Future<void> deleteAccessToken() async {
    try {
      await _storage.delete(key: 'access_token');
      print('✅ Access token deleted');
    } catch (e) {
      print('❌ Error deleting access token: $e');
      rethrow;
    }
  }

  Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: 'refresh_token');
      print('✅ Refresh token deleted');
    } catch (e) {
      print('❌ Error deleting refresh token: $e');
      rethrow;
    }
  }

  // Read all keys (for debugging)
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      print('❌ Error reading all: $e');
      return {};
    }
  }

  // Check if a key exists
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      print('❌ Error checking key: $e');
      return false;
    }
  }
}*/






///
///
///
///
/// todo:: updating for to track the user role
///
///
///
///






import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance =
  SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accountName: 'TagApp',
      synchronizable: true,
    ),
  );

  static SecureStorageService get instance => _instance;

  // ── Keys ──────────────────────────────────────────────
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserRole = 'user_role';
  static const String _keyIsParentDriver = 'is_parent_driver';
  static const String _keyIsOwner = 'is_owner';
  static const String _keyParentDriverId = 'parent_driver_id';

  // ── Save tokens ───────────────────────────────────────
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _keyUserEmail, value: email);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  Future<void> saveUserName(String name) async {
    await _storage.write(key: _keyUserName, value: name);
  }

  Future<void> saveUserRole(String role) async {
    await _storage.write(key: _keyUserRole, value: role);
  }

  /// isParentDriver == true  → owner
  /// isParentDriver == false → not owner
  Future<void> saveIsParentDriver(bool isParentDriver) async {
    await _storage.write(
      key: _keyIsParentDriver,
      value: isParentDriver.toString(),
    );
    await _storage.write(
      key: _keyIsOwner,
      value: isParentDriver.toString(),
    );
  }

  Future<void> saveParentDriverId(String? parentDriverId) async {
    if (parentDriverId == null || parentDriverId.isEmpty) {
      await _storage.delete(key: _keyParentDriverId);
      return;
    }
    await _storage.write(key: _keyParentDriverId, value: parentDriverId);
  }

  /// Call this once after successful login.
  ///
  /// Rules:
  /// - isParentDriver == true  → owner, clear parentDriverId
  /// - isParentDriver == false → not owner, store parentDriverId
  Future<void> saveLoginSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String email,
    required String name,
    required String role,
    required bool isParentDriver,
    String? parentDriverId,
  }) async {
    // Sequential writes avoid secure-storage race on some devices.
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
    await saveUserId(userId);
    await saveUserEmail(email);
    await saveUserName(name);
    await saveUserRole(role);
    await saveIsParentDriver(isParentDriver);
    await saveParentDriverId(
      isParentDriver ? null : parentDriverId,
    );
  }

  // ── Getters ───────────────────────────────────────────
  Future<String?> getAccessToken() async {
    return _storage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _keyRefreshToken);
  }

  Future<String?> getUserEmail() async {
    return _storage.read(key: _keyUserEmail);
  }

  Future<String?> getUserId() async {
    return _storage.read(key: _keyUserId);
  }

  Future<String?> getUserName() async {
    return _storage.read(key: _keyUserName);
  }

  Future<String?> getUserRole() async {
    return _storage.read(key: _keyUserRole);
  }

  Future<bool> getIsParentDriver() async {
    final value = await _storage.read(key: _keyIsParentDriver);
    return value == 'true';
  }

  Future<bool> getIsOwner() async {
    final value = await _storage.read(key: _keyIsOwner);
    return value == 'true';
  }

  Future<String?> getParentDriverId() async {
    return _storage.read(key: _keyParentDriverId);
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ── Delete ────────────────────────────────────────────
  Future<void> deleteAllTokens() async {
    await _storage.deleteAll();
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _keyAccessToken);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _keyRefreshToken);
  }

  Future<Map<String, String>> readAll() async {
    return _storage.readAll();
  }

  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key: key);
  }
}