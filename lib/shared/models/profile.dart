// lib/shared/models/profile.dart

class Profile {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final bool isCreator;
  final bool creatorVerified;
  final int reputationScore;
  final int totalDaresPosted;
  final int totalDaresCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    required this.isCreator,
    required this.creatorVerified,
    required this.reputationScore,
    required this.totalDaresPosted,
    required this.totalDaresCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        username: json['username'] as String,
        displayName: json['display_name'] as String,
        avatarUrl: json['avatar_url'] as String?,
        bio: json['bio'] as String?,
        isCreator: json['is_creator'] as bool? ?? false,
        creatorVerified: json['creator_verified'] as bool? ?? false,
        reputationScore: json['reputation_score'] as int? ?? 0,
        totalDaresPosted: json['total_dares_posted'] as int? ?? 0,
        totalDaresCompleted: json['total_dares_completed'] as int? ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'bio': bio,
        'is_creator': isCreator,
        'creator_verified': creatorVerified,
        'reputation_score': reputationScore,
        'total_dares_posted': totalDaresPosted,
        'total_dares_completed': totalDaresCompleted,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Profile copyWith({
    String? username,
    String? displayName,
    String? avatarUrl,
    String? bio,
    bool? isCreator,
    bool? creatorVerified,
    int? reputationScore,
    int? totalDaresPosted,
    int? totalDaresCompleted,
  }) =>
      Profile(
        id: id,
        username: username ?? this.username,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        bio: bio ?? this.bio,
        isCreator: isCreator ?? this.isCreator,
        creatorVerified: creatorVerified ?? this.creatorVerified,
        reputationScore: reputationScore ?? this.reputationScore,
        totalDaresPosted: totalDaresPosted ?? this.totalDaresPosted,
        totalDaresCompleted: totalDaresCompleted ?? this.totalDaresCompleted,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

  @override
  String toString() => 'Profile($username)';
}
