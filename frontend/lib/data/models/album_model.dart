import '../../domain/entities/album.dart';

class AlbumModel extends Album {
  const AlbumModel({
    required super.id,
    required super.title,
    required super.artistId,
    required super.artistName,
    super.coverUrl,
    super.totalTracks,
    required super.releasedAt,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artistId: json['artistId'] as String,
      artistName: json['artistName'] as String,
      coverUrl: json['coverUrl'] as String?,
      totalTracks: (json['totalTracks'] as num?)?.toInt() ?? 0,
      releasedAt: DateTime.parse(json['releasedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artistId': artistId,
        'artistName': artistName,
        'coverUrl': coverUrl,
        'totalTracks': totalTracks,
        'releasedAt': releasedAt.toIso8601String(),
      };
}
