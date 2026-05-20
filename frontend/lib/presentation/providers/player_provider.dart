import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/track_model.dart';
import '../../domain/entities/song.dart';

enum RepeatMode { none, one, all }

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  List<Track> _queue = [];
  int _currentIndex = -1;
  bool _isPlaying = false;
  bool _isBuffering = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  RepeatMode _repeatMode = RepeatMode.none;
  bool _isShuffled = false;

  Track? get currentTrack => _currentIndex >= 0 && _currentIndex < _queue.length
      ? _queue[_currentIndex]
      : null;
  List<Track> get queue => List.unmodifiable(_queue);
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  bool get hasCurrentTrack => currentTrack != null;
  Duration get position => _position;
  Duration get duration => _duration;
  RepeatMode get repeatMode => _repeatMode;
  bool get isShuffled => _isShuffled;

  double get progress {
    if (_duration.inMilliseconds == 0) return 0;
    return (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
  }

  PlayerProvider() {
    _initListeners();
  }

  void _initListeners() {
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isBuffering = state.processingState == ProcessingState.buffering ||
          state.processingState == ProcessingState.loading;
      if (state.processingState == ProcessingState.completed) {
        _onTrackCompleted();
      }
      notifyListeners();
    });

    _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _player.durationStream.listen((dur) {
      if (dur != null) {
        _duration = dur;
        notifyListeners();
      }
    });
  }

  Future<void> setQueue(List<Track> tracks, int startIndex) async {
    _queue = List.from(tracks);
    _currentIndex = startIndex;
    await _playCurrent();
  }

  Future<void> playQueue(List<Track> tracks, {int startIndex = 0}) async {
    await setQueue(tracks, startIndex);
  }

  Future<void> play(Track track) async {
    final existing = _queue.indexWhere((s) => s.id == track.id);
    if (existing != -1) {
      _currentIndex = existing;
      await _playCurrent();
    } else {
      _queue = [track];
      _currentIndex = 0;
      await _playCurrent();
    }
  }

  Future<void> _playCurrent() async {
    final track = currentTrack;
    if (track == null) return;
    if (track.streamUrl.isEmpty) {
      debugPrint("Playback error: streamUrl is empty");
      return;
    }
    try {
      await _player.stop();
      await _player.setUrl(track.streamUrl);
      await _player.play();
    } catch (e) {
      debugPrint("Audio error: $e");
      await _player.stop();
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  Future<void> seekToProgress(double progress) async {
    final target = Duration(
      milliseconds: (progress * _duration.inMilliseconds).round(),
    );
    await seekTo(target);
  }

  Future<void> skipToNext() async {
    if (_queue.isEmpty) return;
    if (_repeatMode == RepeatMode.one) {
      await _player.seek(Duration.zero);
      await _player.play();
      return;
    }
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
    } else if (_repeatMode == RepeatMode.all) {
      _currentIndex = 0;
    } else {
      return;
    }
    await _playCurrent();
    notifyListeners();
  }

  Future<void> skipToPrevious() async {
    if (_position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    if (_currentIndex > 0) {
      _currentIndex--;
      await _playCurrent();
      notifyListeners();
    }
  }

  // legacy methods for compatibility
  
  Track _songToTrack(Song song) {
    return Track(
      id: song.id,
      title: song.title,
      artist: song.artistName,
      album: song.albumTitle,
      durationSeconds: song.duration.inSeconds,
      streamUrl: song.audioUrl,
      coverArtUrl: song.coverUrl,
    );
  }

  Song? get currentSong {
    final track = currentTrack;
    if (track == null) return null;
    return Song(
      id: track.id,
      title: track.title,
      artistId: '',
      artistName: track.artist,
      albumTitle: track.album,
      audioUrl: track.streamUrl,
      coverUrl: track.coverArtUrl,
      duration: Duration(seconds: track.durationSeconds ?? 0),
      releasedAt: DateTime.now(),
    );
  }

  Future<void> playSongQueue(List<Song> songs, {int startIndex = 0}) async {
    final tracks = songs.map(_songToTrack).toList();
    await setQueue(tracks, startIndex);
  }

  Future<void> skipNext() => skipToNext();
  Future<void> skipPrevious() => skipToPrevious();
  Future<void> playSong(Song song) async {
    await play(_songToTrack(song));
  }

  void toggleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.none:
        _repeatMode = RepeatMode.all;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
      case RepeatMode.one:
        _repeatMode = RepeatMode.none;
    }
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffled = !_isShuffled;
    if (_isShuffled) {
      final current = currentTrack;
      _queue.shuffle();
      if (current != null) {
        final newIdx = _queue.indexWhere((s) => s.id == current.id);
        if (newIdx != -1) _currentIndex = newIdx;
      }
    }
    notifyListeners();
  }

  void addToQueue(Track track) {
    if (!_queue.any((s) => s.id == track.id)) {
      _queue.add(track);
      notifyListeners();
    }
  }

  void _onTrackCompleted() {
    if (_repeatMode == RepeatMode.one) {
      _player.seek(Duration.zero);
      _player.play();
    } else {
      skipToNext();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
