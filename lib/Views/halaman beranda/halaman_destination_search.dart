import 'package:flutter/material.dart';
import 'package:project_tride/Constants/app_colors.dart';
import 'package:project_tride/Models/user_model.dart';
import '../../Widgets/custom_floating_nav_bar.dart';
import '../halaman Ai Planner/halaman_aiplanner_step1.dart';
import '../halaman budget/halaman_budget.dart';
import '../halaman explore/halaman_jelajah.dart';
import '../halaman profile/halaman_profil.dart';
import 'halaman_beranda.dart';
import 'halaman_destination_detail.dart';

class HalamanDestinationSearch extends StatefulWidget {
  final UserModel? user;

  const HalamanDestinationSearch({super.key, this.user});

  @override
  State<HalamanDestinationSearch> createState() =>
      _HalamanDestinationSearchState();
}

class _HalamanDestinationSearchState extends State<HalamanDestinationSearch> {
  final TextEditingController _searchController = TextEditingController();
  final int _currentNavIndex = 0;
  String _searchQuery = '';

  final List<String> _recentSearches = [
    'Bali',
    'Tokyo',
    'Paris',
    'Kyoto',
    'Seoul',
  ];

  final List<Map<String, String>> _trendingDestinations = [
    {
      'title': 'Bangkok',
      'subtitle': 'Thailand',
      'imageUrl':
          'https://images.unsplash.com/photo-1508009603885-50cf7c579365?q=80&w=800&auto=format&fit=crop',
    },
    {
      'title': 'Seoul',
      'subtitle': 'South Korea',
      'imageUrl':
          'https://images.unsplash.com/photo-1538485399081-7191377e8241?q=80&w=800&auto=format&fit=crop',
    },
    {
      'title': 'Bandung',
      'subtitle': 'Indonesia',
      'imageUrl':
          'https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272?q=80&w=800&auto=format&fit=crop',
    },
    {
      'title': 'Singapura',
      'subtitle': 'Singapore',
      'imageUrl':
          'https://images.unsplash.com/photo-1525625293386-3f8f99389edd?q=80&w=800&auto=format&fit=crop',
    },
    {
      'title': 'Ubud',
      'subtitle': 'Bali, Indonesia',
      'imageUrl':
          'https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=800&auto=format&fit=crop',
    },
    {
      'title': 'Lombok',
      'subtitle': 'Indonesia',
      'imageUrl':
          'https://images.unsplash.com/photo-1570789210967-2cac24afeb00?q=80&w=800&auto=format&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    if (index == _currentNavIndex) return;

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
    const Color outlineColor = AppColors.textSecondary;

    final filteredDestinations = _trendingDestinations.where((dest) {
      if (_searchQuery.isEmpty) return true;
      return dest['title']!.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          dest['subtitle']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: bgCloud,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HalamanBeranda(user: widget.user),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.arrow_back, color: textNavy),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEDF9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: outlineColor,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: const TextStyle(
                                fontSize: 14,
                                color: textNavy,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Cari destinasi...',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: outlineColor,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFC3C6D7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Recent Searches
                    const Text(
                      'PENCARIAN TERAKHIR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: outlineColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _recentSearches.map((search) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              onTap: () {
                                _searchController.text = search;
                                _searchController.selection =
                                    TextSelection.fromPosition(
                                      TextPosition(offset: search.length),
                                    );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F3FE),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.03,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.history_rounded,
                                      size: 18,
                                      color: outlineColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      search,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: textNavy,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Section 2: Trending Destinations
                    const Text(
                      'Destinasi Trending',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Plus Jakarta Sans',
                        color: textNavy,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (filteredDestinations.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 56,
                              color: outlineColor.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Destinasi "$_searchQuery" tidak ditemukan',
                              style: const TextStyle(
                                fontSize: 15,
                                color: outlineColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                            ),
                        itemCount: filteredDestinations.length,
                        itemBuilder: (context, index) {
                          final item = filteredDestinations[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HalamanDestinationDetail(
                                    user: widget.user,
                                    destinationTitle: item['title'] != null && item['subtitle'] != null
                                        ? '${item['title']}, ${item['subtitle']}'
                                        : (item['title'] ?? 'Bali, Indonesia'),
                                    imageUrl: item['imageUrl'] ??
                                        'https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=1200&auto=format&fit=crop',
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      item['imageUrl']!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                color: primaryBlue.withValues(
                                                  alpha: 0.1,
                                                ),
                                                child: const Icon(
                                                  Icons.landscape,
                                                  color: primaryBlue,
                                                  size: 40,
                                                ),
                                              ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withValues(
                                              alpha: 0.75,
                                            ),
                                            Colors.black.withValues(alpha: 0.2),
                                            Colors.transparent,
                                          ],
                                          stops: const [0.0, 0.5, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 16,
                                    left: 16,
                                    right: 16,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title']!,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'Plus Jakarta Sans',
                                            shadows: [
                                              Shadow(
                                                color: Colors.black45,
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (item['subtitle'] != null)
                                          Text(
                                            item['subtitle']!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white.withValues(
                                                alpha: 0.85,
                                              ),
                                            ),
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
            ),
          ],
        ),
      ),
      // Integrated Floating Bottom Navigation Bar
      bottomNavigationBar: CustomFloatingNavBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: _onNavTapped,
      ),
    );
  }
}
