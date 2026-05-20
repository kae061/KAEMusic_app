import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/token_manager.dart';
import '../models/playlist_model.dart';

class PlaylistRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<Options?> _userOptions() async {
    final userId = await TokenManager.getValue(AppConstants.userIdKey);
    if (userId == null || userId.isEmpty) {
      return null;
    }
    return Options(headers: {'X-User-Id': userId});
  }

  Future<List<PlaylistModel>> getMyPlaylists() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.playlists,
        options: await _userOptions(),
      );
      final items = response.data as List<dynamic>;
      return items.map((e) => PlaylistModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<PlaylistModel> getPlaylistById(String id) async {
    final response = await _dio.get(
      ApiEndpoints.withId(ApiEndpoints.playlistById, id),
      options: await _userOptions(),
    );
    return PlaylistModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PlaylistModel> createPlaylist({
    required String name,
    String? description,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.playlists,
      data: {'name': name, 'description': description},
      options: await _userOptions(),
    );
    return PlaylistModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PlaylistModel> renamePlaylist({
    required String id,
    required String name,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.withId(ApiEndpoints.playlistById, id),
      data: {'name': name},
      options: await _userOptions(),
    );
    return PlaylistModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deletePlaylist(String id) async {
    await _dio.delete(
      ApiEndpoints.withId(ApiEndpoints.playlistById, id),
      options: await _userOptions(),
    );
  }

  Future<PlaylistModel> addTrackToPlaylist({
    required String playlistId,
    required String trackId,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.withId(ApiEndpoints.playlistTracks, playlistId),
      data: {'trackId': trackId},
      options: await _userOptions(),
    );
    return PlaylistModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PlaylistModel> removeTrackFromPlaylist({
    required String playlistId,
    required String trackId,
  }) async {
    final response = await _dio.delete(
      ApiEndpoints.withIds(ApiEndpoints.removeTrackFromPlaylist, playlistId, trackId),
      options: await _userOptions(),
    );
    return PlaylistModel.fromJson(response.data as Map<String, dynamic>);
  }
}
