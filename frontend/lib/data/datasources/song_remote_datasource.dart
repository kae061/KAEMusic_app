import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../models/song_model.dart';
import 'mock_data.dart';

class SongRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<List<SongModel>> getSongs({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.songs,
        queryParameters: {'page': page, 'size': size},
      );
      final data = response.data as Map<String, dynamic>;
      final items = data['content'] as List<dynamic>? ?? response.data as List<dynamic>;
      return items
          .map((e) => SongModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return MockData.songs;
    }
  }

  Future<SongModel> getSongById(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.withId(ApiEndpoints.songById, id));
      return SongModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return MockData.songs.firstWhere(
        (s) => s.id == id,
        orElse: () => MockData.songs.first,
      );
    }
  }

  Future<List<SongModel>> searchSongs(String query, {int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.searchSongs,
        queryParameters: {'q': query, 'page': page, 'size': size},
      );
      final data = response.data;
      final items = (data is Map) ? (data['content'] as List<dynamic>? ?? []) : data as List<dynamic>;
      return items
          .map((e) => SongModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      final q = query.toLowerCase();
      return MockData.songs
          .where((s) => s.title.toLowerCase().contains(q) || s.artistName.toLowerCase().contains(q))
          .toList();
    }
  }


}

