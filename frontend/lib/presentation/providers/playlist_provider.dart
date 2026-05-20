import 'package:flutter/foundation.dart';
import '../../data/datasources/playlist_remote_datasource.dart';
import '../../domain/entities/playlist.dart';

class PlaylistProvider extends ChangeNotifier {
  final PlaylistRemoteDataSource _dataSource = PlaylistRemoteDataSource();

  List<Playlist> _playlists = [];
  Playlist? _selectedPlaylist;
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  List<Playlist> get playlists => List.unmodifiable(_playlists);
  Playlist? get selectedPlaylist => _selectedPlaylist;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  Future<void> loadPlaylists() async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      _playlists = await _dataSource.getMyPlaylists();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> loadPlaylistDetail(String id) async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      _selectedPlaylist = await _dataSource.getPlaylistById(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> createPlaylist(String name, String? desc) async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      final newPlaylist = await _dataSource.createPlaylist(name: name, description: desc);
      _playlists = [newPlaylist, ..._playlists];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> renamePlaylist(String id, String name) async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      final updated = await _dataSource.renamePlaylist(id: id, name: name);
      final index = _playlists.indexWhere((p) => p.id == id);
      if (index != -1) {
        _playlists[index] = updated;
      }
      if (_selectedPlaylist?.id == id) {
        _selectedPlaylist = updated;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> deletePlaylist(String id) async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      await _dataSource.deletePlaylist(id);
      _playlists.removeWhere((p) => p.id == id);
      if (_selectedPlaylist?.id == id) {
        _selectedPlaylist = null;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> addTrack(String playlistId, String trackId) async {
    _error = null;
    try {
      final updated = await _dataSource.addTrackToPlaylist(playlistId: playlistId, trackId: trackId);
      final index = _playlists.indexWhere((p) => p.id == playlistId);
      if (index != -1) {
        _playlists[index] = updated;
      }
      if (_selectedPlaylist?.id == playlistId) {
        _selectedPlaylist = updated;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _safeNotifyListeners();
    }
  }

  Future<void> removeTrack(String playlistId, String trackId) async {
    _error = null;
    try {
      final updated = await _dataSource.removeTrackFromPlaylist(playlistId: playlistId, trackId: trackId);
      final index = _playlists.indexWhere((p) => p.id == playlistId);
      if (index != -1) {
        _playlists[index] = updated;
      }
      if (_selectedPlaylist?.id == playlistId) {
        _selectedPlaylist = updated;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _safeNotifyListeners();
    }
  }
}