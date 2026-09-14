import 'dart:async';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:project_tride/Constants/app_colors.dart';
import 'package:project_tride/Database/destination_model.dart';
import 'package:project_tride/Database/trip_model.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Services/destination_service.dart';
import 'package:project_tride/Services/saved_places_service.dart';
import 'package:project_tride/Services/trip_service.dart';

import '../../Widgets/custom_floating_nav_bar.dart';
import '../halaman Ai Planner/halaman_aiplanner_step1.dart';
import '../halaman budget/halaman_budget.dart';
import '../halaman explore/halaman_jelajah.dart';
import '../halaman profile/halaman_profil.dart';
import '../halaman profile/halaman_saved_places.dart';
import 'halaman_destination_detail.dart';
import 'halaman_destination_search.dart';
import 'halaman_trip_detail.dart';

class HalamanBeranda extends StatefulWidget {
  final UserModel? user;
  final int initialTab;
  final bool isEmbeddedInShell;
  final ValueChanged<int>? onSwitchTab;

  const HalamanBeranda({
    super.key,
    this.user,
    this.initialTab = 0,
    this.isEmbeddedInShell = false,
    this.onSwitchTab,
  });

  @override
  State<HalamanBeranda> createState() => _HalamanBerandaState();
}

class _HalamanBerandaState extends State<HalamanBeranda> {
  late int _currentNavIndex;
  final Set<int> _favoritedDestinations = {};
  final TextEditingController _searchController = TextEditingController();
  TripModel? _upcomingTrip;
  bool _isLoadingTrip = true;
  StreamSubscription<TripModel?>? _upcomingTripSubscription;

  final List<Map<String, dynamic>> _popularDestinations = [
    {
      'id': 46,
      'title': 'Raja Ampat',
      'subtitle': 'Surga Bahari Dunia',
      'imageUrl':
          'https://images.unsplash.com/photo-1516690561799-46d8f74f9abf?q=80&w=800&auto=format&fit=crop',
      'location': 'Papua Barat Daya · Bahari',
      'category': 'Bahari',
      'rating': 5.0,
    },
    {
      'id': 1,
      'title': 'Borobudur',
      'subtitle': 'Kemegahan Candi Buddha',
      'imageUrl':
          'https://images.unsplash.com/photo-1596402184320-417e7178b2cd?q=80&w=800&auto=format&fit=crop',
      'location': 'Jawa Tengah · Budaya',
      'category': 'Budaya',
      'rating': 4.9,
    },
    {
      'id': 23,
      'title': 'Pulau Padar (Komodo)',
      'subtitle': 'Pesona Alam Prasejarah',
      'imageUrl':
          'https://images.unsplash.com/photo-1516690561799-46d8f74f9abf?q=80&w=800&auto=format&fit=crop',
      'location': 'Nusa Tenggara Timur · Alam',
      'category': 'Alam',
      'rating': 4.9,
    },
    {
      'id': 3,
      'title': 'Gunung Bromo',
      'subtitle': 'Kaldera & Sunrise Magis',
      'imageUrl':
          'https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272?q=80&w=800&auto=format&fit=crop',
      'location': 'Jawa Timur · Petualangan',
      'category': 'Petualangan',
      'rating': 4.9,
    },
    {
      'id': 16,
      'title': 'Ubud Sanctuary',
      'subtitle': 'Ketenangan Sawah & Seni',
      'imageUrl':
          'https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=800&auto=format&fit=crop',
      'location': 'Bali · Budaya',
      'category': 'Budaya',
      'rating': 4.9,
    },
    {
      'id': 39,
      'title': 'Tana Toraja',
      'subtitle': 'Tradisi Megalitik Kuno',
      'imageUrl':
          'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?q=80&w=800&auto=format&fit=crop',
      'location': 'Sulawesi Selatan · Budaya',
      'category': 'Budaya',
      'rating': 4.9,
    },
  ];

