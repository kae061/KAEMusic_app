class Track {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? genre;
  final int? durationSeconds;
  final String streamUrl;
  final String? coverArtUrl;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.genre,
    this.durationSeconds,
    required this.streamUrl,
    this.coverArtUrl,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      artist: json['artist'] ?? 'Unknown Artist',
      album: json['album'],
      genre: json['genre'],
      durationSeconds: json['durationSeconds'],
      streamUrl: json['streamUrl'] ?? '',
      coverArtUrl: json['coverArtUrl'],
    );
  }
}
