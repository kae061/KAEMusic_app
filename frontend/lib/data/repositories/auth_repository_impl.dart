import '../../core/constants/app_constants.dart';
import '../../core/utils/token_manager.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl({AuthRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? AuthRemoteDataSource();

  @override
  Future<({User user, String accessToken, String refreshToken})> login({
    required String email,
    required String password,
  }) async {
    final data = await _dataSource.login(email: email, password: password);
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    final accessToken = data['accessToken'] as String? ?? data['token'] as String?;
    final refreshToken = data['refreshToken'] as String? ?? accessToken;
    if (accessToken == null || refreshToken == null) {
      throw StateError('Auth response did not include tokens');
    }
    await TokenManager.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
    await TokenManager.saveValue(key: AppConstants.userIdKey, value: user.id);
    return (user: user as User, accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<({User user, String accessToken, String refreshToken})> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final data = await _dataSource.register(
      username: username,
      email: email,
      password: password,
    );
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    final accessToken = data['accessToken'] as String? ?? data['token'] as String?;
    final refreshToken = data['refreshToken'] as String? ?? accessToken;
    if (accessToken == null || refreshToken == null) {
      throw StateError('Auth response did not include tokens');
    }
    await TokenManager.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
    await TokenManager.saveValue(key: AppConstants.userIdKey, value: user.id);
    return (user: user as User, accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<void> logout() async {
    try {
      await _dataSource.logout();
    } finally {
      await TokenManager.clearTokens();
    }
  }

  @override
  Future<User> getMe() => _dataSource.getMe();
}
