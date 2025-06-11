import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';
import '../utils/token_storage.dart';

class ChirpWidget extends StatefulWidget {
  final Chirp chirp;
  final VoidCallback? onCommentPressed;
  final VoidCallback? onDelete; // callback untuk notify parent hapus berhasil

  const ChirpWidget({
    Key? key,
    required this.chirp,
    this.onCommentPressed,
    this.onDelete,
  }) : super(key: key);

  @override
  _ChirpWidgetState createState() => _ChirpWidgetState();
}

class _ChirpWidgetState extends State<ChirpWidget> {
  late Chirp chirp;
  List<Reply> replies = [];

  final TextEditingController _replyController = TextEditingController();
  bool _isSendingReply = false;

  @override
  void initState() {
    super.initState();
    chirp = widget.chirp;
  }

   void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengirim reply ke backend
  Future<void> sendReply() async {
    final replyText = _replyController.text.trim();
    if (replyText.isEmpty) return;

    setState(() {
      _isSendingReply = true;
    });

    final String? token = await TokenStorage.getToken();
    final url = Uri.parse('http://localhost:3000/api/posts/${chirp.id}/replies');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'content': replyText}),
      );

      if (response.statusCode == 201) {
        // Reset text field dan refresh replies
        _replyController.clear();
        await fetchRepliesByPost(chirp.id);
        setState(() {
          chirp = chirp.copyWith(replyCount: chirp.replyCount + 1);
        });
      } else {
        print('Failed to send reply: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending reply: $e');
    } finally {
      setState(() {
        _isSendingReply = false;
      });
    }
  }

Future<void> fetchRepliesByPost(int postId) async {
  final url = Uri.parse('http://localhost:3000/api/posts/$postId/replies');
  
  // Mengambil token dari penyimpanan
  final String? token = await TokenStorage.getToken();
  
  try {
    final response = await http.get(
      url,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        // header lain bisa ditambahkan jika perlu
      },
    );

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
        chirp = chirp.copyWith(likedByMe: true, likeCount: chirp.likeCount + 1);
      }
    });
  }


Future<void> deletePost() async {
  // print('Attempting to delete post id: ${chirp.id}');
  final String? token = await TokenStorage.getToken();
  // print('Token: $token');
  
  final url = Uri.parse('http://localhost:3000/api/posts/${chirp.id}');
  // print('Calling URL: $url');

  try {
    final response = await http.delete(
      url,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    // print('Response status code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      if (widget.onDelete != null) {
        widget.onDelete!();
      }
    } else {
      // print('Failed to delete post: ${response.statusCode}');
    }
  } catch (e) {
    // print('Error deleting post: $e');
  }
}


  @override
  // ... bagian import dan class tetap sama
  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'dd MMM yyyy, HH:mm',
    ).format(chirp.createdAt);

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
                  backgroundImage:
                      chirp.authorImage != null
                          ? NetworkImage(chirp.authorImage!)
                          : const AssetImage('assets/images/default_avatar.png')
                              as ImageProvider,
                ),
                const SizedBox(width: 8),
                // Expanded Row dengan space antara username dan date + menu agar date dan tombol menu di paling kanan
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chirp.authorUsername,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') {
                                deletePost();
                              }
                            },
                            itemBuilder:
                                (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Text('Delete Post'),
                                      ),
                                    ],
                          ),
                        ],
                      ),
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
                  icon: const Icon(Icons.comment, size: 20, color: Colors.grey),
                  onPressed: handleCommentPressed,
                  tooltip: 'Comment',
                ),
                Text('${chirp.replyCount}'),
              ],
            ),
             // TextField untuk menambahkan reply
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    enabled: !_isSendingReply,
                    decoration: InputDecoration(
                      hintText: 'Tulis balasan...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                ),
                const SizedBox(width: 8),
                _isSendingReply
                    ? const CircularProgressIndicator()
                    : IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: sendReply,
                        tooltip: 'Kirim balasan',
                      ),
              ],
            ),
            if (replies.isNotEmpty) ...[
              const Divider(),
              const Text(
                'Replies:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ...replies.map((reply) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            reply.authorImage != null
                                ? NetworkImage(reply.authorImage!)
                                : const AssetImage('assets/images/default_avatar.png')
                                    as ImageProvider,
                        radius: 12,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reply.authorUsername,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
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
