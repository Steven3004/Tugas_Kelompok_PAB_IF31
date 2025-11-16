import 'package:flutter/material.dart';

class DetailScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String description;
  final bool initiallyFavorite;

  const DetailScreen({
    super.key,
    required this.title,
    this.subtitle = '',
    this.imageUrl = '',
    this.description = '',
    this.initiallyFavorite = false,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.initiallyFavorite;
  }

  void _toggleFavorite() => setState(() => isFavorite = !isFavorite);

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (widget.imageUrl.isNotEmpty) {
      if (widget.imageUrl.startsWith('http')) {
        imageProvider = NetworkImage(widget.imageUrl);
      } else {
        imageProvider = AssetImage(widget.imageUrl);  
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),  
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imageProvider != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  if (widget.subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(widget.subtitle, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ),
                  const SizedBox(height: 12),
                  Text(widget.description, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleFavorite,
        child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
      ),
    );
  }
}
    