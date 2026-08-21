import 'package:flutter/material.dart';
import 'package:project_tride/Constants/app_colors.dart';
import 'package:project_tride/Database/db_helper.dart';
import 'package:project_tride/Database/destination_model.dart';
import 'package:project_tride/Database/favorite_model.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Widgets/category_filter_bar.dart';
import '../../Widgets/custom_floating_nav_bar.dart';
import '../halaman Ai Planner/halaman_aiplanner_step1.dart';
import '../halaman beranda/halaman_beranda.dart';
import '../halaman beranda/halaman_destination_detail.dart';
import '../halaman budget/halaman_budget.dart';
import '../halaman profile/halaman_profil.dart';
import '../halaman profile/halaman_saved_places.dart';

class HalamanJelajah extends StatefulWidget {
  final UserModel? user;
  final bool isEmbeddedInShell;

  const HalamanJelajah({super.key, this.user, this.isEmbeddedInShell = false});

  @override
  State<HalamanJelajah> createState() => _HalamanJelajahState();
}

class _HalamanJelajahState extends State<HalamanJelajah> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  final Set<int> _favorites = {};

  final List<String> _categories = [
    'Semua',
    'Alam',
    'Perkotaan',
    'Santai',
    'Petualangan',
  ];

  final List<Map<String, dynamic>> _curatedCollections = [
    {
      'id': 1,
      'tag': 'WISATA PANTAI',
      'title': 'Impian\nMediterranean',
      'destinations': '12 Destinasi',
      'imageUrl':
          'https://images.unsplash.com/photo-1533105079780-92b9be482077?q=80&w=800&auto=format&fit=crop',
    },
    {
      'id': 2,
      'tag': 'ALAM BEBAS',
      'title': 'Ketenangan\nPegunungan',
      'destinations': '8 Destinasi',
      'imageUrl':
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=800&auto=format&fit=crop',
    },
  ];

  final List<Map<String, dynamic>> _trendingDestinations = [
    {
      'id': 7,
      'title': 'Tokyo, Japan',
      'price': 'mulai Rp 13,5jt',
      'rating': '4.9',
      'reviews': '(1.2k)',
      'category': 'Perkotaan',
      'imageUrl':
          'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?q=80&w=600&auto=format&fit=crop',
    },
    {
      'id': 8,
      'title': 'Santorini, Greece',
      'price': 'mulai Rp 19jt',
      'rating': '4.9',
      'reviews': '(2.4k)',
      'category': 'Santai',
      'imageUrl':
          'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?q=80&w=600&auto=format&fit=crop',
    },
    {
      'id': 9,
      'title': 'Labuan Bajo, ID',
      'price': 'mulai Rp 6,8jt',
      'rating': '4.8',
      'reviews': '(1.8k)',
      'category': 'Alam',
      'imageUrl':
          'https://images.unsplash.com/photo-1516690561799-46d8f74f9abf?q=80&w=600&auto=format&fit=crop',
    },
    {
      'id': 3,
      'title': 'Kyoto Pagoda',
      'price': 'mulai Rp 12jt',
      'rating': '4.8',
      'reviews': '(3.1k)',
      'category': 'Urban',
      'imageUrl':
          'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?q=80&w=600&auto=format&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final userId = widget.user?.id ?? 1;
      final favs = await DbHelper.instance.getFavoritesByUser(userId);
      if (mounted) {
        setState(() {
          _favorites.clear();
          _favorites.addAll(favs.map((f) => f.destinationId));
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    if (index == 1) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HalamanBeranda(user: widget.user),
          ),
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HalamanAiPlanner(user: widget.user),
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HalamanBudget(user: widget.user),
          ),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HalamanProfil(user: widget.user),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgCloud = AppColors.background;
    const Color textNavy = AppColors.textPrimary;
    const Color primaryBlue = AppColors.primaryDeep;

    // Filter logic
    final query = _searchController.text.toLowerCase().trim();
    final selectedCategory = _categories[_selectedCategoryIndex];

    final filteredList = _trendingDestinations.where((item) {
      final matchesQuery = item['title'].toLowerCase().contains(query);
      final matchesCategory =
          selectedCategory == 'Semua' ||
          selectedCategory == 'All' ||
          item['category'] == selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: bgCloud,
      body: CustomScrollView(
        slivers: [
          // Top App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            surfaceTintColor: Colors.transparent,
            titleSpacing: 20,
            title: Row(
              children: [
                Image.asset(
                  'assets/image/playstore.png',
                  height: 32,
                  width: 32,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.explore, color: primaryBlue, size: 28),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Trips",
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: textNavy,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HalamanSavedPlaces(user: widget.user),
                      ),
                    );
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: primaryBlue.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HalamanProfil(user: widget.user),
                      ),
                    );
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=300&auto=format&fit=crop',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Field
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 253, 253, 253),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: Colors.black54,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {});
                            },
                            style: const TextStyle(
                              color: textNavy,
                              fontSize: 15,
                            ),
                            decoration: const InputDecoration(
                              hintText: "Ke mana tujuan liburan Anda?",
                              hintStyle: TextStyle(
                                color: Colors.black45,
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Pencarian suara diaktifkan..."),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.mic_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Category Chips
                CategoryFilterBar(
                  categories: _categories,
                  selectedCategory: _categories[_selectedCategoryIndex],
                  onCategorySelected: (cat) {
                    setState(() {
                      _selectedCategoryIndex = _categories.indexOf(cat);
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Curated Collections Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Koleksi\nPilihan",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: textNavy,
                          height: 1.2,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "LIHAT SEMUA",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                SizedBox(
                  height: 320,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _curatedCollections.length,
                    itemBuilder: (context, index) {
                      final item = _curatedCollections[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HalamanDestinationDetail(
                                user: widget.user,
                                destinationTitle: item['title'].replaceAll(
                                  '\n',
                                  ' ',
                                ),
                                categoryTag: item['tag'],
                                imageUrl: item['imageUrl'],
                                description:
                                    'Jelajahi keindahan dan pengalaman eksklusif di ${item['title'].replaceAll('\n', ' ')}. Tempat liburan impian terbaik untuk merilekskan pikiran.',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 280,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            image: DecorationImage(
                              image: NetworkImage(item['imageUrl']),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    item['tag'],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  item['title'],
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Plus Jakarta Sans',
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      item['destinations'],
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Trending Now Section
                Container(
                  padding: const EdgeInsets.only(top: 24, bottom: 40),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(36),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Trending Saat Ini",
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: textNavy,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (filteredList.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              "Tidak ada destinasi ditemukan.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.72,
                              ),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            final isFav = _favorites.contains(item['id']);

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HalamanDestinationDetail(
                                      user: widget.user,
                                      destinationTitle: item['title'],
                                      categoryTag:
                                          (item['category'] as String?)
                                              ?.toUpperCase() ??
                                          'DESTINASI POPULER',
                                      imageUrl: item['imageUrl'],
                                      rating:
                                          item['rating']?.toString() ?? '4.8',
                                      pricePerDay: item['price'] ?? 'Rp 1.5M',
                                      description:
                                          'Tinggalkan rutinitas dan nikmati keindahan ${item['title']}. Temukan berbagai atraksi budaya, alam, serta kuliner khas yang memukau.',
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: bgCloud,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Image Banner with Price Tag
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              ),
                                          child: Image.network(
                                            item['imageUrl'],
                                            height: 140,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),

                                        // Favorite Heart Button
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () async {
                                              final userId =
                                                  widget.user?.id ?? 1;
                                              final itemId = item['id'] as int;
                                              final isCurrentlyFav = _favorites
                                                  .contains(itemId);

                                              try {
                                                if (isCurrentlyFav) {
                                                  await DbHelper.instance
                                                      .removeFavorite(
                                                        userId,
                                                        itemId,
                                                      );
                                                  if (mounted) {
                                                    setState(() {
                                                      _favorites.remove(itemId);
                                                    });
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).removeCurrentSnackBar();
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          '${item['title']} dihapus dari Saved Places',
                                                        ),
                                                        duration:
                                                            const Duration(
                                                              seconds: 1,
                                                            ),
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  await DbHelper.instance
                                                      .ensureDestinationExists(
                                                        DestinationModel(
                                                          id: itemId,
                                                          name: item['title'],
                                                          location:
                                                              item['category'] ??
                                                              '',
                                                          description:
                                                              item['title'],
                                                          image:
                                                              item['imageUrl'],
                                                          category:
                                                              item['category'] ??
                                                              'General',
                                                          rating:
                                                              double.tryParse(
                                                                item['rating'] ??
                                                                    '4.8',
                                                              ) ??
                                                              4.8,
                                                        ),
                                                      );

                                                  await DbHelper.instance
                                                      .addFavorite(
                                                        FavoriteModel(
                                                          userId: userId,
                                                          destinationId: itemId,
                                                          createdAt: DateTime.now()
                                                              .toIso8601String(),
                                                        ),
                                                      );
                                                  if (mounted) {
                                                    setState(() {
                                                      _favorites.add(itemId);
                                                    });
                                                  }

                                                  if (context.mounted) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            HalamanSavedPlaces(
                                                              user: widget.user,
                                                            ),
                                                      ),
                                                    ).then(
                                                      (_) => _loadFavorites(),
                                                    );
                                                  }
                                                }
                                              } catch (_) {}
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(
                                                  alpha: 0.35,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                isFav
                                                    ? Icons.favorite_rounded
                                                    : Icons
                                                          .favorite_border_rounded,
                                                color: isFav
                                                    ? Colors.redAccent
                                                    : Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Price Tag
                                        Positioned(
                                          bottom: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              item['price'],
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: textNavy,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Ticket Perforation Dashed Line
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 16,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              return Flex(
                                                direction: Axis.horizontal,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: List.generate(
                                                  (constraints.constrainWidth() /
                                                          8)
                                                      .floor(),
                                                  (_) => SizedBox(
                                                    width: 4,
                                                    height: 1,
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey
                                                            .shade300,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Container(
                                          width: 8,
                                          height: 16,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              bottomLeft: Radius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Details Stub
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: textNavy,
                                              fontFamily: 'Plus Jakarta Sans',
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star_rounded,
                                                color: Color(0xFFFDB813),
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "${item['rating']} ${item['reviews']}",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Integrated Floating Bottom Navigation Bar
      bottomNavigationBar: widget.isEmbeddedInShell
          ? null
          : CustomFloatingNavBar(
              selectedIndex: 1,
              onDestinationSelected: _onNavTapped,
            ),
    );
  }
}
