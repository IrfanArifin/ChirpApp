import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/profile_tab.dart';
import 'screens/edit_profile.dart';

// Contoh default userId supaya bisa dicontohkan untuk ProfileTab
const int loggedInUserId = 1;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chirp App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),

      // Home atau initialRoute kini arahkan ke login
      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginScreen(),
        '/profile': (context) => ProfileTab(userId: loggedInUserId),
        // Jika Anda punya halaman edit profile, bisa ditambahkan di sini 
        '/edit_profile': (context) => EditProfile(),
      },
    );
  }
}
