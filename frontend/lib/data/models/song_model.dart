import '../../domain/entities/song.dart';

class SongModel extends Song {
  const SongModel({
    required super.id,
    required super.title,
    required super.artistId,
    required super.artistName,
    super.albumId,
    super.albumTitle,
    super.coverUrl,
    required super.audioUrl,
    required super.duration,
    super.playCount,
    super.isLiked,
    required super.releasedAt,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    final artist = json['artist'];
    final album = json['album'];

    final artistId = json['artistId'] as String? ??
        (artist is Map<String, dynamic> ? artist['id'] as String? : null) ??
        '';
    final artistName = json['artistName'] as String? ??
        (artist is Map<String, dynamic> ? artist['name'] as String? : null) ??
        'Unknown Artist';

    final albumId = json['albumId'] as String? ??
        (album is Map<String, dynamic> ? album['id'] as String? : null);
    final albumTitle = json['albumTitle'] as String? ??
        (album is Map<String, dynamic> ? album['title'] as String? : null);

    final durationValue = json['durationSeconds'] ?? json['duration'];
    final durationSeconds = durationValue is num ? durationValue.toInt() : 0;

    return SongModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artistId: artistId,
      artistName: artistName,
      albumId: albumId,
      albumTitle: albumTitle,
      coverUrl: json['coverUrl'] as String?,
      audioUrl: json['audioUrl'] as String? ?? '',
      duration: Duration(seconds: durationSeconds),
      playCount: (json['playCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? true,
      releasedAt: _parseDateTime(json['releasedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.parse(value);
    if (value is List && value.length >= 3) {
      return DateTime(
        (value[0] as num).toInt(),
        (value[1] as num).toInt(),
        (value[2] as num).toInt(),
      );
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artistId': artistId,
        'artistName': artistName,
        'albumId': albumId,
        'albumTitle': albumTitle,
        'coverUrl': coverUrl,
        'audioUrl': audioUrl,
        'durationSeconds': duration.inSeconds,
        'playCount': playCount,
        'isLiked': isLiked,
        'releasedAt': releasedAt.toIso8601String(),
      };
}
