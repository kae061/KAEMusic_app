import '../entities/user.dart';

abstract class AuthRepository {
  Future<({User user, String accessToken, String refreshToken})> login({
    required String email,
    required String password,
  });

  Future<({User user, String accessToken, String refreshToken})> register({
    required String username,
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<User> getMe();
}
