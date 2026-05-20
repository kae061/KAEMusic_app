import 'package:flutter/foundation.dart';
import '../../data/datasources/track_remote_datasource.dart';
import '../../data/models/track_model.dart';

class MusicCatalogProvider extends ChangeNotifier {
  final TrackRemoteDataSource _dataSource;

  MusicCatalogProvider(this._dataSource);

  final List<Track> _tracks = [];
  bool _isLoading = false;
  int _currentPage = 0;
  bool _hasMore = true;

  List<Track> get tracks => _tracks;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<void> loadTracks({bool refresh = false}) async {
    if (_isLoading || (!_hasMore && !refresh)) return;

    if (refresh) {
      _currentPage = 0;
      _tracks.clear();
      _hasMore = true;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final newTracks = await _dataSource.fetchTracks(_currentPage, 20);
      if (newTracks.isEmpty) {
        _hasMore = false;
      } else {
        _tracks.addAll(newTracks);
        _currentPage++;
      }
    } catch (e) {
      debugPrint('Error loading tracks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    await loadTracks();
  }
}
