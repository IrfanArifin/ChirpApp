import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Import TokenStorage untuk mengambil token login
import '../utils/token_storage.dart';

// Import halaman ProfileTab (pastikan sudah ada file profile_tab.dart dan kelas ProfileTab)
import 'profile_tab.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({Key? key}) : super(key: key);

  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? userData;
  bool isLoading = false;
  String? error;

  Future<void> _searchUser() async {
    final username = _searchController.text.trim();
    if (username.isEmpty) {
      setState(() {
        error = "Please enter a username to search";
        userData = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
      userData = null;
    });

    try {
      // Ambil token login dari TokenStorage
      final token = await TokenStorage.getToken();
      if (token == null) {
        setState(() {
          error = 'You must be logged in to search users.';
          isLoading = false;
        });
        return;
      }

      // Panggil API pencarian user berdasarkan username
      final uri = Uri.parse(
          'http://localhost:3000/api/users/search?username=$username');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        // Asumsi response: { "user": { "id":..., "username":..., "fullName":..., "image":... } }
        if (jsonBody['user'] != null) {
          setState(() {
            userData = jsonBody['user'];
            error = null;
          });
        } else {
          setState(() {
            userData = null;
            error = 'User not found.';
          });
        }
      } else {
        setState(() {
          error = 'Failed to fetch user. Status code: ${response.statusCode}';
          userData = null;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error occurred: $e';
        userData = null;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildUserCard() {
    if (userData == null) {
      return SizedBox.shrink();
    }
    return Card(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      elevation: 3,
      child: InkWell(
        onTap: () {
          if (userData!['id'] != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileTab(userId: userData!['id']),
              ),
            );
          }
        },
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: userData!['image'] != null &&
                    userData!['image'].toString().isNotEmpty
                ? NetworkImage(userData!['image'])
                : AssetImage('assets/images/default_avatar.png')
                    as ImageProvider,
          ),
          title: Text(userData!['username'] ?? 'No username'),
          subtitle: Text(userData!['fullName'] ?? ''),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'cari pengguna',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: isLoading ? null : _searchUser,
                ),
              ),
              onSubmitted: (_) => isLoading ? null : _searchUser(),
            ),
            if (isLoading)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  error!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            if (userData != null) _buildUserCard(),
          ],
        ),
      ),
    );
  }
}

