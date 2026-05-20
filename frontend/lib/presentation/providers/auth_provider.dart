import 'package:flutter/foundation.dart';
import '../../core/utils/token_manager.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider();

  final AuthRemoteDataSource _authDataSource = AuthRemoteDataSource();

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get displayName => _user?.displayName;
  String? get avatarUrl => _user?.avatarUrl;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> checkAuthStatus() async {
    final hasTokens = await TokenManager.hasTokens();
    if (hasTokens) {
      try {
        await _fetchProfile();
        if (_user != null) {
          await TokenManager.saveValue(key: AppConstants.userIdKey, value: _user!.id);
        }
        _status = AuthStatus.authenticated;
      } catch (_) {
        await TokenManager.clearTokens();
        _status = AuthStatus.unauthenticated;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _authDataSource.login(email: email, password: password);

      final accessToken = data['accessToken'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      if (accessToken != null && refreshToken != null) {
        await TokenManager.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }

      final userData = data['user'];
      if (userData is Map<String, dynamic>) {
        _user = UserModel.fromJson(userData);
      } else {
        await _fetchProfile();
      }

      if (_user != null) {
        await TokenManager.saveValue(key: AppConstants.userIdKey, value: _user!.id);
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _authDataSource.register(
        username: username,
        email: email,
        password: password,
      );

      final accessToken = data['accessToken'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      if (accessToken != null && refreshToken != null) {
        await TokenManager.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }

      final userData = data['user'];
      if (userData is Map<String, dynamic>) {
        _user = UserModel.fromJson(userData);
      }

      if (_user != null) {
        await TokenManager.saveValue(key: AppConstants.userIdKey, value: _user!.id);
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _authDataSource.logout();
    await TokenManager.clearTokens();
    await TokenManager.deleteValue(AppConstants.displayNameKey);
    await TokenManager.deleteValue(AppConstants.avatarUrlKey);
    _user = null;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> loadCurrentUser() async {
    try {
      await _fetchProfile();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> updateDisplayName(String newName) async {
    try {
      debugPrint('=== updateDisplayName START ===');
      debugPrint('Updating display name: $newName');
      final hasTokens = await TokenManager.hasTokens();
      debugPrint('Has tokens: $hasTokens');
      final accessToken = await TokenManager.getAccessToken();
      debugPrint('Access token: ${accessToken != null ? "exists (${accessToken.length} chars)" : "null"}');
      if (accessToken != null) {
        debugPrint('Token prefix: ${accessToken.substring(0, 20)}...');
      }
      final userId = await TokenManager.getValue(AppConstants.userIdKey);
      debugPrint('User ID: $userId');

      final updated = await _authDataSource.updateDisplayName(newName);
      _user = updated;
      debugPrint('=== updateDisplayName SUCCESS ===');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('=== updateDisplayName FAILED ===');
      debugPrint('Failed to update display name: $e');
      return false;
    }
  }

  Future<bool> updateAvatarUrl(String avatarUrl) async {
    try {
      final updated = await _authDataSource.updateAvatar(avatarUrl);
      _user = updated;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to update avatar: $e');
      return false;
    }
  }

  Future<bool> uploadAvatarFile(String filePath, String fileName) async {
    try {
      debugPrint('Uploading avatar file: $fileName');
      final hasTokens = await TokenManager.hasTokens();
      debugPrint('Has tokens: $hasTokens');
      final accessToken = await TokenManager.getAccessToken();
      debugPrint('Access token: ${accessToken != null ? "exists" : "null"}');
      final userId = await TokenManager.getValue(AppConstants.userIdKey);
      debugPrint('User ID: $userId');

      final updated = await _authDataSource.uploadAvatarFile(filePath, fileName);
      _user = updated;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to upload avatar file: $e');
      return false;
    }
  }

  Future<bool> deleteAvatar() async {
    try {
      final updated = await _authDataSource.deleteAvatar();
      _user = updated;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to delete avatar: $e');
      return false;
    }
  }

  Future<void> _fetchProfile() async {
    final userModel = await _authDataSource.getMe();
    _user = userModel;
  }

  String _extractErrorMessage(dynamic e) {
    if (e is Exception) {
      final msg = e.toString();
      if (msg.contains('message')) {
        final match = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(msg);
        if (match != null) return match.group(1)!;
      }
      if (msg.contains('Invalid credentials')) return 'Invalid email or password.';
      if (msg.contains('already exists')) return 'Username or email already taken.';
      if (msg.contains('Connection refused') || msg.contains('SocketException')) {
        return 'Cannot connect to server. Please try again later.';
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }
}