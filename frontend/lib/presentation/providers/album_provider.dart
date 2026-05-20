import 'package:flutter/foundation.dart';
import '../../data/repositories/album_repository_impl.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/album_repository.dart';

class AlbumProvider extends ChangeNotifier {
  final AlbumRepository _repository;

  AlbumProvider({AlbumRepository? repository})
      : _repository = repository ?? AlbumRepositoryImpl();

  List<Album> _albums = [];
  Album? _selectedAlbum;
  List<Song> _albumSongs = [];
  bool _isLoading = false;
  bool _isLoadingSongs = false;
  String? _error;

  List<Album> get albums => List.unmodifiable(_albums);
  Album? get selectedAlbum => _selectedAlbum;
  List<Song> get albumSongs => List.unmodifiable(_albumSongs);
  bool get isLoading => _isLoading;
  bool get isLoadingSongs => _isLoadingSongs;
  String? get error => _error;

  Future<void> loadAlbums({bool refresh = false}) async {
    if (_isLoading) return;
    if (!refresh && _albums.isNotEmpty) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _albums = await _repository.getAlbums();
    } catch (e) {
      _error = 'Failed to load albums.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAlbumDetail(String albumId) async {
    _isLoadingSongs = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.getAlbumById(albumId),
        _repository.getAlbumSongs(albumId),
      ]);
      _selectedAlbum = results[0] as Album;
      _albumSongs = results[1] as List<Song>;
    } catch (e) {
      _error = 'Failed to load album details.';
    }
    _isLoadingSongs = false;
    notifyListeners();
  }
}
