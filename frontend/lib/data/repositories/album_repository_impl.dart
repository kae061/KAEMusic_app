import '../../domain/entities/album.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/album_repository.dart';
import '../datasources/album_remote_datasource.dart';

class AlbumRepositoryImpl implements AlbumRepository {
  final AlbumRemoteDataSource _dataSource;

  AlbumRepositoryImpl({AlbumRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? AlbumRemoteDataSource();

  @override
  Future<List<Album>> getAlbums({int page = 0, int size = 20}) =>
      _dataSource.getAlbums(page: page, size: size);

  @override
  Future<Album> getAlbumById(String id) => _dataSource.getAlbumById(id);

  @override
  Future<List<Song>> getAlbumSongs(String albumId) => _dataSource.getAlbumSongs(albumId);
}
