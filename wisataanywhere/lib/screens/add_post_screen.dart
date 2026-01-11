import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  File? _image;
  String? _base64Image;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        File originalFile = File(pickedFile.path);

        final compressedBytes = await FlutterImageCompress.compressWithFile(
          originalFile.absolute.path,
          quality: 40,
        );

        if (compressedBytes == null) {
          _showErrorSnackbar('Gagal mengompresi gambar.');
          return;
        }

        final compressedFile = File('${originalFile.path}_compressed.jpg')
          ..writeAsBytesSync(compressedBytes);

        final base64 = base64Encode(compressedBytes);

        if (base64.length > 800000) {
          _showErrorSnackbar('Gambar terlalu besar untuk disimpan.');
          return;
        }

        setState(() {
          _image = compressedFile;
          _base64Image = base64;
        });
      }
    } catch (e) {
      _showErrorSnackbar('Gagal memilih gambar: ${e.toString()}');
    }
  }

  Future<void> _getLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorSnackbar('Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          _showErrorSnackbar('Location permissions are denied');
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      ).timeout(const Duration(seconds: 15));

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      _showErrorSnackbar('Gagal mendapatkan lokasi: ${e.toString()}');
    }
  }

  Future<void> _submitPost() async {
    if (_base64Image == null) {
      _showErrorSnackbar('Tambahkan gambar terlebih dahulu');
      return;
    }

    if (_titleController.text.isEmpty) {
      _showErrorSnackbar('Tambahkan judul');
      return;
    }

    if (_descriptionController.text.isEmpty) {
      _showErrorSnackbar('Tambahkan deskripsi');
      return;
    }

    setState(() => _isUploading = true);

    try {
      await _getLocation();

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _showErrorSnackbar('Anda harus login terlebih dahulu');
        return;
      }

      // Get user full name
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      final fullName = userDoc.data()?['fullName'] ?? 'Anonymous';

      // Save post to Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'userId': currentUser.uid,
        'fullName': fullName,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'image': _base64Image,
        'latitude': _latitude ?? 0.0,
        'longitude': _longitude ?? 0.0,
        'createdAt': Timestamp.now(),
        'shareCount': 0,
      });

      if (mounted) {
        Navigator.pop(context);
        _showSuccessSnackbar('Post berhasil disimpan!');
      }
    } catch (e) {
      print('❌ Error saving post: $e');
      _showErrorSnackbar('Gagal menyimpan: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo,
                              size: 50, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(
                            'Tambah Foto',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul',
                hintText: 'Masukkan judul postingan...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Masukkan deskripsi...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              minLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Lokasi'),
              subtitle: _latitude != null
                  ? Text('Lat: $_latitude, Long: $_longitude')
                  : const Text('Menunggu lokasi...'),
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _getLocation,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isUploading ? null : _submitPost,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: _isUploading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child:
                          CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'SIMPAN POST',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
