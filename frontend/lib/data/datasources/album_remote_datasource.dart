import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../models/album_model.dart';
import '../models/song_model.dart';
import 'mock_data.dart';

class AlbumRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<List<AlbumModel>> getAlbums({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.albums,
        queryParameters: {'page': page, 'size': size},
      );
      final data = response.data;
      final items = (data is Map) ? (data['content'] as List<dynamic>? ?? []) : data as List<dynamic>;
      return items.map((e) => AlbumModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return MockData.albums;
    }
  }

  Future<AlbumModel> getAlbumById(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.withId(ApiEndpoints.albumById, id));
      return AlbumModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return MockData.albums.firstWhere(
        (a) => a.id == id,
        orElse: () => MockData.albums.first,
      );
    }
  }

  Future<List<SongModel>> getAlbumSongs(String albumId) async {
    try {
      final response = await _dio.get(ApiEndpoints.withId(ApiEndpoints.albumSongs, albumId));
      final items = response.data as List<dynamic>;
      return items.map((e) => SongModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return MockData.songs.where((s) => s.albumId == albumId).toList();
    }
  }
}

