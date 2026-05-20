import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../models/artist_model.dart';
import '../models/album_model.dart';
import '../models/song_model.dart';
import 'mock_data.dart';

class ArtistRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<List<ArtistModel>> getArtists({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.artists,
        queryParameters: {'page': page, 'size': size},
      );
      final data = response.data;
      final items = (data is Map) ? (data['content'] as List<dynamic>? ?? []) : data as List<dynamic>;
      return items.map((e) => ArtistModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return MockData.artists;
    }
  }

  Future<ArtistModel> getArtistById(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.withId(ApiEndpoints.artistById, id));
      return ArtistModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return MockData.artists.firstWhere(
        (a) => a.id == id,
        orElse: () => MockData.artists.first,
      );
    }
  }

  Future<List<AlbumModel>> getArtistAlbums(String artistId) async {
    try {
      final response = await _dio.get(ApiEndpoints.withId(ApiEndpoints.artistAlbums, artistId));
      final items = response.data as List<dynamic>;
      return items.map((e) => AlbumModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return MockData.albums.where((a) => a.artistId == artistId).toList();
    }
  }

  Future<List<SongModel>> getArtistSongs(String artistId) async {
    try {
      final response = await _dio.get(ApiEndpoints.withId(ApiEndpoints.artistSongs, artistId));
      final items = response.data as List<dynamic>;
      return items.map((e) => SongModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return MockData.songs.where((s) => s.artistId == artistId).toList();
    }
  }
}

