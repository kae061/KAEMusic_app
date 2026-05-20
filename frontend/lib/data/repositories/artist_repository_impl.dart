import '../../domain/entities/artist.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/artist_repository.dart';
import '../datasources/artist_remote_datasource.dart';

class ArtistRepositoryImpl implements ArtistRepository {
  final ArtistRemoteDataSource _dataSource;

  ArtistRepositoryImpl({ArtistRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? ArtistRemoteDataSource();

  @override
  Future<List<Artist>> getArtists({int page = 0, int size = 20}) =>
      _dataSource.getArtists(page: page, size: size);

  @override
  Future<Artist> getArtistById(String id) => _dataSource.getArtistById(id);

  @override
  Future<List<Album>> getArtistAlbums(String artistId) =>
      _dataSource.getArtistAlbums(artistId);

  @override
  Future<List<Song>> getArtistSongs(String artistId) =>
      _dataSource.getArtistSongs(artistId);
}
