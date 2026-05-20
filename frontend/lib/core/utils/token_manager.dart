import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Token manager that works on both native and web platforms.
/// On web, falls back to in-memory storage when secure storage fails.
class TokenManager {
  TokenManager._();

  static const _storage = FlutterSecureStorage(
    webOptions: WebOptions.defaultOptions,
  );

  // In-memory fallback for web when secure storage fails
  static final Map<String, String> _memoryStore = {};

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: AppConstants.accessTokenKey, value: accessToken),
        _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken),
      ]);
    } catch (_) {
      // Fallback to memory on web
      _memoryStore[AppConstants.accessTokenKey] = accessToken;
      _memoryStore[AppConstants.refreshTokenKey] = refreshToken;
    }
  }

  static Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: AppConstants.accessTokenKey);
    } catch (_) {
      return _memoryStore[AppConstants.accessTokenKey];
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: AppConstants.refreshTokenKey);
    } catch (_) {
      return _memoryStore[AppConstants.refreshTokenKey];
    }
  }

  static Future<void> clearTokens() async {
    _memoryStore.remove(AppConstants.accessTokenKey);
    _memoryStore.remove(AppConstants.refreshTokenKey);
    _memoryStore.remove(AppConstants.userIdKey);
    try {
      await Future.wait([
        _storage.delete(key: AppConstants.accessTokenKey),
        _storage.delete(key: AppConstants.refreshTokenKey),
        _storage.delete(key: AppConstants.userIdKey),
      ]);
    } catch (_) {
      // Already cleared from memory
    }
  }

  static Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> saveValue({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      _memoryStore[key] = value;
    }
  }

  static Future<String?> getValue(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return _memoryStore[key];
    }
  }

  static Future<void> deleteValue(String key) async {
    _memoryStore.remove(key);
    try {
      await _storage.delete(key: key);
    } catch (_) {
      // Already cleared from memory
    }
  }
}
