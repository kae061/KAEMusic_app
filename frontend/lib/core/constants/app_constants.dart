class AppConstants {
  AppConstants._();

  static const String appName = 'KAEMusic';
  static const String baseUrl = 'http://localhost:8081/api/v1';

  /// Origin for static assets (avatars) served outside `/api/v1`.
  static String get serverOrigin =>
      baseUrl.replaceFirst(RegExp(r'/api/v1/?$'), '');

  static String resolveMediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final normalized = path.startsWith('/') ? path : '/$path';
    return '$serverOrigin$normalized';
  }

  // Token keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';

  // API Endpoints
  static const String favoritesEndpoint = '/favorites';
  static const String favoritesToggleEndpoint = '/favorites/toggle';
  static const String favoritesCheckEndpoint = '/favorites/check';
  static const String playlistsEndpoint = '/playlists';

  // Profile cache keys
  static const String displayNameKey = 'display_name';
  static const String avatarUrlKey = 'avatar_url';
  
  // Profile Endpoints
  static const String getProfileUrl = '/users/me';
  static const String updateDisplayNameUrl = '/users/me/display-name';
  static const String uploadAvatarUrl = '/users/me/avatar';
  static const String tokenKey = 'auth_token';

  // Pagination
  static const int defaultPageSize = 20;

  // Timeouts
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 15000;
}
