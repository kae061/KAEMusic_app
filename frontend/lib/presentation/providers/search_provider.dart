import 'package:flutter/foundation.dart';
import '../../data/datasources/track_remote_datasource.dart';
import '../../data/datasources/mock_data.dart';
import '../../data/models/track_model.dart';

class SearchProvider extends ChangeNotifier {
  final TrackRemoteDataSource _dataSource;

  SearchProvider(this._dataSource);

  String _query = '';
  List<Track> _results = [];
  bool _isSearching = false;
  final List<String> _recentSearches = [];

  String get query => _query;
  List<Track> get results => _results;
  bool get isSearching => _isSearching;
  List<String> get recentSearches => List.unmodifiable(_recentSearches);

  Future<void> performSearch(String query) async {
    final normalizedQuery = query.trim();
    _query = normalizedQuery;
    if (normalizedQuery.isEmpty) {
      clearSearch();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      _results = await _dataSource.searchTracks(normalizedQuery);
    } catch (e) {
      debugPrint('Error searching tracks: $e');
      _results = _searchLocalTracks(normalizedQuery);
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void saveRecentSearch(String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return;

    _recentSearches.removeWhere(
      (item) => item.toLowerCase() == normalizedQuery.toLowerCase(),
    );
    _recentSearches.insert(0, normalizedQuery);

    if (_recentSearches.length > 8) {
      _recentSearches.removeRange(8, _recentSearches.length);
    }

    notifyListeners();
  }

  void removeRecentSearch(String query) {
    _recentSearches.removeWhere(
      (item) => item.toLowerCase() == query.trim().toLowerCase(),
    );
    notifyListeners();
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  void clearSearch() {
    _query = '';
    _results = [];
    _isSearching = false;
    notifyListeners();
  }

  List<Track> _searchLocalTracks(String query) {
    final normalizedQuery = query.toLowerCase();

    return MockData.mockTracks.where((track) {
      final searchable = [
        track.title,
        track.artist,
        track.album,
        track.genre,
      ].whereType<String>().join(' ').toLowerCase();

      return searchable.contains(normalizedQuery);
    }).toList();
  }
}
