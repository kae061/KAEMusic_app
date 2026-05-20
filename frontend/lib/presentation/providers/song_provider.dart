import 'package:flutter/foundation.dart';
import '../../domain/entities/song.dart';

enum SongLoadState { initial, loading, loaded, error }

class SongProvider extends ChangeNotifier {
  SongProvider() {
    _initializeMockSongs();
  }

  SongLoadState _state = SongLoadState.initial;
  List<Song> _songs = [];
  List<Song> _searchResults = [];
  List<Song> _likedSongs = [];
  String? _errorMessage;
  bool _isSearching = false;

  SongLoadState get state => _state;
  List<Song> get songs => List.unmodifiable(_songs);
  List<Song> get searchResults => List.unmodifiable(_searchResults);
  List<Song> get likedSongs => List.unmodifiable(_likedSongs);
  String? get errorMessage => _errorMessage;
  bool get isSearching => _isSearching;
  bool get isLoading => _state == SongLoadState.loading;

  void _initializeMockSongs() {
    _songs = [
      Song(
        id: '1',
        title: 'Blinding Lights',
        artistId: 'a1',
        artistName: 'The Weeknd',
        albumId: 'al1',
        albumTitle: 'After Hours',
        coverUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/c/c1/The_Weeknd_-_After_Hours.png/220px-The_Weeknd_-_After_Hours.png',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        duration: const Duration(minutes: 3, seconds: 20),
        playCount: 3200000,
        isLiked: true,
        releasedAt: DateTime(2019, 11, 29),
      ),
      Song(
        id: '2',
        title: 'Stay',
        artistId: 'a2',
        artistName: 'The Kid LAROI & Justin Bieber',
        albumId: 'al2',
        albumTitle: 'F*CK LOVE 3',
        coverUrl: 'https://upload.wikimedia.org/wikipedia/en/7/7d/The_Kid_LAROI_-_Stay_%28with_Justin_Bieber%29.png',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        duration: const Duration(minutes: 2, seconds: 21),
        playCount: 4100000,
        isLiked: false,
        releasedAt: DateTime(2021, 7, 9),
      ),
      Song(
        id: '3',
        title: 'Heat Waves',
        artistId: 'a3',
        artistName: 'Glass Animals',
        albumId: 'al3',
        albumTitle: 'Dreamland',
        coverUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/c/c0/Glass_Animals_-_Heat_Waves_%28Official_Single_Cover%29.png/220px-Glass_Animals_-_Heat_Waves_%28Official_Single_Cover%29.png',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        duration: const Duration(minutes: 3, seconds: 59),
        playCount: 2800000,
        isLiked: false,
        releasedAt: DateTime(2020, 6, 29),
      ),
      Song(
        id: '4',
        title: 'Levitating',
        artistId: 'a4',
        artistName: 'Dua Lipa',
        albumId: 'al4',
        albumTitle: 'Future Nostalgia',
        coverUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/4/45/DuaLipaFutureNostalgiaalbumcover.png/220px-DuaLipaFutureNostalgiaalbumcover.png',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
        duration: const Duration(minutes: 3, seconds: 23),
        playCount: 3500000,
        isLiked: false,
        releasedAt: DateTime(2020, 10, 1),
      ),
      Song(
        id: '5',
        title: 'Montero (Call Me By Your Name)',
        artistId: 'a5',
        artistName: 'Lil Nas X',
        albumId: 'al5',
        albumTitle: 'Montero',
        coverUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/0/07/Lil_Nas_X_-_Montero_%28Call_Me_by_Your_Name%29.png/220px-Lil_Nas_X_-_Montero_%28Call_Me_by_Your_Name%29.png',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
        duration: const Duration(minutes: 2, seconds: 17),
        playCount: 1900000,
        isLiked: false,
        releasedAt: DateTime(2021, 3, 26),
      ),
    ];

    _likedSongs = _songs.where((s) => s.isLiked).toList();
    _state = SongLoadState.loaded;
  }

  Future<void> loadSongs({bool refresh = false}) async {
    if (!refresh && _songs.isNotEmpty) return;
    _state = SongLoadState.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 100));
    _initializeMockSongs();
    notifyListeners();
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }
    _isSearching = true;
    notifyListeners();

    _searchResults = _songs
        .where((song) =>
            song.title.toLowerCase().contains(query.toLowerCase()) ||
            song.artistName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    _isSearching = false;
    notifyListeners();
  }

  Future<void> loadLikedSongs() async {
    notifyListeners();
  }

  Future<void> toggleLike(Song song) async {
    final idx = _songs.indexWhere((s) => s.id == song.id);
    if (idx != -1) {
      final updatedSong = _songs[idx].copyWith(isLiked: !_songs[idx].isLiked);
      _songs[idx] = updatedSong;

      if (updatedSong.isLiked) {
        if (!_likedSongs.any((s) => s.id == updatedSong.id)) {
          _likedSongs.add(updatedSong);
        }
      } else {
        _likedSongs.removeWhere((s) => s.id == updatedSong.id);
      }

      final searchIdx = _searchResults.indexWhere((s) => s.id == song.id);
      if (searchIdx != -1) {
        _searchResults[searchIdx] = updatedSong;
      }

      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}