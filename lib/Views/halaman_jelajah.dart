import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:project_tride/Constants/app_colors.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Views/halaman_budget.dart';
import 'package:project_tride/Views/halaman_login.dart';
import 'package:project_tride/Views/halaman_profil.dart';

class HalamanJelajah extends StatefulWidget {
  final UserModel? user;

  const HalamanJelajah({super.key, this.user});

  @override
  State<HalamanJelajah> createState() => _HalamanJelajahState();
}

class _HalamanJelajahState extends State<HalamanJelajah> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  String _activeFilter = 'popular'; // 'popular', 'rating', 'price'
  final Set<int> _favorites = {
    1,
  }; // Card 2 (Borobudur) favorited by default in Stitch HTML

  final List<String> _categories = [
    'Semua',
    'Pantai',
    'Gunung',
    'Kota',
    'Kuliner',
    'Budaya',
  ];

  final List<Map<String, dynamic>> _allDestinations = [
    {
      'id': 0,
      'title': 'Labuan Bajo',
      'location': 'Nusa Tenggara Timur',
      'rating': '4.9',
      'ratingValue': 4.9,
      'reviews': '(2.1k)',
      'popularity': 2100,
      'price': 'Rp 4.5M - 8M',
      'minPrice': 4500000,
      'category': 'Pantai',
      'imageUrl':
          'https://images.unsplash.com/photo-1516690561799-46d8f74f9abf?q=80&w=600&auto=format&fit=crop',
      'fallbackAsset': 'assets/image/bali.jpeg',
      'description':
          'Gugusan pulau eksotis di NTT dengan pemandangan Pulau Padar, komodo, dan perairan kristal bawah laut.',
    },
    {
      'id': 1,
      'title': 'Candi Borobudur',
      'location': 'Yogyakarta',
      'rating': '4.8',
      'ratingValue': 4.8,
      'reviews': '(5.4k)',
      'popularity': 5400,
      'price': 'Rp 1.2M - 3M',
      'minPrice': 1200000,
      'category': 'Budaya',
      'imageUrl':
          'https://images.unsplash.com/photo-1609137144813-7d9921338f24?q=80&w=600&auto=format&fit=crop',
      'fallbackAsset': 'assets/image/jogja.jpeg',
      'description':
          'Candi Buddha terbesar di dunia dengan relief bersejarah megah dan keindahan matahari terbit.',
    },
    {
      'id': 2,
      'title': 'Rancabali',
      'location': 'Bandung',
      'rating': '4.7',
      'ratingValue': 4.7,
      'reviews': '(1.2k)',
      'popularity': 1200,
      'price': 'Rp 800k - 2M',
      'minPrice': 800000,
      'category': 'Gunung',
      'imageUrl':
          'https://images.unsplash.com/photo-1544644181-1484b3fdfc62?q=80&w=600&auto=format&fit=crop',
      'fallbackAsset': 'assets/image/jogja.jpeg',
      'description':
          'Hamparan kebun teh hijau yang sejuk dan asri di Ciwidey, Bandung dengan pemandangan danau Situ Patenggang.',
    },
    {
      'id': 3,
      'title': 'Uluwatu',
      'location': 'Bali',
      'rating': '4.9',
      'ratingValue': 4.9,
      'reviews': '(8.9k)',
      'popularity': 8900,
      'price': 'Rp 3M - 6.5M',
      'minPrice': 3000000,
      'category': 'Pantai',
      'imageUrl':
          'https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=600&auto=format&fit=crop',
      'fallbackAsset': 'assets/image/bali.jpeg',
      'description':
          'Pura spektakuler di atas tebing samudera dengan atraksi Tari Kecak sunset yang memukau.',
    },
    {
      'id': 4,
      'title': 'Kep. Raja Ampat',
      'location': 'Papua Barat',
      'rating': '5.0',
      'ratingValue': 5.0,
      'reviews': '(950)',
      'popularity': 950,
      'price': 'Rp 8M - 15M',
      'minPrice': 8000000,
      'category': 'Pantai',
      'imageUrl':
          'https://images.unsplash.com/photo-1516690561799-46d8f74f9abf?q=80&w=600&auto=format&fit=crop',
      'fallbackAsset': 'assets/image/bali.jpeg',
      'description':
          'Surga bawah laut kelas dunia dengan gugusan pulau karst ikonik Wayag di Papua Barat.',
    },
    {
      'id': 5,
      'title': 'Desa Sade',
      'location': 'Lombok',
      'rating': '4.6',
      'ratingValue': 4.6,
      'reviews': '(1.8k)',
      'popularity': 1800,
      'price': 'Rp 2M - 4.5M',
      'minPrice': 2000000,
      'category': 'Budaya',
      'imageUrl':
          'https://images.unsplash.com/photo-1570789210967-2cac24afeb00?q=80&w=600&auto=format&fit=crop',
      'fallbackAsset': 'assets/image/jogja.jpeg',
      'description':
          'Desa tradisional suku Sasak yang kaya budaya, rumah adat unik, serta tenun khas Lombok.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HalamanLogin()),
      (route) => false,
    );
  }

  List<Map<String, dynamic>> _getFilteredDestinations() {
    final query = _searchController.text.toLowerCase().trim();
    final selectedCategory = _categories[_selectedCategoryIndex];

    List<Map<String, dynamic>> list = _allDestinations.where((item) {
      final matchesCategory =
          selectedCategory == 'Semua' ||
          (item['category'] as String).toLowerCase() ==
              selectedCategory.toLowerCase();

      final matchesQuery =
          query.isEmpty ||
          (item['title'] as String).toLowerCase().contains(query) ||
          (item['location'] as String).toLowerCase().contains(query) ||
          (item['category'] as String).toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();

    // Sorting
    if (_activeFilter == 'popular') {
      list.sort(
        (a, b) => (b['popularity'] as int).compareTo(a['popularity'] as int),
      );
    } else if (_activeFilter == 'rating') {
      list.sort(
        (a, b) =>
            (b['ratingValue'] as double).compareTo(a['ratingValue'] as double),
      );
    } else if (_activeFilter == 'price') {
      list.sort(
        (a, b) => (a['minPrice'] as int).compareTo(b['minPrice'] as int),
      );
    }

    return list;
  }

  void _showDestinationDetail(Map<String, dynamic> item) {
    const Color primaryBlue = Color(0xFF004AC6);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  item['imageUrl'] as String,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    item['fallbackAsset'] as String,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item['title'] as String,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFF59E0B),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item['rating'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFF434655),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item['location'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF434655),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                item['description'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF434655),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Perkiraan Biaya",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF737686),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['price'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Destinasi ${item['title']} ditambahkan ke rencana!",
                          ),
                          backgroundColor: primaryBlue,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Rencanakan",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF004AC6);
    const Color bgLight = Color(0xFFF8FAFC);
    final displayedDestinations = _getFilteredDestinations();

    return Scaffold(
      backgroundColor: bgLight,
      // Fixed Top Header matching Stitch HTML
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Image.asset(
                    'assets/image/playstore.png',
                    height: 32,
                    width: 32,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.flight_takeoff,
                      color: primaryBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Tride",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  // Notifications button
                  Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F3FE),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF434655),
                        size: 22,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Tidak ada notifikasi baru"),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // User Profile menu
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'logout') {
                        _logout();
                      }
                    },
                    offset: const Offset(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.user?.nama ?? 'User',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              widget.user?.email ?? 'user@tride.com',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Divider(),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout,
                              color: AppColors.error,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Keluar',
                              style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          widget.user?.nama.isNotEmpty == true
                              ? widget.user!.nama[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Sticky Top Section: Search Bar & Category Chips
          SliverToBoxAdapter(
            child: Container(
              color: bgLight,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.search,
                            color: Color(0xFF434655),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() {});
                              },
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF0F172A),
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Cari destinasi, kota, atau aktivitas',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF737686),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {});
                                        },
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          Container(
                            width: 34,
                            height: 34,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3F3FE),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.mic_none_rounded,
                                color: primaryBlue,
                                size: 18,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Pencarian suara diaktifkan...",
                                    ),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Category Chips Scrollable
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategoryIndex == index;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryBlue : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: primaryBlue.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.03,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF434655),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Filter Bar (Sort Buttons)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildFilterButton(
                            id: 'popular',
                            icon: Icons.sort_rounded,
                            label: 'Terpopuler',
                          ),
                          const SizedBox(width: 8),
                          _buildFilterButton(
                            id: 'rating',
                            icon: Icons.star_rounded,
                            label: 'Rating Tertinggi',
                          ),
                          const SizedBox(width: 8),
                          _buildFilterButton(
                            id: 'price',
                            icon: Icons.payments_rounded,
                            label: 'Budget Terendah',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Destination Grid (2 Columns) matching Stitch layout
          displayedDestinations.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Destinasi tidak ditemukan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF434655),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Coba kata kunci atau kategori lain",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF737686),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 90,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.68,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = displayedDestinations[index];
                      final isFav = _favorites.contains(item['id'] as int);

                      return _buildDestinationCard(item, isFav);
                    }, childCount: displayedDestinations.length),
                  ),
                ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("AI Travel Planner dibuka!"),
              duration: Duration(seconds: 1),
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Planner',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: 4,
        tabBuilder: (int index, bool isActive) {
          final icons = [
            Icons.home_outlined,
            Icons.explore,
            Icons.account_balance_wallet_outlined,
            Icons.person_outline_rounded,
          ];
          final labels = ['Beranda', 'Jelajah', 'Budget', 'Profil'];
          final color = isActive ? primaryBlue : const Color(0xFF434655);

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icons[index],
                size: 24,
                color: color,
              ),
              const SizedBox(height: 2),
              Text(
                labels[index],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          );
        },
        activeIndex: 1, // Jelajah page active index is 1
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        leftCornerRadius: 0,
        rightCornerRadius: 0,
        backgroundColor: Colors.white,
        shadow: BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, -1),
        ),
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HalamanBudget(user: widget.user),
              ),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HalamanProfil(user: widget.user),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFilterButton({
    required String id,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _activeFilter == id;
    const Color primaryBlue = Color(0xFF004AC6);

    return InkWell(
      onTap: () {
        setState(() {
          _activeFilter = id;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryBlue.withValues(alpha: 0.1)
              : const Color(0xFFF3F3FE),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? primaryBlue : const Color(0xFF434655),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? primaryBlue : const Color(0xFF434655),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard(Map<String, dynamic> item, bool isFav) {
    const Color primaryBlue = Color(0xFF004AC6);

    return GestureDetector(
      onTap: () => _showDestinationDetail(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with favorite heart toggle top right
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      item['imageUrl'] as String,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        item['fallbackAsset'] as String,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          final itemId = item['id'] as int;
                          if (_favorites.contains(itemId)) {
                            _favorites.remove(itemId);
                          } else {
                            _favorites.add(itemId);
                          }
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFav
                              ? AppColors.error
                              : const Color(0xFF434655),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Text content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] as String,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: Color(0xFF434655),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          item['location'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF434655),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 15,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        item['rating'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['reviews'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF737686),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['price'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required Color primaryColor,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? primaryColor : const Color(0xFF434655),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? primaryColor : const Color(0xFF434655),
            ),
          ),
        ],
      ),
    );
  }
}
