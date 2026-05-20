import '../entities/playlist.dart';

abstract class PlaylistRepository {
  Future<List<Playlist>> getMyPlaylists();
  Future<Playlist> getPlaylistById(String id);
  Future<Playlist> createPlaylist({required String name, String? description});
  Future<Playlist> renamePlaylist({required String id, required String name});
  Future<void> deletePlaylist(String id);
  Future<Playlist> addTrackToPlaylist({required String playlistId, required String trackId});
  Future<Playlist> removeTrackFromPlaylist({required String playlistId, required String trackId});
}
