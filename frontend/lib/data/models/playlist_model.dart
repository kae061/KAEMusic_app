import '../../domain/entities/playlist.dart';
import 'track_model.dart';

class PlaylistModel extends Playlist {
  const PlaylistModel({
    required super.id,
    required super.name,
    super.description,
    super.coverUrl,
    required super.userId,
    required super.trackCount,
    super.tracks,
    required super.createdAt,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    final rawTracks = json['tracks'] as List<dynamic>?;
    final parsedTracks = rawTracks
        ?.map((t) => Track.fromJson(t as Map<String, dynamic>))
        .toList();

    final tCount = json['trackCount'] as int? ?? parsedTracks?.length ?? 0;

    return PlaylistModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverUrl: json['coverUrl'] as String?,
      userId: json['userId'] as String? ?? '',
      trackCount: tCount,
      tracks: parsedTracks,
      createdAt: _parseDateTime(json['createdAt']),
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
        'name': name,
        'description': description,
        'coverUrl': coverUrl,
        'userId': userId,
        'trackCount': trackCount,
        'createdAt': createdAt.toIso8601String(),
      };
}
