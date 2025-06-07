class UserProfile {
  final int id;
  final String username;
  final String? email;
  final String fullName;
  final String? bio;
  final String? image;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.bio,
    this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['fullName'],
      bio: json['bio'],
      image: json['image'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class UserProfileResponse {
  final UserProfile user;
  final int followerCount;
  final int followingCount;
  final bool isFollowing;

  UserProfileResponse({
    required this.user,
    required this.followerCount,
    required this.followingCount,
    required this.isFollowing,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      user: UserProfile.fromJson(json['user']),
      followerCount: json['followerCount'],
      followingCount: json['followingCount'],
      isFollowing: json['isFollowing'],
    );
  }
}
