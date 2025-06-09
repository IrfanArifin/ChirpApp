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

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _pickedImage = pickedFile;
        });

        // Upload ke API image backend
        final imageUrl = await _uploadImageToApi(pickedFile);
        if (imageUrl != null) {
          _imageController.text = imageUrl;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal upload gambar ke server'),
          ));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error saat memilih gambar: $e'),
      ));
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


  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  bool _isLoading = false;

Future<void> _submitPost() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final userId = await TokenStorage.getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID tidak ditemukan. Silakan login terlebih dahulu.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final token = await TokenStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token tidak ditemukan. Silakan login terlebih dahulu.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final String content = _contentController.text.trim();
    final String? image = _imageController.text.trim().isEmpty ? null : _imageController.text.trim();

    final Uri url = Uri.parse('http://localhost:3000/api/posts');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'content': content,
        'image': image,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Postingan berhasil dibuat!')),
      );
      _contentController.clear();
      _imageController.clear();
    } else {
      final Map<String, dynamic> errorResponse = jsonDecode(response.body);
      final errorMessage = errorResponse['error'] ?? 'Gagal membuat postingan.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $errorMessage')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi kesalahan: $e')),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  @override
  void dispose() {
    _contentController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
                hintText: 'Tulis isi postingan Anda di sini...',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Content tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageController,
              decoration: const InputDecoration(
                labelText: 'Image URL (optional)',
                border: OutlineInputBorder(),
                hintText: 'Masukkan URL gambar jika ada',
              ),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final uri = Uri.tryParse(value);
                  if (uri == null || (!uri.isAbsolute)) {
                    return 'Masukkan URL yang valid';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitPost,
                    child: const Text('Submit Post'),
                  ),
          ],
        ),
      ),
    );
  }
}
