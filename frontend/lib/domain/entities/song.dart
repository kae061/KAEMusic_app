import 'package:equatable/equatable.dart';

class Song extends Equatable {
  final String id;
  final String title;
  final String artistId;
  final String artistName;
  final String? albumId;
  final String? albumTitle;
  final String? coverUrl;
  final String audioUrl;
  final Duration duration;
  final int playCount;
  final bool isLiked;
  final DateTime releasedAt;

  const Song({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    this.albumId,
    this.albumTitle,
    this.coverUrl,
    required this.audioUrl,
    required this.duration,
    this.playCount = 0,
    this.isLiked = false,
    required this.releasedAt,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artistId,
    String? artistName,
    String? albumId,
    String? albumTitle,
    String? coverUrl,
    String? audioUrl,
    Duration? duration,
    int? playCount,
    bool? isLiked,
    DateTime? releasedAt,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artistId: artistId ?? this.artistId,
      artistName: artistName ?? this.artistName,
      albumId: albumId ?? this.albumId,
      albumTitle: albumTitle ?? this.albumTitle,
      coverUrl: coverUrl ?? this.coverUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      playCount: playCount ?? this.playCount,
      isLiked: isLiked ?? this.isLiked,
      releasedAt: releasedAt ?? this.releasedAt,
    );
  }

  String get durationFormatted {
    final m = duration.inMinutes;
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  List<Object?> get props => [id, title, artistId, isLiked];
}
