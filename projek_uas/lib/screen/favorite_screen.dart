import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<String> _rawItems = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rawItems = prefs.getStringList('favorites') ?? [];
    });
  }

  Future<void> _removeFavorite(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList('favorites') ?? [];
    items.removeWhere((element) => element == key);
    await prefs.setStringList('favorites', items);
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: const Text('Daftar Favorit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            const Divider(),
            Expanded(
              child: _rawItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.favorite_border, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Belum ada favorit', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _rawItems.length,
                      itemBuilder: (context, index) {
                        final raw = _rawItems[index];
                        Map<String, dynamic> data = {};
                        try {
                          data = jsonDecode(raw) as Map<String, dynamic>;
                        } catch (_) {}

                        final title = (data['title'] ?? 'Untitled').toString();
                        final subtitle = (data['subtitle'] ?? '').toString();

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.place, size: 36, color: Colors.blueAccent),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                    if (subtitle.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(subtitle, style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _removeFavorite(raw),
                              ),
                              TextButton(
                                child: const Text('Lihat'),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetailScreen(
                                        title: title,
                                        subtitle: subtitle,
                                        imageUrl: (data['imageUrl'] ?? '').toString(),
                                        description: (data['description'] ?? '').toString(),
                                        initiallyFavorite: true, postId: '', userId: '', createdAt: null,
                                      ),  
                                    ),
                                  );
                                  await _loadFavorites();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}