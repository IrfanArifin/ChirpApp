import 'package:flutter/material.dart';
import '../models/post_model.dart';
import 'package:intl/intl.dart';

class ChirpWidget extends StatelessWidget {
  final Chirp chirp;

  const ChirpWidget({required this.chirp, Key? key}) : super(key: key);

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
            // Header dengan username dan tanggal
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: chirp.authorImage != null
                      ? NetworkImage(chirp.authorImage!)
                      : AssetImage('assets/default_avatar.png') as ImageProvider,
                  radius: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  chirp.authorUsername,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Spacer(),
                Text(
                  formattedDate,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Konten teks
            Text(
              chirp.content,
              style: TextStyle(fontSize: 15),
            ),

            // Image jika ada
            if (chirp.image != null) ...[
              const SizedBox(height: 8),
              Image.network(chirp.image!),
            ],

            const SizedBox(height: 10),

            // Footer dengan like & reply count
            Row(
              children: [
                Icon(
                  chirp.likedByMe ? Icons.favorite : Icons.favorite_border,
                  color: chirp.likedByMe ? Colors.red : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text('${chirp.likeCount}'),
                const SizedBox(width: 16),
                Icon(
                  Icons.comment,
                  size: 20,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text('${chirp.replyCount}'),
              ],
            )
          ],
        ),
      ),
    );
  }
}
