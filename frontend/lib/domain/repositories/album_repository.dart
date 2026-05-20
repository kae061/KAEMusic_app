import '../entities/album.dart';
import '../entities/song.dart';

abstract class AlbumRepository {
  Future<List<Album>> getAlbums({int page = 0, int size = 20});
  Future<Album> getAlbumById(String id);
  Future<List<Song>> getAlbumSongs(String albumId);
}
