// lib/models/chirp_model.dart
class Chirp {
  final int id;
  final String content;
  final String? image; // nullable
  final DateTime createdAt;
  final DateTime updatedAt;
  final int authorId;
  final String authorUsername;
  final String? authorImage; // nullable
  final int likeCount;
  final int replyCount;
  final bool likedByMe;

  Chirp({
    required this.id,
    required this.content,
    this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.authorId,
    required this.authorUsername,
    this.authorImage,
    required this.likeCount,
    required this.replyCount,
    required this.likedByMe,
  });

  factory Chirp.fromJson(Map<String, dynamic> json) {
    return Chirp(
      id: json['id'],
      content: json['content'],
      image: json['image'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      authorId: json['authorId'],
      authorUsername: json['author_username'],
      authorImage: json['author_image'],
      likeCount: int.tryParse(json['like_count'].toString()) ?? 0,
      replyCount: int.tryParse(json['reply_count'].toString()) ?? 0,
      likedByMe: json['liked_by_me'] ?? false,
    );
  }
}
