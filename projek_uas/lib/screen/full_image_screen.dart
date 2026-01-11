import 'dart:convert';
import 'package:flutter/material.dart';

class FullImageScreen extends StatelessWidget {
  final String imageBase64;

  const FullImageScreen({super.key, required this.imageBase64});

  @override
  Widget build(BuildContext context) {
    final bytes = base64Decode(imageBase64);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          clipBehavior: Clip.none,
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.memory(bytes),
        ),
      ),
    );
  }
}
