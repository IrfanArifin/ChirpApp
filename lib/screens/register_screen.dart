import 'dart:io';

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_textfield.dart'; // Asumsikan CustomTextField sudah Anda buat
// Import dialog helper jika nanti mau pakai showDialog atau Snackbar

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController fullName = TextEditingController();  // Ubah dari bio ke fullname
  final TextEditingController password = TextEditingController();
  final TextEditingController passwordConfirm = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    email.dispose();
    username.dispose();
    fullName.dispose();      // Dispose fullname
    password.dispose();
    passwordConfirm.dispose();
    super.dispose();
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _register() async {
    if (password.text != passwordConfirm.text) {
      showSnackBar("Password dan konfirmasi password tidak sama");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.register(
          email.text.trim(), username.text.trim(),fullName.text.trim(), password.text);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registrasi Berhasil'),
          content: Text(result['message'] ?? 'Registrasi berhasil!'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Kembali ke layar login atau sebelumnya
              },
            ),
          ],
        ),
      );
    } catch (error) {
      showSnackBar("Registrasi gagal: ${error.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: email,
              label: 'Email',
              obscureText: false,
              icon: Icons.email,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: username,
              label: 'Username',
              obscureText: false,
              icon: Icons.person,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: fullName,  
              label: 'Nama Lengkap',   
              obscureText: false,
              icon: Icons.badge, // Ganti icon sesuai kebutuhan
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: password,
              label: 'Password',
              obscureText: true,
              icon: Icons.lock,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: passwordConfirm,
              label: 'Konfirmasi Password',
              obscureText: true,
              icon: Icons.lock,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Daftar'),
            ),
          ],
        ),
      ),
    );
  }
}
