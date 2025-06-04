import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_textfield.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  void register() async {
    setState(() => isLoading = true);
    try {
      final result = await AuthService.register(
        emailController.text,
        usernameController.text,
        passwordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(controller: emailController, label: 'Email'),
            const SizedBox(height: 10),
            CustomTextField(controller: usernameController, label: 'Username'),
            const SizedBox(height: 10),
            CustomTextField(controller: passwordController, label: 'Password', obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : register,
              child: isLoading ? const CircularProgressIndicator() : const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
