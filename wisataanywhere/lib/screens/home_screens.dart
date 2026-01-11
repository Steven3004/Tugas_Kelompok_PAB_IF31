import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import 'package:wisataanywhere/screens/add_post_screen.dart';
import 'package:wisataanywhere/screens/detail_screen.dart';
import 'package:wisataanywhere/screens/favorite_screen.dart';
import 'package:wisataanywhere/screens/profile_screen.dart';
import 'package:wisataanywhere/screens/search_screen.dart';
import 'package:wisataanywhere/screens/sign_in_screen.dart';
import 'package:wisataanywhere/screens/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class PostStatsWidget extends StatelessWidget {
  final String postId;
  final bool isDarkMode;
  
  const PostStatsWidget({super.key, 
    required this.postId,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').doc(postId).snapshots(),
      builder: (context, postSnapshot) {
        final shareCount = postSnapshot.hasData 
            ? (postSnapshot.data!.data() as Map<String, dynamic>)['shareCount'] ?? 0 
            : 0;
            
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('favorites')
              .where('postId', isEqualTo: postId)
              .snapshots(),
          builder: (context, likeSnapshot) {
            final likeCount = likeSnapshot.hasData 
                ? likeSnapshot.data!.docs.length 
                : 0;
                
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('comments')
                  .where('postId', isEqualTo: postId)
                  .snapshots(),
              builder: (context, commentSnapshot) {
                final commentCount = commentSnapshot.hasData 
                    ? commentSnapshot.data!.docs.length 
                    : 0;
                    
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Like Count
                    Row(
                      children: [
                        Icon(
                          Icons.favorite_border,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$likeCount',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    
                    // Comment Count
                    Row(
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$commentCount',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    
                    // Share Count
                    Row(
                      children: [
                        Icon(
                          Icons.share_outlined,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$shareCount',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey = GlobalKey<LiquidPullToRefreshState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds} secs ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} mins ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hrs ago';
    } else if (diff.inHours < 48) {
      return '1 day ago';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {});
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (route) => false,
    );
  }

  void _navigateToDetailScreen(
    String postId,
    String? imageBase64,
    String? title,
    String? description,
    DateTime createdAt,
    String fullName,
    String userId,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DetailPostScreen(
          postId: postId,
          userId: userId,
          imageBase64: imageBase64,
          title: title,
          description: description,
          createdAt: createdAt,
          fullName: fullName,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AddPostScreen()),
      ).then((_) {
        setState(() => _selectedIndex = 0);
        _pageController.jumpToPage(0);
      });
      return;
    }
    
    if (index == 3) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const ProfileScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      ).then((_) {
        setState(() => _selectedIndex = 0);
        _pageController.jumpToPage(0);
      });
      return;
    }
    
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index == 3 ? 2 : index);
    });
  }

  Uint8List? _decodeBase64Safe(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      print('❌ Base64 string is null or empty');
      return null;
    }

    try {
      final bytes = base64Decode(base64String);
      print('✅ Successfully decoded base64: ${bytes.length} bytes');
      return bytes;
    } catch (e) {
      print('❌ Error decoding base64: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final themeColor = Theme.of(context).primaryColor;
    final currentUser = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('WisataAnywhere', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.grey[900]!, Colors.grey[800]!]
                    : [themeColor, themeColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => themeProvider.toggleTheme(!isDarkMode),
            ),
            if (currentUser != null)
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(
                      radius: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  final photoBase64 = snapshot.data?['photoBase64'] as String?;
                  return GestureDetector(
                    onTap: () => _onItemTapped(3),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: photoBase64 != null
                          ? MemoryImage(base64Decode(photoBase64))
                          : const AssetImage('assets/default_profile.png') as ImageProvider,
                    ),
                  );
                },
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: LiquidPullToRefresh(
          key: _refreshIndicatorKey,
          onRefresh: _handleRefresh,
          color: themeColor,
          height: 150,
          animSpeedFactor: 2,
          showChildOpacityTransition: false,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildHomeContent(isDarkMode, themeColor),
              Container(), // Placeholder for Add Post
              const FavoriteScreen(),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: themeColor,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddPostScreen()),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
        bottomNavigationBar: BottomAppBar(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  index: 0,
                  isSelected: _selectedIndex == 0,
                  isDarkMode: isDarkMode,
                  themeColor: themeColor,
                ),
                _buildNavItem(
                  icon: Icons.favorite,
                  label: 'Favorites',
                  index: 2,
                  isSelected: _selectedIndex == 2,
                  isDarkMode: isDarkMode,
                  themeColor: themeColor,
                ),
                const SizedBox(width: 40),
                _buildNavItem(
                  icon: Icons.search,
                  label: 'Search',
                  index: 1,
                  isSelected: _selectedIndex == 1,
                  isDarkMode: isDarkMode,
                  themeColor: themeColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                  ),
                ),
                _buildNavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  index: 3,
                  isSelected: _selectedIndex == 3,
                  isDarkMode: isDarkMode,
                  themeColor: themeColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required bool isDarkMode,
    required Color themeColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? themeColor : isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? themeColor : isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(bool isDarkMode, Color themeColor) {
    print('\n\n🏠 [HOME_SCREEN] _buildHomeContent() called');
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        print('📡 [HOME_SCREEN] StreamBuilder callback - connectionState: ${snapshot.connectionState}');
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('⏳ [HOME_SCREEN] Loading posts...');
          return _buildShimmerLoading();
        }
        
        if (snapshot.hasError) {
          print('❌ [HOME_SCREEN] Error: ${snapshot.error}');
          return _buildErrorState(isDarkMode, 'Error loading posts');
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print('⚠️ [HOME_SCREEN] No posts found');
          return _buildEmptyState(isDarkMode, themeColor);
        }

        final posts = snapshot.data!.docs;
        print('✅ [HOME_SCREEN] Found ${posts.length} posts\n');

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            try {
              final postDoc = posts[index];
              final postId = postDoc.id;
              final data = postDoc.data() as Map<String, dynamic>;
              
              // Try to get image from both possible keys
              var imageBase64 = data['imageBase64'] as String?;
              if (imageBase64 == null || imageBase64.isEmpty) {
                imageBase64 = data['image'] as String?; // Fallback to 'image' key
              }
              
              final title = data['title'] as String?;
              final description = data['description'] as String?;
              final fullName = data['fullName'] as String? ?? 'Anonymous';
              final userId = data['userId'] as String? ?? 'Unknown';

            // Debug logging
            print('\n╔════════════════════════════════════════════════╗');
            print('║ 📋 POST DETAIL - ID: $postId');
            print('║ Available keys: ${data.keys.toList()}');
            print('║ Title: "$title"');
            print('║ Description: "$description"');
            
            if (imageBase64 != null && imageBase64.isNotEmpty) {
              print('║ ✅ imageBase64 FOUND: ${imageBase64.length} chars');
              print('║ 🔤 Starts with: "${imageBase64.substring(0, 20)}"');
              print('║ 🔤 Ends with: "${imageBase64.substring(imageBase64.length - 20)}"');
              print('║ 📊 Length % 4 = ${imageBase64.length % 4} (should be 0)');
              print('║ 🏷️ JPEG magic (/9j/): ${imageBase64.startsWith('/9j/') ? '✅ YES' : '❌ NO'}');
            } else {
              print('║ ❌ imageBase64 is NULL or EMPTY');
              print('║ 🔍 Checking alternative keys...');
              if (data.containsKey('image')) {
                final altImage = data['image'] as String?;
                print('║ ⚠️ Found "image" key: ${altImage != null ? "${altImage.length} chars" : "NULL"}');
              }
              if (data.containsKey('photo')) {
                print('║ ⚠️ Found "photo" key: ${data['photo']}');
              }
            }
            print('╚════════════════════════════════════════════════╝\n');

            // Handle createdAt parsing - Firebase returns Timestamp not String
            DateTime createdAt;
            if (data['createdAt'] is Timestamp) {
              createdAt = (data['createdAt'] as Timestamp).toDate();
            } else {
              try {
                final createdAtStr = data['createdAt'] as String?;
                createdAt = createdAtStr != null ? DateTime.parse(createdAtStr) : DateTime.now();
              } catch (_) {
                createdAt = DateTime.now();
              }
            }

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return _buildPostShimmer();
                }

                if (userSnapshot.hasError) {
                  return _buildErrorCard(isDarkMode, 'Error loading user data');
                }

                final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                final photoBase64 = userData?['photoBase64'] as String?;
                final userFullName = userData?['fullName'] as String? ?? fullName ?? 'Anonymous';
                final userPhoto = photoBase64 != null
                    ? MemoryImage(base64Decode(photoBase64))
                    : const AssetImage('assets/default_profile.png') as ImageProvider;

                return AnimatedPostCard(
                  animation: _fadeAnimation,
                  isDarkMode: isDarkMode,
                  imageBase64: imageBase64,
                  title: title,
                  description: description,
                  createdAt: createdAt,
                  fullName: userFullName,
                  userPhoto: userPhoto,
                  onTap: () => _navigateToDetailScreen(
                    postId, imageBase64, title, description, createdAt, fullName, userId),
                  postId: postId,
                  userId: userId,
                );
              },
            );
            } catch (e) {
              print('ERROR in ListView.builder: $e');
              return _buildErrorCard(isDarkMode, 'Error loading post: $e');
            }
          },
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 20,
              width: 200,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: double.infinity,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: 150,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDarkMode, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/error.json',
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: TextStyle(
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => setState(() {}),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(bool isDarkMode, String error) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[400]),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                error,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode, Color themeColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/empty.json',
            width: 250,
            height: 250,
          ),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Be the first to share your travel experience!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddPostScreen()),
              );
            },
            child: const Text(
              'Create Post',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedPostCard extends StatelessWidget {
  final Animation<double> animation;
  final bool isDarkMode;
  final String? imageBase64;
  final String? title;
  final String? description;
  final DateTime createdAt;
  final String fullName;
  final ImageProvider userPhoto;
  final VoidCallback onTap;
  final String userId;
  final String postId;

  const AnimatedPostCard({super.key, 
    required this.animation,
    required this.isDarkMode,
    this.imageBase64,
    this.title,
    this.description,
    required this.createdAt,
    required this.fullName,
    required this.userPhoto,
    required this.onTap,
    required this.userId,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    print('🎨 AnimatedPostCard.build() - postId: $postId, imageBase64: ${imageBase64 != null ? '${imageBase64!.length} chars' : 'null'}');
    
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: SingleChildScrollView(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor:
                      isDarkMode ? Colors.black : Colors.grey.withOpacity(0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageBase64 != null && imageBase64!.isNotEmpty)
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Stack(
                            children: [
                              _buildImageWidget(imageBase64),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _formatTime(createdAt),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported, size: 40),
                                SizedBox(height: 8),
                                Text('Tidak ada gambar'),
                              ],
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Hero(
                                  tag: 'user_avatar_${userId}_$postId', // Fixed: Unique tag with both userId and postId
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundImage: userPhoto,  
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fullName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (title != null && title!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  title!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            if (description != null && description!.isNotEmpty)
                              Text(
                                description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                                ),
                              ),
                            const SizedBox(height: 12),
                            PostStatsWidget(
                              postId: postId,
                              isDarkMode: isDarkMode,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds} secs ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} mins ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hrs ago';
    } else if (diff.inHours < 48) {
      return '1 day ago';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  Widget _buildImageWidget(String? base64Image) {
    if (base64Image == null || base64Image.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey[300],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('DEBUG: base64Image is NULL'),
              SizedBox(height: 8),
              Icon(Icons.image_not_supported),
            ],
          ),
        ),
      );
    }

    try {
      final bytes = base64Decode(base64Image);
      
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 200,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.red[100],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('DEBUG: Image.memory error'),
                  Text('Error: $error', style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        height: 200,
        color: Colors.orange[100],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('DEBUG: Decode error'),
              Text('$e', style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      );
    }
  }

  bool _isValidBase64(String str) {
    try {
      // Base64 should only contain alphanumeric, +, /, and =
      final base64Regex = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
      if (!base64Regex.hasMatch(str)) {
        print('❌ Base64 contains invalid characters');
        return false;
      }
      
      // Length should be multiple of 4
      if (str.length % 4 != 0) {
        print('❌ Base64 length not multiple of 4: ${str.length}');
        return false;
      }

      // Extra validation: check if it ends properly
      final lastChar = str[str.length - 1];
      final secondLastChar = str.length > 1 ? str[str.length - 2] : '';
      
      // Debug info about string ending
      print('✅ Base64 format valid: length=${str.length}, last char=$lastChar, second-last=$secondLastChar');
      print('📊 Base64 first 50 chars: ${str.substring(0, (str.length > 50 ? 50 : str.length))}');
      print('📊 Base64 last 50 chars: ${str.substring((str.length > 50 ? str.length - 50 : 0))}');
      
      return true;
    } catch (e) {
      print('❌ Base64 validation error: $e');
      return false;
    }
  }

  Widget _buildPlaceholder(String text, IconData icon) {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}