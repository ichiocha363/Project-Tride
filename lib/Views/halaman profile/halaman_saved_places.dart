import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_tride/Constants/app_colors.dart';
import 'package:project_tride/Database/db_helper.dart';
import 'package:project_tride/Database/destination_model.dart';
import 'package:project_tride/Database/favorite_model.dart';
import 'package:project_tride/Database/user_model.dart';
import 'package:project_tride/Widgets/category_filter_bar.dart';
import 'package:project_tride/Widgets/destination_grid_card.dart';
import 'package:project_tride/Widgets/destination_hero_card.dart';
import '../halaman beranda/halaman_destination_detail.dart';

class HalamanSavedPlaces extends StatefulWidget {
  final UserModel? user;

  const HalamanSavedPlaces({super.key, this.user});

  @override
  State<HalamanSavedPlaces> createState() => _HalamanSavedPlacesState();
}

class _HalamanSavedPlacesState extends State<HalamanSavedPlaces> {
  String _selectedCategory = 'Semua';
  bool _isLoading = true;

  final List<String> _categories = [
    'Semua',
    'Pantai',
    'Pegunungan',
    'Perkotaan',
    'Pedesaan',
    'Alam',
  ];

  // List of saved places loaded from DB or default initial seed
  List<DestinationModel> _savedDestinations = [];
  final Set<int> _favoriteIds = {};

  // Initial seed dataset matching Stitch design mockup
  final List<DestinationModel> _initialSeedDestinations = [
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

  @override
  void initState() {
    super.initState();
    _loadSavedPlaces();
  }

  Future<void> _loadSavedPlaces() async {
    setState(() => _isLoading = true);
    try {
      final db = DbHelper.instance;
      final userId = widget.user?.id ?? 1;

      // Ensure seed destinations exist in SQLite
      for (var dest in _initialSeedDestinations) {
        await db.ensureDestinationExists(dest);
      }
      List<DestinationModel> dbDestinations = await db.getDestinations();

      // Ensure default saved places start empty for users.
      // Clean up old auto-seeded favorites once if present from previous version
      final prefs = await SharedPreferences.getInstance();
      final cleanupKey = 'has_cleared_auto_seed_v1_$userId';
      final hasClearedAutoSeed = prefs.getBool(cleanupKey) ?? false;
      if (!hasClearedAutoSeed) {
        // Clear initial auto-seeded favorites for a fresh empty starting state
        for (var dest in dbDestinations) {
          if (dest.id != null) {
            await db.removeFavorite(userId, dest.id!);
          }
        }
        await prefs.setBool(cleanupKey, true);
      }

      final updatedFavorites = await db.getFavoritesByUser(userId);
      final favDestIds = updatedFavorites.map((f) => f.destinationId).toSet();

      final filteredDestinations = dbDestinations
          .where((d) => d.id != null && favDestIds.contains(d.id!))
          .toList();

      setState(() {
        _savedDestinations = filteredDestinations;
        _favoriteIds.clear();
        _favoriteIds.addAll(favDestIds);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _savedDestinations = [];
        _favoriteIds.clear();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(DestinationModel destination) async {
    final destId = destination.id;
    if (destId == null) return;

    final userId = widget.user?.id ?? 1;
    final isFav = _favoriteIds.contains(destId);

    setState(() {
      if (isFav) {
        _favoriteIds.remove(destId);
        _savedDestinations.removeWhere((item) => item.id == destId);
      } else {
        _favoriteIds.add(destId);
        if (!_savedDestinations.any((item) => item.id == destId)) {
          _savedDestinations.add(destination);
        }
      }
    });

    try {
      if (isFav) {
        await DbHelper.instance.removeFavorite(userId, destId);
        if (!mounted) return;

        final messenger = ScaffoldMessenger.of(context);

        messenger.removeCurrentSnackBar();

        messenger.showSnackBar(
          SnackBar(
            backgroundColor: AppColors.textPrimary,
            content: Text('${destination.name} removed from Saved Places'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'Undo',
              textColor: const Color(0xFF7BD0FF),
              onPressed: () {
                _toggleFavorite(destination);
                messenger.removeCurrentSnackBar();
              },
            ),
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            messenger.removeCurrentSnackBar();
          }
        });
      } else {
        await DbHelper.instance.addFavorite(
          FavoriteModel(
            userId: userId,
            destinationId: destId,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
        if (mounted) {
          GFToast.showToast(
            '${destination.name} saved to wishlist!',
            context,
            toastPosition: GFToastPosition.BOTTOM,
            toastDuration: 1,
          );
        }
      }
    } catch (_) {}
  }

  List<DestinationModel> get _displayedDestinations {
    final activeFavorites = _savedDestinations
        .where((d) => _favoriteIds.contains(d.id))
        .toList();

    if (_selectedCategory == 'Semua' || _selectedCategory == 'All') {
      return activeFavorites;
    }
    return activeFavorites.where((d) {
      final type = d.placeType ?? d.category;
      return type.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final places = _displayedDestinations;
    final heroPlace = places.isNotEmpty
        ? places.firstWhere((p) => p.name == 'Rome', orElse: () => places.first)
        : null;

    final gridPlaces = heroPlace != null
        ? places.where((p) => p.id != heroPlace.id).toList()
        : places;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceLow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Saved Places",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Your personal travel wishlist",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "${places.length} places",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDeep,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.favorite_rounded,
                          color: AppColors.primaryDeep,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Category Filter Horizontal Bar
            CategoryFilterBar(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: (cat) {
                setState(() {
                  _selectedCategory = cat;
                });
              },
            ),
            const SizedBox(height: 16),

            // Main Scrollable Area
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryDeep),
                    )
                  : places.isEmpty
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 3. Featured Hero Card
                          if (heroPlace != null)
                            DestinationHeroCard(
                              title: heroPlace.name,
                              location: heroPlace.location,
                              imageUrl: heroPlace.image,
                              rating: heroPlace.rating,
                              isFavorite: _favoriteIds.contains(heroPlace.id),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HalamanDestinationDetail(
                                      user: widget.user,
                                      destinationTitle: heroPlace.name,
                                      categoryTag: heroPlace.category.toUpperCase(),
                                      imageUrl: heroPlace.image,
                                      rating: heroPlace.rating.toString(),
                                      description: heroPlace.description,
                                    ),
                                  ),
                                );
                              },
                              onFavoriteTap: () => _toggleFavorite(heroPlace),
                            ),

                          const SizedBox(height: 24),

                          // 4. Section Title
                          if (gridPlaces.isNotEmpty) ...[
                            const Text(
                              "All Saved Places",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // 5. Grid of Saved Places
                            GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: gridPlaces.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.76,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                              itemBuilder: (context, index) {
                                final place = gridPlaces[index];
                                return DestinationGridCard(
                                  title: place.name,
                                  location: place.location,
                                  imageUrl: place.image,
                                  rating: place.rating,
                                  isFavorite: _favoriteIds.contains(place.id),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HalamanDestinationDetail(
                                          user: widget.user,
                                          destinationTitle: place.name,
                                          categoryTag: place.category.toUpperCase(),
                                          imageUrl: place.image,
                                          rating: place.rating.toString(),
                                          description: place.description,
                                        ),
                                      ),
                                    );
                                  },
                                  onFavoriteTap: () => _toggleFavorite(place),
                                );
                              },
                            ),
                          ],
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surfaceLow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 56,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Saved Places Yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Explore destinations and tap the heart icon to add them to your wishlist.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
