import '../entities/song.dart';

abstract class SongRepository {
  Future<List<Song>> getSongs({int page = 0, int size = 20});
  Future<Song> getSongById(String id);
  Future<List<Song>> searchSongs(String query, {int page = 0, int size = 20});
  Future<List<Song>> getLikedSongs();
  Future<void> likeSong(String id);
  Future<void> unlikeSong(String id);
}
