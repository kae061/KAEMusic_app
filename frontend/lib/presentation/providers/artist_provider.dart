import 'package:flutter/foundation.dart';
import '../../data/repositories/artist_repository_impl.dart';
import '../../domain/entities/artist.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/artist_repository.dart';

class ArtistProvider extends ChangeNotifier {
  final ArtistRepository _repository;

  ArtistProvider({ArtistRepository? repository})
      : _repository = repository ?? ArtistRepositoryImpl();

  List<Artist> _artists = [];
  Artist? _selectedArtist;
  List<Album> _artistAlbums = [];
  List<Song> _artistSongs = [];
  bool _isLoading = false;
  bool _isLoadingDetail = false;
  String? _error;

  List<Artist> get artists => List.unmodifiable(_artists);
  Artist? get selectedArtist => _selectedArtist;
  List<Album> get artistAlbums => List.unmodifiable(_artistAlbums);
  List<Song> get artistSongs => List.unmodifiable(_artistSongs);
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get error => _error;

  Future<void> loadArtists({bool refresh = false}) async {
    if (_isLoading) return;
    if (!refresh && _artists.isNotEmpty) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _artists = await _repository.getArtists();
    } catch (e) {
      _error = 'Failed to load artists.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadArtistDetail(String artistId) async {
    _isLoadingDetail = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.getArtistById(artistId),
        _repository.getArtistAlbums(artistId),
        _repository.getArtistSongs(artistId),
      ]);
      _selectedArtist = results[0] as Artist;
      _artistAlbums = results[1] as List<Album>;
      _artistSongs = results[2] as List<Song>;
    } catch (e) {
      _error = 'Failed to load artist details.';
    }
    _isLoadingDetail = false;
    notifyListeners();
  }
}
