// lib/models/chirp_model.dart
class Chirp {
  final int id;
  final String content;
  final String? image; 
  final DateTime createdAt;
  final DateTime updatedAt;
  final int authorId;
  final String authorUsername;
  final String? authorImage; 
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

  Chirp copyWith({
    int? id,
    String? content,
    String? image,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? authorId,
    String? authorUsername,
    String? authorImage,
    int? likeCount,
    int? replyCount,
    bool? likedByMe,
  }) {
    return Chirp(
      id: id ?? this.id,
      content: content ?? this.content,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorId: authorId ?? this.authorId,
      authorUsername: authorUsername ?? this.authorUsername,
      authorImage: authorImage ?? this.authorImage,
      likeCount: likeCount ?? this.likeCount,
      replyCount: replyCount ?? this.replyCount,
      likedByMe: likedByMe ?? this.likedByMe,
    );
  }
}

class Reply {
  final int id;
  final String content;
  final int postId;
  final int authorId;
  final String authorUsername;
  final String? authorImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reply({
    required this.id,
    required this.content,
    required this.postId,
    required this.authorId,
    required this.authorUsername,
    this.authorImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['id'],
      content: json['content'],
      postId: json['postId'],
      authorId: json['authorId'],
      authorUsername: json['author_username'],
      authorImage: json['author_image'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

