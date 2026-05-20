import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String? displayName;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.displayName,
    required this.createdAt,
  });

  String get name => displayName ?? username;

  @override
  List<Object?> get props => [id, username, email, avatarUrl, displayName, createdAt];
}
