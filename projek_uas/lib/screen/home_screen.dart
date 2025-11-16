import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sign_in_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String fullName = '';
  String email = '';

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('fullName') ?? '';
      email = prefs.getString('email') ?? '';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Selamat datang, $fullName', style: const TextStyle(fontSize: 20)),
            Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.info_outline),
              label: const Text('Lihat Detail Contoh'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DetailScreen(
                      title: 'Judul',
                      subtitle: 'baru contoh',
                      imageUrl: 'https://i.pinimg.com/originals/ff/d3/73/ffd37353a07af66dc052dd9cfe3d4034.jpg',
                      description: 'Ini adalah deskripsi contoh untuk melihat tampilan DetailScreen.',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
