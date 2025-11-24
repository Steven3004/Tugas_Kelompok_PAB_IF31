import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DetailPostScreen extends StatefulWidget {
  final String postId;

  const DetailPostScreen({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  State<DetailPostScreen> createState() => _DetailPostScreenState();
}

class _DetailPostScreenState extends State<DetailPostScreen> {
  Future<void> downloadBase64Image(String? base64Image) async {
    if (base64Image == null || base64Image.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gambar tidak tersedia")),
      );
      return;
    }

    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Izin penyimpanan ditolak")));
        return;
      }

      final bytes = base64Decode(base64Image);

      final directory = await getExternalStorageDirectory();
      final filePath =
          "${directory!.path}/post_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gambar disimpan: $filePath")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal download gambar: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Postingan"),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("posts")
            .doc(widget.postId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final post = snapshot.data!;
          final data = post.data() as Map<String, dynamic>?;

          if (data == null) {
            return const Center(child: Text("Post tidak ditemukan"));
          }

          final base64Image = data["image"];
          final title = data["title"] ?? "";
          final description = data["description"] ?? "";
          final timestamp =
              data["createdAt"] != null ? data["createdAt"].toDate() : null;

          final likes = data["likedBy"] ?? [];

          // PERBAIKAN: Akses langsung field latitude dan longitude
          final latitude = data["latitude"] as double?;
          final longitude = data["longitude"] as double?;

          return ListView(
            children: [
              // --- Gambar ---
              Stack(
                children: [
                  if (base64Image != null && base64Image != "")
                    Image.memory(
                      base64Decode(base64Image),
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.image)),
                    ),

                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => downloadBase64Image(base64Image),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.download, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // --- Judul ---
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              // --- Deskripsi ---
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(description),
              ),

              // --- Tanggal ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  timestamp != null
                      ? DateFormat("dd MMM yyyy, HH:mm").format(timestamp)
                      : "",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),

              const SizedBox(height: 8),

              // --- Lokasi ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    const SizedBox(width: 6),
                    if (latitude != null && longitude != null)
                      Text(
                        "Lat: ${latitude.toStringAsFixed(6)}, Long: ${longitude.toStringAsFixed(6)}",
                        style: TextStyle(color: Colors.grey[700]),
                      )
                    else
                      Text(
                        "Lokasi tidak tersedia",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // --- Like & Share ---
              Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.favorite, color: Colors.red[400]),
                  const SizedBox(width: 8),
                  Text("${likes.length} suka"),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Share.share(description),
                    child: const Icon(Icons.share),
                  ),
                  const SizedBox(width: 12),
                ],
              ),

              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}
