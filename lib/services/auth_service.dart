import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/token_storage.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await TokenStorage.saveToken(data['token']);
      return {'user': User.fromJson(data['user'])};
    } else {
      throw Exception(data['error'] ?? 'Login failed');
    }
  }

  static Future<Map<String, dynamic>> register(String email, String username, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'username': username, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return {'message': data['message']};
    } else {
      throw Exception(data['error'] ?? 'Register failed');
    }
  }
}
