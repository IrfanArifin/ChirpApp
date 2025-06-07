import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/profile_model.dart';
import '../models/post_model.dart';
import '../widgets/post_widget.dart';
import '../utils/token_storage.dart';

class ProfileTab extends StatefulWidget {
  final int userId; // User ID yang sedang login

  const ProfileTab({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late Future<UserProfileResponse> futureProfile;
  late Future<List<Chirp>> futureUserPosts;

  @override
  void initState() {
    super.initState();
    futureProfile = fetchUserProfile(widget.userId);
    futureUserPosts = fetchUserPosts(widget.userId);
  }

  Future<UserProfileResponse> fetchUserProfile(int userId) async {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse('http://localhost:3000/api/users/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return UserProfileResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to load profile: Status code ${response.statusCode}, Body: ${response.body}',
      );
    }
  }

  Future<List<Chirp>> fetchUserPosts(int userId) async {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse('http://localhost:3000/api/users/$userId/posts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Chirp.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load user posts: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfileResponse>(
      future: futureProfile,
      builder: (context, profileSnapshot) {
        if (profileSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (profileSnapshot.hasError) {
          return Center(child: Text('Error loading profile: ${profileSnapshot.error}'));
        } else if (!profileSnapshot.hasData) {
          return const Center(child: Text('No profile data found'));
        } else {
          final profile = profileSnapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profile.user.image != null
                      ? NetworkImage(profile.user.image!)
                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
                const SizedBox(height: 16),
                Text(
                  profile.user.username,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  profile.user.fullName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  profile.user.bio ?? "Bio belum diisi",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          profile.followerCount.toString(),
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const Text('Followers'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          profile.followingCount.toString(),
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const Text('Following'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Bagian menampilkan postingan user
                FutureBuilder<List<Chirp>>(
                  future: futureUserPosts,
                  builder: (context, postsSnapshot) {
                    if (postsSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (postsSnapshot.hasError) {
                      return Center(child: Text('Error loading posts: ${postsSnapshot.error}'));
                    } else if (!postsSnapshot.hasData || postsSnapshot.data!.isEmpty) {
                      return const Center(child: Text('No posts found.'));
                    } else {
                      final posts = postsSnapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return ChirpWidget(chirp: posts[index]);
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
