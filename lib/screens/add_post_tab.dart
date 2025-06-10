import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../utils/token_storage.dart';

class AddPostTab extends StatefulWidget {
  const AddPostTab({Key? key}) : super(key: key);

  @override
  _AddPostTabState createState() => _AddPostTabState();
}

class _AddPostTabState extends State<AddPostTab> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contentController = TextEditingController();

  bool _isLoading = false;
  String? _uploadedImageUrl;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _pickedImage = pickedFile;
        });

        final imageUrl = await _uploadImageToApi(pickedFile);
        setState(() {
          _uploadedImageUrl = imageUrl;
        });

        if (imageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal upload gambar ke server')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saat memilih gambar: $e')),
      );
    }
  }

  Future<String?> _uploadImageToApi(XFile imageFile) async {
    final Uri uploadUri = Uri.parse('http://localhost:3000/api/images');
    final token = await TokenStorage.getToken();

    try {
      final request = http.MultipartRequest('POST', uploadUri);
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'] as String?;
      } else {
        print('Upload gagal: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error upload gambar: $e');
      return null;
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await TokenStorage.getUserId();
      final token = await TokenStorage.getToken();
      if (userId == null || token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan login terlebih dahulu.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final content = _contentController.text.trim();
      final image = _uploadedImageUrl;

      final url = Uri.parse('http://localhost:3000/api/posts');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'content': content, 'image': image}),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Postingan berhasil dibuat!')),
        );
        _contentController.clear();
        setState(() {
          _pickedImage = null;
          _uploadedImageUrl = null;
        });
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['error'] ?? 'Gagal membuat postingan.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $errorMessage')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _contentController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Chirp',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: 'Tulis chirp Anda di sini...',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Content tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Upload Gambar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            if (_pickedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_pickedImage!.path),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 30),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : InkWell(
                    onTap: _isLoading ? null : _submitPost,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: _isLoading ? Colors.grey : Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Submit Post',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
