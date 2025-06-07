import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/token_storage.dart'; // Pastikan path ini benar sesuai struktur project Anda
import 'profile_tab.dart';
import 'home_tab.dart';
import 'search_tab.dart';
import 'add_post_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _token;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadTokenAndUserId();
  }

  Future<void> _loadTokenAndUserId() async {
    String? token = await TokenStorage.getToken();
    int? userId = await TokenStorage.getUserId();

    setState(() {
      _token = token;
      _userId = userId?.toString() ?? '';
    });

    // print('Token: $_token');
    // print('UserId: $_userId');
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }
  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomeTab(),
      SearchTab(),
      AddPostTab(),
      ProfileTab(userId: int.tryParse(_userId) ?? 0), // Kirim userId yang sudah di-extract ke ProfileTab
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => _onItemTapped(0),
                child: Icon(Icons.home, size: 27, color: _selectedIndex == 0 ? Colors.black : Colors.grey),
              ),
              GestureDetector(
                onTap: () => _onItemTapped(1),
                child: Icon(Icons.search, size: 27, color: _selectedIndex == 1 ? Colors.black : Colors.grey),
              ),
              GestureDetector(
                onTap: () => _onItemTapped(2),
                child: Icon(Icons.edit_square, size: 27, color: _selectedIndex == 2 ? Colors.black : Colors.grey),
              ),
              GestureDetector(
                onTap: () => _onItemTapped(3),
                child: Icon(Icons.person_2_outlined, size: 27, color: _selectedIndex == 3 ? Colors.black : Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
