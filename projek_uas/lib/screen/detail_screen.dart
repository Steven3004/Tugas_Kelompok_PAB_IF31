import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String description;
  final String? postId;
  final bool? initiallyFavorite;
  final String? userId;
  final DateTime? createdAt;
  final String? fullName;

  const DetailScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.description,
    this.postId,
    this.initiallyFavorite,
    this.userId,
    this.createdAt,
    this.fullName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTO / GAMBAR
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // SUBTITLE
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // DESKRIPSI
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 30),

            // TOMBOL KEMBALI
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali'),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
