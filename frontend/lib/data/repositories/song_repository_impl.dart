import '../../domain/entities/song.dart';
import '../../domain/repositories/song_repository.dart';
import '../datasources/song_remote_datasource.dart';

class SongRepositoryImpl implements SongRepository {
  final SongRemoteDataSource _dataSource;

  SongRepositoryImpl({SongRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? SongRemoteDataSource();

  @override
  Future<List<Song>> getSongs({int page = 0, int size = 20}) =>
      _dataSource.getSongs(page: page, size: size);

  @override
  Future<Song> getSongById(String id) => _dataSource.getSongById(id);

  @override
  Future<List<Song>> searchSongs(String query, {int page = 0, int size = 20}) =>
      _dataSource.searchSongs(query, page: page, size: size);

  @override
  Future<List<Song>> getLikedSongs() async => [];

  @override
  Future<void> likeSong(String id) async {}

  @override
  Future<void> unlikeSong(String id) async {}
}
