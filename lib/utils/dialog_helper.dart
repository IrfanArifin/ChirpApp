import 'package:flutter/material.dart';

/// Fungsi untuk menampilkan dialog alert dengan pesan [message].
/// Gunakan dengan memanggil: dialogBuilder(context, "Pesan Anda");
void dialogBuilder(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Perhatian'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
