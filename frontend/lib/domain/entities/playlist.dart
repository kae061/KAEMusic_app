import 'package:equatable/equatable.dart';
import '../../data/models/track_model.dart';

class Playlist extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final String userId;
  final int trackCount;
  final List<Track>? tracks;
  final DateTime createdAt;

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    required this.userId,
    required this.trackCount,
    this.tracks,
    required this.createdAt,
  });

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? coverUrl,
    String? userId,
    int? trackCount,
    List<Track>? tracks,
    DateTime? createdAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      userId: userId ?? this.userId,
      trackCount: trackCount ?? this.trackCount,
      tracks: tracks ?? this.tracks,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, userId, trackCount, tracks, createdAt];
}
