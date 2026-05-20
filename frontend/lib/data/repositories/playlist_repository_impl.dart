import '../../domain/entities/playlist.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../datasources/playlist_remote_datasource.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistRemoteDataSource _dataSource;

  PlaylistRepositoryImpl({PlaylistRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? PlaylistRemoteDataSource();

  @override
  Future<List<Playlist>> getMyPlaylists() => _dataSource.getMyPlaylists();

  @override
  Future<Playlist> getPlaylistById(String id) => _dataSource.getPlaylistById(id);

  @override
  Future<Playlist> createPlaylist({
    required String name,
    String? description,
  }) =>
      _dataSource.createPlaylist(name: name, description: description);

  @override
  Future<Playlist> renamePlaylist({
    required String id,
    required String name,
  }) =>
      _dataSource.renamePlaylist(id: id, name: name);

  @override
  Future<void> deletePlaylist(String id) => _dataSource.deletePlaylist(id);

  @override
  Future<Playlist> addTrackToPlaylist({required String playlistId, required String trackId}) =>
      _dataSource.addTrackToPlaylist(playlistId: playlistId, trackId: trackId);

  @override
  Future<Playlist> removeTrackFromPlaylist({required String playlistId, required String trackId}) =>
      _dataSource.removeTrackFromPlaylist(playlistId: playlistId, trackId: trackId);
}
