class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/users/me';

  // User Profile
  static const String userMe = '/users/me';
  static const String updateDisplayName = '/users/me/display-name';
  static const String updateAvatar = '/users/me/avatar';

  // Songs
  static const String songs = '/songs';
  static const String songById = '/songs/{id}';
  static const String searchSongs = '/songs/search';
  static const String streamSong = '/songs/{id}/stream';

  // Tracks
  static const String tracks = '/tracks';
  static const String searchTracks = '/tracks/search';

  // Favorites
  static const String favorites = '/favorites';
  static const String toggleFavorite = '/favorites/{trackId}';

  // Albums
  static const String albums = '/albums';
  static const String albumById = '/albums/{id}';
  static const String albumSongs = '/albums/{id}/songs';

  // Artists
  static const String artists = '/artists';
  static const String artistById = '/artists/{id}';
  static const String artistAlbums = '/artists/{id}/albums';
  static const String artistSongs = '/artists/{id}/songs';

  // Playlists
  static const String playlists = '/playlists';
  static const String playlistById = '/playlists/{id}';
  static const String playlistTracks = '/playlists/{id}/tracks';
  static const String removeTrackFromPlaylist = '/playlists/{id}/tracks/{trackId}';

  // Helpers
  static String withId(String endpoint, String id) =>
      endpoint.replaceFirst('{id}', id);

  static String withTrackId(String endpoint, String trackId) =>
      endpoint.replaceFirst('{trackId}', trackId);

  static String withIds(String endpoint, String id, String trackId) =>
      endpoint.replaceFirst('{id}', id).replaceFirst('{trackId}', trackId);
}
