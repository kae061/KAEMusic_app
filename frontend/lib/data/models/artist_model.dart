import '../../domain/entities/artist.dart';

class ArtistModel extends Artist {
  const ArtistModel({
    required super.id,
    required super.name,
    super.bio,
    super.imageUrl,
    super.monthlyListeners,
    super.isFollowing,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      id: json['id'] as String,
      name: json['name'] as String,
      bio: json['bio'] as String?,
      imageUrl: json['imageUrl'] as String?,
      monthlyListeners: (json['monthlyListeners'] as num?)?.toInt() ?? 0,
      isFollowing: json['isFollowing'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bio': bio,
        'imageUrl': imageUrl,
        'monthlyListeners': monthlyListeners,
        'isFollowing': isFollowing,
      };
}
