import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../utils/token_storage.dart'; // Import TokenStorage

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController bioController = TextEditingController();
  TextEditingController imageController = TextEditingController();
  bool isLoading = false;
  String message = '';

  // Placeholder userId dan token (akan diupdate lewat initState)
  int? userId;
  String? token;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final storedUserId = await TokenStorage.getUserId();
    final storedToken = await TokenStorage.getToken();
    setState(() {
      userId = storedUserId;
      token = storedToken;
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null) {
      setState(() {
        imageController.text = pickedFile.path;
      });
    }
  }

  Future<void> updateProfile() async {
    if (userId == null) {
      setState(() {
        message = 'User ID not found. Please login again.';
      });
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      message = '';
    });

    final url = Uri.parse('http://localhost:3000/api/users/$userId/update');
    final body = json.encode({
      'bio': bioController.text.isEmpty ? null : bioController.text,
      'image': imageController.text.isEmpty ? null : imageController.text,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: body,
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          message = 'Profile updated successfully!';
        });
      } else {
        setState(() {
          message = 'Error: ${data['error'] ?? 'Failed to update profile'}';
        });
      }
    } catch (e) {
      setState(() {
        message = 'Request failed: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    bioController.dispose();
    imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: bioController,
                maxLength: 500,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.length > 500) {
                    return 'Bio cannot exceed 500 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Upload Gambar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: isLoading ? null : updateProfile,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: isLoading ? Colors.grey : Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Update Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              if (message.isNotEmpty)
                Text(
                  message,
                  style: TextStyle(
                    color:
                        message.startsWith('Error') ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
