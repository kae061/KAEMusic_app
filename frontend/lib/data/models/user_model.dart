import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.avatarUrl,
    super.displayName,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      displayName: json['displayName'] as String?,
      createdAt: _parseCreatedAt(json['createdAt']),
    );
  }

  static DateTime _parseCreatedAt(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.parse(value);
    if (value is List && value.length >= 3) {
      final year = (value[0] as num).toInt();
      final month = (value[1] as num).toInt();
      final day = (value[2] as num).toInt();
      final hour = value.length > 3 ? (value[3] as num).toInt() : 0;
      final minute = value.length > 4 ? (value[4] as num).toInt() : 0;
      final second = value.length > 5 ? (value[5] as num).toInt() : 0;
      return DateTime(year, month, day, hour, minute, second);
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'avatarUrl': avatarUrl,
        'displayName': displayName,
        'createdAt': createdAt.toIso8601String(),
      };
}
