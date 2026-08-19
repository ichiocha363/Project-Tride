import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_tride/Database/db_helper.dart';
import 'package:project_tride/Database/destination_model.dart';
import 'package:project_tride/Database/favorite_model.dart';
import 'package:project_tride/Database/user_model.dart';
import '../halaman beranda/halaman_destination_detail.dart';

class HalamanSavedPlaces extends StatefulWidget {
  final UserModel? user;

  const HalamanSavedPlaces({super.key, this.user});

  @override
  State<HalamanSavedPlaces> createState() => _HalamanSavedPlacesState();
}

class _HalamanSavedPlacesState extends State<HalamanSavedPlaces> {
  String _selectedCategory = 'All';
  bool _isLoading = true;

  // Stitch Design Color Tokens
  static const Color primaryBlue = Color(0xFF004AC6);
  static const Color primaryContainer = Color(0xFF2563EB);
  static const Color bgCloud = Color(0xFFF8FAFC);
  static const Color textNavy = Color(0xFF0F172A);
  static const Color textSlate = Color(0xFF64748B);
  static const Color warmYellow = Color(0xFFFDB813);
  static const Color surfaceLow = Color(0xFFF3F3FE);
  static const Color primaryFixed = Color(0xFFDBE1FF);

  final List<String> _categories = [
    'All',
    'Nature',
    'Urban',
    'Relax',
    'Culture',
    'Adventure',
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
      List<DestinationModel> dbDestinations = await db.getDestinations();
      if (dbDestinations.isEmpty) {
        for (var dest in _initialSeedDestinations) {
          await db.insertDestination(dest);
        }
        dbDestinations = await db.getDestinations();
      }

      // Seed initial favorites once per user if never seeded before
      final prefs = await SharedPreferences.getInstance();
      final seedKey = 'has_seeded_favorites_v3_$userId';
      final hasSeeded = prefs.getBool(seedKey) ?? false;

      if (!hasSeeded) {
        final now = DateTime.now().toIso8601String();
        for (var dest in dbDestinations) {
          if (dest.id != null) {
            await db.addFavorite(
              FavoriteModel(
                userId: userId,
                destinationId: dest.id!,
                createdAt: now,
              ),
            );
          }
        }
        await prefs.setBool(seedKey, true);
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
            backgroundColor: textNavy,
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

    if (_selectedCategory == 'All') {
      return activeFavorites;
    }
    return activeFavorites
        .where(
          (d) => d.category.toLowerCase() == _selectedCategory.toLowerCase(),
        )
        .toList();
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
      backgroundColor: bgCloud,
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
                      decoration: BoxDecoration(
                        color: surfaceLow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: textNavy,
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
                            color: textNavy,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Your personal travel wishlist",
                          style: TextStyle(fontSize: 13, color: textSlate),
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
                      color: primaryFixed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "${places.length} places",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.favorite_rounded,
                          color: primaryBlue,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Category Filter Horizontal Bar
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF434655),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: primaryContainer,
                    backgroundColor: surfaceLow,
                    showCheckmark: false,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Main Scrollable Area
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryBlue),
                    )
                  : places.isEmpty
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 3. Featured Hero Card (Stitch Rome Concept)
                          if (heroPlace != null) _buildHeroCard(heroPlace),

                          const SizedBox(height: 24),

                          // 4. Section Title
                          if (gridPlaces.isNotEmpty) ...[
                            const Text(
                              "All Saved Places",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textNavy,
                                fontFamily: 'Plus Jakarta Sans',
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
                                return _buildGridCard(place);
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

  Widget _buildHeroCard(DestinationModel place) {
    return GestureDetector(
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
      child: Container(
        height: 210,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(
                  place.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFE1E2ED),
                    child: const Icon(
                      Icons.landscape_rounded,
                      size: 48,
                      color: textSlate,
                    ),
                  ),
                ),
              ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ),

              // Favorite Toggle Button (Top Right)
              Positioned(
                top: 14,
                right: 14,
                child: GestureDetector(
                  onTap: () => _toggleFavorite(place),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Icon(
                      _favoriteIds.contains(place.id)
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: primaryBlue,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Hero Card Content (Bottom)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            place.location,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Rating Pill (Glassmorphism effect)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: warmYellow,
                            size: 16,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            place.rating.toString(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(DestinationModel place) {
    final isFav = _favoriteIds.contains(place.id);
    return GestureDetector(
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(
                  place.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFE1E2ED),
                    child: const Icon(
                      Icons.landscape_rounded,
                      size: 36,
                      color: textSlate,
                    ),
                  ),
                ),
              ),

              // Dark Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ),

              // Favorite Icon Top-Right
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => _toggleFavorite(place),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: primaryBlue,
                      size: 17,
                    ),
                  ),
                ),
              ),

              // Card Bottom Info
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: warmYellow,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              place.rating.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      place.category,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
            decoration: BoxDecoration(
              color: surfaceLow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 56,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Saved Places Yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textNavy,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Explore destinations and tap the heart icon to add them to your wishlist.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: textSlate),
            ),
          ),
        ],
      ),
    );
  }
}
