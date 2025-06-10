import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/token_storage.dart'; // Import kelas TokenStorage Anda

class PostLikeButton extends StatefulWidget {
  final int postId;
  final bool initiallyLiked;

  PostLikeButton({required this.postId, this.initiallyLiked = false});

  @override
  _PostLikeButtonState createState() => _PostLikeButtonState();
}

class _PostLikeButtonState extends State<PostLikeButton> {
  late bool isLiked;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.initiallyLiked;
  }

  Future<void> toggleLike() async {
    setState(() {
      isLoading = true;
    });

    final token = await TokenStorage.getToken();

    if (token == null) {
      print('Token not found. User might not be authenticated.');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final url = isLiked
        ? 'http://localhost:3000/api/posts/${widget.postId}/unlike'
        : 'http://localhost:3000/api/posts/${widget.postId}/like';

    try {
      final response = await http.post(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          isLiked = !isLiked;
        });
      } else {
        print('API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error on like/unlike: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.favorite,
        color: isLiked ? Colors.red : Colors.grey,
      ),
      onPressed: isLoading ? null : toggleLike,
    );
  }
}
