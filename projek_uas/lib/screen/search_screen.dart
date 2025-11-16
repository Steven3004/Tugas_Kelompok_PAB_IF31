import 'package:flutter/material.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchItem> filteredItems = [];
  List<SearchItem> allItems = [
    SearchItem(
      id: '1',
      title: 'Candi Borobudur',
      subtitle: 'Magelang, Jawa Tengah',
      imageUrl: '',
      description: 'Candi Borobudur adalah kompleks candi Buddha terbesar di dunia dengan arsitektur yang megah dan relief yang indah.',
    ),
    SearchItem(
      id: '2',
      title: 'Pantai Parangtritis',
      subtitle: 'Yogyakarta, Jawa Tengah',
      imageUrl: '',
      description: 'Pantai pasir hitam yang indah dengan pemandangan laut yang menakjubkan dan aktivitas wisata air yang seru.',
    ),
    SearchItem(
      id: '3',
      title: 'Taman Nasional Komodo',
      subtitle: 'Flores, Nusa Tenggara Timur',
      imageUrl: '',
      description: 'Taman nasional terkenal dengan populasi komodo dan pemandangan alam yang spektakuler serta diving yang world-class.',
    ),
    SearchItem(
      id: '4',
      title: 'Raja Ampat',
      subtitle: 'Papua Barat',
      imageUrl: '',
      description: 'Kepulauan eksotis dengan kekayaan terumbu karang dan kehidupan laut yang memukau, surga bagi penyelam dan snorkeler.',
    ),
    SearchItem(
      id: '5',
      title: 'Danau Toba',
      subtitle: 'Sumatera Utara',
      imageUrl: '',
      description: 'Danau vulkanik terbesar di Asia Tenggara dengan pemandangan alam yang indah dan budaya Batak yang kaya.',
    ),
    SearchItem(
      id: '6',
      title: 'Gunung Bromo',
      subtitle: 'Jawa Timur',
      imageUrl: '',
      description: 'Gunung berapi aktif yang terkenal dengan pemandangan sunrise spektakuler dan lautan pasir yang memukau.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    filteredItems = allItems;
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredItems = allItems;
      } else {
        filteredItems = allItems
            .where((item) =>
                item.title.toLowerCase().contains(query) ||
                item.subtitle.toLowerCase().contains(query) ||
                item.description.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _openDetailScreen(SearchItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          title: item.title,
          subtitle: item.subtitle,
          imageUrl: item.imageUrl,
          description: item.description,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari tempat wisata, pulau, atau destinasi...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterItems();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Mulai cari tempat wisata yang ingin Anda kunjungi'
                              : 'Tidak ada tempat wisata yang sesuai',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _SearchResultCard(
                        item: item,
                        onTap: () => _openDetailScreen(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class SearchItem {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String description;

  SearchItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.description,
  });
}

class _SearchResultCard extends StatelessWidget {
  final SearchItem item;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.location_on, color: Colors.green),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item.subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              item.description,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
