import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/token_manager.dart';
import '../../data/models/track_model.dart';

class FavoritesProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  List<Track> _favoritesTracks = [];
  final Set<String> _favoritedTrackIds = {};
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  List<Track> get favoritesTracks => List.unmodifiable(_favoritesTracks);
  Set<String> get favoritedTrackIds => _favoritedTrackIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<String?> _getUserId() async {
    return TokenManager.getValue(AppConstants.userIdKey);
  }

  Options _userOptions(String userId) => Options(headers: {'X-User-Id': userId});

  Future<void> loadFavorites() async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final userId = await _getUserId();
      if (userId == null || userId.isEmpty) {
        _errorMessage = 'User not logged in';
        return;
      }

      final response = await _dioClient.dio.get(
        AppConstants.favoritesEndpoint,
        options: _userOptions(userId),
      );

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        _favoritesTracks = data
            .map((json) => Track.fromJson(json as Map<String, dynamic>))
            .toList();
        _favoritedTrackIds
          ..clear()
          ..addAll(_favoritesTracks.map((t) => t.id));
      } else {
        _errorMessage = 'Failed to load favorites';
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] as String? ??
          'Failed to load favorites';
      debugPrint('loadFavorites failed: ${e.response?.statusCode} ${e.response?.data}');
    } catch (e) {
      _errorMessage = 'Failed to load favorites';
      debugPrint('loadFavorites failed: $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  bool isFavorited(String trackId) => _favoritedTrackIds.contains(trackId);

  Future<void> toggleFavorite(String trackId, {Track? trackPlaceholder}) async {
    final wasFavorite = _favoritedTrackIds.contains(trackId);

    // Optimistic Update
    Track? removedTrack;
    if (wasFavorite) {
      _favoritedTrackIds.remove(trackId);
      final idx = _favoritesTracks.indexWhere((t) => t.id == trackId);
      if (idx != -1) {
        removedTrack = _favoritesTracks.removeAt(idx);
      }
    } else {
      _favoritedTrackIds.add(trackId);
      if (trackPlaceholder != null) {
        _favoritesTracks.add(trackPlaceholder);
      }
    }
    _safeNotifyListeners();

    try {
      final userId = await _getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User not logged in');
      }

      debugPrint('toggleFavorite: userId=$userId, trackId=$trackId');
      
      final response = await _dioClient.dio.post(
        '${AppConstants.favoritesEndpoint}/$trackId',
        options: _userOptions(userId),
      );

      debugPrint('toggleFavorite response: ${response.statusCode} ${response.data}');

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data as Map<String, dynamic>;
      final favorited = data['favorited'] as bool? ?? !wasFavorite;
      
      if (favorited) {
        _favoritedTrackIds.add(trackId);
        // If we added a placeholder, keep it. Otherwise, reload favorites might be safer, but this is fine.
      } else {
        _favoritedTrackIds.remove(trackId);
        _favoritesTracks.removeWhere((t) => t.id == trackId);
      }
      _errorMessage = null;
    } on DioException catch (e) {
      // Revert Optimistic Update
      if (wasFavorite) {
        _favoritedTrackIds.add(trackId);
        if (removedTrack != null) {
          _favoritesTracks.add(removedTrack);
        }
      } else {
        _favoritedTrackIds.remove(trackId);
        _favoritesTracks.removeWhere((t) => t.id == trackId);
      }
      _errorMessage = e.response?.data?['message'] as String? ??
          'Failed to toggle favorite';
      debugPrint('toggleFavorite failed: ${e.response?.statusCode} ${e.response?.data}');
    } catch (e) {
      // Revert Optimistic Update
      if (wasFavorite) {
        _favoritedTrackIds.add(trackId);
        if (removedTrack != null) {
          _favoritesTracks.add(removedTrack);
        }
      } else {
        _favoritedTrackIds.remove(trackId);
        _favoritesTracks.removeWhere((t) => t.id == trackId);
      }
      _errorMessage = 'Failed to toggle favorite';
      debugPrint('toggleFavorite failed: $e');
    } finally {
      _safeNotifyListeners();
    }
  }
}
