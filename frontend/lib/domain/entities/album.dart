import 'package:equatable/equatable.dart';

class Album extends Equatable {
  final String id;
  final String title;
  final String artistId;
  final String artistName;
  final String? coverUrl;
  final int totalTracks;
  final DateTime releasedAt;

  const Album({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    this.coverUrl,
    this.totalTracks = 0,
    required this.releasedAt,
  });

  @override
  List<Object?> get props => [id, title, artistId];
}
