import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:project_tride/Constants/app_colors.dart';
import 'package:project_tride/Database/destination_model.dart';
import 'package:project_tride/Database/user_model.dart';
import 'package:project_tride/Services/saved_places_service.dart';
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

  // List of saved places loaded from Firestore
  List<DestinationModel> _savedDestinations = [];
  final Set<int> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadSavedPlaces();
  }

  Future<void> _loadSavedPlaces() async {
    setState(() => _isLoading = true);
    try {
      final savedList = await SavedPlacesService.instance.getSavedPlaces();
      final favDestIds = savedList
          .where((d) => d.id != null)
          .map((d) => d.id!)
          .toSet();

      if (mounted) {
        setState(() {
          _savedDestinations = savedList;
          _favoriteIds.clear();
          _favoriteIds.addAll(favDestIds);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _savedDestinations = [];
          _favoriteIds.clear();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite(DestinationModel destination) async {
    final destId = destination.id;
    if (destId == null) return;

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
        await SavedPlacesService.instance.removeFavorite(destId);
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
        await SavedPlacesService.instance.addFavorite(destination);
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
                                      destinationId: heroPlace.id,
                                      destination: heroPlace,
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
                                          destinationId: place.id,
                                          destination: place,
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
