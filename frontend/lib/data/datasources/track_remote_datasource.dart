
import '../../core/network/dio_client.dart';
import '../models/track_model.dart';

class TrackRemoteDataSource {
  final DioClient _dioClient;

  TrackRemoteDataSource(this._dioClient);

  Future<List<Track>> fetchTracks(int page, int size) async {
    try {
      final response = await _dioClient.dio.get('/tracks', queryParameters: {
        'page': page,
        'size': size,
      });
      final data = response.data['content'] as List;
      return data.map((e) => Track.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tracks');
    }
  }

  Future<List<Track>> searchTracks(String query) async {
    try {
      final response = await _dioClient.dio.get('/tracks/search', queryParameters: {
        'q': query,
      });
      final data = response.data as List;
      return data.map((e) => Track.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to search tracks');
    }
  }

  Future<Track> fetchTrackById(String id) async {
    try {
      final response = await _dioClient.dio.get('/tracks/$id');
      return Track.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch track details');
    }
  }
}
