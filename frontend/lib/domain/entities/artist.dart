import 'package:equatable/equatable.dart';

class Artist extends Equatable {
  final String id;
  final String name;
  final String? bio;
  final String? imageUrl;
  final int monthlyListeners;
  final bool isFollowing;

  const Artist({
    required this.id,
    required this.name,
    this.bio,
    this.imageUrl,
    this.monthlyListeners = 0,
    this.isFollowing = false,
  });

  @override
  List<Object?> get props => [id, name, isFollowing];
}
