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
}