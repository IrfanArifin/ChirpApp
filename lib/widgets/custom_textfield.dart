import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final IconData icon;
  final FocusNode? focusNode; // Tambahkan ini
  final TextInputType? keyboardType; // Tambahkan ini

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    required this.icon,
    this.focusNode, // Parameter opsional diterima
    this.keyboardType, // Parameter opsional diterima
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  late bool _focusNodeCreatedInternally;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _focusNode = FocusNode();
      _focusNodeCreatedInternally = true;
    } else {
      _focusNode = widget.focusNode!;
      _focusNodeCreatedInternally = false;
    }
    _focusNode.addListener(() {
      setState(() {}); // Refresh UI saat fokus berubah
    });
  }

  @override
  void dispose() {
    if (_focusNodeCreatedInternally) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      focusNode: _focusNode,
      keyboardType: widget.obscureText ? TextInputType.visiblePassword : TextInputType.text,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(
          widget.icon,
          color: _focusNode.hasFocus ? Colors.black : Colors.grey,
        ),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
      ),
    );
  }
}

