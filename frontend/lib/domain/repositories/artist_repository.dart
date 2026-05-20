import '../entities/artist.dart';
import '../entities/album.dart';
import '../entities/song.dart';

abstract class ArtistRepository {
  Future<List<Artist>> getArtists({int page = 0, int size = 20});
  Future<Artist> getArtistById(String id);
  Future<List<Album>> getArtistAlbums(String artistId);
  Future<List<Song>> getArtistSongs(String artistId);
}