  final List<Map<String, dynamic>> _experiences = [
    {
      'title': 'Petualangan',
      'imageUrl':
          'https://images.unsplash.com/photo-1501555088652-021faa106b9b?q=80&w=400&auto=format&fit=crop',
    },
    {
      'title': 'Kuliner',
      'imageUrl':
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=400&auto=format&fit=crop',
    },
    {
      'title': 'Kebugaran',
      'imageUrl':
          'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=400&auto=format&fit=crop',
    },
    {
      'title': 'Budaya',
      'imageUrl':
          'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?q=80&w=400&auto=format&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.initialTab;
    _loadFavorites();
    _loadPopularDestinations();
    _loadUpcomingTrip();
    _listenUpcomingTripStream();
  }

  void _listenUpcomingTripStream() {
    _upcomingTripSubscription?.cancel();
    _upcomingTripSubscription = TripService.instance
        .streamUpcomingTrip(uid: widget.user?.id?.toString())
        .listen((trip) {
          if (mounted) {
            setState(() {
              _upcomingTrip = trip;
              _isLoadingTrip = false;
            });
          }
        });
  }

  Future<void> _loadUpcomingTrip() async {
    try {
      if (mounted) {
        setState(() {
          _isLoadingTrip = true;
          _upcomingTrip = null;
        });
      }
      final trip = await TripService.instance.getUpcomingTrip();
      if (mounted) {
        setState(() {
          _upcomingTrip = trip;
          _isLoadingTrip = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _upcomingTrip = null;
          _isLoadingTrip = false;
        });
      }
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final favs = await SavedPlacesService.instance.getFavoriteIds();
      if (mounted) {
        setState(() {
          _favoritedDestinations.clear();
          _favoritedDestinations.addAll(favs);
        });
      }
    } catch (_) {}
  }

  Future<void> _loadPopularDestinations() async {
    try {
      final dests = await DestinationService.instance.getPopularDestinations(
        limit: 6,
      );
      if (dests.isNotEmpty && mounted) {
        setState(() {
          _popularDestinations.clear();
          for (final d in dests) {
            _popularDestinations.add({
              'id': d.id,
              'title': d.name,
              'subtitle': d.location,
              'imageUrl': d.image,
              'location': '${d.location} · ${d.category}',
              'category': d.category,
              'rating': d.rating,
            });
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _upcomingTripSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    if (index == _currentNavIndex) return;

    switch (index) {
      case 0:
        setState(() {
          _currentNavIndex = 0;
        });
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HalamanJelajah(user: widget.user),
          ),
        );
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

    final userName = widget.user?.nama ?? 'Traveler';

    return Scaffold(
      extendBody: true,
      backgroundColor: bgCloud,
      body: CustomScrollView(
        slivers: [
          // Fixed Top App Bar
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
                    ).then((_) => _loadFavorites());
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
                    if (widget.onSwitchTab != null) {
                      widget.onSwitchTab!(4);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HalamanProfil(user: widget.user),
                        ),
                      );
                    }
                  },
                  child: GFAvatar(
                    radius: 19,
                    shape: GFAvatarShape.circle,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/image/playstore.png',
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                              'assets/image/playstore.png',
                              width: 38,
                              height: 38,
                              fit: BoxFit.cover,
                            ),
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
                // Hero Section
                Stack(
                  children: [
                    SizedBox(
                      height: 380,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              'https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=1000&auto=format&fit=crop',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                    'assets/image/bali.jpeg',
                                    fit: BoxFit.cover,
                                  ),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.1),
                                    Colors.black.withValues(alpha: 0.75),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Good morning, $userName",
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Plus Jakarta Sans',
                              shadows: [
                                Shadow(color: Colors.black45, blurRadius: 8),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Escape to paradise. Where will your next journey take you?",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Floating Search Bar
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HalamanDestinationSearch(
                                        user: widget.user,
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.search_rounded,
                                    color: primaryBlue,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      "Where to?",
                                      style: TextStyle(
                                        color: Colors.black45,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE7E7F3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.tune_rounded,
                                      color: primaryBlue,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // AI Entry Point Banner
                Transform.translate(
                  offset: const Offset(0, -16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HalamanAiPlanner(user: widget.user),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Plan a trip with AI",
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: textNavy,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Describe your dream getaway...",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: primaryBlue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Upcoming Trip Section
                _buildUpcomingTripSection(textNavy, primaryBlue, bgCloud),

                // Popular Destinations Carousel Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Destinasi Populer",
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: textNavy,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HalamanJelajah(user: widget.user),
                                ),
                              );
                            },
                            child: const Text(
                              "LIHAT SEMUA",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 320,
                      child: Swiper(
                        itemCount: _popularDestinations.length,
                        viewportFraction: 0.8,
                        scale: 0.88,
                        pagination: const SwiperPagination(
                          alignment: Alignment.bottomCenter,
                          builder: DotSwiperPaginationBuilder(
                            activeColor: AppColors.primaryDeep,
                            color: AppColors.surfaceVariant,
                            size: 6,
                            activeSize: 8,
                            space: 4,
                          ),
                        ),
                        itemBuilder: (context, index) {
                          final item = _popularDestinations[index];
                          final isFav = _favoritedDestinations.contains(
                            item['id'],
                          );

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HalamanDestinationDetail(
                                    user: widget.user,
                                    destinationId: item['id'] as int?,
                                    destinationTitle:
                                        '${item['title']}, ${item['subtitle']}',
                                    imageUrl: item['imageUrl'],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.network(
                                        item['imageUrl'],
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (
                                              context,
                                              error,
                                              stackTrace,
                                            ) => Container(
                                              color: AppColors.surfaceVariant,
                                              child: const Icon(
                                                Icons.landscape_rounded,
                                                size: 48,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withValues(
                                                alpha: 0.8,
                                              ),
                                            ],
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Heart Favorite Button
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: GestureDetector(
                                                onTap: () async {
                                                  final itemId =
                                                      item['id'] as int;
                                                  final isCurrentlyFav =
                                                      _favoritedDestinations
                                                          .contains(itemId);
                                                  final messenger =
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      );

                                                  try {
                                                    if (isCurrentlyFav) {
                                                      await SavedPlacesService
                                                          .instance
                                                          .removeFavorite(
                                                            itemId,
                                                          );
                                                      if (mounted) {
                                                        setState(() {
                                                          _favoritedDestinations
                                                              .remove(itemId);
                                                        });
                                                        messenger
                                                            .removeCurrentSnackBar();
                                                        messenger.showSnackBar(
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
                                                      final destModel = DestinationModel(
                                                        id: itemId,
                                                        name: item['title'],
                                                        location:
                                                            item['location'] ??
                                                            item['subtitle'],
                                                        description:
                                                            item['subtitle'],
                                                        image: item['imageUrl'],
                                                        category:
                                                            item['category'] ??
                                                            'Culture',
                                                        rating:
                                                            (item['rating']
                                                                    as num?)
                                                                ?.toDouble() ??
                                                            4.8,
                                                      );

                                                      await SavedPlacesService
                                                          .instance
                                                          .addFavorite(
                                                            destModel,
                                                          );
                                                      if (mounted) {
                                                        setState(() {
                                                          _favoritedDestinations
                                                              .add(itemId);
                                                        });
                                                      }

                                                      if (context.mounted) {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                HalamanSavedPlaces(
                                                                  user: widget
                                                                      .user,
                                                                ),
                                                          ),
                                                        ).then(
                                                          (_) =>
                                                              _loadFavorites(),
                                                        );
                                                      }
                                                    }
                                                  } catch (_) {}
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    9,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withValues(
                                                          alpha: 0.25,
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
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Destination Text
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['title'],
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontFamily:
                                                        'Plus Jakarta Sans',
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  item['subtitle'],
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white
                                                        .withValues(
                                                          alpha: 0.85,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // Explore by Experience Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Jelajahi Berdasarkan Pengalaman",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: textNavy,
                        ),
                      ),
                      const SizedBox(height: 16),

                      GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 2.1,
                            ),
                        itemCount: _experiences.length,
                        itemBuilder: (context, index) {
                          final exp = _experiences[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HalamanJelajah(user: widget.user),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: NetworkImage(exp['imageUrl']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.black.withValues(alpha: 0.4),
                                ),
                                child: Center(
                                  child: Text(
                                    exp['title'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black54,
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 120),
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
              selectedIndex: _currentNavIndex,
              onDestinationSelected: _onNavTapped,
            ),
    );
  }

  String _formatDepartureDate(String dateStr) {
    if (dateStr.isEmpty) return 'TBA';
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        'JAN',
        'FEB',
        'MAR',
        'APR',
        'MEI',
        'JUN',
        'JUL',
        'AGU',
        'SEP',
        'OKT',
        'NOV',
        'DES',
      ];
      return "${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDurationDays(String startStr, String endStr) {
    try {
      final start = DateTime.parse(startStr);
      final end = DateTime.parse(endStr);
      final days = end.difference(start).inDays + 1;
      return "$days ${days > 1 ? 'DAYS' : 'DAY'}";
    } catch (_) {
      return '1 DAY';
    }
  }

  Widget _buildUpcomingTripSection(
    Color textNavy,
    Color primaryBlue,
    Color bgCloud,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Upcoming Trip",
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: textNavy,
                ),
              ),
              if (_upcomingTrip != null)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HalamanTripDetail(
                          user: widget.user,
                          trip: _upcomingTrip,
                        ),
                      ),
                    ).then((_) => _loadUpcomingTrip());
                  },
                  child: Text(
                    "Lihat Detail",
                    style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          if (_isLoadingTrip)
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          else if (_upcomingTrip == null)
            // Empty Trip State (No fake / dummy trips!)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: primaryBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.luggage_outlined,
                      color: primaryBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "Belum Ada Rencana Perjalanan",
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textNavy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Rencanakan liburan impianmu dengan mudah dan cepat menggunakan AI Planner.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HalamanAiPlanner(user: widget.user),
                        ),
                      ).then((_) => _loadUpcomingTrip());
                    },
                    icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: const Text("Mulai Rencana Baru"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            )
          else
            // Boarding Pass Ticket for Real Upcoming Trip
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HalamanTripDetail(
                      user: widget.user,
                      trip: _upcomingTrip,
                      title: _upcomingTrip!.tripName,
                      dateRange:
                          '${_upcomingTrip!.startDate} - ${_upcomingTrip!.endDate}',
                      status: _upcomingTrip!.status,
                      imageUrl:
                          _upcomingTrip!.imageUrl ??
                          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=800&auto=format&fit=crop',
                    ),
                  ),
                ).then((_) => _loadUpcomingTrip());
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Ticket Top Stub
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "DEPARTURE",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade500,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDepartureDate(_upcomingTrip!.startDate),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textNavy,
                                ),
                              ),
                            ],
                          ),

                          // Orbit Ring Motif Indicator
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primaryBlue.withValues(alpha: 0.2),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2563EB),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.flight_takeoff_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "DURATION",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade500,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDurationDays(
                                  _upcomingTrip!.startDate,
                                  _upcomingTrip!.endDate,
                                ),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textNavy,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Perforation Dashed Line
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 24,
                          decoration: BoxDecoration(
                            color: bgCloud,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                        ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Flex(
                                direction: Axis.horizontal,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  (constraints.constrainWidth() / 10).floor(),
                                  (_) => SizedBox(
                                    width: 5,
                                    height: 1.5,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          width: 12,
                          height: 24,
                          decoration: BoxDecoration(
                            color: bgCloud,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Ticket Bottom Image & Info
                    Container(
                      height: 170,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                        image: DecorationImage(
                          image: NetworkImage(
                            _upcomingTrip!.imageUrl ??
                                'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=800&auto=format&fit=crop',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
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
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryBlue.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _upcomingTrip!.status.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _upcomingTrip!.tripName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _upcomingTrip!.destinationLocation ??
                                      _upcomingTrip!.destinationName ??
                                      'Indonesia',
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
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
