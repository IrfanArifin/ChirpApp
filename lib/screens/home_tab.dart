import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/token_storage.dart';
import '../models/post_model.dart';
import '../widgets/post_widget.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<Chirp> posts = [];
  bool isLoading = true;
  

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      final token = await TokenStorage.getToken();

      if (token == null) {
        print('Token tidak ditemukan');
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:3000/api/posts'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          posts = data.map((json) => Chirp.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        print('Gagal mengambil postingan: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error mengambil data: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (posts.isEmpty) {
      return Center(child: Text('Tidak ada chirp'));
    }

    return ListView.separated(
      itemCount: posts.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        final post = posts[index];
        return ChirpWidget(
          chirp: post,
          onDelete: () {
  print('Menghapus post dengan id: ${post.id}');
  setState(() {
    posts.removeWhere((p) => p.id == post.id);
  });
},

        );
      },
    );
  }
}
