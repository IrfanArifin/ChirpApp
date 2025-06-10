import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';

class ChirpWidget extends StatefulWidget {
  final Chirp chirp;
  final VoidCallback? onCommentPressed;

  const ChirpWidget({
    Key? key,
    required this.chirp,
    this.onCommentPressed,
  }) : super(key: key);

  @override
  _ChirpWidgetState createState() => _ChirpWidgetState();
}

class _ChirpWidgetState extends State<ChirpWidget> {
  late Chirp chirp;
  List<Reply> replies = [];

  @override
  void initState() {
    super.initState();
    chirp = widget.chirp;
  }

  Future<void> fetchRepliesByPost(int postId) async {
    final url = Uri.parse('http://localhost:3000/api/posts/$postId/replies');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> parsed = json.decode(response.body);
        setState(() {
          replies = parsed.map((json) => Reply.fromJson(json)).toList();
        });
      } else {
        print('Failed to load replies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching replies: $e');
    }
  }

  void handleCommentPressed() async {
    await fetchRepliesByPost(chirp.id);
    if (widget.onCommentPressed != null) {
      widget.onCommentPressed!();
    }
  }

  void handleLikeToggle() {
    setState(() {
      if (chirp.likedByMe) {
        chirp = chirp.copyWith(
          likedByMe: false,
          likeCount: (chirp.likeCount > 0) ? chirp.likeCount - 1 : 0,
        );
      } else {
        chirp = chirp.copyWith(
          likedByMe: true,
          likeCount: chirp.likeCount + 1,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(chirp.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header, author info, and post content
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: chirp.authorImage != null
                      ? NetworkImage(chirp.authorImage!)
                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
                const SizedBox(width: 8),
                // Expanded Row dengan space antara username dan date agar date di paling kanan
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chirp.authorUsername,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(formattedDate, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(chirp.content),
            if (chirp.image != null) ...[
              const SizedBox(height: 8),
              Image.network(chirp.image!),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    chirp.likedByMe ? Icons.favorite : Icons.favorite_border,
                    color: chirp.likedByMe ? Colors.red : Colors.grey,
                    size: 20,
                  ),
                  onPressed: handleLikeToggle,
                  tooltip: 'Like',
                ),
                Text('${chirp.likeCount}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(
                    Icons.comment,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: handleCommentPressed,
                  tooltip: 'Comment',
                ),
                Text('${chirp.replyCount}'),
              ],
            ),
            if (replies.isNotEmpty) ...[
              const Divider(),
              const Text('Replies:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...replies.map((reply) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: reply.authorImage != null
                            ? NetworkImage(reply.authorImage!)
                            : const AssetImage('assets/default_avatar.png') as ImageProvider,
                        radius: 12,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reply.authorUsername,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(reply.content),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}
