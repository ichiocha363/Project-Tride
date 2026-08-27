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
  String _selectedCategory = 'Semua';
  final Set<int> _favorites = {};
  List<DestinationModel> _destinations = [];
  bool _isLoadingDestinations = true;

  final List<String> _categories = [
    'Semua',
    'Pantai',
    'Pegunungan',
    'Perkotaan',
    'Pedesaan',
    'Alam',
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

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadDestinations();
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

  Future<void> _loadDestinations() async {
    setState(() => _isLoadingDestinations = true);
    try {
      final seedList = [
        DestinationModel(
          id: 1,
          name: 'Rome',
          location: 'Italy · Culture',
          description:
              'Historical city rich in architecture, ancient ruins, and world-class culinary experiences.',
          image:
              'https://images.unsplash.com/photo-1552832230-c0197dd311b5?q=80&w=1200&auto=format&fit=crop',
          category: 'Culture',
          rating: 4.8,
          estimatedBudget: 2500000,
          bestTime: 'May - Oct',
          placeType: 'Perkotaan',
        ),
        DestinationModel(
          id: 2,
          name: 'Maldives',
          location: 'South Asia · Island',
          description:
              'Crystal clear waters, overwater bungalows, and pristine white sand beaches.',
          image:
              'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?q=80&w=800&auto=format&fit=crop',
          category: 'Relax',
          rating: 4.9,
          estimatedBudget: 4500000,
          bestTime: 'Nov - Apr',
          placeType: 'Pantai',
        ),
        DestinationModel(
          id: 3,
          name: 'Kyoto',
          location: 'Japan · Culture',
          description:
              'Traditional wooden houses, serene Zen gardens, and historic Shinto shrines.',
          image:
              'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?q=80&w=800&auto=format&fit=crop',
          category: 'Culture',
          rating: 4.8,
          estimatedBudget: 3200000,
          bestTime: 'Mar - May',
          placeType: 'Perkotaan',
        ),
        DestinationModel(
          id: 4,
          name: 'Icelandia',
          location: 'North Europe · Nature',
          description:
              'Dramatic volcanic landscapes, majestic waterfalls, and mesmerizing Northern Lights.',
          image:
              'https://images.unsplash.com/photo-1504893524553-b855bce32c67?q=80&w=800&auto=format&fit=crop',
          category: 'Nature',
          rating: 4.9,
          estimatedBudget: 5000000,
          bestTime: 'Sep - Mar',
          placeType: 'Alam',
        ),
        DestinationModel(
          id: 5,
          name: 'Marrakech',
          location: 'Morocco · Culture',
          description:
              'Vibrant souks, stunning riads, and rich African-Arabian culture.',
          image:
              'https://images.unsplash.com/photo-1597212618440-806262de4f6b?q=80&w=800&auto=format&fit=crop',
          category: 'Culture',
          rating: 4.7,
          estimatedBudget: 2200000,
          bestTime: 'Oct - Apr',
          placeType: 'Perkotaan',
        ),
        DestinationModel(
          id: 6,
          name: 'Zermatt',
          location: 'Switzerland · Nature',
          description:
              'Famous mountain resort at the foot of the iconic Matterhorn peak.',
          image:
              'https://images.unsplash.com/photo-1530122037265-a5f1f91d3b99?q=80&w=800&auto=format&fit=crop',
          category: 'Nature',
          rating: 4.8,
          estimatedBudget: 4800000,
          bestTime: 'Dec - Mar',
          placeType: 'Pegunungan',
        ),
        DestinationModel(
          id: 7,
          name: 'Tokyo',
          location: 'Japan · Urban',
          description:
              'Futuristic metropolis blending ultramodern skyscrapers with historic temples.',
          image:
              'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?q=80&w=600&auto=format&fit=crop',
          category: 'Urban',
          rating: 4.9,
          estimatedBudget: 3800000,
          bestTime: 'Mar - May',
          placeType: 'Perkotaan',
        ),
        DestinationModel(
          id: 8,
          name: 'Santorini',
          location: 'Greece · Relax',
          description:
              'White-washed cliffside villas overlooking dramatic Aegean Sea views.',
          image:
              'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?q=80&w=600&auto=format&fit=crop',
          category: 'Relax',
          rating: 4.9,
          estimatedBudget: 4200000,
          bestTime: 'May - Sep',
          placeType: 'Pantai',
        ),
        DestinationModel(
          id: 9,
          name: 'Labuan Bajo',
          location: 'Indonesia · Nature',
          description:
              'Gateway to Komodo National Park with pristine beaches and island adventures.',
          image:
              'https://images.unsplash.com/photo-1516690561799-46d8f74f9abf?q=80&w=600&auto=format&fit=crop',
          category: 'Nature',
          rating: 4.8,
          estimatedBudget: 2800000,
          bestTime: 'Apr - Oct',
          placeType: 'Pantai',
        ),
        DestinationModel(
          id: 10,
          name: 'Desa Penglipuran',
          location: 'Bali · Pedesaan',
          description:
              'Desa adat terbersih dengan arsitektur tradisional Bali yang asri dan tenang.',
          image:
              'https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=800&auto=format&fit=crop',
          category: 'Pedesaan',
          rating: 4.7,
          estimatedBudget: 1500000,
          bestTime: 'Apr - Oct',
          placeType: 'Pedesaan',
        ),
      ];

      for (var dest in seedList) {
        await DbHelper.instance.ensureDestinationExists(dest);
      }

      List<DestinationModel> results;
      if (_selectedCategory == 'Semua') {
        results = await DestinationModel.getAll();
      } else {
        results = await DestinationModel.getByPlaceType(_selectedCategory);
      }

      if (mounted) {
        setState(() {
          _destinations = results;
          _isLoadingDestinations = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingDestinations = false);
      }
    }
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

    final filteredList = _destinations.where((item) {
      final matchesQuery =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.location.toLowerCase().contains(query);
      return matchesQuery;
    }).toList();

    return Scaffold(
      extendBody: true,
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
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (cat) {
                    setState(() {
                      _selectedCategory = cat;
                    });
                    _loadDestinations();
                  },
                ),
                // const SizedBox(height: 20),

                // Curated Collections Section
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       const Text(
                //         "Koleksi\nPilihan",
                //         style: TextStyle(
                //           fontFamily: 'Plus Jakarta Sans',
                //           fontWeight: FontWeight.bold,
                //           fontSize: 24,
                //           color: textNavy,
                //           height: 1.2,
                //         ),
                //       ),
                //       TextButton(
                //         onPressed: () {},
                //         child: const Text(
                //           "LIHAT SEMUA",
                //           style: TextStyle(
                //             fontSize: 12,
                //             fontWeight: FontWeight.bold,
                //             color: primaryBlue,
                //             letterSpacing: 0.8,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // const SizedBox(height: 14),

                // SizedBox(
                //   height: 320,
                //   child: ListView.builder(
                //     padding: const EdgeInsets.symmetric(horizontal: 16),
                //     scrollDirection: Axis.horizontal,
                //     itemCount: _curatedCollections.length,
                //     itemBuilder: (context, index) {
                //       final item = _curatedCollections[index];
                //       return GestureDetector(
                //         onTap: () {
                //           Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //               builder: (context) => HalamanDestinationDetail(
                //                 user: widget.user,
                //                 destinationTitle: item['title'].replaceAll(
                //                   '\n',
                //                   ' ',
                //                 ),
                //                 categoryTag: item['tag'],
                //                 imageUrl: item['imageUrl'],
                //                 description:
                //                     'Jelajahi keindahan dan pengalaman eksklusif di ${item['title'].replaceAll('\n', ' ')}. Tempat liburan impian terbaik untuk merilekskan pikiran.',
                //               ),
                //             ),
                //           );
                //         },
                //         child: Container(
                //           width: 280,
                //           margin: const EdgeInsets.symmetric(horizontal: 8),
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(28),
                //             image: DecorationImage(
                //               image: NetworkImage(item['imageUrl']),
                //               fit: BoxFit.cover,
                //             ),
                //             boxShadow: [
                //               BoxShadow(
                //                 color: Colors.black.withValues(alpha: 0.12),
                //                 blurRadius: 16,
                //                 offset: const Offset(0, 6),
                //               ),
                //             ],
                //           ),
                //           child: Container(
                //             padding: const EdgeInsets.all(22),
                //             decoration: BoxDecoration(
                //               borderRadius: BorderRadius.circular(28),
                //               gradient: LinearGradient(
                //                 begin: Alignment.topCenter,
                //                 end: Alignment.bottomCenter,
                //                 colors: [
                //                   Colors.transparent,
                //                   Colors.black.withValues(alpha: 0.8),
                //                 ],
                //               ),
                //             ),
                //             child: Column(
                //               mainAxisAlignment: MainAxisAlignment.end,
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 Container(
                //                   padding: const EdgeInsets.symmetric(
                //                     horizontal: 12,
                //                     vertical: 6,
                //                   ),
                //                   decoration: BoxDecoration(
                //                     color: Colors.white.withValues(alpha: 0.25),
                //                     borderRadius: BorderRadius.circular(20),
                //                   ),
                //                   child: Text(
                //                     item['tag'],
                //                     style: const TextStyle(
                //                       fontSize: 10,
                //                       fontWeight: FontWeight.bold,
                //                       color: Colors.white,
                //                       letterSpacing: 1.0,
                //                     ),
                //                   ),
                //                 ),
                //                 const SizedBox(height: 10),
                //                 Text(
                //                   item['title'],
                //                   style: const TextStyle(
                //                     fontSize: 26,
                //                     fontWeight: FontWeight.bold,
                //                     color: Colors.white,
                //                     fontFamily: 'Plus Jakarta Sans',
                //                     height: 1.1,
                //                   ),
                //                 ),
                //                 const SizedBox(height: 8),
                //                 Row(
                //                   children: [
                //                     const Icon(
                //                       Icons.location_on_rounded,
                //                       color: Colors.white70,
                //                       size: 16,
                //                     ),
                //                     const SizedBox(width: 4),
                //                     Text(
                //                       item['destinations'],
                //                       style: const TextStyle(
                //                         fontSize: 13,
                //                         color: Colors.white70,
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       );
                //     },
                //   ),
                // ),
                // const SizedBox(height: 32),

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

                      if (_isLoadingDestinations)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: primaryBlue,
                            ),
                          ),
                        )
                      else if (filteredList.isEmpty)
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
                            final itemId = item.id;
                            final isFav =
                                itemId != null && _favorites.contains(itemId);
                            final priceText = item.estimatedBudget > 0
                                ? 'mulai Rp ${(item.estimatedBudget / 1000000).toStringAsFixed(1).replaceAll('.0', '')}jt'
                                : 'mulai Rp 1.5jt';

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HalamanDestinationDetail(
                                      user: widget.user,
                                      destinationTitle: item.name,
                                      categoryTag:
                                          (item.placeType ?? item.category)
                                              .toUpperCase(),
                                      imageUrl: item.image,
                                      rating: item.rating.toString(),
                                      pricePerDay: priceText,
                                      description: item.description.isNotEmpty
                                          ? item.description
                                          : 'Tinggalkan rutinitas dan nikmati keindahan ${item.name}. Temukan berbagai atraksi budaya, alam, serta kuliner khas yang memukau.',
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
                                            item.image,
                                            height: 140,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                                      height: 140,
                                                      color:
                                                          Colors.grey.shade300,
                                                      child: const Icon(
                                                        Icons.image,
                                                        size: 40,
                                                      ),
                                                    ),
                                          ),
                                        ),

                                        // Favorite Heart Button
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () async {
                                              if (itemId == null) return;
                                              final userId =
                                                  widget.user?.id ?? 1;
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
                                                          '${item.name} dihapus dari Saved Places',
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
                                                        item,
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
                                              priceText,
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
                                            item.name,
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
                                                "${item.rating} (4.8k)",
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
                const SizedBox(height: 120),
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
